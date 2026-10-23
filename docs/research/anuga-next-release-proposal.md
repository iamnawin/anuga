# Anuga next release proposal

Research date: **2026-10-12**. Inputs: [`anuga-market-feature-study.md`](anuga-market-feature-study.md),
[`anuga-feature-gap-matrix.md`](anuga-feature-gap-matrix.md), `docs/PRODUCT_SPEC.md`, `docs/HANDOFF.md`.
Everything in this document is a **[Proposal]** unless a line cites evidence. Nothing here changes
`docs/PRODUCT_SPEC.md` yet: adopting a feature that changes the spec needs an ADR (repo rule).

## 0. Current-code decision: smallest next task (2026-10-12)

Compared fetched main `64c4603e5812358f6030ab8c9038747a93ba9b40` with OPEN,
unmerged PR #10 `c561a9d27a2098c3ee5932b60e4e09ceb6ccb46e`. Full reconciliation
and return permissions are in matrix section 5. This is a source review; no new
runtime verification, hosted-schema probe, merge or deployment was performed.

**Recommend one slice of N5: notify the assigned companion when an otherwise
authorized cancellation succeeds.** Main's common transition helper notifies family
only. PR #10 adds companion notification only for weekday-pattern cancellations;
ordinary Family/Ops cancellation still leaves a companion uninformed. The outbox,
`trip_status_changed` cancellation text and en/te/hi renderer already exist.
Reuse them rather than add a new notification template, provider or app screen.

This is smaller than intake (new owner/patient/schedule flow), reminders (job/threshold
design), or readiness (new actors/data and recovery decisions). It requires no new
billing/cancellation policy: keep existing transition permissions and charge behavior.
Recommend a separate follow-up branch from current main, without merging PR #10
as part of this research. At integration, establish one cancellation-notification
writer and reconcile PR #10's explicit notification to avoid duplicate outbox rows.
Do not change PR #10's migration or application code during this document-only task.

Proposed implementation acceptance criteria:
1. Owner/editor cancellation of a scheduled trip enqueues one existing push
   `trip_status_changed` row to its assigned companion with `to_status=cancelled`.
   Family channel recipients/event history remain as before.
2. Ops cancellation of any currently permitted non-terminal state does the same.
   Unassigned trip cancellation succeeds without a companion row.
3. Patient/viewer/unrelated family/companion/anonymous denied cases remain denied
   with no mutation, event or notification; no new cancellation transition or actor.
4. Repeated/concurrent attempts cannot enqueue a second cancellation notification
   for the same terminal trip. Preserve the current invalid-transition error on retry;
   do not promise idempotent RPC success. Transaction rollback leaves no outbox row.
5. With PR #10 present in a test fixture, pattern cancellations yield exactly one
   companion row too, not the common helper plus the existing explicit sender.
   Remove/re-add remains a distinct booking with intact history; individual cancels
   are not resurrected. This is an integration acceptance check, not merge approval.
6. Recipient is the currently assigned companion, not every primary/backup or the
   worker previously assigned. Payload/rendered text contains no cancellation reason,
   clinical detail or free-text note. Existing en/te/hi cancellation text renders.
7. Allowed/denied SQL tests pass in PGlite and real Supabase, contract export stays
   unchanged, dispatcher/message checks and the existing connected journey pass.
   Delivery wording means outbox/in-app/test adapter; live SMS/WhatsApp/FCM remains gated.

Expected implementation scope: one new migration for the shared transition helper,
focused database regression tests, and existing renderer tests if needed. No mobile
consolidation, new dependency, billing line, cron job, cutoff flag or reason UI in this slice.
The follow-up must coordinate with PR #10's sender, not globally deduplicate all
notification templates or edit already-applied migrations.

## 1. Summary

M0-M9 built a secure core: recurring schedules with a fixed primary + backup companion, an OTP-gated
pickup, an audited vault and test-mode billing. The six products studied show that the risk for the
pilot is not missing screens for families; it is **operations**: getting visits booked, getting
patients home when dialysis runs long, catching problems before a visit is missed, and having clear
rules when visits are cancelled.

