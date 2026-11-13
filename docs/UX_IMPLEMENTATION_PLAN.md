# AnugaCare — Complete UI/UX Modernization Implementation Plan (`UX_IMPLEMENTATION_PLAN.md`)

COMP-V2 delivery checkpoint 2026-11-13 15:32:34 IST: foundation committed as
`beddacb2b9a2b609cc35d70a768bfd60233232ff` after planning `2d619e2`.
Final source unified146 tests/analyze PASS; release web rebuild PASS (exit0,
50.1s; existing font warning). Journey source/tests and 21 synthetic PNGs are
being committed next. Draft PR/push pending; no merge/deploy/hosted mutations.


COMP-V2 (2026-11-13 15:31:56 IST): Supported C3-C18 IMPLEMENTED/locally TESTED in
`feat/companion-screens-v2`; C1/C2/C19/C20 and documented missing-contract
portions DEFERRED. Full check-all PASS; final unified146/analyze PASS. Privacy,
EN/TE/HI dark/light/200% and native-handoff-URI checks included; human device/
language acceptance NOT performed. Draft PR pending; no merge/deploy/migration.
Exact commands, screen/reference map and gaps: [receipt](evidence/companion-screens-v2/README.md).
Historical UX/release weights and launch gates are unchanged.


COMP-V2 checkpoint (2026-11-13 15:16 IST): Codex owns isolated
`feat/companion-screens-v2` from main `b834b53` for founder-requested unified
Companion screens. Supported UI in progress; C1/C2/C19/C20 and missing-contract
portions deferred. Plan, reference mapping and actual checks:
[COMP-V2 receipt](evidence/companion-screens-v2/README.md). Draft PR only; no merge,
deploy, hosted migration or production gate closure. Historical entries preserved.


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
