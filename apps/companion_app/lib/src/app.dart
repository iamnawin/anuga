import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_dart/shared_dart.dart';

import '../l10n/generated/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/trips_screen.dart';

/// Root widget. [api] and [auth] are injected so tests can run the whole app
/// against fakes; `main.dart` passes the Supabase-backed versions.
class CompanionApp extends StatefulWidget {
  const CompanionApp({super.key, required this.api, required this.auth, this.initialLocale = const Locale('en')});

  final CompanionApi api;
  final PhoneAuth auth;
  final Locale initialLocale;

  @override
  State<CompanionApp> createState() => _CompanionAppState();
}

class _CompanionAppState extends State<CompanionApp> {
  late Locale _locale = widget.initialLocale;
  late bool _signedIn = widget.auth.isSignedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: companionTheme(Brightness.light),
      darkTheme: companionTheme(Brightness.dark),
      builder: largeText,
      home: _signedIn
          ? TripsScreen(
              api: widget.api,
              onLocaleChanged: _setLocale,
              onSignOut: () async {
                await widget.auth.signOut();
                setState(() => _signedIn = false);
              },
            )
          : LoginScreen(
              auth: widget.auth,
              onLocaleChanged: _setLocale,
              onSignedIn: () => setState(() => _signedIn = true),
            ),
    );
  }

  void _setLocale(Locale locale) => setState(() => _locale = locale);
}

/// Large text, large tap targets, high contrast: many companions and patients are elderly.
ThemeData companionTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0B5CAD), brightness: brightness, contrastLevel: 1.0);
  const tap = Size(64, 56);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: tap,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: tap,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}

/// Text is at least 15% larger than the platform default; a larger accessibility
/// setting chosen by the user still wins.
Widget largeText(BuildContext context, Widget? child) {
  final media = MediaQuery.of(context);
  return MediaQuery(
    data: media.copyWith(textScaler: media.textScaler.clamp(minScaleFactor: 1.15)),
    child: child ?? const SizedBox.shrink(),
  );
}

/// Language picker shown on every screen (English, Telugu, Hindi).
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key, required this.onChanged});

  final ValueChanged<Locale> onChanged;

  static const names = {'en': 'English', 'te': 'తెలుగు', 'hi': 'हिन्दी'};

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.translate, size: 28),
      tooltip: AppLocalizations.of(context).language,
      onSelected: (code) => onChanged(Locale(code)),
      itemBuilder: (context) => [
        for (final entry in names.entries) PopupMenuItem(value: entry.key, child: Text(entry.value)),
      ],
    );
  }
}
