// Manual evidence capture, not part of the regular *_test.dart suite.
// Run from apps/family_app: flutter test test/support/capture_family.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:family_app/l10n/generated/app_localizations.dart';
import 'package:family_app/src/app.dart';
import 'package:family_app/src/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'fake_backend.dart';

final captureNow = DateTime.utc(2026, 11, 12, 0, 30);
final captureKey = GlobalKey();

/// Synthetic specification examples exist only in this test harness.
class CaptureFamilyBackend extends FakeFamilyBackend {
  CaptureFamilyBackend({super.level}) {
    patients
      ..clear()
      ..addAll({'p1': 'Ravi Rao', 'p2': 'Lakshmi Rao'});
    addVisit(FakeVisit(id: 'visit-next', pickupAt: DateTime.utc(2026, 11, 12, 1, 30), companionName: 'Suresh Kumar'));
    addVisit(FakeVisit(id: 'visit-friday', pickupAt: DateTime.utc(2026, 11, 13, 1, 30), companionName: 'Suresh Kumar'));
    addVisit(
      FakeVisit(
        id: 'visit-past',
        pickupAt: DateTime.utc(2026, 11, 11, 1, 30),
        status: TripStatus.completed,
        companionName: 'Suresh Kumar',
      ),
    );
    inbox.addAll([
      {
        'notification_id': 1,
        'trip_id': 'visit-past',
        'template': 'trip_status_changed',
        'payload': {'trip_id': 'visit-past', 'to_status': 'completed'},
        'created_at': '2026-11-11T07:00:00Z',
      },
      {
        'notification_id': 2,
        'trip_id': 'visit-next',
        'template': 'companion_changed',
        'payload': {'trip_id': 'visit-next'},
        'created_at': '2026-11-12T00:20:00Z',
      },
    ]);
  }

  @override
  Future<Object?> rpc(String function, Map<String, Object?> params) async {
    final result = await super.rpc(function, params);
    if (function == 'family_my_patients') {
      return [
        for (final row in result! as List<Map<String, Object?>>)
          {
            ...row,
            'centre_name': 'City Dialysis Centre, Kukatpally',
            'access_level': row['patient_id'] == 'p2' ? 'viewer' : level.dbValue,
          },
      ];
    }
    if (function == 'family_trip_board') {
      return [
        for (final row in result! as List<Map<String, Object?>>)
          {...row, 'centre_name': 'City Dialysis Centre, Kukatpally'},
      ];
    }
    return result;
  }
}

Future<void> pumpCapture(
  WidgetTester tester,
  Widget child, {
  String language = 'en',
  Brightness brightness = Brightness.light,
  double scale = 1.15,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  final theme = familyTheme(brightness);
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      locale: Locale(language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'Nirmala'),
        primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'Nirmala'),
        navigationBarTheme: theme.navigationBarTheme.copyWith(
          labelTextStyle: WidgetStatePropertyAll(
            theme.navigationBarTheme.labelTextStyle!.resolve({})!.copyWith(fontFamily: 'Nirmala'),
          ),
        ),
        appBarTheme: theme.appBarTheme.copyWith(
          titleTextStyle: theme.textTheme.titleLarge?.copyWith(fontFamily: 'Nirmala'),
        ),
        listTileTheme: theme.listTileTheme.copyWith(
          titleTextStyle: theme.listTileTheme.titleTextStyle?.copyWith(fontFamily: 'Nirmala'),
          subtitleTextStyle: theme.listTileTheme.subtitleTextStyle?.copyWith(fontFamily: 'Nirmala'),
        ),
        chipTheme: theme.chipTheme.copyWith(labelStyle: theme.textTheme.labelLarge?.copyWith(fontFamily: 'Nirmala')),
        filledButtonTheme: FilledButtonThemeData(
          style: theme.filledButtonTheme.style!.copyWith(
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontFamily: 'Nirmala', fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: theme.outlinedButtonTheme.style!.copyWith(
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontFamily: 'Nirmala', fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: RepaintBoundary(key: captureKey, child: child!),
      ),
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

HomeScreen captureHome(CaptureFamilyBackend backend) => HomeScreen(
  api: backend.api,
  files: FakeVaultFiles(backend),
  photos: FakePhotoSource(),
  payments: FakePayments(backend),
  onLocaleChanged: (_) {},
  onSignOut: () async {},
  now: () => captureNow,
);

Future<void> captureShot(WidgetTester tester, String name) async {
  for (final element in find.byType(Image).evaluate()) {
    await tester.runAsync(() => precacheImage((element.widget as Image).image, element));
  }
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  final boundary = captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('../../docs/evidence/family-screens-v2/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    for (final font in <(String, String)>[
      ('Nirmala', 'C:/Windows/Fonts/Nirmala.ttc'),
      ('Ahem', 'D:/AI-Workspace/tools/flutter/bin/cache/artifacts/material_fonts/roboto-regular.ttf'),
      ('MaterialIcons', 'D:/AI-Workspace/tools/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf'),
    ]) {
      final loader = FontLoader(font.$1)
        ..addFont(Future.value(ByteData.sublistView(await File(font.$2).readAsBytes())));
      await loader.load();
    }
  });

  testWidgets('capture Group 1 actual synthetic widget renders', (tester) async {
    addTearDown(tester.view.reset);
    for (final variant in <(String, AccessLevel, String, Brightness, double)>[
      ('F12-home-owner-light', AccessLevel.owner, 'en', Brightness.light, 1.15),
      ('F12-home-owner-dark', AccessLevel.owner, 'en', Brightness.dark, 1.15),
      ('F12-home-owner-te', AccessLevel.owner, 'te', Brightness.light, 1.15),
      ('F12-home-owner-200pct', AccessLevel.owner, 'en', Brightness.light, 2),
      ('F34-home-viewer', AccessLevel.viewer, 'en', Brightness.light, 1.15),
      ('F35-home-patient', AccessLevel.patient, 'en', Brightness.light, 1.15),
    ]) {
      await pumpCapture(
        tester,
        captureHome(CaptureFamilyBackend(level: variant.$2)),
        language: variant.$3,
        brightness: variant.$4,
        scale: variant.$5,
      );
      await captureShot(tester, variant.$1);
      if (variant.$1 == 'F12-home-owner-light' || variant.$1 == 'F35-home-patient') {
        await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -550));
        await tester.pumpAndSettle();
        await captureShot(tester, '${variant.$1}-scrolled');
      }
    }
    await pumpCapture(tester, captureHome(CaptureFamilyBackend()));
    await tester.tap(find.byKey(const Key('patient-picker')));
    await tester.pumpAndSettle();
    await captureShot(tester, 'F13-patient-picker');
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
