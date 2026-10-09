import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await widget.api.tripBoard(widget.patient.patientId);
      if (mounted) {
        setState(() {
          _rows = rows;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
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
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.patient.accessLevel == AccessLevel.viewer)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(l10n.viewOnly, key: const Key('view-only')),
            ),
          if (_error != null)
            Text(describeError(l10n, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (rows == null && _error == null) Text(l10n.loading),
          if (rows != null && rows.isEmpty) Text(l10n.noTrips),
          for (final row in rows ?? const <FamilyBoardRow>[])
            Card(
              key: Key('booking-${row.tripId}'),
              child: ListTile(
                minVerticalPadding: 16,
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
