import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../app.dart';
import '../format.dart';
import '../labels.dart';
import 'trip_screen.dart';

/// Today's and upcoming trips from `companion_my_trips()` (restricted fields only).
class TripsScreen extends StatefulWidget {
  const TripsScreen({
    super.key,
    required this.api,
    required this.onLocaleChanged,
    required this.onSignOut,
    this.clock = DateTime.now,
  });

  final CompanionApi api;
  final ValueChanged<Locale> onLocaleChanged;
  final Future<void> Function() onSignOut;
  final DateTime Function() clock;

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  List<CompanionTrip>? _trips;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final trips = await widget.api.myTrips();
      if (mounted) {
        setState(() {
          _trips = trips;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _open(CompanionTrip trip) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TripScreen(api: widget.api, trip: trip),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trips = _trips;
    final today = istDay(widget.clock());
    final todays = trips?.where((t) => !istDay(t.scheduledPickupAt).isAfter(today)).toList() ?? const [];
    final upcoming = trips?.where((t) => istDay(t.scheduledPickupAt).isAfter(today)).toList() ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AnugaCare', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(tooltip: l10n.refresh, icon: const Icon(Icons.refresh, size: 28), onPressed: _load),
          LanguageMenu(onChanged: widget.onLocaleChanged),
          IconButton(tooltip: l10n.signOut, icon: const Icon(Icons.logout, size: 28), onPressed: widget.onSignOut),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.tripsTitle, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (_error != null) Text(l10n.errorGeneric, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (trips == null && _error == null) Text(l10n.loading),
            if (trips != null && trips.isEmpty) Text(l10n.noTrips),
            if (todays.isNotEmpty) ...[
              _Header(l10n.today),
              for (final t in todays) _TripTile(trip: t, onTap: () => _open(t)),
            ],
            if (upcoming.isNotEmpty) ...[
              _Header(l10n.upcoming),
              for (final t in upcoming) _TripTile(trip: t, onTap: () => _open(t)),
            ],
            const SizedBox(height: 24),
            Text(l10n.syntheticBanner, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip, required this.onTap});

  final CompanionTrip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return Card(
      key: Key('trip-${trip.tripId}'),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatIstDateTime(trip.scheduledPickupAt, locale),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 32),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(label: Text(statusLabel(l10n, trip.status))),
              ),
              const SizedBox(height: 12),
              Text(trip.patientName ?? l10n.detailsHidden, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_hospital_outlined, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(trip.centreName, style: Theme.of(context).textTheme.bodyLarge)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
