import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import 'care_ui.dart';
import '../app.dart';

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
      setState(() => _sentTo = phone);
    });
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    if (!isOtpCode(_code.text)) return setState(() => _message = l10n.invalidCode);
    await _run(() async {
      await widget.auth.verifyCode(_sentTo!, _code.text.trim());
      // The database enforces roles anyway; this only avoids an empty, confusing app.
      if (await widget.auth.currentRole() != 'family') {
        await widget.auth.signOut();
        setState(() {
          _sentTo = null;
          _code.clear();
          _message = l10n.notFamily;
        });
        return;
      }
      widget.onSignedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ANUGA',
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
        actions: [LanguageMenu(onChanged: widget.onLocaleChanged)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              CareHeading(_sentTo == null ? l10n.loginTitle : l10n.codeLabel),
              CarePanel(
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.syntheticBanner)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (_sentTo == null) ...[
                TextField(
                  key: const Key('phone'),
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: InputDecoration(
                    labelText: l10n.phoneLabel,
                    helperText: l10n.phoneHint,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _busy ? null : _sendCode, child: Text(l10n.sendCode)),
              ] else ...[
                Text(l10n.codeSentTo(_sentTo!), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('code'),
                  controller: _code,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  decoration: InputDecoration(labelText: l10n.codeLabel),
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _busy ? null : _verify, child: Text(l10n.signIn)),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _busy ? null : () => setState(() => _sentTo = null),
                  child: Text(l10n.changeNumber),
                ),
              ],
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(_message!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 18)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
