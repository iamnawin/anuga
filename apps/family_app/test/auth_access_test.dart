import 'dart:async';
import 'dart:convert';

import 'package:family_app/src/vault_files.dart';
import 'package:family_app/src/payments.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:family_app/src/supabase_rpc.dart';

import 'package:shared_dart/shared_dart.dart';

import 'package:family_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

import 'package:family_app/src/screens/login_screen.dart';

class RestoredAuth extends FakePhoneAuth {
  String? role = 'family';
  bool signedIn = true;
  bool fail = false;
  AccountState state = AccountState.active;
  final events = StreamController<void>.broadcast();
  @override
  Stream<void> get accessChanges => events.stream;
  int lookups = 0;
  Completer<String?>? lookup;
  @override
  bool get isSignedIn => signedIn;
  @override
  Future<AccountAccess> accountAccess() async {
    lookups++;
    if (fail) throw StateError('network unavailable');
    if (state != AccountState.active) return AccountAccess(state);
    final resolved = lookup == null ? role : await lookup!.future;
    return AccountAccess(resolved == null ? AccountState.unconfirmed : AccountState.active, resolved);
  }

  @override
  Future<void> signOut() async {
    signedIn = false;
  }
}

class TrackingAuth extends FakePhoneAuth {
  int sends = 0;
  int verifications = 0;
  Completer<void>? sending;
  @override
  Future<void> sendCode(String phone) async {
    sends++;
    await super.sendCode(phone);
    if (sending != null) await sending!.future;
  }

  @override
  Future<void> verifyCode(String phone, String code) async {
    verifications++;
    await super.verifyCode(phone, code);
  }
}

