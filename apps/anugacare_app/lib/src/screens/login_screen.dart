import 'package:family_app/family_app.dart' show LanguageMenu;
import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';

/// One sign-in for every mobile user: phone, then the SMS code. There is no
/// role choice; after sign-in the app asks the database which screens to open.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth, required this.onSignedIn, required this.onLocaleChanged});

  final PhoneAuth auth;
  final VoidCallback onSignedIn;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  String? _sentTo;
  String? _message;
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } on PhoneAuthException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context);
    final phone = normalizeIndianMobile(_phone.text);
    if (phone == null) return setState(() => _message = l10n.invalidPhone);
    await _run(() async {
      await widget.auth.sendCode(phone);
      if (mounted) setState(() => _sentTo = phone);
    });
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    if (!isOtpCode(_code.text)) return setState(() => _message = l10n.invalidCode);
    await _run(() async {
      await widget.auth.verifyCode(_sentTo!, _code.text.trim());
      widget.onSignedIn();
    });
  }

  void _changeNumber() {
    _code.clear();
    setState(() {
      _sentTo = null;
      _message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final keyboardOtp = _sentTo != null && MediaQuery.viewInsetsOf(context).bottom > 0;
    return PopScope(
      canPop: _sentTo == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _sentTo != null && !_busy) _changeNumber();
      },
      child: Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      key: ValueKey(_sentTo == null),
                      padding: const EdgeInsets.fromLTRB(16, 38, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: PopupMenuButton<String>(
                              tooltip: l10n.language,
                              onSelected: (code) => widget.onLocaleChanged(Locale(code)),
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
                                    const Icon(Icons.language, size: 24),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        LanguageMenu.names[Localizations.localeOf(context).languageCode]!,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.keyboard_arrow_down, size: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: _sentTo == null ? 0 : 8),
                          Center(
                            child: Image.asset(
                              _sentTo == null
                                  ? 'assets/brand/anugacare-lockup.png'
                                  : 'assets/brand/anugacare-symbol.png',
                              key: Key(_sentTo == null ? 'brand-lockup' : 'brand-symbol'),
                              width: _sentTo == null
                                  ? 284
                                  : keyboardOtp
                                  ? 32
                                  : 64,
                              // The light-only lockup sits on its approved mist backing in dark mode.
                              semanticLabel: 'AnugaCare',
                              frameBuilder: (context, child, frame, synchronous) =>
                                  ColoredBox(color: const Color(0xFFF7FBFA), child: child),
                            ),
                          ),
                          SizedBox(height: _sentTo == null ? 0 : 16),
                          Container(
                            padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              border: Border.all(color: scheme.outlineVariant),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    _sentTo == null ? l10n.loginTitle : l10n.signIn,
                                    style: Theme.of(context).textTheme.headlineSmall
                                        ?.copyWith(fontSize: _sentTo == null ? 34 : 28),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_sentTo == null) ...[
                                  Text(
                                    l10n.loginIntro,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 17, height: 1.4),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(l10n.phoneLabel, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 16),
                                  Semantics(
                                    label: l10n.phoneLabel,
                                    child: TextField(
                                      key: const Key('phone'),
                                      controller: _phone,
                                      keyboardType: TextInputType.phone,
                                      autofillHints: const [AutofillHints.telephoneNumber],
                                      decoration: InputDecoration(
                                        hintText: l10n.phoneHint,
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('+91', style: Theme.of(context).textTheme.titleMedium),
                                              const SizedBox(width: 16),
                                              SizedBox(
                                                height: 32,
                                                child: VerticalDivider(color: scheme.outlineVariant, width: 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Divider(color: scheme.outlineVariant, height: 1),
                                  const SizedBox(height: 32),
                                  FilledButton(
                                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                                    key: const Key('send-code'),
                                    onPressed: _busy ? null : _sendCode,
                                    child: Text(l10n.sendCode, textAlign: TextAlign.center),
                                  ),
                                ] else ...[
                                  Text(l10n.codeSentTo(_sentTo!), style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 16),
                                  TextField(
                                    key: const Key('code'),
                                    controller: _code,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    autofillHints: const [AutofillHints.oneTimeCode],
                                    decoration: InputDecoration(
                                      labelText: l10n.codeLabel,
                                      prefixIcon: const Icon(Icons.password_outlined),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (!keyboardOtp)
                                    FilledButton(
                                      key: const Key('verify-code'),
                                      onPressed: _busy ? null : _verify,
                                      child: Text(l10n.signIn, textAlign: TextAlign.center),
                                    ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: _busy ? null : _changeNumber,
                                    child: Text(l10n.changeNumber),
                                  ),
                                ],
                                if (_busy) ...[const SizedBox(height: 16), const LinearProgressIndicator()],
                                if (_message != null) ...[
                                  const SizedBox(height: 16),
                                  Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      _message!,
                                      key: const Key('loginMessage'),
                                      style: TextStyle(color: scheme.error, fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(l10n.syntheticBanner, style: Theme.of(context).textTheme.bodySmall),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (keyboardOtp)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: const Key('verify-code'),
                          onPressed: _busy ? null : _verify,
                          child: Text(l10n.signIn, textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
