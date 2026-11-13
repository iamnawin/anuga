# AnugaCare — Permanent UX & Accessibility Audit Register (`UX_AUDIT.md`)

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


2026-11-13 14:09:07 IST integration receipt: #29 modernization baseline, #32
unified login, #33 Consent and #34 Welcome are MERGED into main d22dc27 under
founder authorization. Historical implementation entries marked IN PR now have
source merge evidence; unresolved UX decisions, physical/native approval and
deployment states are not closed by merging. Seven source CI successes per PR,
final exact-tree proof and timestamps recorded in screen evidence. No history
erased; no broad UX-01–UX-08 human-approval or production claim.


2026-11-13 13:44:37 IST — Screen01 Welcome locally verified after Screen04 #33.
Original teal-shirt illustration, native Flutter copy/controls, explicit stored
language, both same-login CTAs, valid-session bypass;87 tests including6AA checks
and24 layout combinations PASS. Final real-render comparisons9configs complete.
Unselected languages changed to outlines after visual review and recaptured.
No original UX register finding erased or broadly closed; Pixel/native approval
pending. Source support/policy gaps remain in the combined evidence README.


2026-11-12 19:40:46 IST — Screen04 follow-up: explicit Save/partial recovery,
truthful consent hierarchy and accessible labels implemented on isolated branch
from #32. Family94/full suite and nine real-render configs PASS; physical/native
review pending. Support remains standing, policy URL absent; no unsupported link
or per-request promise. Does not close broader UX-05/production gates. Evidence
and mockup comparison: screenshots/consent-welcome/README.md. Welcome not started.


## LOGIN-001 Pixel regression — 2026-11-12 17:11:22 IST

Founder reported dark logo background/size/gaps and truncated hint. Source
20206f4: widget incorrectly painted mist behind already-transparent PNG. Removed
backing, compacted/spaced original asset, lightened dark wordmark without changing
symbol/accent, shortened three locale hints. 49 tests and 360/390 light/dark real
web evidence PASS; final physical Pixel approval pending on same PR #32.
Source images/proof/comparisons: `screenshots/login-review/README.md` follow-up.
No UX-01–UX-08 closure, source PR change or production gate promotion.


## LOGIN-001 follow-up — Codex, 2026-11-12 16:50:49 IST

Isolated phone/OTP rebuild from #29/d75cf07, without changing UX-01–UX-08 or
Gemini's branch. Latest founder phone image and written compact OTP direction
recorded in `screenshots/login-review/README.md`. Layout, locale persistence,
keyboard action visibility and step scroll reset implemented; final 45 unified
tests and scoped browser evidence pass. Real-font captures/overlay retained.
Awaiting isolated PR/CI and founder phone/native-language acceptance; not merged,
deployed or human-approved. Historical findings below remain intact.


