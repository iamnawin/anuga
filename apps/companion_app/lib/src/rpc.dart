/// A database error surfaced by an RPC, independent of the Supabase SDK so
/// widgets and tests do not depend on it. [code] is the Postgres SQLSTATE.
class RpcException implements Exception {
  const RpcException(this.code, this.message);

  final String code;
  final String message;

  /// `42501`: the database refused (not this companion's trip, wrong role).
  bool get isNotAllowed => code == '42501';

  /// `22023`: the transition is not allowed from the trip's current status.
  bool get isStepNotPossible => code == '22023';

  @override
  String toString() => 'RpcException($code): $message';
}
