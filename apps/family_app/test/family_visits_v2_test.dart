import 'dart:async';

import 'package:family_app/src/screens/bookings_tab.dart';
import 'package:family_app/src/screens/trip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

final _now = DateTime.utc(2026, 11, 12, 1);

class _Backend extends FakeFamilyBackend {
  _Backend();
  Object? writeError;
  Object? readError;
  Completer<Object?>? pendingCode;
  final boardRanges = <Map<String, Object?>>[];

  @override
  Future<Object?> rpc(String fn, Map<String, Object?> params) async {
    if (fn == 'family_trip_board') boardRanges.add({...params});
    if ((fn == 'family_trip_board' || fn == 'family_trip_timeline') && readError != null) throw readError!;
    if ((fn == 'issue_pickup_otp' || fn == 'advance_trip') && writeError != null) throw writeError!;
    if (fn == 'issue_pickup_otp' && pendingCode != null) return pendingCode!.future;
    return super.rpc(fn, params);
  }
}

Future<void> _trip(WidgetTester tester, _Backend backend, {ValueNotifier<bool>? online}) async {
  final patient = (await backend.api.myPatients()).single;
  final row = (await backend.api.tripBoard('p1')).single;
  await pumpLocalized(tester, TripScreen(api: backend.api, patient: patient, booking: row, online: online));
}

