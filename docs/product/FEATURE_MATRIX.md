# Feature matrix

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

Audit 2026-10-16. [Baseline](AUDIT_BASELINE.md) owns SHAs/release caveats. Screen
IDs below omit the SCR- prefix in the roles column for compactness. Default row owner
Unassigned except FEAT-001 (ANU-002 coordinator). Baseline verification is Partial
for located/read source and historical evidence; other workflows were not rerun; missing workflows have no acceptance evidence. Main
implementation is not equivalent to production/provider readiness.

| ID | User outcome | Roles/screens | UI | API/data | Permissions | Tests/evidence | Provider/configuration | Blocker/task/release |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| FEAT-001 | Existing users enter the correct role app | All roles; AUTH-001-007, OPS-001 | Phone/OTP/welcome and authoritative lifecycle gates locally implemented; native/rollout acceptance open | Auth SDK; profiles account_state/version + role; my_account_access; no public signup or app management | DB active-state AND role/patient checks; private owner-only audited management; no activation grants/consent | Current lifecycle evidence: real SQL/Auth/Storage, live UI denial, same-origin sessions and te/hi web renders; E-RELEASE stays historical | Synthetic test phones; live SMS not ready | ANU-002 Partial/unreleased; BE locally implemented, F1-F4 only provisional; native/human/rollout gates remain; main release unchanged |
| FEAT-002 | Link/provision patient and reach Family home | Family four levels; FAM-001,020-023 | Home first-use read states locally implemented/tested; creation/setup Missing | create_patient in 0300 creates patient/owner/trips consent; no app caller in shared FamilyApi | create_patient requires family role; do not assume Ops creator; family_my_patients restricts to linked profiles | family_app.test; access.test; full_app_test no-patient assertion | Ops provisions pilot users; authoritative lifecycle verified locally in ANU-002; patient-setup workflow remains unbuilt | D2/D6; ANU-003 supported first-use states local, setup not released |
| FEAT-003 | See and manage recurring visits | Family/Companion/Ops; FAM-002, COMP-001, OPS-002/004 | Lists/assignment implemented; setup/generation UI Missing; weekday edits Open PR #10 | schedules, ops_generate_trips and read boards on main; weekly pattern mutation only PR #10 | Ops assignments/generation; Family linked reads; Companion assigned projection | platform.test; ops_console.test; family_app.test; PR #10 tests separate | No automatic generator/job established by UI | ANU-005; main lists; PR #10 unreleased |
| FEAT-004 | Complete authorized visit and pickup | Family four levels/assigned Companion/Ops; FAM-003-005, COMP-002-005 | Implemented state/OTP/note/cancel; no map/ready actor | 0300 trip_transitions, advance_trip, issue_pickup_otp, verify_pickup_otp; shared Dart | Owner/editor cancel scheduled; owner/editor/patient issue pickup; viewer no writes; assigned companion and Ops forward/return per SQL | platform/access/contract/journey tests; app trip tests; E-RELEASE journey | No clinical actions or dispatch; test notifications only | D5; ANU-005; main + historical synthetic |
| FEAT-005 | Store/read private report photos | Family four levels; FAM-006-009 | Photo flow implemented; PDF UI/folders/history Missing | 0400 audited read; 0800 private storage, signed URLs; vault-files | All linked Family levels read; owner/editor write with owner vault consent; Ops consented audited reads; Companion denied | vault.test; vault_storage.test; vault_files_function/unit; records_test | Storage/vault-files in release receipt; actual current schema Unknown | D7; ANU-005; main photo flow, PDF not released |
| FEAT-006 | Control owner consent and audited access | Family; consented Ops; FAM-010/011, OPS-023 | Purpose switches implemented; invites/Ops access history UI Missing | 0400 authorize_vault_read + audit_log; 0800 family_consents/set_consent | Only owner changes purposes; linked Family read vault; no independent viewer-vault flag; Ops needs active owner ops_vault_access | vault.test; vault_storage.test; records_test | No new consent request provider; retention job absent | D7; ANU-005; main consent; access-management concept unreleased |
| FEAT-007 | Invoice completed visits and simulate payment | Ops; Family owner/editor; FAM-012-014, OPS-008/009 | Implemented monthly billing/fare/test payment; booking checkout/payout absent | 0900 invoices/lines/payment_start/captured; payments and webhook | Ops fare/draft/issue; owner/editor bills; owner pay; service-role capture | payments.test; payments_unit/function; bills_test; ops e2e; E-RELEASE billing journey | Test adapter; real SDK/UPI/autopay and production keys not ready | D4/D7; ANU-005; synthetic only, no real payment release |
| FEAT-008 | Receive visit updates | Family own inbox; FAM-015 | Inbox implemented; Companion inbox missing | notifications/outbox, 0700 dispatch claim/mark; notify-dispatch templates en/te/hi | Own push rows via my_notifications; dispatcher service role; safe message fields | dispatch.test; dispatcher_unit; dispatch_function; family app inbox | Test adapters; no live SMS/WhatsApp/FCM delivery verified | ANU-005; main/in-app historical synthetic |
| FEAT-009 | Assign primary/backup and replace scheduled companion | Ops; OPS-003/005 | Implemented inline forms | 0300 assign schedule/trip and eligibility; 0500 companion options | Ops only; verified/active/radius; scheduled-trip reassignment only | ops_console.test; platform.test; components.test; ops e2e | No companion provisioning/availability calendar/payout service | D5/D6; ANU-005; main + historical synthetic |
| FEAT-010 | Handle late/no-show/issues | Ops and assigned Companion; OPS-006/007, COMP-004/005 | Implemented exception queue and permitted actions; proactive warnings missing | ops_exception_queue; transition rules; issue notes | Ops resume/cancel; assigned Companion reports; no active-trip reassignment | ops_console.test; platform.test; trip_screen tests | No timed early-warning/reminder job established | D4/D5; ANU-005; main + historical synthetic |
| FEAT-011 | Create routine, choose plan and pay at booking | Patient/schedule creator unresolved; users provisioned by Ops; FAM-024-027 | Missing wizard | Packages/schedules/generation/invoices support fragments, not atomic booking checkout | Actor/consent/transaction boundaries unresolved; do not infer from tables | No complete wizard acceptance evidence | Real checkout/provider not ready | D2/D4/D7; ANU-005; not released |
| FEAT-012 | Manage prescription-derived refill reminders | Family; FAM-028 | Missing medicine/refill UI | medicines table/audited read exists; no refill-dispatch job | Vault access rules apply; Companion excluded; no prescribing/sales | vault.test covers medicine visibility, not reminder workflow | Scheduling/notification integration missing | ANU-005; not released as workflow |
| FEAT-013 | Request/approve/assign nonclinical help | Patient/Family/Ops; FAM-029/033, OPS-021 | Missing | No requests table or complete RPC in main schema | Approval/assignment actors unresolved; no clinical tasks | No full request acceptance tests | No request provider/integration | ANU-005; not released |
| FEAT-014 | Invite family and set access | Family owner; FAM-030 | Missing invite/access editor | patient_access supports levels; no invitation lifecycle | Existing DB levels owner/editor/patient/viewer; per-viewer vault toggle absent | access.test covers existing rights, not invite journey | Invite delivery/lifecycle unimplemented | D2; ANU-005; not released |
| FEAT-015 | Simplified patient/help/account experience | Patient/Family; FAM-031/032/034 | Missing dedicated screens; existing Family access preserved | Existing shell/language/sign-out only | No expanded patient mutation permission | Existing app tests do not prove new concept experience | No support/calling integration | ANU-005; not released as separate mode |
| FEAT-016 | Onboard/verify companions and manage roster | Companion/Ops; COMP-020/021, OPS-020 | Missing onboarding/roster UI | companion records/status and assignment eligibility exist; manual process Unknown | Verification attestation/actor/evidence policy unresolved | Eligibility tests are not onboarding certification | No ID/background/training provider configured by this audit | D3/D6; ANU-005; not released |
| FEAT-017 | Show earnings and settle payouts | Companion/Ops; COMP-022, OPS-008 concept | Missing | Family invoice/payment model is not companion compensation ledger | Payout policy and authorization unresolved | No earnings/payout acceptance evidence | No payout provider | D4; ANU-005; not released |
| FEAT-018 | See cluster coverage/density | Ops; OPS-022 | Missing map/density UI | PostGIS cluster/radius support; no H3 density gate implemented | Ops-only intent; no new patient data exposure | Radius eligibility tests do not verify coverage dashboard | No map/provider integration chosen | ANU-005; not released |
| FEAT-019 | Notify assigned companion on all cancellations | Ops/Family trigger; assigned Companion recipient | No new UI; main lacks general companion cancel notice | PR #11 new migration/common helper + exact-once tests; PR #10 pattern-specific sender separate | Existing cancellation actors unchanged; no reason/clinical fields in notice | PR #11 tests/receipt only; not run here; PR #10 integration remains fixture | Test dispatch receipt; no live push provider | ANU-006; open PR #11, not main/deployed |
| FEAT-020 | Live map/ETA and return readiness | Family/Companion/Ops; FAM-003, COMP-002 | Missing | Event location fields are not live GPS/ETA/readiness/actual waiting | New readiness actors/return reassignment require explicit contract | No live geo/readiness workflow acceptance | No background location/maps provider | D5/D6; ANU-005; not released |
| FEAT-021 | Delete vault data after withdrawal / export metrics | Family/Ops supporting operations | Missing | Consent withdrawal exists; deletion/retention job/export not implemented | Retention/export authorization unresolved; never bypass vault audit | Consent tests do not prove deletion/export | No job configured | D7; ANU-005; not released |

