import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../app.dart';
import '../payments.dart';
import '../photo_source.dart';
import '../vault_files.dart';
import 'bills_tab.dart';
import 'bookings_tab.dart';
import 'care_request_screen.dart';
import 'consent_screen.dart';
import 'family_connection.dart';
import 'family_home_tab.dart';
import 'family_ui.dart';
import 'inbox_tab.dart';
import 'records_tab.dart';
import 'trip_screen.dart';

/// The Family home mounted by the unified app. Patient-specific access levels
/// choose presentation; every existing RPC still checks database permissions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.api,
    required this.files,
    required this.photos,
    required this.payments,
    required this.onLocaleChanged,
    required this.onSignOut,
    this.now,
    this.online,
  });

  final FamilyApi api;
  final VaultFiles files;
  final PhotoSource photos;
  final Payments payments;
  final ValueChanged<Locale> onLocaleChanged;
  final Future<void> Function() onSignOut;
  final DateTime Function()? now;
  final ValueListenable<bool>? online;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<FamilyPatient>? _patients;
  FamilyPatient? _selected;
  Object? _error;
  String _tab = 'home';
  int _generation = 0;
  bool _refreshing = false;
  Route<dynamic>? _pickerRoute;
  late final ValueListenable<bool> _online = widget.online ?? familyOnline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final request = ++_generation;
    final previous = _selected?.patientId;
    final previousLevel = _selected?.accessLevel;
    final picker = _pickerRoute;
    _pickerRoute = null;
    if (picker != null) picker.navigator?.removeRoute(picker);
    setState(() {
      _refreshing = true;
      _error = null;
    });
    try {
      final patients = await widget.api.myPatients();
      if (!mounted || request != _generation) return;
      setState(() {
        _patients = patients;
        _selected = patients.where((p) => p.patientId == previous).firstOrNull ?? patients.firstOrNull;
        if (_selected?.patientId != previous || _selected?.accessLevel != previousLevel) _tab = 'home';
        _refreshing = false;
      });
    } catch (e) {
      if (mounted && request == _generation) {
        setState(() {
          _error = e;
          _refreshing = false;
          if (e is RpcException && e.isNotAllowed) {
            _selected = null;
            _patients = null;
          }
        });
      }
    }
  }

  Future<void> _choosePatient() async {
    final patients = _patients;
    if (patients == null || _refreshing) return;
    final generation = _generation;
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<FamilyPatient>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        _pickerRoute = ModalRoute.of(context);
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.fChoosePatient, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                for (final patient in patients)
                  ListTile(
                    key: Key('patient-option-${patient.patientId}'),
                    leading: FamilyAvatar(patient.fullName),
                    title: Text(patient.fullName),
                    subtitle: Text(switch (patient.accessLevel) {
                      AccessLevel.owner => l10n.fAccessOwner,
                      AccessLevel.editor => l10n.fAccessEditor,
                      AccessLevel.viewer => l10n.fAccessViewer,
                      AccessLevel.patient => l10n.fAccessPatient,
                    }),
                    trailing: patient.patientId == _selected?.patientId ? const Icon(Icons.check_circle) : null,
                    onTap: () => Navigator.pop(context, patient),
                  ),
                OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
              ],
            ),
          ),
        );
      },
    );
    _pickerRoute = null;
    if (!mounted || selected == null || generation != _generation) return;
    final current = _patients?.where((p) => p.patientId == selected.patientId).firstOrNull;
    if (current == null) return;
    setState(() {
      _selected = current;
      _tab = 'home';
    });
  }

  Future<void> _help() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _helpPage()));

  Widget _helpBody() {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.fEmergency, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        const FamilySupportUnavailable(),
        const SizedBox(height: 24),
        ListTile(
          key: const Key('family-sign-out'),
          leading: const Icon(Icons.logout),
          title: Text(l10n.signOut),
          onTap: _signOut,
        ),
        Text(l10n.syntheticBanner),
      ],
    );
  }

  Widget _helpPage() => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).fHelp)),
    body: SafeArea(child: _helpBody()),
  );

  Future<void> _signOut() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(l10n.fSignOutConfirm),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.fKeepSignedIn)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.signOut)),
        ],
      ),
    );
    if (confirmed == true && mounted) await widget.onSignOut();
  }

  Widget _more(FamilyPatient patient) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(leading: const Icon(Icons.people_outline), title: Text(l10n.fPatientsAccess), onTap: _choosePatient),
        ListTile(
          key: const Key('privacy'),
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(l10n.openConsent),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ConsentScreen(api: widget.api, patient: patient),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          trailing: LanguageMenu(onChanged: widget.onLocaleChanged),
        ),
        ListTile(leading: const Icon(Icons.help_outline), title: Text(l10n.fHelp), onTap: _help),
        ListTile(
          key: const Key('family-sign-out'),
          leading: const Icon(Icons.logout),
          title: Text(l10n.signOut),
          onTap: _signOut,
        ),
        const SizedBox(height: 24),
        Text(l10n.syntheticBanner),
      ],
    );
  }

  void _updates() {
    final l10n = AppLocalizations.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(l10n.tabInbox)),
          body: SafeArea(child: InboxTab(api: widget.api)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _selected;
    final destinations = selected == null
        ? <(String, String, IconData)>[]
        : [
            ('home', l10n.fHome, Icons.home_outlined),
            ('visits', l10n.fVisits, Icons.event_outlined),
            if (selected.accessLevel != AccessLevel.patient) ('records', l10n.tabRecords, Icons.folder_outlined),
            if (selected.accessLevel == AccessLevel.owner) ('bills', l10n.tabBills, Icons.receipt_long_outlined),
            if (selected.accessLevel != AccessLevel.patient) ('more', l10n.fMore, Icons.more_horiz),
            if (selected.accessLevel == AccessLevel.patient) ('help', l10n.fNavHelp, Icons.help_outline),
          ];
    Widget body;
    if (_error != null && selected == null) {
      body = Padding(
        padding: const EdgeInsets.all(16),
        child: FamilyFailureNotice(_error!, onRetry: _load),
      );
    } else if (_patients == null) {
      body = Center(child: Text(l10n.loading));
    } else if (selected == null) {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [FamilyStateNotice(l10n.fNoPatients), const SizedBox(height: 24), const FamilySupportUnavailable()],
      );
    } else {
      body = switch (_tab) {
        'visits' => BookingsTab(
          key: ValueKey('visits-${selected.patientId}-${selected.accessLevel.name}'),
          api: widget.api,
          patient: selected,
        ),
        'records' => RecordsTab(
          key: ValueKey('records-${selected.patientId}-${selected.accessLevel.name}'),
          api: widget.api,
          files: widget.files,
          photos: widget.photos,
          patient: selected,
        ),
        'bills' when selected.accessLevel == AccessLevel.owner => BillsTab(
          key: ValueKey('bills-${selected.patientId}-${selected.accessLevel.name}'),
          api: widget.api,
          payments: widget.payments,
          patient: selected,
        ),
        'more' => _more(selected),
        'help' => _helpBody(),
        _ => FamilyHomeTab(
          key: ValueKey('home-${selected.patientId}-${selected.accessLevel.name}'),
          api: widget.api,
          patient: selected,
          online: _online,
          now: widget.now ?? DateTime.now,
          onChoosePatient: _choosePatient,
          onVisits: () => setState(() => _tab = 'visits'),
          onHelp: _help,
          onUpdates: _updates,
          onRequest: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CareRequestScreen(api: widget.api, patient: selected),
            ),
          ),
          onVisit: (visit) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TripScreen(api: widget.api, patient: selected, booking: visit),
            ),
          ),
        ),
      };
    }
    final scaledLabel = MediaQuery.textScalerOf(context).scale(14);
    final materialScale = scaledLabel / 14 > 1.3 ? 1.3 : scaledLabel / 14;
    var destinationWidth = destinations.isEmpty ? 0.0 : MediaQuery.sizeOf(context).width / destinations.length;
    for (final destination in destinations) {
      final painter = TextPainter(
        text: TextSpan(text: destination.$2, style: Theme.of(context).navigationBarTheme.labelTextStyle?.resolve({})),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      if (painter.width + 12 > destinationWidth) destinationWidth = painter.width + 12;
      painter.dispose();
    }
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/brand/anugacare-symbol.png', height: 40, semanticLabel: l10n.appTitle),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.language,
            onSelected: (code) => widget.onLocaleChanged(Locale(code)),
            itemBuilder: (_) => [
              for (final entry in LanguageMenu.names.entries) PopupMenuItem(value: entry.key, child: Text(entry.value)),
            ],
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                LanguageMenu.names[Localizations.localeOf(context).languageCode] ?? LanguageMenu.names['en']!,
              ),
            ),
          ),
          IconButton(tooltip: l10n.fHelp, icon: const Icon(Icons.help_outline), onPressed: _help),
          if (selected == null) IconButton(tooltip: l10n.signOut, icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _online,
              builder: (_, online, _) => online ? const SizedBox.shrink() : const FamilyOfflineBanner(),
            ),
            if (_refreshing) const LinearProgressIndicator(),
            if (_error != null && selected != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: FamilyFailureNotice(_error!, onRetry: _load),
              ),
            Expanded(
              key: const Key('family-content'),
              child: IgnorePointer(ignoring: _refreshing, child: body),
            ),
          ],
        ),
      ),
      bottomNavigationBar: destinations.isEmpty
          ? null
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: destinationWidth * destinations.length,
                child: NavigationBar(
                  height: 80 + (scaledLabel - 14) * 3,
                  labelTextStyle: WidgetStatePropertyAll(
                    Theme.of(context).navigationBarTheme.labelTextStyle!
                        .resolve({})!
                        .copyWith(fontSize: scaledLabel / materialScale),
                  ),
                  selectedIndex: destinations.indexWhere((d) => d.$1 == _tab),
                  onDestinationSelected: _refreshing ? null : (i) => setState(() => _tab = destinations[i].$1),
                  destinations: [
                    for (final d in destinations)
                      NavigationDestination(key: Key('nav-${d.$1}'), icon: Icon(d.$3), label: d.$2),
                  ],
                ),
              ),
            ),
    );
  }
}
