import 'package:shared_dart/shared_dart.dart';

import '../l10n/generated/app_localizations.dart';

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

String actorLabel(AppLocalizations l10n, TransitionActor? actor) => switch (actor) {
  TransitionActor.companion => l10n.byCompanion,
  TransitionActor.ops => l10n.byOps,
  TransitionActor.family => l10n.byFamily,
  null => '',
};

String describeError(AppLocalizations l10n, Object error) {
  if (error is RpcException && error.isNotAllowed) return l10n.errorNotAllowed;
  if (error is RpcException && error.isStepNotPossible) return l10n.errorStepNotPossible;
  return l10n.errorGeneric;
}

String docTypeLabel(AppLocalizations l10n, String type) => switch (type) {
  'lab_report' => l10n.docTypeLabReport,
  'prescription' => l10n.docTypePrescription,
  'discharge_summary' => l10n.docTypeDischargeSummary,
  'receipt' => l10n.docTypeReceipt,
  _ => l10n.docTypeOther,
};