Recommended next release, **R1 "Reliable recurring visits"** (all "Now" items): about 3-4 weeks of
one-developer effort, built as stream S6 (backend, one migration at a time) plus S3 (ops console) and
small companion/family app changes. No new third-party SDK, no clinical feature, no paid service.

Cleanup review (2026-10-12): priorities and effort are provisional recommendations,
not approved scope or a delivery commitment. The original gap matrix audits older commit
`299a9bf`; its section 5 now reconciles current main and unmerged PR #10.
Public marketing supports workflow inspiration, not competitor performance or
Anuga market exclusivity. Business-policy choices in section 6 remain pending.
No implementation, merge, deployment or app consolidation is authorized by this document.

## 2. Launch structure: one service, three roles, two surfaces

[Observed in repo] Roles already live in one database (`profiles.role`, `patient_access.access_level`,
RLS and definer RPCs). The family and companion apps are two Flutter packages over the same
`shared_dart`. Staging already serves both as web builds (ADR 0004).

| Option | Pros | Cons |
| --- | --- | --- |
| A. Keep three apps (status quo) | No work now | Two store listings, two release/review cycles, two provisional application ids to freeze |
| **B. One Flutter app with role-based views + web ops console (recommended separately)** | One install link for families and companions, shared release/theme/l10n; preserve DB rules | Merge effort; current single-role model needs explicit handling. Second phone numbers are not an approved launch policy. Request runtime permissions only where a feature needs them. |
| C. Existing browser views through one Anuga URL for the pilot | Reuses current web builds | Three frontends are not a unified PWA/session. Push/offline requirements and users' installation preferences have not been validated. |

**Recommendation:** use C (the staging web links) for the manual pilot now, and do B **before the first
Play Store release (M10)**, because an Android application id cannot change after release
(`docs/HANDOFF.md`, M4). Ops stays a desktop web console. Effort for B: **medium** (new app shell that
routes on `profiles.role`, move screens, merge ARB files and CI jobs). X1 is a separate
pre-store-release decision/workstream, not a dependency or first step for N1-N5 or the web pilot.
The current single application id remains a founder decision.

## 3. Ranked roadmap

| Rank | Item | Apps | Effort |
| --- | --- | --- | --- |
| **Now** N1 | Ops booking intake and series management | Ops (+Family read) | Medium |
| **Now** N2 | Return pickup, overruns and waiting time | Companion, Ops, Family | Medium |
| **Now** N3 | Proactive exception queue and visit reminders | Ops, Family, Companion | Small-Medium |
| **Now** N4 | Structured patient needs and companion matching warnings | Ops, Companion | Small-Medium |
| **Now** N5 | Cancellation cutoff, reason codes and late-cancel flag | Family, Ops | Small |
| Separate X1 | Single mobile app with role-based views; decide before first store release (section 2) | Family, Companion | Medium |
| Next X2 | Receipts: downloadable monthly bill / payment receipt | Family | Small-Medium |
| Next X3 | Family invites with roles | Family | Small-Medium |
| Next X4 | Pilot metrics export (on-time pickups, no-shows, waits) | Ops | Small |
| Next X5 | Companion availability (leave days) and earnings summary | Companion, Ops | Medium |
| Next X6 | Waiting / extra-time invoice line (uses N2 data; needs founder pricing) | Ops, Family | Small |
| Next X7 | Family "home safely" acknowledgement | Family | Small |
| Later | Live location and ETA; family self-serve booking; UPI Autopay; partner-centre portal; masked calling; companion ratings | all | Medium-Large |

Not proposed (scope limits): nephrologist/dietitian consults, lab values, treatment logs, medication or
dialysis calculations (NephroPlus, PatientHub), emergency dispatch, owned vehicle fleet or in-cab video
(HosFriend, digniMuv).

## 4. "Now" features in detail

Conventions for every item: one new migration file per item (S6 owns `supabase/migrations/`); every
new rule gets an allowed and a denied test in `supabase/tests/`; business values go in `app_settings`;
Run `pnpm contract:export` and both database suites after any SQL change, as required
by AGENTS.md. N1-N5 aim to preserve trip states; that does not bypass contract validation.
All numeric cutoff/grace/alert examples below are synthetic test parameters, not adopted policies.

### N1. Ops booking intake and series management

