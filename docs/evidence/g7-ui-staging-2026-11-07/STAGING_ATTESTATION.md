# Read-only synthetic staging attestation

Agent: Codex, PR #28 integration/staging owner.
Observed: 11 November 2026, 19:13-19:17 IST (Asia/Kolkata).
Source: `8646f569a58a9b1508af23c6e0aa19c672bc93a6`, `feat/g7-ui-staging`.
Decision: **HOSTED PARITY FAIL; RECOVERY NOT READY; RELEASE BLOCKED**.

## CI and operation boundary

Run [43030310112](https://github.com/iamnawin/anuga/actions/runs/43030310112)
completed SUCCESS on this source SHA: all seven jobs passed. It was initially
still running; its completion was observed without rerunning any job or build.
CI builds the complete migration chain on disposable Supabase; it does not prove
that the hosted project has those migrations.

All hosted SQL used Supabase CLI **3.1.0**, explicit
`--remote=vsvkllfgrnlbhdydysny --read-only`. The returned database session reports
`transaction_read_only=on`, role `supabase_read_only_user`, database `postgres`,
Postgres `17.11`. No application RPC was invoked, including audited read RPCs,
which can write audit records. No login OTP, role/RLS/data/user change, migration,
history repair, deployment, restore or PR merge was performed.

## Exact project identity

`projects list` now succeeds using existing authenticated CLI access. The earlier
missing-token observation is superseded; no credential was printed or requested.

| Field | Current observation |
| --- | --- |
| Project / ref | `anuga` / `vsvkllfgrnlbhdydysny` |
| Organisation | `dmujucbsijrezfsvgpno` |
| Region | `ap-south-1` (Mumbai) |
| Status | `ACTIVE_HEALTHY` |
| Database version | `17.11.0.003`, release channel `ga` |
| Created | `2026-10-09T14:15:37.430054Z` |
| Database host | `db.vsvkllfgrnlbhdydysny.supabase.co` |
| Environment | Matches the repository's explicitly named existing synthetic staging ref |

CLI labels its main branch `production`; that is not real-patient approval. No
patient-row inventory was read and no assertion is made about every hosted row's
provenance or a separate production environment.

## Migration history reconciled with live definitions

There are **17 committed migration files** and **nine hosted history rows**.
None of the hosted version strings equals a committed local version string.
The first nine map by recorded name, not by identical timestamp:

| Hosted version | Recorded name | Local version with that name |
| --- | --- | --- |
| 20261009154050 | core_schema | 20261008000100 |
| 20261009154129 | access_rls | 20261008000200 |
| 20261009154301 | trip_workflow | 20261008000300 |
| 20261009154343 | vault_audited_access | 20261008000400 |
| 20261009154419 | ops_console | 20261008000500 |
| 20261009154511 | family_app | 20261008000600 |
| 20261009160002 | payments | 20261008000900 |
| 20261009160126 | notification_dispatch | 20261008000700 |
| 20261009160202 | vault_storage | 20261008000800 |

The payments history row has `statements=null`. Name correspondence does not
establish byte-for-byte equality or prove the entire original migration applied.
Do not blindly push the full local chain: timestamps/order differ and later
untracked changes are already present. History reconciliation needs its own
reviewed operator plan; no history was repaired here.

Gemini's Nov 9 receipt at remote workstream `d75cf071` reported SQL Editor
application of Oct 22-Nov 3 changes and three missing Nov 4 migrations. Current
function definitions independently corroborate the important distinction:

| Local migration | History row | Live implementation evidence / verdict |
| --- | --- | --- |
| 20261022000100 trip controls | Absent | `advance_trip` and `assert_companion_eligible` bodies match this source; controls present in inspected functions |
| 20261027000100 start time | Absent | `companion_my_trips` matches this version, not Nov 4 consent version |
| 20261027000200 create trips | Absent | `ops_create_schedule_trips` and `ops_generate_trips` match latest source |
| 20261102000100 care requests | Absent | options/requests/submit/confirm function bodies match latest source |
| 20261103000100 private issue notes | Absent | private-note table exists; `apply_transition`, exception queue and guarded resolver match this version |
| **20261104000100 pickup preservation** | Absent | **Missing effect:** `apply_transition` still sets pickup time on every transition to `picked_up`, without excluding incident resume |
| **20261104000200 consent enforcement** | Absent | **Missing effect:** old read/OTP function bodies, old trip policy, missing consent helpers and triggers |
| **20261104000300 occupancy** | Absent | **Missing effect:** occupancy function and trigger absent |

Comparison inspected 16 relevant function bodies and normalized whitespace only:
12 match their latest local definition; four match older versions. Those four
are `private.apply_transition`, `private.can_view_trip`,
`public.companion_my_trips`, `public.verify_pickup_otp`. This is a targeted source
comparison, not certification of every column/default/grant/extension or migration.

Missing helpers: `private.lock_consent_patient`, `private.assert_trip_consent`,
`private.enforce_companion_trip_consent`, `private.enforce_companion_occupancy`.
Missing triggers: `consent_patient_lock`, `companion_trip_consent`,
`companion_occupancy`. Only eight existing audit triggers were returned.

The `trips.participants` policy still checks assignment/window or Family/Ops
access, with no owner trip-consent predicate. The trip-event policy delegates
to the old `private.can_view_trip`. Therefore hosted consent withdrawal and
occupancy cannot be treated as enforced. No unsafe mutation probe was attempted.

## RPC signatures, role permissions and privacy

The expected catalog entries/signatures exist for Family patients/board/timeline,
care options/requests/submission, Companion trip projection, pickup code issuance/
verification, visit advance, Ops boards/options/confirmation/assignment/issue
resolution, and vault functions. Signature availability is compatible with the
client call shapes; their semantics are **not** at the complete hardened baseline.

- All 24 inspected `public`/`private` ordinary tables have RLS enabled.
- `anon` and `authenticated` are non-superuser, non-login, non-RLS-bypass roles.
  `service_role` has RLS bypass, as expected for trusted backend use.
- No public function in the inspected catalog grants effective EXECUTE to anon.
- App RPCs generally grant EXECUTE to the shared `authenticated` database role;
  Family/Companion/Ops authorization is checked inside functions, not by that
  common grant alone. Inspected source-matching Ops/Family implementations retain
  their role checks. No per-user hosted JWT test is claimed by catalog reads.
- `private.trip_event_internal_notes` has RLS enabled and denies SELECT to anon,
  authenticated and service_role. `private.apply_transition` is not executable
  by those roles. Existing private issue-note boundaries are present.
- Direct trip OTP and vault-document SELECT is denied to app roles; authenticated
  direct trip/schedule/event INSERT/UPDATE is denied. Participant reads use RLS.
- Inspected function security-definer configurations use empty search paths,
  except platform `public.rls_auto_enable` uses `pg_catalog` and has no app-role
  execution grants. No new issue was inferred from that platform exception.
- `vault` bucket is private, 10 MiB limit, JPEG/PNG/WebP/PDF MIME allow-list.
  Storage byte inventory, Edge deployment/secrets and signed-link runtime behavior
  were not exercised in this read-only task.

## Backup and recovery readiness

Current `backups list` result: region `ap-south-1`, `walg_enabled=true`,
`pitr_enabled=false`, `backups=null`, `physical_backup_data={}`.
This corroborates Gemini's no-listed-backup/PITR observation (earlier `[]`, now
`null`). WAL-G enabled alone does not prove a usable backup or restore point.

