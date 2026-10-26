import 'dart:async';

import 'package:companion_app/companion_app.dart' show companionTheme, TripsScreen;
import 'package:companion_app/l10n/generated/app_localizations.dart' as companion_l10n;
import 'package:family_app/family_app.dart' show familyTheme, largeText, HomeScreen, Payments, PhotoSource, VaultFiles;
import 'package:family_app/l10n/generated/app_localizations.dart' as family_l10n;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_dart/shared_dart.dart';

import '../l10n/generated/app_localizations.dart';
import 'auth.dart';
import 'screens/account_status_screen.dart';
import 'screens/login_screen.dart';

/// Where the app is between launch and a role home.
enum AccountStage { signedOut, checking, family, companion, opsAccount, noRole, expired, error }

/// Root widget: one sign-in, then the home for the role the database reports.
/// The role is read from `profiles.role` after every sign-in and on launch with a
/// stored session; nothing on screen can choose or change it, and every RPC the
/// homes call is checked again by the database. Dependencies are injected so
/// tests run the whole app against fakes; `main.dart` passes the Supabase ones.
class AnugaCareApp extends StatefulWidget {
  const AnugaCareApp({
    super.key,
    required this.auth,
    required this.familyApi,
    required this.companionApi,
    required this.files,
    required this.photos,
    required this.payments,
    this.initialLocale = const Locale('en'),
  });

  final AccountAuth auth;
  final FamilyApi familyApi;
  final CompanionApi companionApi;
  final VaultFiles files;
  final PhotoSource photos;
  final Payments payments;
  final Locale initialLocale;

  @override
  State<AnugaCareApp> createState() => _AnugaCareAppState();
}

class _AnugaCareAppState extends State<AnugaCareApp> {
  final _navigator = GlobalKey<NavigatorState>();
  late Locale _locale = widget.initialLocale;
  late AccountStage _stage = widget.auth.isSignedIn ? AccountStage.checking : AccountStage.signedOut;
  late final StreamSubscription<void> _sessionEnded;

  /// Set while the app signs out by itself, so the resulting sign-out event is
  /// not shown as an expired session. Cleared when a new session starts.
  bool _signedOutByApp = false;

  @override
  void initState() {
    super.initState();
    _sessionEnded = widget.auth.sessionEnded.listen((_) {
      final inSession =
          _stage == AccountStage.checking || _stage == AccountStage.family || _stage == AccountStage.companion;
      if (!_signedOutByApp && inSession) _show(AccountStage.expired);
    });
    if (_stage == AccountStage.checking) _resolve();
  }

  @override
  void dispose() {
    _sessionEnded.cancel();
    super.dispose();
  }

  Future<void> _resolve() async {
    _signedOutByApp = false;
    _show(AccountStage.checking);
    try {
      switch (await widget.auth.currentRole()) {
        case 'family':
          _show(AccountStage.family);
        case 'companion':
          _show(AccountStage.companion);
        case 'ops_admin':
          await _signOut(AccountStage.opsAccount);
        default:
          await _signOut(AccountStage.noRole);
      }
    } on SessionExpiredException {
      await _signOut(AccountStage.expired);
    } catch (_) {
      _show(AccountStage.error);
    }
  }

  Future<void> _signOut(AccountStage next) async {
    _signedOutByApp = true;
    try {
      await widget.auth.signOut();
    } catch (_) {
      // The local session is cleared even when the server call fails.
    }
    _show(next);
  }

  void _show(AccountStage stage) {
    if (!mounted || stage == _stage) return;
    // Leave any screen a role home pushed (a trip, a record) before changing home.
    _navigator.currentState?.popUntil((route) => route.isFirst);
    setState(() => _stage = stage);
  }

  void _setLocale(Locale locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    final theme = _stage == AccountStage.companion ? companionTheme : familyTheme;
    return MaterialApp(
      navigatorKey: _navigator,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        family_l10n.AppLocalizations.delegate,
        companion_l10n.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      builder: largeText,
      home: Builder(builder: _home),
    );
  }

  Widget _home(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void signIn() => _show(AccountStage.signedOut);
    return switch (_stage) {
      AccountStage.signedOut => LoginScreen(auth: widget.auth, onLocaleChanged: _setLocale, onSignedIn: _resolve),
      AccountStage.checking => AccountStatusScreen(
        key: const Key('checking'),
        icon: Icons.verified_user_outlined,
        title: l10n.checkingAccount,
        busy: true,
        onLocaleChanged: _setLocale,
      ),
      AccountStage.family => HomeScreen(
        api: widget.familyApi,
        files: widget.files,
        photos: widget.photos,
        payments: widget.payments,
        onLocaleChanged: _setLocale,
        onSignOut: () => _signOut(AccountStage.signedOut),
      ),
      AccountStage.companion => TripsScreen(
        api: widget.companionApi,
        onLocaleChanged: _setLocale,
        onSignOut: () => _signOut(AccountStage.signedOut),
      ),
      AccountStage.opsAccount => AccountStatusScreen(
        key: const Key('opsAccount'),
        icon: Icons.desktop_windows_outlined,
        title: l10n.opsAccountTitle,
        body: l10n.opsAccountBody,
        primaryLabel: l10n.backToSignIn,
        onPrimary: signIn,
        onLocaleChanged: _setLocale,
      ),
      AccountStage.noRole => AccountStatusScreen(
        key: const Key('noRole'),
        icon: Icons.person_off_outlined,
        title: l10n.noRoleTitle,
        body: l10n.noRoleBody,
        primaryLabel: l10n.backToSignIn,
        onPrimary: signIn,
        onLocaleChanged: _setLocale,
      ),
      AccountStage.expired => AccountStatusScreen(
        key: const Key('expired'),
        icon: Icons.lock_clock_outlined,
        title: l10n.sessionExpiredTitle,
        body: l10n.sessionExpiredBody,
        primaryLabel: l10n.signInAgain,
        onPrimary: signIn,
        onLocaleChanged: _setLocale,
      ),
      AccountStage.error => AccountStatusScreen(
        key: const Key('accountError'),
        icon: Icons.wifi_off_outlined,
        title: l10n.accountErrorTitle,
        body: l10n.accountErrorBody,
        primaryLabel: l10n.retry,
        onPrimary: _resolve,
        secondaryLabel: l10n.signOut,
        onSecondary: () => _signOut(AccountStage.signedOut),
        onLocaleChanged: _setLocale,
      ),
    };
  }
}
