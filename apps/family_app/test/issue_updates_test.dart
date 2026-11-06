import 'dart:async';

import 'package:family_app/l10n/generated/app_localizations.dart';
import 'package:family_app/src/app.dart';
import 'package:family_app/src/screens/inbox_tab.dart';
import 'package:family_app/src/screens/trip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

Future<void> _pump(WidgetTester tester, Widget child, {String locale = 'en', double scale = 1}) async {
  tester.view.physicalSize = const Size(320, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: familyTheme(Brightness.light),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

List<Map<String, Object?>> _updates(String state) => [
  {
    'notification_id': 1,
    'trip_id': 't1',
    'template': 'trip_status_changed',
    'payload': {'to_status': state},
    'created_at': '2026-11-03T02:00:00Z',
  },
];

void main() {
  testWidgets('Updates refresh clears stale data and recovers after a failed read', (tester) async {
    var fail = false;
    var state = 'issue_reported';
    final api = FamilyApi((fn, params) async {
      if (fail) throw const RpcException('42501', 'not allowed');
      return _updates(state);
    });
    await _pump(tester, InboxTab(api: api));
    expect(find.textContaining('Service issue'), findsOneWidget);
    fail = true;
    await tapVisible(tester, byKey('updates-refresh'));
    expect(byKey('update-1'), findsNothing);
    expect(byKey('updates-error'), findsOneWidget);
    fail = false;
    state = 'returning';
    await tapVisible(tester, byKey('updates-refresh'));
    expect(find.textContaining('On the way home'), findsOneWidget);
    expect(byKey('updates-error'), findsNothing);
  });

  testWidgets('a slower Updates response cannot overwrite newer service status', (tester) async {
    final responses = <Completer<Object?>>[];
    await _pump(
      tester,
      InboxTab(
        api: FamilyApi((fn, params) {
          final response = Completer<Object?>();
          responses.add(response);
          return response.future;
        }),
      ),
    );
    await tester.tap(byKey('updates-refresh'));
    await tester.pumpAndSettle();
    responses[1].complete(_updates('returning'));
    await tester.pumpAndSettle();
    responses[0].complete(_updates('issue_reported'));
    await tester.pumpAndSettle();
    expect(find.textContaining('On the way home'), findsOneWidget);
    expect(find.textContaining('Service issue'), findsNothing);
  });

  testWidgets('Updates reloads persisted status on resume without polling', (tester) async {
    var calls = 0;
    var state = 'issue_reported';
    await _pump(
      tester,
      InboxTab(
        api: FamilyApi((fn, params) async {
          calls++;
          return _updates(state);
        }),
      ),
    );
    state = 'returning';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.textContaining('On the way home'), findsOneWidget);
    await tester.pump(const Duration(minutes: 1));
    expect(calls, 2);
  });

  for (final locale in ['en', 'te', 'hi']) {
    testWidgets('$locale issue details and Updates fit narrow 200% text', (tester) async {
      final backend = FakeFamilyBackend()
        ..addVisit(FakeVisit(id: 't1', pickupAt: DateTime.utc(2026, 11, 3, 1), status: TripStatus.returning));
      backend.addEvent(backend.visits['t1']!, TripStatus.issueReported, TransitionActor.companion, null);
      final patient = (await backend.api.myPatients()).single;
      final booking = (await backend.api.tripBoard('p1')).single;
      await _pump(
        tester,
        TripScreen(api: backend.api, patient: patient, booking: booking),
        locale: locale,
        scale: 2,
      );
      expect(byKey('visit-issue-help'), findsOneWidget);
      expect(byKey('cancel-trip'), findsNothing);
      final statusText = tester.renderObject<RenderParagraph>(
        find.descendant(of: byKey('status'), matching: find.byType(RichText)),
      );
      expect(statusText.softWrap, isTrue, reason: 'The status must wrap rather than fade horizontally');
      expect(statusText.didExceedMaxLines, isFalse, reason: 'The complete service status must remain readable');
      expect(tester.takeException(), isNull);
      await _pump(tester, InboxTab(api: backend.api), locale: locale, scale: 2);
      expect(byKey('update-1'), findsOneWidget);
      expect(byKey('updates-refresh'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
