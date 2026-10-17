# Screen inventory

## ANU-003 supported local slice (2026-10-17)

Owner Codex coordinator; feat/anu003-family-first-use from reviewed 96bdc59.
Family home/bookings loading, neutral empty, explicit denial/error/retry, visible
refresh and stale-data/selection handling implemented locally. Existing components,
Auth/SQL, owner consent, creation permissions and Patient routing preserved.
No setup/help/Patient-mode controls beyond supported contracts.
[Actual results and blockers](../evidence/anu003/README.md). ANU-003 Partial; no new
release. ANU-002 stays Partial for device/human/rollout checks.

## ANU-002 working-tree update (2026-10-17)

Implementation locally complete and reviewed over base 69bbb36 on
docs/product-inventory-bootstrap; sole writer Codex coordinator. Welcome, role restoration/denial and
lookup-retry plus authoritative pending/active/disabled lifecycle implemented
and tested locally under provisional F1-F4 defaults; no rollout approval.
[Contract](PILOT_ACCESS_CONTRACT.md), [current evidence](../evidence/anu002-lifecycle/README.md).
Overall ANU-002 remains Partial for device/human/rollout checks. No release/deployment.
[Current review/commit receipt](../evidence/anu002-review/README.md).
Current evidence: [ANU-002 receipt](../delivery/tasks/ANU-002.md) and
[current lifecycle verification](../evidence/anu002-lifecycle/README.md);
[earlier entry evidence](../evidence/anu002/README.md) is historical. All other rows retain
their main/historical verification defaults below.

Audit: 2026-10-16. [Baseline, SHAs and limitations](AUDIT_BASELINE.md). Stable IDs
identify views, including dialogs/embedded state panels, not only URL routes.

## Dimensions and defaults

Design = Concept / Spec ready / Approved / Not specified. Existing token mapping is
Concept, not approval of the complete screen. First-slice linked specs are Spec ready
for review; pilot welcome/user-provisioning direction is accepted in ADR 0006,
while readiness and patient/consent details remain pending. The separate Patient
home spec stays Concept. No complete screen implementation is newly Approved.
Implementation = Implemented / Partial / Missing, relative to the explicitly named
view scope. Implemented does not mean every reference capability exists. Verification
= Partial (historical evidence; runtime Not run 2026-10-16), unless Missing -> Not run.
Release = Synthetic staging, historical E-RELEASE receipt at de8f72a and on main
64c4603; individual state deployment is Unknown. Missing -> not released. No Production.

Default owner = Unassigned; ANU-002 entry views are reserved to Codex coordinator.
Task = ANU-002 for AUTH and the Ops entry gate,
ANU-003 for Family home/bookings, ANU-004 for Companion home, ANU-005 for other gaps.
No implementation branch/PR is assigned. PR #10/#11 exceptions are explicit below.
All Family rows are Flutter web/native; all Companion rows Flutter web/native; Ops
rows Next.js web. Root is build-script HTML. Native device verification Unknown.
Data/permission source: shared API/models and migrations in FEATURE_MATRIX.

## Implemented views (36)

Every source link is relative to this file. All rows have implementation Implemented
for their named scope, with missing concept actions listed separately in the state
column. See next section for the intentionally absent dedicated destinations.

