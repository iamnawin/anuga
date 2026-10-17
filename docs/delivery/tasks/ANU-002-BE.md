# ANU-002-BE - account lifecycle backend implementation package

Parent: [ANU-002](ANU-002.md), FEAT-001, SCR-AUTH-001-007. Status: **Implementation locally complete and reviewed under provisional assumptions; rollout gated**;
owner Codex coordinator, sole writer; parent remains Partial/unreleased. This is a child
package, not a new top-level product task. The latest local reservation below
supersedes the original proposed path/approval gate for development only.
Spec: [pilot access contract](../../product/PILOT_ACCESS_CONTRACT.md).

Goal: explicit pending/active/disabled profiles, self-only access resolution,
audited owner-operated provisioning and DB enforcement for old and new sessions.
Architecture: existing profiles + audit_log + private helpers/restricted RPCs/RLS;
no new service, role, admin UI or lifecycle table. Stack: existing Postgres/Supabase
and Node DB harness; no new dependencies. Execute sequentially with one backend
writer after coordinator reservation; no parallel agents are authorised here.

## Entry conditions and ownership

Latest review authorises the ANU-002-only local commit after checks; earlier
no-commit instructions below record preceding phase boundaries. No push, merge,
deploy or hosted changes. [Review receipt](../../evidence/anu002-review/README.md).

- [ ] Record actual founder answers F1-F4 and reviewed synthetic backfill manifest;
  proposed defaults are not approval. Confirm named operator and real authority
  references. No operational/production action is authorised by this document.
- [x] Fetched main and preserved entry work; exact hashes recorded. Latest authority
  reserves the existing isolated integration worktree/branch to the sole coordinator
  rather than creating a second backend branch without the entry changes.
- [x] Coordinator reserves the original paths below plus the explicit expansion
  in the local-development reservation; checked S6/PR #10/#11
  overlap. Apply no PR snapshots or old migrations incidentally.

| Original planned path (expanded below) | Purpose |
| --- | --- |
| supabase/migrations/20261016001000_pilot_account_access.sql | One new atomic lifecycle migration; verify filename is unused before implementation |
| supabase/tests/pilot_account_access.test.ts | State/resolver/RLS/RPC/audit/backfill/transaction tests |
| supabase/tests/support/db.ts | Explicit lifecycle fixtures and migration-on-populated-DB harness only |
| supabase/seed/seed.sql | Explicit synthetic fixture activation with audit context; never a hosted seed reset |
| docs/delivery/tasks/ANU-002-BE.md | Backend contributor receipt |
| docs/SETUP.md | Operator/backfill/recovery procedure, coordinated with coordinator |

Read-only inputs: migrations 0100-0900 and existing DB/function tests, current
app Auth adapters/providers, shared Dart and the contract. Coordinator alone
integrates shared docs/board/handoff/evidence. No application, Edge handler,
shared-Dart, package/lockfile, existing migration or ANU-003 path writes. If a real
API/function test needs a change outside the reservation, report and reserve that
specific test path before editing; do not silently widen ownership.

## Interfaces and migration requirements

- profiles.account_state: pending/active/disabled text check, NOT NULL/new-user
  default pending; account_state_version bigint starts at 1, owner-maintained.
- public.my_account_access(): no parameters, authenticated only, returns JSON
  object {state, role}; inactive role null; missing profile unconfirmed. No new
  patient data or arbitrary-user lookup. Revoke PUBLIC/anon execution explicitly.
- private.account_is_active() and assert_active_account(): self DB read, empty
  search_path/qualified identifiers, no recursive RLS or cached JWT state.
- private.configure_pilot_account(target UUID, expected version bigint, new state
  text, optional pending role public.user_role, reason text, operator reference
  text, authority reference text): owner-only, no API/service management grants;
  returns resulting state/role/version. Record actual authority externally first.
  Lock/CAS; deny role change from active/disabled, blank reasons/references and
  unsupported transitions. Same-state/same-role no-op never implies a new approval.
- Audit trigger: initial pending, actual role/state change and backfill events;
  old/new values, version, real actor/context; audit failure rolls back mutation.

