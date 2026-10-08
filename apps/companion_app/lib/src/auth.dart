import 'package:supabase_flutter/supabase_flutter.dart';

/// Phone-OTP sign-in. The app depends on this interface; tests pass a fake.
abstract class PhoneAuth {
  bool get isSignedIn;

  /// [phone] in E.164. Never creates accounts: companions are onboarded by ops.
  Future<void> sendCode(String phone);

  Future<void> verifyCode(String phone, String code);

  /// `profiles.role` of the signed-in user (`companion`, `family`, `ops_admin`).
  Future<String?> currentRole();

  Future<void> signOut();
}

/// Thrown by [PhoneAuth] with a message from the auth server.
class PhoneAuthException implements Exception {
  const PhoneAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

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