## Permission baseline (current SQL, not concept-image labels)

| Operation | Owner | Editor | Patient | Viewer | Assigned Companion | Unassigned Companion | Ops |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Linked patient trip read | Yes | Yes | Yes | Yes | Restricted assigned projection only | No | Ops boards |
| Issue pickup OTP | Yes, allowed states | Yes, allowed states | Yes, allowed states | No | No | No | No direct issuer permission |
| Family cancel scheduled | Yes | Yes | No | No | No | No | Own Ops transitions |
| Forward/return transitions | No | No | No | No | Per state machine | No | Per Ops transitions |
| Vault audited read | Yes | Yes | Yes | Yes | No | No | Active owner ops_vault_access consent required |
| Vault write | Yes + vault consent | Yes + vault consent | No | No | No | No | No |
| Change purpose consent | Yes | No | No | No | No | No | No |
| Read issued bills | Yes | Yes | No | No | No | No | Ops invoices |
| Pay invoice | Yes | No | No | No | No | No | Service capture is a separate trusted-backend capability |

Anonymous callers cannot read protected app data. A valid login is insufficient
without the per-patient grant. A Companion projection hides essentials outside the
time window and for cancelled/no-show visits; that read rule is not a transition
write-time rule. No independent ready RPC exists. Ops can advance return states,
but app exception UI only exposes its existing recovery subset.

