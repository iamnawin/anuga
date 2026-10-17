import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
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
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } on PhoneAuthException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } catch (_) {
      if (mounted) setState(() => _message = AppLocalizations.of(context).accessError);
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
      if (!mounted) return;
      setState(() {
        _sentTo = phone;
        _code.clear();
      });
    });
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    if (!isOtpCode(_code.text)) return setState(() => _message = l10n.invalidCode);
    await _run(() async {
      await widget.auth.verifyCode(_sentTo!, _code.text.trim());
      if (mounted) widget.onSignedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANUGA', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [LanguageMenu(onChanged: widget.onLocaleChanged)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.people_outline, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(l10n.loginTitle, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 32),
              if (_sentTo == null) ...[
                TextField(
                  key: const Key('phone'),
                  enabled: !_busy,
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: InputDecoration(labelText: l10n.phoneLabel, helperText: l10n.phoneHint),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _busy ? null : _sendCode, child: Text(l10n.sendCode)),
              ] else ...[
                Text(l10n.codeSentTo(_sentTo!), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('code'),
                  enabled: !_busy,
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
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          _sentTo = null;
                          _code.clear();
                          _message = null;
                        }),
                  child: Text(l10n.changeNumber),
                ),
              ],
              if (_busy) ...[const SizedBox(height: 16), const LinearProgressIndicator()],
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(_message!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 18)),
              ],
              const SizedBox(height: 32),
              Text(
                l10n.syntheticBanner,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
