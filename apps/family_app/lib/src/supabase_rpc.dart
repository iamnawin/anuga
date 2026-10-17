import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [RpcCaller] over a Supabase client. Postgres errors become [RpcException]
/// so the rest of the app never depends on the SDK's exception types.
RpcCaller supabaseRpc(SupabaseClient client, {void Function()? onAccessDenied}) => (function, params) async {
  try {
    return await client.rpc<Object?>(function, params: params);
  } on PostgrestException catch (e) {
    if (e.code == '42501' && e.hint == 'account_access_required') onAccessDenied?.call();
    throw RpcException(e.code ?? '', e.message);
  }
};
