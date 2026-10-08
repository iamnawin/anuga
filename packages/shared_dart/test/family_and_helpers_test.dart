import 'package:shared_dart/shared_dart.dart';
import 'package:test/test.dart';

import 'api_test.dart' show FakeRpc;

void main() {
  group('FamilyApi (M5 read models)', () {
    test('myPatients parses access levels and what each level may do', () async {
      final rpc = FakeRpc({
        'family_my_patients': [
          {'patient_id': 'p1', 'full_name': 'Lakshmi Rao (synthetic)', 'access_level': 'viewer', 'centre_name': 'C1'},
        ],
      });
      final patients = await FamilyApi(rpc.call).myPatients();
      expect(patients.single.accessLevel, AccessLevel.viewer);
      expect(rpc.calls.single.$1, 'family_my_patients');
      expect(rpc.calls.single.$2, isEmpty);
    });

    test('access levels mirror the SQL rules', () {
      expect(
        {for (final a in AccessLevel.values) a: a.canIssuePickupOtp},
        {AccessLevel.owner: true, AccessLevel.editor: true, AccessLevel.viewer: false, AccessLevel.patient: true},
      );
      expect(
        {for (final a in AccessLevel.values) a: a.canChangeTrips},
        {AccessLevel.owner: true, AccessLevel.editor: true, AccessLevel.viewer: false, AccessLevel.patient: false},
      );
    });

    test('timeline parses events (bigint ids arrive as numbers)', () async {
      final rpc = FakeRpc({
        'family_trip_timeline': [
          {
            'event_id': 7,
            'from_status': 'scheduled',
            'to_status': 'companion_en_route',
            'actor_kind': 'companion',
            'note': null,
            'created_at': '2026-10-09T01:00:00+00:00',
          },
        ],
      });
      final events = await FamilyApi(rpc.call).timeline('t1');
      expect(events.single.eventId, 7);
      expect(events.single.toStatus, TripStatus.companionEnRoute);
      expect(events.single.actorKind, TransitionActor.companion);
      expect(rpc.calls.single.$2, {'p_trip_id': 't1'});
    });

    test('notifications parse payload status and pass the limit only when given', () async {
      final rpc = FakeRpc({
        'my_notifications': [
          {
            'notification_id': 3,
            'trip_id': 't1',
            'template': 'trip_status_changed',
            'payload': {'trip_id': 't1', 'from_status': 'scheduled', 'to_status': 'cancelled', 'note': null},
            'created_at': '2026-10-09T01:00:00+00:00',
          },
          {
            'notification_id': 2,
            'trip_id': null,
            'template': 'companion_assigned',
            'payload': {'schedule_id': 's1'},
            'created_at': '2026-10-08T01:00:00+00:00',
          },
        ],
      });
      final api = FamilyApi(rpc.call);
      final inbox = await api.notifications();
      expect(inbox.first.toStatus, TripStatus.cancelled);
      expect(inbox.last.toStatus, isNull);
      await api.notifications(limit: 10);
      expect(rpc.calls.map((c) => c.$2), [
        <String, Object?>{},
        {'p_limit': 10},
      ]);
    });
  });

  group('FamilyApi (M8 vault and consents)', () {
    test('vault documents parse status and type; the read states its purpose', () async {
      final rpc = FakeRpc({
        'vault_list_documents': [
          {
            'id': 'd1',
            'patient_id': 'p1',
            'doc_type': 'lab_report',
            'title': 'Monthly labs (synthetic)',
            'storage_path': 'p1/d1.png',
            'uploaded_by': 'u1',
            'created_at': '2026-10-08T10:00:00+00:00',
            'status': 'uploaded',
            'content_type': 'image/png',
            'size_bytes': 2048,
          },
        ],
      });
      final docs = await FamilyApi(rpc.call).vaultDocuments('p1');
      expect(docs.single.isUploaded, isTrue);
      expect(docs.single.isImage, isTrue);
      expect(rpc.calls.single.$2, {'p_patient_id': 'p1', 'p_purpose': 'family app: records'});
    });

    test('consents parse purposes; setConsent sends the database value', () async {
      final rpc = FakeRpc({
        'family_consents': [
          {'purpose': 'ops_vault_access', 'active': false, 'granted_at': null, 'can_change': true},
        ],
        'set_consent': true,
      });
      final api = FamilyApi(rpc.call);
      expect((await api.consents('p1')).single.purpose, ConsentPurpose.opsVaultAccess);
      expect(await api.setConsent('p1', ConsentPurpose.opsVaultAccess, active: true), isTrue);
      expect(rpc.calls.last.$2, {'p_patient_id': 'p1', 'p_purpose': 'ops_vault_access', 'p_active': true});
    });
  });

  group('India helpers', () {
    test('normalizes mobile numbers to E.164', () {
      expect(normalizeIndianMobile('9000000201'), '+919000000201');
      expect(normalizeIndianMobile('+91 90000-00201'), '+919000000201');
      expect(normalizeIndianMobile('09000000201'), '+919000000201');
      expect(normalizeIndianMobile('5000000201'), isNull);
      expect(normalizeIndianMobile('12345'), isNull);
    });

    test('six-digit codes', () {
      expect(isOtpCode(' 123456 '), isTrue);
      expect(isOtpCode('12345'), isFalse);
      expect(isOtpCode('12a456'), isFalse);
    });

    test('India-time days', () {
      expect(istDay(DateTime.utc(2026, 10, 7, 19)), DateTime.utc(2026, 10, 8));
      expect(istDay(DateTime.utc(2026, 10, 7, 18)), DateTime.utc(2026, 10, 7));
      expect(toIst(DateTime.utc(2026, 10, 9, 1, 30)), DateTime.utc(2026, 10, 9, 7));
    });

    test('RpcException classifies SQLSTATEs', () {
      expect(const RpcException('42501', 'x').isNotAllowed, isTrue);
      expect(const RpcException('22023', 'x').isStepNotPossible, isTrue);
      expect(const RpcException('P0001', 'x').isNotAllowed, isFalse);
    });
  });
}
