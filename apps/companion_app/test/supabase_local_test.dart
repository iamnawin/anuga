// The companion journey against a real database: Supabase local with the
// synthetic seed, real phone-OTP sign-in, real RPCs and RLS. Uses the same
// CompanionApi and RPC adapter as the app (no widgets: flutter_test blocks HTTP
// inside testWidgets). Skipped unless SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY
// are set in the environment. Commits data: run after `supabase db reset`.
import 'dart:io';

import 'package:companion_app/src/supabase_rpc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _url = Platform.environment['SUPABASE_URL'];
final _key = Platform.environment['SUPABASE_PUBLISHABLE_KEY'];
final _skip = _url == null || _key == null ? 'set SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY (Supabase local)' : null;

const _otp = '123456'; // supabase/config.toml [auth.sms.test_otp], local only
const _ops = '+919000000001';
const _ravi = '+919000000202';
const _raviId = '30000000-0000-0000-0000-000000000002';
const _owner = '+919000000101';
const _viewer = '+919000000102';

Future<SupabaseClient> signedIn(String phone) async {
  final client = SupabaseClient(_url!, _key!, authOptions: const AuthClientOptions(autoRefreshToken: false));
  await client.auth.signInWithOtp(phone: phone, shouldCreateUser: false);
  await client.auth.verifyOTP(type: OtpType.sms, phone: phone, token: _otp);
  return client;
}

void main() {
  test('companion runs a full trip on Supabase local', skip: _skip, () async {
    final ops = await signedIn(_ops);
    final companion = await signedIn(_ravi);
    final family = await signedIn(_owner);
    final viewer = await signedIn(_viewer);
    final api = CompanionApi(supabaseRpc(companion));
    final familyApi = FamilyApi(supabaseRpc(family));

    // Ops covers the next scheduled trip with the backup companion (Ravi).
    final now = DateTime.now().toUtc();
    final board = await ops.rpc<List<dynamic>>(
      'ops_trip_board',
      params: {
        'p_from': now.toIso8601String(),
        'p_to': now.add(const Duration(days: 14)).toIso8601String(),
        'p_statuses': ['scheduled'],
      },
    );
    final tripId = (board.first as Map<String, dynamic>)['trip_id'] as String;
    await OpsApi(supabaseRpc(ops)).assignTripCompanion(tripId, _raviId);

    var trips = await api.myTrips();
    final trip = trips.firstWhere((t) => t.tripId == tripId);
    expect(trip.status, TripStatus.scheduled);

    // Companion projection never carries date of birth or vault data.
    final raw = await companion.rpc<List<dynamic>>('companion_my_trips');
    final row = raw.cast<Map<String, dynamic>>().firstWhere((r) => r['trip_id'] == trip.tripId);
    expect(row.keys, isNot(contains('date_of_birth')));
    expect(row.keys, isNot(contains('patient_id')));

    // The seed trip can be days ahead, past the companion start window, so ops
    // (allowed at any time) sets it on its way. scripts/e2e-journey.sh covers a
    // companion starting inside the window.
    await ops.rpc<dynamic>('advance_trip', params: {'p_trip_id': trip.tripId, 'p_to_status': 'companion_en_route'});
    expect((await api.myTrips()).firstWhere((t) => t.tripId == trip.tripId).status, TripStatus.companionEnRoute);

    // Pickup is impossible through advance_trip, even for the assigned companion.
    await expectLater(
      api.advance(trip.tripId, TripStatus.pickedUp),
      throwsA(isA<RpcException>().having((e) => e.code, 'code', '22023')),
    );
    // A viewer-level family member cannot issue the code; the owner can.
    await expectLater(
      FamilyApi(supabaseRpc(viewer)).issuePickupOtp(trip.tripId),
      throwsA(isA<RpcException>().having((e) => e.isNotAllowed, 'not allowed', isTrue)),
    );
    final code = await familyApi.issuePickupOtp(trip.tripId);
    final wrong = code == '000000' ? '111111' : '000000';
    final miss = await api.verifyPickupOtp(trip.tripId, wrong);
    expect(miss.ok, isFalse);
    expect(miss.reason, 'wrong_code');
    final hit = await api.verifyPickupOtp(trip.tripId, code);
    expect(hit.ok, isTrue);
    expect(hit.status, TripStatus.pickedUp);

    for (final step in [
      TripStatus.atCentre,
      TripStatus.handedOver,
      TripStatus.sessionDone,
      TripStatus.returning,
      TripStatus.droppedHome,
    ]) {
      expect((await api.advance(trip.tripId, step)).status, step);
    }
    final done = await api.advance(trip.tripId, TripStatus.completed, note: 'Synthetic post-visit note');
    expect(done.status, TripStatus.completed);
    expect(done.postVisitNote, 'Synthetic post-visit note');

    // Family sees the completed trip and got a status notification for every step.
    final familyBoard = await familyApi.tripBoard('70000000-0000-0000-0000-000000000001');
    expect(familyBoard.firstWhere((b) => b.tripId == trip.tripId).status, TripStatus.completed);
    final notices = await family
        .from('notifications')
        .select('payload')
        .eq('trip_id', trip.tripId)
        .eq('template', 'trip_status_changed')
        .eq('channel', 'push');
    expect(notices.map((n) => (n['payload'] as Map<String, dynamic>)['to_status']), [
      'companion_en_route',
      'picked_up',
      'at_centre',
      'handed_over',
      'session_done',
      'returning',
      'dropped_home',
      'completed',
    ]);

    trips = await api.myTrips();
    expect(trips.firstWhere((t) => t.tripId == trip.tripId).status, TripStatus.completed);
    for (final c in [ops, companion, family, viewer]) {
      await c.dispose();
    }
  });
}
