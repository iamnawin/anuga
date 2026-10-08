import 'package:family_app/src/screens/consent_screen.dart';
import 'package:family_app/src/screens/record_screen.dart';
import 'package:family_app/src/screens/records_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

Map<String, Object?> doc(String id, {String status = 'uploaded', String type = 'image/png'}) => {
  'id': id,
  'patient_id': 'p1',
  'doc_type': 'lab_report',
  'title': 'Monthly labs (synthetic)',
  'storage_path': 'p1/$id.png',
  'uploaded_by': 'owner',
  'created_at': '2026-10-08T06:00:00+00:00',
  'status': status,
  'content_type': type,
  'size_bytes': 2048,
};

Future<({FakeFamilyBackend backend, FakeVaultFiles files, FakePhotoSource photos})> pumpRecords(
  WidgetTester tester,
  AccessLevel level, {
  bool vaultConsent = true,
  List<Map<String, Object?>> docs = const [],
}) async {
  final backend = FakeFamilyBackend(level: level);
  backend.consentState[ConsentPurpose.vault] = vaultConsent;
  backend.documents.addAll(docs);
  final files = FakeVaultFiles(backend);
  final photos = FakePhotoSource();
  final patient = (await backend.api.myPatients()).single;
  await pumpLocalized(
    tester,
    Scaffold(
      body: RecordsTab(api: backend.api, files: files, photos: photos, patient: patient),
    ),
  );
  return (backend: backend, files: files, photos: photos);
}

void main() {
  group('records tab', () {
    for (final (level, canAdd) in [
      (AccessLevel.owner, true),
      (AccessLevel.editor, true),
      (AccessLevel.patient, false),
      (AccessLevel.viewer, false),
    ]) {
      testWidgets('${level.dbValue} with consent: sees reports, add button $canAdd', (tester) async {
        await pumpRecords(tester, level, docs: [doc('d1')]);
        expect(byKey('record-d1'), findsOneWidget);
        expect(byKey('add-record'), canAdd ? findsOneWidget : findsNothing);
      });
    }

    testWidgets('without the records consent nobody can add; the owner is pointed to the consent screen', (
      tester,
    ) async {
      await pumpRecords(tester, AccessLevel.owner, vaultConsent: false);
      expect(byKey('add-record'), findsNothing);
      expect(find.textContaining('Turn on the records consent'), findsOneWidget);
      await tapVisible(tester, byKey('open-consent'));
      expect(find.byType(ConsentScreen), findsOneWidget);
    });

    testWidgets('a viewer without consent is told only the owner can turn records on', (tester) async {
      await pumpRecords(tester, AccessLevel.viewer, vaultConsent: false);
      expect(find.textContaining('Only the owner can turn them on'), findsOneWidget);
      expect(byKey('open-consent'), findsNothing);
    });

    testWidgets('owner adds a report photo: start, put, confirm, then the list shows it', (tester) async {
      final r = await pumpRecords(tester, AccessLevel.owner);
      await tapVisible(tester, byKey('add-record'));
      await tapVisible(tester, find.text('Take a photo'));
      // The name is required.
      await tapVisible(tester, find.text('Upload'));
      expect(find.text('Give the report a name.'), findsOneWidget);
      await tester.enterText(byKey('record-title'), 'Prescription Oct (synthetic)');
      await tapVisible(tester, byKey('record-type'));
      await tapVisible(tester, find.text('Prescription').last);
      await tapVisible(tester, find.text('Upload'));

      expect(r.photos.requests, [true]);
      expect(r.files.calls, [
        'start:prescription:Prescription Oct (synthetic):image/jpeg:2048',
        'put:/storage/v1/object/upload/sign/vault/doc-1:2048',
        'confirm:doc-1',
      ]);
      expect(find.text('Report added.'), findsOneWidget);
      expect(byKey('record-doc-1'), findsOneWidget);
      expect(find.textContaining('Upload not finished'), findsNothing);
    });

    testWidgets('an unfinished upload is shown as such and cannot be opened', (tester) async {
      await pumpRecords(tester, AccessLevel.owner, docs: [doc('d2', status: 'pending_upload')]);
      expect(find.textContaining('Upload not finished'), findsOneWidget);
      await tapVisible(tester, byKey('record-d2'));
      expect(find.byType(RecordScreen), findsNothing);
    });
  });

  group('record screen', () {
    testWidgets('an image is shown through a fresh signed URL', (tester) async {
      final backend = FakeFamilyBackend();
      final files = FakeVaultFiles(backend);
      await pumpLocalized(tester, RecordScreen(files: files, document: VaultDocument.fromJson(doc('d1'))));
      expect(files.calls, ['download:d1']);
      final image = tester.widget<Image>(byKey('record-image'));
      expect((image.image as NetworkImage).url, contains('/object/sign/vault/d1?token='));
    });

    testWidgets('a PDF is not fetched (no viewer yet)', (tester) async {
      final files = FakeVaultFiles(FakeFamilyBackend());
      await pumpLocalized(
        tester,
        RecordScreen(
          files: files,
          document: VaultDocument.fromJson(doc('d3', type: 'application/pdf')),
        ),
      );
      expect(byKey('pdf-note'), findsOneWidget);
      expect(files.calls, isEmpty);
    });
  });

  group('consent screen', () {
    Future<FakeFamilyBackend> pumpConsents(WidgetTester tester, AccessLevel level) async {
      final backend = FakeFamilyBackend(level: level);
      final patient = (await backend.api.myPatients()).single;
      await pumpLocalized(tester, ConsentScreen(api: backend.api, patient: patient));
      return backend;
    }

    testWidgets('owner sees one switch per purpose; withdrawing asks first', (tester) async {
      final backend = await pumpConsents(tester, AccessLevel.owner);
      for (final p in ConsentPurpose.values) {
        expect(byKey('switch-${p.dbValue}'), findsOneWidget);
      }
      await tapVisible(tester, byKey('switch-vault'));
      expect(find.textContaining('Records already saved are kept'), findsOneWidget);
      await tapVisible(tester, find.text('Keep visit'));
      expect(backend.consentState[ConsentPurpose.vault], isTrue);

      await tapVisible(tester, byKey('switch-vault'));
      await tapVisible(tester, find.text('Turn off'));
      expect(backend.consentState[ConsentPurpose.vault], isFalse);
      expect(tester.widget<Switch>(byKey('switch-vault')).value, isFalse);

      // Giving consent needs no confirmation: one tap, as easy as withdrawing.
      await tapVisible(tester, byKey('switch-ops_vault_access'));
      expect(backend.consentState[ConsentPurpose.opsVaultAccess], isTrue);
    });

    testWidgets('non-owners see the status but no switches', (tester) async {
      await pumpConsents(tester, AccessLevel.viewer);
      expect(find.byType(Switch), findsNothing);
      expect(byKey('consent-owner-only'), findsOneWidget);
      expect(tester.widget<Text>(byKey('status-vault')).data, 'On');
      expect(tester.widget<Text>(byKey('status-ops_vault_access')).data, 'Off');
    });
  });
}
