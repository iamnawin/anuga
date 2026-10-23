// The family side of the journey against a real database: Supabase local with
// the synthetic seed, real phone-OTP sign-in, RPCs and RLS. Uses the same
// FamilyApi and RPC adapter as the app. Skipped unless SUPABASE_URL and
// SUPABASE_PUBLISHABLE_KEY are set. Commits data: run after `supabase db reset`.
import 'dart:io';

import 'dart:typed_data';

import 'package:family_app/src/supabase_rpc.dart';
import 'package:family_app/src/vault_files.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _url = Platform.environment['SUPABASE_URL'];
final _key = Platform.environment['SUPABASE_PUBLISHABLE_KEY'];
final _skip = _url == null || _key == null ? 'set SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY (Supabase local)' : null;

const _otp = '123456'; // supabase/config.toml [auth.sms.test_otp], local only
const _patientId = '70000000-0000-0000-0000-000000000001';

// One session per number for the whole file: Supabase Auth limits OTP requests
// per number to one every few seconds.
final _sessions = <String, Future<SupabaseClient>>{};

Future<SupabaseClient> signedIn(String phone) => _sessions[phone] ??= () async {
  final client = SupabaseClient(_url!, _key!, authOptions: const AuthClientOptions(autoRefreshToken: false));
  await client.auth.signInWithOtp(phone: phone, shouldCreateUser: false);
  await client.auth.verifyOTP(type: OtpType.sms, phone: phone, token: _otp);
  return client;
}();

Matcher rpcError(String code) => throwsA(isA<RpcException>().having((e) => e.code, 'code', code));

