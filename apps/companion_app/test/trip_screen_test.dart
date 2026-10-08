import 'package:companion_app/src/screens/trip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

Future<FakeBackend> pumpTrip(WidgetTester tester, TripStatus status, {bool visible = true, String? otp}) async {
  final backend = FakeBackend()
    ..addTrip(
      FakeTrip(id: 't1', pickupAt: DateTime.utc(2026, 10, 9, 1, 30), status: status, detailsVisible: visible, otp: otp),
    );
  final trip = (await backend.api.myTrips()).single;
  await pumpLocalized(tester, TripScreen(api: backend.api, trip: trip));
  return backend;
}

Finder byKey(String key) => find.byKey(Key(key));

void main() {
  // The buttons a companion sees in each state (keys from the trip screen).
  final buttons = <TripStatus, List<String>>{
    TripStatus.scheduled: ['action-companion_en_route', 'action-noShow'],
    TripStatus.companionEnRoute: ['action-picked_up', 'action-noShow', 'action-reportIssue'],
    TripStatus.pickedUp: ['action-at_centre', 'action-reportIssue'],
    TripStatus.atCentre: ['action-handed_over', 'action-reportIssue'],
    TripStatus.handedOver: ['action-session_done', 'action-reportIssue'],
    TripStatus.sessionDone: ['action-returning', 'action-reportIssue'],
    TripStatus.returning: ['action-dropped_home', 'action-reportIssue'],
    TripStatus.droppedHome: ['action-completed', 'action-reportIssue'],
    TripStatus.completed: [],
    TripStatus.cancelled: [],
    TripStatus.noShow: [],
    TripStatus.issueReported: [],
  };
  const allKeys = [
    'action-companion_en_route',
    'action-picked_up',
    'action-at_centre',
    'action-handed_over',
    'action-session_done',
    'action-returning',
    'action-dropped_home',
    'action-completed',
    'action-noShow',
    'action-reportIssue',
  ];

  for (final entry in buttons.entries) {
    testWidgets('trip screen in ${entry.key.dbValue} shows exactly its allowed steps', (tester) async {
      await pumpTrip(tester, entry.key);
      for (final key in allKeys) {
        expect(byKey(key), entry.value.contains(key) ? findsOneWidget : findsNothing, reason: key);
      }
      // The OTP field appears only while the companion is at the door.
      expect(byKey('otp'), entry.key == TripStatus.companionEnRoute ? findsOneWidget : findsNothing);
      if (entry.key.isTerminal) expect(find.text('This trip is closed.'), findsOneWidget);
      expect(find.textContaining('Call 108'), findsOneWidget);
    });
  }

  testWidgets('shows restricted essentials inside the window and nothing else', (tester) async {
    await pumpTrip(tester, TripStatus.scheduled);
    expect(find.text('Patient: Lakshmi Rao (synthetic)'), findsOneWidget);
    expect(find.textContaining('Uses a walking stick'), findsOneWidget);
    expect(find.textContaining('Kiran Rao (synthetic) +919000000101'), findsOneWidget);
  });

  testWidgets('hides patient details outside the window', (tester) async {
    await pumpTrip(tester, TripStatus.scheduled, visible: false);
    expect(find.textContaining('Lakshmi'), findsNothing);
    expect(find.text('Patient details appear closer to pickup time.'), findsOneWidget);
  });

  testWidgets('wrong OTP shows attempts left; no code shows how to get one', (tester) async {
    final backend = await pumpTrip(tester, TripStatus.companionEnRoute, otp: '482913');
    await tester.enterText(byKey('otp'), '000000');
    await tapVisible(tester, byKey('action-picked_up'));
    expect(find.text('Wrong code. 4 attempts left.'), findsOneWidget);
    expect(backend.trips['t1']!.status, TripStatus.companionEnRoute);

    backend.trips['t1']!.otp = null;
    await tester.enterText(byKey('otp'), '482913');
    await tapVisible(tester, byKey('action-picked_up'));
    expect(find.text('No valid code. Ask the family to issue a new code in their app.'), findsOneWidget);
  });

  testWidgets('a malformed OTP is not sent to the server', (tester) async {
    final backend = await pumpTrip(tester, TripStatus.companionEnRoute, otp: '482913');
    await tester.enterText(byKey('otp'), '12');
    await tapVisible(tester, byKey('action-picked_up'));
    expect(find.text('Enter the 6-digit code.'), findsOneWidget);
    expect(backend.calls.where((c) => c == 'verify_pickup_otp'), isEmpty);
  });

  testWidgets('a trip reassigned to someone else shows "not allowed"', (tester) async {
    final backend = await pumpTrip(tester, TripStatus.scheduled);
    backend.trips['t1']!.companionId = 'ravi';
    await tapVisible(tester, byKey('action-companion_en_route'));
    expect(find.text('Not allowed. This trip may have been reassigned.'), findsOneWidget);
  });

  testWidgets('a step overtaken by ops shows "no longer possible"', (tester) async {
    final backend = await pumpTrip(tester, TripStatus.scheduled);
    backend.trips['t1']!.status = TripStatus.cancelled;
    await tapVisible(tester, byKey('action-companion_en_route'));
    expect(find.text('This step is no longer possible. Refresh the trip.'), findsOneWidget);
  });

  testWidgets('reporting an issue needs a description', (tester) async {
    final backend = await pumpTrip(tester, TripStatus.pickedUp);
    await tapVisible(tester, byKey('action-reportIssue'));
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Describe the issue.'), findsOneWidget);
    await tester.enterText(byKey('note'), 'Auto broke down (synthetic)');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(backend.trips['t1']!.status, TripStatus.issueReported);
    expect(backend.trips['t1']!.events.last.note, 'Auto broke down (synthetic)');
    expect(find.text('Issue reported. Ops will contact you.'), findsOneWidget);
    expect(byKey('action-reportIssue'), findsNothing);
  });

  testWidgets('no-show asks for confirmation first', (tester) async {
    final backend = await pumpTrip(tester, TripStatus.scheduled);
    await tapVisible(tester, byKey('action-noShow'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(backend.trips['t1']!.status, TripStatus.scheduled);
    await tapVisible(tester, byKey('action-noShow'));
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(backend.trips['t1']!.status, TripStatus.noShow);
    expect(find.text('This trip is closed.'), findsOneWidget);
  });
}
