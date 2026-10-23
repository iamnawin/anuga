# Anuga feature gap matrix

Research date: **2026-10-12**. Repository state: branch `claude/trusting-bell-4fgv07` at `299a9bf`
(M0-M9 done per `docs/HANDOFF.md`; no code changed by this research).
The 45-row table below retains that historical snapshot. Section 5 now reconciles
the recommendations against fetched main `64c4603e5812358f6030ab8c9038747a93ba9b40`
and OPEN PR #10 head `c561a9d27a2098c3ee5932b60e4e09ceb6ccb46e` (2026-10-12).
PR #10 is not merged; its capability must not be reported as present on main/live.
No hosted schema, live behavior or runtime tests were inspected in this comparison.
Evidence labels ([Observed], [Vendor], [Inferred], [Proposal]) are defined in
[`anuga-market-feature-study.md`](anuga-market-feature-study.md#11-evidence-labels-used-in-every-document).

Status values: **Implemented**, **Partial**, **Missing**, **Unclear**. "Implemented" means present in
the database *and* reachable from an app screen. Database-only capability is **Partial**.

Short paths used below:
`M100` = `supabase/migrations/20261008000100_core_schema.sql`, `M200` = `..._0200_access_rls.sql`,
`M300` = `..._0300_trip_workflow.sql`, `M400` = `..._0400_vault_audited_access.sql`,
`M500` = `..._0500_ops_console.sql`, `M600` = `..._0600_family_app.sql`,
`M700` = `..._0700_notification_dispatch.sql`, `M800` = `..._0800_vault_storage.sql`,
`M900` = `..._0900_payments.sql`; `OPS` = `apps/ops_console/src`, `FAM` = `apps/family_app/lib/src`,
`CMP` = `apps/companion_app/lib/src`, `SD` = `packages/shared_dart/lib/src`.

## 1. How the three roles are implemented today

| Aspect | Today (evidence) |
| --- | --- |
| Role model | One `profiles.role` enum: `family`, `companion`, `ops_admin` (`M100` line 12). Patient-level rights via `patient_access.access_level`: `owner`, `editor`, `viewer`, `patient` (`M100` line 13). |
| Enforcement | Database: grants revoked by default, RLS, `security definer` RPCs (`M200`, ADR 0002). Apps only hide buttons (`SD` `AccessLevel`). |
| Apps | Three clients: `apps/family_app` (Flutter), `apps/companion_app` (Flutter), `apps/ops_console` (Next.js, client-side, anon key + user JWT). Shared Dart logic in `packages/shared_dart`. |
| Auth | Phone OTP for all roles; no self sign-up (`shouldCreateUser: false`, `docs/HANDOFF.md` M5). |
| Distribution | Separate Android ids `com.zeroorigins.companion_app` / `com.zeroorigins.family_app`, marked provisional; "an id cannot change after a Play Store release" (`docs/HANDOFF.md` M4). Staging serves `/family/`, `/companion/`, `/ops/` as web builds (ADR 0004). |

**Finding:** the security boundary is already role-based in one database. The split into two Flutter
apps is a packaging choice, not a security requirement. See section 4 and the proposal's
"Launch structure".

## 2. Capability matrix

Columns: **Ref** = reference products ([Vendor]/[Observed] as in the study). **Roles**: F = Family/Patient,
C = Companion, O = Ops.

### 2.1 Booking, recurring series and plans

| Capability | Ref | Roles | Status | Evidence in repo | Gap |
| --- | --- | --- | --- | --- | --- |
| Recurring weekly pattern (days + pickup time + session length) | Ride Health "recurring subscriptions"; Hospy360 monthly plans | O | **Partial** | `schedules` with `days_of_week`, `pickup_time`, `session_minutes`, `starts_on/ends_on` (`M100` 139-157); `ops_generate_trips` (`M300` 267) | No screen creates a schedule or runs generation. Ops console `/schedules` only assigns companions (`OPS/app/schedules/page.tsx`); `ops_generate_trips` is not called from `OPS/lib/api.ts`. Rolling generation is not scheduled. |
| Create patient profile | All | F, O | **Partial** | `create_patient` RPC (`M300` 142) | No UI in family app or ops console calls it. |
| Booking intake (phone/WhatsApp request captured by ops) | HosFriend, Hospy360, digniMuv (P1) | O | **Missing** | none | Ops cannot record a new request, a one-off visit or a series in any screen. |
| One-off (non-recurring) visit | digniMuv, Hospy360 | F, O | **Partial** | `trips.schedule_id` nullable (`M100` 165) | No RPC or UI to create a single trip. |
| Skip / reschedule one visit in a series | digniMuv "reschedule"; HosFriend FAQ 9 | F, O | **Missing** | Family can only cancel (`FAM/screens/trip_screen.dart` 92) | No reschedule; no move to another day/time. |
| Pause / end a series (hospitalisation, travel) | Hospy360 "flexible monthly plans" | F, O | **Partial** | `schedules.active`, `ends_on`; editors may update them (`M200` 133, 190-192) | No UI; future generated trips are not cancelled when a series is paused. |
| Service level: companion-only vs transport + companion; stays through session | HosFriend tiers, Hospy360 | F, O | **Partial** | `packages.companion_stays_through_session` (`M100` 134), packages Basic/Plus/Family Care (`docs/PRODUCT_SPEC.md` §5) | Not shown to family; companion app does not tell the companion whether to stay or leave. Transport mode (auto/cab/patient's own car) not recorded. |
| Monthly plan billing | Hospy360 monthly packages | F, O | **Partial** | `packages.monthly_fee_paise`, invoice line kind `monthly_fee` (`M900` 13) | UPI Autopay not built (founder decision pending, `docs/HANDOFF.md`). |

### 2.2 Patient needs and companion matching

| Capability | Ref | Roles | Status | Evidence | Gap |
| --- | --- | --- | --- | --- | --- |
| Mobility requirements | HosFriend FAQ 18 (sitting only); digniMuv; Ride Health | F, C, O | **Partial** | Free-text `patients.mobility_notes` (`M100` 84), shown to companion (`M300` 475) | Not structured: ops cannot filter or be warned (e.g. wheelchair at centre, needs two-person assist, cannot sit in auto). |
| Patient language(s) | Ride Health "communication preferences" | C, O | **Missing** | `profiles.preferred_language` is the *app user's* UI language (`M100` 48), not the patient's | No patient language or companion languages; no matching. |
| Companion gender preference | Hospy360 female companions | F, O | **Missing** | none | No preference or companion attribute. |
| Familiar companion (same primary + backup) | Hospy360 "dedicated companion" | O | **Implemented** | `schedules.primary/backup_companion_id`; `ops_assign_schedule_companions`; console schedules page | Anuga strength; competitor backup workflows unknown. |
| Replacement when primary unavailable | Ride Health overflow; HosFriend RM | O, F | **Implemented** (manual) | `ops_assign_trip_companion` with eligibility (`M300` 232); `ops_companion_options` with ineligibility reasons (`M500`); family notified `companion_changed` (`M300` 258-260) | No companion "unavailable" (leave) calendar; ops finds out only when late. |
| Companion eligibility radius / verification | n/a | O | **Implemented** | `clusters.companion_radius_m`, `private.assert_companion_eligible`, `verification_status` | Needs/skills matching missing (above). |

### 2.3 Live visit, pickup, return

| Capability | Ref | Roles | Status | Evidence | Gap |
| --- | --- | --- | --- | --- | --- |
| Trip state machine | all | C, O, F | **Implemented** | `trip_transitions` as data (`M300` 4-44); `TripStateMachine` (`SD`); contract fixture | none |
| Pickup verification (OTP) | No equivalent established in the inspected competitor material; private workflows unknown | F, C | **Implemented** | `issue_pickup_otp`, `verify_pickup_otp`, salted hash, attempt limit (`M300` 317+, `app_settings`) | Owner-unreachable scenarios need validation against patient access and existing ops issue-resolution rules. |
| Family status timeline and notifications | Ride Health ETA; HosFriend FAQ 15 | F | **Implemented** (test adapters) | `trip_status_changed` per transition (`M300` 131); `family_trip_timeline` (`M600` 29); inbox; `notify-dispatch` | Live providers (FCM/WhatsApp/SMS) not implemented (`docs/HANDOFF.md` M6). |
| ETA / live location during active trip | Ride Health, digniMuv, HosFriend | F, O | **Missing** | `trip_events.location` stored at transitions only (`M100` 207) | No live position or ETA anywhere. In spec §3.2. |
| Safe return confirmation | Hospy360 "Safe Return" | F | **Partial** | `dropped_home` then `completed` by companion; family notified on each | Family cannot acknowledge "home safely"; no alert if `dropped_home` is never reached by the expected time. |
| Treatment overrun / flexible return pickup | digniMuv optional return field; HosFriend FAQ 30 | C, O, F | **Missing** | `scheduled_return_at` fixed at generation (`M100` 170) | No readiness signal, return window or waiting capture. Optional return field does not prove on-demand return pickup. |
| Waiting time capture | HosFriend, Hospy360 "additional time chargeable" | O | **Missing** | Timestamps exist in `trip_events` (`M100` 199-208) | Not computed or shown; cannot bill or pay for it. |
| Post-visit note | (Hospy360 "updates after every visit") | C, F | **Implemented** | `trips.post_visit_note`; note never leaves DB in messages (`docs/HANDOFF.md` M6) | Optional receipt/report photo from companion (spec §3.2) not built. |
| Emergency handling (show numbers, no dispatch) | HosFriend, Hospy360 exclude emergencies | C | **Implemented** | Companion trip screen emergency number + family contacts (`CMP/screens/trip_screen.dart` 143-159) | none |

### 2.4 Cancellations, no-shows, exceptions

| Capability | Ref | Roles | Status | Evidence | Gap |
| --- | --- | --- | --- | --- | --- |
| Family cancels a visit | all | F | **Partial** | `scheduled -> cancelled` by family (`M300` 20); UI with reason (`FAM/screens/trip_screen.dart`) | No cutoff time, no late-cancel flag, no reason codes, no series-level cancel. |
| Cancellation policy and late-cancel charge | digniMuv 6 h; Hospy360 before start; HosFriend FAQ 31 | O, F | **Missing** | `billable_trip_statuses` = completed only (`docs/HANDOFF.md` M9) | Founder decision pending on no-show billing. |
| No-show (patient not available) | all | C, O | **Implemented** | `scheduled/en_route -> no_show` by companion; in exception queue (`M500` 100-135) | No reason code (patient unwell, hospitalised, centre closed). |
| Late pickup detection | Ride Health monitoring | O | **Implemented** | `ops_exception_queue` kind `late` after `ops_late_after_minutes` (`M500`) | Reactive only: flagged after pickup time passes. |
| Unassigned upcoming visit (delayed assignment) | Ride Health "before missed visits" | O | **Missing** | Console shows "Not assigned" in boards (`OPS/app/trips/page.tsx` 92) but the exception queue ignores unassigned trips | Should alert N hours before pickup. |
| At-risk visit (companion not en route X min before pickup) | Ride Health alerts; HosFriend command centre | O | **Missing** | none | Same queue, new kind. |
| Issue reported by companion and ops resolution | HosFriend RM | C, O | **Implemented** | `issue_reported` from any active state; ops resolve transitions (`M300` 23-44); Playwright test | none |
| Visit reminders (day before / morning) | digniMuv "Reminder service" [Vendor] | F, C | **Missing** | Outbox exists (`M100` 222, `M700`) | No scheduled reminder job. |

### 2.5 Billing, receipts, documents, access

| Capability | Ref | Roles | Status | Evidence | Gap |
| --- | --- | --- | --- | --- | --- |
| Monthly invoice with visit + fare lines | Hospy360 "transport at actuals"; HosFriend | O, F | **Implemented** (test mode) | `invoices`, `invoice_lines`, `ops_generate_invoice`, fares by ops (`M900`); family Bills tab | Razorpay live/test keys pending. |
| Waiting / extra-time charge line | HosFriend FAQ 30; Hospy360 T&C | O, F | **Missing** | Line kinds: `visit`, `fare`, `monthly_fee` (`M900` 13) | Needs waiting capture first. |
| Downloadable receipt / bill PDF | NephroPlus "download your bills" | F | **Missing** | Bills tab lists lines; no download (`FAM/screens/bills_tab.dart`) | Families need receipts for reimbursement claims. |
| Payment history | NephroPlus transaction history | F | **Partial** | `payments` table, invoice `paid` state | No history list beyond invoice status. |
| Patient documents vault, audited | PatientHub (clinical, out of scope) | F, O (consented reads) | **Implemented** | `vault_*` RPCs with same-transaction audit (`M400`, `M800`); consent gate; signed URLs | Ops read requires owner's active `ops_vault_access` consent; no ops write grant. Companions denied. PDF upload/view pending a package decision. |
| Role-based family access (owner/editor/viewer/patient) | Ride Health configurable permissions | F | **Partial** | Levels and checks in DB (`M100` 13, `private.can_*`) | No invite flow; owner cannot add a sibling (backlog in `docs/HANDOFF.md`). |
| Patient's own simplified view | spec §2 | F | **Unclear** | `access_level = 'patient'` exists; no distinct simplified UI found in `FAM` | Verify on device; likely same screens. |
| Companion never sees vault / diagnosis | (Anuga rule) | C | **Implemented** | `companion_my_trips` restricted fields and time window (`M300` 467-489), ADR 0002 | none |
| Consent per purpose, withdraw | DPDP | F | **Partial** | `consents`, `set_consent`, consent screen (`FAM/screens/consent_screen.dart`) | Deletion job on withdrawal pending retention decision. |

### 2.6 Companion workforce and ops reporting

| Capability | Ref | Roles | Status | Evidence | Gap |
| --- | --- | --- | --- | --- | --- |
| Today / upcoming trips for companion | Ride Health driver tools | C | **Implemented** | `companion_my_trips`, `CMP/screens/trips_screen.dart` | none |
| Companion earnings summary | spec §3.7 | C | **Missing** | `packages.companion_pay_per_visit_paise` exists | No screen or RPC. |
| Companion availability / leave | Ride Health dispatch | C, O | **Missing** | `companions.active` only | No date-level unavailability. |
| Pilot metrics export (on-time %, no-shows) | Ride Health CSV/dashboards | O | **Missing** | spec §8 requires it; backlog in `docs/HANDOFF.md` | Needed for the go/no-go gate. |
| Medicine refill reminders (non-clinical) | n/a | F | **Partial** | `medicines` table; reminders backlog | Not part of this study's priorities. |

## 3. Historical snapshot counts (not current-main completeness)

| Status | Count (rows above) |
| --- | --- |
| Implemented | 15 |
| Partial | 13 |
| Missing | 16 |
| Unclear | 1 |

## 4. Role structure: do we need three apps?

[Observed in repo] Roles are already one identity system and one database; both Flutter apps share
`shared_dart`, the same auth adapter pattern and the same theme rules. [Inferred] Keeping two Flutter
store apps doubles store listings, release pipelines and reviews, and the provisional application ids
must be fixed before the first Play Store release.

[Proposal] Launch with **two surfaces**:

This packaging recommendation is separate from N1-N5 operational improvements;
neither approves consolidation nor makes it a prerequisite for the web pilot.

1. **One Flutter mobile app** that routes by `profiles.role` after OTP sign-in: Family/Patient view
   (owner, editor, viewer, patient access levels) or Companion view. A user with no recognised role
   sees a "contact us" screen. Database rules stay unchanged.
2. **The existing web ops console** for coordinators (desktop work, tables, billing).

Choose the single application id **before** M10. Details and trade-offs are in the proposal, section 2.

## 5. Reconciliation with current main and PR #10 (2026-10-12)

Source-only comparison via `git show`, `git grep` and branch diff; no merge or code edits.
Main includes combined hosting, redesigned UIs and isolated browser sessions. One URL
is implemented; one login/role-router and one mobile app are not. PR #10 changes Ops
weekly-pattern UI/API and one new SQL migration, not the mobile apps/shared Dart.

| Recommendation | Current main | PR #10 addition | Gap that remains |
| --- | --- | --- | --- |
| N1 recurring series | Fixed primary/backup assignment, generation RPC, direct RLS-controlled schedule insert/update | Ops edits 1-4 weekdays on an existing active schedule; atomic future-unstarted replacement, history/provenance and stale-edit checks | No patient/intake/new-schedule/generation UI, pause/end UI, one-visit move or scheduled rolling-generation job. Do not rebuild pattern editor. |
| N2 return pickup | Assigned companion and Ops can advance session completion and return; scheduled return time/event timestamps exist | None | No independent readiness request, arrival/waiting capture or measured response SLA; active return reassignment denied. Permissions detailed below. |
| N3 early operations | Board shows unassigned; queue flags late/no_show/issue_reported | Readable Trips range labels; no early-warning changes | No proactive unassigned/at-risk queue, acknowledgement or day-before/morning reminder job. |
| N4 needs/matching | Free-text mobility and UI preferred language; radius/verification/active eligibility | None | No structured patient/companion languages, mobility skills or consented gender preference/mismatch warnings. |
| N5 cancellation | Owner/editor can cancel scheduled trips; Ops can cancel active non-terminal trips. Common transition helper notifies family | Weekly-pattern cancellation explicitly also notifies assigned companion | Ordinary family/Ops cancellation still does not notify companion. No structured reasons, cutoff/late flag or approved additional billing. |
| X1 packaging (separate) | Two Flutter apps + Ops web; one hosted chooser with separate sessions | None | Shared mobile shell/login/role routing; final app id decision. Not a web-pilot dependency. |
| X2 receipts | Invoice lines and test-mode payment shown | None | Downloadable receipt/bill absent. |
| X3 invites | Database patient access exists | None | Owner onboarding/invites UI absent; `create_patient` is family-only, not an Ops intake RPC. |
| X4 metrics | Trip events and statuses stored | None | Pilot metrics export absent; waiting duration cannot be inferred reliably from these events alone. |
| X5 workforce | Assignment eligibility and package pay amount | None | Date-level availability and earnings RPC/screen absent. |
| X6 waiting billing | Visit/fare/monthly-fee invoice kinds | None | Waiting line absent; measurement, grace, price and worker-pay decisions pending. |
| X7 safe-home acknowledgement | Companion dropped_home/completed events; family notifications | None | Independent family acknowledgement absent. |
| Other deferred items | Vault consent/audited reads; outbox/test adapters | None | Live location/ETA, production notification providers, refill reminders, consent-withdrawal deletion and distinct simplified patient UI still absent or incomplete. |

Evidence: main migration 0300 (`create_patient`, `advance_trip`, `ops_generate_trips`,
`ops_assign_trip_companion`, `companion_my_trips`); 0200 grants/RLS/helpers; 0400
`authorize_vault_read`; 0500 Ops boards/queue/options; current Ops API/routes, Family
trip screen and Companion trip screen; PR #10 migration `20261012000100_weekly_visit_pattern.sql`
and `SchedulePatternForm.tsx`. The historical 15/13/16/1 tally is not a refreshed score:
coarse rows conceal partial progress such as weekday editing and cancellation notifications.

### 5.1 Return-pickup permission findings (same on main and PR #10)

| Operation | Allowed by current SQL | Denied / limitation |
| --- | --- | --- |
| handed_over -> session_done; session_done -> returning | Assigned companion via `advance_trip`; Ops inherits every non-OTP companion transition | Owner/editor have only the family scheduled -> cancelled transition. Patient/viewer have no mutation actor through `can_edit_patient`; unrelated/unassigned users denied. |
| Mark independent return-ready request | No such RPC/column exists | The proposed owner/editor/patient readiness button is new permission scope, not an existing grant. |
| Change companion | Ops only, while trip is scheduled; eligibility rechecked | handed_over/session_done/returning and issue_reported cannot be reassigned by this RPC. Issue resolution changes state, not assignment; no return-leg model exists. |
| Read trip essentials | Assigned companion projection masks patient fields outside pickup-minus/return-plus configured window; cancels/no-shows masked | Projection window is not an `advance_trip` write-time restriction. Do not silently alter either boundary for overruns. |
| Issue pickup OTP (different operation) | Patient access owner/editor/patient in scheduled or companion_en_route | Viewer denied; this permission does not authorize patient/family return transitions. |

`advance_trip` locks the row, chooses assigned-companion/Ops/family actor, validates
the exact transition and records the event. Ops has database permission for return
progress, but the current exceptions screen offers issue-resume/cancel, not a general
return-progress control. Existing `session_done` event is session completion; it does
not establish an independent pickup request, actual companion arrival or waiting time.
An overrun can leave patient essentials masked after the existing details window;
this is a limitation for workflow review, not permission to extend access automatically.

Correction to earlier cleanup: Ops has consent-gated audited vault reads (0400 and
`supabase/tests/vault.test.ts`), not a blanket vault denial. Do not grant Ops ownership
or vault writes as an intake workaround. Companions remain denied vault data.
