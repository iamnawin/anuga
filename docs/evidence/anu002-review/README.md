# ANU-002 pre-commit review receipt — 17 October 2026

**Implementation locally complete and reviewed. Overall ANU-002 remains Partial**
for device, human language/accessibility and rollout acceptance. F1-F4 remain
provisional local assumptions, unapproved for rollout. No real roster was
classified or real privileged operator designated. No push, merge, deploy or
hosted modification. Latest founder request authorises this owned local commit.

Branch `docs/product-inventory-bootstrap`, implementation base `69bbb36`, fetched
main `64c4603`. This receipt belongs to the ANU-002 implementation commit; obtain
its exact hash with `git log -1 --format=%H -- docs/evidence/anu002-review/README.md`.
The earlier [implementation receipt](../anu002-lifecycle/README.md) and its source
manifest are historical pre-review snapshots, preserved unchanged in this step.

## Review result

PASS: no concrete permission escalation, existing-session bypass, unsafe backfill
or audit defect found. Coordinator reviewed entry/client/Storage paths; an
independent read-only backend reviewer inspected the migration, classifier,
seed/support, existing helpers/RPCs and permission/migration/concurrency tests.
The reviewer made no edits and independently passed 15 lifecycle/backfill/migration
tests. One writer remained responsible for all changes.

- Management: no authenticated/service execution of the owner-only command;
  direct role/state changes require owner context and audit references. Role
  assignment is pending-only; expected-version CAS and row locks prevent stale
  updates. Human authority is verified outside the DB, never inferred from a string.
- Existing sessions: restrictive RLS and guards at the start of authenticated
  definer RPCs consult the current profile. Resolver exposes only the caller's
  safe state/active role. Trusted service operations retain existing restrictions.
  Client checks supplement rather than replace database enforcement.
- Backfill: one transaction locks creation/profile writes, validates the exact
  manifest before DDL, audits classifications and enables guards. Unknown/missing/
  duplicate/mismatched records, audit failure and lock timeout abort atomically.
  Offline tooling refuses unlabelled/non-synthetic inputs and writes no DB state.
- Audit/patient boundary: state/version/audit commit together; activation never
  creates patients, grants or consent, and reactivation cannot restore revocations.
  Family-only grant interpretation prevents cross-role clinical escalation.
- Signed files: new signing/confirmation is denied after disable. Preissued URLs,
  cached data and in-flight work retain the documented residual access. Download
  expiry was observed at 60 seconds; upload claims measured 7200 seconds. Actual
  upload expiry rejection used a separate five-second same-image probe; the full
  two hours were not observed and hosted TTLs remain unknown.

Concrete review corrections:

1. Strengthened the lifecycle regression to assert every operator audit detail and
   that an idempotent activation retry changes neither version nor audit count.
   Production code needed no change. Updated the task's RPC coverage wording:
   catalog tests require 42501 before validation using typed NULLs, supplemented
   by valid-fixture and real old-JWT paths; they do not use valid arguments for
   every signature.
2. Reconciled superseded backend-blocked/uncommitted statements with locally
   complete implementation and the latest commit authority. Kept historical phase
   receipts and all open rollout/device/human acceptance explicit.
3. Curated `.log` files are globally ignored; explicitly include only the reviewed,
   secret-scanned evidence logs so linked verification survives the commit. No
   local environment, stack startup/inspect logs, build output or credentials.
   Normalised selected logs/backfill reports to LF and removed trailing whitespace
   exposed by the staged check; their evidence payloads remain unchanged.

## Verification and evidence

Initial evidence audit: all 63 saved changed/added source hashes matched before
review edits; real DB log confirms 166/166 with zero skips; real Flutter Companion
1/1 and Family 2/2; Auth/Storage results, 21 lifecycle/live-disable browser cases,
six locale scenarios and three session-isolation results agree with the receipt.
42 lifecycle and 25 earlier entry captures are preserved. Saved real runs were
not relabelled as newly rerun browser/device tests.

Current review reruns:

- Full `bash scripts/check-all.sh`: PASS. PGlite 157 pass/9 real-only skips;
  Ops lint/typecheck/build and 60 tests; shared Dart format/analyze and 28 tests;
  Companion 51 pass/3 integration skips; Family 49 pass/6 integration skips.
  [Fast log](check-all.txt).
- After strengthening assertions: `node --test
  supabase/tests/pilot_account_access.test.ts`: 11/11, zero skips.
  [Audit regression](audit-tests.txt). Fast-run DB tests preceded this assertion
  extension; this targeted run and the real rerun cover the final test source.
- Root `pnpm typecheck`: PASS. [Typecheck](typecheck.txt).
- Real local PostgreSQL/Auth/Edge suite rerun and final scope results are recorded
  in [verification](verification.json), [real log](real-db-tests.txt),
  [source hashes](source-hashes.json) and [scope checks](scope.json).

No production/auth/routing/Storage implementation changed during review. Existing
real Auth/Storage/browser evidence therefore remains applicable; it was inspected,
not repeated. Android SDK/device is absent; no iOS/macOS/Xcode; Windows native
build prerequisites incomplete. Human Telugu/Hindi copy review, screen readers,
mobile lifecycle/keyboard/offline and full accessibility matrix remain open in
[ANU-002-VERIFY](../../delivery/tasks/ANU-002-VERIFY.md). Real SMS, actual F1-F4
approval, reviewed rollout roster/operator and hosted acceptance remain unperformed.

## ANU-003 inspection only

[ANU-003](../../delivery/tasks/ANU-003.md) is an **unassigned documentation-only
Family first-use/home specification**, not an implementation authorisation.
Its entire write scope is these three files, unchanged by this review:

1. `docs/delivery/tasks/ANU-003.md` — its task and contributor receipt.
2. `docs/product/screens/SCR-FAM-001.md` — Family home, design 13–14.
3. `docs/product/screens/SCR-FAM-032.md` — simplified Patient-home concept 25.

Specify zero linked patients versus linked/no bookings, multiple patients,
revoked/denied access, loading/failure/retry and populated states; owner/editor/
patient/viewer controls; patient-switch/default/stale-content/back/tab behavior;
existing components and 360/430/wide, dark, keyboard, en/te/hi and 1.15/2x/3x text.
Preserve database permissions, existing viewer vault reads and pickup OTP versus
login OTP distinctions. No source/API/Auth/tokens/inventory/shared-handoff edits,
new onboarding wizard, simplified-mode router, help workflow or backend changes.

Dependencies resolved locally: ANU-002 self resolver, authoritative lifecycle,
restore/recheck behavior, no registration and separate provisioning versus grants/
owner consent. ANU-003's older “readiness representation unresolved” wording is
stale against this local contract; its owner must reconcile it in its own task.
Its suggested main base `64c4603` lacks ANU-002, so explicitly reference this
reviewed implementation commit as the contract input when assigning the package;
do not assume it has reached main or the deployed site.

Remaining decisions blocking new setup/help/patient-mode controls: authorised
patient/schedule creation actor and procedure; owner-consent capture; actual help
contact/destination; whether/how Patient-home replaces or supplements Family
home. Current `create_patient` is Family-only with owner/trips-consent effects;
Ops provisioning does not grant patient creation or owner-consent authority.
The current no-patient home has no refresh/setup CTA and initial-load errors lack
retry; document those gaps without promising an unbuilt action.

Existing-state specification can proceed independently while recording those
decisions as open. Real rollout operator/roster and ANU-002 device/human acceptance
still gate rollout, not read-only specification work. No ANU-003 file was edited,
owner assigned, branch created or implementation started in this review.
