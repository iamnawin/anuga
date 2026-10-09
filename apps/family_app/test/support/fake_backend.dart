import 'dart:typed_data';

import 'package:family_app/src/payments.dart';
import 'package:family_app/src/photo_source.dart';
import 'package:family_app/src/vault_files.dart';
import 'package:shared_dart/shared_dart.dart';

/// In-memory stand-in for the family RPCs, applying the same rules as SQL:
/// pickup code for owner/editor/patient while the trip awaits pickup; cancel
/// (advance_trip as `family`) for owner/editor, only where the state machine allows.
class FakeFamilyBackend {
  FakeFamilyBackend({this.level = AccessLevel.owner});

  AccessLevel level;
  final patients = <String, String>{'p1': 'Lakshmi Rao (synthetic)'};
  final Map<String, FakeVisit> visits = {};
  final List<Map<String, Object?>> inbox = [];
  final List<Map<String, Object?>> documents = [];
  final List<Map<String, Object?>> invoices = [];
  final Map<String, List<Map<String, Object?>>> invoiceLines = {};
  final Map<ConsentPurpose, bool> consentState = {
    ConsentPurpose.trips: true,
    ConsentPurpose.vault: true,
    ConsentPurpose.opsVaultAccess: false,
  };
  final List<String> calls = [];
  int _codes = 0;
  int _events = 0;

  FamilyApi get api => FamilyApi(rpc);

  FakeVisit addVisit(FakeVisit v) => visits[v.id] = v;

  Future<Object?> rpc(String function, Map<String, Object?> params) async {
    calls.add(function);
    switch (function) {
      case 'family_my_patients':
        return [
          for (final e in patients.entries)
            {'patient_id': e.key, 'full_name': e.value, 'access_level': level.dbValue, 'centre_name': 'Centre 1'},
        ];
      case 'family_trip_board':
        _patient(params['p_patient_id']! as String);
        return [
          for (final v in visits.values)
            if (v.patientId == params['p_patient_id']) v.toBoardRow(),
        ];
      case 'family_trip_timeline':
        return [for (final e in _visit(params['p_trip_id']! as String).events) e];
      case 'issue_pickup_otp':
        final v = _visit(params['p_trip_id']! as String);
        if (!level.canIssuePickupOtp) throw const RpcException('42501', 'not allowed');
        if (v.status != TripStatus.scheduled && v.status != TripStatus.companionEnRoute) {
          throw const RpcException('22023', 'trip is not awaiting pickup');
        }
        return v.otp = (482913 + _codes++).toString();
      case 'advance_trip':
        final v = _visit(params['p_trip_id']! as String);
        final to = TripStatus.fromDb(params['p_to_status']! as String);
        if (!level.canChangeTrips) throw const RpcException('42501', 'not allowed');
        if (!TripStateMachine.instance.canAdvance(v.status, to, TransitionActor.family)) {
          throw RpcException('22023', 'transition ${v.status.dbValue} -> ${to.dbValue} not allowed for family');
        }
        addEvent(v, to, TransitionActor.family, params['p_note'] as String?);
        return v.toTripRow();
      case 'my_notifications':
        return inbox.reversed.toList();
      case 'family_invoices':
        _patient(params['p_patient_id']! as String);
        if (!level.canChangeTrips) throw const RpcException('42501', 'not allowed');
        return [
          for (final i in invoices) {...i, 'can_pay': i['status'] == 'issued' && level == AccessLevel.owner},
        ];
      case 'family_invoice_lines':
        if (!level.canChangeTrips) throw const RpcException('42501', 'not allowed');
        return invoiceLines[params['p_invoice_id']] ?? const [];
      case 'vault_list_documents':
        _patient(params['p_patient_id']! as String);
        return documents.reversed.toList();
      case 'family_consents':
        _patient(params['p_patient_id']! as String);
        return [
          for (final e in consentState.entries)
            {
              'purpose': e.key.dbValue,
              'active': e.value,
              'granted_at': e.value ? '2026-10-01T04:30:00+00:00' : null,
              'can_change': level == AccessLevel.owner,
            },
        ];
      case 'set_consent':
        if (level != AccessLevel.owner) throw const RpcException('42501', 'only the owner can change consents');
        final purpose = ConsentPurpose.fromDb(params['p_purpose']! as String);
        return consentState[purpose] = params['p_active']! as bool;
      default:
        throw UnsupportedError('fake backend has no $function');
    }
  }

  /// Records a status change the way apply_transition() does: event + inbox row.
  void addEvent(FakeVisit v, TripStatus to, TransitionActor actor, String? note) {
    final from = v.status;
    v.status = to;
    _events++;
    v.events.add({
      'event_id': _events,
      'from_status': from.dbValue,
      'to_status': to.dbValue,
      'actor_kind': actor.dbValue,
      'note': note,
      'created_at': DateTime.utc(2026, 10, 9, 1, _events).toIso8601String(),
    });
    inbox.add({
      'notification_id': inbox.length + 1,
      'trip_id': v.id,
      'template': 'trip_status_changed',
      'payload': {'trip_id': v.id, 'from_status': from.dbValue, 'to_status': to.dbValue, 'note': note},
      'created_at': DateTime.utc(2026, 10, 9, 1, _events).toIso8601String(),
    });
  }

  void _patient(String id) {
    if (!patients.containsKey(id)) throw const RpcException('42501', 'not allowed');
  }

  FakeVisit _visit(String id) {
    final v = visits[id];
    if (v == null) throw const RpcException('42501', 'not allowed');
    _patient(v.patientId);
    return v;
  }
}