Current-code scope: PR #10 already edits existing schedules' weekdays and replaces
future unstarted bookings. Preserve that work. New patient/intake/schedule creation,
pause/end, individual moves and automated generation remain separate gaps.

- **User problem.** A daughter in Bengaluru calls or WhatsApps on Sunday: "Amma needs Mon/Wed/Fri 7 AM
  at the Kukatpally centre from next week." Today ops cannot enter this anywhere: `create_patient`
  exists but no screen calls it, no screen creates a schedule, and trip generation is never run from
  the console (gap matrix 2.1). Two weeks later Amma is admitted to hospital for five days and the
  series must pause.
- **Reference.** The three reviewed Hyderabad services advertise phone/WhatsApp or form-based intake.
  Hospy360 and digniMuv advertise short confirmation/call-back times; HosFriend's response SLA was not established.
  Hospy360 sells flexible monthly plans [Vendor].
  digniMuv allows advance bookings "up to 30 days ahead" and reschedules [Vendor].
- **Apps.** Ops console (primary). Family app shows the result (existing bookings tab).
- **Status.** Partial (DB pieces exist, no UI, no rolling generation).
- **Screens and workflow.**
  1. Ops `/patients/new`: family owner phone (existing account or invite placeholder), patient name,
     home address + map pin, centre, mobility fields (N4), emergency contacts. Calls `create_patient`
     with the owner as `patient_access.owner` (new ops variant, see data).
  2. Ops `/schedules/new`: package, days, pickup time, session length, start date, optional end date,
     primary + backup (existing options list with warnings from N4). On save: generate trips for the
     rolling window.
  3. Schedule row actions: **Skip one visit** (cancels that trip with reason `skipped`), **Move one
     visit** (new date/time for that trip only), **Pause from/to** (cancels trips in the range,
     keeps the schedule), **End series** (sets `ends_on`, cancels later trips).
  4. Family app: unchanged screens; cancelled/moved visits appear with their reason.
- **Data, state and permissions.**
  - New RPCs (ops only, `private.assert_ops()`, audited with `write_audit`):
    `ops_create_patient(owner_phone, ...)`, `ops_create_schedule(...)`,
    `ops_move_trip(trip_id, new_pickup_at)`, `ops_pause_schedule(schedule_id, from, to)`.
    `ops_move_trip` allowed only while status is `scheduled`; recomputes `scheduled_return_at` from
    `session_minutes`; notifies family (`trip_rescheduled`) and the assigned companion.
  - Rolling generation: a scheduled job (Supabase cron calling `ops_generate_trips` for active
    schedules) with `trip_generation_days` from `app_settings`. Generation must stay idempotent
    (no duplicate trip for the same schedule + date).
  - Pausing cancels through the existing `cancelled` transition (actor `ops`) so `trip_events` and
    family notifications stay consistent.
- **Failure and recovery.** Owner phone has no account: hold the intake as pending until an
  approved owner-onboarding flow exists (X3). Do not grant ops patient ownership or vault access.
  Duplicate patient: warn on
  same owner + name + centre. Generation job fails: next run fills the gap; ops board shows
  "schedule has no trips in the next 7 days" warning. Moving a visit into a slot where the
  companion already has a trip: return the conflict and keep the old time.
- **Acceptance criteria.**
  - Ops creates a patient and a Mon/Wed/Fri schedule in under 3 minutes; trips for the window appear
    in the trips board and in the family app.
  - Running generation twice creates no duplicates (test).
  - Family viewer and companion are denied every new RPC (denied tests); ops allowed (allowed tests).
  - Pausing 5 days cancels exactly the trips in the range, writes `trip_events`, and notifies the family once per trip.
  - Moving a visit that is already `companion_en_route` is refused.
- **Dependencies and effort.** Scheduling mechanism and hosted availability/cost need confirmation.
  X3 or an approved onboarding flow for new owners; no ops-held ownership workaround. **Medium.**

### N2. Return pickup, treatment overruns and waiting time

Current-code permissions: assigned companion and Ops may advance handed_over to
session_done and then returning. Family owner/editor cannot perform those transitions;
patient/viewer cannot either. Patient can issue pickup OTP, which is a different grant.
No independent readiness RPC exists. Any owner/editor/patient readiness button below
is conditional new scope; it must not call existing `advance_trip` as if already allowed.

