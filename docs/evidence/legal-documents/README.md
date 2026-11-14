# Legal documents (draft preview): evidence

Agent: Claude Code. Task: LEGAL-DOCS-1. Branch `feat/legal-documents` from `origin/main` b834b53.
Worktree: `D:\AI-Workspace\Repos\anuga-legal-documents`. Checkpoint: 2026-11-13 19:55 IST.

## What was built

- `apps/family_app/lib/src/legal/legal_document.dart`: versioned document model with a draft/approved status and the `canRequestAcceptance` gate.
- `apps/family_app/lib/src/legal/legal_documents_en.dart`: English draft privacy notice and terms of service, version `0.1-draft`, taken from `docs/legal/lawyer-review-pack.md`. Blanks are kept as `[To be confirmed: ...]`.
- `apps/family_app/lib/src/screens/legal_document_screen.dart`: read-only screen with a pinned draft banner.
- `apps/family_app/lib/src/screens/consent_screen.dart`: two reading links under the introduction. No consent logic changed.
- Seven new strings in English, Telugu and Hindi (screen labels only; the legal text itself is English only).
- `docs/legal/acceptance-evidence.md`: evidence requirements and gaps G1 to G9.

## What was not built

- No terms acceptance flow, no acceptance storage, no migration, no RPC change.
- No Telugu or Hindi legal text.
- No change to authentication, role routing, RLS, consent withdrawal or patient access.
- No link from the unified app's Welcome, More or About screens (those belong to the open screen PRs #36 and #37).

## Checks actually run (local, Windows, Flutter 3.47.6)

| Command | Where | Result |
|---|---|---|
| `flutter analyze --fatal-infos` | `apps/family_app` | No issues |
| `flutter test` | `apps/family_app` | 141 passed, 6 skipped (existing skips), 0 failed (after merging main e8e0063) |
| `flutter analyze --fatal-infos` | `apps/anugacare_app` | No issues |
| `flutter test` | `apps/anugacare_app` | 91 passed, 0 failed (after merging main e8e0063) |
| `flutter test test/support/capture_legal.dart` | `apps/family_app` | 1 passed; wrote the images below |

Not run: `pnpm db:test`, `scripts/check-all.sh`, ops console checks, companion app tests (no SQL, shared Dart, ops or companion source changed). CI: see the pull request.
A first `flutter test` in `apps/anugacare_app` failed to load because the fresh worktree had no generated companion translations; it passed after `flutter pub get` in `apps/companion_app`. That was a setup step, not a code fix.

## Screenshots

Rendered from the real widgets by the test harness at 390 x 844, using a local system font loaded only by the harness. They show the first viewport, not the full page.

| File | Shows |
|---|---|
| `privacy-draft-light.png` | Privacy notice, English, light |
| `privacy-draft-dark.png` | Privacy notice, English, dark |
| `privacy-draft-te.png` | Telugu labels, English legal text, "English only" note |
| `privacy-draft-hi-200pct.png` | Hindi labels at 200% text |
| `terms-draft-light.png`, `terms-draft-light-scrolled.png` | Terms of service; banner stays pinned after scrolling |
| `consent-with-document-links.png` | Consent screen with the two reading links |

## Open items

- Lawyer review of `docs/legal/lawyer-review-pack.md`; founder to fill Part H first.
- Native-speaker review of the seven Telugu and Hindi labels.
- Physical-phone and screen-reader check.
- PR #37 merged to main during this task; main e8e0063 is merged into this branch. Only the four shared handoff documents conflicted (both sides kept).
