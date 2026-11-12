import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fakes.dart';

class SlowAuth extends FakeAccountAuth {
  final sent = Completer<void>();

  @override
  Future<void> sendCode(String phone) => sent.future;
}

class SlowVerifyAuth extends FakeAccountAuth {
  final verified = Completer<void>();

  @override
  Future<void> verifyCode(String phone, String code) => verified.future;
}

void main() {
  testWidgets('sending from a scrolled phone form opens OTP at the top', (tester) async {
    await pumpApp(tester, FakeAccountAuth());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('phone')), '9000000101');
    await tester.ensureVisible(find.byKey(const Key('send-code')));
    await tester.tap(find.byKey(const Key('send-code')));
    await tester.pumpAndSettle();
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
    expect(scroll.position.pixels, 0);
    expect(find.byKey(const Key('code')).hitTestable(), findsOneWidget);
  });
  testWidgets('verification stays disabled across keyboard changes and recovers from expiry', (tester) async {
    final auth = SlowVerifyAuth();
    await pumpApp(tester, auth);
    await tester.enterText(find.byKey(const Key('phone')), '9000000101');
    await tester.tap(find.byKey(const Key('send-code')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('code')), '123456');
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('verify-code')));
    await tester.pump();
    for (final inset in [0.0, 280.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pump();
      expect(find.byKey(const Key('verify-code')), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byKey(const Key('verify-code'))).onPressed, isNull);
      expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed, isNull);
    }
    auth.verified.completeError(const PhoneAuthException('Token has expired or is invalid'));
    await tester.pumpAndSettle();
    expect(find.text('Token has expired or is invalid'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('verify-code'))).onPressed, isNotNull);
    expect(auth.roleLookups, 0);
  });
  testWidgets('Verify stays visible when the OTP keyboard opens without manual scrolling', (tester) async {
    await pumpApp(tester, FakeAccountAuth());
    await tester.enterText(find.byKey(const Key('phone')), '9000000101');
    await tester.tap(find.byKey(const Key('send-code')));
    await tester.pumpAndSettle();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    await tester.tap(find.byKey(const Key('code')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('verify-code')).hitTestable(), findsOneWidget);
  });
  testWidgets('English language selector fits at 200 percent on a narrow phone', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, FakeAccountAuth());
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    await tester.pumpAndSettle();
  });
  testWidgets('phone entry uses approved lockup and verification copy', (tester) async {
    await pumpApp(tester, FakeAccountAuth());
    expect(find.byKey(const Key('brand-lockup')), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Send verification code'), findsOneWidget);
  });

  testWidgets('sending disables repeat submission and announces progress', (tester) async {
    final auth = SlowAuth();
    await pumpApp(tester, auth);
    await tester.enterText(find.byKey(const Key('phone')), '9000000101');
    await tester.tap(find.widgetWithText(FilledButton, 'Send verification code'));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byKey(const Key('send-code'))).onPressed, isNull);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    auth.sent.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('code')), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Verify code'), findsOneWidget);
    expect(find.byKey(const Key('brand-symbol')), findsOneWidget);
  });
}
