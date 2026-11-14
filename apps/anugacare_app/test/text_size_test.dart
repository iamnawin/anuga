import 'package:anugacare_app/src/text_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fakes.dart';

Future<void> chooseSize(WidgetTester tester, AppTextSize size) async {
  final setting = find.byKey(const Key('text-size-setting'));
  if (setting.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      setting,
      200,
      scrollable: find
          .byWidgetPredicate((widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down)
          .first,
    );
  }
  await tester.ensureVisible(setting);
  await tester.pumpAndSettle();
  await tester.tap(setting);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('text-size-choice-${size.name}')));
  await tester.pumpAndSettle();
}

double scaled(WidgetTester tester, Finder target) => MediaQuery.textScalerOf(tester.element(target)).scale(20);

class _NonlinearScaler extends TextScaler {
  const _NonlinearScaler();
  @override
  double scale(double fontSize) => fontSize * (fontSize <= 20 ? 2 : 1.5);
  @override
  double get textScaleFactor => 2;
}

void main() {
  testWidgets('default text size uses the device scale without forced enlargement', (tester) async {
    await pumpApp(tester, FakeAccountAuth());
    final context = tester.element(find.byKey(const Key('welcome')));
    expect(MediaQuery.textScalerOf(context).scale(20), 20);
  });

  test('unknown stored size falls back to Standard', () {
    expect(AppTextSize.fromStoredValue(null), AppTextSize.standard);
    expect(AppTextSize.fromStoredValue('invalid'), AppTextSize.standard);
    expect(AppTextSize.fromStoredValue('small'), AppTextSize.small);
  });

  test('size adjustment preserves nonlinear device scaling', () {
    final scaler = adjustedTextScaler(const _NonlinearScaler(), AppTextSize.small);
    expect(scaler.scale(16), closeTo(28.8, 0.001));
    expect(scaler.scale(32), closeTo(43.2, 0.001));
  });

  testWidgets('selected size notifies persistence and is restored on a new app instance', (tester) async {
    AppTextSize? stored;
    await pumpApp(tester, FakeAccountAuth(), onTextSizeChanged: (size) => stored = size);
    await chooseSize(tester, AppTextSize.small);
    expect(scaled(tester, find.byKey(const Key('welcome'))), 18);
    expect(stored, AppTextSize.small);
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpApp(tester, FakeAccountAuth(), initialTextSize: stored!);
    expect(scaled(tester, find.byKey(const Key('welcome'))), 18);
  });

  testWidgets('Companion Me changes size without reauth or losing its tab, and sign-out retains it', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final auth = FakeAccountAuth(signedInAs: companionPhone);
    final rpc = await pumpApp(tester, auth);
    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    final calls = [...rpc.calls];
    final lookups = auth.roleLookups;
    await chooseSize(tester, AppTextSize.small);
    expect(find.byKey(const Key('companion-sign-out')), findsOneWidget);
    expect(scaled(tester, find.byKey(const Key('text-size-setting'))), 36);
    expect(rpc.calls, calls);
    expect(auth.roleLookups, lookups);
    await tester.ensureVisible(find.byKey(const Key('companion-sign-out')));
    await tester.tap(find.byKey(const Key('companion-sign-out')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await tester.pumpAndSettle();
    expect(scaled(tester, find.byKey(const Key('welcome'))), 36);
  });

  for (final level in [AccessLevel.owner, AccessLevel.patient]) {
    testWidgets('Family ${level.name} can reach text size in its settings', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final api = FamilyApi(
        (fn, params) async => switch (fn) {
          'family_my_patients' => [
            {
              'patient_id': 'synthetic',
              'full_name': 'Synthetic Patient',
              'access_level': level.dbValue,
              'centre_name': 'Synthetic Centre',
            },
          ],
          'family_trip_board' || 'family_care_requests' || 'my_notifications' => <Object?>[],
          _ => throw const RpcException('42501', 'unexpected'),
        },
      );
      await pumpApp(tester, FakeAccountAuth(signedInAs: familyPhone), familyApi: api);
      final destination = find.byKey(Key(level == AccessLevel.patient ? 'nav-help' : 'nav-more'));
      await tester.ensureVisible(destination);
      await tester.pumpAndSettle();
      await tester.tap(destination);
      await tester.pumpAndSettle();
      await chooseSize(tester, AppTextSize.large);
      expect(scaled(tester, find.byKey(const Key('text-size-setting'))), 46);
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in const [Locale('en'), Locale('te'), Locale('hi')]) {
    testWidgets('${locale.languageCode} menu remains reachable at 200% device text and extra-large preference', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpApp(tester, FakeAccountAuth(), locale: locale);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      await tester.pumpAndSettle();
      await chooseSize(tester, AppTextSize.extraLarge);
      expect(scaled(tester, find.byKey(const Key('welcome'))), 52);
      final start = find.byKey(const Key('welcome-get-started'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      tester.view.viewInsets = FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('phone')), familyPhone.substring(3));
      final send = find.byKey(const Key('send-code'));
      await tester.ensureVisible(send);
      await tester.tap(send);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('code')));
      expect(scaled(tester, find.byKey(const Key('code'))), 52);
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await chooseSize(tester, AppTextSize.standard);
      expect(scaled(tester, find.byKey(const Key('welcome'))), 40);
      expect(tester.takeException(), isNull);
    });
  }
}