Migration must be atomic over schema + reviewed existing-user backfill + auditing +
enforcement. Nonempty database UUID/expected-role set must exactly match the approved
synthetic manifest; unclassified/missing-profile/role mismatch aborts, no guesses.
Fresh empty DB needs no backfill; seed fixture activation is explicit and does not
change new-user defaults. Lock Auth/profile creation/writes during final manifest
validation; bound lock wait and rehearse concurrent account creation. All existing
roles, patient_access, consents, schedules and trip rows stay unchanged by backfill.
No real-user manifest or secret enters the repo. No enforcement-off rollout flag.

Restrictive active-account policies supplement every authenticated table-grant
surface. Update existing role/access helpers, add explicit active guard to each
user-callable security-definer RPC and check candidate companion state for new
assignment. A catalog-derived permission inventory must enumerate all such tables,
RPC signatures and pre-existing service exceptions from final definitions (0900
replaces earlier ops_trip_board). Cover direct-UID bypasses, not only is_ops.
Account restriction must not broaden any existing row/column/RPC permission.
Preserve existing service-only callbacks; suppress new notification claims for
inactive recipients as specified in the contract, without deleting queue/history.

## Test-first execution and local acceptance

Checked items refer to synthetic local runs only; actual authority/operator and
rollout acceptance remain open. File denial means new authorization; previously
issued capabilities have the measured residual lifetime in the current receipt.

- [x] Add failing lifecycle tests with separate active, pending, disabled, missing
  profile and unknown-phone cases. Existing fixture helpers explicitly establish
  active test identities; never make all new users active to keep old tests green.
- [x] Implement the single migration and fixture changes. Rehearse empty migration
  then seed, populated approved backfill, unknown UUID, altered role, missing
  profile, lock contention and injected audit failure. Every failed migration
  leaves the old schema/access unchanged; no partially active cutover.
- [x] Active role matrix preserves previous allowed AND denied behavior for Family
  owner/editor/patient/viewer, assigned/unassigned/unverified Companion and Ops.
  Verify account activation adds no patient grant/consent/companion verification.
- [x] Pending/disabled cannot read protected tables, alter own profile fields,
  create patients, change consent, issue/verify pickup OTP, advance assigned trips,
  read own notifications, sign/upload/confirm/download files or start payments.
  Catalog checks invoke ALL user RPC signatures with typed NULLs and require 42501
  before argument validation. Representative valid-fixture RPCs and real old-JWT
  paths are also exercised. Resolver returns own safe status; anon denied and no
  target argument is exposed.
- [x] Ordinary active Ops/Family/Companion cannot set lifecycle/role/version or
  invoke the private management command; revoked/withdrawn patient records never
  reappear on reactivation. Active Ops retains existing consented vault limits;
  active Companion still cannot read vault/diagnosis/DOB. An active account with
  no links/trips reaches its existing empty state, not implicit provisioning.
- [x] State/version/audit commit together; stale versions, direct privileged writes,
  no-op retries and audit failure have explicit assertions. Last-admin recovery
  uses recorded founder authority and the owner path, never app self-promotion.
- [x] Real Supabase old-JWT request after disable commit is denied without waiting
  for logout, token expiry or UI recheck; reactivation permits only surviving
  permissions. Record request-start/disable-commit boundary for in-flight cases.
  New assignment/notification claim rejects inactive targets/recipients.
- [x] Signed capabilities are tested under F4; no assertion of immediate file
  revocation based only on a DB test. See verification package for actual Auth,
  Storage and device acceptance. No fixture result substitutes for these checks.

Commands: pnpm db:test; pnpm typecheck; pnpm contract:export and both SQL/Dart
contract suites (verify no trip-transition drift); scripts/check-all.sh;
pnpm db:test:supabase with an isolated local Supabase/Docker environment and its
required DATABASE_URL. Run actual Supabase Auth/Storage verification from the
verification package too. Do not reset a hosted project or weaken/skip a failing
permission test to claim completion. Capture exact SHA/uncommitted source hashes,
allowed/denied counts, skips and remaining client-integration work.

## Rollback and stopping rules

