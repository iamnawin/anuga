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

/// A user's relationship to a patient. Matches `public.access_level`.
enum AccessLevel {
  owner('owner'),
  editor('editor'),
  viewer('viewer'),
  patient('patient');

  const AccessLevel(this.dbValue);

  final String dbValue;

  static AccessLevel fromDb(String value) => values.firstWhere(
    (a) => a.dbValue == value,
    orElse: () => throw ArgumentError.value(value, 'value', 'unknown access level'),
  );

  /// Mirrors `issue_pickup_otp()`: owner, editor or the patient may issue the code.
  bool get canIssuePickupOtp => this == owner || this == editor || this == patient;

  /// Mirrors `advance_trip()` for family: owner and editor act as the `family` actor.
  bool get canChangeTrips => this == owner || this == editor;
}

/// Row of `family_my_patients()`.
class FamilyPatient {
  const FamilyPatient({
    required this.patientId,
    required this.fullName,
    required this.accessLevel,
    required this.centreName,
  });

  factory FamilyPatient.fromJson(Json json) => FamilyPatient(
    patientId: json['patient_id'] as String,
    fullName: json['full_name'] as String,
    accessLevel: AccessLevel.fromDb(json['access_level'] as String),
    centreName: json['centre_name'] as String,
  );

  final String patientId;
  final String fullName;
  final AccessLevel accessLevel;
  final String centreName;
}

/// Row of `family_trip_timeline()`.
class TripEvent {
  const TripEvent({
    required this.eventId,
    required this.toStatus,
    required this.createdAt,
    this.fromStatus,
    this.actorKind,
    this.note,
  });

  factory TripEvent.fromJson(Json json) => TripEvent(
    eventId: (json['event_id'] as num).toInt(),
    fromStatus: json['from_status'] == null ? null : TripStatus.fromDb(json['from_status'] as String),
    toStatus: TripStatus.fromDb(json['to_status'] as String),
    actorKind: json['actor_kind'] == null ? null : TransitionActor.fromDb(json['actor_kind'] as String),
    note: json['note'] as String?,
    createdAt: _time(json['created_at']),
  );

  final int eventId;
  final TripStatus? fromStatus;
  final TripStatus toStatus;
  final TransitionActor? actorKind;
  final String? note;
  final DateTime createdAt;
}

/// Row of `my_notifications()`: the in-app inbox (push channel).
class InboxNotification {
  const InboxNotification({
    required this.notificationId,
    required this.template,
    required this.payload,
    required this.createdAt,
    this.tripId,
  });

  factory InboxNotification.fromJson(Json json) => InboxNotification(
    notificationId: (json['notification_id'] as num).toInt(),
    tripId: json['trip_id'] as String?,
    template: json['template'] as String,
    payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
    createdAt: _time(json['created_at']),
  );

  final int notificationId;
  final String? tripId;

  /// `trip_status_changed`, `companion_assigned`, `companion_changed`, ...
  final String template;
  final Json payload;
  final DateTime createdAt;

  /// For `trip_status_changed`: the new status.
  TripStatus? get toStatus {
    final value = payload['to_status'];
    return value is String ? TripStatus.fromDb(value) : null;
  }
}

/// Row of `vault_list_documents()` (an audited vault read). The storage path is
/// not exposed: files are fetched only through signed URLs from `vault-files`.
class VaultDocument {
  const VaultDocument({
    required this.id,
    required this.docType,
    required this.title,
    required this.status,
    required this.createdAt,
    this.contentType,
    this.sizeBytes,
  });

  factory VaultDocument.fromJson(Json json) => VaultDocument(
    id: json['id'] as String,
    docType: json['doc_type'] as String,
    title: json['title'] as String,
    status: json['status'] as String,
    createdAt: _time(json['created_at']),
    contentType: json['content_type'] as String?,
    sizeBytes: (json['size_bytes'] as num?)?.toInt(),
  );

  /// The document types the database accepts (`vault_documents.doc_type`).
  static const docTypes = ['lab_report', 'prescription', 'discharge_summary', 'receipt', 'other'];

  final String id;
  final String docType;
  final String title;

  /// `pending_upload` until the file is confirmed in storage, then `uploaded`.
  final String status;
  final DateTime createdAt;
  final String? contentType;
  final int? sizeBytes;

  bool get isUploaded => status == 'uploaded';
  bool get isImage => contentType?.startsWith('image/') ?? false;
}

/// Matches `public.consent_purpose`.
enum ConsentPurpose {
  trips('trips'),
  vault('vault'),
  opsVaultAccess('ops_vault_access');

  const ConsentPurpose(this.dbValue);

  final String dbValue;

  static ConsentPurpose fromDb(String value) => values.firstWhere(
    (p) => p.dbValue == value,
    orElse: () => throw ArgumentError.value(value, 'value', 'unknown consent purpose'),
  );
}

/// Row of `family_consents()`: the owner's consent for one purpose.
class ConsentStatus {
  const ConsentStatus({required this.purpose, required this.active, required this.canChange, this.grantedAt});

  factory ConsentStatus.fromJson(Json json) => ConsentStatus(
    purpose: ConsentPurpose.fromDb(json['purpose'] as String),
    active: json['active'] as bool,
    canChange: json['can_change'] as bool,
    grantedAt: json['granted_at'] == null ? null : _time(json['granted_at']),
  );

  final ConsentPurpose purpose;
  final bool active;

  /// Only the patient's owner can change consents.
  final bool canChange;
  final DateTime? grantedAt;
}

DateTime _date(Object? value) => DateTime.parse(value as String);

/// Row of `family_invoices()`: an issued or paid monthly bill (amounts in paise).
class Invoice {
  const Invoice({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.totalPaise,
    required this.packageName,
    required this.canPay,
    this.issuedAt,
    this.paidAt,
  });

  factory Invoice.fromJson(Json json) => Invoice(
    id: json['invoice_id'] as String,
    periodStart: _date(json['period_start']),
    periodEnd: _date(json['period_end']),
    status: json['status'] as String,
    totalPaise: (json['total_paise'] as num).toInt(),
    packageName: json['package_name'] as String,
    canPay: json['can_pay'] as bool,
    issuedAt: json['issued_at'] == null ? null : _time(json['issued_at']),
    paidAt: json['paid_at'] == null ? null : _time(json['paid_at']),
  );

  final String id;
  final DateTime periodStart;
  final DateTime periodEnd;

  /// `issued` (due) or `paid`; drafts are never shown to family.
  final String status;
  final int totalPaise;
  final String packageName;

  /// True for the owner while the bill is due.
  final bool canPay;
  final DateTime? issuedAt;
  final DateTime? paidAt;

  bool get isPaid => status == 'paid';
}

/// Row of `family_invoice_lines()`.
class InvoiceLine {
  const InvoiceLine({required this.kind, required this.amountPaise, this.serviceDate});

  factory InvoiceLine.fromJson(Json json) => InvoiceLine(
    kind: json['kind'] as String,
    amountPaise: (json['amount_paise'] as num).toInt(),
    serviceDate: json['service_date'] == null ? null : _date(json['service_date']),
  );

  /// `visit`, `fare` or `monthly_fee`.
  final String kind;
  final int amountPaise;
  final DateTime? serviceDate;
}