void main() {
  Future<FakeFamilyBackend> start(WidgetTester tester, RestoredAuth auth) async {
    final backend = FakeFamilyBackend();
    addTearDown(auth.events.close);
    await tester.pumpWidget(
      FamilyApp(
        api: backend.api,
        auth: auth,
        files: FakeVaultFiles(backend),
        photos: FakePhotoSource(),
        payments: FakePayments(backend),
      ),
    );
    await tester.pump();
    return backend;
  }

  testWidgets('restored session cannot fetch data during role lookup', (tester) async {
    final auth = RestoredAuth()..lookup = Completer<String?>();
    final backend = await start(tester, auth);
    expect(auth.lookups, 1);
    expect(backend.calls, isEmpty);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    auth.lookup!.complete('family');
    await tester.pumpAndSettle();
    expect(backend.calls, isNotEmpty);
  });
  for (final role in ['companion', 'ops_admin', null]) {
    testWidgets('restored role $role never mounts home', (tester) async {
      final auth = RestoredAuth()..role = role;
      final backend = await start(tester, auth);
      await tester.pumpAndSettle();
      expect(backend.calls, isEmpty);
      expect(find.byKey(const Key('access-retry')), findsOneWidget);
      expect(auth.signedIn, role == null);
    });
  }
  testWidgets('lookup failure is retryable and never implies pending', (tester) async {
    final auth = RestoredAuth()..fail = true;
    final backend = await start(tester, auth);
    await tester.pumpAndSettle();
    expect(backend.calls, isEmpty);
    expect(find.text('Your access could not be checked. Try again.'), findsOneWidget);
    auth.fail = false;
    await tester.tap(find.byKey(const Key('access-retry')));
    await tester.pumpAndSettle();
    expect(backend.calls, isNotEmpty);
    expect(auth.lookups, 2);
  });
  testWidgets('resume revalidates a changed backend role', (tester) async {
    final auth = RestoredAuth();
    await start(tester, auth);
    await tester.pumpAndSettle();
    auth.role = 'ops_admin';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(auth.lookups, 2);
    expect(auth.signedIn, isFalse);
    expect(find.byKey(const Key('access-retry')), findsOneWidget);
  });
  testWidgets('expired session on resume returns to login', (tester) async {
    final auth = RestoredAuth();
    await start(tester, auth);
    await tester.pumpAndSettle();
    auth.signedIn = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('phone')), findsOneWidget);
  });
  testWidgets('older role result cannot override a newer resume check', (tester) async {
    final auth = RestoredAuth()..lookup = Completer<String?>();
    final backend = await start(tester, auth);
    final older = auth.lookup!;
    auth.lookup = null;
    auth.role = 'ops_admin';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    older.complete('family');
    await tester.pumpAndSettle();
    expect(backend.calls, isEmpty);
    expect(auth.signedIn, isFalse);
  });
  testWidgets('phone and code validation make no auth call; failures allow retry', (tester) async {
    final auth = TrackingAuth();
    var signedIn = false;
    await pumpLocalized(tester, LoginScreen(auth: auth, onSignedIn: () => signedIn = true, onLocaleChanged: (_) {}));
    await tester.enterText(find.byKey(const Key('phone')), '12');
    await tapVisible(tester, find.text('Send code'));
    expect(auth.sends, 0);
    await tester.enterText(find.byKey(const Key('phone')), '9123456789');
    await tapVisible(tester, find.text('Send code'));
    expect(find.text('Signups not allowed for otp'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('phone')), '9000000101');
    await tapVisible(tester, find.text('Send code'));
    await tester.enterText(find.byKey(const Key('code')), '12');
    await tapVisible(tester, find.text('Sign in'));
    expect(auth.verifications, 0);
    await tester.enterText(find.byKey(const Key('code')), '654321');
    await tapVisible(tester, find.text('Sign in'));
    expect(find.text('Token has expired or is invalid'), findsOneWidget);
    expect(signedIn, isFalse);
    await tapVisible(tester, find.text('Use another number'));
    await tapVisible(tester, find.text('Send code'));
    expect(tester.widget<TextField>(find.byKey(const Key('code'))).controller!.text, isEmpty);
    await tester.enterText(find.byKey(const Key('code')), '123456');
    await tapVisible(tester, find.text('Sign in'));
    expect(signedIn, isTrue);
  });
  testWidgets('sending disables repeated submits and phone edits', (tester) async {
    final auth = TrackingAuth()..sending = Completer<void>();
    await pumpLocalized(tester, LoginScreen(auth: auth, onSignedIn: () {}, onLocaleChanged: (_) {}));
    await tester.enterText(find.byKey(const Key('phone')), '9000000101');
    await tester.tap(find.text('Send code'));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    expect(tester.widget<TextField>(find.byKey(const Key('phone'))).enabled, isFalse);
    expect(auth.sends, 1);
    auth.sending!.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('code')), findsOneWidget);
  });
  for (final state in [AccountState.pending, AccountState.disabled]) {
    testWidgets('authoritative $state blocks home until explicit recheck or event', (tester) async {
      final auth = RestoredAuth()..state = state;
      final backend = await start(tester, auth);
      await tester.pumpAndSettle();
      expect(backend.calls, isEmpty);
      expect(
        find.text(
          state == AccountState.pending
              ? 'Your pilot account setup is pending. Ops needs to finish your access setup.'
              : 'Your account access is disabled.',
        ),
        findsOneWidget,
      );
      auth.state = AccountState.active;
      auth.events.add(null);
      await tester.pumpAndSettle();
      expect(backend.calls, isNotEmpty);
      auth.state = AccountState.disabled;
      auth.events.add(null);
      await tester.pumpAndSettle();
      expect(find.text('Your account access is disabled.'), findsOneWidget);
    });
  }
  test('RPC adapter rechecks account denial but preserves normal permission errors', () async {
    for (final hint in ['account_access_required', 'patient permission']) {
      var rechecked = false;
      final client = SupabaseClient(
        'http://127.0.0.1:54321',
        'synthetic-anon',
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({'code': '42501', 'message': 'denied', 'hint': hint}),
            403,
            request: request,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      final rpc = supabaseRpc(client, onAccessDenied: () => rechecked = true);
      await expectLater(rpc('synthetic', {}), throwsA(isA<RpcException>()));
      expect(rechecked, hint == 'account_access_required');
      await client.dispose();
    }
  });

  test('Edge adapters recheck lifecycle denial without changing payment/vault permissions', () async {
    for (final message in ['account access required', 'not allowed']) {
      var rechecks = 0;
      final client = SupabaseClient(
        'http://127.0.0.1:54321',
        'synthetic-anon',
        httpClient: MockClient(
          (_) async => http.Response(
            jsonEncode({'error': 'not_allowed', 'message': message}),
            403,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      final files = SupabaseVaultFiles(client, 'http://127.0.0.1:54321', onAccessDenied: () => rechecks++);
      final payments = SupabasePayments(client, onAccessDenied: () => rechecks++);
      await expectLater(files.downloadUrl('synthetic-doc'), throwsA(isA<RpcException>()));
      await expectLater(payments.provider('synthetic-bill'), throwsA(isA<RpcException>()));
      expect(rechecks, message == 'account access required' ? 2 : 0);
      await client.dispose();
    }
  });
}
