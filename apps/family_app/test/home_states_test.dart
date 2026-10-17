import 'dart:async';

import 'package:family_app/src/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

Future<void> home(WidgetTester tester, FakeFamilyBackend backend, {FamilyApi? api}) => pumpLocalized(
  tester,
  HomeScreen(
    api: api ?? backend.api,
    files: FakeVaultFiles(backend),
    photos: FakePhotoSource(),
    payments: FakePayments(backend),
    onLocaleChanged: (_) {},
    onSignOut: () async {},
  ),
);

void main() {
  testWidgets('empty linked-patient state refreshes without promising setup or help', (tester) async {
    final backend = FakeFamilyBackend()..patients.clear();
    await home(tester, backend);
    expect(find.textContaining('No patient is currently linked'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Add loved one'), findsNothing);
    expect(find.text('Contact Ops'), findsNothing);
    backend.patients['p1'] = 'Synthetic patient';
    await tapVisible(tester, byKey('home-retry'));
    expect(find.text('Synthetic patient'), findsOneWidget);
    expect(find.textContaining('There are no visits'), findsOneWidget);
    expect(backend.calls.every((c) => c == 'family_my_patients' || c == 'family_trip_board'), isTrue);
  });

  testWidgets('initial linked-patient error and explicit denial both allow retry', (tester) async {
    for (final error in [Exception('offline'), const RpcException('42501', 'denied')]) {
      final backend = FakeFamilyBackend();
      var fail = true;
      final api = FamilyApi((fn, args) async {
        if (fn == 'family_my_patients' && fail) throw error;
        return backend.rpc(fn, args);
      });
      await home(tester, backend, api: api);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.textContaining('No patient is currently linked'), findsNothing);
      expect(
        find.text(error is RpcException ? 'You do not have permission for this.' : 'Something went wrong. Try again.'),
        findsOneWidget,
      );
      fail = false;
      await tapVisible(tester, byKey('home-retry'));
      expect(find.byType(NavigationBar), findsOneWidget);
    }
  });

  testWidgets('refresh hides previous patient and visits before a revoked link returns empty', (tester) async {
    final backend = FakeFamilyBackend()..addVisit(FakeVisit(id: 'old', pickupAt: DateTime.now().toUtc()));
    Completer<Object?>? pending;
    final api = FamilyApi(
      (fn, args) => fn == 'family_my_patients' && pending != null ? pending.future : backend.rpc(fn, args),
    );
    await home(tester, backend, api: api);
    expect(byKey('booking-old'), findsOneWidget);
    pending = Completer<Object?>();
    await tester.tap(byKey('home-refresh'));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Lakshmi Rao (synthetic)'), findsNothing);
    expect(byKey('booking-old'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    pending.complete(<Object?>[]);
    await tester.pumpAndSettle();
    expect(find.textContaining('No patient is currently linked'), findsOneWidget);
  });

  testWidgets('failed booking refresh removes stale visits and supports a visible retry', (tester) async {
    final backend = FakeFamilyBackend()..addVisit(FakeVisit(id: 'old', pickupAt: DateTime.now().toUtc()));
    var denied = false;
    final api = FamilyApi((fn, args) async {
      if (fn == 'family_trip_board' && denied) throw const RpcException('42501', 'denied');
      return backend.rpc(fn, args);
    });
    await home(tester, backend, api: api);
    denied = true;
    await tapVisible(tester, byKey('bookings-refresh'));
    expect(byKey('booking-old'), findsNothing);
    expect(find.text('You do not have permission for this.'), findsOneWidget);
    expect(find.textContaining('There are no visits'), findsNothing);
    denied = false;
    await tapVisible(tester, byKey('bookings-refresh'));
    expect(byKey('booking-old'), findsOneWidget);
  });

  testWidgets('patient switching ignores a late result for the previous patient; refresh preserves selection', (
    tester,
  ) async {
    final backend = FakeFamilyBackend()..patients['p2'] = 'Synthetic second patient';
    final late = Completer<Object?>();
    var first = true;
    final api = FamilyApi((fn, args) async {
      if (fn == 'family_trip_board' && args['p_patient_id'] == 'p1' && first) {
        first = false;
        return late.future;
      }
      return backend.rpc(fn, args);
    });
    await home(tester, backend, api: api);
    await tapVisible(tester, byKey('patient-picker'));
    await tapVisible(tester, find.text('Synthetic second patient').last);
    late.complete([backend.addVisit(FakeVisit(id: 'late', pickupAt: DateTime.now().toUtc())).toBoardRow()]);
    await tester.pumpAndSettle();
    expect(byKey('booking-late'), findsNothing);
    await tapVisible(tester, byKey('home-refresh'));
    expect(find.text('Synthetic second patient'), findsWidgets);
    expect(byKey('booking-late'), findsNothing);
  });

  for (final level in AccessLevel.values) {
    testWidgets('${level.dbValue} keeps existing visit actions and Patient routing', (tester) async {
      final backend = FakeFamilyBackend(level: level)..addVisit(FakeVisit(id: 't1', pickupAt: DateTime.now().toUtc()));
      await home(tester, backend);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(byKey('view-only'), level == AccessLevel.viewer ? findsOneWidget : findsNothing);
      await tapVisible(tester, byKey('booking-t1'));
      expect(byKey('get-pickup-code'), level.canIssuePickupOtp ? findsOneWidget : findsNothing);
      expect(byKey('cancel-trip'), level.canChangeTrips ? findsOneWidget : findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(byKey('booking-t1'), findsOneWidget);
      expect(backend.calls.contains('create_patient'), isFalse);
      expect(backend.calls.contains('set_consent'), isFalse);
    });
  }
}
