import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Vault file transfer through the `vault-files` Edge Function. Widgets depend
/// on this interface; tests pass a fake. The function asks the database (as the
/// signed-in user) before it signs any URL; this app never sees a storage path.
abstract class VaultFiles {
  /// Creates the document record and returns a signed upload URL for it.
  Future<({String documentId, Uri uploadUrl})> startUpload({
    required String patientId,
    required String docType,
    required String title,
    required String contentType,
    required int sizeBytes,
  });

  Future<void> putFile(Uri uploadUrl, Uint8List bytes, String contentType);

  /// Marks the document uploaded once the file is in storage.
  Future<void> confirm(String documentId);

  /// A short-lived URL for viewing; each call is an audited vault read.
  Future<Uri> downloadUrl(String documentId);
}

/// [VaultFiles] over Supabase. [baseUrl] is the app's Supabase URL: the function
/// returns URL paths so phones never see an internal address.
class SupabaseVaultFiles implements VaultFiles {
  SupabaseVaultFiles(this._client, this._baseUrl, {http.Client? httpClient, this.onAccessDenied})
    : _http = httpClient ?? http.Client();

  final SupabaseClient _client;
  final String _baseUrl;
  final void Function()? onAccessDenied;
  final http.Client _http;

  Future<Map<String, dynamic>> _call(Map<String, Object?> body) async {
    try {
      final response = await _client.functions.invoke('vault-files', body: body);
      return response.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      final details = e.details;
      if (e.status == 403 && details is Map && details['message'] == 'account access required') onAccessDenied?.call();
      final message = details is Map ? '${details['message'] ?? details['error']}' : '$details';
      // Same classification as database errors, so screens handle both alike.
      throw RpcException(
        e.status == 403
            ? '42501'
            : e.status == 400
            ? '22023'
            : '${e.status}',
        message,
      );
    }
  }

  Uri _url(String path) => Uri.parse('${_baseUrl.replaceAll(RegExp(r'/$'), '')}$path');

  @override
  Future<({String documentId, Uri uploadUrl})> startUpload({
    required String patientId,
    required String docType,
    required String title,
    required String contentType,
    required int sizeBytes,
  }) async {
    final data = await _call({
      'action': 'upload',
      'patient_id': patientId,
      'doc_type': docType,
      'title': title,
      'content_type': contentType,
      'size_bytes': sizeBytes,
    });
    return (documentId: data['document_id'] as String, uploadUrl: _url(data['upload_path'] as String));
  }

  @override
  Future<void> putFile(Uri uploadUrl, Uint8List bytes, String contentType) async {
    final response = await _http.put(uploadUrl, headers: {'Content-Type': contentType}, body: bytes);
    if (response.statusCode >= 300) throw RpcException('${response.statusCode}', 'upload failed');
  }

  @override
  Future<void> confirm(String documentId) => _call({'action': 'confirm', 'document_id': documentId});

  @override
  Future<Uri> downloadUrl(String documentId) async =>
      _url((await _call({'action': 'download', 'document_id': documentId}))['download_path'] as String);
}
