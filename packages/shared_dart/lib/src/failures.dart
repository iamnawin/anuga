import 'dart:async';

import 'errors.dart';

/// Thrown by an app's backend adapter when a request failed in transit
/// (no connection, dropped connection). No server answer was received.
class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException';
}

/// Thrown by an app's backend adapter when no answer came within the time limit.
/// The server may still have applied a write, so callers must not repeat one blindly.
class RequestTimeoutException implements Exception {
  const RequestTimeoutException();

  @override
  String toString() => 'RequestTimeoutException';
}

/// How long a normal request may take before the app stops waiting.
const requestTimeLimit = Duration(seconds: 20);

/// How long a file upload may take.
const uploadTimeLimit = Duration(seconds: 60);

/// What went wrong, in terms a screen can explain. [prefix] starts the support code.
enum FailureKind {
  network('NET'),
  timeout('TIM'),
  sessionExpired('SES'),
  notAllowed('DEN'),
  outOfDate('OLD'),
  notFound('NFD'),
  alreadyDone('DUP'),
  server('SRV');

  const FailureKind(this.prefix);

  final String prefix;
}

/// Sorts any caught error into a [FailureKind]. Unknown errors are [FailureKind.server].
FailureKind classifyFailure(Object error) {
  if (error is NetworkException) return FailureKind.network;
  if (error is RequestTimeoutException) return FailureKind.timeout;
  if (error is! RpcException) return FailureKind.server;
  return switch (error.code) {
    '42501' => FailureKind.notAllowed,
    '22023' => FailureKind.outOfDate,
    'P0002' => FailureKind.notFound,
    '23505' => FailureKind.alreadyDone,
    // PostgREST JWT expired or invalid; 401 from an Edge Function.
    'PGRST301' || 'PGRST303' || '401' => FailureKind.sessionExpired,
    _ => FailureKind.server,
  };
}

/// A short code the user can read out to support: the kind, plus the database
/// or HTTP code when there is one. Never contains a message, a name or an id.
String failureCode(Object error) {
  final kind = classifyFailure(error);
  final code = error is RpcException ? error.code.replaceAll(RegExp('[^A-Za-z0-9]'), '') : '';
  if (code.isEmpty) return kind.prefix;
  return '${kind.prefix}-${code.length > 8 ? code.substring(0, 8) : code}';
}

/// Runs [request] with a time limit and turns transport failures into the typed
/// exceptions above. [isNetworkError] names the SDK's transport error, so this
/// package stays free of SDK dependencies.
Future<T> guardRequest<T>(
  Future<T> Function() request, {
  required bool Function(Object error) isNetworkError,
  Duration limit = requestTimeLimit,
}) async {
  try {
    return await request().timeout(limit);
  } on TimeoutException {
    throw const RequestTimeoutException();
  } catch (e) {
    if (isNetworkError(e)) throw const NetworkException();
    rethrow;
  }
}
