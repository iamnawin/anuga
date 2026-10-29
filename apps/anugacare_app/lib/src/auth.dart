import 'package:family_app/family_app.dart' show SupabasePhoneAuth;
import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The stored session can no longer be used (refresh token revoked or expired).
class SessionExpiredException implements Exception {
  const SessionExpiredException();
}

/// [PhoneAuth] for the unified app: [currentRole] throws [SessionExpiredException]
/// when the session is no longer valid, and [sessionEnded] fires whenever the
/// session ends (the app ignores the ones it caused itself).
abstract class AccountAuth implements PhoneAuth {
  Stream<void> get sessionEnded;
}

/// [AccountAuth] over Supabase Auth. Sign-in and role lookup are the existing
/// [SupabasePhoneAuth] (no account creation; role from `profiles.role`, which RLS
/// limits to the user's own row and users cannot update).
class SupabaseAccountAuth extends SupabasePhoneAuth implements AccountAuth {
  SupabaseAccountAuth(this._client) : super(_client);

  final SupabaseClient _client;

  @override
  Stream<void> get sessionEnded =>
      _client.auth.onAuthStateChange.where((state) => state.event == AuthChangeEvent.signedOut).map((_) {});

  @override
  Future<String?> currentRole() async {
    try {
      return await super.currentRole();
    } on AuthException {
      throw const SessionExpiredException();
    } on PostgrestException catch (e) {
      // PostgREST: PGRST301 (older) / PGRST303 (newer) = JWT expired or invalid.
      if (e.code == 'PGRST301' || e.code == 'PGRST303') throw const SessionExpiredException();
      rethrow;
    }
  }
}
