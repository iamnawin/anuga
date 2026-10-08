import 'trip_status.dart';

typedef Json = Map<String, dynamic>;

DateTime _time(Object? value) => DateTime.parse(value as String);

/// Row of `companion_my_trips()`. Patient fields are null outside the
/// visibility window ([detailsVisible] is false).
class CompanionTrip {
  const CompanionTrip({
    required this.tripId,
    required this.scheduledPickupAt,
    required this.scheduledReturnAt,
    required this.status,
    required this.centreName,
    required this.centreAddress,
    required this.detailsVisible,
    this.patientName,
    this.homeAddress,
    this.homeLat,
    this.homeLng,
    this.mobilityNotes,
    this.emergencyContacts = const [],
  });

  factory CompanionTrip.fromJson(Json json) => CompanionTrip(
    tripId: json['trip_id'] as String,
    scheduledPickupAt: _time(json['scheduled_pickup_at']),
    scheduledReturnAt: _time(json['scheduled_return_at']),
    status: TripStatus.fromDb(json['status'] as String),
    centreName: json['centre_name'] as String,
    centreAddress: json['centre_address'] as String,
    detailsVisible: json['details_visible'] as bool,
    patientName: json['patient_name'] as String?,
    homeAddress: json['home_address'] as String?,
    homeLat: (json['home_lat'] as num?)?.toDouble(),
    homeLng: (json['home_lng'] as num?)?.toDouble(),
    mobilityNotes: json['mobility_notes'] as String?,
    emergencyContacts: [
      for (final c in (json['emergency_contacts'] as List<dynamic>? ?? const [])) EmergencyContact.fromJson(c as Json),
    ],
  );

  final String tripId;
  final DateTime scheduledPickupAt;
  final DateTime scheduledReturnAt;
  final TripStatus status;
  final String centreName;
  final String centreAddress;
  final bool detailsVisible;
  final String? patientName;
  final String? homeAddress;
  final double? homeLat;
  final double? homeLng;
  final String? mobilityNotes;
  final List<EmergencyContact> emergencyContacts;
}

class EmergencyContact {
  const EmergencyContact({required this.name, required this.phone, this.relation});

  factory EmergencyContact.fromJson(Json json) => EmergencyContact(
    name: json['name'] as String,
    phone: json['phone'] as String,
    relation: json['relation'] as String?,
  );

  final String name;
  final String phone;
  final String? relation;
}

/// Row of `family_trip_board()`.
class FamilyBoardRow {
  const FamilyBoardRow({
    required this.tripId,
    required this.scheduledPickupAt,
    required this.scheduledReturnAt,
    required this.status,
    required this.centreName,
    this.companionName,
    this.primaryCompanionName,
    this.backupCompanionName,
  });

  factory FamilyBoardRow.fromJson(Json json) => FamilyBoardRow(
    tripId: json['trip_id'] as String,
    scheduledPickupAt: _time(json['scheduled_pickup_at']),
    scheduledReturnAt: _time(json['scheduled_return_at']),
    status: TripStatus.fromDb(json['status'] as String),
    centreName: json['centre_name'] as String,
    companionName: json['companion_name'] as String?,
    primaryCompanionName: json['primary_companion_name'] as String?,
    backupCompanionName: json['backup_companion_name'] as String?,
  );

  final String tripId;
  final DateTime scheduledPickupAt;
  final DateTime scheduledReturnAt;
  final TripStatus status;
  final String centreName;
  final String? companionName;
  final String? primaryCompanionName;
  final String? backupCompanionName;

  /// The backup (not the primary) is covering this trip.
  bool get isCoveredByBackup =>
      companionName != null && primaryCompanionName != null && companionName != primaryCompanionName;
}

/// Row of `public.trips` as returned by `advance_trip()` and the ops RPCs.
class Trip {
  const Trip({
    required this.id,
    required this.patientId,
    required this.status,
    required this.scheduledPickupAt,
    required this.scheduledReturnAt,
    this.companionId,
    this.postVisitNote,
  });

  factory Trip.fromJson(Json json) => Trip(
    id: json['id'] as String,
    patientId: json['patient_id'] as String,
    status: TripStatus.fromDb(json['status'] as String),
    scheduledPickupAt: _time(json['scheduled_pickup_at']),
    scheduledReturnAt: _time(json['scheduled_return_at']),
    companionId: json['companion_id'] as String?,
    postVisitNote: json['post_visit_note'] as String?,
  );

  final String id;
  final String patientId;
  final TripStatus status;
  final DateTime scheduledPickupAt;
  final DateTime scheduledReturnAt;
  final String? companionId;
  final String? postVisitNote;
}

/// Result of `verify_pickup_otp()`. Wrong codes are results, not errors.
class OtpVerification {
  const OtpVerification({required this.ok, this.status, this.reason, this.attemptsLeft});

  factory OtpVerification.fromJson(Json json) => OtpVerification(
    ok: json['ok'] as bool,
    status: json['status'] == null ? null : TripStatus.fromDb(json['status'] as String),
    reason: json['reason'] as String?,
    attemptsLeft: json['attempts_left'] as int?,
  );

  final bool ok;
  final TripStatus? status;

  /// `wrong_code` or `no_valid_code` (expired, used, locked or never issued).
  final String? reason;
  final int? attemptsLeft;
}