**Created:** 2026-11-09 15:12 IST (Asia/Kolkata)
**Last Updated:** 2026-11-09 19:10 IST (Asia/Kolkata)
**Author / Responsible Agent:** Gemini CLI (Lead UI/UX Engineer & Independent Product Analyst)
**Active Workstream Branch:** `feat/anugacare-ui-modernization` (isolated worktree at `D:\AI-Workspace\Ideas\Anuga`, branched from `origin/main` `ea6d142`, [PR #29](https://github.com/iamnawin/anuga/pull/29), head `c4ced74`, CI run `42625907826` 7/7 green)
**Concurrent Workstream Dependency:** Codex owns `feat/g7-ui-staging` ([PR #28](https://github.com/iamnawin/anuga/pull/28), head `7fa7cb2` / `e80ffd0`) in `D:\AI-Workspace\Repos\anuga-trips-fix` for the nine-segment persisted visit progress strip and synthetic staging validation.

> **Lifecycle Governance Rule:** Findings in this register must never be deleted when UI code changes. Each finding tracks distinct states: `Not started` → `In progress` → `Implemented` → `Tested` → `In PR` → `Merged` → `Deployed` → `Human approved`. A finding is only marked fully resolved when all behavioral and backend requirements are met; styling-only or contract-constrained items are recorded as `Partial` or `Requires Product Decision` with explicit acceptance criteria.

---

## 1. Summary Matrix (`UX-01` through `UX-08`)

| ID | Title | Severity | Role / Screen | Responsible Agent | Status | Target Batch |
| :--- | :--- | :---: | :--- | :--- | :--- | :--- |
| **UX-01** | Remove Family nested scroll clipping and unify booking/request card hierarchy | **High** | Family (`HomeScreen`, `BookingsTab`) | Gemini CLI | `Tested` (`In PR` #29 — header compacted & cards unified; confirmed request row retained per E2E contract `DEC-04`) | Batch 2 (`WP-2`) |
| **UX-02** | Preserve authorized visit details across transient action/network errors | **High** | Family & Companion (`TripScreen`) | Gemini CLI | `Tested` (`In PR` #29 — fully resolved in UI & widget tests) | Batch 2 & 3 (`WP-2`, `WP-3`) |
| **UX-03** | Persist generated Pickup OTP in active in-memory view without leaking to storage/logs | **High** | Family & Patient-Access (`TripScreen`) | Gemini CLI | `Partial — In-Session Resolved / Cross-Reload Requires Product Decision (DEC-01)` (`In PR` #29) | Batch 2 & 3 (`WP-2`, `WP-3`) |
| **UX-04** | Improve Companion action hierarchy and separate primary CTA from exception actions | **High** | Companion (`TripScreen`) | Gemini CLI | `Partial — Requires Product Decision (DEC-02)` (`In PR` #29 — visual separation implemented; `scheduled` no-show eligibility locked by SQL/test contract) | Batch 3 (`WP-3`) |
| **UX-05** | Registered centre presentation and structured Care Request review layout | **Medium** | Family (`CareRequestScreen`, `ConsentScreen`) | Gemini CLI | `Partial` (`In PR` #29 — structured review & centre card implemented; full-field modal picker deferred to preserve keyboard/Playwright E2E text entry) | Batch 2 (`WP-2`) |
| **UX-06** | Customer-facing EN/TE/HI terminology cleanup (remove phonetic "Ops" in TE/HI, standardize Telugu "Companion") | **Medium** | Unified, Family, Companion (`app_te.arb`, `app_hi.arb`) | Gemini CLI | `Partial — Pending Human Native-Speaker Signoff (QA-002)` (`In PR` #29) | Batch 5 (`WP-5`) |
| **UX-07** | Ops Console visual hierarchy, exception border indicators & request confirmation flow | **Medium** | Ops Console (`globals.css`, `exceptions/page.tsx`, `schedules/page.tsx`) | Gemini CLI | `Partial — Requires Product Decision (DEC-05)` (`In PR` #29 — CSS severity hierarchy & lint fix complete; 1-step confirm+assign requires RPC change) | Batch 4 (`WP-4`) |
| **UX-08** | Emergency/contact banner usability, 9-stage progress strip (`Key('visit-progress')`), and Patient-level view polish | **Low–Med** | Family, Patient-Access, Companion (`care_ui.dart`, `HomeScreen`, `TripScreen`) | Gemini CLI | `Partial — Requires Product Decision` (`In PR` #29 — 9-stage progress strip & `108` banner implemented; tappable `tel:` dialer requires dependency/product approval) | Batch 1, 2 & 3 (`WP-1`–`WP-3`) |

---

## 2. Detailed Audit Findings (`UX-01` through `UX-08`)

### UX-01 — Family Home Nested Scroll Clipping & Duplicate Confirmed Request Cards
- **Severity:** High
- **Affected Role & Screen:** Family (`HomeScreen`, `BookingsTab`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/src/screens/home_screen.dart` (`_HomeScreenState.build`)
  - `apps/family_app/lib/src/screens/bookings_tab.dart` (`_BookingsTabState.build`)
- **Observed Behavior & Evidence:**
  1. `HomeScreen` wrapped the patient summary `CarePanel` and optional `patient-picker` inside `ConstrainedBox(constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.35))` with `headlineSmall` text and large padding, causing `"Centre 1"` to clip at `200%` text scaling (`docs/evidence/unified-entry/360-en-light-200pct-family-home.png`).
  2. In `BookingsTab`, care-request cards (`Key('care-request-<scheduleId>')`) and booking cards (`Key('booking-<tripId>')`) had inconsistent styling. Note: Playwright E2E (`apps/ops_console/e2e/care_request.spec.ts:121-126`) requires pending care-request cards to merge their date/time and status text into a single semantic node and confirmed cards to expose a semantic `group` with the `Open visit` button.
- **Impact on Users:**
  - Elderly users and family caregivers at `1.15x`–`2.0x` text scaling experienced a cramped patient summary header and inconsistent card hierarchy.
- **Recommended Solution:**
  1. Compacted the `HomeScreen` patient summary panel (`padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)`, `titleMedium` patient name, `bodyMedium` centre name, `0.38` max-height) so normal and large-text viewports render without clipping.
  2. Unified `BookingsTab` care-request and booking cards with consistent `14px` rounded borders, icons, and a non-semantic-splitting status pill `Container` (`c4ced74`) that preserves Flutter Web semantic merging for Playwright E2E.
- **Security & Privacy Considerations:**
  - Purely presentation/layout over existing `family_care_requests` and `family_trip_board` RPC responses. Preserves patient access filtering and stale-request generation guards (`_loadSeq`).
- **Acceptance Criteria:**
  - *Met in `WP-2` (`c4ced74`):* Compacted patient header and unified card hierarchy pass all 58 `family_app` widget tests, 39 `anugacare_app` tests, and the full real-Supabase Playwright `care_request.spec.ts` / `issue_handling.spec.ts` E2E suite in CI run `42625907826`.
  - *Product Decision (`DEC-04`):* Confirmed care-request cards (`request.tripId != null`) are intentionally retained above the booking list with their `Open visit` button because `care_request_test.dart` and `e2e/care_request.spec.ts` explicitly assert both the confirmed request card and `Open visit` action.
- **Required Regression Tests:**
  - `apps/family_app/test/care_request_test.dart` and `apps/ops_console/e2e/care_request.spec.ts`.
- **Implementation Status:** `Tested` (`In PR` #29)
- **Responsible Agent:** Gemini CLI
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `71fb555`, `d22c39d`, `c4ced74` / [PR #29](https://github.com/iamnawin/anuga/pull/29)
- **Verification Results:** All 7 CI jobs passed in GitHub Actions run `42625907826` (including `family-app`, `anugacare-app`, and `supabase-local` Playwright E2E).
- **Outstanding Decisions:** `DEC-04` (whether to collapse confirmed care-request cards into the scheduled booking list in a future E2E-updated slice).

---

### UX-02 — Preserve Authorized Visit Details After Transient Network / Action Errors
- **Severity:** High
- **Affected Role & Screen:** Family (`TripScreen`) and Companion (`TripScreen`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/src/screens/trip_screen.dart` (`_TripScreenState._run`)
  - `apps/companion_app/lib/src/screens/trip_screen.dart` (`_TripScreenState._run`)
- **Observed Behavior & Evidence:**
  - Previously, `_run()` in Family `TripScreen` unconditionally cleared `_booking = null; _events = null;` on any action error, blanking out the entire visit screen on a transient action failure.
- **Impact on Users:**
  - Hospital basements and dialysis centres in India frequently have spotty mobile data. Wiping the entire visit screen on a failed action stranded the user until they tapped the AppBar refresh icon.
- **Recommended Solution:**
  - Updated `_run()` in both Family and Companion `TripScreen` to distinguish between **authorization revocations (`isNotAllowed` / SQLSTATE `42501`) and refresh failures** (which immediately clear `_booking = null; _events = null; _activePickupCode = null;` / `_trip = null;`) vs. **in-screen action/validation errors** (which keep the authorized visit details on screen alongside the `Key('error')` notice).
- **Security & Privacy Considerations:**
  - Never retains `_booking`, `_events`, `_activePickupCode`, or `_trip` if a refresh/load fails or if an RPC returns `42501` (`isNotAllowed`). All `visit_refresh_test.dart` and `visit_progress_test.dart` denial assertions pass.
- **Acceptance Criteria:**
  - Encountering a non-authorization action error displays `Key('error')` while keeping the visit details and action buttons visible.
  - Refreshing a visit after reassignment, consent withdrawal (`42501`), or read failure clears visit details and `Key('visit-progress')` immediately.
- **Required Regression Tests:**
  - `apps/companion_app/test/trip_screen_test.dart`, `apps/companion_app/test/visit_refresh_test.dart`, `apps/family_app/test/trip_screen_test.dart`, `apps/family_app/test/visit_progress_test.dart`.
- **Implementation Status:** `Tested` (`In PR` #29 — fully resolved in UI & widget tests)
- **Responsible Agent:** Gemini CLI
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `71fb555`, `d22c39d`, `c4ced74` / [PR #29](https://github.com/iamnawin/anuga/pull/29)
- **Verification Results:** All 7 CI jobs passed in GitHub Actions run `42625907826`; local `family_app` (58/58) and `companion_app` (58/58) widget tests pass.
- **Outstanding Decisions:** None.

---

### UX-03 — Ephemeral Pickup OTP Dialog & Doorstep Visibility
- **Severity:** High
- **Affected Role & Screen:** Family & Patient-Access (`TripScreen`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/src/screens/trip_screen.dart` (`_TripScreenState._getPickupCode`, `_activePickupCode`, `Key('active-pickup-code-card')`)
- **Observed Behavior & Evidence:**
  - Tapping `Get pickup code` (`Key('get-pickup-code')`) calls `issuePickupOtp`, which generates a new 6-digit code in PostgreSQL (invalidating any prior code) and opens an `AlertDialog` (`Key('pickup-code')`).
  - Previously, once the user tapped `Close`, the code disappeared from the screen.
- **Impact on Users:**
  - An elderly patient at the doorstep or a family member switching apps to read/send the code easily dismissed the modal; tapping `Get pickup code` a second time invalidated the code they just shared.
- **Recommended Solution:**
  - Hold the most recently generated pickup code in transient widget memory (`String? _activePickupCode` on `_TripScreenState`) immediately after the modal dialog closes (keeping `find.text(code)` unique while the dialog is open for `trip_screen_test.dart`), and render a high-contrast inline **Active Pickup Code card** (`Key('active-pickup-code-card')`) on `TripScreen` while `_canIssueCode` is true.
  - Automatically clear `_activePickupCode = null` whenever `_canIssueCode` becomes false, `_load()` fails, or the widget is disposed.
- **Security & Privacy Considerations:**
  - Never writes the pickup OTP to `localStorage`, `SharedPreferences`, URLs, logs, or persistent state. Across full page reloads, plaintext OTP is not recoverable because PostgreSQL stores only `sha256(salt || code)` (`20261008000300_trip_workflow.sql`).
- **Acceptance Criteria:**
  - *Met in `WP-2`:* Closing the pickup code dialog leaves `Key('active-pickup-code-card')` visible on `TripScreen` during the active screen session while awaiting pickup, and clears it immediately when status advances to `picked_up` or refresh fails.
  - *Remaining for cross-reload persistence (`DEC-01`):* If the founder wants the same plaintext OTP to survive a full browser page reload without re-issuing, a backend schema/RPC change is required.
- **Required Regression Tests:**
  - `apps/family_app/test/trip_screen_test.dart` (`owner gets a pickup code and sees it large, with instructions`).
- **Implementation Status:** `Partial — In-Session Resolved / Cross-Reload Requires Product Decision (DEC-01)` (`In PR` #29)
- **Responsible Agent:** Gemini CLI
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `71fb555`, `d22c39d`, `c4ced74` / [PR #29](https://github.com/iamnawin/anuga/pull/29)
- **Verification Results:** Verified by `apps/family_app/test/trip_screen_test.dart` and CI run `42625907826` (`7/7` green).
- **Outstanding Decisions:** `DEC-01` — Keep one-way hashed OTP in PostgreSQL (current secure design) vs. encrypted server retrieval across page reloads.

---

### UX-04 — Companion Action Hierarchy, Early No-Show Guard & Irreversible Step Confirmation
- **Severity:** High
- **Affected Role & Screen:** Companion (`TripScreen`, `trip_actions.dart`)
- **Exact Source Files & Components:**
  - `apps/companion_app/lib/src/screens/trip_screen.dart`
  - `apps/companion_app/lib/src/trip_actions.dart`
- **Observed Behavior & Evidence:**
  1. Previously, the primary `FilledButton` (`I'm on my way`) was immediately followed by `Patient not available` (`action-noShow`) and `Report an issue` (`action-reportIssue`) with no visual section boundary.
  2. When `_tooEarlyToStart` is true (more than 180 minutes before pickup), `I'm on my way` (`action-companion_en_route`) is disabled, but `Patient not available` (`action-noShow`) remains enabled because both SQL `public.advance_trip` (`20261008000300_trip_workflow.sql`) and `apps/companion_app/test/trip_screen_test.dart:207` (`expect(enabled(tester, 'action-noShow'), isTrue)`) explicitly require `action-noShow` to remain enabled in `scheduled` before the start window.
  3. Tapping `Patient not available` or `Report an issue` opens `_askNote(required: true)` (requiring a non-empty note and `Submit` tap), whereas forward non-note transitions execute on a single tap.
- **Impact on Users:**
  - Without visual separation, Companions assisting a patient one-handed can confuse primary progression with exception actions, and backend rules currently allow `no_show` from `scheduled` before `companion_en_route`.
- **Recommended Solution:**
  1. **Implemented in `WP-3`:** Visually separated the primary forward `FilledButton` from secondary exception `OutlinedButton`s (`action-noShow`, `action-reportIssue`) with a dedicated `Divider(height: 24)` and destructive error-border styling on `action-noShow`.
  2. **Requires Product & Backend Decision (`DEC-02`):** Restricting `no_show` in SQL (`trip_transitions` / `advance_trip`) so it is only allowed after `companion_en_route` and within the pickup window, and updating `apps/companion_app/test/trip_screen_test.dart` accordingly.
- **Security & Privacy Considerations:**
  - Preserves `TripStateMachine`, SQL `trip_transitions`, and all existing `Key('action-...')` identifiers.
- **Acceptance Criteria:**
  - *Met in `WP-3`:* Primary forward action and exception actions (`action-noShow`, `action-reportIssue`) are separated by a visual divider and distinct button hierarchy; all 58/58 `companion_app` widget tests and CI run `42625907826` pass.
  - *Remaining for full closure (`DEC-02`):* Update `supabase/migrations/` (`trip_transitions` / `advance_trip`) and `apps/companion_app/test/trip_screen_test.dart:207` to disallow `no_show` while `status == 'scheduled'` or before `startAllowedAt`, and add an explicit irreversible-warning banner inside the `no_show` note modal.
- **Required Regression Tests:**
  - `apps/companion_app/test/trip_screen_test.dart` (58/58 passing).
- **Implementation Status:** `Partial — Requires Product Decision (DEC-02)` (`In PR` #29)
- **Responsible Agent:** Gemini CLI
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `71fb555`, `d22c39d`, `c4ced74` / [PR #29](https://github.com/iamnawin/anuga/pull/29)
- **Verification Results:** Visual hierarchy and section separation verified in `apps/companion_app/test/trip_screen_test.dart` (58/58 pass) and CI run `42625907826` (`7/7` green). Premature `scheduled` no-show eligibility remains governed by existing SQL and widget test contracts (`DEC-02`).
- **Outstanding Decisions:** `DEC-02` — Founder/backend approval required to remove `scheduled -> no_show` from SQL `trip_transitions` and update `trip_screen_test.dart:207`.

---

### UX-05 — Date/Time Picker Affordances & Read-Only Registered Centre Display
- **Severity:** Medium
- **Affected Role & Screen:** Family (`CareRequestScreen`, `ConsentScreen`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/src/screens/care_request_screen.dart`
  - `apps/family_app/lib/src/screens/consent_screen.dart`
- **Observed Behavior & Evidence:**
  1. On `CareRequestScreen`, `care-date` (`YYYY-MM-DD`) and `care-time` (`HH:mm`) are `TextField`s with trailing `IconButton`s (`Key('care-date-picker')`, `Key('care-time-picker')`).
  2. Both `apps/family_app/test/care_request_test.dart` (`tester.enterText(byKey('care-date'), ...)`) and Playwright E2E (`apps/ops_console/e2e/care_request.spec.ts:95` `enterFlutter(family, 'Pickup date (IST)', day)`) focus the `TextField` directly and type the date/time string via keyboard. Making `onTap` on the `TextField` open a modal `showDatePicker`/`showTimePicker` dialog would block keyboard focus and break automated Playwright and widget tests.
- **Impact on Users:**
  - Caregivers who tap the text body instead of the trailing calendar/clock icon see the keyboard rather than the modal picker.
- **Recommended Solution:**
  1. **Implemented in `WP-2`:** Structured `CareRequestScreen` patient summary card, read-only registered dialysis centre presentation (`Key('care-centre')` with hospital icon and helper explanation), and structured review summary card (`Key('care-review-summary')`).
  2. **Remaining (`Partial`):** Keep `care-date` and `care-time` directly editable for keyboard/E2E compatibility while adding optional quick-select date/time chips or a dedicated picker button row in a future iteration after updating E2E selectors, plus a calendar picker button on `ConsentScreen` (`consent-dob`).
- **Security & Privacy Considerations:**
  - Preserves IST validation (`parseIstPickup`) and registered-centre enforcement in `family_request_care`.
- **Acceptance Criteria:**
  - *Met in `WP-2`:* Structured patient/centre/review cards on `CareRequestScreen` render cleanly at `1.0x` and `2.0x` text scale across `en`, `te`, and `hi`; `care_request_test.dart` and Playwright `care_request.spec.ts` pass in CI run `42625907826`.
  - *Remaining for full closure:* Add non-blocking quick-select date/time chips on `CareRequestScreen` and a date-picker icon button on `ConsentScreen` (`consent-dob`).
- **Required Regression Tests:**
  - `apps/family_app/test/care_request_test.dart` (all 9 tests pass, including 200% text scaling in `en`, `te`, `hi`).
- **Implementation Status:** `Partial` (`In PR` #29)
- **Responsible Agent:** Gemini CLI
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `71fb555`, `d22c39d`, `c4ced74` / [PR #29](https://github.com/iamnawin/anuga/pull/29)
- **Verification Results:** Structured patient, registered centre, and review cards verified by `care_request_test.dart` and CI run `42625907826` (`7/7` green).
- **Outstanding Decisions:** Whether to replace typed IST date/time inputs in E2E specs with modal picker interactions.

---

### UX-06 — Customer-Facing Terminology Across English, Telugu & Hindi
- **Severity:** Medium
- **Affected Role & Screen:** Unified Entry, Family, and Companion (`app_en.arb`, `app_te.arb`, `app_hi.arb`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/l10n/app_te.arb`, `app_hi.arb`
  - `apps/companion_app/lib/l10n/app_te.arb`, `app_hi.arb`
- **Observed Behavior & Evidence:**
  1. Internal term **"Ops"** was phonetically transliterated into Telugu as `ఆప్స్` and into Hindi as `ऑप्स`.
  2. Telugu used masculine singular `సహచరుడు` in `careRequestIntro`, `carePendingExplanation`, and `careConfirmed`.
- **Impact on Users:**
  - Elderly Telugu and Hindi speakers do not understand phonetic `"Ops"`, and `సహచరుడు` misgenders female companions (such as Asha).
- **Recommended Solution:**
  - Replaced phonetic `ఆప్స్` / `ऑप्स` in Telugu and Hindi customer-facing strings with natural team phrases (`మా బృందం` / `हमारी टीम` / `ఆపరేషన్స్ బృందం` / `ऑपरेशंस टीम`), and standardized Telugu `"Companion"` to gender-neutral respectful `సహచరులు` (`WP-5`). Preserved English ARB strings asserted by `care_request_test.dart` and Playwright E2E.
- **Security & Privacy Considerations:**
  - Maintains exact ARB key and placeholder parity across `en`, `te`, and `hi` (`27` unified / `138` Family / `74` Companion keys) and never reintroduces unsupported outbound notification promises.
- **Acceptance Criteria:**
  - *Met in `WP-5`:* `flutter gen-l10n` and `l10n_test.dart` pass across all three Flutter packages with zero missing keys or placeholder mismatches; Telugu and Hindi customer-facing strings no longer use phonetic `ఆప్స్` / `ऑप्स` or masculine singular `సహచరుడు`.
  - *Remaining for full closure (`QA-002`):* Named human Telugu and Hindi native-speaker and healthcare reviewer signoff (`docs/ANDROID_TEST_PLAN.md`).
- **Required Regression Tests:**
  - `apps/family_app/test/l10n_test.dart`, `apps/companion_app/test/l10n_test.dart`, `apps/anugacare_app/test/mobile_readiness_test.dart`.
- **Implementation Status:** `Partial — Pending Human Native-Speaker Signoff (QA-002)` (`In PR` #29)
- **Responsible Agent:** Gemini CLI
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `71fb555`, `d22c39d`, `c4ced74` / [PR #29](https://github.com/iamnawin/anuga/pull/29)
- **Verification Results:** Automated localization parity and narrow-viewport 200% text tests pass across `en`, `te`, and `hi` in CI run `42625907826` (`7/7` green). Human native-speaker meaning review (`QA-002`) remains `Not tested`.
- **Outstanding Decisions:** Named human native-speaker signoff (`QA-002` / `F03`) and `DEC-03` (whether to rename English `"Ops"` in customer-facing English copy and update E2E matchers).

---

### UX-07 — Clarify Ops Request Confirmation, Assignment Sequence & Exception Guidance
- **Severity:** Medium
- **Affected Role & Screen:** Ops Console (`/schedules`, `/trips`, `/exceptions`, `globals.css`)
- **Exact Source Files & Components:**
  - `apps/ops_console/src/app/globals.css`
  - `apps/ops_console/src/app/exceptions/page.tsx`
  - `apps/ops_console/src/app/schedules/page.tsx`
- **Observed Behavior & Evidence:**
  1. On `/schedules`, confirming a pending Family care request (`ops_confirm_care_request`) and assigning companions (`ops_assign_schedule_companions`) are two separate RPC steps enforced by `20261102000100_family_care_requests.sql` and asserted sequentially by `e2e/care_request.spec.ts` (lines 149–175) and `e2e/issue_handling.spec.ts` (lines 107–122).
  2. Exception cards (`issue_reported`, `late`) and data tables needed stronger visual severity hierarchy, and `exceptions/page.tsx` had a React effect ref cleanup lint warning.
- **Impact on Users:**
  - Coordinators benefit from immediate visual severity cues on `/exceptions`, while combining confirmation and companion assignment into a single step requires a backend RPC change.
- **Recommended Solution:**
  1. **Implemented in `WP-4`:** Enhanced card/table elevation, alert borders, and left-border severity indicators (`.card-issue_reported`, `.card-late`) in `apps/ops_console/src/app/globals.css`, and fixed the React effect ref cleanup warning in `apps/ops_console/src/app/exceptions/page.tsx` (`0` lint warnings).
  2. **Requires Product & Backend Decision (`DEC-05`):** Combining `ops_confirm_care_request` and `ops_assign_schedule_companions` into a single atomic confirmation+assignment step on `/schedules` requires a SQL migration and Playwright E2E spec update.
- **Security & Privacy Considerations:**
  - Zero changes to `apps/ops_console/src/lib/**`, auth providers, or RPC payloads.
- **Acceptance Criteria:**
  - *Met in `WP-4`:* Ops Console `pnpm lint` (0 errors, 0 warnings), `pnpm typecheck`, `pnpm test` (70/70 Vitest), `pnpm build` (9/9 static routes), and Playwright E2E pass in CI run `42625907826`.
  - *Remaining for full closure (`DEC-05`):* Add an atomic confirm-and-assign RPC or pre-confirmation companion selector on `/schedules` and update `e2e/care_request.spec.ts`.
- **Required Regression Tests:**
  - `apps/ops_console/test/care_requests.test.tsx`, `test/issue_handling.test.tsx`, `test/components.test.tsx` (70/70 pass).
- **Implementation Status:** `Partial — Requires Product Decision (DEC-05)` (`In PR` #29)
- **Responsible Agent:** Gemini CLI
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `71fb555`, `d22c39d`, `c4ced74` / [PR #29](https://github.com/iamnawin/anuga/pull/29)
- **Verification Results:** `pnpm lint` (0 warnings), `pnpm typecheck`, `pnpm test` (70/70 pass), `pnpm build`, and CI run `42625907826` (`7/7` green) verified.
- **Outstanding Decisions:** `DEC-05` (atomic confirm+assign RPC on `/schedules`) and underway companion takeover RPC (`Recommendation #1`).

---

### UX-08 — Emergency Contact Usability, 9-Stage Progress Strip & Patient-Level View Polish
- **Severity:** Low–Medium
- **Affected Role & Screen:** Family, Patient-Access, and Companion (`HomeScreen`, `TripScreen`, `care_ui.dart`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/src/screens/care_ui.dart`
  - `apps/family_app/lib/src/screens/home_screen.dart`
  - `apps/family_app/lib/src/screens/trip_screen.dart`
  - `apps/companion_app/lib/src/screens/trip_screen.dart`
- **Observed Behavior & Evidence:**
  1. Family and Companion `TripScreen` lacked an at-a-glance visual progress indicator across the 9-state visit lifecycle (`scheduled` through `completed`).
  2. Emergency `108` notices were plain text blocks without high-contrast iconography.
  3. Neither `108` nor Companion `emergencyContacts` launches the native phone dialer (`tel:`) because `url_launcher` is not in `pubspec.yaml` and external call/dialer actions are gated by repository dependency and scope rules (`AGENTS.md`, `EXECUTION_STATE.md`).
- **Impact on Users:**
  - Families and Companions can now see the exact 9-stage persisted journey progress at a glance and spot the high-contrast `108` emergency banner immediately, while tapping a phone number does not yet launch the OS dialer.
- **Recommended Solution:**
  1. **Implemented in `WP-1`–`WP-3`:** Added the 9-stage persisted `_VisitProgressStrip` (`Key('visit-progress')`, `Key('visit-progress-stage-$index')`, `Key('visit-progress-current-$index')`) on both Family and Companion `TripScreen` (matching Codex PR #28 `0644dd9` / `8eb152e` baseline, including preserving the last non-issue stage during `issue_reported` on Family `TripScreen` and hiding linear progress on terminal `issue_reported`/`cancelled`/`no_show` on Companion `TripScreen`), plus the high-contrast `CareEmergencyBanner` (`Key('care-emergency-banner')`).
  2. **Requires Product Decision:** Adding `url_launcher` (or platform `tel:` intent launching) for `108` and emergency contact numbers, and deciding whether `AccessLevel.patient` should hide the `Bills` tab (`tab-bills` is currently asserted in `family_app` access-level matrix tests).
- **Security & Privacy Considerations:**
  - Zero new Patient authentication roles or broadened `AccessLevel.patient` permissions.
- **Acceptance Criteria:**
  - *Met in `WP-1`–`WP-3`:* 9-stage `_VisitProgressStrip` and `CareEmergencyBanner` render without overflow at `360px` width and `200%` text scale across `en`, `te`, and `hi`; all 58 Family and 58 Companion widget tests and CI run `42625907826` (`7/7` green) pass.
  - *Remaining for full closure:* Founder approval to add `url_launcher` for tappable `tel:108` / emergency contact numbers and to adjust `AccessLevel.patient` bottom navigation tabs.
- **Required Regression Tests:**
  - `apps/family_app/test/visit_progress_test.dart`, `apps/companion_app/test/trip_screen_test.dart`, `apps/companion_app/test/visit_refresh_test.dart`.
- **Implementation Status:** `Partial — Requires Product Decision` (`In PR` #29)
- **Responsible Agent:** Gemini CLI
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `71fb555`, `d22c39d`, `c4ced74` / [PR #29](https://github.com/iamnawin/anuga/pull/29)
- **Verification Results:** 9-stage progress strip and `CareEmergencyBanner` verified across `family_app` (58/58), `companion_app` (58/58), and CI run `42625907826` (`7/7` green).
- **Outstanding Decisions:** Product authorization for `url_launcher` (`tel:` links) and `AccessLevel.patient` dedicated mode.

---

## 3. Five Prioritized Post-Staging Product Recommendations

These five product capabilities require backend/SQL, external provider, or founder policy changes and are preserved here as the post-staging roadmap (not fabricated in the frontend UI):

1. **Controlled Underway Companion Takeover (`reassign_active_trip` RPC + Ops Exception Flow)**
   - *Priority:* #1 (Critical Patient Safety & Operational Reliability)
   - *Why:* `ops_assign_trip_companion` currently restricts reassignment to `status = 'scheduled'`. If a companion has a vehicle breakdown or medical emergency mid-visit (`en_route` through `return_en_route`), Ops needs an audited handover transition that assigns the backup companion while preserving completed milestones.
2. **One-Step Ops Request Confirmation with Inline Companion Assignment**
   - *Priority:* #2 (High Operational Reliability)
   - *Why:* Allowing `ops_confirm_care_request` to optionally accept `primary_companion_id` / `backup_companion_id` in a single atomic transaction eliminates the two-step `/schedules` workflow.
3. **Truthful External Navigation Handoff (`NAV-001`) & Tappable `tel:` Dialers**
   - *Priority:* #3 (High Field Usability)
   - *Why:* Launching the device dialer (`tel:`) or an external map intent for the pickup/centre address gives Companions practical field tools without fabricating an in-app GPS tracker or live ETA.
4. **Outbound WhatsApp / SMS Milestone Notifications (Via Approved Provider — `M10`)**
   - *Priority:* #4 (High Pilot Business Value)
   - *Why:* Families rely on push/WhatsApp alerts for pickup, centre handover, and return home rather than manual pull-to-refresh.
5. **Guided Recurrent Dialysis Schedule Change Requests**
   - *Priority:* #5 (Medium Caregiver Convenience)
   - *Why:* Dialysis patients frequently have clinic slot adjustments; a structured request flow reduces manual phone coordination with Ops.

---

## 4. Open Founder / Product Decisions Register

| Decision ID | Question | Current Safe Default in `feat/anugacare-ui-modernization` | Owner |
| :--- | :--- | :--- | :--- |
| **DEC-01** | Should the generated 6-digit Pickup OTP remain visible only in ephemeral in-memory screen state (`_activePickupCode`), or should the backend return an active unconsumed code across full browser reloads? | **Ephemeral in-memory widget state only** (cleared on status advance, refresh failure, or unmount; never persisted to `localStorage` or logs). | Founder / Security |
| **DEC-02** | Should `no_show` (`Patient not available`) in SQL require `companion_en_route` and pickup-window proximity rather than being allowed on `scheduled` visits before `startAllowedAt`? | **Visually separated in UI (`Divider` + destructive border)** while keeping `scheduled` enabled per existing SQL and `trip_screen_test.dart:207` contract. | Founder / Ops |
| **DEC-03** | What customer-facing term should replace internal **"Ops"** in English, Telugu, and Hindi (`Care Team` / `AnugaCare Team` / `మా బృందం` / `हमारी टीम`)? | **Replaced phonetic `ఆప్స్` / `ऑप्स` in TE/HI** with natural team phrasing (`మా బృందం` / `हमारी टीम` / `ఆపరేషన్స్ బృందం` / `ऑपरेशंस टीम`); kept English strings asserted by existing tests; flagged for human review (`QA-002`). | Founder / Native Reviewers |
| **DEC-04** | Should a confirmed Care Request (`tripId != null`) be collapsed into the main scheduled visit card in `BookingsTab` once E2E tests are updated? | **Unified card styling & preserved non-splitting status pill (`c4ced74`)** while retaining both `Key('care-request-<id>')` and `Key('booking-<tripId>')` for test/E2E compatibility. | Product / Engineering |
| **DEC-05** | Should `/schedules` allow confirming a Care Request before a Primary Companion is assigned, or combine confirmation + assignment in one step? | **Preserved existing two-step RPC contract** (`Confirm request` -> `Change companions` -> `Save`) required by `20261102000100_family_care_requests.sql` and `e2e/care_request.spec.ts`. | Founder / Ops |
