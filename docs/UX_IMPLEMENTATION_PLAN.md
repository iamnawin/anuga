# AnugaCare — Complete UI/UX Modernization Implementation Plan (`UX_IMPLEMENTATION_PLAN.md`)

### Agent Session - 2026-11-13 20:19:11 IST - FAMILY-V2 group2

**Agent:** Codex; Family/Patient UI implementation and verification.
**Task ID / Name:** FAMILY-V2 / group2.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-family-screens-v2`.
**Branch:** `feat/family-screens-v2`.
**Starting commit:** b834b53fbc19952e86161d3bdb049354dfb78291.
**Current commit:** 4724e39f9fc889d16297f7e70828eb64faff6599; this checkpoint is included in the next task commit.
**PR:** Draft only; see evidence README for current link.
**Scope:** Approved six-group Family screen specification; no Companion/auth/backend changes.
**Completed work / Files changed:** F14/F15/F16 complete: grouped visits/date blocks/history,9steps/stopped banners/route/first-name companion, issued-code lifecycle, current access refresh, cancellation draftretry/private notes.21 focused tests +4 unified visit-action tests. Final check-all PASS DB209/11skip Ops70 shared29 Companion58/3skip Family130/6skip unified95; fatal-info/format pass.24 actual renders (Group1 refreshed). Worker/reviewer authrefresh unavailable; root completed/self-reviewed, no credentials changes. Browser selector/copy updates retain backend assertions. Same draftPR37; nextpush+CI gate beforeGroup3.
**Tests and actual results / CI evidence:** See group ledger in docs/evidence/family-screens-v2/README.md; no unrecorded pass implied.
**Merge status:** Not merged.
**Deployment and migration status:** Not deployed; no migrations or hosted mutations.
**Decisions and assumptions:** Approved url_launcher ^6.3.3 for dialer only. Deferred contracts explicitly listed in evidence.
**Blockers:** Support number, profile/routine/address/latest-history/notification lookup/overdue/upload-limit/legal contracts deferred.
**Uncommitted changes:** Intended group changes before task commit; other worktrees preserved.
**Exact next action:** Complete current group checks/docs/push, verify CI, continue next approved group.
**Next responsible agent:** Codex.

**BACKEND FOLLOW-UP (not implemented here):** Make family_invoices and family_invoice_lines owner-only reads. Add allowed owner and denied editor/viewer/patient database tests, including direct RPC access. Existing SQL still permits editor reads; UI hiding does not change that boundary.


### Agent Session - 2026-11-13 19:57:45 IST - FAMILY-V2 group1-CI-green-group2-start

**Agent:** Codex; Family/Patient UI implementation and verification.
**Task ID / Name:** FAMILY-V2 / group1-CI-green-group2-start.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-family-screens-v2`.
**Branch:** `feat/family-screens-v2`.
**Starting commit:** b834b53fbc19952e86161d3bdb049354dfb78291.
**Current commit:** 4724e39f9fc889d16297f7e70828eb64faff6599; this checkpoint is included in the next task commit.
**PR:** Draft only; see evidence README for current link.
**Scope:** Approved six-group Family screen specification; no Companion/auth/backend changes.
**Completed work / Files changed:** Group1 source4724e39/run43441169469 all7CI SUCCESS, observed2026-11-13 19:56:51IST. Includes real LOCAL Supabase SQL/Edge, both browser/API journeys and cross-app journey. Preview integration skipped; no hosted mutations. Group2 F14/F15/F16 implementation starts only after this gate, same draftPR37. Deferred contracts unchanged.
**Tests and actual results / CI evidence:** See group ledger in docs/evidence/family-screens-v2/README.md; no unrecorded pass implied.
**Merge status:** Not merged.
**Deployment and migration status:** Not deployed; no migrations or hosted mutations.
**Decisions and assumptions:** Approved url_launcher ^6.3.3 for dialer only. Deferred contracts explicitly listed in evidence.
**Blockers:** Support number, profile/routine/address/latest-history/notification lookup/overdue/upload-limit/legal contracts deferred.
**Uncommitted changes:** Intended group changes before task commit; other worktrees preserved.
**Exact next action:** Complete current group checks/docs/push, verify CI, continue next approved group.
**Next responsible agent:** Codex.

