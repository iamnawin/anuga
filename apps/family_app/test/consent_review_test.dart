import 'dart:async';

import 'package:family_app/src/screens/consent_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

class ConsentBackend extends FakeFamilyBackend {
  ConsentBackend({super.level});
  final writes = <Map<String, Object?>>[];
  ConsentPurpose? failPurpose;
  Object? readError;
  bool failReload = false;
  bool wrongResult = false;
  Completer<void>? saveGate;

  @override
  Future<Object?> rpc(String function, Map<String, Object?> params) async {
    if (function == 'family_consents' && (readError != null || (failReload && writes.isNotEmpty))) {
      throw readError ?? const RpcException('', 'offline reload');
    }
    if (function == 'set_consent') {
      writes.add({...params});
      if (saveGate != null) await saveGate!.future;
      if (wrongResult) return !(params['p_active']! as bool);
      if (params['p_purpose'] == failPurpose?.dbValue) throw const RpcException('', 'offline save');
    }
    return super.rpc(function, params);
  }
}

Future<void> openConsents(WidgetTester tester, ConsentBackend backend) async {
  final patient = (await backend.api.myPatients()).single;
  await pumpLocalized(tester, ConsentScreen(api: backend.api, patient: patient));
}

void main() {
  testWidgets('each switch announces its consent purpose', (tester) async {
    final handle = tester.ensureSemantics();
    final backend = ConsentBackend();
    await openConsents(tester, backend);
    for (final entry in {
      'trips': 'Trip coordination',
      'vault': 'Private health vault',
      'ops_vault_access': 'Let AnugaCare support see my vault',
    }.entries) {
      final control = byKey('switch-${entry.key}');
      await tester.ensureVisible(control);
      await tester.pumpAndSettle();
      expect(tester.getSemantics(control).label, contains(entry.value));
    }
    expect(backend.writes, isEmpty);
    handle.dispose();
  });
  testWidgets('existing support is not revoked implicitly when vault is withdrawn', (tester) async {
    final backend = ConsentBackend()..consentState[ConsentPurpose.opsVaultAccess] = true;
    await openConsents(tester, backend);
    await tapVisible(tester, byKey('switch-vault'));
    await tapVisible(tester, find.text('Turn off'));
    await tapVisible(tester, byKey('save-consents'));
    expect(backend.consentState[ConsentPurpose.opsVaultAccess], isTrue);
    expect(backend.writes.single['p_purpose'], 'vault');
    expect(tester.widget<Switch>(byKey('switch-ops_vault_access')).onChanged, isNotNull);
  });

  testWidgets('unsaved support grant is dropped when vault draft is turned off', (tester) async {
    final backend = ConsentBackend()..consentState[ConsentPurpose.vault] = false;
    await openConsents(tester, backend);
    await tapVisible(tester, byKey('switch-vault'));
    await tapVisible(tester, byKey('switch-ops_vault_access'));
    await tapVisible(tester, byKey('switch-vault'));
    expect(tester.widget<Switch>(byKey('switch-ops_vault_access')).value, isFalse);
    expect(tester.widget<FilledButton>(byKey('save-consents')).onPressed, isNull);
    expect(backend.writes, isEmpty);
  });

  testWidgets('mismatched RPC result is not reported saved', (tester) async {
    final backend = ConsentBackend()..wrongResult = true;
    await openConsents(tester, backend);
    await tapVisible(tester, byKey('switch-ops_vault_access'));
    await tapVisible(tester, byKey('save-consents'));
    expect(backend.consentState[ConsentPurpose.opsVaultAccess], isFalse);
    expect(find.text('Your choices were saved.'), findsNothing);
    expect(tester.widget<FilledButton>(byKey('save-consents')).onPressed, isNotNull);
  });

  testWidgets('pending save disables edits and repeat save', (tester) async {
    final backend = ConsentBackend()..saveGate = Completer<void>();
    await openConsents(tester, backend);
    await tapVisible(tester, byKey('switch-ops_vault_access'));
    await tester.ensureVisible(byKey('save-consents'));
    await tester.tap(byKey('save-consents'));
    await tester.pump();
    expect(tester.widget<FilledButton>(byKey('save-consents')).onPressed, isNull);
    expect(tester.widget<Switch>(byKey('switch-trips')).onChanged, isNull);
    backend.saveGate!.complete();
    await tester.pumpAndSettle();
    expect(backend.writes, hasLength(1));
  });
  testWidgets('server state is the initial state; only explicit differences save for selected patient', (tester) async {
    final backend = ConsentBackend()..consentState.updateAll((_, _) => false);
    await openConsents(tester, backend);
    expect(find.text('Trip coordination'), findsOneWidget);
    expect(find.text('Needed to book trips'), findsOneWidget);
    expect(tester.widget<Switch>(byKey('switch-trips')).value, isFalse);
    expect(backend.writes, isEmpty);
    await tapVisible(tester, byKey('switch-trips'));
    expect(backend.writes, isEmpty);
    await tapVisible(tester, byKey('save-consents'));
    expect(backend.writes, [
      {'p_patient_id': 'p1', 'p_purpose': 'trips', 'p_active': true},
    ]);
    expect(tester.widget<FilledButton>(byKey('save-consents')).onPressed, isNull);
  });

  testWidgets('vault off blocks new support grant but existing support can be withdrawn separately', (tester) async {
    final backend = ConsentBackend()..consentState[ConsentPurpose.vault] = false;
    await openConsents(tester, backend);
    expect(tester.widget<Switch>(byKey('switch-ops_vault_access')).onChanged, isNull);
    backend.consentState[ConsentPurpose.opsVaultAccess] = true;
    await openConsents(tester, backend);
    await tapVisible(tester, byKey('switch-ops_vault_access'));
    await tapVisible(tester, find.text('Turn off'));
    expect(backend.consentState[ConsentPurpose.opsVaultAccess], isTrue);
    await tapVisible(tester, byKey('save-consents'));
    expect(backend.consentState[ConsentPurpose.opsVaultAccess], isFalse);
    expect(backend.writes.single['p_purpose'], 'ops_vault_access');
  });

  testWidgets('partial save reconciles successful values and retries only remaining explicit change', (tester) async {
    final backend = ConsentBackend()
      ..consentState[ConsentPurpose.vault] = false
      ..failPurpose = ConsentPurpose.opsVaultAccess;
    await openConsents(tester, backend);
    await tapVisible(tester, byKey('switch-vault'));
    await tapVisible(tester, byKey('switch-ops_vault_access'));
    await tapVisible(tester, byKey('save-consents'));
    expect(backend.consentState[ConsentPurpose.vault], isTrue);
    expect(backend.consentState[ConsentPurpose.opsVaultAccess], isFalse);
    expect(byKey('consent-save-message'), findsOneWidget);
    backend.failPurpose = null;
    await tapVisible(tester, byKey('save-consents'));
    expect(backend.writes.where((w) => w['p_purpose'] == 'vault'), hasLength(1));
    expect(backend.consentState[ConsentPurpose.opsVaultAccess], isTrue);
  });

  testWidgets('failed vault enable never sends dependent support grant', (tester) async {
    final backend = ConsentBackend()
      ..consentState[ConsentPurpose.vault] = false
      ..failPurpose = ConsentPurpose.vault;
    await openConsents(tester, backend);
    await tapVisible(tester, byKey('switch-vault'));
    await tapVisible(tester, byKey('switch-ops_vault_access'));
    await tapVisible(tester, byKey('save-consents'));
    expect(backend.writes.any((w) => w['p_purpose'] == 'ops_vault_access'), isFalse);
  });

  testWidgets('read error retries without granting anything', (tester) async {
    final backend = ConsentBackend()..readError = const RpcException('', 'offline');
    await openConsents(tester, backend);
    expect(byKey('consent-retry'), findsOneWidget);
    backend.readError = null;
    await tapVisible(tester, byKey('consent-retry'));
    expect(byKey('switch-trips'), findsOneWidget);
    expect(backend.writes, isEmpty);
  });

  testWidgets('failed reconciliation blocks edits and save until reload succeeds', (tester) async {
    final backend = ConsentBackend()..failReload = true;
    await openConsents(tester, backend);
    await tapVisible(tester, byKey('switch-ops_vault_access'));
    await tapVisible(tester, byKey('save-consents'));
    expect(tester.widget<FilledButton>(byKey('save-consents')).onPressed, isNull);
    expect(tester.widget<Switch>(byKey('switch-trips')).onChanged, isNull);
    backend.failReload = false;
    await tapVisible(tester, byKey('consent-retry'));
    expect(backend.writes, hasLength(1));
  });

  testWidgets('server permission refusal overrides stale owner UI; non-owners cannot edit', (tester) async {
    final backend = ConsentBackend();
    await openConsents(tester, backend);
    await tapVisible(tester, byKey('switch-ops_vault_access'));
    backend.level = AccessLevel.viewer;
    await tapVisible(tester, byKey('save-consents'));
    expect(find.byType(Switch), findsNothing);
    expect(byKey('consent-owner-only'), findsOneWidget);
    expect(backend.consentState[ConsentPurpose.opsVaultAccess], isFalse);
  });
}
