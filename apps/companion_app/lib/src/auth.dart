import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [PhoneAuth] over Supabase Auth. Never creates accounts: companions are onboarded by ops.
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

  @override
  Future<String?> currentRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client.from('profiles').select('role').eq('id', user.id).maybeSingle();
    return row?['role'] as String?;
  }

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
