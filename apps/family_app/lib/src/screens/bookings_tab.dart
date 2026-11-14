import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import 'care_ui.dart';
import '../format.dart';
import '../labels.dart';
import 'trip_screen.dart';
import 'care_request_screen.dart';
import 'family_connection.dart';
import 'family_ui.dart';

/// Booking board for one patient (`family_trip_board`): yesterday to two weeks ahead.
class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key, required this.api, required this.patient, this.online, this.now});

  final FamilyApi api;
  final FamilyPatient patient;
  final ValueListenable<bool>? online;
  final DateTime Function()? now;

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> with WidgetsBindingObserver {
  List<FamilyBoardRow>? _rows;
  List<CareRequest>? _requests;
  Object? _error;
  int _request = 0;
  bool _past = false;
  late DateTime _month = toIst((widget.now ?? DateTime.now)());
  late final ValueListenable<bool> _online = widget.online ?? familyOnline;

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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  void _connectionChanged() {
    if (_online.value) _load();
    setState(() {});
  }

  bool _isPast(FamilyBoardRow row) {
    if ([TripStatus.completed, TripStatus.cancelled, TripStatus.noShow].contains(row.status)) return true;
    final today = toIst((widget.now ?? DateTime.now)());
    return row.status == TripStatus.scheduled &&
        toIst(row.scheduledPickupAt).isBefore(DateTime.utc(today.year, today.month, today.day));
  }

  Future<void> _changePeriod(bool past) async {
    setState(() => _past = past);
    await _load();
  }

  Future<void> _changeMonth(int delta) async {
    setState(() => _month = DateTime.utc(_month.year, _month.month + delta));
    await _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final request = ++_request;
    setState(() {
      _rows = null;
      _requests = null;
      _error = null;
    });
    try {
      final result = await Future.wait<Object>([
        widget.api.tripBoard(
          widget.patient.patientId,
          from: _past ? DateTime.utc(_month.year, _month.month).subtract(istOffset) : null,
          to: _past
              ? DateTime.utc(
                  _month.year,
                  _month.month + 1,
                ).subtract(istOffset).subtract(const Duration(microseconds: 1))
              : null,
        ),
        widget.api.careRequests(widget.patient.patientId),
      ]);
      if (mounted && request == _request) {
        setState(() {
          _rows = result[0] as List<FamilyBoardRow>;
          _requests = result[1] as List<CareRequest>;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted && request == _request) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final rows = _rows;
    final requests = _requests ?? const <CareRequest>[];
    final requestTrips = requests.map((r) => r.tripId).whereType<String>().toSet();
    final visibleRows =
        (rows ?? const <FamilyBoardRow>[]).where((r) {
          if (requestTrips.contains(r.tripId) || _isPast(r) != _past) return false;
          final date = toIst(r.scheduledPickupAt);
          return !_past || (date.year == _month.year && date.month == _month.month);
        }).toList()..sort(
          (a, b) => _past
              ? b.scheduledPickupAt.compareTo(a.scheduledPickupAt)
              : a.scheduledPickupAt.compareTo(b.scheduledPickupAt),
        );
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: CareHeading(l10n.fVisits)),
                IconButton(
                  key: const Key('care-refresh'),
                  tooltip: l10n.refresh,
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            Text(widget.patient.fullName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  key: const Key('visits-upcoming'),
                  label: Text(l10n.fUpcoming),
                  selected: !_past,
                  onSelected: (_) => _changePeriod(false),
                ),
                ChoiceChip(
                  key: const Key('visits-past'),
                  label: Text(l10n.fPast),
                  selected: _past,
                  onSelected: (_) => _changePeriod(true),
                ),
              ],
            ),
            if (_past)
              Row(
                children: [
                  IconButton(
                    key: const Key('visits-previous-month'),
                    tooltip: l10n.fPreviousMonth,
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(child: Text(formatMonth(_month, locale), textAlign: TextAlign.center)),
                  IconButton(
                    key: const Key('visits-next-month'),
                    tooltip: l10n.fNextMonth,
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (!_online.value) const FamilyOfflineBanner(),
            if (widget.patient.accessLevel.canChangeTrips)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FilledButton.icon(
                  key: const Key('request-care'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.fRequestVisit),
                  onPressed: !_online.value
                      ? null
                      : () async {
                          final submitted = await Navigator.of(context).push<bool>(
                            MaterialPageRoute<bool>(
                              builder: (_) => CareRequestScreen(api: widget.api, patient: widget.patient),
                            ),
                          );
                          if (submitted == true) await _load();
                        },
                ),
              ),
            if (widget.patient.accessLevel == AccessLevel.viewer)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(l10n.viewOnly, key: const Key('view-only')),
              ),
            if (_error != null) FamilyFailureNotice(_error!, onRetry: _load),
            if (rows == null && _error == null) Text(l10n.loading),
            if (rows != null && visibleRows.isEmpty) Text(l10n.fNoVisits),
            if (requests.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l10n.fEarlierRequests, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
            ],
            for (final request in requests)
              Card(
                key: Key('care-request-${request.scheduleId}'),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.event_note_outlined, color: Theme.of(context).colorScheme.primary, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              formatIstDateTime(request.pickupAt, locale),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          ),
                          child: Text(
                            _requestStatus(l10n, request),
                            key: Key('care-state-${request.scheduleId}'),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${request.centreName}\n${request.packageName}'),
                      if (request.companionName != null) ...[
                        const SizedBox(height: 6),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: FamilyAvatar(request.companionName!),
                          title: Text(l10n.fYourCompanion(familyFirstName(request.companionName!))),
                        ),
                      ],
                      if (request.requestState == 'pending') ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.carePendingExplanation,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                      if (request.tripId != null && rows != null && rows.any((r) => r.tripId == request.tripId)) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                            key: Key('care-visit-${request.scheduleId}'),
                            onPressed: () async {
                              final row = rows.firstWhere((r) => r.tripId == request.tripId);
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => TripScreen(
                                    api: widget.api,
                                    patient: widget.patient,
                                    booking: row,
                                    online: _online,
                                  ),
                                ),
                              );
                              await _load();
                            },
                            child: Text(l10n.careOpenVisit),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            for (final (index, row) in visibleRows.indexed) ...[
              if (index == 0 ||
                  formatDay(toIst(row.scheduledPickupAt), locale) !=
                      formatDay(toIst(visibleRows[index - 1].scheduledPickupAt), locale))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    formatDay(toIst(row.scheduledPickupAt), locale),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              Card(
                key: Key('booking-${row.tripId}'),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: ListTile(
                  minVerticalPadding: 16,
                  leading: MediaQuery.textScalerOf(context).scale(16) > 24
                      ? null
                      : Container(
                          key: Key('visit-date-block-${row.tripId}'),
                          width: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat.E(locale).format(toIst(row.scheduledPickupAt)),
                                style: const TextStyle(fontSize: 16, height: 1.2),
                              ),
                              Text(
                                DateFormat.d(locale).format(toIst(row.scheduledPickupAt)),
                                style: const TextStyle(fontSize: 16, height: 1.2, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                  title: Text(
                    formatIstDateTime(row.scheduledPickupAt, locale),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.centreName),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Chip(label: Text(statusLabel(l10n, row.status), maxLines: 4, softWrap: true)),
                        ),
                        if (row.companionName case final name?)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: FamilyAvatar(name),
                            title: Text(l10n.fYourCompanion(familyFirstName(name))),
                          )
                        else
                          Text(l10n.companionNotAssigned),
                      ],
                    ),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right, size: 32),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            TripScreen(api: widget.api, patient: widget.patient, booking: row, online: _online),
                      ),
                    );
                    await _load();
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _requestStatus(AppLocalizations l10n, CareRequest request) => switch (request.requestState) {
  'pending' => l10n.carePending,
  'confirmed' => l10n.careConfirmed,
  'assigned' => l10n.careAssigned,
  'inactive' => l10n.careInactive,
  _ => request.tripStatus == null ? l10n.carePending : statusLabel(l10n, request.tripStatus!),
};
