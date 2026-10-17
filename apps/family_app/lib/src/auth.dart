import 'dart:async';

import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Existing Auth OTP plus the authoritative, self-only lifecycle resolver.
class SupabasePhoneAuth implements PhoneAuth {
  SupabasePhoneAuth(this._client);

  final SupabaseClient _client;

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  Future<void> sendCode(String phone) =>
      _guard(() => _client.auth.signInWithOtp(phone: phone, shouldCreateUser: false));

  @override
  Future<void> verifyCode(String phone, String code) =>
      _guard(() => _client.auth.verifyOTP(type: OtpType.sms, phone: phone, token: code));

  final _invalidations = StreamController<void>.broadcast();

  void invalidateAccess() => _invalidations.add(null);

  @override
  Stream<void> get accessChanges => Stream<void>.multi((events) {
    final auth = _client.auth.onAuthStateChange.listen((_) => events.add(null));
    final denied = _invalidations.stream.listen((_) => events.add(null));
    events.onCancel = () async {
      await auth.cancel();
      await denied.cancel();
    };
  });

  @override
  Future<AccountAccess> accountAccess() async =>
      AccountAccess.fromJson(await _client.rpc<Object?>('my_account_access'));

  @override
  Future<void> signOut() => _client.auth.signOut();

  Future<void> _guard(Future<Object?> Function() call) async {
    try {
      await call();
    } on AuthException catch (e) {
      throw PhoneAuthException(e.message);
    }
  }
}
