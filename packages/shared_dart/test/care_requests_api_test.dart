import 'package:shared_dart/shared_dart.dart';
import 'package:test/test.dart';

void main() {
  test('care request carries stable intent and UTC pickup, not client confirmation fields', () async {
    final calls = <(String, Map<String, Object?>)>[];
    final api = FamilyApi((function, params) async {
      calls.add((function, params));
      return 'request-1';
    });
    final id = await api.requestCare(
      requestId: 'request-1',
      patientId: 'patient-1',
      centreId: 'centre-1',
      packageId: 'package-1',
      pickupAt: DateTime.parse('2026-11-10T10:00:00+05:30'),
    );
    expect(id, 'request-1');
    expect(calls.single.$1, 'family_request_care');
    expect(calls.single.$2, <String, Object?>{
      'p_request_id': 'request-1',
      'p_patient_id': 'patient-1',
      'p_centre_id': 'centre-1',
      'p_package_id': 'package-1',
      'p_pickup_at': '2026-11-10T04:30:00.000Z',
    });
  });

  test('care options and request state are parsed from backend projections', () async {
    final api = FamilyApi(
      (function, params) async => switch (function) {
        'family_care_options' => {
          'centre_id': 'centre-1',
          'centre_name': 'Existing centre',
          'packages': [
            {'id': 'package-1', 'name': 'Basic'},
          ],
        },
        'family_care_requests' => [
          {
            'schedule_id': 'request-1',
            'patient_id': 'patient-1',
            'patient_name': 'Synthetic patient',
            'centre_id': 'centre-1',
            'centre_name': 'Existing centre',
            'package_id': 'package-1',
            'package_name': 'Basic',
            'pickup_at': '2026-11-10T04:30:00Z',
            'trip_id': 'trip-1',
            'trip_status': 'cancelled',
            'companion_name': null,
            'request_state': 'cancelled',
          },
        ],
        _ => throw StateError('Unexpected RPC'),
      },
    );
    final options = await api.careOptions('patient-1');
    expect(options.centreId, 'centre-1');
    expect(options.packages.single.name, 'Basic');
    final request = (await api.careRequests('patient-1')).single;
    expect(request.scheduleId, 'request-1');
    expect(request.requestState, 'cancelled');
    expect(request.tripStatus, TripStatus.cancelled);
    expect(request.companionName, isNull);
  });
}
