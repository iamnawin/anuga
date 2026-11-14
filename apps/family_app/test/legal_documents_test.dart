import 'package:family_app/l10n/generated/app_localizations.dart';
import 'package:family_app/src/app.dart';
import 'package:family_app/src/legal/legal_document.dart';
import 'package:family_app/src/legal/legal_documents_en.dart';
import 'package:family_app/src/screens/consent_screen.dart';
import 'package:family_app/src/screens/legal_document_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

const _sections = [
  LegalSection('Heading', ['Complete text.']),
];

LegalDocument _approved({
  String reference = 'docs/legal/signoff.pdf',
  String date = '2027-01-01',
  List<LegalSection> sections = _sections,
}) => LegalDocument.approved(
  kind: LegalDocumentKind.termsOfService,
  version: '1.0',
  sections: sections,
  approvalReference: reference,
  effectiveDate: date,
);

Widget _app(Widget home, {String code = 'en', Brightness brightness = Brightness.light}) => MaterialApp(
  locale: Locale(code),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  theme: familyTheme(brightness),
  builder: largeText,
  home: home,
);

void main() {
  group('acceptance gate', () {
    test('the shipped documents are drafts and cannot request acceptance', () {
      for (final doc in [privacyNoticeEn, termsOfServiceEn]) {
        expect(doc.status, LegalDocumentStatus.draft);
        expect(doc.approvalReference, isNull);
        expect(doc.canRequestAcceptance, isFalse);
        expect(doc.version, contains('draft'));
        expect(doc.sections, isNotEmpty);
      }
    });

    test('approved text with a sign-off, a date and no blanks can request acceptance', () {
      expect(_approved().canRequestAcceptance, isTrue);
    });

    test('approved status alone is not enough', () {
      expect(_approved(reference: ' ').canRequestAcceptance, isFalse);
      expect(_approved(date: '').canRequestAcceptance, isFalse);
      expect(
        _approved(
          sections: const [
            LegalSection('Heading', ['[To be confirmed: refund terms]']),
          ],
        ).canRequestAcceptance,
        isFalse,
      );
    });

    test('a draft with complete text still cannot request acceptance', () {
      const doc = LegalDocument.draft(kind: LegalDocumentKind.privacyNotice, version: '0.9', sections: _sections);
      expect(doc.hasPlaceholders, isFalse);
      expect(doc.canRequestAcceptance, isFalse);
    });
  });

  group('document screen', () {
    for (final doc in [privacyNoticeEn, termsOfServiceEn]) {
      for (final code in ['en', 'te', 'hi']) {
        for (final brightness in Brightness.values) {
          for (final scale in [1.0, 2.0]) {
            testWidgets('${doc.kind.name} $code ${brightness.name} ${scale}x shows the draft warning and no accept', (
              tester,
            ) async {
              tester.view.physicalSize = const Size(360, 780);
              tester.view.devicePixelRatio = 1;
              tester.platformDispatcher.textScaleFactorTestValue = scale;
              addTearDown(tester.view.reset);
              addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
              await tester.pumpWidget(
                _app(
                  LegalDocumentScreen(document: doc),
                  code: code,
                  brightness: brightness,
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              expect(byKey('legal-draft-banner').hitTestable(), findsOneWidget);
              expect(byKey('legal-draft-body'), findsOneWidget);
              expect(
                find.text(AppLocalizations.of(tester.element(byKey('legal-version'))).legalVersion(doc.version)),
                findsOneWidget,
              );
              expect(byKey('legal-english-only'), code == 'en' ? findsNothing : findsOneWidget);
              // Nothing on the page can record agreement.
              expect(find.byType(Checkbox), findsNothing);
              expect(find.byType(Switch), findsNothing);
              expect(find.byType(FilledButton), findsNothing);
              expect(find.byType(ElevatedButton), findsNothing);
              expect(find.byType(OutlinedButton), findsNothing);
              // The banner stays pinned while the text scrolls to its end.
              await tester.scrollUntilVisible(find.text(doc.sections.last.heading), 400);
              expect(byKey('legal-draft-banner').hitTestable(), findsOneWidget);
              expect(tester.takeException(), isNull);
            });
          }
        }
      }
    }

    testWidgets('approved text shows its date and no draft warning', (tester) async {
      await pumpLocalized(tester, LegalDocumentScreen(document: _approved()));
      expect(byKey('legal-draft-banner'), findsNothing);
      expect(byKey('legal-draft-body'), findsNothing);
      expect(byKey('legal-effective'), findsOneWidget);
    });

    testWidgets('approved status without a recorded sign-off is still shown as a draft', (tester) async {
      await pumpLocalized(tester, LegalDocumentScreen(document: _approved(reference: '')));
      expect(byKey('legal-draft-banner'), findsOneWidget);
      expect(byKey('legal-effective'), findsNothing);
    });
  });

  group('consent screen links', () {
    for (final (key, heading) in [('open-privacy-notice', 'Who we are'), ('open-terms', '1. Who we are')]) {
      testWidgets('$key opens the draft for reading and changes no consent', (tester) async {
        final backend = FakeFamilyBackend();
        final patient = (await backend.api.myPatients()).single;
        final before = Map.of(backend.consentState);
        await pumpLocalized(tester, ConsentScreen(api: backend.api, patient: patient));
        await tapVisible(tester, byKey(key));
        expect(byKey('legal-draft-banner'), findsOneWidget);
        expect(find.text(heading), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(byKey('save-consents'), findsOneWidget);
        expect(backend.calls, isNot(contains('set_consent')));
        expect(backend.consentState, before);
      });
    }
  });
}
