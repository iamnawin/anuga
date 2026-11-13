import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../format.dart';
import '../labels.dart';
import 'care_ui.dart';
import 'family_ui.dart';

class FamilyHomeTab extends StatefulWidget {
  const FamilyHomeTab({
    super.key,
    required this.api,
    required this.patient,
    required this.online,
    required this.onChoosePatient,
    required this.onVisits,
    required this.onHelp,
    required this.onUpdates,
    required this.onRequest,
    required this.onVisit,
    required this.now,
  });

  final FamilyApi api;
  final FamilyPatient patient;
  final ValueListenable<bool> online;
  final VoidCallback onChoosePatient;
  final VoidCallback onVisits;
  final VoidCallback onHelp;
  final VoidCallback onUpdates;
  final Future<void> Function() onRequest;
  final Future<void> Function(FamilyBoardRow) onVisit;
  final DateTime Function() now;

  @override
  State<FamilyHomeTab> createState() => _FamilyHomeTabState();
}

class _FamilyHomeTabState extends State<FamilyHomeTab> with WidgetsBindingObserver {
  List<FamilyBoardRow>? _visits;
  List<InboxNotification>? _updates;
  Object? _error;
  String? _code;
  bool _busy = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.online.addListener(_connectionChanged);
    _load();
  }

  @override
  void dispose() {
    widget.online.removeListener(_connectionChanged);
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  void _connectionChanged() {
    if (!widget.online.value) {
      _generation++;
      setState(() {
        _code = null;
        _busy = false;
      });
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    final request = ++_generation;
    setState(() {
      _visits = null;
      _updates = null;
      _code = null;
      _busy = false;
      _error = null;
    });
    try {
      final result = await Future.wait<Object>([
        widget.api.tripBoard(widget.patient.patientId),
        widget.api.notifications(),
      ]);
      if (!mounted || request != _generation) return;
      setState(() {
        _visits = result[0] as List<FamilyBoardRow>;
        _updates = result[1] as List<InboxNotification>;
      });
    } catch (e) {
      if (mounted && request == _generation) setState(() => _error = e);
    }
  }

  Future<void> _issueCode(FamilyBoardRow visit) async {
    if (!widget.online.value || _busy) return;
    final request = ++_generation;
    setState(() {
      _busy = true;
      _code = null;
      _error = null;
    });
    try {
      final code = await widget.api.issuePickupOtp(visit.tripId);
      if (mounted && request == _generation && widget.online.value) setState(() => _code = code);
    } catch (e) {
      if (e is RpcException && e.code == '22023' && mounted && request == _generation) {
        await _load();
        return;
      }
      if (mounted && request == _generation) {
        setState(() {
          _error = e;
          if (e is RpcException && e.isNotAllowed) {
            _visits = null;
            _updates = null;
          }
        });
      }
    } finally {
      if (mounted && request == _generation) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final level = widget.patient.accessLevel;
    final patientView = level == AccessLevel.patient;
    final visits = [...?_visits]..sort((a, b) => a.scheduledPickupAt.compareTo(b.scheduledPickupAt));
    final active = visits.where(
      (v) =>
          v.status != TripStatus.completed &&
          v.status != TripStatus.cancelled &&
          v.status != TripStatus.noShow &&
          (v.status != TripStatus.scheduled || !v.scheduledReturnAt.isBefore(widget.now())),
    );
    final next = active.firstOrNull;
    final canCode =
        level.canIssuePickupOtp &&
        next != null &&
        (next.status == TripStatus.scheduled || next.status == TripStatus.companionEnRoute);
    return ValueListenableBuilder<bool>(
      valueListenable: widget.online,
      builder: (context, online, _) => RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CareHeading(
                      patientView ? l10n.fHelloPatient(familyFirstName(widget.patient.fullName)) : l10n.fHomeGreeting,
                    ),
                  ),
                  IconButton(
                    key: const Key('home-refresh'),
                    tooltip: l10n.refresh,
                    onPressed: _busy ? null : _load,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              Card(
                child: ListTile(
                  key: const Key('patient-picker'),
                  leading: FamilyAvatar(widget.patient.fullName),
                  title: Text(widget.patient.fullName),
                  subtitle: Text(widget.patient.centreName),
                  trailing: const Icon(Icons.expand_more),
                  onTap: widget.onChoosePatient,
                ),
              ),
              if (level == AccessLevel.viewer) ...[
                FamilyStateNotice(l10n.fViewerNotice, key: const Key('home-viewer-notice')),
                const SizedBox(height: 16),
              ],
              if (_error != null) ...[
                FamilyStateNotice(describeError(l10n, _error!), onRetry: _load),
                const SizedBox(height: 16),
              ],
              if (_visits == null && _error == null) Text(l10n.loading),
              if (_visits != null && next == null) FamilyStateNotice(l10n.fNoVisits),
              if (next != null) ...[
                CarePanel(
                  key: const Key('home-next-visit'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.fNextVisit, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(
                        formatIstDateTime(next.scheduledPickupAt, locale),
                        style: theme.textTheme.titleLarge?.copyWith(fontSize: patientView ? 28 : 24),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.apartment_outlined),
                        title: Text(next.centreName),
                      ),
                      Chip(label: Text(statusLabel(l10n, next.status))),
                      const SizedBox(height: 12),
                      FamilyProgress(next.status),
                      const SizedBox(height: 12),
                      if (next.companionName case final name?)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: FamilyAvatar(name),
                          title: Text(l10n.fYourCompanion(familyFirstName(name))),
                        )
                      else
                        Text(l10n.companionNotAssigned),
                      const SizedBox(height: 16),
                      FilledButton(
                        key: const Key('home-view-visit'),
                        onPressed: () async {
                          await widget.onVisit(next);
                          if (mounted) await _load();
                        },
                        child: Text(l10n.fViewVisit),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (canCode) ...[
                if (_code != null) ...[
                  CarePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.pickupCodeTitle, style: theme.textTheme.titleLarge),
                        SelectableText(
                          _code!,
                          key: const Key('home-pickup-code'),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: 4),
                        ),
                        Text(l10n.pickupCodeHelp),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton.icon(
                  key: const Key('home-get-pickup-code'),
                  onPressed: online && !_busy ? () => _issueCode(next) : null,
                  icon: const Icon(Icons.password),
                  label: Text(l10n.getPickupCode),
                ),
                const SizedBox(height: 12),
              ],
              if (patientView) ...[
                FilledButton.icon(
                  onPressed: widget.onVisits,
                  icon: const Icon(Icons.event),
                  label: Text(l10n.fMyVisits),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: widget.onHelp,
                  icon: const Icon(Icons.help_outline),
                  label: Text(l10n.fHelp),
                ),
              ] else ...[
                if (level.canChangeTrips) ...[
                  OutlinedButton.icon(
                    key: const Key('home-request-visit'),
                    onPressed: online
                        ? () async {
                            await widget.onRequest();
                            if (mounted) await _load();
                          }
                        : null,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.fRequestVisit),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(l10n.tabInbox, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                if (_updates != null && _updates!.isEmpty) Text(l10n.noUpdates),
                for (final update in (_updates ?? const <InboxNotification>[]).take(2))
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: Text(update.toStatus == null ? l10n.updateOther : statusLabel(l10n, update.toStatus!)),
                    subtitle: Text(formatIstDateTime(update.createdAt, locale)),
                    onTap: widget.onUpdates,
                  ),
                OutlinedButton(
                  key: const Key('home-all-updates'),
                  onPressed: widget.onUpdates,
                  child: Text(l10n.fSeeUpdates),
                ),
              ],
              const SizedBox(height: 24),
              Text(l10n.syntheticBanner, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
