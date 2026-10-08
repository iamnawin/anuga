// M7 journey steps for the family side, driven by scripts/e2e-journey.sh with
// the same FamilyApi and RPC adapter as the app. Skipped unless JOURNEY_STATE,
// SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are set. Select a step with --plain-name.
import 'dart:convert';
import 'dart:io';

import 'package:family_app/src/supabase_rpc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _env = Platform.environment;
final _skip = ['JOURNEY_STATE', 'SUPABASE_URL', 'SUPABASE_PUBLISHABLE_KEY'].any((k) => _env[k] == null)
    ? 'run through scripts/e2e-journey.sh'
    : null;
const _patientId = '70000000-0000-0000-0000-000000000001';

Map<String, dynamic> readState() => jsonDecode(File(_env['JOURNEY_STATE']!).readAsStringSync()) as Map<String, dynamic>;

void writeState(Map<String, dynamic> state) =>
    File(_env['JOURNEY_STATE']!).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(state));

Future<FamilyApi> familyAs(String phone) async {
  final client = SupabaseClient(
    _env['SUPABASE_URL']!,
    _env['SUPABASE_PUBLISHABLE_KEY']!,
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  await client.auth.signInWithOtp(phone: phone, shouldCreateUser: false);
  await client.auth.verifyOTP(type: OtpType.sms, phone: phone, token: '123456');
  addTearDown(client.dispose);
  return FamilyApi(supabaseRpc(client));
}

void log(String line) => stdout.writeln('    $line');

void main() {
  test(
    'journey 2: family sees the booking with the backup companion and issues the pickup code',
    skip: _skip,
    () async {
      final state = readState();
      final owner = await familyAs('+919000000101');
      final visit = (await owner.tripBoard(_patientId)).firstWhere((b) => b.tripId == state['tripId']);
      expect(visit.status, TripStatus.scheduled);
      expect(visit.companionName, 'Ravi Companion (synthetic)');
      expect(visit.isCoveredByBackup, isTrue);
      final inbox = await owner.notifications();
      expect(inbox.any((n) => n.tripId == state['tripId'] && n.template == 'companion_changed'), isTrue);

      final viewer = await familyAs('+919000000102');
      await expectLater(viewer.issuePickupOtp(visit.tripId), throwsA(isA<RpcException>()));
      final code = await owner.issuePickupOtp(visit.tripId);
      expect(isOtpCode(code), isTrue);
      writeState({...state, 'otp': code});
      log('family board: ${visit.companionName} (backup covering), status ${visit.status.dbValue}');
      log('viewer refused the pickup code; owner issued a code');
    },
  );

  test('journey 4: family sees the handover in the timeline and the updates inbox', skip: _skip, () async {
    final tripId = readState()['tripId'] as String;
    final viewer = await familyAs('+919000000102');
    final timeline = await viewer.timeline(tripId);
    expect(timeline.map((e) => e.toStatus), [
      TripStatus.companionEnRoute,
      TripStatus.pickedUp,
      TripStatus.atCentre,
      TripStatus.handedOver,
    ]);
    expect(timeline.last.note, 'Handed to Nurse Station 2 (synthetic)');
    final latest = (await viewer.notifications()).firstWhere((n) => n.tripId == tripId);
    expect(latest.toStatus, TripStatus.handedOver);
    for (final e in timeline) {
      log('timeline: ${e.toStatus.dbValue} by ${e.actorKind?.dbValue}${e.note == null ? '' : ' — ${e.note}'}');
    }
  });

  test('journey 6: family sees the visit completed with the post-visit note', skip: _skip, () async {
    final tripId = readState()['tripId'] as String;
    final owner = await familyAs('+919000000101');
    final visit = (await owner.tripBoard(_patientId)).firstWhere((b) => b.tripId == tripId);
    expect(visit.status, TripStatus.completed);
    final timeline = await owner.timeline(tripId);
    expect(timeline.last.toStatus, TripStatus.completed);
    expect(timeline.last.note, 'Session went well; patient comfortable on the way home (synthetic)');
    expect(timeline, hasLength(8));
    final updates = (await owner.notifications()).where((n) => n.tripId == tripId && n.toStatus != null);
    expect(updates.first.toStatus, TripStatus.completed);
    log(
      'family board: ${visit.status.dbValue}; ${timeline.length} timeline events; ${updates.length} status updates in inbox',
    );
  });
}
