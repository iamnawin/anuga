import 'dart:convert';
import 'dart:io';

import 'package:shared_dart/shared_dart.dart';
import 'package:test/test.dart';

/// test/fixtures/trip_contract.json is exported from the migrations by
/// `pnpm contract:export`, and `pnpm db:test` fails if it drifts from SQL.
/// These tests make the Dart side agree with the same file.
Map<String, dynamic> _loadContract() =>
    jsonDecode(File('test/fixtures/trip_contract.json').readAsStringSync()) as Map<String, dynamic>;

void main() {
  final machine = TripStateMachine.instance;
  final contract = _loadContract();

  group('agreement with the SQL contract', () {
    test('trip statuses match public.trip_status (values and order)', () {
      expect([for (final s in TripStatus.values) s.dbValue], contract['trip_status']);
    });

    test('actors match public.transition_actor', () {
      expect([for (final a in TransitionActor.values) a.dbValue], contract['transition_actor']);
    });

    test('transitions match public.trip_transitions exactly', () {
      final sql = {
        for (final t in contract['transitions'] as List<dynamic>)
          TripTransition(
            TripStatus.fromDb(t['from'] as String),
            TripStatus.fromDb(t['to'] as String),
            TransitionActor.fromDb(t['actor'] as String),
            requiresOtp: t['requires_otp'] as bool,
          ),
      };
      final dart = machine.transitions.toSet();
      expect(dart.length, machine.transitions.length, reason: 'Dart rules produce duplicates');
      expect(dart.difference(sql), isEmpty, reason: 'in Dart but not in SQL');
      expect(sql.difference(dart), isEmpty, reason: 'in SQL but not in Dart');
    });
  });

  group('state machine behaviour', () {
    test('companion walks the full journey; pickup needs the OTP', () {
      const c = TransitionActor.companion;
      expect(machine.canAdvance(TripStatus.scheduled, TripStatus.companionEnRoute, c), isTrue);
      expect(machine.canAdvance(TripStatus.companionEnRoute, TripStatus.pickedUp, c), isFalse);
      expect(machine.needsPickupOtp(TripStatus.companionEnRoute, c), isTrue);
      for (final (from, to) in [
        (TripStatus.pickedUp, TripStatus.atCentre),
        (TripStatus.atCentre, TripStatus.handedOver),
        (TripStatus.handedOver, TripStatus.sessionDone),
        (TripStatus.sessionDone, TripStatus.returning),
        (TripStatus.returning, TripStatus.droppedHome),
        (TripStatus.droppedHome, TripStatus.completed),
      ]) {
        expect(machine.canAdvance(from, to, c), isTrue, reason: '$from -> $to');
      }
    });

    test('ops can never skip the pickup OTP from en route', () {
      expect(machine.canAdvance(TripStatus.companionEnRoute, TripStatus.pickedUp, TransitionActor.ops), isFalse);
      expect(machine.needsPickupOtp(TripStatus.companionEnRoute, TransitionActor.ops), isFalse);
    });

    test('family may only cancel a scheduled trip', () {
      const f = TransitionActor.family;
      expect(machine.nextStatuses(TripStatus.scheduled, f), [TripStatus.cancelled]);
      for (final s in TripStatus.values.where((s) => s != TripStatus.scheduled)) {
        expect(machine.nextStatuses(s, f), isEmpty, reason: '$s');
      }
    });

    test('terminal statuses have no exits for anyone', () {
      for (final s in TripStatus.values.where((s) => s.isTerminal)) {
        for (final a in TransitionActor.values) {
          expect(machine.nextStatuses(s, a), isEmpty, reason: '$s by $a');
        }
      }
    });

    test('only ops resolve an issue', () {
      expect(machine.nextStatuses(TripStatus.issueReported, TransitionActor.companion), isEmpty);
      expect(
        machine.nextStatuses(TripStatus.issueReported, TransitionActor.ops),
        containsAll([TripStatus.companionEnRoute, TripStatus.completed, TripStatus.cancelled]),
      );
    });

    test('unknown database values are rejected', () {
      expect(() => TripStatus.fromDb('teleported'), throwsArgumentError);
    });
  });
}
