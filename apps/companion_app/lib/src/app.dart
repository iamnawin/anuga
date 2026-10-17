import 'dart:async';

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

enum _AccessState { signedOut, checking, allowed, denied, pending, disabled, unconfirmed, error }

class _CompanionAppState extends State<CompanionApp> with WidgetsBindingObserver {
  late Locale _locale = widget.initialLocale;
  _AccessState _access = _AccessState.signedOut;
  final _navigator = GlobalKey<NavigatorState>();
  int _request = 0;
  StreamSubscription<void>? _accessSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _accessSubscription = widget.auth.accessChanges.listen((_) {
      if (_access == _AccessState.denied && !widget.auth.isSignedIn) return;
      _checkAccess();
    });
    _checkAccess();
  }

  @override
  void dispose() {
    _request++;
    _accessSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkAccess();
  }

  Future<void> _checkAccess() async {
    final request = ++_request;
    _navigator.currentState?.popUntil((route) => route.isFirst);
    if (!widget.auth.isSignedIn) {
      setState(() => _access = _AccessState.signedOut);
      return;
    }
    setState(() => _access = _AccessState.checking);
    try {
      final access = await widget.auth.accountAccess();
      if (!mounted || request != _request) return;
      if (!widget.auth.isSignedIn) {
        setState(() => _access = _AccessState.signedOut);
      } else if (access.state == AccountState.pending) {
        setState(() => _access = _AccessState.pending);
      } else if (access.state == AccountState.disabled) {
        setState(() => _access = _AccessState.disabled);
      } else if (access.state == AccountState.unconfirmed) {
        // A missing profile cannot establish incomplete provisioning or revocation.
        setState(() => _access = _AccessState.unconfirmed);
      } else if (access.role != 'companion') {
        setState(() => _access = _AccessState.denied);
        await widget.auth.signOut();
        if (mounted && request == _request) setState(() => _access = _AccessState.denied);
      } else {
        setState(() => _access = _AccessState.allowed);
      }
    } catch (_) {
      if (mounted && request == _request) setState(() => _access = _AccessState.error);
    }
  }

  Future<void> _signOut() async {
    final request = ++_request;
    _navigator.currentState?.popUntil((route) => route.isFirst);
    setState(() => _access = _AccessState.checking);
    try {
      await widget.auth.signOut();
      if (mounted && request == _request) setState(() => _access = _AccessState.signedOut);
    } catch (_) {
      if (mounted && request == _request) setState(() => _access = _AccessState.error);
    }
  }

  Widget _accessScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = _access == _AccessState.checking;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANUGA'),
        actions: [LanguageMenu(onChanged: _setLocale)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (busy) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 24),
                Text(l10n.accessChecking, semanticsLabel: l10n.accessChecking),
              ] else ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _access == _AccessState.denied
                        ? l10n.notCompanion
                        : _access == _AccessState.pending
                        ? l10n.accessPending
                        : _access == _AccessState.disabled
                        ? l10n.accessDisabled
                        : _access == _AccessState.unconfirmed
                        ? l10n.accessUnconfirmed
                        : l10n.accessError,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('access-retry'),
                  onPressed: _checkAccess,
                  child: Text(_access == _AccessState.denied ? l10n.changeNumber : l10n.refresh),
                ),
                const SizedBox(height: 16),
                OutlinedButton(onPressed: _signOut, child: Text(l10n.signOut)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigator,
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
      home: _access == _AccessState.allowed
          ? TripsScreen(api: widget.api, onLocaleChanged: _setLocale, onSignOut: _signOut)
          : _access != _AccessState.signedOut
          ? Builder(builder: _accessScreen)
          : LoginScreen(auth: widget.auth, onLocaleChanged: _setLocale, onSignedIn: _checkAccess),
    );
  }

  void _setLocale(Locale locale) => setState(() => _locale = locale);
}

/// Large text, large tap targets, high contrast: many companions and patients are elderly.
ThemeData companionTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF00666B), brightness: brightness).copyWith(
    primary: Color(dark ? 0xFF8DDDD1 : 0xFF00666B),
    onPrimary: Color(dark ? 0xFF073B3E : 0xFFFFFFFF),
    surface: Color(dark ? 0xFF102426 : 0xFFFFFFFF),
    onSurface: Color(dark ? 0xFFEFF8F6 : 0xFF10243A),
    onSurfaceVariant: Color(dark ? 0xFFBED3D1 : 0xFF465D6B),
    surfaceContainerLow: Color(dark ? 0xFF183235 : 0xFFEAF7F4),
    outline: Color(dark ? 0xFF8BAAA7 : 0xFF6A8588),
    outlineVariant: Color(dark ? 0xFF355457 : 0xFFD5E4E2),
    error: Color(dark ? 0xFFFFB4AB : 0xFF9E2929),
    errorContainer: Color(dark ? 0xFF503030 : 0xFFFDEAEA),
    onErrorContainer: Color(dark ? 0xFFFFDAD6 : 0xFF9E2929),
  );
  const tap = Size(64, 56);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Color(dark ? 0xFF102426 : 0xFFF7FBFA),
    textTheme: base.textTheme
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
        .copyWith(
          headlineSmall: TextStyle(color: scheme.onSurface, fontSize: 28, fontWeight: FontWeight.w700, height: 1.25),
          titleLarge: TextStyle(color: scheme.onSurface, fontSize: 22, fontWeight: FontWeight.w700, height: 1.3),
          titleMedium: TextStyle(color: scheme.onSurface, fontSize: 20, fontWeight: FontWeight.w700, height: 1.35),
          bodyLarge: TextStyle(color: scheme.onSurface, fontSize: 18, height: 1.5),
          bodyMedium: TextStyle(color: scheme.onSurface, fontSize: 16, height: 1.5),
        ),
    appBarTheme: AppBarTheme(backgroundColor: scheme.surface, foregroundColor: scheme.primary, elevation: 0),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: const Size(48, 48))),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(48, 48))),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: tap,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: tap,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: BorderSide(color: scheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.all(16),
      helperMaxLines: 3,
      errorMaxLines: 4,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outline),
      ),
    ),
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
      constraints: const BoxConstraints(minWidth: 160),
      icon: const Icon(Icons.translate, size: 28),
      tooltip: AppLocalizations.of(context).language,
      onSelected: (code) => onChanged(Locale(code)),
      itemBuilder: (context) => [
        for (final entry in names.entries) PopupMenuItem(value: entry.key, child: Text(entry.value)),
      ],
    );
  }
}
