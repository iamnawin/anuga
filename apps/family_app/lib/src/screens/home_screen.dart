import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import 'care_ui.dart';
import '../app.dart';
import '../labels.dart';
import '../payments.dart';
import '../photo_source.dart';
import '../vault_files.dart';
import 'bills_tab.dart';
import 'bookings_tab.dart';
import 'consent_screen.dart';
import 'inbox_tab.dart';
import 'records_tab.dart';

/// Patients the user can see (`family_my_patients`), with Bookings and Updates tabs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.api,
    required this.files,
    required this.photos,
    required this.payments,
    required this.onLocaleChanged,
    required this.onSignOut,
  });

  final FamilyApi api;
  final VaultFiles files;
  final PhotoSource photos;
  final Payments payments;
  final ValueChanged<Locale> onLocaleChanged;
  final Future<void> Function() onSignOut;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FamilyPatient>? _patients;
  FamilyPatient? _selected;
  Object? _error;
  int _tab = 0;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final request = ++_request;
    final previousId = _selected?.patientId;
    final previousLevel = _selected?.accessLevel;
    setState(() {
      _patients = null;
      _selected = null;
      _error = null;
    });
    try {
      final patients = await widget.api.myPatients();
      if (!mounted || request != _request) return;
      setState(() {
        _patients = patients;
        _selected = patients.where((p) => p.patientId == previousId).firstOrNull ?? patients.firstOrNull;
        if (_selected?.patientId != previousId || _selected?.accessLevel != previousLevel) _tab = 0;
        _error = null;
      });
    } catch (e) {
      if (mounted && request == _request) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final patients = _patients;
    final selected = _selected;
    final scaledLabel = MediaQuery.textScalerOf(context).scale(14);
    // Material caps destination labels at 1.3. Compensate so the user's full
    // scale is retained, with horizontal scrolling for longer labels.
    final materialLabelScale = scaledLabel / 14 > 1.3 ? 1.3 : scaledLabel / 14;
    final navigationLabels = [l10n.tabBookings, l10n.tabRecords, l10n.tabBills, l10n.tabInbox];
    var destinationWidth = MediaQuery.sizeOf(context).width / navigationLabels.length;
    for (final label in navigationLabels) {
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: Theme.of(context).textTheme.labelMedium
              ?.merge(Theme.of(context).navigationBarTheme.labelTextStyle?.resolve({})),
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      if (painter.width + 16 > destinationWidth) destinationWidth = painter.width + 16;
      painter.dispose();
    }

    Widget body;
    if (_error != null || patients == null || selected == null) {
      final loading = patients == null && _error == null;
      body = ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CareHeading(l10n.linkedPatientsTitle),
          CarePanel(
            child: Semantics(
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    _error != null ? Icons.info_outline : Icons.people_outline,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loading
                        ? l10n.loading
                        : _error != null
                        ? describeError(l10n, _error!)
                        : l10n.noPatients,
                  ),
                  if (loading) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ] else ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const Key('home-retry'),
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.refresh),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      body = LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.35),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: CarePanel(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.person_outline, size: 32, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.patientLabel, style: Theme.of(context).textTheme.bodySmall),
                                  Text(selected.fullName, style: Theme.of(context).textTheme.titleMedium),
                                  Text(selected.centreName, style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (patients.length > 1)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: DropdownButtonFormField<String>(
                          key: const Key('patient-picker'),
                          itemHeight: null,
                          isDense: false,
                          initialValue: selected.patientId,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l10n.patientLabel),
                          items: [
                            for (final p in patients) DropdownMenuItem(value: p.patientId, child: Text(p.fullName)),
                          ],
                          onChanged: (id) => setState(() => _selected = patients.firstWhere((p) => p.patientId == id)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: switch (_tab) {
                0 => BookingsTab(key: ValueKey(selected.patientId), api: widget.api, patient: selected),
                1 => RecordsTab(
                  key: ValueKey('records-${selected.patientId}'),
                  api: widget.api,
                  files: widget.files,
                  photos: widget.photos,
                  patient: selected,
                ),
                2 => BillsTab(
                  key: ValueKey('bills-${selected.patientId}'),
                  api: widget.api,
                  payments: widget.payments,
                  patient: selected,
                ),
                _ => InboxTab(api: widget.api),
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ANUGA',
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
        actions: [
          IconButton(
            key: const Key('home-refresh'),
            tooltip: l10n.refresh,
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: patients == null && _error == null ? null : _load,
          ),
          if (selected != null)
            IconButton(
              key: const Key('privacy'),
              tooltip: l10n.openConsent,
              icon: const Icon(Icons.privacy_tip, size: 28),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ConsentScreen(api: widget.api, patient: selected),
                ),
              ),
            ),
          LanguageMenu(onChanged: widget.onLocaleChanged),
          IconButton(tooltip: l10n.signOut, icon: const Icon(Icons.logout, size: 28), onPressed: widget.onSignOut),
        ],
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: selected == null
          ? null
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: destinationWidth * navigationLabels.length,
                child: NavigationBar(
                  height: 80 + (MediaQuery.textScalerOf(context).scale(14) - 14) * 3,
                  labelTextStyle: WidgetStatePropertyAll(
                    Theme.of(context).navigationBarTheme.labelTextStyle!
                        .resolve({})!
                        .copyWith(fontSize: scaledLabel / materialLabelScale),
                  ),
                  selectedIndex: _tab,
                  onDestinationSelected: (i) => setState(() => _tab = i),
                  destinations: [
                    NavigationDestination(icon: const Icon(Icons.event), label: l10n.tabBookings),
                    NavigationDestination(icon: const Icon(Icons.folder_shared), label: l10n.tabRecords),
                    NavigationDestination(icon: const Icon(Icons.receipt_long), label: l10n.tabBills),
                    NavigationDestination(icon: const Icon(Icons.notifications), label: l10n.tabInbox),
                  ],
                ),
              ),
            ),
    );
  }
}
