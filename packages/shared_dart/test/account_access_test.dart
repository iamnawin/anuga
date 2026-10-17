import 'package:shared_dart/shared_dart.dart';
import 'package:test/test.dart';

void main() {
  test('authoritative lifecycle parsing never infers active from a role', () {
    for (final state in ['pending', 'disabled', 'unconfirmed']) {
      final access = AccountAccess.fromJson({'state': state, 'role': null});
      expect(access.state.name, state);
      expect(access.role, isNull);
    }
    expect(AccountAccess.fromJson({'state': 'active', 'role': 'family'}).role, 'family');
    for (final invalid in [
      null,
      {},
      {'role': 'family'},
      {'state': 'active', 'role': null},
      {'state': 'approved', 'role': 'ops_admin'},
    ]) {
      expect(() => AccountAccess.fromJson(invalid), throwsFormatException);
    }
  });
}