Before cutover: failed manifest/lock/audit/assertion rolls back the single transaction;
leave existing users/roles/grants untouched, fix the reviewed input and rehearse again.
No deployment with an unclassified identity or unverified recovery operator.

After cutover: prefer a forward corrective migration. Retain lifecycle columns,
audit history and all deny enforcement; reverting only the UI cannot restore access
for pending/disabled users. An erroneous disable is repaired per user through the
same reviewed/audited operator path; never bulk activate as rollback. Keep active
Ops recovery available through the owner connection if last-admin disable occurred.

Removing guards would restore pending/disabled access: it is a separate explicit
founder-approved access-policy reversal, not an automatic down migration. Do not
drop state/audit records or replay stale patient grants/consent. Rehearse fix-forward
and per-user recovery tests on synthetic local data before later rollout authority.

Loop: one failing scenario -> minimal change -> allowed/denied tests; two review
passes maximum. Stop on acceptance, no progress, contract/ownership conflict or risk.
Finish receipt lists exact paths/SHA/commands/skips and rollout/rollback rehearsals.
No commit, push, merge, hosted mutation or deploy without new task-specific authority.
Backend completion alone does not complete ANU-002: its resolver/client integration
and verification package must still pass. ANU-003 is not this task.

## Active local-development reservation (2026-10-17)

Latest founder request authorises local BE + resolver/client integration using F1-F4
as provisional development assumptions, NOT rollout approval. Owner: sole Codex
coordinator in existing isolated docs/product-inventory-bootstrap worktree; preserve
all uncommitted entry work. No real operator designation/real-user classification.
Source reservation expands sequentially to listed migration/tests/seed/support plus
supabase/scripts/pilot-backfill.ts and its tests, shared_dart phone-auth model/tests,
both Flutter auth/RPC adapters/app roots/localisations/fake auth/access tests, Ops
AuthProvider/OpsShell/ApiProvider/auth-access messages/tests and local synthetic
Auth/Storage/browser verification scripts. No ANU-003 home/spec ownership changes.
Coordinator updates shared inventory/handoff. No old migration changes, hosted
environment action, commit/push/merge/deploy. Local stack is disposable/synthetic.

Final local scope addition: supabase/config.toml disables public signup globally, retaining enabled email/SMS
providers so Admin-provisioned users can sign in. This is local
configuration only; hosted Auth settings are not read or changed.

## Implementation receipt (2026-10-17)

HEAD 69bbb36, main 64c4603, docs/product-inventory-bootstrap; all changes uncommitted.
F1-F4 provisionally assumed per latest user request, never approved for rollout.
No real operator designation or real-user classification/modification.

Implemented profiles state/version, audited owner-only management, self resolver,
restrictive RLS and every authenticated definer RPC guard. Added candidate/dispatch
inactive checks and Family-only patient-grant interpretation: even an accidental
Companion/Ops link cannot grant Family-owner/clinical authority. No automatic
patient/access/consent mutation; deliberate synthetic revocations prove no restoration.
Default Auth profiles remain pending; metadata cannot activate or select a role.
Source local Auth signup is disabled; existing Admin-provisioned OTP works.

Implementation deviation from planning: a populated migration reads a complete
manifest from the owner connection session setting anuga.pilot_backfill_manifest.
It embeds no static roster; missing/unknown/duplicate/role mismatch aborts before
cutover. Offline synthetic checker reports seven matched fixtures and exit 1 for
an extra unknown identity; rejects non-synthetic input without classifications.

Scope also includes both Flutter main/auth/RPC/app roots, shared PhoneAuth access
model and events, Family file/payment lifecycle-denial callbacks, Ops auth/API
resolver events and en/te/hi labels. Existing apps, session keys/channel isolation,
patient home/wizard ownership and trip transition contract are preserved.

[Actual commands/results/source hashes and screenshots](../../evidence/anu002-lifecycle/README.md)
own verification. Local real Auth, Storage, SQL and browser tests are acceptance
evidence for this local implementation only. Native device/language/reviewer and
rollout gates are listed in ANU-002-VERIFY; neither task grants deployment authority.

No earlier planned path restriction authorises editing ANU-003; no home/spec paths
were touched. No commit/push/merge/deploy or hosted environment change occurred.
