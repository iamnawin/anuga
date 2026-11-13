/// Versioned legal text shown in the app.
///
/// A document is a draft until a lawyer's written approval is recorded in
/// source through [LegalDocument.approved]. Only [canRequestAcceptance] may
/// gate an acceptance flow; a draft can be read but never accepted.
enum LegalDocumentKind { privacyNotice, termsOfService }

enum LegalDocumentStatus { draft, approved }

class LegalSection {
  const LegalSection(this.heading, this.paragraphs);
  final String heading;
  final List<String> paragraphs;
}

class LegalDocument {
  const LegalDocument.draft({required this.kind, required this.version, required this.sections})
    : status = LegalDocumentStatus.draft,
      approvalReference = null,
      effectiveDate = null;

  /// [approvalReference] names the lawyer's written sign-off (for example the
  /// path of the signed letter under `docs/legal/`). [effectiveDate] is ISO 8601.
  const LegalDocument.approved({
    required this.kind,
    required this.version,
    required this.sections,
    required String this.approvalReference,
    required String this.effectiveDate,
  }) : status = LegalDocumentStatus.approved;

  final LegalDocumentKind kind;
  final String version;
  final LegalDocumentStatus status;
  final String? approvalReference;
  final String? effectiveDate;
  final List<LegalSection> sections;

  /// Blanks are written as `[To be confirmed: ...]`.
  bool get hasPlaceholders => sections.any((s) => s.heading.contains('[') || s.paragraphs.any((p) => p.contains('[')));

  /// True only for approved text with a recorded sign-off, a date and no blanks.
  bool get canRequestAcceptance =>
      status == LegalDocumentStatus.approved &&
      (approvalReference?.trim().isNotEmpty ?? false) &&
      (effectiveDate?.trim().isNotEmpty ?? false) &&
      !hasPlaceholders;
}
