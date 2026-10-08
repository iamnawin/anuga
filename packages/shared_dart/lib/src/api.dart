import 'models.dart';
import 'trip_status.dart';

/// Calls a Postgres function exposed by Supabase. In the apps pass
/// `(fn, params) => supabase.rpc(fn, params: params)`; tests pass a fake.
typedef RpcCaller = Future<Object?> Function(String function, Map<String, Object?> params);

List<Json> _rows(Object? result) => [for (final r in result as List<dynamic>) r as Json];

Json _single(Object? result) => result is List ? result.single as Json : result as Json;

String _timestamp(DateTime value) => value.toUtc().toIso8601String();

/// Companion app calls. Authorization happens in the database.
class CompanionApi {
  const CompanionApi(this._rpc);

  final RpcCaller _rpc;

  Future<List<CompanionTrip>> myTrips({DateTime? from, DateTime? to}) async => [
    for (final row in _rows(
      await _rpc('companion_my_trips', {
        if (from != null) 'p_from': _timestamp(from),
        if (to != null) 'p_to': _timestamp(to),
      }),
    ))
      CompanionTrip.fromJson(row),
  ];

  Future<Trip> advance(String tripId, TripStatus to, {String? note, double? lat, double? lng}) async => Trip.fromJson(
    _single(
      await _rpc('advance_trip', {
        'p_trip_id': tripId,
        'p_to_status': to.dbValue,
        'p_note': note,
        'p_lat': lat,
        'p_lng': lng,
      }),
    ),
  );

  Future<OtpVerification> verifyPickupOtp(String tripId, String code, {double? lat, double? lng}) async =>
      OtpVerification.fromJson(
        _single(await _rpc('verify_pickup_otp', {'p_trip_id': tripId, 'p_code': code, 'p_lat': lat, 'p_lng': lng})),
      );
}

/// Family app calls.
class FamilyApi {
  const FamilyApi(this._rpc);

  final RpcCaller _rpc;

  Future<List<FamilyBoardRow>> tripBoard(String patientId, {DateTime? from, DateTime? to}) async => [
    for (final row in _rows(
      await _rpc('family_trip_board', {
        'p_patient_id': patientId,
        if (from != null) 'p_from': _timestamp(from),
        if (to != null) 'p_to': _timestamp(to),
      }),
    ))
      FamilyBoardRow.fromJson(row),
  ];

  /// Returns the 6-digit code to read out to the companion at the door.
  Future<String> issuePickupOtp(String tripId) async =>
      (await _rpc('issue_pickup_otp', {'p_trip_id': tripId})) as String;

  /// Patients the signed-in family member can see, with their access level.
  Future<List<FamilyPatient>> myPatients() async => [
    for (final row in _rows(await _rpc('family_my_patients', const {}))) FamilyPatient.fromJson(row),
  ];

  /// Status events of one trip, oldest first.
  Future<List<TripEvent>> timeline(String tripId) async => [
    for (final row in _rows(await _rpc('family_trip_timeline', {'p_trip_id': tripId}))) TripEvent.fromJson(row),
  ];

  /// In-app inbox, newest first.
  Future<List<InboxNotification>> notifications({int? limit}) async => [
    for (final row in _rows(await _rpc('my_notifications', {'p_limit': ?limit}))) InboxNotification.fromJson(row),
  ];

  /// Vault documents (each call is an audited vault read).
  Future<List<VaultDocument>> vaultDocuments(String patientId, {String purpose = 'family app: records'}) async => [
    for (final row in _rows(await _rpc('vault_list_documents', {'p_patient_id': patientId, 'p_purpose': purpose})))
      VaultDocument.fromJson(row),
  ];

  /// The owner's consent per purpose, and whether the caller may change it.
  Future<List<ConsentStatus>> consents(String patientId) async => [
    for (final row in _rows(await _rpc('family_consents', {'p_patient_id': patientId}))) ConsentStatus.fromJson(row),
  ];

  /// Owner only. Returns whether the consent is active afterwards.
  Future<bool> setConsent(String patientId, ConsentPurpose purpose, {required bool active}) async =>
      (await _rpc('set_consent', {'p_patient_id': patientId, 'p_purpose': purpose.dbValue, 'p_active': active}))
          as bool;

  Future<Trip> cancelTrip(String tripId, {String? reason}) async => Trip.fromJson(
    _single(
      await _rpc('advance_trip', {'p_trip_id': tripId, 'p_to_status': TripStatus.cancelled.dbValue, 'p_note': reason}),
    ),
  );
}

/// Ops calls (the ops console is Next.js; this serves Dart tools and tests).
class OpsApi {
  const OpsApi(this._rpc);

  final RpcCaller _rpc;

  Future<void> assignScheduleCompanions(String scheduleId, {required String primaryId, required String backupId}) =>
      _rpc('ops_assign_schedule_companions', {
        'p_schedule_id': scheduleId,
        'p_primary_id': primaryId,
        'p_backup_id': backupId,
      });

  Future<Trip> assignTripCompanion(String tripId, String companionId) async => Trip.fromJson(
    _single(await _rpc('ops_assign_trip_companion', {'p_trip_id': tripId, 'p_companion_id': companionId})),
  );

  Future<int> generateTrips(String scheduleId, {DateTime? from, int? days}) async => (await _rpc('ops_generate_trips', {
    'p_schedule_id': scheduleId,
    if (from != null) 'p_from': from.toIso8601String().substring(0, 10),
    'p_days': ?days,
  })) as int;
}
