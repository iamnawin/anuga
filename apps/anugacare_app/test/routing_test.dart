import 'dart:async';

import 'package:anugacare_app/src/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fakes.dart';

void main() {
  group('one sign-in, home from the database role', () {
    testWidgets('family account opens the family home and only family RPCs run', (tester) async {
      final auth = FakeAccountAuth();
      final rpc = await pumpApp(tester, auth);

      await signIn(tester, familyPhone);

      expect(find.text('No patient is linked to this account yet. Ask the family owner to add you.'), findsOneWidget);
      expect(rpc.calls, contains('family_my_patients'));
      expect(rpc.calls, isNot(contains('companion_my_trips')));
      expect(auth.isSignedIn, isTrue);
    });

    testWidgets('companion account opens the companion trips and only companion RPCs run', (tester) async {
      final auth = FakeAccountAuth();
      final rpc = await pumpApp(tester, auth);

      await signIn(tester, companionPhone);

      expect(find.text('No trips assigned yet.'), findsOneWidget);
      expect(rpc.calls, contains('companion_my_trips'));
      expect(rpc.calls, isNot(contains('family_my_patients')));
    });

    testWidgets('the login offers no role choice', (tester) async {
      await pumpApp(tester, FakeAccountAuth());

      for (final word in ['Family', 'Companion', 'Patient']) {
        expect(find.textContaining(word), findsNothing, reason: 'no role picker or role-named button');
      }
      expect(find.byType(Radio<Object>), findsNothing);
      expect(find.byType(SegmentedButton<Object>), findsNothing);
    });

    testWidgets('a stored session is checked against the database before any home opens', (tester) async {
      final lookup = Completer<String?>();
      final auth = FakeAccountAuth(signedInAs: companionPhone)..roleLookup = () => lookup.future;
      final rpc = await pumpApp(tester, auth, settle: false);

      // The lookup is still pending: the checking state stays up, with its
      // spinner and no home, for as long as the database has not answered.
      for (var frame = 0; frame < 3; frame++) {
        await tester.pump(const Duration(seconds: 1));
        expect(find.byKey(const Key('checking')), findsOneWidget);
        expect(find.text('Checking your account…'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(rpc.calls, isEmpty);
      }

      lookup.complete('companion');
      await tester.pumpAndSettle();
      expect(find.text('No trips assigned yet.'), findsOneWidget);
    });

    testWidgets('sign out from a role home returns to the shared sign-in', (tester) async {
      final auth = FakeAccountAuth(signedInAs: familyPhone);
      await pumpApp(tester, auth);

      await tester.tap(find.byTooltip('Sign out'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('phone')), findsOneWidget);
      expect(auth.isSignedIn, isFalse);
      expect(find.byKey(const Key('expired')), findsNothing, reason: 'own sign-out is not an expired session');
    });

    testWidgets('sign out from the companion home returns to the shared sign-in', (tester) async {
      final auth = FakeAccountAuth(signedInAs: companionPhone);
      await pumpApp(tester, auth);

      await tester.tap(find.byTooltip('Sign out'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('phone')), findsOneWidget);
      expect(auth.isSignedIn, isFalse);
      expect(find.byKey(const Key('expired')), findsNothing);
    });
  });

  group('accounts this app cannot open', () {
    testWidgets('ops account is pointed to the ops console and signed out', (tester) async {
      final auth = FakeAccountAuth();
      final rpc = await pumpApp(tester, auth);

      await signIn(tester, opsPhone);

      expect(find.byKey(const Key('opsAccount')), findsOneWidget);
      expect(find.text('Use the ops console'), findsOneWidget);
      expect(auth.isSignedIn, isFalse);
      expect(rpc.calls, isEmpty);

      await tester.tap(find.text('Back to sign in'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('phone')), findsOneWidget);
    });

    testWidgets('account without a known role is refused and signed out', (tester) async {
      final auth = FakeAccountAuth();
      final rpc = await pumpApp(tester, auth);

      await signIn(tester, unlinkedPhone);

      expect(find.byKey(const Key('noRole')), findsOneWidget);
      expect(auth.isSignedIn, isFalse);
      expect(rpc.calls, isEmpty);
    });

    testWidgets('an unexpected role value never opens a home', (tester) async {
      final auth = FakeAccountAuth(signedInAs: familyPhone)..roleLookup = () async => 'patient';
      final rpc = await pumpApp(tester, auth);

      expect(find.byKey(const Key('noRole')), findsOneWidget);
      expect(auth.isSignedIn, isFalse);
      expect(rpc.calls, isEmpty);
    });

    testWidgets('unknown number gets the auth server message, no account is created', (tester) async {
      await pumpApp(tester, FakeAccountAuth());

      await tester.enterText(find.byKey(const Key('phone')), '9123456789');
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();

      expect(find.text('Signups not allowed for otp'), findsOneWidget);
      expect(find.byKey(const Key('code')), findsNothing);
    });
  });

  group('loading, errors and expired sessions', () {
    testWidgets('invalid phone and wrong code are shown on the sign-in screen', (tester) async {
      final auth = FakeAccountAuth();
      await pumpApp(tester, auth);

      await tester.enterText(find.byKey(const Key('phone')), '12345');
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid 10-digit mobile number.'), findsOneWidget);

      await signIn(tester, familyPhone, code: '000000');
      expect(find.text('Token has expired or is invalid'), findsOneWidget);
      expect(auth.roleLookups, 0);
    });

    testWidgets('failed role lookup shows retry, keeps the session, and retry opens the home', (tester) async {
      final auth = FakeAccountAuth(signedInAs: familyPhone)
        ..roleLookup = () async => throw const RpcException('', 'network down');
      await pumpApp(tester, auth);

      expect(find.byKey(const Key('accountError')), findsOneWidget);
      expect(auth.isSignedIn, isTrue);

      auth.roleLookup = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('No patient is linked to this account yet. Ask the family owner to add you.'), findsOneWidget);
    });

    testWidgets('failed role lookup can also sign out', (tester) async {
      final auth = FakeAccountAuth(signedInAs: familyPhone)..roleLookup = () async => throw StateError('offline');
      await pumpApp(tester, auth);

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('phone')), findsOneWidget);
      expect(auth.isSignedIn, isFalse);
    });

    testWidgets('expired stored session clears it and asks to sign in again', (tester) async {
      final auth = FakeAccountAuth(signedInAs: companionPhone)
        ..roleLookup = () async => throw const SessionExpiredException();
      final rpc = await pumpApp(tester, auth);

      expect(find.byKey(const Key('expired')), findsOneWidget);
      expect(auth.isSignedIn, isFalse);
      expect(rpc.calls, isEmpty);

      auth.roleLookup = null;
      await tester.tap(find.text('Sign in again'));
      await tester.pumpAndSettle();
      await signIn(tester, companionPhone);
      expect(find.text('No trips assigned yet.'), findsOneWidget);
    });

    testWidgets('session ending while a home is open shows the expired state', (tester) async {
      final auth = FakeAccountAuth(signedInAs: companionPhone);
      await pumpApp(tester, auth);
      expect(find.text('No trips assigned yet.'), findsOneWidget);

      auth.sessionEvents.add(null);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expired')), findsOneWidget);
      expect(find.text('No trips assigned yet.'), findsNothing);
    });
  });

  group('language and accessibility', () {
    testWidgets('language choice applies to sign-in and carries into the role home', (tester) async {
      final auth = FakeAccountAuth();
      await pumpApp(tester, auth);

      await tester.tap(find.byTooltip('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('తెలుగు').last);
      await tester.pumpAndSettle();
      expect(find.text('కోడ్ పంపండి'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('phone')), companionPhone.substring(3));
      await tester.tap(find.text('కోడ్ పంపండి'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('code')), '123456');
      await tester.tap(find.text('సైన్ ఇన్'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out'), findsNothing);
      expect(find.byTooltip('సైన్ అవుట్'), findsOneWidget);
    });

    testWidgets('Hindi sign-in carries into the family home', (tester) async {
      await pumpApp(tester, FakeAccountAuth());

      await tester.tap(find.byTooltip('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('हिन्दी').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('phone')), familyPhone.substring(3));
      await tester.tap(find.text('कोड भेजें'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('code')), '123456');
      await tester.tap(find.text('साइन इन'));
      await tester.pumpAndSettle();

      expect(
        find.text('इस खाते से अभी कोई मरीज़ नहीं जुड़ा है। परिवार के मालिक से आपको जोड़ने को कहें।'),
        findsOneWidget,
      );
      expect(find.byTooltip('साइन आउट'), findsOneWidget);
    });

    for (final locale in const [Locale('en'), Locale('te'), Locale('hi')]) {
      testWidgets(
        'sign-in and status screens meet tap-target, label and contrast guidelines (${locale.languageCode})',
        (tester) async {
          final handle = tester.ensureSemantics();
          await pumpApp(tester, FakeAccountAuth(), locale: locale);
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));

          await pumpApp(
            tester,
            FakeAccountAuth(signedInAs: familyPhone)..roleLookup = () async => throw const SessionExpiredException(),
            locale: locale,
          );
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        },
      );
    }

    testWidgets('sign-in screen does not overflow at 200% text', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpApp(tester, FakeAccountAuth(), locale: const Locale('te'));
      expect(tester.takeException(), isNull);
    });
  });
}
