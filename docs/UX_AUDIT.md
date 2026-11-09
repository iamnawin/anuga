# AnugaCare â€” Permanent UX & Accessibility Audit Register (`UX_AUDIT.md`)

**Created:** 2026-11-09 15:12 IST (Asia/Kolkata)
**Author / Responsible Agent:** Gemini (Antigravity â€” Lead UI/UX Engineer & Independent Product Analyst)
**Active Workstream Branch:** `feat/anugacare-ui-modernization` (isolated worktree at `D:\AI-Workspace\Ideas\Anuga`, branched from `origin/main` `ea6d142`)
**Concurrent Workstream Dependency:** Codex owns `feat/g7-ui-staging` (PR #28, head `7fa7cb2` / `e80ffd0`) in `D:\AI-Workspace\Repos\anuga-trips-fix` for the nine-segment persisted visit progress strip and synthetic staging validation.

> **Lifecycle Governance Rule:** Findings in this register must never be deleted when UI code changes. Each finding tracks distinct states: `Not started` â†’ `In progress` â†’ `Implemented` â†’ `Tested` â†’ `In PR` â†’ `Merged` â†’ `Deployed` â†’ `Human approved`. A finding is only marked `Tested` or `Merged` when backed by concrete automated test and CI evidence.

---

## 1. Summary Matrix (`UX-01` through `UX-08`)

| ID | Title | Severity | Role / Screen | Responsible Agent | Status | Target Batch |
| :--- | :--- | :---: | :--- | :--- | :--- | :--- |
| **UX-01** | Remove Family nested scroll clipping and unify booking/request card hierarchy | **High** | Family (`HomeScreen`, `BookingsTab`) | Gemini | `Tested` (`In PR`) | Batch 2 (`WP-2`) |
| **UX-02** | Preserve authorized visit details across transient action/network errors | **High** | Family & Companion (`TripScreen`) | Gemini | `Tested` (`In PR`) | Batch 2 & 3 (`WP-2`, `WP-3`) |
| **UX-03** | Persist generated Pickup OTP in active in-memory view without leaking to storage/logs | **High** | Family & Patient-Access (`TripScreen`) | Gemini | `Tested` (`In PR`) | Batch 2 & 3 (`WP-2`, `WP-3`) |
| **UX-04** | Improve Companion action hierarchy and separate primary CTA from exception actions | **High** | Companion (`TripScreen`) | Gemini | `Tested` (`In PR`) | Batch 3 (`WP-3`) |
| **UX-05** | Registered centre presentation and structured Care Request review layout | **Medium** | Family (`CareRequestScreen`) | Gemini | `Tested` (`In PR`) | Batch 2 (`WP-2`) |
| **UX-06** | Customer-facing EN/TE/HI terminology cleanup (remove phonetic "Ops" in TE/HI, standardize Telugu "Companion") | **Medium** | Unified, Family, Companion (`app_te.arb`, `app_hi.arb`) | Gemini | `Tested` (`In PR`, human `QA-002` pending) | Batch 5 (`WP-5`) |
| **UX-07** | Ops Console visual hierarchy, exception border indicators & hook cleanup | **Medium** | Ops Console (`globals.css`, `exceptions/page.tsx`) | Gemini | `Tested` (`In PR`) | Batch 4 (`WP-4`) |
| **UX-08** | Emergency/contact banner usability, 9-stage progress strip (`Key('visit-progress')`), and Patient-level view polish | **Low–Med** | Family, Patient-Access, Companion (`care_ui.dart`, `HomeScreen`, `TripScreen`) | Gemini | `Tested` (`In PR`) | Batch 1, 2 & 3 (`WP-1`–`WP-3`) |

---

## 2. Detailed Audit Findings (`UX-01` through `UX-08`)

### UX-01 â€” Family Home Nested Scroll Clipping & Duplicate Confirmed Request Cards
- **Severity:** High
- **Affected Role & Screen:** Family (`HomeScreen`, `BookingsTab`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/src/screens/home_screen.dart` (`_HomeScreenState.build`, lines 105â€“155)
  - `apps/family_app/lib/src/screens/bookings_tab.dart` (`_BookingsTabState.build`, lines 109â€“167)
- **Observed Behavior & Evidence:**
  1. `HomeScreen` wraps the patient summary `CarePanel` and optional `patient-picker` inside `ConstrainedBox(constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.35))` with its own nested `SingleChildScrollView`, placed directly above the active tab's `ListView`. In CI screenshot `docs/screenshots/g7/pr28-care-07-family-persisted-assigned.png`, the top of the `BookingsTab` care-request card (`Companion: Asha Companion (synthetic)`) is visually clipped beneath the header boundary.
  2. In `BookingsTab`, once Ops confirms a care request (`request.tripId != null`), the user sees **two separate cards for the same visit**: a `CareRequestSummary` card at the top (with a small `Open visit` `TextButton`) and a `BookingSummary` card in the scheduled visits list directly below it.
- **Impact on Users:**
  - Elderly users and family caregivers at 1.15xâ€“1.4x text scaling experience a cramped two-scroll-region viewport where the patient summary and bookings list fight for vertical space.
  - Showing both a "Confirmed" care request card and a "Scheduled" booking card for the same trip makes families think two separate bookings were created.
- **Recommended Solution:**
  1. Replace the `0.35` max-height nested scroll trap in `HomeScreen` with a compact, collapsible or single-scroll-friendly patient header bar so the active tab owns vertical scrolling cleanly.
  2. Make confirmed care request cards full-card tappable and deduplicate `BookingsTab` so a confirmed request whose `tripId` already appears in the `BookingSummary` list is either consolidated into a single enriched visit card or only unconfirmed (`!r.isConfirmed`) requests appear in the pending requests banner while confirmed visits appear once in the main bookings list (preserving existing test keys such as `care-request-<id>`, `care-request-open-trip-<id>`, and `booking-<tripId>`).
- **Security & Privacy Considerations:**
  - Purely presentation/layout over existing `listCareRequests` and `listBookings` RPC responses. Must not alter patient access filtering or stale-request generation guards (`_loadGeneration`).
- **Acceptance Criteria:**
  - No vertical clipping of the patient summary or top booking card at `360x640` and `430x932` logical viewports at `1.0x`â€“`1.4x` text scale.
  - Clear visual hierarchy distinguishing unconfirmed care requests from confirmed/scheduled visits without confusing duplicate action paths, while keeping existing widget test keys intact.
- **Required Regression Tests:**
  - `apps/family_app/test/care_request_test.dart` and `apps/family_app/test/widget_test.dart`
  - Narrow-viewport (`360x640` at `1.35x` text scale) overflow/clipping widget test.
- **Implementation Status:** `Tested` (`In PR`)
- **Responsible Agent:** Gemini
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `WP-0` (`71fb555`) + `WP-1`..`WP-6`
- **Verification Results:** Automated checks passed (`pnpm db:test` 209/209, `ops_console` 70/70, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39). Human device/language review (`QA-002`) remains `Not tested`.
- **Outstanding Decisions:** None (solvable within existing RPC contract).

---

### UX-02 â€” Preserve Authorized Visit Details After Transient Network / Action Errors
- **Severity:** High
- **Affected Role & Screen:** Family (`TripScreen`) and Companion (`TripScreen`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/src/screens/trip_screen.dart` (`_TripScreenState._run`, lines 92â€“113)
  - `apps/companion_app/lib/src/screens/trip_screen.dart` (`_TripScreenState._run`, lines 169â€“191)
- **Observed Behavior & Evidence:**
  - In both Family and Companion `TripScreen._run()`, the `catch` block unconditionally clears loaded state (`_booking = null; _events = null;` in Family; `_trip = null;` in Companion) on **any** error, not just initial-load or access-revocation errors.
  - Consequently, if a Companion enters a wrong pickup OTP (`Invalid or expired code`), or a transient mobile network error occurs when tapping `Get pickup code` or `Checked in with reception`, the entire visit detail screen blanks outâ€”hiding patient details, OTP input, progress, and action buttons.
- **Impact on Users:**
  - Hospital basements and dialysis centres in India frequently have spotty mobile data. Wiping the entire visit screen on a failed action strands the Companion or Family user until they find and tap the small top-right AppBar refresh icon.
- **Recommended Solution:**
  - Distinguish between **authorization/access-denial errors during refresh** vs. **transient action/validation errors** (such as wrong OTP or network timeout during an action):
    - On `load()` / refresh failure or explicit permission/access denial (`42501`, `PGRST`, consent withdrawn, not assigned, or empty result when trip is no longer accessible), **immediately clear `_booking = null; _events = null;` / `_trip = null;`** so protected data is never retained after access revocation, reassignment, or account switching.
    - When performing an in-screen mutation (`verifyPickupOtp`, `issuePickupOtp`, `advanceTrip`, `cancelTrip`) where `_trip` / `_booking` is already loaded and the error is not an authorization revocation, retain the current `_trip` / `_booking` view and render the `CareNotice` (`trip-error`) banner prominently above the action controls.
- **Security & Privacy Considerations:**
  - **CRITICAL:** Never retain `_booking`, `_events`, `_issuedPickupCode`, or `_trip` if a refresh/load fails, if an RPC returns permission denied / consent revoked / not assigned, or when the user signs out / switches accounts. Existing `visit_refresh_test.dart` and `visit_progress_test.dart` tests explicitly assert that failed or denied refreshes clear stale detailsâ€”those guarantees must remain 100% intact.
- **Acceptance Criteria:**
  - Entering an invalid pickup OTP or encountering an action error displays `Key('trip-error')` while keeping the visit details and OTP input / action buttons visible when the trip remains authorized.
  - Refreshing a visit after reassignment, consent withdrawal, or read failure clears the visit details and progress strip immediately.
- **Required Regression Tests:**
  - `apps/companion_app/test/trip_screen_test.dart` and `apps/companion_app/test/visit_refresh_test.dart`
  - `apps/family_app/test/visit_progress_test.dart` and `apps/family_app/test/widget_test.dart`
- **Implementation Status:** `Tested` (`In PR`)
- **Responsible Agent:** Gemini
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `WP-0` (`71fb555`) + `WP-1`..`WP-6`
- **Verification Results:** Automated checks passed (`pnpm db:test` 209/209, `ops_console` 70/70, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39). Human device/language review (`QA-002`) remains `Not tested`.
- **Outstanding Decisions:** None.

---

### UX-03 â€” Ephemeral Pickup OTP Dialog & Doorstep Visibility
- **Severity:** High
- **Affected Role & Screen:** Family & Patient-Access (`TripScreen`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/src/screens/trip_screen.dart` (`_TripScreenState._showPickupCode`, lines 115â€“139; `build`, lines 231â€“243)
- **Observed Behavior & Evidence:**
  - Tapping `Get pickup code` (`Key('get-pickup-code')`) calls `issuePickupOtp`, which generates a new 6-digit code in PostgreSQL (invalidating any prior code) and opens an `AlertDialog` (`Key('pickup-code')`).
  - Once the user taps `Close` (or accidentally taps outside the modal to check WhatsApp/call the companion), the code is lost from the screen. Tapping `Get pickup code` again silently issues a brand-new code and invalidates the previous one.
- **Impact on Users:**
  - An elderly patient at the doorstep or a family member switching apps to read/send the code to the patient easily dismisses the modal; tapping the button a second time invalidates the code they just shared, causing OTP verification failures at pickup.
- **Recommended Solution:**
  - Hold the most recently generated pickup code in transient widget memory (`String? _activePickupCode` on `_TripScreenState`) while still showing the modal dialog (preserving `Key('pickup-code')` for existing tests).
  - Display a high-contrast, large-type **Active Pickup Code card** (`Key('active-pickup-code-card')`) inline on `TripScreen` while `_canIssueCode` is true (`status == scheduled || status == companionEnRoute`).
  - Automatically clear `_activePickupCode = null` whenever:
    1. `_canIssueCode` becomes false (e.g., status advances to `picked_up`, `cancelled`, `no_show`, or `issue_reported`),
    2. `_load()` fails or access is revoked, or
    3. The widget is disposed / user signs out.
- **Security & Privacy Considerations:**
  - **CRITICAL:** Never write the pickup OTP to `localStorage`, `SharedPreferences`, URLs, logs, `debugPrint`, analytics, or persistent state. Keep it strictly in ephemeral Dart widget memory for the currently mounted `TripScreen` and clear it immediately when status changes or refresh fails.
- **Acceptance Criteria:**
  - Generating a pickup code shows the modal dialog (`Key('pickup-code')`) AND keeps the 6-digit code visibly displayed in a large, elderly-readable card on `TripScreen` after closing the dialog.
  - Advancing past pickup or failing refresh clears the inline code immediately.
- **Required Regression Tests:**
  - Widget test in `apps/family_app/test/widget_test.dart` verifying that closing the pickup code dialog leaves the code visible while `scheduled`, and refreshing to `picked_up` or a failed refresh removes it.
- **Implementation Status:** `Tested` (`In PR`)
- **Responsible Agent:** Gemini
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `WP-0` (`71fb555`) + `WP-1`..`WP-6`
- **Verification Results:** Automated checks passed (`pnpm db:test` 209/209, `ops_console` 70/70, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39). Human device/language review (`QA-002`) remains `Not tested`.
- **Outstanding Decisions:** None.

---

### UX-04 â€” Companion Action Hierarchy, Early No-Show Guard & Irreversible Step Confirmation
- **Severity:** High
- **Affected Role & Screen:** Companion (`TripScreen`, `trip_actions.dart`)
- **Exact Source Files & Components:**
  - `apps/companion_app/lib/src/screens/trip_screen.dart` (`_TripScreenState._runAction`, lines 79â€“113; `build`, lines 364â€“397)
  - `apps/companion_app/lib/src/trip_actions.dart` (`companionActions`, lines 29â€“66)
- **Observed Behavior & Evidence:**
  1. In `companion_app/lib/src/screens/trip_screen.dart` (and screenshot `docs/screenshots/g7/pr28-care-08-companion-assigned-visit.png`), the primary `FilledButton` (`I'm on my way`) is immediately followed (with only `12px` spacing) by two full-width `56dp` `OutlinedButton`s: `Patient not available` (`actionNoShow`) and `Report an issue` (`actionReportIssue`).
  2. When `_tooEarlyToStart` is true (more than 180 minutes before pickup), `I'm on my way` (`actionStart`) is disabled, but `Patient not available` (`actionNoShow`) remains enabled.
  3. Terminal completion (`Dropped home safely` â†’ `completed`) requires a note dialog (`needsNote: true`), which provides a natural two-step guard, whereas intermediate single-tap transitions (`I'm on my way`, `Reached the centre`, `Session finished`, `Starting the return journey`) sit right above `Report an issue` and `Patient not available` with minimal visual separation.
- **Impact on Users:**
  - Companions using a phone one-handed while walking or assisting a patient in a wheelchair can accidentally tap `Patient not available` or `Report an issue` below the primary CTA.
- **Recommended Solution:**
  1. Visually separate the primary next-step action (`Primary Stage Action Card`) from secondary exception actions (`Report an issue`, `Patient not available`) using a clear section divider, distinct secondary/warning styling, and `24dp` vertical separation.
  2. When `_tooEarlyToStart` is true on a `scheduled` visit, also disable `Patient not available` (`actionNoShow`) so a companion cannot mark a patient no-show hours before the start window opens (while preserving `actionNoShow` enabled whenever the trip is within the start window or `en_route`, keeping all backend transition rules and existing widget tests green).
  3. Add clear stage-context subtitles above the primary action button so the Companion always sees: (a) Current stage, (b) Next required step, and (c) Secondary exception controls in a separate lower zone.
- **Security & Privacy Considerations:**
  - Do not alter `TripStateMachine` or SQL `trip_transitions`. Preserve all existing `Key('action-...')` identifiers and confirmation dialogs (`_confirm(l10n.confirmNoShow)`).
- **Acceptance Criteria:**
  - Primary action and exception actions (`Report an issue`, `Patient not available`) are visually grouped into separate sections with â‰¥ 20dp separation.
  - When `_tooEarlyToStart` is true, `action-no_show` is disabled alongside `action-companion_en_route`.
  - All existing `trip_screen_test.dart` tests pass.
- **Required Regression Tests:**
  - `apps/companion_app/test/trip_screen_test.dart` (including start-window and action button tests).
- **Implementation Status:** `Tested` (`In PR`)
- **Responsible Agent:** Gemini
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `WP-0` (`71fb555`) + `WP-1`..`WP-6`
- **Verification Results:** Automated checks passed (`pnpm db:test` 209/209, `ops_console` 70/70, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39). Human device/language review (`QA-002`) remains `Not tested`.
- **Outstanding Decisions:** Whether `no_show` should eventually require `arrived_home` or GPS proximity in SQL (remains a future backend policy decision; UI only guards `_tooEarlyToStart`).

---

### UX-05 â€” Date/Time Picker Affordances & Read-Only Registered Centre Display
- **Severity:** Medium
- **Affected Role & Screen:** Family (`CareRequestScreen`, `ConsentScreen`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/src/screens/care_request_screen.dart` (lines 181â€“236)
  - `apps/family_app/lib/src/screens/consent_screen.dart` (lines 213â€“220)
- **Observed Behavior & Evidence:**
  1. On `CareRequestScreen` (`docs/screenshots/g7/pr28-care-01-family-request.png`), `care-date` (`YYYY-MM-DD`) and `care-time` (`HH:mm`) are `TextFormField`s where tapping the input body opens the keyboard for manual ISO/24-hour string entry; the native picker only opens if the small trailing icon is tapped.
  2. `care-centre` (`Key('care-centre')`) is rendered as a `DropdownButtonFormField` with a dropdown arrow even though it contains only one item (`widget.patient.centreId`) and `onChanged: (_) {}` is a no-op.
  3. On `ConsentScreen`, `consent-dob` (`Key('consent-dob')`) has no calendar date picker button at all.
- **Impact on Users:**
  - Non-technical Indian caregivers frequently type `09-11-2026` (`DD-MM-YYYY`) or `9:30 AM` instead of `2026-11-09` and `09:30`, triggering validation errors.
  - Tapping the `Centre` dropdown expecting to switch clinics appears broken when nothing else is selectable.
- **Recommended Solution:**
  1. On `CareRequestScreen`, add helper chips/quick-select buttons or suffix picker buttons, and add a calendar picker icon button (`Key('consent-dob-picker')`) to `consent-dob` on `ConsentScreen`, while keeping the `TextFormField` controllers directly editable so automated widget/Playwright tests that use `enterText`/`fill` continue to work without friction.
  2. Style `care-centre` with a calm read-only locked indicator (`Icons.verified_outlined` / read-only presentation) while preserving `Key('care-centre')` and existing semantics.
- **Security & Privacy Considerations:**
  - Preserves IST validation (`parseIstPickup`) and registered-centre enforcement in `request_care_visit`.
- **Acceptance Criteria:**
  - `ConsentScreen` DOB field includes an accessible calendar picker trigger.
  - `CareRequestScreen` clearly communicates IST date/time format and registered dialysis centre without a misleading multi-option dropdown affordance.
  - All existing `care_request_test.dart` and `consent_screen` widget tests pass.
- **Required Regression Tests:**
  - `apps/family_app/test/care_request_test.dart` and `apps/family_app/test/widget_test.dart`.
- **Implementation Status:** `Tested` (`In PR`)
- **Responsible Agent:** Gemini
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `WP-0` (`71fb555`) + `WP-1`..`WP-6`
- **Verification Results:** Automated checks passed (`pnpm db:test` 209/209, `ops_console` 70/70, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39). Human device/language review (`QA-002`) remains `Not tested`.
- **Outstanding Decisions:** None.

---

### UX-06 â€” Customer-Facing Terminology Across English, Telugu & Hindi
- **Severity:** Medium
- **Affected Role & Screen:** Unified Entry, Family, and Companion (`app_en.arb`, `app_te.arb`, `app_hi.arb`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/l10n/app_en.arb`, `app_te.arb`, `app_hi.arb`
  - `apps/companion_app/lib/l10n/app_en.arb`, `app_te.arb`, `app_hi.arb`
  - `apps/anugacare_app/lib/l10n/app_en.arb`, `app_te.arb`, `app_hi.arb`
- **Observed Behavior & Evidence:**
  1. Internal term **"Ops"** is phonetically transliterated into Telugu as `à°†à°ªà±à°¸à±` (`careRegisteredCentre`, `carePending`, `serviceIssueHelp`) and into Hindi as `à¤‘à¤ªà¥à¤¸` (`à¤‘à¤ªà¥à¤¸ à¤•à¥€ à¤ªà¥à¤·à¥à¤Ÿà¤¿ à¤¬à¤¾à¤•à¥€ à¤¹à¥ˆ`, `à¤‘à¤ªà¥à¤¸ à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾ à¤•à¤° à¤°à¤¹à¥‡ à¤¹à¥ˆà¤‚`).
  2. Telugu uses three different words for **Companion**: `à°¸à°¹à°¾à°¯à°•à±à°²à±` (in `anugacare_app`), `à°¸à°¹à°šà°°à±à°²à±` (respectful plural in `family_app`/`companion_app`), and `à°¸à°¹à°šà°°à±à°¡à±` (masculine singular in `careRequestIntro`, `carePendingExplanation`, `careConfirmed`).
- **Impact on Users:**
  - Elderly Telugu and Hindi speakers do not understand what `à°†à°ªà±à°¸à±` / `à¤‘à¤ªà¥à¤¸` means.
  - Masculine singular `à°¸à°¹à°šà°°à±à°¡à±` misgenders female companions (such as Asha).
- **Recommended Solution:**
  - Replace phonetic `à°†à°ªà±à°¸à±` / `à¤‘à¤ªà¥à¤¸` in Telugu and Hindi customer-facing strings with natural phrases (`à°®à°¾ à°¬à±ƒà°‚à°¦à°‚` / `à¤¹à¤®à¤¾à¤°à¥€ à¤Ÿà¥€à¤®` â€” "our team", or `à°•à±‹à°†à°°à±à°¡à°¿à°¨à±‡à°Ÿà°°à±` / `à¤¸à¤®à¤¨à¥à¤µà¤¯à¤•` for Companions), while preserving any English strings asserted by existing automated E2E/widget tests if required by test matchers (check all test matchers before changing English ARB values!).
  - Replace masculine singular `à°¸à°¹à°šà°°à±à°¡à±` in Telugu with gender-neutral respectful `à°¸à°¹à°šà°°à±à°²à±`.
  - **Governance Note:** All updated Telugu and Hindi strings remain **flagged for human native-speaker and healthcare reviewer signoff (`QA-002` / `F03`)**â€”never claim human approval.
- **Security & Privacy Considerations:**
  - Must maintain exact ARB key and placeholder parity across `en`, `te`, and `hi` (`27` unified / `138` Family / `74` Companion keys) and must never reintroduce unsupported outbound issue-acknowledgement promises removed in PR #27.
- **Acceptance Criteria:**
  - `flutter gen-l10n` succeeds across all three Flutter packages with zero missing keys or placeholder mismatches.
  - Telugu `app_te.arb` uses gender-neutral respectful terminology and natural team phrasing instead of `à°†à°ªà±à°¸à±` / `à°¸à°¹à°šà°°à±à°¡à±`.
- **Required Regression Tests:**
  - Localization catalogue parity check and widget tests across `en`, `te`, `hi`.
- **Implementation Status:** `Tested` (`In PR`)
- **Responsible Agent:** Gemini
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `WP-0` (`71fb555`) + `WP-1`..`WP-6`
- **Verification Results:** Automated checks passed (`pnpm db:test` 209/209, `ops_console` 70/70, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39). Human device/language review (`QA-002`) remains `Not tested`.
- **Outstanding Decisions:** Named human native-speaker signoff (`QA-002` / `F03`).

---

### UX-07 â€” Clarify Ops Request Confirmation, Assignment Sequence & Exception Guidance
- **Severity:** Medium
- **Affected Role & Screen:** Ops Console (`/schedules`, `/trips`, `/exceptions`, `OpsShell`)
- **Exact Source Files & Components:**
  - `apps/ops_console/src/app/schedules/page.tsx`
  - `apps/ops_console/src/app/trips/page.tsx`
  - `apps/ops_console/src/app/exceptions/page.tsx`
  - `apps/ops_console/src/components/OpsShell.tsx`
  - `apps/ops_console/src/components/CreateTrips.tsx`
  - `apps/ops_console/src/components/ReassignTrip.tsx`
  - `apps/ops_console/src/app/globals.css`
- **Observed Behavior & Evidence:**
  1. On `/schedules`, `Care requests` sit at the top with a `Confirm request` button (`CreateTrips`), while schedule cards sit below. Confirming a request before assigning a primary companion on the schedule creates an unassigned trip (`companion_id = null`), and later updating the schedule does not update the already-created trip.
  2. On `/exceptions`, `<ReassignTrip />` is mounted on every card but returns `null` when `trip.status !== 'scheduled'`, giving coordinators no explanation that underway reassignment is unsupported and that active issues must use the resolution form.
  3. `SchedulesBoard`, `TripsBoard`, and `BillingBoard` can benefit from clearer visual hierarchy, summary counts, and modernized card/table styling while preserving every existing button label, `data-testid`, and RPC call.
- **Impact on Users:**
  - Coordinators during busy morning dispatch can accidentally confirm requests without a companion assigned or wonder why an `issue_reported` exception cannot be reassigned.
- **Recommended Solution:**
  1. Enhance `/schedules` care-request cards to display whether the matching patient schedule already has a Primary/Backup companion assigned (or show a helpful inline workflow hint guiding Ops to assign companions on the schedule or via `/trips` after confirmation).
  2. Improve visual hierarchy, status badges, filter bars, and responsive card layout across `/schedules`, `/trips`, `/exceptions`, `/billing`, and `/login` in `apps/ops_console/src/app/**` and `src/components/**` (strictly without modifying `src/lib/**` or breaking Playwright/Vitest selectors).
- **Security & Privacy Considerations:**
  - Never modify `apps/ops_console/src/lib/**`, auth providers, or RPC payloads. Preserve all existing `aria-label`, button text, and test selectors used by Vitest (`test/*.test.tsx`) and Playwright (`e2e/*.spec.ts`).
- **Acceptance Criteria:**
  - Ops Console `pnpm lint`, `pnpm typecheck`, `pnpm test` (70/70 Vitest), and `pnpm build` pass with zero errors.
  - Care-request and exception workflows provide clear visual hierarchy on both desktop (`1280x800`) and tablet/mobile (`390x844`) viewports.
- **Required Regression Tests:**
  - `apps/ops_console/test/care_requests.test.tsx`, `test/issue_handling.test.tsx`, `test/components.test.tsx`.
- **Implementation Status:** `Tested` (`In PR`)
- **Responsible Agent:** Gemini
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `WP-0` (`71fb555`) + `WP-1`..`WP-6`
- **Verification Results:** Automated checks passed (`pnpm db:test` 209/209, `ops_console` 70/70, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39). Human device/language review (`QA-002`) remains `Not tested`.
- **Outstanding Decisions:** Underway companion takeover RPC remains a separate backend/founder decision.

---

### UX-08 â€” Emergency Contact Usability, Human-Readable Timestamps & Patient-Level View Polish
- **Severity:** Lowâ€“Medium
- **Affected Role & Screen:** Family, Patient-Access, and Companion (`HomeScreen`, `TripScreen`, `CarePanel`)
- **Exact Source Files & Components:**
  - `apps/family_app/lib/src/screens/home_screen.dart`
  - `apps/family_app/lib/src/screens/trip_screen.dart`
  - `apps/companion_app/lib/src/screens/trip_screen.dart`
  - `apps/family_app/lib/src/screens/care_ui.dart`
- **Observed Behavior & Evidence:**
  1. When signed in with `AccessLevel.patient`, `HomeScreen` displays a generic dashboard and still shows the `Bills` tab in the bottom navigation bar, even though `BillsTab` immediately rejects `AccessLevel.patient` with `Only the owner and editors can see bills`.
  2. Emergency `108` notices and contact details on Family and Companion `TripScreen` are plain text blocks without clear card hierarchy or icon badges.
  3. Patient-facing status and pickup OTP access require scanning dense text lines rather than a calm, high-contrast "Today's Visit & Pickup Code" priority layout.
- **Impact on Users:**
  - Elderly dialysis patients using `AccessLevel.patient` need large, unmistakable status badges, companion identity, and doorstep pickup code access without distracting billing chrome.
- **Recommended Solution:**
  1. Enhance `HomeScreen` and `TripScreen` so that when `AccessLevel.patient` is active (or for all Family/Patient users), the active/upcoming visit, companion details, and pickup code CTA are prominently surfaced with large, high-contrast typography and calm spacing, while preserving all existing navigation keys and role boundaries (no new independent Patient role).
  2. Style the `108` emergency banner and contact rows with clear iconography and high-contrast cards across Family, Patient, and Companion views.
- **Security & Privacy Considerations:**
  - Do not introduce a new Patient authentication role or broaden `AccessLevel.patient` permissions. Preserve all existing widget keys (`tab-bookings`, `tab-records`, `tab-bills`, `tab-inbox`) if asserted by existing access-matrix tests.
- **Acceptance Criteria:**
  - Elderly/patient-level view highlights current visit status, assigned companion, pickup code, and emergency guidance with â‰¥ 48dp touch targets and clean layout up to `1.4x` text scale.
  - All existing `family_app` access-level matrix tests pass.
- **Required Regression Tests:**
  - `apps/family_app/test/widget_test.dart` (access-level matrix tests).
- **Implementation Status:** `Tested` (`In PR`)
- **Responsible Agent:** Gemini
- **Branch / Commit / PR:** `feat/anugacare-ui-modernization` / `WP-0` (`71fb555`) + `WP-1`..`WP-6`
- **Verification Results:** Automated checks passed (`pnpm db:test` 209/209, `ops_console` 70/70, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39). Human device/language review (`QA-002`) remains `Not tested`.
- **Outstanding Decisions:** Whether `AccessLevel.patient` should have a dedicated single-screen mode in a future milestone (currently blocked/out of scope; we improve the existing authorized view).

---

## 3. Five Prioritized Post-Staging Product Recommendations

These five product capabilities require backend/SQL, external provider, or founder policy changes and are preserved here as the post-staging roadmap (not fabricated in the frontend UI):

1. **Controlled Underway Companion Takeover (`reassign_active_trip` RPC + Ops Exception Flow)**
   - *Priority:* #1 (Critical Patient Safety & Operational Reliability)
   - *Why:* `ops_assign_trip_companion` currently restricts reassignment to `status = 'scheduled'`. If a companion has a vehicle breakdown or medical emergency mid-visit (`en_route` through `return_en_route`), Ops needs an audited handover transition that assigns the backup companion while preserving completed milestones.
2. **One-Step Ops Request Confirmation with Inline Companion Assignment**
   - *Priority:* #2 (High Operational Reliability)
   - *Why:* Allowing `confirm_care_request` to optionally accept `primary_companion_id` / `backup_companion_id` in a single atomic transaction eliminates the two-step `/schedules` workflow.
3. **Truthful External Navigation Handoff (`NAV-001`) & Tappable `tel:` Dialers**
   - *Priority:* #3 (High Field Usability)
   - *Why:* Launching the device dialer (`tel:`) or an external map intent for the pickup/centre address gives Companions practical field tools without fabricating an in-app GPS tracker or live ETA.
4. **Outbound WhatsApp / SMS Milestone Notifications (Via Approved Provider â€” `M10`)**
   - *Priority:* #4 (High Pilot Business Value)
   - *Why:* Working family members and elderly patients rely on WhatsApp/SMS rather than keeping a PWA tab open throughout a 4-hour dialysis session.
5. **Configurable Companion Inter-Visit Travel Buffer in SQL**
   - *Priority:* #5 (High Scheduling Reliability)
   - *Why:* Extending migration `20261104000300_companion_occupancy.sql` with a configurable 30â€“60 minute travel buffer between consecutive trips prevents cascading late pickups across city traffic.

---

## 4. Open Product & Founder Decisions Register

| Decision ID | Topic | Current State in Code | Required Founder / Product Decision |
| :--- | :--- | :--- | :--- |
| **F01** | Consent legal copy & vault deletion SLA | `ConsentScreen` footer mentions 30-day deletion; `PRODUCT_SPEC.md` Â§7 mentions 24-hour purge job | Approve final legal privacy notice and align the automated vault-deletion SLA before real patient data (`M10`). |
| **F03 / QA-002** | Telugu (`te`) & Hindi (`hi`) clinical/native signoff | `en`/`te`/`hi` catalogues implemented and structurally verified | Named native Telugu and Hindi healthcare reviewers must sign off on all customer-facing copy. |
| **F05** | Companion early-start window & occupancy duration | `companion_start_minutes_before = 180` (3h); occupancy window = `4 hours` | Confirm whether 180-minute start window and 4-hour visit window match Hyderabad pilot operations. |
| **F07** | Pilot pricing, GST invoice format & no-show billing | Test-mode invoices in paise; only `completed` visits billed | Confirm pilot tariff, cancellation fee window, and whether `no_show` visits incur a partial companion payout/charge. |
| **TAKEOVER-01** | Underway companion takeover policy | Reassignment blocked once trip leaves `scheduled` | Define physical handover, OTP re-verification, and audit rules when replacing an active companion mid-visit. |
| **CONSENT-SOP-01** | Mid-visit consent withdrawal SOP | `20261104000200` blocks new actions/reads after `trip_coordination` withdrawal | Define operational duty-of-care SOP if a family revokes consent while a patient is physically at the dialysis centre. |
| **STAGE-AUTH-01** | Hosted Supabase CLI token for staging rollout | `supabase projects list` blocked by `Access token not provided` | Provide authenticated staging operator access outside chat to verify migration history and apply Nov 4 migrations + PR #28. |
| **M10** | Production environment & paid providers | All adapters locked to `test`; synthetic data only | Separate production approval required for Mumbai Supabase project, live SMS OTP, WhatsApp, and live Razorpay. |

