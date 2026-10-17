import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import 'care_ui.dart';
import '../format.dart';
import '../labels.dart';
import 'trip_screen.dart';

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
      _error = null;
    });
    try {
      final rows = await widget.api.tripBoard(widget.patient.patientId);
      if (mounted && request == _request) {
        setState(() {
          _rows = rows;
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
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          CareHeading(l10n.tabBookings),
          Text(l10n.bookingWindow, style: Theme.of(context).textTheme.bodySmall),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const Key('bookings-refresh'),
              onPressed: rows == null && _error == null ? null : _load,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.refresh),
            ),
          ),
          if (widget.patient.accessLevel == AccessLevel.viewer)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(l10n.viewOnly, key: const Key('view-only')),
            ),
          if (_error != null) CarePanel(child: Semantics(liveRegion: true, child: Text(describeError(l10n, _error!)))),
          if (rows == null && _error == null) Text(l10n.loading),
          if (rows != null && rows.isEmpty)
            CarePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.event_note, size: 32, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(l10n.noTripsTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l10n.noTrips),
                ],
              ),
            ),
          for (final row in rows ?? const <FamilyBoardRow>[])
            Card(
              key: Key('booking-${row.tripId}'),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: ListTile(
                minVerticalPadding: 16,
                leading: const Icon(Icons.calendar_month_outlined, size: 28),
                title: Text(formatIstDateTime(row.scheduledPickupAt, locale)),
                subtitle: Text(
                  [
                    statusLabel(l10n, row.status),
                    row.companionName == null ? l10n.companionNotAssigned : l10n.companionLabel(row.companionName!),
                    if (row.isCoveredByBackup) l10n.backupCovering,
                  ].join('\n'),
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
