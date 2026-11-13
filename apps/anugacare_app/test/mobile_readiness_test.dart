import 'package:anugacare_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

Future<void> useNarrowPhone(WidgetTester tester, {double keyboardHeight = 0}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 640);
  tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('system back from the code step returns to phone entry', (tester) async {
    await pumpLogin(tester, FakeAccountAuth());
    await useNarrowPhone(tester);
    await tester.enterText(find.byKey(const Key('phone')), familyPhone.substring(3));
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Send verification code'));
    expect(find.byKey(const Key('code')), findsOneWidget);

    // No keyboard inset: this is route back, after Android has dismissed the IME.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('phone')), findsOneWidget);
    expect(find.byKey(const Key('code')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [Locale('en'), Locale('te'), Locale('hi')]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('${locale.languageCode} ${scale}x phone and code controls remain reachable above the keyboard', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpLogin(tester, FakeAccountAuth(), locale: locale);
        await useNarrowPhone(tester, keyboardHeight: 280);
        final l10n = AppLocalizations.of(tester.element(find.byKey(const Key('phone'))));

        await tester.ensureVisible(find.byKey(const Key('phone')));
        await tester.enterText(find.byKey(const Key('phone')), familyPhone.substring(3));
        await tapVisible(tester, find.widgetWithText(FilledButton, l10n.sendCode));
        expect(find.byKey(const Key('code')), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.byKey(const Key('code')));
        await tester.enterText(find.byKey(const Key('code')), '000000');
        await tapVisible(tester, find.widgetWithText(FilledButton, l10n.signIn));
        expect(find.byKey(const Key('loginMessage')), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tapVisible(tester, find.widgetWithText(OutlinedButton, l10n.changeNumber));
        expect(find.byKey(const Key('phone')), findsOneWidget);
        expect(find.byKey(const Key('loginMessage')), findsNothing);
        await tester.enterText(find.byKey(const Key('phone')), familyPhone.substring(3));
        await tapVisible(tester, find.widgetWithText(FilledButton, l10n.sendCode));
        expect(tester.widget<TextField>(find.byKey(const Key('code'))).controller!.text, isEmpty);
        expect(tester.takeException(), isNull);
      });

      testWidgets('${locale.languageCode} ${scale}x ops direction fits a narrow phone', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final auth = FakeAccountAuth(signedInAs: opsPhone);
        await pumpLogin(tester, auth, locale: locale);
        await useNarrowPhone(tester);
        final l10n = AppLocalizations.of(tester.element(find.byKey(const Key('opsAccount'))));

        expect(auth.isSignedIn, isFalse);
        expect(tester.takeException(), isNull);
        await tapVisible(tester, find.widgetWithText(FilledButton, l10n.backToSignIn));
        expect(find.byKey(const Key('phone')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final phone in [familyPhone, companionPhone]) {
    testWidgets('pause and resume preserve the role home, but cannot undo logout ($phone)', (tester) async {
      final auth = FakeAccountAuth(signedInAs: phone);
      final rpc = await pumpLogin(tester, auth);
      final ownRead = phone == familyPhone ? 'family_my_patients' : 'companion_my_trips';
      final otherRead = phone == familyPhone ? 'companion_my_trips' : 'family_my_patients';
      expect(rpc.calls, contains(ownRead));
      expect(rpc.calls, isNot(contains(otherRead)));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(auth.isSignedIn, isTrue);
      expect(find.byKey(const Key('phone')), findsNothing);
      expect(find.byTooltip('Sign out'), findsOneWidget);
      expect(rpc.calls, isNot(contains(otherRead)));

      await tester.tap(find.byTooltip('Sign out'));
      await tester.pumpAndSettle();
      if (phone == familyPhone) {
        await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
        await tester.pumpAndSettle();
      }
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(auth.isSignedIn, isFalse);
      expect(find.byKey(const Key('welcome')), findsOneWidget);
      expect(find.byTooltip('Sign out'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
