import 'package:shared_dart/shared_dart.dart';
import 'package:test/test.dart';

void main() {
  test('unified board is explicitly enabled and preserves server leg rights', () async {
    String? called;
    final api = CompanionApi((fn, args) async {
      called = fn;
      return [
        {
          'trip_id': 'synthetic',
          'scheduled_pickup_at': '2026-11-15T07:00:00Z',
          'scheduled_return_at': '2026-11-15T12:00:00Z',
          'status': 'handed_over',
          'centre_name': 'Synthetic Centre',
          'centre_address': 'Sample',
          'details_visible': false,
          'can_outbound': false,
          'can_return': true,
          'visit_plan': {
            'stays_through_session': false,
            'return_prepare_at': '2026-11-15T11:30:00Z',
            'return_arrive_by': '2026-11-15T11:45:00Z',
            'expected_ready_at': '2026-11-15T12:00:00Z',
            'return_end_at': '2026-11-15T13:00:00Z',
          },
        },
      ];
    }, visitPlansEnabled: true);
    final trips = await api.myTrips();
    expect(called, 'companion_visit_board');
    expect(trips.single.canOutbound, isFalse);
    expect(trips.single.canReturn, isTrue);
    expect(trips.single.visitPlan!.staysThroughSession, isFalse);
    expect(trips.single.patientName, isNull);
  });

  test('return verification never calls the home-pickup endpoint', () async {
    final calls = <String>[];
    final api = CompanionApi((fn, args) async {
      calls.add(fn);
      expect(args['p_trip_id'], 'synthetic');
      return {'ok': true, 'status': 'returning'};
    });
    expect((await api.verifyReturnPickup('synthetic', '123456')).ok, isTrue);
    expect(calls, ['verify_return_pickup']);
  });

  test('legacy Family client does not request absent plan endpoints', () async {
    final api = FamilyApi((fn, args) async => throw StateError('Unexpected RPC'));
    expect(await api.visitPlan('synthetic'), isNull);
  });
}
