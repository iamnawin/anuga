import 'package:shared_dart/shared_dart.dart';

import '../l10n/generated/app_localizations.dart';
import 'trip_actions.dart';

String statusLabel(AppLocalizations l10n, TripStatus status) => switch (status) {
  TripStatus.scheduled => l10n.statusScheduled,
  TripStatus.companionEnRoute => l10n.statusCompanionEnRoute,
  TripStatus.pickedUp => l10n.statusPickedUp,
  TripStatus.atCentre => l10n.statusAtCentre,
  TripStatus.handedOver => l10n.statusHandedOver,
  TripStatus.sessionDone => l10n.statusSessionDone,
  TripStatus.returning => l10n.statusReturning,
  TripStatus.droppedHome => l10n.statusDroppedHome,
  TripStatus.completed => l10n.statusCompleted,
  TripStatus.cancelled => l10n.statusCancelled,
  TripStatus.noShow => l10n.statusNoShow,
  TripStatus.issueReported => l10n.statusIssueReported,
};

String actionLabel(AppLocalizations l10n, TripAction action) => switch (action.kind) {
  TripActionKind.verifyPickupOtp => l10n.actionVerifyOtp,
  TripActionKind.noShow => l10n.actionNoShow,
  TripActionKind.reportIssue => l10n.actionReportIssue,
  TripActionKind.advance => switch (action.to) {
    TripStatus.companionEnRoute => l10n.actionStart,
    TripStatus.atCentre => l10n.actionAtCentre,
    TripStatus.handedOver => l10n.actionHandedOver,
    TripStatus.sessionDone => l10n.actionSessionDone,
    TripStatus.returning => l10n.actionReturning,
    TripStatus.droppedHome => l10n.actionDroppedHome,
    TripStatus.completed => l10n.actionComplete,
    _ => statusLabel(l10n, action.to),
  },
};
