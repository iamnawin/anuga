// M7 journey steps for the companion, driven by scripts/e2e-journey.sh with the
// same CompanionApi and RPC adapter as the app. Skipped unless JOURNEY_STATE,
// SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are set. Select a step with --plain-name.
import 'dart:convert';
import 'dart:io';

import 'package:companion_app/src/supabase_rpc.dart';
import 'package:companion_app/src/trip_actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _env = Platform.environment;
final _skip = ['JOURNEY_STATE', 'SUPABASE_URL', 'SUPABASE_PUBLISHABLE_KEY'].any((k) => _env[k] == null)
    ? 'run through scripts/e2e-journey.sh'
    : null;

Map<String, dynamic> readState() => jsonDecode(File(_env['JOURNEY_STATE']!).readAsStringSync()) as Map<String, dynamic>;

Future<CompanionApi> ravi() async {
  final client = SupabaseClient(
    _env['SUPABASE_URL']!,
    _env['SUPABASE_PUBLISHABLE_KEY']!,
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  await client.auth.signInWithOtp(phone: '+919000000202', shouldCreateUser: false);
  await client.auth.verifyOTP(type: OtpType.sms, phone: '+919000000202', token: '123456');
  addTearDown(client.dispose);
  return CompanionApi(supabaseRpc(client));
}

void log(String line) => stdout.writeln('    $line');

/// Takes the step the app would show as the main button, so the journey follows the UI rules.
Future<TripStatus> tapNext(CompanionApi api, String tripId, TripStatus from, {String? note}) async {
  final action = companionActions(from).first;
  expect(action.kind, TripActionKind.advance, reason: 'main button at ${from.dbValue}');
  final trip = await api.advance(tripId, action.to, note: note);
  log('${from.dbValue} -> ${trip.status.dbValue}${note == null ? '' : ' (note: $note)'}');
  return trip.status;
}

void main() {
  test('journey 3: companion sets off, picks up with the family code and hands over', skip: _skip, () async {
    final state = readState();
    final tripId = state['tripId'] as String;
    final api = await ravi();

    final trip = (await api.myTrips()).firstWhere((t) => t.tripId == tripId);
    expect(trip.detailsVisible, isTrue, reason: 'pickup is within the details window');
    expect(trip.patientName, 'Lakshmi Rao (synthetic)');
    expect(trip.mobilityNotes, isNotEmpty);
    log('pickup sheet: ${trip.patientName}, ${trip.homeAddress}; mobility: ${trip.mobilityNotes}');

    var status = await tapNext(api, tripId, trip.status);
    expect(companionActions(status).first.kind, TripActionKind.verifyPickupOtp);
    final wrong = state['otp'] == '000000' ? '111111' : '000000';
    final miss = await api.verifyPickupOtp(tripId, wrong);
    expect(miss.ok, isFalse);
    log('wrong code refused: ${miss.reason}, ${miss.attemptsLeft} attempts left');
    final hit = await api.verifyPickupOtp(tripId, state['otp'] as String);
    expect(hit.ok, isTrue);
    status = hit.status!;
    log('family code accepted: ${status.dbValue}');
    status = await tapNext(api, tripId, status);
    status = await tapNext(api, tripId, status, note: 'Handed to Nurse Station 2 (synthetic)');
    expect(status, TripStatus.handedOver);
  });

  test('journey 5: companion runs the return journey and completes with a note', skip: _skip, () async {
    final tripId = readState()['tripId'] as String;
    final api = await ravi();
    var status = (await api.myTrips()).firstWhere((t) => t.tripId == tripId).status;
    expect(status, TripStatus.handedOver);
    while (status != TripStatus.droppedHome) {
      status = await tapNext(api, tripId, status);
    }
    status = await tapNext(api, tripId, status, note: 'Session went well; patient comfortable on the way home (synthetic)');
    expect(status, TripStatus.completed);
  });
}
