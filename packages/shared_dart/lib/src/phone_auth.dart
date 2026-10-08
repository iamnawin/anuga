/// Phone-OTP sign-in. Apps depend on this interface; each app implements it
/// over Supabase Auth and tests pass a fake.
abstract class PhoneAuth {
  bool get isSignedIn;

  /// [phone] in E.164. Never creates accounts from the companion app.
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
