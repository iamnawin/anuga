import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../format.dart';
import '../labels.dart';
import 'care_ui.dart';
import 'family_connection.dart';
import 'family_ui.dart';

/// A visit is always refreshed through guarded reads. Codes exist only after
/// issuance, and all mutations retain the existing database checks.
class TripScreen extends StatefulWidget {
  const TripScreen({super.key, required this.api, required this.patient, required this.booking, this.online});
  final FamilyApi api;
  final FamilyPatient patient;
  final FamilyBoardRow booking;
  final ValueListenable<bool>? online;

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> with WidgetsBindingObserver {
  FamilyBoardRow? _booking;
  FamilyPatient? _patient;
  List<TripEvent>? _events;
  String? _activePickupCode;
  int _request = 0;
  bool _busy = false;
  Object? _error;
  String? _info;
  Route<void>? _codeRoute;
  Route<Object?>? _cancelRoute;
  late final ValueListenable<bool> _online = widget.online ?? familyOnline;
  final _cancelAllowed = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _online.addListener(_connectionChanged);
    _load();
  }

  @override
  void dispose() {
    _request++;
    WidgetsBinding.instance.removeObserver(this);
    _online.removeListener(_connectionChanged);
    _cancelAllowed.dispose();
    super.dispose();
  }

  void _clearCode() {
    _activePickupCode = null;
    final route = _codeRoute;
    _codeRoute = null;
    if (route != null) route.navigator?.removeRoute(route);
  }

