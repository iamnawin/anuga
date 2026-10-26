import 'package:family_app/family_app.dart' show CareHeading, LanguageMenu;
import 'package:flutter/material.dart';

/// Full-screen state between sign-in and a role home: checking, expired session,
/// an account this app cannot open, or a failed lookup. [busy] shows a spinner
/// instead of actions.
class AccountStatusScreen extends StatelessWidget {
  const AccountStatusScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.onLocaleChanged,
    this.body,
    this.busy = false,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String? body;
  final bool busy;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Fixed wordmark, as on the family and companion screens; the localized name is the window title.
          'AnugaCare',
          style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
        actions: [LanguageMenu(onChanged: onLocaleChanged)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(icon, size: 48, color: scheme.primary),
              const SizedBox(height: 24),
              // Announced by screen readers as soon as the state changes.
              Semantics(liveRegion: true, child: CareHeading(title)),
              if (body != null) Text(body!, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              if (busy)
                const Center(child: CircularProgressIndicator())
              else ...[
                if (primaryLabel != null) FilledButton(onPressed: onPrimary, child: Text(primaryLabel!)),
                if (secondaryLabel != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
