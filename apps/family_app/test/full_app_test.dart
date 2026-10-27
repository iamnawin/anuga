// The family journey through the real app widgets against the fake backend:
// sign in -> bookings -> visit -> pickup code -> updates inbox.
import 'package:family_app/src/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

Future<void> pumpApp(WidgetTester tester, FakeFamilyBackend backend, FakePhoneAuth auth) async {
  usePhoneScreen(tester);
  await tester.pumpWidget(
    FamilyApp(
      api: backend.api,
      auth: auth,
      files: FakeVaultFiles(backend),
      photos: FakePhotoSource(),
      payments: FakePayments(backend),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> signIn(WidgetTester tester, String phone) async {
  expect(byKey('brand-symbol'), findsOneWidget);
  await tester.enterText(byKey('phone'), phone);
  await tapVisible(tester, find.text('Send code'));
  await tester.enterText(byKey('code'), '123456');
  await tapVisible(tester, find.text('Sign in'));
}

void main() {
  testWidgets('a companion account cannot use the family app', (tester) async {
    final auth = FakePhoneAuth();
    await pumpApp(tester, FakeFamilyBackend(), auth);
    await signIn(tester, '9000000201');
    expect(find.text('This account is not a family account.'), findsOneWidget);
    expect(auth.isSignedIn, isFalse);
  });

  testWidgets('owner: bookings, pickup code, live updates', (tester) async {
    final backend = FakeFamilyBackend();
    final today = backend.addVisit(FakeVisit(id: 'today', pickupAt: DateTime.now().toUtc()));
    backend.addVisit(
      FakeVisit(
        id: 'friday',
        pickupAt: DateTime.now().toUtc().add(const Duration(days: 2)),
        companionName: 'Ravi Companion (synthetic)',
      ),
    );
    await pumpApp(tester, backend, FakePhoneAuth());
    await signIn(tester, '9000000101');

    expect(find.text('Lakshmi Rao (synthetic)'), findsOneWidget); // app bar
    expect(byKey('booking-today'), findsOneWidget);
    // Friday is covered by the backup companion, and the family can see that.
    expect(
      find.descendant(of: byKey('booking-friday'), matching: find.textContaining('Backup companion')),
      findsOneWidget,
    );

    await tapVisible(tester, byKey('booking-today'));
    await tapVisible(tester, byKey('get-pickup-code'));
    expect(find.text('482913'), findsOneWidget);
    await tapVisible(tester, find.text('Close'));

    // The companion moves the trip; the family sees it in Updates.
    backend.addEvent(today, TripStatus.companionEnRoute, TransitionActor.companion, null);
    backend.addEvent(today, TripStatus.pickedUp, TransitionActor.companion, 'pickup OTP verified');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.descendant(of: byKey('booking-today'), matching: find.textContaining('Picked up')), findsOneWidget);

    await tapVisible(tester, find.text('Updates'));
    expect(byKey('update-2'), findsOneWidget);
    expect(find.descendant(of: byKey('update-2'), matching: find.textContaining('Picked up')), findsOneWidget);
    expect(
      find.descendant(of: byKey('update-1'), matching: find.textContaining('Companion on the way')),
      findsOneWidget,
    );
  });

  testWidgets('viewer: sees bookings, a view-only note, and no pickup code', (tester) async {
    final backend = FakeFamilyBackend(level: AccessLevel.viewer)
      ..addVisit(FakeVisit(id: 'today', pickupAt: DateTime.now().toUtc()));
    await pumpApp(tester, backend, FakePhoneAuth());
    await signIn(tester, '9000000101');
    expect(byKey('view-only'), findsOneWidget);
    await tapVisible(tester, byKey('booking-today'));
    expect(byKey('get-pickup-code'), findsNothing);
    expect(byKey('cancel-trip'), findsNothing);
  });

  testWidgets('an account with no linked patient is told what to do', (tester) async {
    final backend = FakeFamilyBackend()..patients.clear();
    await pumpApp(tester, backend, FakePhoneAuth());
    await signIn(tester, '9000000101');
    expect(find.textContaining('No patient is linked'), findsOneWidget);
  });

  testWidgets('the app switches to Telugu and Hindi', (tester) async {
    await pumpApp(tester, FakeFamilyBackend(), FakePhoneAuth());
    await tapVisible(tester, find.byTooltip('Language'));
    await tapVisible(tester, find.text('తెలుగు'));
    expect(find.text('కుటుంబ సైన్ ఇన్'), findsOneWidget);
    await tapVisible(tester, find.byTooltip('భాష'));
    await tapVisible(tester, find.text('हिन्दी'));
    expect(find.text('परिवार साइन इन'), findsOneWidget);
  });
}