| ID | View / role & patient access | Navigation | Source | Reference board:panel | API/action | Dependencies | States and gaps |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SCR-AUTH-001 | ANUGA two-link welcome; Public | / | [build-staging.sh](../../scripts/build-staging.sh) | 1:01 (welcome differs) | None | FEAT-001; CMP-001 | Two sign-in links, locale/dark/focus/text-scale support locally verified; Ops dedicated URL; lifecycle pending/disabled locally verified, native/rollout gates open |
| SCR-AUTH-002 | Family phone sign-in; Family | /family/ signed out | [login_screen.dart](../../apps/family_app/lib/src/screens/login_screen.dart) | 1:02 | Auth signInWithOtp; shouldCreateUser=false | FEAT-001; CMP-003; CMP-005 | Phone validation, busy/send failure, success -> code; new account unsupported; role selection outside form |
| SCR-AUTH-003 | Family login OTP; Family | /family/ signed out -> code state | [login_screen.dart](../../apps/family_app/lib/src/screens/login_screen.dart) | 1:03 | Auth verifyOTP/verifyOtp; my_account_access; signOut | FEAT-001; CMP-004; CMP-005 | Six-digit validation, server failure, wrong role/sign-out, change number; no timed resend; Flutter restore/post-OTP/resume role gate locally tested; missing profile/error retry; lifecycle locally verified; rollout gated |
| SCR-AUTH-004 | Companion phone sign-in; Companion | /companion/ signed out | [login_screen.dart](../../apps/companion_app/lib/src/screens/login_screen.dart) | 1:02 | Auth signInWithOtp; shouldCreateUser=false | FEAT-001; CMP-003; CMP-005 | Phone validation, busy/send failure, success -> code; new account unsupported; role selection outside form |
| SCR-AUTH-005 | Companion login OTP; Companion | /companion/ signed out -> code state | [login_screen.dart](../../apps/companion_app/lib/src/screens/login_screen.dart) | 1:03 | Auth verifyOTP/verifyOtp; my_account_access; signOut | FEAT-001; CMP-004; CMP-005 | Six-digit validation, server failure, wrong role/sign-out, change number; no timed resend; Flutter restore/post-OTP/resume role gate locally tested; missing profile/error retry; lifecycle locally verified; rollout gated |
| SCR-AUTH-006 | Ops phone sign-in; Ops | /ops/login/ | [page.tsx](../../apps/ops_console/src/app/login/page.tsx) | 1:02 | Auth signInWithOtp; shouldCreateUser=false | FEAT-001; CMP-003; CMP-005 | Phone validation, busy/send failure, success -> code; new account unsupported; role selection outside form |
| SCR-AUTH-007 | Ops login OTP; Ops | /ops/login/ -> code state | [page.tsx](../../apps/ops_console/src/app/login/page.tsx) | 1:03 | Auth verifyOTP/verifyOtp; my_account_access; signOut | FEAT-001; CMP-004; CMP-005 | Six-digit validation, server failure, wrong role/sign-out, change number; no timed resend; Flutter restore/post-OTP/resume role gate locally tested; missing profile/error retry; lifecycle locally verified; rollout gated |
| SCR-FAM-001 | Home and patient picker; Owner/editor/patient/viewer | Family signed in | [home_screen.dart](../../apps/family_app/lib/src/screens/home_screen.dart) | 4:13; 7:25 | family_my_patients | FEAT-002; CMP-002; CMP-013 | Loading, neutral empty, error/denied with visible refresh; preserve valid selection on recheck; no stale patient content; no creation/help CTA; ANU-003 locally verified |
| SCR-FAM-002 | Bookings list; All four Family levels | Home -> Bookings | [bookings_tab.dart](../../apps/family_app/lib/src/screens/bookings_tab.dart) | 4:14 | family_trip_board | FEAT-003; CMP-007; CMP-008 | Loading/error/empty; pull refresh; viewer note; no calendar/routine editor |
| SCR-FAM-003 | Visit detail, timeline and completed state; All four Family levels | Booking tap/back to Bookings | [trip_screen.dart](../../apps/family_app/lib/src/screens/trip_screen.dart) | 4:15-16; 5:17; 7:26 | family_trip_timeline | FEAT-004; CMP-009 | Event loading/error; current/completed status; no live map/ETA/call/reschedule or per-visit receipt |
| SCR-FAM-004 | Issue pickup code dialog; Owner/editor/patient; viewer denied | Visit -> pickup code | [trip_screen.dart](../../apps/family_app/lib/src/screens/trip_screen.dart) | 4:16; 7:26 | issue_pickup_otp | FEAT-004; CMP-010 | Busy/error; display server code only in scheduled/en_route; close; distinct from login OTP |
| SCR-FAM-005 | Cancel visit dialog; Owner/editor; patient/viewer denied | Visit -> cancel | [trip_screen.dart](../../apps/family_app/lib/src/screens/trip_screen.dart) | Unmatched | advance_trip(cancelled) | FEAT-004; CMP-010 | Optional reason, dismiss, busy/error/success; scheduled only; general companion notice only PR #11 |
| SCR-FAM-006 | Records list; All four Family levels | Home -> Records | [records_tab.dart](../../apps/family_app/lib/src/screens/records_tab.dart) | 5:18 | family_consents; vault_list_documents | FEAT-005; CMP-007; CMP-011 | Loading/error/empty; consent inactive; pending upload; pull refresh; no folders/access history |
| SCR-FAM-007 | Photo source sheet; Owner/editor plus vault consent | Records -> add photo | [records_tab.dart](../../apps/family_app/lib/src/screens/records_tab.dart) | 5:19 | PhotoSource.pick (device) | FEAT-005; CMP-010 | Camera/gallery/dismiss; native permissions/provider failures not reverified; PDF picker missing |
| SCR-FAM-008 | Photo metadata dialog and upload; Owner/editor plus vault consent | After photo selection | [records_tab.dart](../../apps/family_app/lib/src/screens/records_tab.dart) | 5:19 | vault-files start/upload/confirm; vault_create_document | FEAT-005; CMP-006; CMP-010 | Required title/type, dismiss/submitting/success/failure/pending; no concept date/PDF fields |
| SCR-FAM-009 | Signed image viewer; All four Family levels | Uploaded record tap/back | [record_screen.dart](../../apps/family_app/lib/src/screens/record_screen.dart) | 5:20 | vault-files download; vault_document_download | FEAT-005; CMP-011 | Loading/signing failure/image failure/zoom; unsupported PDF notice; no retry action |
| SCR-FAM-010 | Consent purposes; All four levels read; owner writes | Home privacy or Records | [consent_screen.dart](../../apps/family_app/lib/src/screens/consent_screen.dart) | 1:04; 14:23-24 vocabulary | family_consents; set_consent | FEAT-006; CMP-011 | Loading/error/non-owner read-only; per-purpose switches; no invite editor |
| SCR-FAM-011 | Consent withdrawal confirmation; Owner | Consent switch off | [consent_screen.dart](../../apps/family_app/lib/src/screens/consent_screen.dart) | Unmatched | set_consent after confirmation | FEAT-006; CMP-010 | Keep/turn off; save failure; retention/deletion job unresolved |
| SCR-FAM-012 | Monthly bills list; Owner/editor; patient/viewer denied | Home -> Bills | [bills_tab.dart](../../apps/family_app/lib/src/screens/bills_tab.dart) | 13:11; 14:24 (vocabulary) | family_invoices | FEAT-007; CMP-007 | Denied/loading/error/empty; pull refresh |
| SCR-FAM-013 | Bill lines and due/paid state; Owner/editor | Bill tap/back | [bills_tab.dart](../../apps/family_app/lib/src/screens/bills_tab.dart) | 13:11; 15:46 vocabulary | family_invoice_lines | FEAT-007; CMP-008 | Loading/paid; line-fetch failure has no explicit catch; owner-only payment via canPay |
| SCR-FAM-014 | Simulated payment confirmation; Owner only | Due bill -> pay | [bills_tab.dart](../../apps/family_app/lib/src/screens/bills_tab.dart) | 13:11 vocabulary only | payments test provider/completeTestPayment | FEAT-007; CMP-010 | Dismiss/busy/failure/success/non-test unsupported; no UPI/card checkout |
| SCR-FAM-015 | Updates inbox; Signed-in Family; own notifications | Home -> Updates | [inbox_tab.dart](../../apps/family_app/lib/src/screens/inbox_tab.dart) | 4:16 vocabulary (standalone unmatched) | my_notifications | FEAT-008; CMP-007 | Loading/error/empty; pull refresh; no fake unread count |
| SCR-COMP-001 | Today and upcoming trips; Assigned Companion | Companion signed in | [trips_screen.dart](../../apps/companion_app/lib/src/screens/trips_screen.dart) | 9:31 | companion_my_trips | FEAT-003; CMP-007; CMP-008 | Loading/error/empty, refresh/pull; hidden patient details; today bucket includes earlier dates returned by RPC |
| SCR-COMP-002 | Trip essentials and state actions; Assigned Companion | Trip tap/back to list | [trip_screen.dart](../../apps/companion_app/lib/src/screens/trip_screen.dart) | 9:32; 8:33,35-36; 10:37-40 | advance_trip; restricted CompanionTrip projection | FEAT-004; CMP-008; CMP-012 | All 12 statuses; hidden details; action submitting/errors; no maps/ETA/checklists/calling/fare/receipt/earnings |
| SCR-COMP-003 | Pickup OTP input/result; Assigned Companion | En-route trip -> pickup input | [trip_screen.dart](../../apps/companion_app/lib/src/screens/trip_screen.dart) | 8:34 | verify_pickup_otp | FEAT-004; CMP-004 | Six-digit validation; wrong/expired/locked code; busy/success; no login effect |
| SCR-COMP-004 | Transition/no-show confirmation; Assigned Companion | Trip action | [trip_screen.dart](../../apps/companion_app/lib/src/screens/trip_screen.dart) | 8:35-36; 10:38 vocabulary | advance_trip after confirmation | FEAT-004; CMP-010 | Dismiss/confirm/error/busy; state machine decides actions |
| SCR-COMP-005 | Issue/completion note dialog; Assigned Companion | Issue or complete action | [trip_screen.dart](../../apps/companion_app/lib/src/screens/trip_screen.dart) | 10:39; 8:35 vocabulary | advance_trip(note) | FEAT-004; CMP-010 | Required issue/completion note; validation/cancel; no receipt upload; issue emergency notice |
| SCR-OPS-001 | Ops root redirect; Public -> Ops gate | /ops/ -> /ops/trips/ | [page.tsx](../../apps/ops_console/src/app/page.tsx) | Unmatched | None (redirect) | FEAT-001; CMP-001 | No separate dashboard; shell gates trips |
| SCR-OPS-002 | Trips board and filters; Ops only | /ops/trips/ | [page.tsx](../../apps/ops_console/src/app/trips/page.tsx) | 11:41 | ops_trip_board | FEAT-003; CMP-001; CMP-008 | Date/range/status; loading/error/empty/refresh/success; no concept aggregate metrics; PR #10 range labels pending |
| SCR-OPS-003 | Scheduled-trip reassignment; Ops only | Trip row -> inline picker | [ReassignTrip.tsx](../../apps/ops_console/src/components/ReassignTrip.tsx) | 11:42 | ops_companion_options; ops_assign_trip_companion | FEAT-009; CMP-014 | Backup/picker/cancel/eligibility error/busy; scheduled only, not active return |
| SCR-OPS-004 | Schedules board; Ops only | /ops/schedules/ | [page.tsx](../../apps/ops_console/src/app/schedules/page.tsx) | 11:43 | ops_schedule_board | FEAT-003; CMP-001 | Loading/error/empty/refresh/success; no creation/generation/calendar; weekday editor only PR #10 |
| SCR-OPS-005 | Primary/backup assignment; Ops only | Schedule -> inline form | [ScheduleAssignForm.tsx](../../apps/ops_console/src/components/ScheduleAssignForm.tsx) | 11:42-43 | ops_companion_options; ops_assign_schedule_companions | FEAT-009; CMP-014 | Option load/failure; no selection disabled; busy/cancel/DB validation; same-companion rejection |
| SCR-OPS-006 | Exception queue; Ops only | /ops/exceptions/ | [page.tsx](../../apps/ops_console/src/app/exceptions/page.tsx) | 11:41 vocabulary (unmatched) | ops_exception_queue; trip_transitions read | FEAT-010; CMP-001; CMP-008 | Loading/error/empty/refresh; late/no-show/issue cards |
| SCR-OPS-007 | Exception resolution and cancel confirm; Ops only | Exception -> resume/cancel | [page.tsx](../../apps/ops_console/src/app/exceptions/page.tsx) | Unmatched | advance_trip; window.confirm for cancellation | FEAT-010; CMP-010 | Busy/error/success; permitted resume state or cancel; no active reassignment |
| SCR-OPS-008 | Invoice generation and issue; Ops only | /ops/billing/ | [page.tsx](../../apps/ops_console/src/app/billing/page.tsx) | 15:46 | ops_schedule_board; ops_invoices; ops_generate_invoice; ops_issue_invoice | FEAT-007; CMP-001 | Month/loading/error; draft/issue/paid; no payout/export; empty draft cannot issue |
| SCR-OPS-009 | Transport fare editor; Ops only | Completed trip row | [FareEditor.tsx](../../apps/ops_console/src/components/FareEditor.tsx) | 15:46 vocabulary | ops_record_trip_fare | FEAT-007; CMP-006 | Rupees validation -> paise; busy/error/saved; frozen once billed |

