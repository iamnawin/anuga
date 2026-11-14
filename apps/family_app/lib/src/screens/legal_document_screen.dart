import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../legal/legal_document.dart';

/// Read-only view of one versioned legal document.
///
/// There is deliberately no accept control here: acceptance is a separate
/// flow that must check [LegalDocument.canRequestAcceptance] first.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.document});
  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final draft = !document.canRequestAcceptance;
    final title = switch (document.kind) {
      LegalDocumentKind.privacyNotice => l10n.legalPrivacyTitle,
      LegalDocumentKind.termsOfService => l10n.legalTermsTitle,
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (draft)
              // Pinned above the text so it stays visible while scrolling.
              Semantics(
                container: true,
                child: Container(
                  key: const Key('legal-draft-banner'),
                  color: scheme.errorContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.edit_document, color: scheme.onErrorContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.legalDraftBanner,
                          style: theme.textTheme.titleMedium?.copyWith(color: scheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(header: true, child: Text(title, style: theme.textTheme.headlineSmall)),
                        const SizedBox(height: 8),
                        Text(l10n.legalVersion(document.version), key: const Key('legal-version')),
                        if (!draft)
                          Text(l10n.legalEffective(document.effectiveDate!), key: const Key('legal-effective')),
                        if (draft) ...[
                          const SizedBox(height: 12),
                          Text(
                            l10n.legalDraftBody,
                            key: const Key('legal-draft-body'),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                        if (Localizations.localeOf(context).languageCode != 'en') ...[
                          const SizedBox(height: 12),
                          Text(l10n.legalEnglishOnly, key: const Key('legal-english-only')),
                        ],
                        for (final section in document.sections) ...[
                          const SizedBox(height: 24),
                          Semantics(header: true, child: Text(section.heading, style: theme.textTheme.titleLarge)),
                          for (final paragraph in section.paragraphs)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              // The legal text itself stays left-to-right English.
                              child: Text(paragraph, style: theme.textTheme.bodyLarge, locale: const Locale('en')),
                            ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