- **User problem.** On the Basic package the companion drops the patient at 7:30 and returns for the
  scheduled 12:30 pickup. Today dialysis started late after a machine change, and the session ends at
  13:20. The companion has waited 50 minutes with no way to record it; ops does not know; the family
  sees "handed over" for six hours. On another day the session ends early and the patient waits
  alone in the lobby. Today `scheduled_return_at` is fixed and nothing records readiness or waiting
  (gap matrix 2.3).
- **Reference.** digniMuv's booking form has "Return Date & Time (Optional) For round trips only"
  [Observed form; not proof of on-demand return pickup]. The unsourced US one-hour
  will-call comparison was removed. HosFriend: when a visit runs long "Your Companion will continue to stay with you,
  with extra time billed accordingly" [Observed FAQ 30]. Hospy360: "Additional time, if required, will
  be chargeable" [Vendor].
- **Apps.** Companion (record readiness, stay or return), Ops (board column and alerts), Family (status line).
- **Status.** Missing.
- **Screens and workflow.**
  1. Companion trip screen after `handed_over`: the package tells the companion "Stay with the
     patient" or "You may leave; come back by 12:30" (from `packages.companion_stays_through_session`).
  2. A large **"Patient is ready to go home"** button, available to the companion, to the family
     owner/editor/patient on the visit screen, and to ops (centre staff phone the family or ops).
     Pressing it sets the ready time and notifies the companion and ops.
  3. If the companion is not on site, the companion app shows "Return pickup requested at 13:20";
     the companion taps the existing `session_done -> returning` steps when they collect the patient.
  4. Ops trips board: expected time, recorded ready time and response interval,
     with unknown arrival/waiting durations left unknown.
  5. Family visit screen: expected return passed / readiness not confirmed, if verified
     timestamps justify it. Do not label missing input as a confirmed treatment overrun.
- **Data, state and permissions.**
  - `trips.return_ready_at timestamptz`, `trips.return_ready_by uuid` (new columns; column grants
    only through an RPC).
  - RPC `mark_return_ready(trip_id)`: allowed for the trip's companion, family `owner`/`editor`/
    `patient` (not `viewer`), and ops; only when status is `handed_over` or `session_done`;
    idempotent (first press wins); audited; notifies companion and ops (`return_ready`) and the
    family once.
  - Proposed overrun is elapsed minutes after expected return, less a founder-approved
    grace period, clamped to zero. Readiness-to-returning measures a response interval,
    not verified patient or companion waiting: submission can be delayed and no
    companion-arrival timestamp exists. Keep unknown durations unknown; validate the
    measurement before using it for invoices or worker pay. New proposed settings: `return_grace_minutes`,
    `return_pickup_target_minutes`. Exposed in `ops_trip_board` and `family_trip_board` (minutes only).
  - No new trip status: the state machine and the SQL/Dart contract stay unchanged.
- **Failure and recovery.** No ready signal: flag missing confirmation after the approved
  threshold and have ops phone the centre; this does not prove a treatment overrun.
  Double press: proposed first-write-wins behavior. Offline: family or ops can record readiness.
  Active return reassignment is currently denied: existing `ops_assign_trip_companion` accepts
  only `scheduled` trips (migration 0300), so it cannot reassign a handed-over trip.
  Do not promise this fallback without a separately reviewed access/workflow design.