  void _closeCancel() {
    final route = _cancelRoute;
    _cancelRoute = null;
    if (route != null) route.navigator?.removeRoute(route);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _request++;
      _cancelAllowed.value = false;
      setState(() {
        _clearCode();
        _busy = false;
      });
    }
  }

  void _connectionChanged() {
    if (_online.value) {
      _load();
    } else {
      _request++;
      _cancelAllowed.value = false;
      setState(() {
        _clearCode();
        _busy = false;
      });
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    final request = ++_request;
    _cancelAllowed.value = false;
    setState(() {
      _clearCode();
      _booking = null;
      _patient = null;
      _events = null;
      _busy = false;
      _error = null;
      _info = null;
    });
    try {
      final pickup = widget.booking.scheduledPickupAt;
      final result = await Future.wait<Object>([
        widget.api.tripBoard(
          widget.patient.patientId,
          from: pickup.subtract(const Duration(seconds: 1)),
          to: pickup.add(const Duration(seconds: 1)),
        ),
        widget.api.timeline(widget.booking.tripId),
        widget.api.myPatients(),
      ]);
      final booking = (result[0] as List<FamilyBoardRow>).where((b) => b.tripId == widget.booking.tripId).firstOrNull;
      final patient = (result[2] as List<FamilyPatient>)
          .where((p) => p.patientId == widget.patient.patientId)
          .firstOrNull;
      if (booking == null || patient == null) throw const RpcException('42501', 'visit is unavailable');
      if (!mounted || request != _request) return;
      setState(() {
        _booking = booking;
        _patient = patient;
        _events = result[1] as List<TripEvent>;
      });
      _cancelAllowed.value = _canCancel && _online.value;
      if (!_canCancel) _closeCancel();
    } catch (e) {
      if (mounted && request == _request) {
        if (e is RpcException && e.isNotAllowed) _closeCancel();
        setState(() => _error = e);
      }
    }
  }

  bool get _canIssueCode =>
      _patient?.accessLevel.canIssuePickupOtp == true &&
      (_booking?.status == TripStatus.scheduled || _booking?.status == TripStatus.companionEnRoute);

  bool get _canCancel =>
      _patient?.accessLevel.canChangeTrips == true &&
      _booking != null &&
      TripStateMachine.instance.canAdvance(_booking!.status, TripStatus.cancelled, TransitionActor.family);

  Future<void> _issueCode() async {
    if (_busy || !_online.value || !_canIssueCode) return;
    final request = ++_request;
    setState(() {
      _busy = true;
      _clearCode();
      _error = null;
      _info = null;
    });
    try {
      final code = await widget.api.issuePickupOtp(widget.booking.tripId);
      if (!mounted || request != _request || !_online.value || !_canIssueCode) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _activePickupCode = code;
      });
      final route = DialogRoute<void>(
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
      _codeRoute = route;
      await Navigator.of(context).push(route);
      if (mounted && identical(_codeRoute, route)) setState(() => _codeRoute = null);
    } catch (e) {
      if (!mounted || request != _request) return;
      if (e is RpcException && e.isStepNotPossible) {
        await _load();
        if (mounted) setState(() => _error = e);
      } else {
        setState(() {
          _clearCode();
          if (e is RpcException && e.isNotAllowed) {
            _booking = null;
            _events = null;
            _patient = null;
          }
          _error = e;
        });
      }
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    if (!_canCancel || !_online.value || _busy) return;
    final route = DialogRoute<Object?>(
      context: context,
      builder: (_) => _CancelDialog(api: widget.api, tripId: widget.booking.tripId, allowed: _cancelAllowed),
    );
    _cancelRoute = route;
    final result = await Navigator.of(context).push(route);
    if (identical(_cancelRoute, route)) _cancelRoute = null;
    if (!mounted || result == null) return;
    await _load();
    if (!mounted) return;
    setState(() {
      if (result == true && _booking != null) _info = AppLocalizations.of(context).tripCancelled;
      if (result is RpcException) _error = result;
    });
  }

  Future<void> _help() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: Text(AppLocalizations.of(context).fHelp),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppLocalizations.of(context).fEmergency),
          const SizedBox(height: 16),
          const FamilySupportUnavailable(),
        ],
      ),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).close))],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final b = _booking;
    final events = _events;
    final stopped = b != null && !familyProgressStatuses.contains(b.status);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fVisitDetails),
        actions: [
          IconButton(
            key: const Key('visit-refresh'),
            tooltip: l10n.refresh,
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: _online,
          builder: (context, online, _) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!online) const FamilyOfflineBanner(),
                if (b == null && _error == null) Text(l10n.loading),
                if (b != null) ...[
                  CareHeading(formatIstDateTime(b.scheduledPickupAt, locale)),
                  CarePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Chip(
                          key: const Key('status'),
                          label: Text(
                            statusLabel(l10n, b.status),
                            style: const TextStyle(fontSize: 18),
                            softWrap: true,
                            maxLines: 4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (stopped)
                          FamilyStateNotice(statusLabel(l10n, b.status), key: const Key('visit-stopped'))
                        else
                          FamilyProgress(b.status),
                        if (b.status == TripStatus.issueReported)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(l10n.serviceIssueHelp, key: const Key('visit-issue-help')),
                          ),
                        const SizedBox(height: 12),
                        Text(l10n.pickupAt(formatIstTime(b.scheduledPickupAt, locale))),
                        Text(l10n.returnAt(formatIstTime(b.scheduledReturnAt, locale))),
                        if (events != null && events.isNotEmpty)
                          Text(
                            l10n.visitLatestUpdate(_milestoneTime(events.last.createdAt, locale)),
                            key: const Key('visit-latest-update'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CarePanel(
                    key: const Key('visit-route'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.home_outlined),
                          title: Text(l10n.fPickupHome),
                        ),
                        ExcludeSemantics(
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: SizedBox(
                              height: 24,
                              width: 48,
                              child: CustomPaint(painter: _RouteDots(theme.colorScheme.primary)),
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.apartment_outlined),
                          title: Text(b.centreName),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CarePanel(
                    child: b.companionName == null
                        ? Text(l10n.companionNotAssigned)
                        : ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: FamilyAvatar(b.companionName!),
                            title: Text(l10n.fYourCompanion(familyFirstName(b.companionName!))),
                          ),
                  ),
                  const SizedBox(height: 16),
                  if (b.status == TripStatus.completed) ...[
                    CarePanel(
                      key: const Key('visit-complete'),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline),
                          const SizedBox(width: 12),
                          Expanded(child: Text(l10n.statusCompleted, style: theme.textTheme.titleLarge)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_canIssueCode && _activePickupCode != null && _codeRoute == null) ...[
                    CarePanel(
                      key: const Key('active-pickup-code-card'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l10n.pickupCodeTitle, style: theme.textTheme.titleLarge),
                          SelectableText(
                            _activePickupCode!,
                            key: const Key('inline-pickup-code'),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 2),
                          ),
                          Text(l10n.pickupCodeHelp),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_canIssueCode) ...[
                    FilledButton.icon(
                      key: const Key('get-pickup-code'),
                      onPressed: _busy || !online ? null : _issueCode,
                      icon: const Icon(Icons.password),
                      label: Text(l10n.getPickupCode),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_canCancel) ...[
                    OutlinedButton(
                      key: const Key('cancel-trip'),
                      onPressed: _busy || !online ? null : _cancel,
                      child: Text(l10n.cancelTrip),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const FamilySupportUnavailable(),
                  OutlinedButton.icon(
                    key: const Key('visit-help'),
                    onPressed: _help,
                    icon: const Icon(Icons.help_outline),
                    label: Text(l10n.fHelp),
                  ),
                  const Divider(height: 32),
                  Text(l10n.timeline, style: theme.textTheme.titleLarge),
                  if (events != null && events.isEmpty) Text(l10n.noEvents),
                  for (final event in events ?? const <TripEvent>[])
                    ListTile(
                      key: Key('event-${event.eventId}'),
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(_eventIcon(event.toStatus), color: theme.colorScheme.onPrimaryContainer),
                      ),
                      title: Text(statusLabel(l10n, event.toStatus)),
                      subtitle: Text(
                        [
                          '${_milestoneTime(event.createdAt, locale)} \u00b7 ${actorLabel(l10n, event.actorKind)}',
                          ?_familyNote(event),
                        ].join('\n'),
                      ),
                    ),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: FamilyStateNotice(describeError(l10n, _error!), key: const Key('error'), onRetry: _load),
                  ),
                if (_info != null) Text(_info!, key: const Key('info'), style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                CareEmergencyBanner(l10n.fEmergency),
                const SizedBox(height: 16),
                Text(l10n.syntheticBanner),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _milestoneTime(DateTime value, String locale) =>
    '${DateFormat('d MMM y, HH:mm:ss', locale).format(toIst(value))} IST';

String? _familyNote(TripEvent event) {
  if (event.actorKind == TransitionActor.ops || event.toStatus == TripStatus.issueReported) return null;
  if (event.actorKind == TransitionActor.companion &&
      ![TripStatus.handedOver, TripStatus.completed].contains(event.toStatus)) {
    return null;
  }
  final note = event.note?.trim();
  return note == null || note.isEmpty ? null : note;
}

IconData _eventIcon(TripStatus status) => switch (status) {
  TripStatus.scheduled => Icons.event_outlined,
  TripStatus.companionEnRoute || TripStatus.returning => Icons.directions_walk,
  TripStatus.pickedUp => Icons.password,
  TripStatus.atCentre || TripStatus.handedOver => Icons.apartment_outlined,
  TripStatus.sessionDone => Icons.check_circle_outline,
  TripStatus.droppedHome || TripStatus.completed => Icons.home_outlined,
  _ => Icons.info_outline,
};

class _RouteDots extends CustomPainter {
  const _RouteDots(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = 3.0; y < size.height; y += 6) {
      canvas.drawCircle(Offset(size.width / 2, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(_RouteDots oldDelegate) => oldDelegate.color != color;
}

class _CancelDialog extends StatefulWidget {
  const _CancelDialog({required this.api, required this.tripId, required this.allowed});
  final FamilyApi api;
  final String tripId;
  final ValueListenable<bool> allowed;
  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _reason = TextEditingController();
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !widget.allowed.value) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final reason = _reason.text.trim();
      await widget.api.cancelTrip(widget.tripId, reason: reason.isEmpty ? null : reason);
      if (mounted && ModalRoute.of(context)?.isCurrent == true) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      if (e is RpcException && (e.isNotAllowed || e.isStepNotPossible)) {
        if (ModalRoute.of(context)?.isCurrent == true) Navigator.pop(context, e);
      } else {
        setState(() => _error = e);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: widget.allowed,
      builder: (context, allowed, _) => PopScope(
        canPop: !_busy,
        child: AlertDialog(
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.confirmCancel),
              const SizedBox(height: 12),
              TextField(
                key: const Key('cancel-reason'),
                controller: _reason,
                readOnly: _busy,
                decoration: InputDecoration(labelText: l10n.cancelReason),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(describeError(l10n, _error!)),
                OutlinedButton(
                  key: const Key('cancel-retry'),
                  onPressed: allowed && !_busy ? _submit : null,
                  child: Text(l10n.fTryAgain),
                ),
              ],
            ],
          ),
          actions: [
            FilledButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l10n.keepTrip)),
            OutlinedButton(
              key: const Key('confirm-cancel-visit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: allowed && !_busy ? _submit : null,
              child: Text(l10n.cancelTrip),
            ),
          ],
        ),
      ),
    );
  }
}