## Missing dedicated concept views (22)

These are Concept / Missing / Not run / not released. Source/route/RPC integration,
owner, branch/PR and acceptance evidence are Unknown or unscheduled. Backend support
is separately recorded in FEATURE_MATRIX, never inferred from a matching table.
Ops pilot user provisioning is accepted in ADR 0006; patient/schedule creation,
readiness and consent contracts remain D2 dependencies, not an owner-only assumption.

| ID | View | Preferred reference | Dependencies / pending decision |
| --- | --- | --- | --- |
| SCR-FAM-020 | Patient identity | 2:05 | D2; FEAT-002 |
| SCR-FAM-021 | Pickup location setup | 2:06 | D2; FEAT-002 |
| SCR-FAM-022 | Centre selection | 2:07 | D2; FEAT-002 |
| SCR-FAM-023 | Visit needs and contact setup | 2:08 | D2/D6; FEAT-002 |
| SCR-FAM-024 | New recurring routine | 13:09 | D2; FEAT-003 |
| SCR-FAM-025 | Plan choice | 13:10 | D4; FEAT-011 |
| SCR-FAM-026 | Booking checkout | 13:11 | D7; FEAT-011 |
| SCR-FAM-027 | Routine booking confirmation | 13:12 | D2; FEAT-011 |
| SCR-FAM-028 | Medicines/refill UI | 14:21 | FEAT-012 |
| SCR-FAM-029 | Request approval/create UI | 14:22 | FEAT-013 |
| SCR-FAM-030 | Invite/access management | 14:23 | D2; FEAT-014 |
| SCR-FAM-031 | More/account destination | 14:24 | FEAT-015 |
| SCR-FAM-032 | Separate simplified patient home | 7:25 | FEAT-015 |
| SCR-FAM-033 | Patient request form | 7:27 | FEAT-013 |
| SCR-FAM-034 | Patient help/call page | 7:28 | FEAT-015 |
| SCR-COMP-020 | Companion profile/onboarding | 9:29 | D3; FEAT-016 |
| SCR-COMP-021 | Verification checklist | 9:30 | D3; FEAT-016 |
| SCR-COMP-022 | Earnings/payout page | 10:40 | D4; FEAT-017 |
| SCR-OPS-020 | Companion roster/onboarding | 11:44 | D3; FEAT-016 |
| SCR-OPS-021 | Request assignment board | 15:45 | FEAT-013 |
| SCR-OPS-022 | Coverage/density map | 15:47 | FEAT-018 |
| SCR-OPS-023 | Consent request/vault access history UI | 15:48 | FEAT-006 |

