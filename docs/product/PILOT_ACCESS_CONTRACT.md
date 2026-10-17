# ANU-002 pilot account access contract

Updated 2026-10-17 by Codex coordinator. **Lifecycle and client implementation locally complete, reviewed
and tested; ANU-002 remains Partial/unreleased. F1-F4 are provisional
development assumptions, NOT rollout approval.**
[ADR 0006](../adr/0006-pilot-entry-and-provisioning.md) supplies the accepted pilot
direction. This revision resolves technical choices; F1-F4 below are proposed
business defaults, not founder rollout decisions. Latest user authority explicitly
permits local synthetic implementation/testing. No real operator was designated;
no real-user classification or hosted change. Latest review authorises a local
ANU-002-only commit; no push, merge or deploy.
[Backend task](../delivery/tasks/ANU-002-BE.md),
[verification tasks](../delivery/tasks/ANU-002-VERIFY.md),
[parent receipt](../delivery/tasks/ANU-002.md).

## 1. Existing behavior and smallest technical change

Use existing Supabase Auth, public.profiles, private helpers, RLS/restricted RPCs
and public.audit_log. Do not add a lifecycle table, new Auth role, admin console,
Edge provisioning service, dependency, JWT lifecycle claim or auth-hook service.
This replaces the earlier separate-record proposal with two columns on profiles:

| Local implementation | Contract |
| --- | --- |
| profiles.account_state | Text constrained to pending / active / disabled; NOT NULL, default pending for new identities |
| profiles.account_state_version | Bigint starting at 1, incremented for actual lifecycle or pending-role changes; compare-and-set for operator commands |
| public.my_account_access() | No arguments; authenticated self-only resolver returning state and role; no patient data |
| private.account_is_active() / assert_active_account() | Derive auth.uid(); read current profile state from DB, never client metadata or JWT claims |
| private.configure_pilot_account(...) | Database-owner operator command; row lock, expected version, validated transition, pending-only role assignment, required reason/operator/authority references |
| Private lifecycle audit trigger | Reuses audit_log for initial state and actual role/state changes; no new audit store |

Implementation: [new migration](../../supabase/migrations/20261016001000_pilot_account_access.sql),
[offline synthetic backfill checker](../../supabase/scripts/pilot-backfill.ts),
and [local lifecycle receipt](../evidence/anu002-lifecycle/README.md). APIs/columns exist only in disposable local test stacks;
hosted schema and deployed apps remain unchanged.
private.handle_new_user currently creates a default Family profile; retain its
metadata-independent role behavior. New profile insertion must create/audit pending
state in the same transaction. Auth identity creation or OTP never activates it.
Existing app logins retain shouldCreateUser=false; unknown phones cannot register.

Source basis: migrations [0100](../../supabase/migrations/20261008000100_core_schema.sql)
(profiles, roles, audit_log), [0200](../../supabase/migrations/20261008000200_access_rls.sql)
(Auth trigger, helper/grant/RLS boundary), [0300](../../supabase/migrations/20261008000300_trip_workflow.sql)
(ID-based trip functions), [0600](../../supabase/migrations/20261008000600_family_app.sql)
(Family/notification reads), [0800](../../supabase/migrations/20261008000800_vault_storage.sql)
(consent and signed-file paths), [0900](../../supabase/migrations/20261008000900_payments.sql)
(billing); current Flutter auth adapters/app roots and Ops AuthProvider.
No existing account-provisioning application workflow was found; seed/admin test
helpers are privileged fixtures, not an approved pilot provisioning procedure.
The Family adapter's old owner-invites comment is stale; do not implement invitations
from that comment or add invitations in this lifecycle task.

## 2. Resolution and transitions

Resolver requires a valid authenticated caller, uses auth.uid() without any target
argument, and returns one object: state = pending / active / disabled / unconfirmed,
role = existing profiles.role only when active, otherwise null. Missing profile is
unconfirmed; unsupported state is a DB integrity failure, never an active fallback.
No full name, phone, audit reason, operator reference, patient links or grants are
returned. Anonymous execution is denied; expired/invalid JWT follows Auth sign-in
recovery. Transport/query failure is a retryable error outside the state enum.

