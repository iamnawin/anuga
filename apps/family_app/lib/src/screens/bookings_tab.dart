import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import 'care_ui.dart';
import '../format.dart';
import '../labels.dart';
import 'trip_screen.dart';
import 'care_request_screen.dart';

/// Booking board for one patient (`family_trip_board`): yesterday to two weeks ahead.
class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key, required this.api, required this.patient});

  final FamilyApi api;
  final FamilyPatient patient;

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  List<FamilyBoardRow>? _rows;
  List<CareRequest>? _requests;
  Object? _error;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
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
        widget.api.tripBoard(widget.patient.patientId),
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
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: CareHeading(l10n.tabBookings)),
              IconButton(
                key: const Key('care-refresh'),
                tooltip: l10n.refresh,
                onPressed: _load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (widget.patient.accessLevel.canChangeTrips)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FilledButton.icon(
                key: const Key('request-care'),
                icon: const Icon(Icons.add),
                label: Text(l10n.careRequestTitle),
                onPressed: () async {
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
          if (_error != null)
            Text(describeError(l10n, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (rows == null && _error == null) Text(l10n.loading),
          if (rows != null && rows.isEmpty && requests.isEmpty) Text(l10n.noTrips),
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
                      Text(
                        l10n.companionLabel(request.companionName!),
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                                builder: (_) => TripScreen(api: widget.api, patient: widget.patient, booking: row),
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
          for (final row in (rows ?? const <FamilyBoardRow>[]).where((r) => !requestTrips.contains(r.tripId)))
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
                leading: Icon(Icons.calendar_month_outlined, size: 28, color: Theme.of(context).colorScheme.primary),
                title: Text(
                  formatIstDateTime(row.scheduledPickupAt, locale),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    [
                      statusLabel(l10n, row.status),
                      row.companionName == null ? l10n.companionNotAssigned : l10n.companionLabel(row.companionName!),
                      if (row.isCoveredByBackup) l10n.backupCovering,
                    ].join('\n'),
                  ),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right, size: 32),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TripScreen(api: widget.api, patient: widget.patient, booking: row),
                    ),
                  );
                  await _load();
                },
              ),
            ),
        ],
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