void main() {
  tearDownAll(() async {
    for (final session in _sessions.values) {
      await (await session).dispose();
    }
  });

  test('family journey on Supabase local', skip: _skip, () async {
    final ownerClient = await signedIn('+919000000101');
    final viewerClient = await signedIn('+919000000102');
    final ashaClient = await signedIn('+919000000201');
    final owner = FamilyApi(supabaseRpc(ownerClient));
    final viewer = FamilyApi(supabaseRpc(viewerClient));
    final asha = CompanionApi(supabaseRpc(ashaClient));

    expect((await owner.myPatients()).single.accessLevel, AccessLevel.owner);
    expect((await viewer.myPatients()).single.accessLevel, AccessLevel.viewer);

    final board = await owner.tripBoard(_patientId);
    final scheduled = board.where((b) => b.status == TripStatus.scheduled).toList();
    expect(scheduled.length, greaterThanOrEqualTo(2), reason: 'seed generates Mon/Wed/Fri trips for 14 days');
    final visit = scheduled[0];
    final toCancel = scheduled[1];
    expect(visit.companionName, 'Asha Companion (synthetic)');
    expect(visit.backupCompanionName, 'Ravi Companion (synthetic)');

    // The viewer can look but not act: the database refuses the code and the cancel.
    expect((await viewer.tripBoard(_patientId)).length, board.length);
    await expectLater(viewer.issuePickupOtp(visit.tripId), rpcError('42501'));
    await expectLater(viewer.cancelTrip(toCancel.tripId), rpcError('42501'));

    // The trip is on its way; owner issues the code; companion picks up with it.
    // The seed trip can be days ahead, past the companion start window, so ops
    // (allowed at any time) sets it on its way. scripts/e2e-journey.sh covers a
    // companion starting inside the window.
    final opsClient = await signedIn('+919000000001');
    await opsClient.rpc<dynamic>(
      'advance_trip',
      params: {'p_trip_id': visit.tripId, 'p_to_status': 'companion_en_route'},
    );
    final code = await owner.issuePickupOtp(visit.tripId);
    expect(isOtpCode(code), isTrue);
    expect((await asha.verifyPickupOtp(visit.tripId, code)).ok, isTrue);

    // Family cannot cancel once the companion has started.
    await expectLater(owner.cancelTrip(visit.tripId), rpcError('22023'));

    final timeline = await viewer.timeline(visit.tripId);
    expect(timeline.map((e) => e.toStatus), [TripStatus.companionEnRoute, TripStatus.pickedUp]);
    expect(timeline.last.note, 'pickup OTP verified');
    expect(timeline.map((e) => e.actorKind), [TransitionActor.ops, TransitionActor.companion]);

    // Owner cancels another visit with a reason; it shows on the board and in the timeline.
    final cancelled = await owner.cancelTrip(toCancel.tripId, reason: 'Hospital rescheduled (synthetic)');
    expect(cancelled.status, TripStatus.cancelled);
    expect((await owner.timeline(toCancel.tripId)).single.note, 'Hospital rescheduled (synthetic)');
    expect(
      (await viewer.tripBoard(_patientId)).firstWhere((b) => b.tripId == toCancel.tripId).status,
      TripStatus.cancelled,
    );

    // Inbox: one push row per change, newest first; the viewer gets the same updates.
    for (final api in [owner, viewer]) {
      final inbox = await api.notifications();
      final forVisit = inbox.where((n) => n.tripId == visit.tripId && n.template == 'trip_status_changed');
      expect(forVisit.map((n) => n.toStatus), [TripStatus.pickedUp, TripStatus.companionEnRoute]);
      expect(inbox.any((n) => n.tripId == toCancel.tripId && n.toStatus == TripStatus.cancelled), isTrue);
    }

    // Companions never use the family read models.
    await expectLater(FamilyApi(supabaseRpc(ashaClient)).myPatients(), rpcError('42501'));
    await expectLater(FamilyApi(supabaseRpc(ashaClient)).timeline(visit.tripId), rpcError('42501'));
  });

  test('family vault on Supabase local: consent, upload, view, refusals', skip: _skip, () async {
    final ownerClient = await signedIn('+919000000101');
    final viewerClient = await signedIn('+919000000102');
    final owner = FamilyApi(supabaseRpc(ownerClient));
    final viewer = FamilyApi(supabaseRpc(viewerClient));
    final ownerFiles = SupabaseVaultFiles(ownerClient, _url!);
    final viewerFiles = SupabaseVaultFiles(viewerClient, _url!);
    // A valid 1x1 PNG (synthetic).
    final png = Uint8List.fromList(const [
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, //
      21, 196, 137, 0, 0, 0, 13, 73, 68, 65, 84, 120, 218, 99, 252, 207, 192, 80, 15, 0, 4, 133, 1, 128, 132, //
      169, 140, 33, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
    ]);

    // Consents as the owner sees them; the viewer cannot change them.
    final consents = await owner.consents(_patientId);
    expect(consents.firstWhere((c) => c.purpose == ConsentPurpose.vault).active, isTrue);
    expect(consents.every((c) => c.canChange), isTrue);
    await expectLater(viewer.setConsent(_patientId, ConsentPurpose.vault, active: false), rpcError('42501'));

    // Owner uploads a report photo through the vault-files function.
    final start = await ownerFiles.startUpload(
      patientId: _patientId,
      docType: 'lab_report',
      title: 'Monthly labs photo (synthetic)',
      contentType: 'image/png',
      sizeBytes: png.length,
    );
    await ownerFiles.putFile(start.uploadUrl, png, 'image/png');
    await ownerFiles.confirm(start.documentId);
    final docs = await viewer.vaultDocuments(_patientId);
    expect(docs.firstWhere((d) => d.id == start.documentId).isUploaded, isTrue);

    // The viewer opens it through a short-lived signed URL; bytes match.
    final url = await viewerFiles.downloadUrl(start.documentId);
    final file = await http.get(url);
    expect(file.statusCode, 200);
    expect(file.bodyBytes, png);

    // A viewer cannot upload; with the records consent withdrawn, neither can the owner.
    await expectLater(
      viewerFiles.startUpload(
        patientId: _patientId,
        docType: 'other',
        title: 'x',
        contentType: 'image/png',
        sizeBytes: 10,
      ),
      rpcError('42501'),
    );
    expect(await owner.setConsent(_patientId, ConsentPurpose.vault, active: false), isFalse);
    try {
      await expectLater(
        ownerFiles.startUpload(
          patientId: _patientId,
          docType: 'other',
          title: 'x',
          contentType: 'image/png',
          sizeBytes: 10,
        ),
        rpcError('42501'),
      );
    } finally {
      expect(await owner.setConsent(_patientId, ConsentPurpose.vault, active: true), isTrue);
    }
  });
}
