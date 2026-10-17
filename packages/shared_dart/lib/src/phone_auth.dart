/// Phone-OTP sign-in. Apps depend on this interface; each app implements it
/// over Supabase Auth and tests pass a fake.
abstract class PhoneAuth {
  bool get isSignedIn;

  /// [phone] in E.164. Never creates accounts from the companion app.
  Future<void> sendCode(String phone);

  Future<void> verifyCode(String phone, String code);

  /// Safe self-only lifecycle resolution; never infer approval from a role.
  Future<AccountAccess> accountAccess();

  /// Auth events and lifecycle-denied requests trigger a new gate check.
  Stream<void> get accessChanges;

  Future<void> signOut();
}

/// Thrown by [PhoneAuth] with a message from the auth server.
class PhoneAuthException implements Exception {
  const PhoneAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum AccountState { pending, active, disabled, unconfirmed }

class AccountAccess {
  const AccountAccess(this.state, [this.role]);
  final AccountState state;
  final String? role;

  factory AccountAccess.fromJson(Object? data) {
    if (data is! Map) throw const FormatException('Invalid account access response');
    final state = AccountState.values.where((s) => s.name == data['state']).firstOrNull;
    final role = data['role'];
    if (state == null ||
        (state == AccountState.active ? !['family', 'companion', 'ops_admin'].contains(role) : role != null)) {
      throw const FormatException('Invalid account access response');
    }
    return AccountAccess(state, role as String?);
  }
}