class FakeVisit {
  FakeVisit({
    required this.id,
    required this.pickupAt,
    this.patientId = 'p1',
    this.status = TripStatus.scheduled,
    this.companionName = 'Asha Companion (synthetic)',
    this.primaryName = 'Asha Companion (synthetic)',
    this.backupName = 'Ravi Companion (synthetic)',
  });

  final String id;
  final String patientId;
  final DateTime pickupAt;
  TripStatus status;
  String? companionName;
  String? primaryName;
  String? backupName;
  String? otp;
  final List<Map<String, Object?>> events = [];

  Map<String, Object?> toBoardRow() => {
    'trip_id': id,
    'scheduled_pickup_at': pickupAt.toUtc().toIso8601String(),
    'scheduled_return_at': pickupAt.add(const Duration(hours: 5)).toUtc().toIso8601String(),
    'status': status.dbValue,
    'centre_name': 'Synthetic Dialysis Centre 1',
    'companion_name': companionName,
    'primary_companion_name': primaryName,
    'backup_companion_name': backupName,
  };

  Map<String, Object?> toTripRow() => {
    'id': id,
    'patient_id': patientId,
    'status': status.dbValue,
    'scheduled_pickup_at': pickupAt.toUtc().toIso8601String(),
    'scheduled_return_at': pickupAt.add(const Duration(hours: 5)).toUtc().toIso8601String(),
    'companion_id': 'asha',
    'post_visit_note': null,
  };
}

class FakePhoneAuth implements PhoneAuth {
  FakePhoneAuth({this.roles = const {'+919000000101': 'family', '+919000000201': 'companion'}, this.code = '123456'});

  final Map<String, String> roles;
  final String code;
  String? _pending;
  String? _signedInAs;

  @override
  bool get isSignedIn => _signedInAs != null;

  @override
  Future<void> sendCode(String phone) async {
    if (!roles.containsKey(phone)) throw const PhoneAuthException('Signups not allowed for otp');
    _pending = phone;
  }

  @override
  Future<void> verifyCode(String phone, String code) async {
    if (phone != _pending || code != this.code) throw const PhoneAuthException('Token has expired or is invalid');
    _signedInAs = phone;
  }

  @override
  Future<String?> currentRole() async => roles[_signedInAs];

  @override
  Future<void> signOut() async => _signedInAs = null;
}

/// Records the vault-files calls and applies the same rules as the function +
/// database: edit access and the owner's vault consent to upload.
class FakeVaultFiles implements VaultFiles {
  FakeVaultFiles(this.backend);

  final FakeFamilyBackend backend;
  final List<String> calls = [];
  final Map<String, Uint8List> stored = {};
  int _n = 0;

  @override
  Future<({String documentId, Uri uploadUrl})> startUpload({
    required String patientId,
    required String docType,
    required String title,
    required String contentType,
    required int sizeBytes,
  }) async {
    calls.add('start:$docType:$title:$contentType:$sizeBytes');
    if (!backend.level.canChangeTrips || backend.consentState[ConsentPurpose.vault] != true) {
      throw const RpcException('42501', 'not allowed');
    }
    final id = 'doc-${++_n}';
    backend.documents.add({
      'id': id,
      'patient_id': patientId,
      'doc_type': docType,
      'title': title,
      'storage_path': '$patientId/$id.png',
      'uploaded_by': 'owner',
      'created_at': '2026-10-08T06:00:00+00:00',
      'status': 'pending_upload',
      'content_type': contentType,
      'size_bytes': sizeBytes,
    });
    return (
      documentId: id,
      uploadUrl: Uri.parse('http://127.0.0.1:54321/storage/v1/object/upload/sign/vault/$id?token=t'),
    );
  }

  @override
  Future<void> putFile(Uri uploadUrl, Uint8List bytes, String contentType) async {
    calls.add('put:${uploadUrl.path}:${bytes.length}');
    stored[uploadUrl.path] = bytes;
  }

  @override
  Future<void> confirm(String documentId) async {
    calls.add('confirm:$documentId');
    backend.documents.firstWhere((d) => d['id'] == documentId)['status'] = 'uploaded';
  }

  @override
  Future<Uri> downloadUrl(String documentId) async {
    calls.add('download:$documentId');
    return Uri.parse('http://127.0.0.1:54321/storage/v1/object/sign/vault/$documentId?token=d');
  }
}

class FakePhotoSource implements PhotoSource {
  final List<bool> requests = [];

  @override
  Future<PickedPhoto?> pick({required bool camera}) async {
    requests.add(camera);
    return PickedPhoto(bytes: Uint8List.fromList(List.filled(2048, 7)), contentType: 'image/jpeg');
  }
}

/// Applies the payment rules: only the owner, only a due bill; records calls.
class FakePayments implements Payments {
  FakePayments(this.backend, {this.providerName = 'test'});

  final FakeFamilyBackend backend;
  final String providerName;
  final List<String> calls = [];

  Map<String, Object?> _due(String invoiceId) {
    if (backend.level != AccessLevel.owner) throw const RpcException('42501', 'not allowed');
    final bill = backend.invoices.firstWhere((i) => i['invoice_id'] == invoiceId);
    if (bill['status'] != 'issued') throw const RpcException('22023', 'invoice is paid');
    return bill;
  }

  @override
  Future<String> provider(String invoiceId) async {
    calls.add('start:$invoiceId');
    _due(invoiceId);
    return providerName;
  }

  @override
  Future<void> completeTestPayment(String invoiceId) async {
    calls.add('complete-test:$invoiceId');
    _due(invoiceId)['status'] = 'paid';
  }
}
