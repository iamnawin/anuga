import 'package:flutter/material.dart';
import 'package:family_app/src/screens/trip_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

Future<FakeFamilyBackend> pumpTrip(WidgetTester tester, AccessLevel level, TripStatus status) async {
  final backend = FakeFamilyBackend(level: level)
    ..addVisit(FakeVisit(id: 't1', pickupAt: DateTime.utc(2026, 10, 9, 1, 30), status: status));
  final patient = (await backend.api.myPatients()).single;
  final booking = (await backend.api.tripBoard('p1')).single;
  await pumpLocalized(tester, TripScreen(api: backend.api, patient: patient, booking: booking));
  return backend;
}

void main() {
  // Which buttons each access level gets on a scheduled visit.
  final expected = <AccessLevel, ({bool code, bool cancel})>{
    AccessLevel.owner: (code: true, cancel: true),
    AccessLevel.editor: (code: true, cancel: true),
    AccessLevel.patient: (code: true, cancel: false),
    AccessLevel.viewer: (code: false, cancel: false),
  };

  for (final entry in expected.entries) {
    testWidgets('${entry.key.dbValue} on a scheduled visit: code ${entry.value.code}, cancel ${entry.value.cancel}', (
      tester,
    ) async {
      await pumpTrip(tester, entry.key, TripStatus.scheduled);
      expect(byKey('get-pickup-code'), entry.value.code ? findsOneWidget : findsNothing);
      expect(byKey('cancel-trip'), entry.value.cancel ? findsOneWidget : findsNothing);
    });
  }

  testWidgets('a viewer never sees the pickup code button, in any status', (tester) async {
    for (final status in TripStatus.values) {
      await pumpTrip(tester, AccessLevel.viewer, status);
      expect(byKey('get-pickup-code'), findsNothing, reason: status.dbValue);
      expect(byKey('cancel-trip'), findsNothing, reason: status.dbValue);
    }
  });

  testWidgets('the code is offered only while the visit awaits pickup', (tester) async {
    for (final status in TripStatus.values) {
      await pumpTrip(tester, AccessLevel.owner, status);
      final awaiting = status == TripStatus.scheduled || status == TripStatus.companionEnRoute;
      expect(byKey('get-pickup-code'), awaiting ? findsOneWidget : findsNothing, reason: status.dbValue);
      // Family may cancel only before the companion sets off.
      expect(
        byKey('cancel-trip'),
        status == TripStatus.scheduled ? findsOneWidget : findsNothing,
        reason: status.dbValue,
      );
    }
  });

  testWidgets('owner gets a pickup code and sees it large, with instructions', (tester) async {
    final backend = await pumpTrip(tester, AccessLevel.owner, TripStatus.companionEnRoute);
    await tapVisible(tester, byKey('get-pickup-code'));
    expect(find.text('482913'), findsOneWidget);
    expect(find.textContaining('Only the newest code works'), findsOneWidget);
    expect(backend.visits['t1']!.otp, '482913');
  });

  testWidgets('if the database refuses the code, the user is told', (tester) async {
    final backend = await pumpTrip(tester, AccessLevel.owner, TripStatus.scheduled);
    backend.level = AccessLevel.viewer; // access was reduced since the screen opened
    await tapVisible(tester, byKey('get-pickup-code'));
    expect(find.text('You do not have permission for this.'), findsOneWidget);
    expect(byKey('pickup-code'), findsNothing);
  });

  testWidgets('cancel asks first, records the reason and updates the timeline', (tester) async {
    final backend = await pumpTrip(tester, AccessLevel.owner, TripStatus.scheduled);
    await tapVisible(tester, byKey('cancel-trip'));
    await tapVisible(tester, find.text('Keep visit'));
    expect(backend.visits['t1']!.status, TripStatus.scheduled);

    await tapVisible(tester, byKey('cancel-trip'));
    await tester.enterText(byKey('cancel-reason'), 'Hospital rescheduled (synthetic)');
    await tapVisible(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text('Cancel this visit')));
    expect(backend.visits['t1']!.status, TripStatus.cancelled);
    expect(find.text('Visit cancelled.'), findsOneWidget);
    expect(find.textContaining('Hospital rescheduled (synthetic)'), findsOneWidget);
    expect(byKey('cancel-trip'), findsNothing);
    expect(byKey('get-pickup-code'), findsNothing);
  });

  testWidgets('a visit the companion already started cannot be cancelled by family', (tester) async {
    final backend = await pumpTrip(tester, AccessLevel.owner, TripStatus.scheduled);
    backend.visits['t1']!.status = TripStatus.companionEnRoute; // changed since the screen opened
    await tapVisible(tester, byKey('cancel-trip'));
    await tapVisible(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text('Cancel this visit')));
    expect(find.text('This is no longer possible. Refresh the visit.'), findsOneWidget);
    expect(backend.visits['t1']!.status, TripStatus.companionEnRoute);
  });

  testWidgets('timeline shows who did what, with notes', (tester) async {
    final backend = FakeFamilyBackend()..addVisit(FakeVisit(id: 't1', pickupAt: DateTime.utc(2026, 10, 9, 1, 30)));
    final v = backend.visits['t1']!;
    backend
      ..addEvent(v, TripStatus.companionEnRoute, TransitionActor.companion, null)
      ..addEvent(v, TripStatus.issueReported, TransitionActor.companion, 'Auto broke down (synthetic)')
      ..addEvent(v, TripStatus.companionEnRoute, TransitionActor.ops, 'Resolved by ops');
    final patient = (await backend.api.myPatients()).single;
    final booking = (await backend.api.tripBoard('p1')).single;
    await pumpLocalized(tester, TripScreen(api: backend.api, patient: patient, booking: booking));
    expect(byKey('event-1'), findsOneWidget);
    expect(find.textContaining('Auto broke down (synthetic)'), findsOneWidget);
    expect(find.textContaining('by our team'), findsOneWidget);
    expect(find.textContaining('Call 108'), findsOneWidget);
  });
}