## Exact implementation/evidence anchors

- [Trip workflow SQL](../../supabase/migrations/20261008000300_trip_workflow.sql):
  creation, generation, eligibility, transitions, OTP, Family/Companion boards.
- [RLS/helpers](../../supabase/migrations/20261008000200_access_rls.sql),
  [vault](../../supabase/migrations/20261008000400_vault_audited_access.sql),
  [Family projections](../../supabase/migrations/20261008000600_family_app.sql),
  [storage/consent](../../supabase/migrations/20261008000800_vault_storage.sql),
  [payments](../../supabase/migrations/20261008000900_payments.sql).
- [Shared API](../../packages/shared_dart/lib/src/api.dart),
  [models](../../packages/shared_dart/lib/src/models.dart),
  [state machine](../../packages/shared_dart/lib/src/trip_state_machine.dart),
  [Ops wrappers](../../apps/ops_console/src/lib/api.ts).
- [Database tests](../../supabase/tests/), [app test index](COMPONENT_INVENTORY.md),
  [historical deployment/CI](AUDIT_BASELINE.md). File names in the table identify
  tests in these directories, not freshly passing results.

No feature gets an Approved, Passed or Production label from this audit.
Screen evidence is narrower than the entire feature; backend support is not
workflow completion. Open PR #10 and #11 must be reviewed together for duplicate
cancellation writers before any authorized integration, with real migration/
concurrency/journey checks; neither is merged or deployed by this documentation.
