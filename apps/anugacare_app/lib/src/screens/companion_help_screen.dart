import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'companion_ui.dart';

class CompanionHelpScreen extends StatelessWidget {
  const CompanionHelpScreen({super.key, this.onReportIssue});
  final VoidCallback? onReportIssue;
  @override
  Widget build(BuildContext context) => CompanionNetworkView(
    builder: (context) {
      final l = AppLocalizations.of(context);
      Future<void> call(String number) async {
        final opened = await companionExternal(Uri(scheme: 'tel', path: number));
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.cCannotOpen)));
        }
      }

      return Scaffold(
        appBar: AppBar(title: Text(l.cHelp)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (companionIsOffline(context)) const CompanionOfflineNotice(),
              CompanionPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.emergency_outlined, size: 40),
                    const SizedBox(height: 12),
                    Text(l.cEmergency),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: () => call('112'), child: Text(l.cCall112)),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: () => call('108'), child: Text(l.cCall108)),
                  ],
                ),
              ),
              const CompanionSupport(),
              if (onReportIssue != null)
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onReportIssue!();
                  },
                  child: Text(l.actionReportIssue),
                ),
              ExpansionTile(
                title: Text(l.cUnwell),
                children: [Padding(padding: const EdgeInsets.all(16), child: Text(l.cUnwellGuide))],
              ),
              ExpansionTile(
                title: Text(l.cCannotFind),
                children: [Padding(padding: const EdgeInsets.all(16), child: Text(l.cCannotFindGuide))],
              ),
              ExpansionTile(
                title: Text(l.cCentreNotReady),
                children: [Padding(padding: const EdgeInsets.all(16), child: Text(l.cCentreGuide))],
              ),
              const SizedBox(height: 24),
              Text(l.cNonClinical),
            ],
          ),
        ),
      );
    },
  );
}
