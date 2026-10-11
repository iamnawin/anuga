import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import 'care_ui.dart';
import '../format.dart';
import '../labels.dart';

/// One visit: status, companion, timeline (`family_trip_timeline`) and the
/// actions the user's access level allows. The database re-checks both:
/// `issue_pickup_otp` (owner, editor, patient) and `advance_trip` (owner, editor).
class TripScreen extends StatefulWidget {
  const TripScreen({super.key, required this.api, required this.patient, required this.booking});

  final FamilyApi api;
  final FamilyPatient patient;
  final FamilyBoardRow booking;

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  late TripStatus _status = widget.booking.status;
  List<TripEvent>? _events;
  bool _busy = false;
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    try {
      final events = await widget.api.timeline(widget.booking.tripId);
      if (mounted) setState(() => _events = events);
    } catch (e) {
      if (mounted) setState(() => _error = describeError(AppLocalizations.of(context), e));
    }
  }

  bool get _canIssueCode =>
      widget.patient.accessLevel.canIssuePickupOtp &&
      (_status == TripStatus.scheduled || _status == TripStatus.companionEnRoute);

  bool get _canCancel =>
      widget.patient.accessLevel.canChangeTrips &&
      TripStateMachine.instance.canAdvance(_status, TripStatus.cancelled, TransitionActor.family);

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) _error = describeError(AppLocalizations.of(context), e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _issueCode() => _run(() async {
    final code = await widget.api.issuePickupOtp(widget.booking.tripId);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pickupCodeTitle),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              code,
              key: const Key('pickup-code'),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            Text(l10n.pickupCodeHelp),
          ],
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))],
      ),
    );
  });

  Future<void> _cancel() async {
    final reason = await showDialog<String>(context: context, builder: (_) => const _CancelDialog());
    if (reason == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    await _run(() async {
      final trip = await widget.api.cancelTrip(widget.booking.tripId, reason: reason.isEmpty ? null : reason);
      _status = trip.status;
      _info = l10n.tripCancelled;
      await _loadTimeline();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final b = widget.booking;
    final events = _events;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabBookings)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CareHeading(formatIstDateTime(b.scheduledPickupAt, locale)),
              CarePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Chip(
                      key: const Key('status'),
                      label: Text(statusLabel(l10n, _status), style: const TextStyle(fontSize: 18)),
                    ),
                    _Fact(l10n.pickupAt(formatIstTime(b.scheduledPickupAt, locale))),
                    _Fact(l10n.returnAt(formatIstTime(b.scheduledReturnAt, locale))),
                    _Fact('${l10n.centre}: ${b.centreName}'),
                    _Fact(b.companionName == null ? l10n.companionNotAssigned : l10n.companionLabel(b.companionName!)),
                    if (b.isCoveredByBackup) _Fact(l10n.backupCovering),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_canIssueCode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FilledButton.icon(
                    key: const Key('get-pickup-code'),
                    onPressed: _busy ? null : _issueCode,
                    icon: const Icon(Icons.password),
                    label: Text(l10n.getPickupCode),
                  ),
                ),
              if (_canCancel)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton(
                    key: const Key('cancel-trip'),
                    onPressed: _busy ? null : _cancel,
                    child: Text(l10n.cancelTrip),
                  ),
                ),
              if (_error != null)
                Text(
                  _error!,
                  key: const Key('error'),
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 18),
                ),
              if (_info != null) Text(_info!, key: const Key('info'), style: theme.textTheme.titleMedium),
              const Divider(height: 32),
              Text(l10n.timeline, style: theme.textTheme.titleLarge),
              if (events == null) Text(l10n.loading),
              if (events != null && events.isEmpty) Text(l10n.noEvents),
              for (final e in events ?? const <TripEvent>[])
                ListTile(
                  key: Key('event-${e.eventId}'),
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.check_circle_outline, size: 24, color: theme.colorScheme.primary),
                  title: Text(statusLabel(l10n, e.toStatus)),
                  subtitle: Text(
                    [
                      '${formatIstTime(e.createdAt, locale)} · ${actorLabel(l10n, e.actorKind)}',
                      if ((e.note ?? '').isNotEmpty) e.note!,
                    ].join('\n'),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(l10n.emergencyNumber, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirms a cancellation; returns the (possibly empty) reason, or null to keep the visit.
class _CancelDialog extends StatefulWidget {
  const _CancelDialog();

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.confirmCancel),
          const SizedBox(height: 12),
          TextField(
            key: const Key('cancel-reason'),
            controller: _reason,
            decoration: InputDecoration(labelText: l10n.cancelReason),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.keepTrip)),
        FilledButton(onPressed: () => Navigator.pop(context, _reason.text.trim()), child: Text(l10n.cancelTrip)),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(text, style: const TextStyle(fontSize: 18)),
  );
}
