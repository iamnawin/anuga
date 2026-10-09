import 'package:shared_dart/shared_dart.dart';

/// What a button on the trip screen does.
enum TripActionKind { advance, verifyPickupOtp, noShow, reportIssue }

/// Note the companion writes with the step.
enum NoteRequirement { none, optional, required }

class TripAction {
  const TripAction(this.kind, this.to, {this.note = NoteRequirement.none});

  final TripActionKind kind;
  final TripStatus to;
  final NoteRequirement note;

  @override
  bool operator ==(Object other) => other is TripAction && other.kind == kind && other.to == to && other.note == note;

  @override
  int get hashCode => Object.hash(kind, to, note);

  @override
  String toString() => 'TripAction(${kind.name} -> ${to.dbValue}, note: ${note.name})';
}

/// Buttons for a companion at [status], derived from the shared state machine
/// (the same rules as `public.trip_transitions`). Order: the next journey step
/// first, then "patient not available", then "report an issue".
List<TripAction> companionActions(TripStatus status, {TripStateMachine? machine}) {
  final sm = machine ?? TripStateMachine.instance;
  const actor = TransitionActor.companion;
  final next = sm.nextStatuses(status, actor);
  final actions = <TripAction>[];

  if (sm.needsPickupOtp(status, actor)) {
    actions.add(const TripAction(TripActionKind.verifyPickupOtp, TripStatus.pickedUp));
  }
  for (final to in next) {
    switch (to) {
      case TripStatus.noShow || TripStatus.issueReported:
        break; // added last, below
      case TripStatus.handedOver:
        actions.add(TripAction(TripActionKind.advance, to, note: NoteRequirement.optional));
      case TripStatus.completed:
        actions.add(TripAction(TripActionKind.advance, to, note: NoteRequirement.required));
      default:
        actions.add(TripAction(TripActionKind.advance, to));
    }
  }
  if (next.contains(TripStatus.noShow)) {
    actions.add(const TripAction(TripActionKind.noShow, TripStatus.noShow));
  }
  if (next.contains(TripStatus.issueReported)) {
    actions.add(const TripAction(TripActionKind.reportIssue, TripStatus.issueReported, note: NoteRequirement.required));
  }
  return actions;
}
