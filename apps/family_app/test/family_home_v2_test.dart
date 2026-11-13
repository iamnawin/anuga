import 'dart:async';

import 'package:family_app/src/screens/home_screen.dart';
import 'package:family_app/src/screens/records_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

final now = DateTime.utc(2026, 11, 12, 1);

Future<void> openHome(
  WidgetTester tester,
  FakeFamilyBackend backend, {
  ValueNotifier<bool>? online,
  Future<void> Function()? onSignOut,
}) => pumpLocalized(
  tester,
  HomeScreen(
    api: backend.api,
    files: FakeVaultFiles(backend),
    photos: FakePhotoSource(),
    payments: FakePayments(backend),
    onLocaleChanged: (_) {},
    onSignOut: onSignOut ?? () async {},
    now: () => now,
    online: online,
  ),
);

class ReadBackend extends FakeFamilyBackend {
  ReadBackend({super.level});
  Object? patientError;
  Object? boardError;
  Object? issueError;
  Completer<Object?>? delayedBoard;
  Completer<Object?>? delayedPatients;

  @override
  Future<Object?> rpc(String function, Map<String, Object?> params) async {
    if (function == 'family_my_patients' && patientError != null) throw patientError!;
    if (function == 'family_my_patients' && delayedPatients != null) return delayedPatients!.future;
    if (function == 'issue_pickup_otp' && issueError != null) throw issueError!;
    if (function == 'family_trip_board') {
      if (boardError != null) throw boardError!;
      if (params['p_patient_id'] == 'p1' && delayedBoard != null) return delayedBoard!.future;
    }
    return super.rpc(function, params);
  }
}

