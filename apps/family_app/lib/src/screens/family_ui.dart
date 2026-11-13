import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../labels.dart';
import 'care_ui.dart';

String familyFirstName(String name) => name.trim().split(RegExp(r'\s+')).first;

class FamilyAvatar extends StatelessWidget {
  const FamilyAvatar(this.name, {super.key});
  final String name;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 24,
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    child: Text(name.trim().isEmpty ? '' : name.trim().characters.first.toUpperCase()),
  );
}

class FamilyStateNotice extends StatelessWidget {
  const FamilyStateNotice(this.message, {super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => CarePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, style: Theme.of(context).textTheme.bodyLarge),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('family-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context).fTryAgain),
          ),
        ],
      ],
    ),
  );
}

class FamilyOfflineBanner extends StatelessWidget {
  const FamilyOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    key: const Key('family-offline'),
    padding: const EdgeInsets.all(16),
    child: FamilyStateNotice(AppLocalizations.of(context).fOffline),
  );
}

const familyProgressStatuses = [
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

class FamilyProgress extends StatelessWidget {
  const FamilyProgress(this.status, {super.key});
  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final index = familyProgressStatuses.indexOf(status);
    if (index < 0) return FamilyStateNotice(statusLabel(l10n, status));
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: l10n.fStep(index + 1, statusLabel(l10n, status)),
          child: ExcludeSemantics(
            child: Row(
              children: [
                for (var i = 0; i < familyProgressStatuses.length; i++)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsetsDirectional.only(end: 3),
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= index ? scheme.primary : scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.fStep(index + 1, statusLabel(l10n, status))),
      ],
    );
  }
}

class FamilySupportUnavailable extends StatelessWidget {
  const FamilySupportUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.support_agent), label: Text(l10n.fCallSupport)),
        const SizedBox(height: 8),
        Text(l10n.fSupportUnavailable),
      ],
    );
  }
}