**BACKEND FOLLOW-UP (not implemented here):** Make family_invoices and family_invoice_lines owner-only reads. Add allowed owner and denied editor/viewer/patient database tests, including direct RPC access. Existing SQL still permits editor reads; UI hiding does not change that boundary.


### Agent Session - 2026-11-13 19:46:19 IST - FAMILY-V2 group1-CI-tab-semantics

**Agent:** Codex; Family/Patient UI implementation and verification.
**Task ID / Name:** FAMILY-V2 / group1-CI-tab-semantics.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-family-screens-v2`.
**Branch:** `feat/family-screens-v2`.
**Starting commit:** b834b53fbc19952e86161d3bdb049354dfb78291.
**Current commit:** 35a20fc83656489e0468f81946f5027517661dfe; this checkpoint is included in the next task commit.
**PR:** Draft only; see evidence README for current link.
**Scope:** Approved six-group Family screen specification; no Companion/auth/backend changes.
**Completed work / Files changed:** Replacement CI43438812876: sixSUCCESS, supabase-localFAILED on rolebutton Visits selector. Corrected both existing browser journeys to role tab for Visits/More, with4 passing unified semantic-role assertions. Production widgets unchanged. Repeated scripts/check-all.sh ALL CHECKS PASSED (Family109/6skip, unified91). No weakened backend assertions or new skips. Next: replacement CI on this fix, thenGroup2.
**Tests and actual results / CI evidence:** See group ledger in docs/evidence/family-screens-v2/README.md; no unrecorded pass implied.
**Merge status:** Not merged.
**Deployment and migration status:** Not deployed; no migrations or hosted mutations.
**Decisions and assumptions:** Approved url_launcher ^6.3.3 for dialer only. Deferred contracts explicitly listed in evidence.
**Blockers:** Support number, profile/routine/address/latest-history/notification lookup/overdue/upload-limit/legal contracts deferred.
**Uncommitted changes:** Intended group changes before task commit; other worktrees preserved.
**Exact next action:** Complete current group checks/docs/push, verify CI, continue next approved group.
**Next responsible agent:** Codex.

**BACKEND FOLLOW-UP (not implemented here):** Make family_invoices and family_invoice_lines owner-only reads. Add allowed owner and denied editor/viewer/patient database tests, including direct RPC access. Existing SQL still permits editor reads; UI hiding does not change that boundary.


### Agent Session - 2026-11-13 19:31:13 IST - FAMILY-V2 group1-CI-navigation-fix

**Agent:** Codex; Family/Patient UI implementation and verification.
**Task ID / Name:** FAMILY-V2 / group1-CI-navigation-fix.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-family-screens-v2`.
**Branch:** `feat/family-screens-v2`.
**Starting commit:** b834b53fbc19952e86161d3bdb049354dfb78291.
**Current commit:** 5283415bac05ddac8ae5faf001ba46ef2b4efbce; this checkpoint is included in the next task commit.
**PR:** Draft only; see evidence README for current link.
**Scope:** Approved six-group Family screen specification; no Companion/auth/backend changes.
**Completed work / Files changed:** Group1 source5283415 pushed to draftPR37 byiamnawin. CI43437185702: sixSUCCESS, supabase-localFAILED on obsolete Request care landing selector. Adapted only two existing Ops browser-test files for Home->Visits after sign-in/reload and More confirmed signout; retained backend assertions. Playwright discovery2 PASS (not execution), Docker unavailable locally. Repeated scripts/check-all.sh ALL CHECKS PASSED: Family109/6skip, unified91 and unchanged broad counts. Replacement CI pending; do not startGroup2 until corrected.
**Tests and actual results / CI evidence:** See group ledger in docs/evidence/family-screens-v2/README.md; no unrecorded pass implied.
**Merge status:** Not merged.
**Deployment and migration status:** Not deployed; no migrations or hosted mutations.
**Decisions and assumptions:** Approved url_launcher ^6.3.3 for dialer only. Deferred contracts explicitly listed in evidence.
**Blockers:** Support number, profile/routine/address/latest-history/notification lookup/overdue/upload-limit/legal contracts deferred.
**Uncommitted changes:** Intended group changes before task commit; other worktrees preserved.
**Exact next action:** Complete current group checks/docs/push, verify CI, continue next approved group.
**Next responsible agent:** Codex.