| Evidence | Presentation and access |
| --- | --- |
| No valid session | Selected app phone/OTP sign-in |
| Explicit pending profile | Setup pending; Recheck and Sign out; no protected home/data |
| Explicit disabled profile | Account disabled/denied; Sign out; no protected home/data |
| Active + expected backend role | Existing role home, with current SQL/RLS patient/assignment/consent checks |
| Active + other known backend role | Wrong-app denial; never role reassignment |
| Missing profile | Access unconfirmed; Recheck and Sign out; not assumed pending |
| Lookup/refresh error | Error with Retry/Sign out; not a confirmed denial or pending |
| Active Family with zero links / Companion with zero visits | Existing empty home; no implied incomplete provisioning |

Pending copy follows ADR 0006 and is implemented in en/te/hi. Local visual checks
passed; native-language human acceptance remains open. Disabled copy must say access is disabled without exposing the reason.
Inactive callers use the resolver instead of a direct profile SELECT; direct
protected profile reads/updates are also denied. Resolver is read-only and does
not audit every refresh or mutate roles, patients, grants, consent or Auth.

Allowed state changes: initial creation -> pending; pending -> active or disabled;
active -> disabled; disabled -> active only with explicit reactivation authority.
No timer/OTP/family link reactivates anyone. An explicit repeat of the current state
is an idempotent no-op at the same expected version, not another activation event.
Conflicting version fails without mutation. No active -> pending reset is needed.
Existing roles stay unchanged; role assignment is allowed only while the old state
is pending, by the trusted operator, with the same audit controls. Changing a role
after activation or converting a disabled account to another role is a separate
reviewed task, not an account-reactivation shortcut.

## 3. Who manages each role (F1 assumed for local development only)

| Target role | Provision pending / assign initial role | Activate | Disable | Reactivate |
| --- | --- | --- | --- | --- |
| family (all patient access levels) | Active Ops authorises | Active Ops authorises | Active Ops authorises | Active Ops authorises after reviewing current access |
| companion | Active Ops authorises | Active Ops authorises | Active Ops authorises | Active Ops authorises after review |
| ops_admin, including first/replacement admin | Founder authorises | Founder authorises | Founder authorises | Founder authorises |

Execution for every row: a named founder-designated trusted database/Auth operator,
outside the browser. An Ops authorisation is an operational request, not a new
SQL grant or authenticated management RPC. Regular Family/Companion callers and
pending/disabled Ops cannot manage accounts; active Ops cannot self-activate or
promote themselves. Founder is a human authority, not an invented profiles.role.
ADR 0006 already makes Ops responsible for pilot-user provisioning; F1 does not
reopen that decision. Unsettled activation/disable/reactivation delegation and Ops-admin
management in this matrix remain recommendations, not new authorisation. Founder-only Ops management
also covers last-admin recovery; the owner connection is the controlled recovery
route, with recorded authority, not an app bypass or an auto-elected admin.

Runbook sequence: record real authorisation and operator identity; create an Auth
identity through the existing server-side Auth administration surface; confirm its
trigger-created pending profile; assign its reviewed initial role; explicitly
activate or leave pending. Disable/reactivate uses the same owner-only command; lifecycle changes do not
automatically set or remove Auth bans, confirm a phone or bypass OTP.
Keep privileged credentials local to that authorised operator. Do not expose the
private schema or give service-role credentials to Ops UI. Auth and profile actions
are separate transactions: on failure leave pending, retry by confirmed UUID, do
not create duplicate identities or delete an account as compensation. A missing
profile is an integrity repair, not automatic new-profile provisioning.

Database credential possession does not prove human founder approval. The operator
must verify the actual external approval before executing a founder-only change;
an approval-reference string is an audit pointer, not a cryptographic entitlement.
This manual trust boundary avoids inventing an unsupported founder role/RBAC system.
Companion account activation does not certify identity, training or verification:
existing companions.active/verification_status/radius checks still apply, and
assignment eligibility must additionally require an active account.

## 4. Auditing and administration integrity

Use one owner-only private command with inputs: target UUID, expected version,
new state, optional pending-role assignment, reason, operator reference and authority
reference. No management grant to PUBLIC/anon/authenticated/service_role; a later
service interface would need its own scope. Lock target row, validate nonempty
reason/references and transition/version, and commit state/version/audit together.
Prevent active/disabled role reassignment at the trigger boundary as well.

Audit action account_created / account_access_changed / account_backfilled uses
existing audit_log.table_name = profiles, record_id = UUID, patient_id = null.
Details contain old/new state, old/new role, version, source (Auth creation,
operator or migration), reason, operator reference and actual authority reference
where applicable. Timestamp uses audit_log.at. actor_id remains auth.uid() when
there is a real authenticated actor; owner-run operations have a null actor and
record session_user plus the named operator reference. Never forge a JWT subject
or label the founder as approver without evidence. No phone, OTP, token or patient
payload in these events. Capture privileged direct changes too; require operator
context for lifecycle/role updates, with an explicit migration/backfill context.

