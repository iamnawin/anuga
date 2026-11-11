# BACKUP-001: synthetic backup and isolated recovery readiness

Agent: Codex, PR #28 technical integration/staging owner.
Session start: 2026-11-11 19:29:10 IST (first captured task clock).
Checkpoint: 2026-11-11 19:32:58 IST (Asia/Kolkata).
Source: `7d94feb1358e48bf40ca8c23ed216ed8c94041be`, `feat/g7-ui-staging`.
Project: existing synthetic `vsvkllfgrnlbhdydysny` only.

**Recovery readiness: BLOCKED. No backup artifact or recovery target created.**

## Work completed and preserved boundaries

Repository, HEAD, branch, remote and worktrees were verified; tracked tree was
clean, with only local `.unlazy/` untracked. PR #28 is OPEN/unmerged at task start.
ATTEST-001 was read and reused, not repeated. No builds or CI jobs were rerun.
The existing recovery and environment-attestation runbooks were reviewed against
current official Supabase backup documentation and CLI 3.1.0 help/source.

No source database dump/query, password reset, temporary login-role creation,
data/schema/user/RLS change, migration/history repair, backup restore, project
creation, merge or deployment was attempted. Other worktrees and PRs #29/V2/#30
were not modified. Only this sanitized receipt and tracking changes are pushed.

## Safest supported method and current capability

The official logical route is a `pg_dump`-backed export of roles, schema and data,
with managed-schema customizations, migration history and Storage bytes handled
explicitly. Supabase recommends CLI exports/off-site copies for free-tier projects.
The current account's exact billing plan label was not established; do not infer
the plan from an empty backup listing. ATTEST-001's observed capability is reused:
`walg_enabled=true`, `pitr_enabled=false`, no listed physical restore points.
There is no demonstrated downloadable backup to reuse.

The source must be preserved as actually hosted, including manual SQL changes and
the divergent migration ledger. The committed migrations plus seed reconstruct
a baseline, not the current synthetic project or its test-created records.

| Prerequisite | Actual check/result | Consequence |
| --- | --- | --- |
| Supabase CLI | Existing `pnpm dlx supabase@3.1.0` help available | Management access from ATTEST-001 does not imply safe direct dump credentials |
| Docker runtime | Not on PATH; standard Docker Desktop binary absent | Documented CLI container dump cannot run here with existing tooling |
| Native PostgreSQL tools | `pg_dump` and `psql` not on PATH; standard PG17/18 binary paths absent | Native logical-export/restore alternative unavailable with existing tooling |
| Protected direct DB connection | No `PGSERVICE`, `PGSERVICEFILE`, `PGPASSFILE`, `PGPASSWORD` or `SUPABASE_DB_PASSWORD` supplied; usual per-user libpq service/password files absent | No discovered existing direct connection credential; no credential store was searched or exposed |
| Passwordless remote dump | CLI help may require `database_write`; official CLI source creates a temporary login role when no DB password is supplied | Incompatible with this task's strict no-hosted-role-change boundary; not invoked, even with dry-run |
| Existing isolated target | None identified/approved for this restore; no local Docker runtime | Restore NOT TESTED; no unrelated/inactive hosted project reused |
| New hosted target | Could create billable resources; no specific approved target/budget | No provisioning performed |

The documentation's suggested password-reset step is not authorized here and was
not followed. Installing Docker/native clients alone would not resolve missing
safe direct database access or restore-target authorization, so no tooling was
installed for this blocked export. No custom JSON row export was substituted for
a supported, restorable database backup.

## Recovery coverage inventory

This is an explicit inventory/plan, not a claim that anything was exported.