**BACKEND FOLLOW-UP (not implemented here):** Make family_invoices and family_invoice_lines owner-only reads. Add allowed owner and denied editor/viewer/patient database tests, including direct RPC access. Existing SQL still permits editor reads; UI hiding does not change that boundary.


### Agent Session - 2026-11-13 19:20:13 IST - FAMILY-V2 group1

**Agent:** Codex; Family/Patient UI implementation and verification.
**Task ID / Name:** FAMILY-V2 / group1.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-family-screens-v2`.
**Branch:** `feat/family-screens-v2`.
**Starting commit:** b834b53fbc19952e86161d3bdb049354dfb78291.
**Current commit:** b834b53fbc19952e86161d3bdb049354dfb78291; this checkpoint is included in the next task commit.
**PR:** Draft only; see evidence README for current link.
**Scope:** Approved six-group Family screen specification; no Companion/auth/backend changes.
**Completed work / Files changed:** F12/F13/F34/F35 and access-specific shell built. Added15 Home regressions and4 unified access/session tests, existing navigation expectations adapted. Final scripts/check-all.sh PASS: DB209/11skip, Ops70, shared29, Companion58/3skip, Family109/6skip, unified91; analyzers/format PASS. Nine actual renders; reviewer findings fixed. Source changes confined to Family UI/l10n and app tests; no app.dart/auth/adapter/Companion source edits.
**Tests and actual results / CI evidence:** See group ledger in docs/evidence/family-screens-v2/README.md; no unrecorded pass implied.
**Merge status:** Not merged.
**Deployment and migration status:** Not deployed; no migrations or hosted mutations.
**Decisions and assumptions:** Approved url_launcher ^6.3.3 for dialer only. Deferred contracts explicitly listed in evidence.
**Blockers:** Support number, profile/routine/address/latest-history/notification lookup/overdue/upload-limit/legal contracts deferred.
**Uncommitted changes:** Intended group changes before task commit; other worktrees preserved.
**Exact next action:** Complete current group checks/docs/push, verify CI, continue next approved group.
**Next responsible agent:** Codex.

**BACKEND FOLLOW-UP (not implemented here):** Make family_invoices and family_invoice_lines owner-only reads. Add allowed owner and denied editor/viewer/patient database tests, including direct RPC access. Existing SQL still permits editor reads; UI hiding does not change that boundary.


### Agent Session - 2026-11-13 19:05:48 IST - FAMILY-V2 startup

**Agent:** Codex; Family/Patient UI implementation and verification.
**Task ID / Name:** FAMILY-V2 / startup.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-family-screens-v2`.
**Branch:** `feat/family-screens-v2`.
**Starting commit:** b834b53fbc19952e86161d3bdb049354dfb78291.
**Current commit:** b834b53fbc19952e86161d3bdb049354dfb78291; this checkpoint is included in the next task commit.
**PR:** Draft only; see evidence README for current link.
**Scope:** Approved six-group Family screen specification; no Companion/auth/backend changes.
**Completed work / Files changed:** Isolated main-based branch created. Baseline flutter test: Family 94 passed/6 existing skips; unified 87 passed. Dependency resolution passed. Specification and four boards inspected; existing adapters retained.
**Tests and actual results / CI evidence:** See group ledger in docs/evidence/family-screens-v2/README.md; no unrecorded pass implied.
**Merge status:** Not merged.
**Deployment and migration status:** Not deployed; no migrations or hosted mutations.
**Decisions and assumptions:** Approved url_launcher ^6.3.3 for dialer only. Deferred contracts explicitly listed in evidence.
**Blockers:** Support number, profile/routine/address/latest-history/notification lookup/overdue/upload-limit/legal contracts deferred.
**Uncommitted changes:** Intended group changes before task commit; other worktrees preserved.
**Exact next action:** Complete current group checks/docs/push, verify CI, continue next approved group.
**Next responsible agent:** Codex.

