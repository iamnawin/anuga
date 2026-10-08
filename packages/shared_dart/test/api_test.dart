import 'package:shared_dart/shared_dart.dart';
import 'package:test/test.dart';

/// Records calls and returns canned responses shaped like PostgREST output
/// (copied from the M1 database tests' rows).
class FakeRpc {
  FakeRpc(this.responses);

  final Map<String, Object?> responses;
  final calls = <(String, Map<String, Object?>)>[];

  Future<Object?> call(String function, Map<String, Object?> params) async {
    calls.add((function, params));
    return responses[function];
  }
}

const _tripRow = {
  'id': 't1',
  'patient_id': 'p1',
  'companion_id': 'c1',
  'status': 'handed_over',
  'scheduled_pickup_at': '2026-10-09T01:30:00+00:00',
  'scheduled_return_at': '2026-10-09T06:30:00+00:00',
  'post_visit_note': null,
};

void main() {
  test('companion trips parse visible and hidden rows', () async {
    final rpc = FakeRpc({
      'companion_my_trips': [
        {
          'trip_id': 't1',
          'scheduled_pickup_at': '2026-10-09T01:30:00+00:00',
          'scheduled_return_at': '2026-10-09T06:30:00+00:00',
          'status': 'scheduled',
          'centre_name': 'Synthetic Dialysis Centre 1',
          'centre_address': '1 Example Road',
          'details_visible': true,
          'patient_name': 'Lakshmi Rao (synthetic)',
          'home_address': '22 Sample Colony',
          'home_lat': 17.495,
          'home_lng': 78.405,
          'mobility_notes': 'Uses a walking stick',
          'emergency_contacts': [
            {'name': 'Kiran Rao (synthetic)', 'phone': '+919000000101', 'relation': 'son'},
          ],
        },
        {
          'trip_id': 't2',
          'scheduled_pickup_at': '2026-10-14T01:30:00+00:00',
          'scheduled_return_at': '2026-10-14T06:30:00+00:00',
          'status': 'scheduled',
          'centre_name': 'Synthetic Dialysis Centre 1',
          'centre_address': '1 Example Road',
          'details_visible': false,
          'patient_name': null,
          'home_address': null,
          'home_lat': null,
          'home_lng': null,
          'mobility_notes': null,
          'emergency_contacts': null,
        },
      ],
    });

    final trips = await CompanionApi(rpc.call).myTrips(from: DateTime.utc(2026, 10, 8));

    expect(rpc.calls.single.$1, 'companion_my_trips');
    expect(rpc.calls.single.$2, {'p_from': '2026-10-08T00:00:00.000Z'});
    expect(trips.first.patientName, 'Lakshmi Rao (synthetic)');
    expect(trips.first.emergencyContacts.single.relation, 'son');
    expect(trips.first.homeLat, 17.495);
    expect(trips.last.detailsVisible, isFalse);
    expect(trips.last.homeAddress, isNull);
    expect(trips.last.emergencyContacts, isEmpty);
  });

  test('advance sends the database status value', () async {
    final rpc = FakeRpc({'advance_trip': _tripRow});
    final trip = await CompanionApi(rpc.call).advance('t1', TripStatus.handedOver, note: 'Front desk (synthetic)');
    expect(rpc.calls.single.$2['p_to_status'], 'handed_over');
    expect(rpc.calls.single.$2['p_note'], 'Front desk (synthetic)');
    expect(trip.status, TripStatus.handedOver);
  });

  test('a wrong OTP is a result, not an exception', () async {
    final rpc = FakeRpc({
      'verify_pickup_otp': {'ok': false, 'reason': 'wrong_code', 'attempts_left': 4},
    });
    final result = await CompanionApi(rpc.call).verifyPickupOtp('t1', '000000');
    expect(result.ok, isFalse);
    expect(result.reason, 'wrong_code');
    expect(result.attemptsLeft, 4);
  });

  test('successful OTP returns the picked_up status', () async {
    final rpc = FakeRpc({
      'verify_pickup_otp': {'ok': true, 'status': 'picked_up'},
    });
    final result = await CompanionApi(rpc.call).verifyPickupOtp('t1', '123456');
    expect(result.status, TripStatus.pickedUp);
  });

  test('family board flags a trip covered by the backup', () async {
    final rpc = FakeRpc({
      'family_trip_board': [
        {
          'trip_id': 't1',
          'scheduled_pickup_at': '2026-10-09T01:30:00+00:00',
          'scheduled_return_at': '2026-10-09T06:30:00+00:00',
          'status': 'scheduled',
          'centre_name': 'Synthetic Dialysis Centre 1',
          'companion_name': 'Ravi Companion (synthetic)',
          'primary_companion_name': 'Asha Companion (synthetic)',
          'backup_companion_name': 'Ravi Companion (synthetic)',
        },
      ],
    });
    final rows = await FamilyApi(rpc.call).tripBoard('p1');
    expect(rpc.calls.single.$2, {'p_patient_id': 'p1'});
    expect(rows.single.isCoveredByBackup, isTrue);
  });

  test('family cancel and OTP issue call the right functions', () async {
    final rpc = FakeRpc({
      'advance_trip': {..._tripRow, 'status': 'cancelled'},
      'issue_pickup_otp': '042517',
    });
    final api = FamilyApi(rpc.call);
    expect(await api.issuePickupOtp('t1'), '042517');
    final trip = await api.cancelTrip('t1', reason: 'Admitted elsewhere');
    expect(trip.status, TripStatus.cancelled);
    expect(rpc.calls.last.$2['p_to_status'], 'cancelled');
  });

  test('ops calls pass schedule, companions and dates', () async {
    final rpc = FakeRpc({'ops_generate_trips': 6, 'ops_assign_trip_companion': _tripRow});
    final api = OpsApi(rpc.call);
    await api.assignScheduleCompanions('s1', primaryId: 'c1', backupId: 'c2');
    expect(await api.generateTrips('s1', from: DateTime(2026, 10, 12), days: 14), 6);
    await api.assignTripCompanion('t1', 'c2');
    expect(rpc.calls[0].$2, {'p_schedule_id': 's1', 'p_primary_id': 'c1', 'p_backup_id': 'c2'});
    expect(rpc.calls[1].$2, {'p_schedule_id': 's1', 'p_from': '2026-10-12', 'p_days': 14});
    expect(rpc.calls[2].$1, 'ops_assign_trip_companion');
  });
}
