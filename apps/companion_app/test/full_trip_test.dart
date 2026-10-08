// The whole companion journey through the real app widgets, against the fake
// backend: sign in -> trip list -> en route -> OTP pickup -> centre -> handover
// -> session done -> return -> home -> complete with a note.
import 'package:companion_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

Finder byKey(String key) => find.byKey(Key(key));

Future<void> pumpApp(WidgetTester tester, FakeBackend backend, FakePhoneAuth auth) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(CompanionApp(api: backend.api, auth: auth));
  await tester.pumpAndSettle();
}

Future<void> signIn(WidgetTester tester, String phone) async {
  await tester.enterText(byKey('phone'), phone);
  await tapVisible(tester, find.text('Send code'));
  await tester.enterText(byKey('code'), '123456');
  await tapVisible(tester, find.text('Sign in'));
}

void main() {
  testWidgets('a family account cannot use the companion app', (tester) async {
    final auth = FakePhoneAuth();
    await pumpApp(tester, FakeBackend(), auth);
    await signIn(tester, '9000000101');
    expect(find.text('This account is not a companion account.'), findsOneWidget);
    expect(auth.isSignedIn, isFalse);
    expect(find.text('My trips'), findsNothing);
  });

  testWidgets('an unknown number cannot sign up from the companion app', (tester) async {
    await pumpApp(tester, FakeBackend(), FakePhoneAuth());
    await tester.enterText(byKey('phone'), '9123456789');
    await tapVisible(tester, find.text('Send code'));
    expect(find.text('Signups not allowed for otp'), findsOneWidget);
  });

  testWidgets('full trip from pickup to completion', (tester) async {
    final backend = FakeBackend();
    final trip = backend.addTrip(FakeTrip(id: 'today', pickupAt: DateTime.now().toUtc(), otp: '482913'));
    backend.addTrip(FakeTrip(id: 'later', pickupAt: DateTime.now().toUtc().add(const Duration(days: 3))));
    backend.addTrip(FakeTrip(id: 'not-mine', pickupAt: DateTime.now().toUtc(), companionId: 'ravi'));

    await pumpApp(tester, backend, FakePhoneAuth());
    await signIn(tester, '9000000201');

    // Trip list: today and upcoming; never another companion's trip.
    expect(find.text('My trips'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(byKey('trip-not-mine'), findsNothing);
    await tapVisible(tester, byKey('trip-today'));

    await tapVisible(tester, byKey('action-companion_en_route'));
    expect(trip.status, TripStatus.companionEnRoute);

    // Wrong code first: counted, not picked up.
    await tester.enterText(byKey('otp'), '111111');
    await tapVisible(tester, byKey('action-picked_up'));
    expect(find.text('Wrong code. 4 attempts left.'), findsOneWidget);
    expect(trip.status, TripStatus.companionEnRoute);

    await tester.enterText(byKey('otp'), '482913');
    await tapVisible(tester, byKey('action-picked_up'));
    expect(trip.status, TripStatus.pickedUp);

    await tapVisible(tester, byKey('action-at_centre'));
    await tapVisible(tester, byKey('action-handed_over'));
    await tester.enterText(byKey('note'), 'Handed to Nurse Station 2 (synthetic)');
    await tapVisible(tester, find.text('Submit'));
    expect(trip.status, TripStatus.handedOver);

    await tapVisible(tester, byKey('action-session_done'));
    await tapVisible(tester, byKey('action-returning'));
    await tapVisible(tester, byKey('action-dropped_home'));
    expect(trip.status, TripStatus.droppedHome);

    // The post-visit note is required.
    await tapVisible(tester, byKey('action-completed'));
    await tapVisible(tester, find.text('Submit'));
    expect(find.text('Write a short note for the family.'), findsOneWidget);
    await tester.enterText(byKey('note'), 'Session went well; next visit Friday (synthetic)');
    await tapVisible(tester, find.text('Submit'));

    expect(trip.status, TripStatus.completed);
    expect(trip.postVisitNote, 'Session went well; next visit Friday (synthetic)');
    expect(find.text('Visit completed. Thank you!'), findsOneWidget);
    expect(trip.events.map((e) => e.to), [
      TripStatus.companionEnRoute,
      TripStatus.pickedUp,
      TripStatus.atCentre,
      TripStatus.handedOver,
      TripStatus.sessionDone,
      TripStatus.returning,
      TripStatus.droppedHome,
      TripStatus.completed,
    ]);
    expect(trip.events[3].note, 'Handed to Nurse Station 2 (synthetic)');
    // Pickup went through verify_pickup_otp, never advance_trip.
    expect(backend.calls.where((c) => c == 'verify_pickup_otp'), hasLength(2));

    // Back on the list, the trip shows as completed.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.descendant(of: byKey('trip-today'), matching: find.textContaining('Completed')), findsOneWidget);
  });

  testWidgets('the app switches to Telugu and Hindi', (tester) async {
    await pumpApp(tester, FakeBackend(), FakePhoneAuth());
    await tapVisible(tester, find.byTooltip('Language'));
    await tapVisible(tester, find.text('తెలుగు'));
    expect(find.text('సహచరుల సైన్ ఇన్'), findsOneWidget);
    await tapVisible(tester, find.byTooltip('భాష'));
    await tapVisible(tester, find.text('हिन्दी'));
    expect(find.text('साथी साइन इन'), findsOneWidget);
  });
}
