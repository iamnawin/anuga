import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

Future<void> start(WidgetTester tester, String key) async {
  final action = find.byKey(Key(key));
  await tester.ensureVisible(action);
  await tester.tap(action);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Welcome chip/menu selections notify preferences and carry through phone/back', (tester) async {
    final selected = <String>[];
    await pumpApp(tester, FakeAccountAuth(), onLocaleChanged: (l) => selected.add(l.languageCode));
    await start(tester, 'welcome-language-te');
    expect(selected, ['te']);
    await start(tester, 'welcome-get-started');
    expect(Localizations.localeOf(tester.element(find.byKey(const Key('phone')))).languageCode, 'te');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    final menu = find.byTooltip('భాష');
    await tester.ensureVisible(menu);
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('हिन्दी').last);
    await tester.pumpAndSettle();
    expect(selected, ['te', 'hi']);
    await start(tester, 'welcome-get-started');
    expect(Localizations.localeOf(tester.element(find.byKey(const Key('phone')))).languageCode, 'hi');
  });

  for (final brightness in Brightness.values) {
    for (final code in ['en', 'te', 'hi']) {
      testWidgets('Welcome ${brightness.name} $code meets target/label/contrast guidelines', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final handle = tester.ensureSemantics();
        await pumpApp(tester, FakeAccountAuth(), locale: Locale(code));
        await tester.ensureVisible(find.byKey(const Key('welcome-get-started')));
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  }
  testWidgets('signed-out entry is Welcome with supplied illustration and no role/API lookup', (tester) async {
    final auth = FakeAccountAuth();
    final rpc = await pumpApp(tester, auth);
    expect(find.byKey(const Key('welcome')), findsOneWidget);
    expect(find.byKey(const Key('welcome-illustration')), findsOneWidget);
    expect(find.byKey(const Key('phone')), findsNothing);
    expect(auth.roleLookups, 0);
    expect(rpc.calls, isEmpty);
  });

  for (final data in [
    ('welcome-get-started', companionPhone, 'companion_my_trips'),
    ('welcome-companion-sign-in', familyPhone, 'family_my_patients'),
  ]) {
    testWidgets('${data.$1} uses the same login and database role, not its label', (tester) async {
      final rpc = await pumpApp(tester, FakeAccountAuth());
      await start(tester, data.$1);
      expect(find.byKey(const Key('phone')), findsOneWidget);
      await signIn(tester, data.$2);
      expect(rpc.calls, contains(data.$3));
      expect(find.byKey(const Key('welcome')), findsNothing);
      expect(find.byKey(const Key('phone')), findsNothing);
    });
  }

  for (final phone in [familyPhone, companionPhone]) {
    testWidgets('stored $phone bypasses Welcome and keeps account routing', (tester) async {
      final auth = FakeAccountAuth(signedInAs: phone);
      final rpc = await pumpApp(tester, auth);
      expect(find.byKey(const Key('welcome')), findsNothing);
      expect(find.byKey(const Key('phone')), findsNothing);
      expect(rpc.calls, isNotEmpty);
      expect(auth.isSignedIn, isTrue);
    });
  }

  testWidgets('OTP back returns to phone; phone back returns to Welcome', (tester) async {
    await pumpApp(tester, FakeAccountAuth());
    await start(tester, 'welcome-get-started');
    await tester.enterText(find.byKey(const Key('phone')), '9000000101');
    await tester.ensureVisible(find.byKey(const Key('send-code')));
    await tester.tap(find.byKey(const Key('send-code')));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('phone')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('welcome')), findsOneWidget);
    expect(find.byKey(const Key('phone')), findsNothing);
  });

  testWidgets('repeated Welcome actions do not stack login routes', (tester) async {
    await pumpApp(tester, FakeAccountAuth());
    final primary = tester.widget<FilledButton>(find.byKey(const Key('welcome-get-started')));
    final secondary = tester.widget<TextButton>(find.byKey(const Key('welcome-companion-sign-in')));
    primary.onPressed!();
    secondary.onPressed!();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('welcome')), findsOneWidget);
    expect(find.byKey(const Key('phone')), findsNothing);
  });

  for (final width in [360.0, 390.0]) {
    for (final brightness in Brightness.values) {
      for (final code in ['en', 'te', 'hi']) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('$width ${brightness.name} $code ${scale}x Welcome actions remain reachable', (tester) async {
            tester.platformDispatcher.platformBrightnessTestValue = brightness;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
            await pumpApp(tester, FakeAccountAuth(), locale: Locale(code));
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            for (final key in ['welcome-get-started', 'welcome-companion-sign-in']) {
              final action = find.byKey(Key(key));
              await tester.ensureVisible(action);
              await tester.pumpAndSettle();
              expect(action.hitTestable(), findsOneWidget);
              expect(tester.takeException(), isNull);
            }
          });
        }
      }
    }
  }
}
