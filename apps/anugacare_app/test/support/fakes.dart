import 'dart:async';

import 'package:anugacare_app/src/app.dart';
import 'package:anugacare_app/src/auth.dart';
import 'package:anugacare_app/src/text_size.dart';
import 'package:family_app/family_app.dart' show Payments, PhotoSource, PickedPhoto, VaultFiles;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

const familyPhone = '+919000000101';
const companionPhone = '+919000000201';
const opsPhone = '+919000000001';
const unlinkedPhone = '+919000000999';

/// Sign-in as Supabase Auth does it, with the role a `profiles` row would hold.
/// [roleLookup] replaces the role read, to simulate a slow, failing or expired lookup.
class FakeAccountAuth implements AccountAuth {
  FakeAccountAuth({this._signedInAs, this.code = '123456'});

  final roles = <String, String?>{
    familyPhone: 'family',
    companionPhone: 'companion',
    opsPhone: 'ops_admin',
    unlinkedPhone: null,
  };
  final String code;
  final sessionEvents = StreamController<void>.broadcast();
  Future<String?> Function()? roleLookup;
  int roleLookups = 0;
  int signOuts = 0;
  String? _pending;
  String? _signedInAs;

  @override
  bool get isSignedIn => _signedInAs != null;

  @override
  Stream<void> get sessionEnded => sessionEvents.stream;

  @override
  Future<void> sendCode(String phone) async {
    if (!roles.containsKey(phone)) throw const PhoneAuthException('Signups not allowed for otp');
    _pending = phone;
  }

  @override
  Future<void> verifyCode(String phone, String code) async {
    if (phone != _pending || code != this.code) throw const PhoneAuthException('Token has expired or is invalid');
    _signedInAs = phone;
  }

  @override
  Future<String?> currentRole() async {
    roleLookups++;
    final lookup = roleLookup;
    if (lookup != null) return lookup();
    return roles[_signedInAs];
  }

  @override
  Future<void> signOut() async {
    signOuts++;
    _signedInAs = null;
    sessionEvents.add(null); // Supabase emits signedOut for app-initiated sign-outs too.
  }
}

/// RPCs the role homes call on first load; records every call.
class FakeRpc {
  FakeRpc({this.companionTrips = const []});

  /// Rows `companion_my_trips` returns.
  final List<Object?> companionTrips;
  final calls = <String>[];

  Future<Object?> call(String function, Map<String, Object?> params) async {
    calls.add(function);
    return switch (function) {
      'companion_my_trips' => companionTrips,
      'family_my_patients' || 'my_notifications' => <Object?>[],
      _ => throw RpcException('42501', 'not expected in this test: $function'),
    };
  }
}

class _NoFiles implements VaultFiles {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoPhotos implements PhotoSource {
  @override
  Future<PickedPhoto?> pick({required bool camera}) async => null;
}

class _NoPayments implements Payments {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Phone-sized screen, so tests see what a user sees.
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
}

Future<FakeRpc> pumpApp(
  WidgetTester tester,
  FakeAccountAuth auth, {
  Locale locale = const Locale('en'),
  bool settle = true,
  List<Object?> companionTrips = const [],
  ValueChanged<Locale>? onLocaleChanged,
  AppTextSize initialTextSize = AppTextSize.standard,
  ValueChanged<AppTextSize>? onTextSizeChanged,
  FamilyApi? familyApi,
}) async {
  usePhoneScreen(tester);
  final rpc = FakeRpc(companionTrips: companionTrips);
  await tester.pumpWidget(
    AnugaCareApp(
      auth: auth,
      familyApi: familyApi ?? FamilyApi(rpc.call),
      companionApi: CompanionApi(rpc.call),
      files: _NoFiles(),
      photos: _NoPhotos(),
      payments: _NoPayments(),
      initialLocale: locale,
      onLocaleChanged: onLocaleChanged,
      initialTextSize: initialTextSize,
      onTextSizeChanged: onTextSizeChanged,
    ),
  );
  // The checking screen spins until the role lookup returns, so a test that
  // holds the lookup open pumps frames itself instead of settling.
  settle ? await tester.pumpAndSettle() : await tester.pump();
  return rpc;
}

Future<void> signIn(WidgetTester tester, String phone, {String code = '123456'}) async {
  await tester.enterText(find.byKey(const Key('phone')), phone.substring(3));
  await tester.ensureVisible(find.byKey(const Key('send-code')));
  await tester.tap(find.byKey(const Key('send-code')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('code')), code);
  await tester.tap(find.byKey(const Key('verify-code')));
  await tester.pumpAndSettle();
}

/// Login-focused tests explicitly open phone entry. Entry tests use pumpApp,
/// which keeps the actual Welcome screen and never silently skips it.
Future<FakeRpc> pumpLogin(
  WidgetTester tester,
  FakeAccountAuth auth, {
  Locale locale = const Locale('en'),
  bool settle = true,
  List<Object?> companionTrips = const [],
}) async {
  final rpc = await pumpApp(tester, auth, locale: locale, settle: settle, companionTrips: companionTrips);
  if (find.byKey(const Key('welcome')).evaluate().isNotEmpty) {
    final start = find.byKey(const Key('welcome-get-started'));
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
  }
  return rpc;
}

/// Companion sign-out is a confirmed Me action in the unified shell.
Future<void> signOutCompanion(WidgetTester tester) async {
  await tester.tap(find.text('Me'));
  await tester.pumpAndSettle();
  final button = find.byKey(const Key('companion-sign-out'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
  await tester.pumpAndSettle();
}
