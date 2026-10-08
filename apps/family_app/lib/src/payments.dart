import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bill payments through the `payments` Edge Function. Widgets depend on this
/// interface; tests pass a fake. The database lets only the owner pay an issued bill.
abstract class Payments {
  /// Which provider the server uses: `test` (no real money) or `razorpay`.
  Future<String> provider(String invoiceId);

  /// Test mode only: completes the payment as a provider would.
  Future<void> completeTestPayment(String invoiceId);
}

class SupabasePayments implements Payments {
  SupabasePayments(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> _call(Map<String, Object?> body) async {
    try {
      return (await _client.functions.invoke('payments', body: body)).data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      final details = e.details;
      throw RpcException(
        e.status == 403
            ? '42501'
            : e.status == 400
            ? '22023'
            : '${e.status}',
        details is Map ? '${details['message'] ?? details['error']}' : '$details',
      );
    }
  }

  @override
  Future<String> provider(String invoiceId) async =>
      (await _call({'action': 'start', 'invoice_id': invoiceId}))['provider'] as String;

  @override
  Future<void> completeTestPayment(String invoiceId) => _call({'action': 'complete-test', 'invoice_id': invoiceId});
}
