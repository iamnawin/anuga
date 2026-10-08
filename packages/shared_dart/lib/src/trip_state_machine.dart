import 'trip_status.dart';

/// One allowed status change. Mirrors a row of `public.trip_transitions`.
class TripTransition {
  const TripTransition(this.from, this.to, this.actor, {this.requiresOtp = false});

  final TripStatus from;
  final TripStatus to;
  final TransitionActor actor;

  /// Only reachable through `verify_pickup_otp`, never `advance_trip`.
  final bool requiresOtp;

  @override
  bool operator ==(Object other) =>
      other is TripTransition &&
      other.from == from &&
      other.to == to &&
      other.actor == actor &&
      other.requiresOtp == requiresOtp;

  @override
  int get hashCode => Object.hash(from, to, actor, requiresOtp);

  @override
  String toString() => '${from.dbValue} -> ${to.dbValue} (${actor.dbValue}${requiresOtp ? ', otp' : ''})';
}

/// Client-side copy of the database state machine, used to decide which
/// buttons to show. The database remains the authority: `advance_trip`
/// rejects anything not in `public.trip_transitions`.
///
/// Built from the same rules as supabase/migrations/20261008000300_trip_workflow.sql.
/// test/trip_state_machine_test.dart checks it against test/fixtures/trip_contract.json.
class TripStateMachine {
  TripStateMachine._(this.transitions);

  static final TripStateMachine instance = TripStateMachine._(List.unmodifiable(_buildTransitions()));

  final List<TripTransition> transitions;

  /// Statuses [actor] may move a trip to from [from], excluding OTP-gated steps.
  List<TripStatus> nextStatuses(TripStatus from, TransitionActor actor) => [
    for (final t in transitions)
      if (t.from == from && t.actor == actor && !t.requiresOtp) t.to,
  ];

  /// True when [actor] must verify the pickup OTP to leave [from].
  bool needsPickupOtp(TripStatus from, TransitionActor actor) =>
      transitions.any((t) => t.from == from && t.actor == actor && t.requiresOtp);

  bool canAdvance(TripStatus from, TripStatus to, TransitionActor actor) => nextStatuses(from, actor).contains(to);
}

const _forwardJourney = [
  TripStatus.scheduled,
  TripStatus.companionEnRoute,
  TripStatus.pickedUp,
  TripStatus.atCentre,
  TripStatus.handedOver,
  TripStatus.sessionDone,
  TripStatus.returning,
  TripStatus.droppedHome,
  TripStatus.completed,
];

const _activeStates = [
  TripStatus.companionEnRoute,
  TripStatus.pickedUp,
  TripStatus.atCentre,
  TripStatus.handedOver,
  TripStatus.sessionDone,
  TripStatus.returning,
  TripStatus.droppedHome,
];

List<TripTransition> _buildTransitions() {
  const companion = TransitionActor.companion;
  const ops = TransitionActor.ops;

  final companionRules = <TripTransition>[
    for (var i = 0; i < _forwardJourney.length - 1; i++)
      TripTransition(
        _forwardJourney[i],
        _forwardJourney[i + 1],
        companion,
        requiresOtp: _forwardJourney[i + 1] == TripStatus.pickedUp,
      ),
    const TripTransition(TripStatus.scheduled, TripStatus.noShow, companion),
    const TripTransition(TripStatus.companionEnRoute, TripStatus.noShow, companion),
    for (final s in _activeStates) TripTransition(s, TripStatus.issueReported, companion),
  ];

  return [
    ...companionRules,
    const TripTransition(TripStatus.scheduled, TripStatus.cancelled, TransitionActor.family),
    // Ops: every non-OTP companion step, cancel any non-terminal trip, resolve issues.
    for (final t in companionRules)
      if (!t.requiresOtp) TripTransition(t.from, t.to, ops),
    for (final s in [TripStatus.scheduled, ..._activeStates, TripStatus.issueReported])
      TripTransition(s, TripStatus.cancelled, ops),
    for (final s in [..._activeStates, TripStatus.completed]) TripTransition(TripStatus.issueReported, s, ops),
  ];
}
