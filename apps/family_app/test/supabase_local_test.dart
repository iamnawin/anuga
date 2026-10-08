// The family side of the journey against a real database: Supabase local with
// the synthetic seed, real phone-OTP sign-in, RPCs and RLS. Uses the same
// FamilyApi and RPC adapter as the app. Skipped unless SUPABASE_URL and
// SUPABASE_PUBLISHABLE_KEY are set. Commits data: run after `supabase db reset`.
import 'dart:io';

import 'package:family_app/src/supabase_rpc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _url = Platform.environment['SUPABASE_URL'];
final _key = Platform.environment['SUPABASE_PUBLISHABLE_KEY'];
final _skip = _url == null || _key == null ? 'set SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY (Supabase local)' : null;

const _otp = '123456'; // supabase/config.toml [auth.sms.test_otp], local only
const _patientId = '70000000-0000-0000-0000-000000000001';

Future<SupabaseClient> signedIn(String phone) async {
  final client = SupabaseClient(_url!, _key!, authOptions: const AuthClientOptions(autoRefreshToken: false));
  await client.auth.signInWithOtp(phone: phone, shouldCreateUser: false);
  await client.auth.verifyOTP(type: OtpType.sms, phone: phone, token: _otp);
  return client;
}

Matcher rpcError(String code) => throwsA(isA<RpcException>().having((e) => e.code, 'code', code));

void main() {
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

    // Companion sets off; owner issues the code; companion picks up with it.
    await asha.advance(visit.tripId, TripStatus.companionEnRoute);
    final code = await owner.issuePickupOtp(visit.tripId);
    expect(isOtpCode(code), isTrue);
    expect((await asha.verifyPickupOtp(visit.tripId, code)).ok, isTrue);

    // Family cannot cancel once the companion has started.
    await expectLater(owner.cancelTrip(visit.tripId), rpcError('22023'));

    final timeline = await viewer.timeline(visit.tripId);
    expect(timeline.map((e) => e.toStatus), [TripStatus.companionEnRoute, TripStatus.pickedUp]);
    expect(timeline.last.note, 'pickup OTP verified');
    expect(timeline.map((e) => e.actorKind).toSet(), {TransitionActor.companion});

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

    for (final c in [ownerClient, viewerClient, ashaClient]) {
      await c.dispose();
    }
  });
}