- **Acceptance criteria.**
  - Proposed readiness access: owner/editor/patient, assigned companion and ops allowed;
    viewer denied. Confirm this new permission scope before implementation; test each role.
  - Calling it in `scheduled` or `returning` is refused.
  - With grace 15 min, ready at +50 min yields `overrun_minutes = 35` on the ops board (test with fixed times).
  - Companion app shows "stay" vs "return by" correctly for each package (widget test).
  - No free text or clinical detail is sent in the `return_ready` message (dispatcher test, like M7's note check).
- **Dependencies and effort.** N3 for overrun alerts. Billing of overruns is X6 and needs a founder
  price decision. **Medium.**

### N3. Proactive exception queue and visit reminders

- **User problem.** Thursday's 7 AM visit has no companion because the backup was reassigned on
  Tuesday. Ops discovers it at 7:05 when the queue shows "late". On Monday the companion overslept;
  the trip stayed `scheduled` until pickup time passed. The family forgot that Friday's visit moved.
- **Reference.** Ride Health advertises proactive monitoring and automated alerts handled by
  an operations team [Vendor]; the reminder claim lacks a recorded supporting passage.
  digniMuv advertises a reminder service [Vendor]. HosFriend: a command centre with primary and
  secondary relationship managers monitors each visit [Vendor].
- **Apps.** Ops (queue), Family and Companion (reminders through the existing outbox).
- **Status.** Partial: `late` only, after pickup time (`ops_exception_queue`, migration 0500).
- **Screens and workflow.**
  1. Exception queue gains kinds, ordered by urgency: `unassigned` (no companion within
     `ops_unassigned_alert_hours` of pickup), `at_risk` (still `scheduled` within
     `ops_at_risk_minutes` of pickup), existing `late`, confirmed `overrun` (N2), `no_return_ready`
     (no ready signal and past expected return + grace), existing `no_show`, `issue_reported`.
  2. Each row offers the existing actions (assign backup, reassign, call details) plus
     "Acknowledge" so two coordinators do not chase the same row.
  3. Reminders: family "Tomorrow 7:00 AM: Ravi will pick up Amma" the evening before; companion
     "Tomorrow 7:00 AM pickup" the evening before and a morning reminder. Status words and times only.
- **Data, state and permissions.**
  - Replace `ops_exception_queue` in a new migration (same signature + `kind` values); ops-only as today.
  - `trip_exception_acks(trip_id, kind, acked_by, acked_at)` with ops-only grants and RLS; audited.
  - Reminder job (Supabase cron) inserts outbox rows once per trip per reminder kind
    (unique constraint prevents duplicates). New settings: reminder hour, alert thresholds.
- **Failure and recovery.** Cron does not run: queue still works on demand (computed at read time);
  reminders are best effort and never block a visit. Duplicate reminders prevented by the unique key.
  Live channels are still test adapters (M6): reminders reach the in-app inbox until a provider is approved.
- **Acceptance criteria.**
  - A trip 20 hours away with no companion appears as `unassigned` with threshold 24 h; disappears after assignment (test).
  - A `scheduled` trip 15 minutes before pickup appears as `at_risk` with threshold 30 min (test).
  - Family and companion are denied the queue and acks (tests).
  - Running the reminder job twice produces one reminder per recipient per trip (test).
- **Dependencies and effort.** N2 for `overrun` / `no_return_ready`. Supabase cron. **Small-Medium.**

### N4. Structured patient needs and companion matching warnings

- **User problem.** A patient uses a wheelchair and speaks only Telugu; a woman patient prefers a
  woman companion. Today this is free text in `mobility_notes`, so ops can assign a Hindi-speaking
  companion who cannot help with a wheelchair transfer, and nothing warns them (gap matrix 2.2).
- **Reference.** HosFriend serves only patients who can travel "in a sitting position" [Observed FAQ 18].
  Hospy360: "Female Companions are available for women" [Observed]. Ride Health profiles carry
  "mobility constraints" and "communication preferences" [Vendor].
- **Apps.** Ops (patient form, assignment warnings), Companion (sees the trip-essential needs).
- **Status.** Partial (free text only).
- **Screens and workflow.**
  1. Patient form (N1) adds: mobility level (walks independently / needs a steady arm / uses a
     wheelchair / cannot travel seated: ops review warning pending founder service-scope decision), wheelchair
     available at home (yes/no), languages spoken (en/te/hi/other), companion preference
     (no preference / woman / man).
  2. Companion profile (ops) adds languages and wheelchair-assistance training.
     Gender/preference fields remain conditional on the founder's collection and consent decision.
  3. Assignment lists (`ops_companion_options`) keep today's hard eligibility (radius, verified,
     active) and add **non-blocking warnings**: "no shared language", "not wheelchair-trained",
     "preference: woman companion".
  4. Companion trip screen shows mobility level and languages as plain labels (not diagnoses).
