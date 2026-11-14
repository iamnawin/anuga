import 'package:family_app/family_app.dart' show LanguageMenu;
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Signed-out introduction only. Both actions open the same existing login;
/// neither selects a role or creates an account.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onStart, required this.onLocaleChanged, this.textSizeControl});
  final VoidCallback onStart;
  final ValueChanged<Locale> onLocaleChanged;
  final Widget? textSizeControl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final code = Localizations.localeOf(context).languageCode;
    final logo = Image.asset('assets/brand/anugacare-lockup.png', width: 176, semanticLabel: 'AnugaCare');
    return Scaffold(
      key: const Key('welcome'),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: PopupMenuButton<String>(
                      tooltip: l10n.language,
                      onSelected: (value) => onLocaleChanged(Locale(value)),
                      itemBuilder: (_) => [
                        for (final entry in LanguageMenu.names.entries)
                          PopupMenuItem(value: entry.key, child: Text(entry.value)),
                      ],
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: scheme.onSurfaceVariant),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                LanguageMenu.names[code]!,
                                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: scheme.brightness == Brightness.dark
                        ? ShaderMask(
                            blendMode: BlendMode.srcATop,
                            // Same approved PNG/text boundary as the reviewed login artwork.
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.transparent, scheme.onSurface, scheme.onSurface],
                              stops: const [0, .70, .70, 1],
                            ).createShader(bounds),
                            child: logo,
                          )
                        : logo,
                  ),
                  const SizedBox(height: 16),
                  const _WelcomeHero(),
                  const SizedBox(height: 8),
                  Semantics(
                    header: true,
                    child: Text(l10n.welcomeTitle, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.welcomeBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in LanguageMenu.names.entries)
                        ChoiceChip(
                          key: Key('welcome-language-${entry.key}'),
                          label: Text(entry.value),
                          selected: code == entry.key,
                          backgroundColor: Colors.transparent,
                          selectedColor: scheme.primary,
                          checkmarkColor: scheme.onPrimary,
                          side: BorderSide(color: code == entry.key ? scheme.primary : scheme.outline),
                          onSelected: (_) => onLocaleChanged(Locale(entry.key)),
                          labelStyle: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: code == entry.key ? scheme.onPrimary : scheme.onSurface,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('welcome-get-started'),
                    onPressed: onStart,
                    icon: const Icon(Icons.arrow_forward),
                    iconAlignment: IconAlignment.end,
                    label: Text(l10n.welcomeGetStarted, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(l10n.welcomeOr)),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  TextButton(
                    key: const Key('welcome-companion-sign-in'),
                    onPressed: onStart,
                    child: Text(
                      l10n.welcomeCompanionSignIn,
                      textAlign: TextAlign.center,
                      style: const TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.syntheticBanner, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                  ?textSizeControl,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The asset owns the asymmetric arch and softened scenery. Alpha-only masks
/// blend with either theme without tinting the faces, hands or cane handle.
class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: AspectRatio(
      aspectRatio: 4 / 3,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent, Colors.transparent],
          // Both hands finish above .86; the image is clear before the headline.
          stops: [0, .06, .86, .92, 1],
        ).createShader(bounds),
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
            stops: [0, .12, .88, 1],
          ).createShader(bounds),
          child: Image.asset(
            'assets/welcome/walking-clinic-hero.png',
            key: const Key('welcome-illustration'),
            excludeFromSemantics: true,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
  );
}