void main() {
  for (final level in AccessLevel.values) {
    testWidgets('navigation and Home actions follow ${level.name} access', (tester) async {
      final backend = FakeFamilyBackend(level: level)
        ..patients['p1'] = 'Ravi Rao'
        ..addVisit(FakeVisit(id: 'next', pickupAt: now.add(const Duration(hours: 1)), companionName: 'Suresh Kumar'));
      await openHome(tester, backend);
      expect(byKey('nav-home'), findsOneWidget);
      expect(byKey('nav-visits'), findsOneWidget);
      expect(byKey('nav-bills'), level == AccessLevel.owner ? findsOneWidget : findsNothing);
      expect(byKey('nav-records'), level == AccessLevel.patient ? findsNothing : findsOneWidget);
      expect(byKey('nav-more'), level == AccessLevel.patient ? findsNothing : findsOneWidget);
      expect(byKey('nav-help'), level == AccessLevel.patient ? findsOneWidget : findsNothing);
      expect(byKey('home-request-visit'), level.canChangeTrips ? findsOneWidget : findsNothing);
      expect(byKey('home-get-pickup-code'), level.canIssuePickupOtp ? findsOneWidget : findsNothing);
      expect(find.textContaining('Suresh Kumar'), findsNothing);
      expect(find.textContaining('Suresh'), findsOneWidget);
      expect(find.textContaining('Step 1 of 9'), findsOneWidget);
      expect(byKey('home-viewer-notice'), level == AccessLevel.viewer ? findsOneWidget : findsNothing);
      expect(backend.calls, isNot(contains('family_invoices')));
      expect(backend.calls, isNot(contains('issue_pickup_otp')));
      expect(find.text('482913'), findsNothing);
    });
  }

  testWidgets('code appears only after issuing and disappears offline', (tester) async {
    final online = ValueNotifier(true);
    addTearDown(online.dispose);
    final backend = FakeFamilyBackend()..addVisit(FakeVisit(id: 'next', pickupAt: now.add(const Duration(hours: 1))));
    await openHome(tester, backend, online: online);
    await tapVisible(tester, byKey('home-get-pickup-code'));
    expect(find.text('482913'), findsOneWidget);
    expect(backend.calls.where((c) => c == 'issue_pickup_otp').length, 1);
    online.value = false;
    await tester.pumpAndSettle();
    expect(find.text('482913'), findsNothing);
    expect(byKey('family-offline'), findsOneWidget);
    final button = tester.widget<FilledButton>(byKey('home-get-pickup-code'));
    expect(button.onPressed, isNull);
  });

  testWidgets('patient picker uses access words and clears old Home content', (tester) async {
    final backend = FakeFamilyBackend()
      ..patients['p1'] = 'Ravi Rao'
      ..patients['p2'] = 'Lakshmi Rao'
      ..addVisit(FakeVisit(id: 'next', pickupAt: now.add(const Duration(hours: 1))));
    await openHome(tester, backend);
    await tapVisible(tester, byKey('patient-picker'));
    expect(find.text('Choose patient'), findsOneWidget);
    expect(find.text('You are the owner'), findsNWidgets(2));
    await tapVisible(tester, byKey('patient-option-p2'));
    expect(find.text('Ravi Rao'), findsNothing);
    expect(find.text('Lakshmi Rao'), findsOneWidget);
    expect(byKey('home-next-visit'), findsNothing);
    expect(find.text('No visits booked yet'), findsOneWidget);
  });

  testWidgets('retry recovers a failed patient list without stale content', (tester) async {
    final backend = ReadBackend()..patientError = const RpcException('', 'network unavailable');
    await openHome(tester, backend);
    expect(byKey('family-retry'), findsOneWidget);
    expect(byKey('patient-picker'), findsNothing);
    backend.patientError = null;
    await tapVisible(tester, byKey('family-retry'));
    expect(byKey('patient-picker'), findsOneWidget);
  });

  testWidgets('no patient has support explanation and no navigation', (tester) async {
    final backend = FakeFamilyBackend()..patients.clear();
    await openHome(tester, backend);
    expect(find.textContaining('Your patient is not set up yet'), findsOneWidget);
    expect(find.textContaining('support number is not available'), findsOneWidget);
    expect(byKey('nav-home'), findsNothing);
  });

  testWidgets('Home denial clears the visit and code, with retry', (tester) async {
    final backend = ReadBackend()..addVisit(FakeVisit(id: 'next', pickupAt: now.add(const Duration(hours: 1))));
    await openHome(tester, backend);
    await tapVisible(tester, byKey('home-get-pickup-code'));
    expect(find.text('482913'), findsOneWidget);
    backend.boardError = const RpcException('42501', 'denied');
    await tapVisible(tester, byKey('home-refresh'));
    expect(byKey('home-next-visit'), findsNothing);
    expect(find.text('482913'), findsNothing);
    expect(find.text('You do not have permission for this.'), findsOneWidget);
    expect(byKey('family-retry'), findsOneWidget);
  });

  testWidgets('stale async response cannot replace newly selected patient', (tester) async {
    final backend = ReadBackend()
      ..patients['p1'] = 'Ravi Rao'
      ..patients['p2'] = 'Lakshmi Rao'
      ..delayedBoard = Completer<Object?>();
    await openHome(tester, backend);
    await tapVisible(tester, byKey('patient-picker'));
    await tapVisible(tester, byKey('patient-option-p2'));
    backend.delayedBoard!.complete([FakeVisit(id: 'old', pickupAt: now).toBoardRow()]);
    await tester.pumpAndSettle();
    expect(find.text('Ravi Rao'), findsNothing);
    expect(byKey('home-next-visit'), findsNothing);
    expect(find.text('Lakshmi Rao'), findsOneWidget);
  });

  testWidgets('a picker opened before access refresh cannot restore a removed patient', (tester) async {
    final backend = FakeFamilyBackend()
      ..patients['p1'] = 'Ravi Rao'
      ..patients['p2'] = 'Lakshmi Rao';
    await openHome(tester, backend);
    await tapVisible(tester, byKey('patient-picker'));
    backend.patients.remove('p2');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Lakshmi Rao'), findsNothing);
    expect(byKey('patient-option-p2'), findsNothing);
    expect(find.text('Ravi Rao'), findsOneWidget);
  });

  testWidgets('patient can sign out from Help after confirmation', (tester) async {
    var signOuts = 0;
    final backend = FakeFamilyBackend(level: AccessLevel.patient);
    await openHome(tester, backend, onSignOut: () async => signOuts++);
    await tapVisible(tester, byKey('nav-help'));
    await tapVisible(tester, byKey('family-sign-out'));
    expect(signOuts, 0);
    await tapVisible(tester, find.widgetWithText(OutlinedButton, 'Stay signed in'));
    expect(signOuts, 0);
    await tapVisible(tester, byKey('family-sign-out'));
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Sign out'));
    expect(signOuts, 1);
  });

  testWidgets('a changed pickup state refreshes and removes code actions', (tester) async {
    final backend = ReadBackend();
    final visit = backend.addVisit(FakeVisit(id: 'next', pickupAt: now.add(const Duration(hours: 1))));
    await openHome(tester, backend);
    await tapVisible(tester, byKey('home-get-pickup-code'));
    expect(find.text('482913'), findsOneWidget);
    visit.status = TripStatus.pickedUp;
    backend.issueError = const RpcException('22023', 'not awaiting pickup');
    await tapVisible(tester, byKey('home-get-pickup-code'));
    expect(find.text('482913'), findsNothing);
    expect(byKey('home-get-pickup-code'), findsNothing);
    expect(find.textContaining('Step 3 of 9'), findsOneWidget);
  });

  testWidgets('resume keeps an allowed Records destination mounted during access refresh', (tester) async {
    final backend = ReadBackend();
    await openHome(tester, backend);
    await tapVisible(tester, byKey('nav-records'));
    final previous = tester.state(find.byType(RecordsTab));
    backend.delayedPatients = Completer<Object?>();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tester.state(find.byType(RecordsTab)), same(previous));
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 2);
    backend.delayedPatients!.complete([
      {'patient_id': 'p1', 'full_name': 'Ravi Rao', 'access_level': 'owner', 'centre_name': 'City Dialysis Centre'},
    ]);
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(RecordsTab)), same(previous));
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 2);
  });

  testWidgets('resume refreshes a preserved Home and removes a consumed pickup code', (tester) async {
    final backend = ReadBackend();
    final visit = backend.addVisit(FakeVisit(id: 'next', pickupAt: now.add(const Duration(hours: 1))));
    await openHome(tester, backend);
    await tapVisible(tester, byKey('home-get-pickup-code'));
    expect(find.text('482913'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    visit.status = TripStatus.pickedUp;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('482913'), findsNothing);
    expect(byKey('home-get-pickup-code'), findsNothing);
    expect(find.textContaining('Step 3 of 9'), findsOneWidget);
  });
}