## First-slice specifications and evidence

[Entry](screens/SCR-AUTH-001.md), [all three phone forms](screens/SCR-AUTH-002.md),
[all three login OTP states](screens/SCR-AUTH-003.md), [consent 04](screens/SCR-FAM-010.md), [role homes](screens/ROLE_HOMES.md).
Patient-home concept 25 has its own [pending spec](screens/SCR-FAM-032.md);
it remains Missing as a dedicated view. Consent remains a post-login settings
screen; mandatory onboarding placement is pending D2.
These specifications describe intended acceptance, not new app implementation.

Historical per-view evidence: AUTH/Ops rows use [S3 receipt](../evidence/s3-ui/README.md);
Companion rows use [S4 receipt](../evidence/s4-ui/README.md); Family rows use
[S5 receipt](../evidence/s5-ui/README.md). E-RELEASE covers cross-role journey but
does not prove every denied/empty/error state. Source tests: Family full_app_test,
trip_screen_test, records_test, bills_test; Companion full_trip_test/trip_screen_test;
Ops e2e/ops_console.spec and test/components.test. Exact links in COMPONENT_INVENTORY.
Test-source presence is not runtime verification.

## Panel ledger - every visual reference instance

Excalidraw has 12 original embedded boards / 48 concepts. This ledger describes
the 15 standalone PNGs, including three corrected variants; see AUDIT_BASELINE
for the inspected embedded-versus-standalone differences. Preserve printed
01-48 as design references independently of SCR implementation IDs.

