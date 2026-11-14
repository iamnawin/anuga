import 'package:http/http.dart' as http;
import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The HTTP client's own failure: the request never got an answer.
bool isTransportError(Object error) => error is http.ClientException;

/// [RpcCaller] over a Supabase client. Postgres errors become [RpcException]
/// so the rest of the app never depends on the SDK's exception types. Transport
/// failures and stalled requests become [NetworkException] and [RequestTimeoutException].
RpcCaller supabaseRpc(SupabaseClient client) =>
    (function, params) => guardRequest(() async {
      try {
        return await client.rpc<Object?>(function, params: params);
      } on PostgrestException catch (e) {
        throw RpcException(e.code ?? '', e.message);
      }
    }, isNetworkError: isTransportError);
