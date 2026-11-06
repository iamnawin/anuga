import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../format.dart';
import '../labels.dart';
import '../trip_actions.dart';

/// One trip: the essentials the companion needs and one button per allowed step.
/// The database re-checks every step (`advance_trip`, `verify_pickup_otp`).
class TripScreen extends StatefulWidget {
  const TripScreen({super.key, required this.api, required this.trip, this.now = DateTime.now});

  final CompanionApi api;
  final CompanionTrip trip;

  /// Clock for the start window; tests pass a fixed time.
  final DateTime Function() now;

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> with WidgetsBindingObserver {
  late CompanionTrip? _trip = widget.trip;
  late TripStatus _status = widget.trip.status;
  final _otp = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _info;
  Timer? _startTimer;
  bool _loading = false;
  bool _refreshAfterAction = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleStartTimer();
  }

  void _scheduleStartTimer() {
    _startTimer?.cancel();
    // Enable "Start" when the window opens (F05), without reopening the screen.
    final opensAt = _trip?.startAllowedAt;
    if (opensAt != null && opensAt.isAfter(widget.now())) {
      _startTimer = Timer(opensAt.difference(widget.now()), () {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _startTimer?.cancel();
    _otp.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  Future<void> _reload() async {
    if (_busy) {
      _refreshAfterAction = true;
      return;
    }
    final request = ++_request;
    setState(() {
      _trip = null;
      _loading = true;
      _error = null;
      _info = null;
      _otp.clear();
    });
    try {
      // Explicit pickup range keeps an opened visit refreshable after midnight.
      // Patient fields still come only from the server's restricted projection.
      final trips = await widget.api.myTrips(
        from: widget.trip.scheduledPickupAt.subtract(const Duration(seconds: 1)),
        to: widget.trip.scheduledPickupAt.add(const Duration(seconds: 1)),
      );
      if (!mounted || request != _request) return;
      final trip = trips.where((t) => t.tripId == widget.trip.tripId).firstOrNull;
      setState(() {
        _trip = trip;
        _loading = false;
        if (trip == null) {
          _error = AppLocalizations.of(context).errorNotAllowed;
        } else {
          _status = trip.status;
        }
      });
      _scheduleStartTimer();
    } catch (error) {
      if (mounted && request == _request) {
        setState(() {
          _loading = false;
          _error = _describe(error, AppLocalizations.of(context));
        });
      }
    }
  }

  /// The database refuses a start before this time (advance_trip, F05).
  bool get _tooEarlyToStart =>
      _status == TripStatus.scheduled && (_trip?.startAllowedAt?.isAfter(widget.now()) ?? false);

  String _describe(Object error, AppLocalizations l10n) {
    if (error is RpcException && error.isNotAllowed) return l10n.errorNotAllowed;
    if (error is RpcException && error.isStepNotPossible) return l10n.errorStepNotPossible;
    return l10n.errorGeneric;
  }

  Future<void> _perform(TripAction action) async {
    if (_busy || _loading || _trip == null) return;
    final initialStatus = _status;
    final l10n = AppLocalizations.of(context);
    String? note;
    switch (action.kind) {
      case TripActionKind.noShow:
        if (!await _confirm(l10n.confirmNoShow)) return;
      case TripActionKind.reportIssue:
        note = await _askNote(l10n.issueNote, l10n.issueNoteRequired, required: true, help: l10n.issueNoteHelp);
        if (note == null) return;
      case TripActionKind.advance when action.note != NoteRequirement.none:
        final required = action.note == NoteRequirement.required;
        note = await _askNote(
          required ? l10n.postVisitNote : l10n.handoverNote,
          l10n.postVisitNoteRequired,
          required: required,
        );
        if (note == null) return;
        if (note.isEmpty) note = null;
      case TripActionKind.verifyPickupOtp:
        return _verifyOtp();
      case TripActionKind.advance:
        break;
    }
    if (!mounted || _trip == null || _loading || initialStatus != _status) return;
    await _run(() async {
      final trip = await widget.api.advance(widget.trip.tripId, action.to, note: note);
      _status = trip.status;
      _info = switch (trip.status) {
        TripStatus.completed => l10n.tripCompleted,
        TripStatus.issueReported => l10n.issueReported,
        _ => null,
      };
    });
  }

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context);
    if (!isOtpCode(_otp.text)) return setState(() => _error = l10n.invalidCode);
    await _run(() async {
      final result = await widget.api.verifyPickupOtp(widget.trip.tripId, _otp.text.trim());
      if (result.ok) {
        _status = result.status ?? TripStatus.pickedUp;
        _otp.clear();
      } else {
        _error = result.reason == 'wrong_code' ? l10n.otpWrong(result.attemptsLeft ?? 0) : l10n.otpNoValidCode;
      }
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy || _loading || _trip == null) return;
    ++_request;
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        _trip = null;
        _otp.clear();
        _error = _describe(e, AppLocalizations.of(context));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        if (_refreshAfterAction) {
          _refreshAfterAction = false;
          await _reload();
        }
      }
    }
  }

  Future<bool> _confirm(String question) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
            content: Text(question),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.confirm)),
            ],
          ),
        ) ??
        false;
  }

  /// Returns the trimmed note, '' for an empty optional note, or null when cancelled.
  Future<String?> _askNote(String label, String requiredMessage, {required bool required, String? help}) =>
      showDialog<String>(
        context: context,
        builder: (context) =>
            _NoteDialog(label: label, requiredMessage: requiredMessage, required: required, help: help),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final trip = _trip;
    final theme = Theme.of(context);
    final actions = companionActions(_status);
    final appBar = AppBar(
      title: const Text('AnugaCare', style: TextStyle(fontWeight: FontWeight.w700)),
      actions: [
        IconButton(
          key: const Key('visit-refresh'),
          tooltip: l10n.refresh,
          onPressed: _busy ? null : _reload,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );

    if (trip == null) {
      return Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _loading ? l10n.loading : _error ?? l10n.errorNotAllowed,
              key: _loading ? const Key('visit-loading') : const Key('error'),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                trip.detailsVisible ? '${l10n.patient}: ${trip.patientName ?? ''}' : l10n.patient,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(formatIstDateTime(trip.scheduledPickupAt, locale), style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              Container(
                key: const Key('status'),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      switch (_status) {
                        TripStatus.completed => Icons.check_circle_outline,
                        TripStatus.cancelled => Icons.cancel_outlined,
                        TripStatus.noShow => Icons.person_off_outlined,
                        TripStatus.issueReported => Icons.warning_amber_outlined,
                        _ => Icons.directions_car_outlined,
                      },
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(statusLabel(l10n, _status), style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(l10n.pickupAt(formatIstTime(trip.scheduledPickupAt, locale))),
                          Text(l10n.returnAt(formatIstTime(trip.scheduledReturnAt, locale))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (trip.detailsVisible) ...[
                        _Fact(l10n.homeAddress, trip.homeAddress ?? '', Icons.home_outlined),
                        const Divider(height: 32),
                      ],
                      _Fact(l10n.centre, '${trip.centreName}, ${trip.centreAddress}', Icons.local_hospital_outlined),
                      if (trip.detailsVisible) ...[
                        if ((trip.mobilityNotes ?? '').isNotEmpty) ...[
                          const Divider(height: 32),
                          _Fact(l10n.mobilityNotes, trip.mobilityNotes!, Icons.accessibility_new),
                        ],
                        if (trip.emergencyContacts.isNotEmpty) ...[
                          const Divider(height: 32),
                          _Fact(
                            l10n.familyContacts,
                            trip.emergencyContacts.map((c) => '${c.name} ${c.phone}').join(', '),
                            Icons.phone_outlined,
                          ),
                        ],
                      ] else ...[
                        const Divider(height: 32),
                        Text(l10n.detailsHidden, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(l10n.emergencyNumber, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
              ),
              const SizedBox(height: 24),
              if (_status == TripStatus.issueReported) ...[
                Text(l10n.issueWaiting, key: const Key('issue-waiting'), style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
              ],
              if (_status.isTerminal) ...[
                Text(l10n.tripClosed, style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
              ],
              for (final action in actions) ...[
                if (action.to == TripStatus.companionEnRoute && _tooEarlyToStart) ...[
                  Text(
                    l10n.startOpensAt(formatIstTime(trip.startAllowedAt!, locale)),
                    key: const Key('start-opens'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                ],
                if (action.kind == TripActionKind.verifyPickupOtp)
                  TextField(
                    key: const Key('otp'),
                    controller: _otp,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(labelText: l10n.otpLabel),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: action.kind == TripActionKind.noShow || action.kind == TripActionKind.reportIssue
                      ? OutlinedButton(
                          key: Key('action-${action.kind.name}'),
                          onPressed: _busy ? null : () => _perform(action),
                          child: Text(actionLabel(l10n, action)),
                        )
                      : FilledButton(
                          key: Key('action-${action.to.dbValue}'),
                          onPressed: _busy || (action.to == TripStatus.companionEnRoute && _tooEarlyToStart)
                              ? null
                              : () => _perform(action),
                          child: Text(actionLabel(l10n, action)),
                        ),
                ),
              ],
              if (_error != null)
                Text(
                  _error!,
                  key: const Key('error'),
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 18),
                ),
              if (_info != null) Text(_info!, key: const Key('info'), style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.text, this.icon);
  final String label;
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    ],
  );
}

/// Owns its text controller so it is disposed only after the dialog is gone.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.label, required this.requiredMessage, required this.required, this.help});

  final String label;
  final String requiredMessage;
  final bool required;
  final String? help;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(widget.label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.help != null) ...[
            Text(widget.help!, key: const Key('issue-note-help')),
            const SizedBox(height: 12),
          ],
          TextField(
            key: const Key('note'),
            controller: _controller,
            autofocus: true,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(errorText: _error),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (widget.required && text.isEmpty) return setState(() => _error = widget.requiredMessage);
            Navigator.pop(context, text);
          },
          child: Text(l10n.submit),
        ),
      ],
    );
  }
}