**BACKEND FOLLOW-UP (not implemented here):** Make family_invoices and family_invoice_lines owner-only reads. Add allowed owner and denied editor/viewer/patient database tests, including direct RPC access. Existing SQL still permits editor reads; UI hiding does not change that boundary.


2026-11-13 14:09:07 IST: founder-approved source integration completed for #29,
#32, #33 and #34, preserving separate merge commits and branch history. Main
d22dc27 exactly matches the final tested UI tree. Source state MERGED; deployment
and physical/native acceptance remain separate/open. No next work package or
hosted release automatically authorized. See HANDOFF for source/CI evidence.


2026-11-13 13:44:37 IST: requested sequence completed locally—Consent verified
and pushed #33 before Welcome began. Welcome separate branch now tested87 and
rendered9configs with reference comparisons. Complete PR receipt then STOP for
Pixel/native-language acceptance; no next feature or merge/deploy authorization.


2026-11-12 19:40:46 IST: founder authorized separate Screen04 then Screen01.
Consent implemented/verified with full fast checks, explicit RPC Save and source
permission tests; code/evidence commit before Welcome. Welcome next on a separate
reviewable change; no merge/deploy. See screenshots/consent-welcome/README.md.


## LOGIN-001 Pixel correction checkpoint — 2026-11-12 17:11:22 IST

Same PR #32; founder-reported dark layout fixed and locally checked (49 tests,
analyze/web build, phone/OTP/menu 360/390 light/dark screenshots). Evidence and
actual Pixel-file limitation recorded in `screenshots/login-review/README.md`.
Next: founder refreshes existing Wi-Fi preview and retests both themes; STOP.
No other work package, merge/deploy or release gate is authorized by this fix.


## LOGIN-001 follow-up checkpoint — 2026-11-12 16:50:49 IST

Codex implemented only unified phone/OTP on `feat/unified-login-review`, isolated
from #28/#29/V2/#30. Reused #29 baseline and approved logo/theme; added persisted
explicit language, compact OTP/IME action and scroll reset. Final unified 45 pass,
full-fast/scoped checks, hosted verification and comparison evidence are in
`screenshots/login-review/README.md`. Founder phone and native-language review
are next; no subsequent work package, merge/deploy or gate closure authorized.


