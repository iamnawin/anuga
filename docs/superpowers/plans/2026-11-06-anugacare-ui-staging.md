# AnugaCare UI Staging Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the integrated AnugaCare journey easier to read on a phone, preserve the supplied design references, and deliver evidence-backed synthetic staging without adding unsupported capabilities.

**Architecture:** Keep the existing unified Flutter shell and the Family/Companion packages. Add presentation-only lifecycle progress derived from existing `TripStatus` and persisted Family events; do not change APIs, RPCs, migrations or action availability. Keep release, PWA and hosted verification as separate evidence tasks.

**Tech Stack:** Flutter 3.47.6, Dart 3.13.5, Material 3, existing Flutter localization, Next.js Ops console, Supabase/Postgres, Playwright, GitHub Actions.

**Spec:** `docs/design/g7-ui-staging-design.md`

## Global Constraints

- Preserve all RLS, consent, OTP, private-note, session and occupancy enforcement.
- No new dependencies, maps, live GPS/ETA, clinical checklists, independent Patient role or provider activation.
- Enabled controls must map to an existing backend action; exact status text remains visible.
- New English strings require Telugu/Hindi parity; prefer existing localized status strings.
- Minimum 48-pixel targets, 200% text support and no fixed-height translated content.
- Concept boards are references; actual screenshots name the source commit/run/environment.

## Review Focus

- `issue_reported` after pickup: retain the last persisted non-issue progress stage without exposing the private note.
- cancelled/no-show: hide linear progress so terminal exceptions are not presented as completed journey stages.
- failed/denied refresh: remove all stale progress along with stale details/actions.
- narrow EN/TE/HI at 200% text: progress must not overflow or clip surrounding controls.
- resumed/reloaded visit: progress must derive from the newly persisted status/events, not cached UI state.

---

### Task 1: Preserve and qualify the new design inputs

**Files:**
- Add: `docs/design/AnugaCare concept family journey 2026-11-06.png`
- Add: `docs/design/AnugaCare concept patient journey 2026-11-06.png`
- Add: `docs/design/AnugaCare concept companion journey 2026-11-06.png`
- Modify: `docs/design/tokens.md`
- Add: `docs/design/g7-ui-staging-design.md`
- Add: `apps/anugacare_app/PRODUCT.md`
- Add: `apps/anugacare_app/DESIGN.md`

**Interfaces:**
- Consumes: founder concept boards and existing `docs/PRODUCT_SPEC.md`/token contract.
- Produces: explicit supported/deferred mapping used by Tasks 2-5.

- [ ] Verify all three PNGs exist and record SHA-256 hashes.
- [ ] Confirm the contract marks maps/ETA, calls, clinical checklists, recurring controls and expanded Patient access as unsupported unless proven.
- [ ] Run `git diff --check` and commit the qualified design inputs.

### Task 2: Add Family/Patient-view lifecycle progress

**Files:**
- Modify: `apps/family_app/lib/src/screens/trip_screen.dart`
- Test: `apps/family_app/test/visit_progress_test.dart`

**Interfaces:**
- Consumes: `FamilyBoardRow.status`, `List<TripEvent>`, existing localized `statusLabel`.
- Produces: private `_VisitProgressStrip` and `_progressStatus(TripStatus, List<TripEvent>?)` presentation helpers.

- [ ] Add failing tests that require nine progress segments for a normal visit, use the last non-issue event during `issue_reported`, hide the strip after cancelled/no-show, clear it on denied refresh, and render at 320 pixels/200% EN/TE/HI without exceptions.
- [ ] Run `flutter test test/visit_progress_test.dart` in `apps/family_app`; expect the new assertions to fail.
- [ ] Implement a nine-segment `ExcludeSemantics` strip below the exact status chip. Completed/current segments use the existing primary color; future segments use `outlineVariant`; no new strings or actions.
- [ ] Rerun the focused test; expect all cases to pass.
- [ ] Commit Family/Patient-view progress independently.

### Task 3: Add Companion lifecycle progress

**Files:**
- Modify: `apps/companion_app/lib/src/screens/trip_screen.dart`
- Test: `apps/companion_app/test/trip_screen_test.dart`
- Test: `apps/companion_app/test/visit_refresh_test.dart`

**Interfaces:**
- Consumes: current `TripStatus` and existing exact status label.
- Produces: private `_VisitProgressStrip` using the same nine-state order as Task 2.

- [ ] Add failing tests for scheduled, handed-over and completed segment state; hide on issue/cancelled/no-show; clear on denied/reassigned refresh; render at narrow 200% text.
- [ ] Run the two focused Companion test files; expect the new assertions to fail.
- [ ] Implement the presentation-only strip inside the existing status panel without changing action keys, prerequisites or RPC calls.
- [ ] Rerun focused tests; expect all cases to pass.
- [ ] Commit Companion progress independently.

### Task 4: Reverify role UI, navigation and PWA boundaries

**Files:**
- Add: `docs/evidence/g7-ui-staging-2026-11-06/README.md`
- Add: actual source-labeled screenshots under `docs/screenshots/g7/`
- Modify: `docs/PROGRESS_LEDGER.md`
- Modify: `docs/EXECUTION_STATE.md`

**Interfaces:**
- Consumes: CI artifacts, built unified web app, manifests/icons and prior PWA evidence.
- Produces: visual defect inventory, screenshot manifest and honest navigation/PWA verdict.

- [ ] Run Family, Companion and unified app format/analyze/tests, then `scripts/check-all.sh`.
- [ ] Build the unified web/PWA and Android debug artifact using existing scripts/workflows.
- [ ] Capture actual mobile/desktop screens for login, Family request/progress/completion, Companion assignment/progress/completion and Ops assignment/exception states.
- [ ] Inspect clipping, CTA reachability, horizontal overflow, role routing, refresh/reopen, offline/retry and logout/account switching.
- [ ] Record that no map/navigation action is shipped because no direct dependency/configured provider/authorized route data exists.
- [ ] Commit only evidence that names its source commit and environment.

### Task 5: Release PR, hosted prerequisites and synthetic staging

**Files:**
- Modify: `docs/EXECUTION_STATE.md`
- Modify: `docs/PROGRESS_LEDGER.md`
- Modify: `docs/RELEASE_CHECKLIST.md`
- Modify: `docs/HANDOFF.md`
- Modify: `docs/TASKS.md`

**Interfaces:**
- Consumes: verified Tasks 1-4 and main CI.
- Produces: merged release commit, hosted migration/deployment receipt, phone test guide and final staging decision.

- [ ] Push `feat/g7-ui-staging`, open a PR and wait for all seven required jobs.
- [ ] Review the complete diff and merge only if code, tests, screenshots and docs agree.
- [ ] Positively verify the Supabase project is the existing synthetic staging project, inspect hosted migration history and establish a usable recovery path before mutation.
- [ ] Apply only missing ordered migrations, deploy the exact merged main commit with the existing synthetic workflow, and record migration versions/deployment ID/URLs.
- [ ] Run hosted Family/Ops/Companion smoke and full supported journey without real SMS/payment/provider activation.
- [ ] Leave physical Android and Telugu/Hindi human approval as NOT TESTED until signed, then issue the honest final staging verdict.