Board number is filename suffix, not title order: board 8 has title "09" and board 9
has title "08". All 60 instances were visually opened in this audit. 48 distinct
printed concepts; 12 superseded instances. Classification Mapped can cover partial
presentation; exceptions specify omitted actions. No concept grants permissions.

| Board / file | Panel | Observed concept | Classification / stable view IDs | Difference / reason |
| --- | --- | --- | --- | --- |
| 1: [Companion onboarding_ Start with trust-1.png](../design/Companion%20onboarding_%20Start%20with%20trust-1.png) | 01 | Welcome | Decision-needed SCR-AUTH-001 | ANUGA two-link welcome + lifecycle locally verified (ANU-002); rollout gated |
| 1: [Companion onboarding_ Start with trust-1.png](../design/Companion%20onboarding_%20Start%20with%20trust-1.png) | 02 | Phone | Mapped SCR-AUTH-002/004/006 | Role-specific forms; no signup |
| 1: [Companion onboarding_ Start with trust-1.png](../design/Companion%20onboarding_%20Start%20with%20trust-1.png) | 03 | Login OTP | Mapped SCR-AUTH-003/005/007 | Single OTP field; no resend countdown |
| 1: [Companion onboarding_ Start with trust-1.png](../design/Companion%20onboarding_%20Start%20with%20trust-1.png) | 04 | Consent | Mapped SCR-FAM-010 | Consent is a post-login destination, not onboarding gate |
| 2: [Add your loved one setup-2.png](../design/Add%20your%20loved%20one%20setup-2.png) | 05 | Patient identity | Deferred SCR-FAM-020 | Creator/identity consent D2 |
| 2: [Add your loved one setup-2.png](../design/Add%20your%20loved%20one%20setup-2.png) | 06 | Pickup location | Deferred SCR-FAM-021 | No map/location setup |
| 2: [Add your loved one setup-2.png](../design/Add%20your%20loved%20one%20setup-2.png) | 07 | Centre | Deferred SCR-FAM-022 | No centre chooser |
| 2: [Add your loved one setup-2.png](../design/Add%20your%20loved%20one%20setup-2.png) | 08 | Visit needs | Decision-needed SCR-FAM-023 | Needs/contact actors D2/D6 |
| 3: [Companion recurring visit setup-3.png](../design/Companion%20recurring%20visit%20setup-3.png) | 09 | Schedule | Superseded by board 13:09 | Use corrected board; historical image only |
| 3: [Companion recurring visit setup-3.png](../design/Companion%20recurring%20visit%20setup-3.png) | 10 | Plan | Superseded by board 13:10 | Use corrected board; historical image only |
| 3: [Companion recurring visit setup-3.png](../design/Companion%20recurring%20visit%20setup-3.png) | 11 | Checkout | Superseded by board 13:11 | Use corrected board; historical image only |
| 3: [Companion recurring visit setup-3.png](../design/Companion%20recurring%20visit%20setup-3.png) | 12 | Confirmed | Superseded by board 13:12 | Use corrected board; historical image only |
| 4: [Family visit companion app flow-4.png](../design/Family%20visit%20companion%20app%20flow-4.png) | 13 | Family home | Mapped SCR-FAM-001 | No greeting/verified photo or primary/backup profile |
| 4: [Family visit companion app flow-4.png](../design/Family%20visit%20companion%20app%20flow-4.png) | 14 | Visits | Mapped SCR-FAM-002 | No calendar/manage-routine controls |
| 4: [Family visit companion app flow-4.png](../design/Family%20visit%20companion%20app%20flow-4.png) | 15 | Visit detail | Mapped SCR-FAM-003 | No calling/reschedule |
| 4: [Family visit companion app flow-4.png](../design/Family%20visit%20companion%20app%20flow-4.png) | 16 | Live visit | Mapped SCR-FAM-003/004/015 | No map/ETA; inbox is separate |
| 5: [Visit summary and private health vault-5.png](../design/Visit%20summary%20and%20private%20health%20vault-5.png) | 17 | Completed visit | Mapped SCR-FAM-003 | No per-visit charge/receipt download |
| 5: [Visit summary and private health vault-5.png](../design/Visit%20summary%20and%20private%20health%20vault-5.png) | 18 | Vault | Mapped SCR-FAM-006 | No folders/PDF/access-history UI |
| 5: [Visit summary and private health vault-5.png](../design/Visit%20summary%20and%20private%20health%20vault-5.png) | 19 | Upload | Mapped SCR-FAM-007/008 | Photo-only source/metadata; PDF deferred |
| 5: [Visit summary and private health vault-5.png](../design/Visit%20summary%20and%20private%20health%20vault-5.png) | 20 | Viewer | Mapped SCR-FAM-009 | Image only; PDF unsupported notice |
| 6: [Family care_ medicines, requests, and access-6.png](../design/Family%20care_%20medicines,%20requests,%20and%20access-6.png) | 21 | Medicines | Superseded by board 14:21 | Use corrected board; historical image only |
| 6: [Family care_ medicines, requests, and access-6.png](../design/Family%20care_%20medicines,%20requests,%20and%20access-6.png) | 22 | Requests | Superseded by board 14:22 | Use corrected board; historical image only |
| 6: [Family care_ medicines, requests, and access-6.png](../design/Family%20care_%20medicines,%20requests,%20and%20access-6.png) | 23 | Family access | Superseded by board 14:23 | Use corrected board; historical image only |
| 6: [Family care_ medicines, requests, and access-6.png](../design/Family%20care_%20medicines,%20requests,%20and%20access-6.png) | 24 | More | Superseded by board 14:24 | Use corrected board; historical image only |
| 7: [A simpler patient companion view-7.png](../design/A%20simpler%20patient%20companion%20view-7.png) | 25 | Patient home | Mapped SCR-FAM-001; deferred SCR-FAM-032 | Same Family app; no simplified mode |
| 7: [A simpler patient companion view-7.png](../design/A%20simpler%20patient%20companion%20view-7.png) | 26 | Patient visit | Mapped SCR-FAM-003/004 | No calling |
| 7: [A simpler patient companion view-7.png](../design/A%20simpler%20patient%20companion%20view-7.png) | 27 | Patient request | Deferred SCR-FAM-033 | No request composer |
| 7: [A simpler patient companion view-7.png](../design/A%20simpler%20patient%20companion%20view-7.png) | 28 | Patient help | Deferred SCR-FAM-034 | No help/call screen; no emergency dispatch |
| 8: [Companion outbound trip check-ins-8.png](../design/Companion%20outbound%20trip%20check-ins-8.png) | 33 | En route | Mapped SCR-COMP-002 | No map/ETA or separate arrived state |
| 8: [Companion outbound trip check-ins-8.png](../design/Companion%20outbound%20trip%20check-ins-8.png) | 34 | Pickup OTP | Mapped SCR-COMP-003 | Pickup verification, not login |
| 8: [Companion outbound trip check-ins-8.png](../design/Companion%20outbound%20trip%20check-ins-8.png) | 35 | At centre | Mapped SCR-COMP-002/005 | No map/ETA; existing actions only |
| 8: [Companion outbound trip check-ins-8.png](../design/Companion%20outbound%20trip%20check-ins-8.png) | 36 | Handover | Mapped SCR-COMP-002/004 | No staff/checklist fields |
| 9: [Companion onboarding and trip essentials-9.png](../design/Companion%20onboarding%20and%20trip%20essentials-9.png) | 29 | Companion profile | Decision-needed SCR-COMP-020 | Manual vs software onboarding D3 |
| 9: [Companion onboarding and trip essentials-9.png](../design/Companion%20onboarding%20and%20trip%20essentials-9.png) | 30 | Verification | Decision-needed SCR-COMP-021 | No verification evidence UI; no invented badges |
| 9: [Companion onboarding and trip essentials-9.png](../design/Companion%20onboarding%20and%20trip%20essentials-9.png) | 31 | Today | Mapped SCR-COMP-001 | No earnings/profile nav or unread counts |
| 9: [Companion onboarding and trip essentials-9.png](../design/Companion%20onboarding%20and%20trip%20essentials-9.png) | 32 | Essentials | Mapped SCR-COMP-002 | Restricted fields only; no directions/call |
| 10: [Companion visit return and completion flow-10.png](../design/Companion%20visit%20return%20and%20completion%20flow-10.png) | 37 | Return | Mapped SCR-COMP-002 | No route/waiting measurement |
| 10: [Companion visit return and completion flow-10.png](../design/Companion%20visit%20return%20and%20completion%20flow-10.png) | 38 | Home arrival | Mapped SCR-COMP-002/004 | No additional completion checklist |
| 10: [Companion visit return and completion flow-10.png](../design/Companion%20visit%20return%20and%20completion%20flow-10.png) | 39 | Post-visit note | Mapped SCR-COMP-005 | Note only; no companion fare/receipt upload |
| 10: [Companion visit return and completion flow-10.png](../design/Companion%20visit%20return%20and%20completion%20flow-10.png) | 40 | Completed/earnings | Mapped SCR-COMP-002; deferred SCR-COMP-022 | Completion exists; earnings/payout does not |
| 11: [Coordinate reliable dialysis visits-11.png](../design/Coordinate%20reliable%20dialysis%20visits-11.png) | 41 | Ops overview | Mapped SCR-OPS-002/006 | No overview counts/new destinations |
| 11: [Coordinate reliable dialysis visits-11.png](../design/Coordinate%20reliable%20dialysis%20visits-11.png) | 42 | Assignment | Mapped SCR-OPS-003/005 | Inline scheduled assignment; active return unsupported |
| 11: [Coordinate reliable dialysis visits-11.png](../design/Coordinate%20reliable%20dialysis%20visits-11.png) | 43 | Schedules | Mapped SCR-OPS-004/005 | No create/calendar; weekday editor only PR #10 |
| 11: [Coordinate reliable dialysis visits-11.png](../design/Coordinate%20reliable%20dialysis%20visits-11.png) | 44 | Roster | Deferred SCR-OPS-020 | No roster/activate verification flow |
| 12: [Companion service operations dashboard-12.png](../design/Companion%20service%20operations%20dashboard-12.png) | 45 | Requests | Superseded by board 15:45 | Use corrected board; historical image only |
| 12: [Companion service operations dashboard-12.png](../design/Companion%20service%20operations%20dashboard-12.png) | 46 | Payments | Superseded by board 15:46 | Use corrected board; historical image only |
| 12: [Companion service operations dashboard-12.png](../design/Companion%20service%20operations%20dashboard-12.png) | 47 | Coverage | Superseded by board 15:47 | Use corrected board; historical image only |
| 12: [Companion service operations dashboard-12.png](../design/Companion%20service%20operations%20dashboard-12.png) | 48 | Access | Superseded by board 15:48 | Old companion/centre vault examples are excluded by security rules |
| 13: [Four-screen companion care setup, updated to 2026-13.png](../design/Four-screen%20companion%20care%20setup,%20updated%20to%202026-13.png) | 09 | Schedule corrected | Deferred SCR-FAM-024 | PR #10 edits existing pattern only |
| 13: [Four-screen companion care setup, updated to 2026-13.png](../design/Four-screen%20companion%20care%20setup,%20updated%20to%202026-13.png) | 10 | Plan corrected | Decision-needed SCR-FAM-025 | No package-choice UI; prices not approved by image |
| 13: [Four-screen companion care setup, updated to 2026-13.png](../design/Four-screen%20companion%20care%20setup,%20updated%20to%202026-13.png) | 11 | Checkout corrected | Deferred SCR-FAM-026; mapped vocabulary SCR-FAM-013/014 | Monthly test bill differs from booking checkout |
| 13: [Four-screen companion care setup, updated to 2026-13.png](../design/Four-screen%20companion%20care%20setup,%20updated%20to%202026-13.png) | 12 | Confirmed corrected | Deferred SCR-FAM-027 | No booking confirmation wizard |
| 14: [Family vault and prescription overview-14.png](../design/Family%20vault%20and%20prescription%20overview-14.png) | 21 | Medicines neutral | Deferred SCR-FAM-028 | Schema is not medicine/refill UI |
| 14: [Family vault and prescription overview-14.png](../design/Family%20vault%20and%20prescription%20overview-14.png) | 22 | Requests | Deferred SCR-FAM-029 | No request approval/create workflow |
| 14: [Family vault and prescription overview-14.png](../design/Family%20vault%20and%20prescription%20overview-14.png) | 23 | Access corrected | Deferred SCR-FAM-030; mapped vocabulary SCR-FAM-010 | Consent purposes are not independent viewer-vault ACL toggles |
| 14: [Family vault and prescription overview-14.png](../design/Family%20vault%20and%20prescription%20overview-14.png) | 24 | More corrected | Deferred SCR-FAM-031; mapped SCR-FAM-010/012 | Language/sign-out in app bar; no More page |
| 15: [Four-panel ops board_ requests, payments, access-15.png](../design/Four-panel%20ops%20board_%20requests,%20payments,%20access-15.png) | 45 | Requests Ops corrected | Deferred SCR-OPS-021 | No request board |
| 15: [Four-panel ops board_ requests, payments, access-15.png](../design/Four-panel%20ops%20board_%20requests,%20payments,%20access-15.png) | 46 | Payments Ops corrected | Mapped SCR-OPS-008/009 | Monthly invoices/fares; no payout/export |
| 15: [Four-panel ops board_ requests, payments, access-15.png](../design/Four-panel%20ops%20board_%20requests,%20payments,%20access-15.png) | 47 | Coverage Ops corrected | Deferred SCR-OPS-022 | No map/density feature |
| 15: [Four-panel ops board_ requests, payments, access-15.png](../design/Four-panel%20ops%20board_%20requests,%20payments,%20access-15.png) | 48 | Access Ops corrected | Decision-needed SCR-OPS-023 | Audited consented read backend; no Ops vault UI; no companion/centre access |

## Source/state coverage limits

All main screen files are covered above: Family login/home/bookings/trip/records/record/
consent/bills/inbox; Companion login/trips/trip; Ops root/login/trips/schedules/
exceptions/billing. Root providers/layout and presentation helpers are catalogued
as components, not fictitious screens. Companion trip view covers scheduled,
companion_en_route, picked_up, at_centre, handed_over, session_done, returning,
dropped_home, completed, cancelled, no_show and issue_reported. No independent
ready-to-return actor or return reassignment is claimed. Read masking and allowed
transition writes have separate SQL rules; masking does not establish write denial.

No panel is silently excluded. Explicitly excluded capabilities: clinical actions,
medicine sales, emergency dispatch, companion vault/diagnosis/DOB access, and the
unsafe vault actor examples in superseded board 12. Synthetic names/prices/dates,
maps and verification marks are visual examples, not product facts.
