// Manual evidence capture, not part of the regular *_test.dart suite.
// Run from apps/family_app: flutter test test/support/capture_legal.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:family_app/l10n/generated/app_localizations.dart';
import 'package:family_app/src/app.dart';
import 'package:family_app/src/legal/legal_documents_en.dart';
import 'package:family_app/src/screens/consent_screen.dart';
import 'package:family_app/src/screens/legal_document_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_backend.dart';

final _key = GlobalKey();

Future<void> _pump(
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
        appBarTheme: theme.appBarTheme.copyWith(
          titleTextStyle: theme.textTheme.titleLarge?.copyWith(fontFamily: 'Nirmala'),
        ),
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(textStyle: WidgetStatePropertyAll(TextStyle(fontFamily: 'Nirmala', fontSize: 16))),
        ),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: RepaintBoundary(key: _key, child: child!),
      ),
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _shot(WidgetTester tester, String name) async {
  for (final element in find.byType(Image).evaluate()) {
    await tester.runAsync(() => precacheImage((element.widget as Image).image, element));
  }
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  final boundary = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('../../docs/evidence/legal-documents/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    for (final font in <(String, String)>[
      ('Nirmala', 'C:/Windows/Fonts/Nirmala.ttc'),
      ('MaterialIcons', 'D:/AI-Workspace/tools/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf'),
    ]) {
      final loader = FontLoader(font.$1)
        ..addFont(Future.value(ByteData.sublistView(await File(font.$2).readAsBytes())));
      await loader.load();
    }
  });

  testWidgets('capture legal draft screens from the real widgets', (tester) async {
    addTearDown(tester.view.reset);
    for (final (name, language, brightness, scale) in <(String, String, Brightness, double)>[
      ('privacy-draft-light', 'en', Brightness.light, 1.15),
      ('privacy-draft-dark', 'en', Brightness.dark, 1.15),
      ('privacy-draft-te', 'te', Brightness.light, 1.15),
      ('privacy-draft-hi-200pct', 'hi', Brightness.light, 2),
    ]) {
      await _pump(
        tester,
        const LegalDocumentScreen(document: privacyNoticeEn),
        language: language,
        brightness: brightness,
        scale: scale,
      );
      await _shot(tester, name);
    }
    await _pump(tester, const LegalDocumentScreen(document: termsOfServiceEn));
    await _shot(tester, 'terms-draft-light');
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await _shot(tester, 'terms-draft-light-scrolled');

    final backend = FakeFamilyBackend();
    final patient = (await backend.api.myPatients()).single;
    await _pump(tester, ConsentScreen(api: backend.api, patient: patient));
    await _shot(tester, 'consent-with-document-links');
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
