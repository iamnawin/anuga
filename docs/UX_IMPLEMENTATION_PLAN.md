# AnugaCare — Complete UI/UX Modernization Implementation Plan (`UX_IMPLEMENTATION_PLAN.md`)

**Created:** 2026-11-09 15:12 IST (Asia/Kolkata)
**Last Updated:** 2026-11-09 17:00 IST (Asia/Kolkata)
**Lead Owner:** Gemini (Antigravity — Lead UI/UX Engineer)
**Branch:** `feat/anugacare-ui-modernization` (isolated worktree at `D:\AI-Workspace\Ideas\Anuga`, branched from `origin/main` `ea6d142`)
**Concurrent Codex Stream:** `feat/g7-ui-staging` (PR #28, head `7fa7cb2` / `e80ffd0` in `D:\AI-Workspace\Repos\anuga-trips-fix`)

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
| **WP-0: Multi-Agent Handoff Policy, UX Audit Register & Plan** | Establish permanent multi-agent handoff rules in `AGENTS.md`, create `docs/UX_AUDIT.md` and `docs/UX_IMPLEMENTATION_PLAN.md`, and update `HANDOFF.md`, `TASKS.md`, `EXECUTION_STATE.md`, `PROGRESS_LEDGER.md`, and `README.md`. Commit and push to `feat/anugacare-ui-modernization` before UI edits. | Governance + `UX-01`–`UX-08` registration | `Tested` (`In PR`) | Commit `71fb555` pushed to `origin/feat/anugacare-ui-modernization` |
| **WP-1: Shared Visual System & Reusable UI Components** | Upgrade visual design system in `apps/family_app/lib/src/screens/care_ui.dart`: refined `CarePanel`, bold `CareHeading`, high-contrast `CareEmergencyBanner` (`Call 108`), and 9-stage `_VisitProgressStrip` (`Key('visit-progress')`, `Key('visit-progress-stage-$i')`, `Key('visit-progress-current-$i')`) compatible with Codex PR #28. | `UX-08` (foundation), Section 3 & 6 visual system | `Tested` (`In PR`) | `flutter analyze --fatal-infos` (0 issues), `family_app` 58/58 pass |
| **WP-2: Entry/Authentication & Family Experience Modernization** | Modernize `anugacare_app` (`LoginScreen`, `AccountStatusScreen`) and `family_app` (`HomeScreen`, `BookingsTab`, `CareRequestScreen`, `TripScreen`):<br>- Compact patient summary header in `HomeScreen` and cohesive card hierarchy in `BookingsTab` (`UX-01`)<br>- Preserve authorized `_booking` / `_events` on transient/step action errors while clearing immediately on `isNotAllowed` or refresh failure (`UX-02`)<br>- Persist active pickup OTP inline in ephemeral widget memory (`Key('active-pickup-code-card')`) after closing dialog (`UX-03`)<br>- Structured patient/centre/review panels on `CareRequestScreen` (`UX-05`) | `UX-01`, `UX-02`, `UX-03`, `UX-05`, `UX-08` | `Tested` (`In PR`) | `anugacare_app` 39/39 pass; `family_app` 58/58 pass (`visit_progress_test.dart`, `trip_screen_test.dart`, `care_request_test.dart`) |
| **WP-3: Patient-Access & Companion Experience Modernization** | Modernize `companion_app` (`TripsScreen`, `TripScreen`):<br>- Visually separate primary forward action (`FilledButton`) from secondary exception actions (`action-noShow`, `action-reportIssue`) with a dedicated section divider while preserving backend/test eligibility (`UX-04`)<br>- Preserve authorized `_trip` state on transient/step action errors while clearing on `isNotAllowed` or refresh failure (`UX-02`)<br>- Add 9-stage `_VisitProgressStrip` (`Key('visit-progress')`) matching PR #28 (`UX-08`) | `UX-02`, `UX-03`, `UX-04`, `UX-08` | `Tested` (`In PR`) | `companion_app` `flutter analyze --fatal-infos` (0 issues), 58/58 widget tests pass |
| **WP-4: Ops Console Modernization** | Modernize `apps/ops_console` (`src/app/globals.css`, `src/app/exceptions/page.tsx`) without touching `src/lib/**`:<br>- Add high-contrast severity left-border indicators on `.card-issue_reported` and `.card-late`, refined card/table elevation and alert borders (`UX-07`)<br>- Fix React effect ref cleanup warning in `exceptions/page.tsx` so `pnpm lint` runs with 0 warnings | `UX-07` | `Tested` (`In PR`) | `ops_console`: `pnpm lint` (0 warnings), `pnpm typecheck`, `pnpm test` (70/70 pass), `pnpm build` (9/9 static routes) |
| **WP-5: Localization (`EN` / `TE` / `HI`), Responsive Layout & Accessibility** | Update `app_te.arb` and `app_hi.arb` across `family_app` and `companion_app`:<br>- Replace phonetic Telugu/Hindi `"Ops"` (`ఆప్స్` / `ऑप्स`) with natural team phrasing (`మా బృందం` / `हमारी टीम` / `ఆపరేషన్స్ బృందం` / `ऑपरेशंस टीम`) and standardize Telugu `"Companion"` to gender-neutral respectful `సహచరులు` (`UX-06`, flagged for human `QA-002` review)<br>- Regenerate localizations and verify narrow-phone `200%` text scaling across `en`, `te`, `hi` | `UX-06`, `UX-08` | `Tested` (`In PR`, human `QA-002` pending) | `l10n_test.dart`, `issue_updates_test.dart`, `care_request_test.dart`, `issue_waiting_test.dart`, `mobile_readiness_test.dart` all pass |
| **WP-6: Integration Regression, PR #28 Compatibility & GitHub Delivery** | Run full check-all verification (`pnpm db:test` 209/209, `pnpm typecheck`, `ops_console` 70/70, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39), update `UX_AUDIT.md`, `UX_IMPLEMENTATION_PLAN.md`, `HANDOFF.md`, `TASKS.md`, `EXECUTION_STATE.md`, and `PROGRESS_LEDGER.md`, push `feat/anugacare-ui-modernization`, and open the PR. | All (`UX-01`–`UX-08`) | `Tested` (`In PR`) | All 463 automated tests across DB, Ops, Shared Dart, and 3 Flutter apps pass |

---

## 3. Non-Negotiable Engineering Boundaries

1. **Git & Worktree Isolation:** All work stays in `D:\AI-Workspace\Ideas\Anuga` on branch `feat/anugacare-ui-modernization`. Never touch Codex's worktree (`D:\AI-Workspace\Repos\anuga-trips-fix`), branch `feat/g7-ui-staging`, or PR #28.
2. **Backend Contract Preservation:** Zero edits to `supabase/migrations/`, RLS policies, SQL functions, `packages/shared_dart` RPC contracts, or `apps/ops_console/src/lib/**`.
3. **No Fabricated Capabilities:** No fake live GPS maps, route ETAs, clinical checklists, or unbuilt payment gateways.
4. **PR #28 Progress-Strip Compatibility:** Use the exact same widget keys (`Key('visit-progress')`, `Key('visit-progress-stage-$index')`, `Key('visit-progress-current-$index')`) and persisted 9-stage status mapping (`_visitProgressStatuses` / `_progressStatus`) introduced in PR #28 (`0644dd9` and `8eb152e`) so that rebasing/merging with PR #28 is seamless and conflict-free.