void main() {
  for (final locale in ['en', 'te', 'hi']) {
    testWidgets('$locale Visits remain readable at 200 percent on a narrow phone', (tester) async {
      tester.platformDispatcher.localeTestValue = Locale(locale);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final backend = _Backend()
        ..addVisit(FakeVisit(id: 'future', pickupAt: _now.add(const Duration(days: 1)), companionName: 'Suresh Kumar'));
      final patient = (await backend.api.myPatients()).single;
      await pumpLocalized(
        tester,
        Scaffold(
          body: BookingsTab(api: backend.api, patient: patient, now: () => _now),
        ),
      );
      tester.view.physicalSize = const Size(800, 2250);
      await tester.pumpAndSettle();
      await tester.ensureVisible(byKey('booking-future'));
      await tester.pumpAndSettle();
      expect(byKey('booking-future'), findsOneWidget);
      expect(find.textContaining('Suresh Kumar'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  const steps = [
    TripStatus.scheduled,
    TripStatus.companionEnRoute,
    TripStatus.pickedUp,
    TripStatus.atCentre,
    TripStatus.handedOver,
    TripStatus.sessionDone,
    TripStatus.returning,
    TripStatus.droppedHome,
    TripStatus.completed,
  ];
  const names = [
    'Booked',
    'Companion on the way',
    'Picked up',
    'At the centre',
    'Handed to centre staff',
    'Session finished',
    'On the way home',
    'Home',
    'Visit complete',
  ];
  for (var i = 0; i < steps.length; i++) {
    testWidgets('persisted ${steps[i].name} is step ${i + 1} with words', (tester) async {
      final backend = _Backend()
        ..addVisit(FakeVisit(id: 'visit', pickupAt: _now, status: steps[i], companionName: 'Suresh Kumar'));
      await _trip(tester, backend);
      expect(find.text('Step ${i + 1} of 9 · ${names[i]}'), findsOneWidget);
      expect(byKey('visit-route'), findsOneWidget);
      expect(find.textContaining('Suresh Kumar'), findsNothing);
      expect(find.text('Suresh, your companion'), findsOneWidget);
      expect(find.textContaining('Backup companion'), findsNothing);
      expect(byKey('visit-complete'), steps[i] == TripStatus.completed ? findsOneWidget : findsNothing);
    });
  }

  for (final status in [TripStatus.cancelled, TripStatus.noShow, TripStatus.issueReported]) {
    testWidgets('${status.name} replaces progress with a stopped banner and Help', (tester) async {
      final backend = _Backend()..addVisit(FakeVisit(id: 'visit', pickupAt: _now, status: status));
      await _trip(tester, backend);
      expect(byKey('visit-progress'), findsNothing);
      expect(byKey('visit-stopped'), findsOneWidget);
      expect(byKey('visit-help'), findsOneWidget);
      await tapVisible(tester, byKey('visit-help'));
      expect(
        find.descendant(of: find.byType(AlertDialog), matching: find.textContaining('112 or 108')),
        findsOneWidget,
      );
    });
  }

  testWidgets('resume dismisses exact code dialog and never restores a consumed code', (tester) async {
    final backend = _Backend()..addVisit(FakeVisit(id: 'visit', pickupAt: _now));
    await _trip(tester, backend);
    await tapVisible(tester, byKey('get-pickup-code'));
    expect(byKey('pickup-code'), findsOneWidget);
    backend.visits['visit']!.status = TripStatus.pickedUp;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    expect(byKey('pickup-code'), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(byKey('inline-pickup-code'), findsNothing);
    expect(byKey('get-pickup-code'), findsNothing);
    expect(find.textContaining('Step 3 of 9'), findsOneWidget);
  });

  testWidgets('a delayed code response after background cannot open a dialog', (tester) async {
    final backend = _Backend()..addVisit(FakeVisit(id: 'visit', pickupAt: _now));
    await _trip(tester, backend);
    backend.pendingCode = Completer<Object?>();
    await tapVisible(tester, byKey('get-pickup-code'));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    backend.pendingCode!.complete('482913');
    await tester.pumpAndSettle();
    expect(find.text('482913'), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('offline clears issued code and disables writes', (tester) async {
    final online = ValueNotifier(true);
    addTearDown(online.dispose);
    final backend = _Backend()..addVisit(FakeVisit(id: 'visit', pickupAt: _now));
    await _trip(tester, backend, online: online);
    await tapVisible(tester, byKey('get-pickup-code'));
    online.value = false;
    await tester.pumpAndSettle();
    expect(find.text('482913'), findsNothing);
    expect(byKey('family-offline'), findsOneWidget);
    expect(tester.widget<FilledButton>(byKey('get-pickup-code')).onPressed, isNull);
    expect(tester.widget<OutlinedButton>(byKey('cancel-trip')).onPressed, isNull);
  });

  testWidgets('cancel keeps primary Keep action and typed reason on transient failure', (tester) async {
    final backend = _Backend()..addVisit(FakeVisit(id: 'visit', pickupAt: _now));
    await _trip(tester, backend);
    await tapVisible(tester, byKey('cancel-trip'));
    expect(find.widgetWithText(FilledButton, 'Keep visit'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Cancel this visit'), findsNWidgets(2));
    await tester.enterText(byKey('cancel-reason'), 'Centre changed my appointment');
    backend.writeError = const RpcException('', 'network unavailable');
    await tapVisible(tester, byKey('confirm-cancel-visit'));
    expect(find.text('Centre changed my appointment'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(byKey('cancel-retry'), findsOneWidget);
    backend.writeError = null;
    await tapVisible(tester, byKey('cancel-retry'));
    expect(backend.visits['visit']!.status, TripStatus.cancelled);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('Centre changed my appointment'), findsOneWidget);
  });

  testWidgets('family timeline keeps legitimate handover text but hides injected operational notes', (tester) async {
    final backend = _Backend();
    final visit = backend.addVisit(FakeVisit(id: 'visit', pickupAt: _now));
    backend.addEvent(visit, TripStatus.handedOver, TransitionActor.companion, 'Front desk received the bag');
    // Simulate stale or malformed projection to verify presentation redaction too.
    visit.events.add({
      'event_id': 9,
      'from_status': 'handed_over',
      'to_status': 'issue_reported',
      'actor_kind': 'companion',
      'note': 'PRIVATE ISSUE',
      'created_at': _now.toIso8601String(),
    });
    visit.events.add({
      'event_id': 10,
      'from_status': 'issue_reported',
      'to_status': 'handed_over',
      'actor_kind': 'ops',
      'note': 'PRIVATE OPS',
      'created_at': _now.toIso8601String(),
    });
    await _trip(tester, backend);
    expect(find.textContaining('Front desk received the bag'), findsOneWidget);
    expect(find.textContaining('PRIVATE ISSUE'), findsNothing);
    expect(find.textContaining('PRIVATE OPS'), findsNothing);
  });

  testWidgets('Past requests calendar-month ranges and upcoming does not invent a window', (tester) async {
    final backend = _Backend()
      ..addVisit(FakeVisit(id: 'future', pickupAt: _now.add(const Duration(days: 1))))
      ..addVisit(FakeVisit(id: 'past', pickupAt: _now.subtract(const Duration(days: 1)), status: TripStatus.completed));
    final patient = (await backend.api.myPatients()).single;
    await pumpLocalized(
      tester,
      Scaffold(
        body: BookingsTab(api: backend.api, patient: patient, now: () => _now),
      ),
    );
    expect(byKey('booking-future'), findsOneWidget);
    expect(byKey('visit-date-block-future'), findsOneWidget);
    expect(byKey('booking-past'), findsNothing);
    expect(backend.boardRanges.last.containsKey('p_from'), isFalse);
    await tapVisible(tester, byKey('visits-past'));
    expect(byKey('booking-past'), findsOneWidget);
    expect(byKey('booking-future'), findsNothing);
    expect(DateTime.parse(backend.boardRanges.last['p_from']! as String), DateTime.utc(2026, 10, 31, 18, 30));
    await tapVisible(tester, byKey('visits-previous-month'));
    expect(DateTime.parse(backend.boardRanges.last['p_from']! as String), DateTime.utc(2026, 9, 30, 18, 30));
  });
}
