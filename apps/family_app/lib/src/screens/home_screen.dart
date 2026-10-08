import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../app.dart';
import '../labels.dart';
import '../photo_source.dart';
import '../vault_files.dart';
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
    required this.onLocaleChanged,
    required this.onSignOut,
  });

  final FamilyApi api;
  final VaultFiles files;
  final PhotoSource photos;
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final patients = await widget.api.myPatients();
      if (!mounted) return;
      setState(() {
        _patients = patients;
        _selected = patients.isEmpty ? null : patients.first;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final patients = _patients;
    final selected = _selected;

    Widget body;
    if (_error != null) {
      body = Center(child: Text(describeError(l10n, _error!)));
    } else if (patients == null) {
      body = Center(child: Text(l10n.loading));
    } else if (selected == null) {
      body = Padding(
        padding: const EdgeInsets.all(24),
        child: Text(l10n.noPatients, style: const TextStyle(fontSize: 18)),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (patients.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: DropdownButtonFormField<String>(
                key: const Key('patient-picker'),
                initialValue: selected.patientId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.patientLabel),
                items: [for (final p in patients) DropdownMenuItem(value: p.patientId, child: Text(p.fullName))],
                onChanged: (id) => setState(() => _selected = patients.firstWhere((p) => p.patientId == id)),
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
              _ => InboxTab(api: widget.api),
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(selected?.fullName ?? l10n.appTitle),
        actions: [
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
          : NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              destinations: [
                NavigationDestination(icon: const Icon(Icons.event), label: l10n.tabBookings),
                NavigationDestination(icon: const Icon(Icons.folder_shared), label: l10n.tabRecords),
                NavigationDestination(icon: const Icon(Icons.notifications), label: l10n.tabInbox),
              ],
            ),
    );
  }
}