Create-time pending audit records identity creation only, not activation approval.
Backfill audit records its approved manifest reference. Audit insert failure rolls
back the access change. Existing audit grants remain read-only to authorised Ops;
patient owners do not gain account-wide audit access through patient ownership.
Denied requests roll back: do not claim they persist SQL audit events. Ordinary
caller write/update/delete of lifecycle fields/audit is denied. Superuser/DB-owner
compromise is outside this privilege boundary; append-only means application roles,
not an assertion that database owners cannot tamper.

## 5. Existing sessions and complete permission coverage

An account state check is an additional AND condition, never a replacement for an
existing role/patient/consent/assignment check. No JWT state cache or token expiry
wait: every new protected DB request starting after disable commits must consult
the current row. Already-running transactions may finish; downloaded/cached data
cannot be recalled. F4 below covers previously issued storage capabilities.

Implemented together in one append-only migration:

- Add a restrictive active-account policy for every RLS-enabled public table with
  authenticated grants (reads and applicable writes), including profiles,
  patient_access, consents, companions, trips/events, notifications/audit, lookups,
  schedules and vault/billing tables. Preserve all existing permissive policies;
  an extra permissive policy would incorrectly OR the lifecycle check.
- Read lifecycle in owner-defined private helpers with empty search_path and fully
  qualified names, without RLS recursion. current_app_role returns null for inactive callers; access_level_for additionally
  requires Family role. An accidental patient link cannot turn Companion/Ops into
  a Family owner or give Companion clinical access. This intentional restriction
  enforces the existing role boundaries without deleting grant/consent rows.
  View/edit/is_ops helpers retain their role-specific conditions. Grant only helper execution needed by existing policies.
- Guard every authenticated security-definer RPC at entry, including direct-UID
  paths verify_pickup_otp, advance_trip's assigned-companion branch,
  companion_my_trips, my_notifications, create_patient and set_consent. RLS alone
  cannot secure a definer function. Cover all boards, vault and payment_start too.
- Preserve only pre-existing explicitly permitted trusted-backend branches and
  service-only reconciliation/dispatch/file-confirmation contracts. Do not create
  a global service bypass. Old browser JWTs cannot invoke those service-only RPCs. New dispatch claims
  must additionally exclude pending/disabled recipient accounts, retaining queued
  rows/history; already claimed deliveries are in-flight work under F4.
- Check candidate account state in assert_companion_eligible so disabled/pending
  companions cannot be newly assigned. Do not automatically cancel/reassign
  existing visits, change trip transitions or add active-trip reassignment.

Keep protected exceptions generic 42501; the self resolver supplies safe lifecycle
feedback. Tables may return zero rows under RLS, which clients must not relabel as
pending. Current app wiring consumes the resolver on OTP/restore/resume, Auth events,
explicit recheck and protected-request denial; clear protected navigation/data on
invalidation and ignore stale responses. No polling/realtime dependency is needed
for DB enforcement; a foreground UI may learn about disable on its next recheck or
protected request. No claim that remote disable instantly erases an idle screen.

Vault Edge handlers already authorise with the user JWT before signing; newly
requested URLs/confirmation fail once disabled. Previously issued download/upload
URLs bypass later lifecycle checks until their own expiry; the source download
setting defaults to 60 seconds, not proof of the hosted setting. Upload validity
must be measured with the actual Storage stack; it is not set by that download
setting. Service callbacks may still reconcile already-authorised work; they do
not reactivate accounts or create patient consent. No key rotation/object deletion
or new proxy is part of this smallest design.

## 6. Safe backfill and cutover

No blanket UPDATE to active, role inference from patient links, or blanket disable
of unknown users. F2 chooses actual classification; technical rollout is fixed:

1. Inspect a read-only inventory of all existing Auth/profile UUIDs and current
   roles; identify missing profiles, Auth bans/deletions, duplicates and unexpected
   role mappings. Names, phones and real records stay out of tracked evidence.
2. Obtain a complete reviewed manifest: each existing profile UUID, expected current
   role, desired state and approval reference. Recommended F2 preserves known
   approved pilot users as active in their exact current role. Any known disabled/
   banned/revoked identity needs explicit classification, not inferred reactivation.