- **Data, state and permissions.**
  - Enums `mobility_level`, `companion_gender_pref`; `patients.languages text[]`,
    `patients.mobility_level`, `patients.companion_gender_pref`; `companions.languages text[]`,
    `companions.gender`, `companions.wheelchair_trained boolean`.
  - `companion_my_trips` returns `mobility_level` and `languages` (trip-essential, same time window).
    It must **not** return the gender preference.
  - These are non-clinical descriptors; no diagnosis, no medical history. Companion gender is
    personal data of a worker: record only with the companion's consent at onboarding.
- **Failure and recovery.** No companion matches all needs: warnings, not blocks, so ops can still
  cover the visit and note why. Patient's mobility changes: family editor can request an update;
  ops edits (audited).
- **Acceptance criteria.**
  - `ops_companion_options` returns the right warnings for each mismatch and still agrees with
    `ops_assign_trip_companion` on hard eligibility (extend the existing agreement test).
  - Companion sees mobility level and languages only inside the details window; never the gender
    preference (allowed/denied tests).
  - Mobility mismatch is a non-blocking ops warning; any new service exclusion or
    booking block needs a separate founder decision and tests after approval.
- **Dependencies and effort.** N1 form. **Small-Medium.**

### N5. Cancellation cutoff, reason codes and late-cancel flag

Current-code scope: main does not notify companions through the common cancellation
path; PR #10 notifies them only when changing weekly patterns. Section 0 recommends
closing that notification gap alone. Cutoff/reasons/late flags are subsequent scope,
and charges remain pending founder policy, not part of the recommended slice.

- **User problem.** A family cancels at 6:40 for a 7:00 pickup; the companion is already walking over.
  Today the family can cancel any time before `companion_en_route`, with no record that it was late
  and no reason category, so pilot metrics cannot separate "patient unwell" from "we failed".
- **Reference.** digniMuv: cancel or reschedule "at least 6 hours prior to pick-up" to avoid a fee
  [Vendor]. Hospy360: no refund once service begins [Vendor]. HosFriend: late changes leave a slot
  unused because "we do not make any back-up bookings"; a charge applies when a hospital cancels
  after arrival [Observed FAQ 9, 31].
- **Apps.** Family (cancel dialog), Ops (queue and reports).
- **Status.** Partial.
- **Screens and workflow.**
  1. Family cancel dialog: pick a reason (patient unwell, admitted to hospital, centre changed the
     slot, family will take them, other + text). If inside the cutoff, show "Late cancellation:
     your companion may already be on the way" and still allow it.
  2. Companion gets an immediate `trip_cancelled` notification. Today `private.apply_transition()`
     calls only `notify_patient_family` (migration 0300). PR #10 separately notifies
     companions for pattern cancellations, not general Family/Ops cancellations.
  3. Ops sees late cancellations in the queue (kind `late_cancel`) and in the metrics export (X4).
- **Data, state and permissions.**
  - `trips.cancel_reason` (enum) and `trips.cancelled_late boolean`, set by `advance_trip` when the
    target is `cancelled`; `family_cancel_cutoff_minutes` in `app_settings`.
  - Billing: **no automatic charge**. Whether late cancels or no-shows are billable stays the pending
    founder decision (`billable_trip_statuses`, `docs/HANDOFF.md`). The flag makes either choice possible.
- **Failure and recovery.** Network drop during cancel: reload current state before retrying;
  idempotent cancellation is a proposed behavior, not established by the existing transition RPC.
  Companion already `en_route`: family cancel stays refused (existing rule); they
  phone ops, who cancels with reason.
- **Acceptance criteria.**
  - Cancel 30 min before pickup with cutoff 120 sets `cancelled_late = true` (test); 3 hours before sets false.
  - Viewer still cannot cancel (existing denied test kept).
  - Assigned companion receives exactly one `trip_cancelled` notification (test).
- **Dependencies and effort.** None. **Small.**

## 5. "Next" items (short form)