| Component | Required recovery coverage | Backup versus reconstruction | Current state |
| --- | --- | --- | --- |
| Application database | Actual `public` and `private` DDL, functions, policies, grants, constraints, triggers, sequences/defaults and all application rows | Logical schema + data + role/ACL export; preserve private notes/audit/billing/notification/OTP data only in protected artifacts | NOT EXPORTED |
| Migration ledger | Actual `supabase_migrations.schema_migrations`, including legacy version names/statements and manual-change evidence | Explicitly include history; do not rewrite it to match Git during backup | NOT EXPORTED; prior catalog receipt retained |
| Auth records | Required managed `auth` data, users/identities and dependent tables, with consistent relationships and version compatibility | Verify managed data coverage in the chosen export; platform-managed DDL is recreated by compatible Supabase, not blindly overwritten | NOT EXPORTED |
| Auth configuration | Phone/provider/test mappings, redirect URLs, signup/session/rate-limit/CAPTCHA settings | Separate protected configuration inventory/reconstruction; sensitive mappings and provider credentials stay outside Git | NOT CAPTURED; actual values not retrieved |
| Auth sessions and credentials | Define whether sessions are restored or deliberately invalidated; preserve required credential material only through supported custody | Cannot promise that old sessions/JWTs/passwords work in a new project; custom-role passwords require separate secure reconstruction | NOT VERIFIED |
| Storage metadata | Buckets, object ownership/metadata, policies, MIME/size limits and custom managed-schema changes | DB metadata plus separately reviewed custom DDL; owner references must reconcile with restored Auth | NOT EXPORTED |
| Storage file bytes | Every in-scope object version/key/size/hash and binary contents | Separate authorized Storage/S3 export; database backup contains metadata, not bytes | NOT EXPORTED; no Storage credential requested or generated |
| Edge Functions | Exact deployed source/version, entry settings/JWT verification, enabled function inventory | Capture deployed version; Git is a reconstruction input only after comparing deployed source | NOT EXPORTED; repository code available |
| Secrets and encryption | Secret names/custody references, provider settings, required Vault/column encryption keys where applicable | Separate secure custody/import procedure; never plaintext in Git or receipt; DB role dumps do not guarantee passwords/key custody | NOT VERIFIED |
| Platform configuration | Extensions/versions, custom auth/storage triggers, publications, cron/webhooks, network settings and outbound destinations | Separate compatibility/reconstruction checklist; suppress delivery and charging on recovery target before runnable jobs restore | NOT CAPTURED |
| Application hosting | Existing Vercel source/artifact IDs, public backend configuration, routes and environment scopes | Reconstruct from reviewed artifacts and protected settings after DB compatibility check; deploying is outside this task | Existing Git/runbook evidence only |
| Recovery manifest | Source identity, UTC/IST times, tool versions, artifact sizes/SHA-256, counts, coverage/exclusions and restore instructions | Store beside encrypted/access-restricted artifacts outside repo and synced/public folders | NOT CREATED because export is blocked |

Application-table inventory reused from ATTEST-001: 24 ordinary tables across
`public`/`private`, including `private.trip_event_internal_notes`; patient/access/
consent/companion/schedule/trip/event/OTP tables; vault documents, vitals,
medicines; invoices/lines/payments; notification outbox/deliveries; audit/config/
package/centre/cluster/profile tables. No application/Auth row or Storage byte
was read in BACKUP-001. No assertion of complete recovery is inferred from counts.

Default CLI schema export excludes platform-managed schemas and omits data/roles.
Custom `auth`/`storage` policies/triggers need separate verification. Select
explicit coverage rather than assuming one `schema.sql` file is sufficient.
Exports taken separately also need a consistent snapshot/quiescence strategy;
separate file hashes alone do not prove relational consistency across components.

## Protection, checksums and restoration evidence

- Protected backup artifact: **NONE CREATED**, blocked before source export.
- Backup SHA-256 checksums: **NOT APPLICABLE**, because no backup files exist.
- No source data, passwords, tokens, object paths or backup contents enter Git.
- Future exports must write directly into a preapproved access-restricted,
  nonsynced directory outside all worktrees, with encryption/key custody and an
  independent retained copy. Gitignore alone is not protection.
- Isolated recovery: **NOT TESTED**; no source restore, new project, local stack,
  billable resource or outbound job was created/executed.
- RPO/RTO, recovered counts, file-byte hashes, role-denial tests and measured
  recovery time: **UNKNOWN/NOT TESTED**. Written instructions are not a drill.

## Exact blocker and proposed next single task

The supported logical-export route lacks both a runnable PostgreSQL dump toolchain
and a discovered protected direct DB connection. The available passwordless CLI
route can create a hosted login role, which is prohibited. A safe isolated restore
target is also not yet provisioned/explicitly approved. Existing management SQL
read access is not evidence of a full supported backup path.

**Proposed next single task: BACKUP-ACCESS-001.** Have the staging owner establish
an existing direct/session-pooler connection in a protected libpq service/password
file outside Git (no credential in chat; no reset/new role under this scope), and
make a compatible official PostgreSQL client/Docker toolchain available on the
operator machine. Identify a separate approved restore target and its no-charge/
outbound-isolation constraints. Reattempt backup only after these prerequisites
are reviewed. Backup/restore execution, migration repair/application and deployment
remain separate subsequent review checkpoints.

## Primary sources reviewed

- [Supabase CLI backup/restore](https://supabase.com/docs/guides/platform/migrating-within-supabase/backup-restore): roles/schema/data exports, Docker/connection prerequisites, managed-schema customizations and restore limitations.
- [Supabase backups](https://supabase.com/docs/guides/platform/backups): free-tier export recommendation, backup coverage and exclusion of Storage bytes/custom-role passwords.
- [CLI database connection source](https://github.com/supabase/cli/blob/develop/apps/cli/src/command-internal/db-config.layer.ts): passwordless remote initialization creates a temporary login role. CLI 3.1.0 local help confirms `database_write` may be required without a password.

STOP for founder review. No migration-history reconciliation or missing migration
application is started by this receipt.