No verified usable backup/restore artifact or restore drill is demonstrated.
The migration chain plus synthetic seed can reconstruct a test baseline, but
cannot recover current test-created rows, Auth sessions/configuration, Storage
bytes or all platform configuration. It is not sufficient rollback evidence.
No export, backup creation, restore, resource creation or provider call occurred.

## Retained local evidence and method

Existing `scripts/production-attestation.sql` was read first. CLI `--read-only`
rejected its explicit BEGIN wrapper before execution. The flag was retained;
a SELECT-only adapter reused its catalog queries, with the CLI owning the read-
only transaction. Four lightweight catalog/history queries read metadata only.
They were separate observations, not one cross-query consistent snapshot.

Local ignored `artifacts/` retains query adapters and results for follow-up:

- `staging-attestation-result.json`, SHA-256
  `1D5B642A0C4A24F64E302AAC2B9BC86703BB720E9E7C355B887BE384D3EC4325`
- `staging-functions-result.json`, SHA-256
  `6BDFB04740C3007B39F72B7617BDEB74C7843560673E032C7CEA650D27FF2045`
- `staging-boundaries-result.json`, `staging-history-result.json` and the local
  body-comparison script. No patient/auth rows, OTPs, secrets or object paths were
  requested. Only this sanitized receipt and tracking updates are pushed.

## Remaining release blockers and next review

1. Verified missing Nov 4 pickup/consent/occupancy behavior on hosted staging.
2. Divergent migration history, untracked manual applications and missing payment
   statement history need an evidence-backed baseline reconciliation plan.
3. No demonstrated usable backup/recovery coverage or isolated restore proof.
4. Candidate deployment/hosted allowed-denied/journey verification remains undone.
5. Physical Android Chrome/PWA and signed TE/HI healthcare review remain open.
6. PR #28 remains open/unmerged; #29/V2 and #30 are independent streams requiring
   explicit integration decisions. Their code or PR state was not changed.

**Recommended next single task:** approve a synthetic backup/recovery work item
that establishes a protected DB/Auth/Storage/configuration artifact and validates
it in an isolated recovery target before any migration rollout. Migration ledger
repair/application and deployment are subsequent separately reviewed tasks.
STOP for founder review; no automatic next action.
