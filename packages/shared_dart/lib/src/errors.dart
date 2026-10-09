/// A database error surfaced by an RPC, independent of the Supabase SDK so app
/// widgets and tests do not depend on it. [code] is the Postgres SQLSTATE.
/// Apps convert the SDK's exception into this in one adapter.
class RpcException implements Exception {
  const RpcException(this.code, this.message);

  final String code;
  final String message;

  /// `42501`: the database refused (not the caller's trip, wrong role or access level).
  bool get isNotAllowed => code == '42501';

  /// `22023`: the request is invalid now, e.g. a transition not allowed from the current status.
  bool get isStepNotPossible => code == '22023';

  @override
  String toString() => 'RpcException($code): $message';
}