3. Synthetic pilot only: supply the reviewed UUID manifest on the owner migration
   connection in anuga.pilot_backfill_manifest (session setting), with no phone/name/
   credential. The migration embeds no roster and classifies nobody by default. Empty DB is a separate supported path
   with no backfill. Nonempty DB must match its full reviewed manifest exactly;
   unknown/missing UUID, role mismatch or missing profile aborts before cutover.
   Never commit a real-user manifest; a real-data rollout is separate M10 work.
4. During an authorised maintenance window, one transaction locks Auth/profile
   creation/writes long enough to revalidate that manifest, adds pending-default
   columns, classifies/audits existing rows, and enables all guards. No exposed
   intermediate pending-all state, missing-row fallback, enforcement feature flag
   or partially applied migration. Lock order/timeouts are tested; failures roll
   back the whole transaction. Snapshot/check patient grants/consent unchanged.
5. Empty-stack seeds/tests explicitly activate only their synthetic fixtures via
   the owner path; new Auth users still start pending. Cutover to populated pilot
   requires the approved manifest and a verified operator/recovery account. Recheck
   exact client artifacts, sessions and SQL tests before any later release authority.

Only disposable synthetic backfill rehearsals ran: exact match passes; unknown,
duplicate, absent-profile, role mismatch and audit failure abort atomically. The
offline checker refuses non-synthetic input before classifying it. No hosted-user
inventory or real-user backfill ran. Local source config disables public signup
globally; email/SMS providers remain enabled for existing-user sign-in. Hosted Auth settings are
unknown and unchanged.

## 7. Rollout decisions (all four assumed provisionally for local development)

| ID | Business decision | Recommended default | Concrete impact |
| --- | --- | --- | --- |
| F1 | Who authorises activation/disable/reactivation and Ops-admin provisioning, and who is the trusted operator? Ops pilot-user provisioning is already accepted. | Active Ops authorises Family/Companion; founder alone authorises all Ops-admin changes; founder names the operator | Ops can run pilot onboarding without gaining browser admin privileges; founder must handle new/replacement Ops and last-admin recovery |
| F2 | Which existing identities are already approved, pending or disabled? | Review the entire synthetic roster; preserve confirmed pilot users active with unchanged roles, explicitly classify others; stop cutover on any unknown | Known approved users retain access; no default Family profile is silently approved and no unknown user is silently locked out; roster review is required |
| F3 | What happens operationally on disable/reactivate? | Disable account access on next new DB request even during a visit; active Ops handles ongoing work using existing permissions. Reactivate only by explicit authority, preserving only surviving grants/consents; do not cancel/delete/regrant or invent consent | Disabled Companion/owner cannot keep acting; another authorised Ops may need to resolve a visit; new dispatch claims stop for inactive recipients. Other linked users and prior owner consent stay governed by existing records; withdrawn consent/revoked grants never return |
| F4 | Does the pilot accept bounded residual access from issued URLs/in-flight work? | Accept existing capability expiry and already-started work, require actual download/upload TTL evidence; block all new protected DB/URL authorisation after disable | A previously issued URL can still work for its remaining lifetime and cached data remains. If immediate file revocation is required, this small task is insufficient: separately scope storage/proxy enforcement before rollout |

Architecture, helper design, column types, versioning, audit store, migration
atomicity and test strategy are engineering decisions above, not founder blockers.
The latest request authorises implementation using these four defaults only as
provisional development assumptions. Actual F1-F4 answers, a reviewed real rollout
roster and a designated real operator still gate any rollout. No authority or
consent is inferred from a successful synthetic test.

## 8. Patient permissions and ANU-003 remain separate

Activation enables the existing role only. It never calls create_patient,
set_consent, creates patient_access, selects a patient access level or overrides
withdrawn consent. create_patient is Family-only and has its existing owner/trips
consent effects; this task adds no caller. Ops account provisioning does not grant
patient-creation or owner-consent authority. Disabling an owner does not delete
patient data/grants or manufacture consent withdrawal; F3's effect on surviving
records needs actual founder agreement. Companion vault/diagnosis/DOB denial and
Ops owner-consented audited vault access remain unchanged for active accounts.

ANU-003 remains separately owned/unassigned, with its home/spec paths untouched.
It consumes the final resolver; zero patient links is not a readiness signal.
Patient/schedule creation actor, consent capture and actual help destination remain
its separate dependencies, not reasons to expand this backend lifecycle task.
