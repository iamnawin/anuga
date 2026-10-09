import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../format.dart';
import '../labels.dart';

/// One plain-language choice per purpose (DPDP: specific, separate, as easy to
/// withdraw as to give). Only the owner can change them; everyone with access
/// can see them. Changes go through `set_consent` and are audited.
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key, required this.api, required this.patient});

  final FamilyApi api;
  final FamilyPatient patient;

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  List<ConsentStatus>? _consents;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final consents = await widget.api.consents(widget.patient.patientId);
      if (mounted) setState(() => _consents = consents);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _set(ConsentPurpose purpose, bool active) async {
    final l10n = AppLocalizations.of(context);
    if (!active) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(l10n.confirmWithdraw),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.keepTrip)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.turnOff)),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _busy = true);
    try {
      await widget.api.setConsent(widget.patient.patientId, purpose, active: active);
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  ({String title, String body}) _text(AppLocalizations l10n, ConsentPurpose p) => switch (p) {
    ConsentPurpose.trips => (title: l10n.consentTripsTitle, body: l10n.consentTripsBody),
    ConsentPurpose.vault => (title: l10n.consentVaultTitle, body: l10n.consentVaultBody),
    ConsentPurpose.opsVaultAccess => (title: l10n.consentOpsTitle, body: l10n.consentOpsBody),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final consents = _consents;
    final canChange = consents?.any((c) => c.canChange) ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.consentTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.consentIntro, style: const TextStyle(fontSize: 18)),
            if (consents != null && !canChange)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.consentOwnerOnly, key: const Key('consent-owner-only')),
              ),
            if (_error != null)
              Text(describeError(l10n, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (consents == null && _error == null) Text(l10n.loading),
            for (final c in consents ?? const <ConsentStatus>[])
              Card(
                key: Key('consent-${c.purpose.dbValue}'),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(_text(l10n, c.purpose).title, style: Theme.of(context).textTheme.titleMedium),
                          ),
                          if (c.canChange)
                            Switch(
                              key: Key('switch-${c.purpose.dbValue}'),
                              value: c.active,
                              onChanged: _busy ? null : (v) => _set(c.purpose, v),
                            )
                          else
                            Text(c.active ? l10n.consentOn : l10n.consentOff, key: Key('status-${c.purpose.dbValue}')),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(_text(l10n, c.purpose).body),
                      if (c.active && c.grantedAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            formatIstDateTime(c.grantedAt!, locale),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
