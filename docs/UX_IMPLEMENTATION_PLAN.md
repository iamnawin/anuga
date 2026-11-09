# AnugaCare â€” Complete UI/UX Modernization Implementation Plan (`UX_IMPLEMENTATION_PLAN.md`)

**Created:** 2026-11-09 15:12 IST (Asia/Kolkata)
**Lead Owner:** Gemini (Antigravity â€” Lead UI/UX Engineer)
**Branch:** `feat/anugacare-ui-modernization` (isolated worktree at `D:\AI-Workspace\Ideas\Anuga`, branched from `origin/main` `ea6d142`)
**Concurrent Codex Stream:** `feat/g7-ui-staging` (PR #28, head `7fa7cb2` / `e80ffd0` in `D:\AI-Workspace\Repos\anuga-trips-fix`)

---

## 1. Lifecycle State Definitions

Every work package (`WP`) and UX finding (`UX-01`â€“`UX-08`) is tracked using these non-interchangeable states:
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
| **WP-0: Multi-Agent Handoff Policy, UX Audit Register & Plan** | Establish permanent multi-agent handoff rules in `AGENTS.md`, create `docs/UX_AUDIT.md` and `docs/UX_IMPLEMENTATION_PLAN.md`, and update `HANDOFF.md`, `TASKS.md`, `EXECUTION_STATE.md`, `PROGRESS_LEDGER.md`, and `README.md`. Commit and push to `feat/anugacare-ui-modernization` before UI edits. | Governance + `UX-01`â€“`UX-08` registration | `In progress` | Pending Batch 0 commit |
| **WP-1: Shared Visual System & Reusable UI Components** | Upgrade visual design system in `apps/family_app/lib/src/screens/care_ui.dart`, `apps/family_app/lib/src/app.dart`, `apps/companion_app/lib/src/app.dart`, and `apps/anugacare_app/lib/src/app.dart`: refined teal/mint/navy palette (`#00666B`, `#F7FBFA`, `#EAF7F4`, `#10243A`), cohesive card elevation/borders, status pills with icons, emergency banner component, section headers, and 9-stage progress indicator styling compatible with PR #28 (`Key('visit-progress')`). | `UX-08` (foundation), Section 3 & 6 visual system | `Not started` | Pending Batch 1 |
| **WP-2: Entry/Authentication & Family Experience Modernization** | Modernize `anugacare_app` (`LoginScreen`, `AccountStatusScreen`) and `family_app` (`HomeScreen`, `BookingsTab`, `CareRequestScreen`, `TripScreen`, `ConsentScreen`, `RecordsTab`, `RecordScreen`, `InboxTab`, `BillsTab`):<br>- Fix nested scroll clipping & deduplicate confirmed care-request vs. booking cards (`UX-01`)<br>- Preserve authorized visit screen state on transient action errors while clearing on refresh/access failure (`UX-02`)<br>- Persist active pickup OTP inline in memory on `TripScreen` (`UX-03`)<br>- Add calendar picker trigger to `ConsentScreen` DOB, improve date/time pickers, and style registered centre clearly (`UX-05`) | `UX-01`, `UX-02`, `UX-03`, `UX-05`, `UX-08` | `Not started` | Pending Batch 2 |
| **WP-3: Patient-Access & Companion Experience Modernization** | Modernize patient-level authorized view in `family_app` (`AccessLevel.patient` priority card, large pickup code display, clear emergency/help callouts) and `companion_app` (`LoginScreen`, `TripsScreen`, `TripScreen`, `trip_actions.dart`):<br>- Guard `Patient not available` when `_tooEarlyToStart` is true and visually separate primary forward action from secondary exception actions (`UX-04`)<br>- Preserve authorized `_trip` state on invalid OTP / transient action errors while clearing on refresh/revocation (`UX-02`)<br>- Enhance 9-stage visit progress presentation, OTP verification card, handover/completion notes, and `108` emergency notice (`UX-08`) | `UX-02`, `UX-03`, `UX-04`, `UX-08` | `Not started` | Pending Batch 3 |
| **WP-4: Ops Console Modernization** | Modernize `apps/ops_console` (`src/app/globals.css`, `OpsShell.tsx`, `login/page.tsx`, `schedules/page.tsx`, `trips/page.tsx`, `exceptions/page.tsx`, `billing/page.tsx`, `CreateTrips.tsx`, `ScheduleAssignForm.tsx`, `ReassignTrip.tsx`, `ErrorMessage.tsx`) without touching `src/lib/**`:<br>- Clarify Care Request confirmation vs. schedule companion assignment sequence (`UX-07`)<br>- Add clear status summary pills, exception resolution guidance, and responsive desktop/tablet/mobile cards | `UX-07` | `Not started` | Pending Batch 4 |
| **WP-5: Localization (`EN` / `TE` / `HI`), Responsive Layout & Accessibility** | Update `app_en.arb`, `app_te.arb`, `app_hi.arb` across `anugacare_app`, `family_app`, and `companion_app`:<br>- Replace phonetic Telugu/Hindi `"Ops"` (`à°†à°ªà±à°¸à±` / `à¤‘à¤ªà¥à¤¸`) with natural team phrasing (`à°®à°¾ à°¬à±ƒà°‚à°¦à°‚` / `à¤¹à¤®à¤¾à¤°à¥€ à¤Ÿà¥€à¤®` / `à°•à±‹à°†à°°à±à°¡à°¿à°¨à±‡à°Ÿà°°à±`) and standardize Telugu `"Companion"` to gender-neutral respectful `à°¸à°¹à°šà°°à±à°²à±` (`UX-06`)<br>- Regenerate localizations and verify `360x640` / `430x932` layouts at `1.0x`â€“`1.4x` text scale across `en`, `te`, `hi` | `UX-06`, `UX-08` | `Not started` | Pending Batch 5 |
| **WP-6: Integration Regression, PR #28 Compatibility & GitHub Delivery** | Run full `scripts/check-all.sh` and per-app test suites, add/update widget and UI regression tests for `UX-01`â€“`UX-08`, verify clean reconciliation path with Codex's PR #28 (`_VisitProgressStrip`), update `UX_AUDIT.md`, `HANDOFF.md`, `TASKS.md`, `EXECUTION_STATE.md`, and `PROGRESS_LEDGER.md`, push `feat/anugacare-ui-modernization`, and open/update the PR. | All (`UX-01`â€“`UX-08`) | `Not started` | Pending Batch 6 |

---

## 3. Non-Negotiable Engineering Boundaries

1. **Git & Worktree Isolation:** All work stays in `D:\AI-Workspace\Ideas\Anuga` on branch `feat/anugacare-ui-modernization`. Never touch Codex's worktree (`D:\AI-Workspace\Repos\anuga-trips-fix`), branch `feat/g7-ui-staging`, or PR #28.
2. **Backend Contract Preservation:** Zero edits to `supabase/migrations/`, RLS policies, SQL functions, `packages/shared_dart` RPC contracts, or `apps/ops_console/src/lib/**`.
3. **No Fabricated Capabilities:** No fake live GPS maps, route ETAs, clinical checklists, or unbuilt payment gateways.
4. **PR #28 Progress-Strip Compatibility:** Use the exact same widget keys (`Key('visit-progress')`, `Key('visit-progress-stage-$index')`, `Key('visit-progress-current-$index')`) and persisted 9-stage status mapping (`_visitProgressStatuses` / `_progressStatus`) introduced in PR #28 (`0644dd9` and `8eb152e`) so that rebasing/merging with PR #28 is seamless and conflict-free.