| Item | Problem and reference | Data / permissions | Acceptance | Effort |
| --- | --- | --- | --- | --- |
| X1 Single mobile app | Section 2 | No DB change; app routes on `profiles.role`; companion permissions requested only in companion view | Same tests pass in one package; one debug APK in CI; family user never sees companion screens | Medium |
| X2 Receipts | Families claim reimbursement; NephroPlus "download your bills" [Observed] | Generate PDF server-side (Edge Function) for `paid` invoices, store in private bucket, signed URL like `vault-files`; owner/editor only | Viewer denied; PDF totals equal invoice lines | Small-Medium (needs PDF library decision) |
| X3 Family invites | Siblings abroad want updates; Ride Health configurable permissions [Vendor] | `patient_invites` (phone, level, expiry); accept on OTP sign-in creates `patient_access`; owner only | Non-owner cannot invite; expired invite refused | Small-Medium |
| X4 Pilot metrics export | Go/no-go gate needs on-time %, no-shows (`docs/PRODUCT_SPEC.md` §8); Ride Health CSV [Vendor] | Ops-only RPC returning per-trip rows (no names) + CSV download in console | Totals match synthetic seed fixtures | Small |
| X5 Companion availability + earnings | Ops learns of absence only when late; spec §3.7 earnings | `companion_unavailability(date range)`; options list excludes unavailable; earnings RPC from completed trips × package pay | Companion sees only own earnings; options agree with assignment | Medium |
| X6 Waiting charge line | HosFriend FAQ 30, Hospy360 T&C | New `invoice_line_kind` `waiting` from N2 `overrun_minutes` and a per-package rate | Rate 0 produces no line; frozen after issue | Small (founder pricing needed) |
| X7 "Home safely" acknowledgement | Hospy360 "Safe Return" [Vendor] | Family owner/patient ack on `dropped_home`; alert ops if not acknowledged in N minutes (optional) | Viewer cannot ack | Small |

## 6. Founder decisions this release needs

Business policies (pending; no values or charges adopted):

1. Cancellation cutoff value and whether late cancels / no-shows are billable.
2. Grace minutes before an overrun counts, and whether overruns are charged (X6) or absorbed.
3. Whether to record companion gender (with consent) to honour "woman companion" requests.
4. Service mobility limits and whether any new booking exclusion is justified;
   mismatch warnings alone do not approve a hard block.
5. Compensation for actual companion waiting, if any; response intervals are not a pay calculation.

Separate packaging decision: whether to combine the mobile apps before the first
Play Store release, and the final application id/name. This does not block the web pilot.

Separate workflow/technical scope decisions: owner onboarding, who may submit a
new independent readiness request, active return reassignment and scheduling
mechanism/cost. Current return-progress permissions are resolved in matrix section
5.1; they need no new founder policy to describe them. App consolidation/final id
is separate from operations. No paid-service authorization is implied.

No cutoff, no-show/late-cancel charge, grace period, waiting charge, companion gender
collection, mobility exclusion or final application id has been approved by this research.

## 7. Top five improvements and why they matter

1. **Ops booking intake and series management (N1).** The three reviewed Hyderabad services
   advertise human-assisted intake; this is not a claim about every competitor. Without a screen
   to create a patient, a recurring series and pauses in the audited snapshot, the pilot
   runs on a spreadsheet and the app's strongest feature (fixed recurring companions) never gets data.
2. **Return pickup and overrun handling (N2).** Dialysis sessions run late; competitors bill extra
   time. This is the moment the patient is most tired and the family most anxious, and Anuga today
   has no signal for it. It also produces the waiting data needed to price plans honestly.
3. **Proactive exceptions and reminders (N3).** The go/no-go gate demands ≥95% on-time pickups and
   <2% visits missed by us. Flagging unassigned and at-risk visits hours ahead (Ride Health's core
   promise) is a plausible way to protect those targets; cost or outcome superiority was not measured.
4. **Structured needs and matching warnings (N4).** Language, wheelchair handling and gender
   preference decide whether an elderly patient trusts the companion. Warnings keep ops flexible
   while preventing obvious mismatches, without collecting clinical data.
5. **Cancellation cutoff and reasons (N5).** These can improve operational visibility;
   protecting companion pay requires an approved compensation policy. Reason codes help
   separate patient-side from service-side misses in pilot metrics, and let the founder choose a
   billing rule from real data instead of guessing.

Structural recommendation alongside these: one mobile app with role-based views plus the web ops
console (section 2), decided before M10.
