import 'package:family_app/family_app.dart' show LanguageMenu;
import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import 'companion_help_screen.dart';
import 'companion_trip_screen.dart';
import 'companion_ui.dart';

class CompanionHomeScreen extends StatefulWidget {
  const CompanionHomeScreen({
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
  State<CompanionHomeScreen> createState() => _CompanionHomeScreenState();
}

class _CompanionHomeScreenState extends State<CompanionHomeScreen> with WidgetsBindingObserver {
  List<CompanionTrip>? _trips;
  Object? _error;
  int _request = 0;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _trips = null;
      _error = null;
    });
    try {
      final trips = await widget.api.myTrips();
      if (mounted && request == _request) setState(() => _trips = trips);
    } catch (e) {
      if (mounted && request == _request) setState(() => _error = e);
    }
  }

  Future<void> _open(CompanionTrip trip) async {
    final next =
        [...?_trips].where((t) => t.scheduledPickupAt.isAfter(trip.scheduledPickupAt) && !t.status.isTerminal).toList()
          ..sort((a, b) => a.scheduledPickupAt.compareTo(b.scheduledPickupAt));
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CompanionTripScreen(
          api: widget.api,
          trip: trip,
          clock: widget.clock,
          nextPickupAt: next.firstOrNull?.scheduledPickupAt,
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _signOut() async {
    final l = AppLocalizations.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(l.cSignOutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.signOut)),
        ],
      ),
    );
    if (yes == true && mounted) await widget.onSignOut();
  }

  @override
  Widget build(BuildContext context) => CompanionNetworkView(builder: _build);

  Widget _build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = istDay(widget.clock());
    final trips = [...?_trips]..sort((a, b) => a.scheduledPickupAt.compareTo(b.scheduledPickupAt));
    final todays = trips.where((t) => istDay(t.scheduledPickupAt) == today).toList();
    final upcoming = trips.where((t) => istDay(t.scheduledPickupAt).isAfter(today)).toList();
    final previous = trips.where((t) => istDay(t.scheduledPickupAt).isBefore(today)).toList();
    return Scaffold(
      appBar: AppBar(
        title: _tab == 0
            ? Row(
                children: [
                  Image.asset('assets/brand/anugacare-symbol.png', width: 32, height: 32, excludeFromSemantics: true),
                  const SizedBox(width: 8),
                  Flexible(child: Text(l.appTitle)),
                ],
              )
            : Text(_tab == 1 ? l.cVisits : l.cMe),
        actions: [
          IconButton(
            key: const Key('trips-refresh'),
            tooltip: l.refresh,
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.today_outlined), label: l.cToday),
          NavigationDestination(icon: const Icon(Icons.list_alt_outlined), label: l.cVisits),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: l.cMe),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (companionIsOffline(context)) const CompanionOfflineNotice(),
              if (_tab == 2) ...[
                CompanionPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CompanionPerson(name: l.cCompanion),
                      const SizedBox(height: 12),
                      Text(l.cProfileUnavailable),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.translate),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.language)),
                    LanguageMenu(onChanged: widget.onLocaleChanged),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CompanionHelpScreen())),
                  icon: const Icon(Icons.help_outline),
                  label: Text(l.cHelp),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  key: const Key('companion-sign-out'),
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: Text(l.signOut),
                ),
              ] else ...[
                Text(_tab == 0 ? l.cToday : l.upcoming, style: Theme.of(context).textTheme.headlineSmall),
                if (_tab == 0) Text(companionDate(widget.clock(), context)),
                const SizedBox(height: 16),
                if (_trips == null && _error == null) Text(l.loading, key: const Key('trips-loading')),
                if (_error != null)
                  CompanionNotice(
                    key: const Key('trips-error'),
                    message: _error is RpcException && (_error! as RpcException).isNotAllowed
                        ? l.errorNotAllowed
                        : _error is RpcException
                        ? l.errorGeneric
                        : l.cConnectionProblem,
                    onRetry: _load,
                  ),
                if (_trips != null && (_tab == 0 ? todays : upcoming).isEmpty)
                  CompanionNotice(message: _tab == 0 ? l.cNoToday : l.cNoVisits),
                if (_tab == 0) ...[
                  for (final trip in todays) _tile(context, trip),
                  if (upcoming.isNotEmpty) ...[
                    TextButton(onPressed: () => setState(() => _tab = 1), child: Text(l.cViewUpcoming)),
                    Text(companionDate(upcoming.first.scheduledPickupAt, context)),
                    _tile(context, upcoming.first),
                  ],
                ] else ...[
                  for (var i = 0; i < upcoming.length; i++) ...[
                    if (i == 0 || istDay(upcoming[i - 1].scheduledPickupAt) != istDay(upcoming[i].scheduledPickupAt))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          companionDate(upcoming[i].scheduledPickupAt, context),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    _tile(context, upcoming[i]),
                  ],
                  if (previous.isNotEmpty) ...[
                    Text(l.previous, style: Theme.of(context).textTheme.titleLarge),
                    for (final trip in previous) _tile(context, trip),
                  ],
                ],
              ],
              const SizedBox(height: 24),
              Text(l.syntheticBanner, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, CompanionTrip trip) {
    final l = AppLocalizations.of(context);
    return Semantics(
      identifier: 'companion-trip-${trip.tripId}',
      child: CompanionPanel(
        key: Key('trip-${trip.tripId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompanionPerson(name: trip.detailsVisible ? trip.patientName : null),
            const SizedBox(height: 12),
            Text(companionStatus(l, trip.status), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(trip.centreName),
            if (trip.detailsVisible && (trip.homeAddress?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 8),
                  Expanded(child: Text(trip.homeAddress!)),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(l.cDrop(companionTime(trip.scheduledPickupAt, context))),
            Text(l.cReturn(companionTime(trip.scheduledReturnAt, context))),
            const SizedBox(height: 16),
            FilledButton(
              key: Key('open-${trip.tripId}'),
              onPressed: companionIsOffline(context) ? null : () => _open(trip),
              child: Text(l.cOpenVisit),
            ),
          ],
        ),
      ),
    );
  }
}
