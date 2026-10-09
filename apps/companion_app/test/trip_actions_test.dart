import 'package:companion_app/src/trip_actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

void main() {
  const advance = TripActionKind.advance;
  const issue = TripAction(TripActionKind.reportIssue, TripStatus.issueReported, note: NoteRequirement.required);
  const noShow = TripAction(TripActionKind.noShow, TripStatus.noShow);

  final expected = <TripStatus, List<TripAction>>{
    TripStatus.scheduled: [const TripAction(advance, TripStatus.companionEnRoute), noShow],
    TripStatus.companionEnRoute: [const TripAction(TripActionKind.verifyPickupOtp, TripStatus.pickedUp), noShow, issue],
    TripStatus.pickedUp: [const TripAction(advance, TripStatus.atCentre), issue],
    TripStatus.atCentre: [const TripAction(advance, TripStatus.handedOver, note: NoteRequirement.optional), issue],
    TripStatus.handedOver: [const TripAction(advance, TripStatus.sessionDone), issue],
    TripStatus.sessionDone: [const TripAction(advance, TripStatus.returning), issue],
    TripStatus.returning: [const TripAction(advance, TripStatus.droppedHome), issue],
    TripStatus.droppedHome: [const TripAction(advance, TripStatus.completed, note: NoteRequirement.required), issue],
    TripStatus.completed: [],
    TripStatus.cancelled: [],
    TripStatus.noShow: [],
    TripStatus.issueReported: [],
  };

  for (final status in TripStatus.values) {
    test('companion actions at ${status.dbValue}', () {
      expect(companionActions(status), expected[status]);
    });
  }

  test('every offered step is allowed for companions, and pickup always needs the OTP', () {
    final sm = TripStateMachine.instance;
    for (final status in TripStatus.values) {
      for (final action in companionActions(status)) {
        if (action.kind == TripActionKind.verifyPickupOtp) {
          expect(sm.needsPickupOtp(status, TransitionActor.companion), isTrue);
        } else {
          expect(sm.canAdvance(status, action.to, TransitionActor.companion), isTrue, reason: '$status -> $action');
          expect(action.to, isNot(TripStatus.pickedUp));
        }
      }
    }
  });
}
