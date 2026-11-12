import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../format.dart';
import '../labels.dart';

/// Explicit patient-specific edits over the existing owner-only consent RPC.
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key, required this.api, required this.patient});
  final FamilyApi api;
  final FamilyPatient patient;
  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  List<ConsentStatus>? _consents;
  final _draft = <ConsentPurpose, bool>{};
  Object? _error;
  String? _message;
  bool _loading = true;
  bool _busy = false;
  bool _requiresReload = false;

  ConsentStatus? _row(ConsentPurpose purpose) {
    for (final row in _consents ?? const <ConsentStatus>[]) {
      if (row.purpose == purpose) return row;
    }
    return null;
  }

  bool _value(ConsentPurpose purpose) => _draft[purpose] ?? _row(purpose)?.active ?? false;

  void _accept(List<ConsentStatus> rows) {
    _consents = rows;
    _draft.removeWhere((purpose, value) => _row(purpose)?.canChange != true || _row(purpose)!.active == value);
    _requiresReload = false;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });
    try {
      final rows = await widget.api.consents(widget.patient.patientId);
      if (mounted) setState(() => _accept(rows));
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _requiresReload = true;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _choose(ConsentStatus row, bool active) async {
    if (_busy || _loading || _requiresReload || !row.canChange) return;
    if (row.purpose == ConsentPurpose.opsVaultAccess && active && !row.active && !_value(ConsentPurpose.vault)) return;
    if (!active && row.active) {
      final l10n = AppLocalizations.of(context);
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          content: Text(l10n.confirmWithdraw),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.consentKeep)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.turnOff)),
          ],
        ),
      );
      if (!mounted) return;
      if (ok != true) return;
    }
    setState(() {
      _error = null;
      _message = null;
      if (active == row.active) {
        _draft.remove(row.purpose);
      } else {
        _draft[row.purpose] = active;
      }
      // Drop only an unsaved new grant, never an existing support permission.
      if (!_value(ConsentPurpose.vault) && _row(ConsentPurpose.opsVaultAccess)?.active != true) {
        _draft.remove(ConsentPurpose.opsVaultAccess);
      }
    });
  }

  Future<void> _save() async {
    if (_busy || _loading || _requiresReload || _draft.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final changes = <ConsentPurpose, bool>{
      for (final row in _consents ?? const <ConsentStatus>[])
        if (row.canChange && _draft.containsKey(row.purpose)) row.purpose: _draft[row.purpose]!,
    };
    int priority(ConsentPurpose p) => changes[p] == false
        ? (p == ConsentPurpose.opsVaultAccess
              ? 0
              : p == ConsentPurpose.vault
              ? 1
              : 2)
        : (p == ConsentPurpose.vault
              ? 3
              : p == ConsentPurpose.trips
              ? 4
              : 5);
    final ordered = changes.keys.toList()..sort((a, b) => priority(a).compareTo(priority(b)));
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    Object? saveError;
    var saved = 0;
    for (final purpose in ordered) {
      try {
        if (purpose == ConsentPurpose.opsVaultAccess &&
            changes[purpose] == true &&
            _row(ConsentPurpose.opsVaultAccess)?.active != true &&
            _row(ConsentPurpose.vault)?.active != true) {
          throw StateError('Vault grant has not been confirmed');
        }
        final actual = await widget.api.setConsent(widget.patient.patientId, purpose, active: changes[purpose]!);
        if (actual != changes[purpose]) throw StateError('Consent was not saved as requested');
        if (!mounted) return;
        setState(() {
          _consents = [
            for (final row in _consents!)
              if (row.purpose == purpose)
                ConsentStatus(purpose: purpose, active: actual, canChange: row.canChange)
              else
                row,
          ];
          _draft.remove(purpose);
        });
        saved++;
      } catch (e) {
        saveError = e;
        break;
      }
    }
    try {
      final rows = await widget.api.consents(widget.patient.patientId);
      if (!mounted) return;
      setState(() => _accept(rows));
    } catch (e) {
      if (!mounted) return;
      setState(() => _requiresReload = true);
      saveError ??= e;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = saveError;
      _message = _requiresReload
          ? l10n.consentReloadRequired
          : saveError != null
          ? (saved > 0 ? l10n.consentPartial : null)
          : l10n.consentSaved;
    });
  }

  Widget _choice(
    ConsentStatus row, {
    required String title,
    required String body,
    required IconData icon,
    String? badge,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final value = _value(row.purpose);
    final available = row.purpose != ConsentPurpose.opsVaultAccess || _value(ConsentPurpose.vault) || row.active;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badge, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value ? l10n.consentOn : l10n.consentOff,
                  key: Key('status-${row.purpose.dbValue}'),
                  style: theme.textTheme.titleMedium,
                ),
                if (row.canChange)
                  Semantics(
                    label: title,
                    child: Switch(
                      key: Key('switch-${row.purpose.dbValue}'),
                      value: value,
                      onChanged: _busy || _loading || _requiresReload || !available ? null : (v) => _choose(row, v),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(body, style: theme.textTheme.bodyLarge),
        if (row.active && row.grantedAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              formatIstDateTime(row.grantedAt!, Localizations.localeOf(context).languageCode),
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final rows = _consents;
    final canChange = rows?.any((c) => c.canChange) ?? false;
    final trips = _row(ConsentPurpose.trips);
    final vault = _row(ConsentPurpose.vault);
    final support = _row(ConsentPurpose.opsVaultAccess);
    Widget panel(String key, Widget child) => Container(
      key: Key(key),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: child,
    );
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/brand/anugacare-symbol.png', height: 40, semanticLabel: 'AnugaCare'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(header: true, child: Text(l10n.consentTitle, style: theme.textTheme.headlineSmall)),
                  const SizedBox(height: 12),
                  Text(l10n.consentIntro, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text('${l10n.patientLabel}: ${widget.patient.fullName}', key: const Key('consent-patient')),
                  const SizedBox(height: 24),
                  if (rows != null && !canChange)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(l10n.consentOwnerOnly, key: const Key('consent-owner-only')),
                    ),
                  if (_loading) ...[const LinearProgressIndicator(), const SizedBox(height: 8), Text(l10n.loading)],
                  if (trips != null)
                    panel(
                      'consent-trips',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _choice(
                            trips,
                            title: l10n.consentTripsTitle,
                            body: l10n.consentTripsBody,
                            icon: Icons.directions_car_outlined,
                            badge: l10n.consentTripsRequired,
                          ),
                          const Divider(height: 32),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline),
                              const SizedBox(width: 12),
                              Expanded(child: Text(l10n.consentTripsOff)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (vault != null)
                    panel(
                      'consent-vault',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _choice(
                            vault,
                            title: l10n.consentVaultTitle,
                            body: l10n.consentVaultBody,
                            icon: Icons.folder_shared_outlined,
                            badge: l10n.consentOptional,
                          ),
                          if (support != null)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 16),
                              child: Column(
                                key: const Key('consent-ops_vault_access'),
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Divider(height: 32),
                                  _choice(
                                    support,
                                    title: l10n.consentOpsTitle,
                                    body: l10n.consentOpsBody,
                                    icon: Icons.shield_outlined,
                                  ),
                                  if (!_value(ConsentPurpose.vault)) ...[
                                    const SizedBox(height: 12),
                                    Text(support.active ? l10n.consentSupportStillOn : l10n.consentSupportUnavailable),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (_draft.isNotEmpty) Semantics(liveRegion: true, child: Text(l10n.consentUnsaved)),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(describeError(l10n, _error!), style: TextStyle(color: theme.colorScheme.error)),
                      ),
                    ),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(_message!, key: const Key('consent-save-message')),
                      ),
                    ),
                  if (_error != null && !_loading)
                    OutlinedButton.icon(
                      key: const Key('consent-retry'),
                      onPressed: _busy ? null : _load,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.consentReload),
                    ),
                  if (canChange)
                    FilledButton(
                      key: const Key('save-consents'),
                      onPressed: _busy || _loading || _requiresReload || _draft.isEmpty ? null : _save,
                      child: Text(l10n.consentSave, textAlign: TextAlign.center),
                    ),
                  if (_busy) const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator()),
                  const SizedBox(height: 24),
                  Text(l10n.syntheticBanner, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
