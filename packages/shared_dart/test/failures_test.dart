import 'dart:async';

import 'package:shared_dart/shared_dart.dart';
import 'package:test/test.dart';

class _Transport implements Exception {}

bool _isTransport(Object e) => e is _Transport;

void main() {
  group('classifyFailure', () {
    test('typed transport failures', () {
      expect(classifyFailure(const NetworkException()), FailureKind.network);
      expect(classifyFailure(const RequestTimeoutException()), FailureKind.timeout);
    });

    test('database and function codes', () {
      FailureKind kind(String code) => classifyFailure(RpcException(code, 'internal text'));
      expect(kind('42501'), FailureKind.notAllowed);
      expect(kind('22023'), FailureKind.outOfDate);
      expect(kind('P0002'), FailureKind.notFound);
      expect(kind('23505'), FailureKind.alreadyDone);
      expect(kind('PGRST301'), FailureKind.sessionExpired);
      expect(kind('PGRST303'), FailureKind.sessionExpired);
      expect(kind('401'), FailureKind.sessionExpired);
      expect(kind('P0001'), FailureKind.server);
      expect(kind('500'), FailureKind.server);
      expect(kind(''), FailureKind.server);
    });

    test('anything unknown is a server failure', () {
      expect(classifyFailure(StateError('bug')), FailureKind.server);
      expect(classifyFailure('text'), FailureKind.server);
    });
  });

  group('failureCode', () {
    test('kind alone when there is no database code', () {
      expect(failureCode(const NetworkException()), 'NET');
      expect(failureCode(const RequestTimeoutException()), 'TIM');
      expect(failureCode(StateError('bug')), 'SRV');
      expect(failureCode(const RpcException('', 'x')), 'SRV');
    });

    test('kind and code, never the message', () {
      expect(failureCode(const RpcException('42501', 'not owner of patient 123')), 'DEN-42501');
      expect(failureCode(const RpcException('P0001', 'secret detail')), 'SRV-P0001');
      expect(failureCode(const RpcException('500', 'secret detail')), 'SRV-500');
    });

    test('odd codes are cleaned and shortened', () {
      expect(failureCode(const RpcException('ab-cd ef/123456789', 'x')), 'SRV-abcdef12');
    });
  });

  group('guardRequest', () {
    test('returns the answer', () async {
      expect(await guardRequest(() async => 7, isNetworkError: _isTransport), 7);
    });

    test('transport error becomes NetworkException', () {
      expect(
        guardRequest<int>(() async => throw _Transport(), isNetworkError: _isTransport),
        throwsA(isA<NetworkException>()),
      );
    });

    test('no answer in time becomes RequestTimeoutException', () {
      expect(
        guardRequest<int>(
          () => Completer<int>().future,
          isNetworkError: _isTransport,
          limit: const Duration(milliseconds: 10),
        ),
        throwsA(isA<RequestTimeoutException>()),
      );
    });

    test('other errors pass through unchanged', () {
      const denied = RpcException('42501', 'no');
      expect(guardRequest<int>(() async => throw denied, isNetworkError: _isTransport), throwsA(same(denied)));
    });
  });
}
