import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'rpc.dart';

/// [RpcCaller] over a Supabase client. Postgres errors become [RpcException]
/// so the rest of the app never depends on the SDK's exception types.
RpcCaller supabaseRpc(SupabaseClient client) => (function, params) async {
  try {
    return await client.rpc<Object?>(function, params: params);
  } on PostgrestException catch (e) {
    throw RpcException(e.code ?? '', e.message);
  }
};