**Created:** 2026-11-09 15:12 IST (Asia/Kolkata)
**Last Updated:** 2026-11-09 19:10 IST (Asia/Kolkata)
**Lead Owner:** Gemini CLI (Lead UI/UX Engineer & Independent Product Analyst)
**Branch:** `feat/anugacare-ui-modernization` (isolated worktree at `D:\AI-Workspace\Ideas\Anuga`, branched from `origin/main` `ea6d142`, [PR #29](https://github.com/iamnawin/anuga/pull/29), head `c4ced74`, CI run `42625907826` 7/7 green)
**Concurrent Codex Stream:** `feat/g7-ui-staging` ([PR #28](https://github.com/iamnawin/anuga/pull/28), head `7fa7cb2` / `e80ffd0` in `D:\AI-Workspace\Repos\anuga-trips-fix`)

---

## 1. Lifecycle State Definitions

Every work package (`WP`) and UX finding (`UX-01`–`UX-08`) is tracked using these non-interchangeable states:
1. **`Not started`**: Planned, no code or doc changes committed yet.
2. **`In progress`**: Active implementation underway in the isolated worktree.
3. **`Implemented`**: Code/documentation changes written and committed on `feat/anugacare-ui-modernization`.
4. **`Tested`**: Local analyzer, lint, typecheck, and widget/unit regression suites executed and passing with recorded evidence.
5. **`In PR`**: Pushed to `origin/feat/anugacare-ui-modernization` and linked in a GitHub Pull Request with CI running/passing.
6. **`Merged`**: Reconciled with `main` (including PR #28) and merged under branch protection.
7. **`Deployed`**: Published to the authorized synthetic staging environment (`anuga.vercel.app`) after hosted migration checks.
8. **`Human approved`**: Verified on physical Android hardware and signed off by named Telugu/Hindi native reviewers (`QA-002`).

---

## 2. Work Package Tracker

| Work Package | Scope & Deliverables | Addresses Findings | Lifecycle Status | Commit / Evidence |
| :--- | :--- | :--- | :---: | :--- |
| **WP-0: Multi-Agent Handoff Policy, UX Audit Register & Plan** | Establish permanent multi-agent handoff rules in `AGENTS.md`, create `docs/UX_AUDIT.md` and `docs/UX_IMPLEMENTATION_PLAN.md`, and update `HANDOFF.md`, `TASKS.md`, `EXECUTION_STATE.md`, `PROGRESS_LEDGER.md`, and `README.md`. Commit and push to `feat/anugacare-ui-modernization` before UI edits. | Governance + `UX-01`–`UX-08` registration | `Tested` (`In PR` #29) | Commit `71fb555` pushed to `origin/feat/anugacare-ui-modernization` |
| **WP-1: Shared Visual System & Reusable UI Components** | Upgrade visual design system in `apps/family_app/lib/src/screens/care_ui.dart`: refined `CarePanel`, bold `CareHeading`, high-contrast `CareEmergencyBanner` (`Call 108`), and 9-stage `_VisitProgressStrip` (`Key('visit-progress')`, `Key('visit-progress-stage-$i')`, `Key('visit-progress-current-$i')`) compatible with Codex PR #28. | `UX-08` (`Partial` — progress strip & banner complete; `tel:` dialer gated) | `Tested` (`In PR` #29) | Commits `d22c39d`, `c4ced74`; CI `42625907826` 7/7 green |
| **WP-2: Entry/Authentication & Family Experience Modernization** | Modernize `anugacare_app` (`LoginScreen`, `AccountStatusScreen`) and `family_app` (`HomeScreen`, `BookingsTab`, `CareRequestScreen`, `TripScreen`):<br>- Compact patient summary header in `HomeScreen` and cohesive card hierarchy with semantic-preserving status pill in `BookingsTab` (`UX-01`)<br>- Preserve authorized `_booking` / `_events` on transient/step action errors while clearing immediately on `isNotAllowed` or refresh failure (`UX-02`)<br>- Persist active pickup OTP inline in ephemeral widget memory (`Key('active-pickup-code-card')`) after closing dialog (`UX-03` in-session)<br>- Structured patient/centre/review panels on `CareRequestScreen` while preserving keyboard text entry for E2E (`UX-05` `Partial`) | `UX-01`, `UX-02`, `UX-03` (`Partial`), `UX-05` (`Partial`), `UX-08` (`Partial`) | `Tested` (`In PR` #29) | Commits `d22c39d`, `c4ced74`; `anugacare_app` 39/39, `family_app` 58/58, Playwright `care_request.spec.ts` & `issue_handling.spec.ts` pass in CI `42625907826` |
| **WP-3: Patient-Access & Companion Experience Modernization** | Modernize `companion_app` (`TripsScreen`, `TripScreen`):<br>- Visually separate primary forward action (`FilledButton`) from secondary exception actions (`action-noShow`, `action-reportIssue`) with a dedicated section divider while preserving backend/test eligibility (`UX-04` `Partial — DEC-02`)<br>- Preserve authorized `_trip` state on transient/step action errors while clearing on `isNotAllowed` or refresh failure (`UX-02`)<br>- Add 9-stage `_VisitProgressStrip` (`Key('visit-progress')`) matching PR #28 (`UX-08`) | `UX-02`, `UX-03` (`Partial`), `UX-04` (`Partial`), `UX-08` (`Partial`) | `Tested` (`In PR` #29) | Commits `d22c39d`, `c4ced74`; `companion_app` 58/58 widget tests + APK build + real-Supabase E2E pass in CI `42625907826` |
| **WP-4: Ops Console Modernization** | Modernize `apps/ops_console` (`src/app/globals.css`, `src/app/exceptions/page.tsx`) without touching `src/lib/**`:<br>- Add high-contrast severity left-border indicators on `.card-issue_reported` and `.card-late`, refined card/table elevation and alert borders (`UX-07` `Partial — DEC-05`)<br>- Fix React effect ref cleanup warning in `exceptions/page.tsx` so `pnpm lint` runs with 0 warnings | `UX-07` (`Partial`) | `Tested` (`In PR` #29) | Commits `d22c39d`, `c4ced74`; `ops_console` 70/70 Vitest + Next.js static export + Playwright E2E pass in CI `42625907826` |
| **WP-5: Localization (`EN` / `TE` / `HI`), Responsive Layout & Accessibility** | Update `app_te.arb` and `app_hi.arb` across `family_app` and `companion_app`:<br>- Replace phonetic Telugu/Hindi `"Ops"` (`ఆప్స్` / `ऑप्स`) with natural team phrasing (`మా బృందం` / `हमारी टीम` / `ఆపరేషన్స్ బృందం` / `ऑपरेशंस टीम`) and standardize Telugu `"Companion"` to gender-neutral respectful `సహచరులు` (`UX-06` `Partial — pending human QA-002`)<br>- Regenerate localizations and verify narrow-phone `200%` text scaling across `en`, `te`, `hi` | `UX-06` (`Partial`), `UX-08` (`Partial`) | `Tested` (`In PR` #29, human `QA-002` pending) | Commits `d22c39d`, `c4ced74`; `l10n_test.dart`, `care_request_test.dart`, `mobile_readiness_test.dart` pass in CI `42625907826` |
| **WP-6: Integration Regression, PR #28 Compatibility & GitHub Delivery** | Run full check-all verification (`pnpm db:test` 209/209, `pnpm typecheck`, `ops_console` 70/70, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39), verify all 7 GitHub Actions CI jobs pass on [PR #29](https://github.com/iamnawin/anuga/pull/29) (`42625907826`), inspect rendered CI screenshots, and prepare Codex PR #28 integration analysis. | All (`UX-01`–`UX-08`) | `Tested` (`In PR` #29 — 7/7 CI green) | Commit `c4ced74`, [PR #29](https://github.com/iamnawin/anuga/pull/29), CI run `42625907826` (all 7 jobs `SUCCESS`) |

---

## 3. Non-Negotiable Engineering Boundaries

1. **Git & Worktree Isolation:** All work stays in `D:\AI-Workspace\Ideas\Anuga` on branch `feat/anugacare-ui-modernization`. Never touch Codex's worktree (`D:\AI-Workspace\Repos\anuga-trips-fix`), branch `feat/g7-ui-staging`, or PR #28.
2. **Backend Contract Preservation:** Zero edits to `supabase/migrations/`, RLS policies, SQL functions, `packages/shared_dart` RPC contracts, or `apps/ops_console/src/lib/**`.
3. **No Fabricated Capabilities:** No fake live GPS maps, route ETAs, clinical checklists, or unbuilt payment gateways.
4. **PR #28 Progress-Strip Compatibility:** Uses the exact same widget keys (`Key('visit-progress')`, `Key('visit-progress-stage-$index')`, `Key('visit-progress-current-$index')`) and persisted 9-stage status mapping (`_visitProgressStatuses` / `_progressStatus`) introduced in PR #28 (`0644dd9` and `8eb152e`).
