import 'dart:async';

import 'package:family_app/l10n/generated/app_localizations.dart';
import 'package:family_app/src/app.dart';
import 'package:family_app/src/screens/bookings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

Future<void> pumpBookings(
  WidgetTester tester,
  FakeFamilyBackend backend, {
  String language = 'en',
  FamilyApi? api,
}) async {
  usePhoneScreen(tester);
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
      theme: familyTheme(Brightness.light),
      builder: largeText,
      home: Scaffold(
        body: BookingsTab(
          api: api ?? backend.api,
          patient: FamilyPatient(
            patientId: 'p1',
            fullName: 'Lakshmi Rao (synthetic)',
            accessLevel: backend.level,
            centreName: 'Centre 1',
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String futureDate() {
  final date = toIst(DateTime.now()).add(const Duration(days: 2));
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

Future<void> reviewRequest(WidgetTester tester) async {
  await tapVisible(tester, byKey('request-care'));
  await tapVisible(tester, byKey('care-package'));
  await tapVisible(tester, find.text('Basic').last);
  await tester.enterText(byKey('care-date'), futureDate());
  await tester.enterText(byKey('care-time'), '07:15');
  await tapVisible(tester, byKey('care-review'));
}

List<Map<String, Object?>> requestRows(String state) => [
  {
    'schedule_id': 's1',
    'patient_id': 'p1',
    'patient_name': 'Lakshmi Rao (synthetic)',
    'centre_id': 'c1',
    'centre_name': 'Centre 1',
    'package_id': 'basic',
    'package_name': 'Basic',
    'pickup_at': '2026-11-04T01:45:00Z',
    'trip_id': 't1',
    'trip_status': state,
    'companion_name': 'Asha Companion (synthetic)',
    'request_state': state,
  },
];

void main() {
  testWidgets('a slower bookings response cannot replace the latest care status', (tester) async {
    final responses = <Completer<Object?>>[];
    await pumpBookings(
      tester,
      FakeFamilyBackend(),
      api: FamilyApi((fn, params) async {
        if (fn == 'family_trip_board') return <Object?>[];
        final response = Completer<Object?>();
        responses.add(response);
        return response.future;
      }),
    );
    await tapVisible(tester, byKey('care-refresh'));
    responses[1].complete(requestRows('completed'));
    await tester.pumpAndSettle();
    responses[0].complete(requestRows('issue_reported'));
    await tester.pumpAndSettle();
    expect(find.text('Visit complete'), findsOneWidget);
    expect(find.text('Service issue'), findsNothing);
  });

  testWidgets('failed bookings refresh clears old cards and recovers without replaying a request', (tester) async {
    var fail = false;
    final backend = FakeFamilyBackend()
      ..addVisit(
        FakeVisit(
          id: 'old',
          pickupAt: DateTime.now().toUtc().add(const Duration(days: 1)),
          status: TripStatus.scheduled,
        ),
      );
    await pumpBookings(
      tester,
      backend,
      api: FamilyApi((fn, params) async {
        if (fail) throw const RpcException('42501', 'not allowed');
        if (fn == 'family_care_requests') return requestRows('issue_reported');
        return backend.rpc(fn, params);
      }),
    );
    expect(byKey('booking-old'), findsOneWidget);
    expect(byKey('care-request-s1'), findsOneWidget);
    fail = true;
    await tapVisible(tester, byKey('care-refresh'));
    expect(byKey('booking-old'), findsNothing);
    expect(byKey('care-request-s1'), findsNothing);
    expect(find.text('You do not have permission for this.'), findsOneWidget);
    fail = false;
    await tapVisible(tester, byKey('care-refresh'));
    expect(byKey('care-request-s1'), findsOneWidget);
    expect(backend.careSubmissions, isEmpty);
  });

  testWidgets('request is reviewed, persisted and reloaded with ops-backed states', (tester) async {
    final backend = FakeFamilyBackend();
    await pumpBookings(tester, backend);
    await reviewRequest(tester);
    expect(byKey('care-review-summary'), findsOneWidget);
    expect(backend.careSubmissions, isEmpty);
    await tapVisible(tester, byKey('care-submit'));

    expect(backend.careRequests, hasLength(1));
    final saved = backend.careRequests.single;
    expect(saved['patient_id'], 'p1');
    expect(saved['centre_id'], 'c1');
    expect(saved['package_id'], 'basic');
    final pickup = DateTime.parse(saved['pickup_at']! as String);
    expect(toIst(pickup).hour, 7);
    expect(toIst(pickup).minute, 15);
    expect(find.text('Pending ops confirmation'), findsOneWidget);

    await pumpBookings(tester, backend);
    expect(
      find.text('Pending ops confirmation'),
      findsOneWidget,
      reason: 'reads persisted backend request after remount',
    );
    saved.addAll({'request_state': 'confirmed', 'trip_id': 'generated-visit', 'trip_status': 'scheduled'});
    await tapVisible(tester, byKey('care-refresh'));
    expect(find.text('Confirmed · companion not assigned'), findsOneWidget);
    saved.addAll({'request_state': 'assigned', 'companion_name': 'Asha Companion (synthetic)'});
    await tapVisible(tester, byKey('care-refresh'));
    expect(find.text('Confirmed · companion assigned'), findsOneWidget);
    expect(find.textContaining('Asha Companion'), findsNothing);
    expect(find.textContaining('Asha'), findsOneWidget);
  });

  testWidgets('submit is disabled in flight and retries preserve the request identity', (tester) async {
    final backend = FakeFamilyBackend();
    final gate = Completer<void>();
    backend.beforeCareSubmit = () => gate.future;
    backend.careSubmitError = const RpcException('', 'offline');
    await pumpBookings(tester, backend);
    await reviewRequest(tester);
    await tester.ensureVisible(byKey('care-submit'));
    await tester.tap(byKey('care-submit'));
    await tester.pump();
    expect(tester.widget<FilledButton>(byKey('care-submit')).onPressed, isNull);
    await tester.tap(byKey('care-submit'));
    await tester.pump();
    expect(backend.careSubmissions, hasLength(1));
    gate.complete();
    await tester.pumpAndSettle();
    expect(byKey('care-error'), findsOneWidget);
    expect(backend.careRequests, isEmpty);

    backend.beforeCareSubmit = null;
    backend.careSubmitError = null;
    await tapVisible(tester, byKey('care-submit'));
    expect(backend.careSubmissions, hasLength(2));
    expect(backend.careSubmissions.first['p_request_id'], backend.careSubmissions.last['p_request_id']);
    expect(backend.careRequests, hasLength(1));
  });

  testWidgets('viewer and patient access cannot request care', (tester) async {
    for (final level in [AccessLevel.viewer, AccessLevel.patient]) {
      await pumpBookings(tester, FakeFamilyBackend(level: level));
      expect(byKey('request-care'), findsNothing);
    }
  });

  testWidgets('missing owner trip consent opens existing privacy screen without granting consent', (tester) async {
    final backend = FakeFamilyBackend()..consentState[ConsentPurpose.trips] = false;
    await pumpBookings(tester, backend);
    await tapVisible(tester, byKey('request-care'));
    expect(byKey('care-error'), findsOneWidget);
    await tapVisible(tester, find.text('Privacy and consent'));
    expect(byKey('switch-trips'), findsOneWidget);
    expect(backend.consentState[ConsentPurpose.trips], isFalse);
    expect(backend.calls, isNot(contains('set_consent')));
  });

  for (final language in ['en', 'te', 'hi']) {
    testWidgets('$language form validates and review fits at 200% text on a narrow phone', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpBookings(tester, FakeFamilyBackend(), language: language);
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      await tester.pumpAndSettle();
      await tapVisible(tester, byKey('request-care'));
      await tapVisible(tester, byKey('care-review'));
      expect(find.byType(Form), findsOneWidget);
      expect(byKey('care-review-summary'), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await reviewRequest(tester);
      await tester.ensureVisible(byKey('care-submit'));
      await tester.pumpAndSettle();
      expect(byKey('care-submit').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
