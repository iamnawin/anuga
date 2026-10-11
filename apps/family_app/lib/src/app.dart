import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_dart/shared_dart.dart';

import '../l10n/generated/app_localizations.dart';
import 'payments.dart';
import 'photo_source.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'vault_files.dart';

/// Root widget. [api] and [auth] are injected so tests can run the whole app
/// against fakes; `main.dart` passes the Supabase-backed versions.
class FamilyApp extends StatefulWidget {
  const FamilyApp({
    super.key,
    required this.api,
    required this.auth,
    required this.files,
    required this.photos,
    required this.payments,
    this.initialLocale = const Locale('en'),
  });

  final FamilyApi api;
  final PhoneAuth auth;
  final VaultFiles files;
  final PhotoSource photos;
  final Payments payments;
  final Locale initialLocale;

  @override
  State<FamilyApp> createState() => _FamilyAppState();
}

class _FamilyAppState extends State<FamilyApp> {
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
      theme: familyTheme(Brightness.light),
      darkTheme: familyTheme(Brightness.dark),
      builder: largeText,
      home: _signedIn
          ? HomeScreen(
              api: widget.api,
              files: widget.files,
              photos: widget.photos,
              payments: widget.payments,
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

/// High contrast, 56 dp buttons: many family members and patients are elderly.
ThemeData familyTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF00666B), brightness: brightness).copyWith(
    primary: Color(dark ? 0xFF8DDDD1 : 0xFF00666B),
    onPrimary: Color(dark ? 0xFF073B3E : 0xFFFFFFFF),
    surface: Color(dark ? 0xFF102426 : 0xFFFFFFFF),
    onSurface: Color(dark ? 0xFFEFF8F6 : 0xFF10243A),
    onSurfaceVariant: Color(dark ? 0xFFBED3D1 : 0xFF465D6B),
    surfaceContainerLow: Color(dark ? 0xFF183235 : 0xFFEAF7F4),
    primaryContainer: Color(dark ? 0xFF24484A : 0xFFD4F0E9),
    onPrimaryContainer: Color(dark ? 0xFFEFF8F6 : 0xFF073B3E),
    outline: Color(dark ? 0xFF91ADAB : 0xFF6A8588),
    outlineVariant: Color(dark ? 0xFF375659 : 0xFFD5E4E2),
    error: Color(dark ? 0xFFFFB4AB : 0xFF9E2929),
    errorContainer: Color(dark ? 0xFF532726 : 0xFFFDEAEA),
    onErrorContainer: Color(dark ? 0xFFFFDAD6 : 0xFF9E2929),
  );
  const tap = Size(64, 56);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final text = base.textTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  return base.copyWith(
    scaffoldBackgroundColor: Color(dark ? 0xFF102426 : 0xFFF7FBFA),
    textTheme: text.copyWith(
      headlineSmall: text.headlineSmall?.copyWith(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25),
      titleLarge: text.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3),
      titleMedium: text.titleMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.35),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 18, height: 1.5),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
      bodySmall: text.bodySmall?.copyWith(fontSize: 14, height: 1.4, color: scheme.onSurfaceVariant),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(color: scheme.onSurface, fontSize: 20, fontWeight: FontWeight.w700),
      toolbarHeight: 72,
    ),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.primaryContainer,
      labelStyle: TextStyle(color: scheme.onPrimaryContainer, fontSize: 14, fontWeight: FontWeight.w600),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurface),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: const Size(48, 48))),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.all(16),
      iconColor: scheme.primary,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: scheme.onSurface),
      subtitleTextStyle: TextStyle(fontSize: 16, height: 1.5, color: scheme.onSurfaceVariant),
    ),
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
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(48, 48))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.primary, width: 2),
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
      icon: const Icon(Icons.translate, size: 28),
      tooltip: AppLocalizations.of(context).language,
      onSelected: (code) => onChanged(Locale(code)),
      itemBuilder: (context) => [
        for (final entry in names.entries) PopupMenuItem(value: entry.key, child: Text(entry.value)),
      ],
    );
  }
}
