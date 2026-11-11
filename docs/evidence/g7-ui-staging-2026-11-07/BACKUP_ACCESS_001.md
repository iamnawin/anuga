# BACKUP-ACCESS-001 — client and recovery prerequisites

Codex, PR #28 staging recovery owner. Start: 2026-11-11 19:36:44 IST;
checkpoint: 19:41:54 IST (Asia/Kolkata). Starting commit
`ad85d34db0111665a93f1262a6f04c52db66fc7c`, `feat/g7-ui-staging`.

**Prerequisite verdict: PARTIAL. BACKUP-002 is BLOCKED pending owner actions.**
Client tools and protected configuration scaffolding are prepared. Authenticated
source connectivity, export completeness and isolated recovery are NOT TESTED.
No dump/restore, migration, source change, paid provisioning, merge or deployment.
ATTEST-001 was reused, not repeated. #29/V2 and #30 were untouched.

## Environment and smallest client choice

| Item | Actual observation / action |
| --- | --- |
| Windows | Windows 11 Home Single Language, 10.0.26300, x64 |
| Existing clients | No pg_dump/pg_restore/psql on Windows PATH; no standard PostgreSQL installation; scoped Tools/Installers inventory found no reusable client binaries |
| WSL2 | Existing Ubuntu 26.04 LTS, kernel 6.6.87.2-microsoft-standard-WSL2; initially stopped; inspection eventually ran after WSL reported virtual-network fallback errors |
| Existing WSL Docker | Docker CLI/docker.io 29.1.3-0ubuntu4.1 exists; server query fails because /var/run/docker.sock is absent. No daemon started, runtime installed or unrelated container changed |
| WSL PostgreSQL | No inspected pg_dump/pg_restore/psql binaries; postgresql-client-17 package absent |
| Windows Docker | No PATH command, standard Desktop installation or matching service found. Docker Desktop was not installed |
| Selected clients | EDB PostgreSQL **17.11**, matching ATTEST-001's server major/minor; portable native clients, no server/service/pgAdmin installation |
| Installation | `D:\AI-Workspace\Tools\postgresql-client-17.11\bin`; explicit executable paths, no global PATH changes |
| Extracted files | pg_dump, pg_dumpall (role coverage), pg_restore, psql and nine supporting DLLs; 13 files / 12,271,258 bytes. Server binaries and graphical tools were not extracted |
| Disk | WSL inspection reported approximately 462 GiB available on D:; this is not backup-size or retention validation |

Official PostgreSQL Windows page links EDB's binary archive. Selected download
was its **17.11 Windows x86-64** link, fileid **1260616**. Archive retained outside
Git at `D:\AI-Workspace\Installers\postgresql-17.11-windows-x64-binaries.zip`,
381,531,864 bytes. A full vendor archive was downloaded; only client files were
extracted. HTTPS vendor provenance and locally computed hashes are recorded;
no independently published checksum/signature comparison is claimed.

| Artifact | SHA-256 |
| --- | --- |
| Vendor binary archive | `80379B2C04D51C30225532E0AE04509899141E9957ED096FE749D7FD9DF8F82F` |
| pg_dump.exe | `EAA2D00935E0DD55A6AD7AA2F106D013DCB4E793B7E7D2C6DF64BF5B60FBDCD7` |
| pg_dumpall.exe | `7405BB55CEF85B5F5FCB891C1F762D91F5995F013D470E6C1CB6E6D13DDD3FA7` |
| pg_restore.exe | `B91271BD574183DADD17B7DC996DD793805DE3EAB676E7F9991A067360EDF4CE` |
| psql.exe | `C290C7F0A3335F290F8C18011A1E5AFA03EE3CDD628697A5F3E767E5F1D3D10D` |

These are **tool** hashes, not backup checksums. No backup exists.

## Protected source configuration

Prepared `D:\AI-Workspace\Backups\AnugaCare\access` outside all worktrees,
OneDrive and user profile. Directory inheritance is disabled; two allow rules
grant current Windows user and SYSTEM only. Files inherit those restricted
rules. This is access restriction, not encryption; disk encryption was not
verified and no encryption settings changed.

- `pg_service.conf`: service `anuga_synthetic_source`, known attested direct
  host `db.vsvkllfgrnlbhdydysny.supabase.co`, port 5432, database/user postgres.
  Defaults to `default_transaction_read_only=on`, eight-second connect timeout,
  explicit passfile and **verify-full TLS** with a dedicated CA path.
- `pgpass.conf`: comments only, **no credential configured**. Do not use wildcard
  matches. Escape colons/backslashes as required by libpq.
- `supabase-ca.crt`: **not present**; obtain from the project's official settings.
- No credentials were printed, copied from password stores, committed, reset
  or generated. No persistent environment variables were changed. Use explicit
  session `PGSERVICEFILE` to select this nondefault service-file location.

The source endpoint is a candidate based on previous attestation and official
connection conventions, **not a newly verified Connect-dialog selection**.
Browser inventory reported `browser access host is unavailable`; no authenticated
project settings were inspected. The precise Dashboard action remains manual:
[synthetic project Connect](https://supabase.com/dashboard/project/vsvkllfgrnlbhdydysny?showConnect=true).
Confirm the project ref before selecting **Direct connection**, or **Session
pooler** if IPv6 is unavailable. Copy the actual pooler hostname from the dialog;
its cluster index cannot be inferred from Mumbai/region. Session mode uses port
5432 and pooler username `postgres.vsvkllfgrnlbhdydysny`; do not use transaction
mode port 6543 for this work. Obtain the project CA from its database SSL settings.

Existing management/API access does not supply the existing database password.
Do not substitute an anon/service-role key, passwordless CLI-created login role,
password reset or new role. Source authentication/TLS/network reachability remain
unverified; DNS inspection returned no usable result, not a certified outage.

## Appropriate checks actually executed

- All four extracted clients: `--version` exit 0, report PostgreSQL 17.11.
- Local service parsing probe used psql `-X -w`, the explicit PGSERVICEFILE and
  **hostaddr=127.0.0.1 port=1** override. It reached local connection refusal,
  proving the service could be parsed; it did **not** contact hosted staging or
  prove source connectivity. An initial invalid `servicefile` connection option
  was rejected locally, then corrected to the documented environment variable.
- Protected-directory/file ACL count and inheritance checked; password-file
  content check returned `PasswordConfigured=false` without printing contents.
- No pg_dump/pg_dumpall/pg_restore execution except version checks; no application
  tests/builds/CI reruns. Documentation whitespace validation performed.

## Isolated recovery target investigation

No recovery target was provisioned or started. Existing WSL Docker CLI can
potentially support a local Supabase-compatible stack after a separately reviewed
daemon/network/storage setup. A vanilla PostgreSQL 17 server alone is insufficient
to certify managed Auth/Storage/extensions/roles compatibility. PGlite/seed tests
also do not establish recovery of the actual hosted project.

Proposed target is a dedicated disposable local Supabase-compatible stack and
private volume/network, with no hosted integration credentials. Before restoring
runnable objects, review cron jobs, HTTP/webhook triggers, pg_net, subscriptions,
notification workers and provider configuration. Block outbound network traffic;
disable external delivery/charging and avoid public port bindings. Loopback-only
ports alone do not block outbound calls. Storage bytes and Auth/configuration
reconstruction retain the separate coverage requirements in `BACKUP_001.md`.
No existing shared Docker daemon or unrelated project should be repurposed.

Target runtime/version, resource budget, outbound firewall/network policy and
explicit provisioning/restore approval remain **pending**. Do not install Docker
Desktop or start a local daemon merely to bypass this checkpoint.

## Owner checklist before BACKUP-002

1. In the exact project Connect dialog, confirm direct versus session mode and
   privately update the protected service host/user if needed. No paid IPv4
   add-on is needed merely to use the shared session pooler.
2. Privately enter the **existing** database password into protected pgpass.conf
   for the exact host/port/database/user. Do not paste it into chat, terminal
   arguments, Git or screenshots. If the password is unavailable, report that
   blocker; reset/new role needs separate authorization.
3. Save the project's trusted CA certificate to the prepared CA path. Preserve
   verify-full; authorize a read-only native psql identity/TLS check once ready.
4. Confirm a nonsynced, access-restricted **encrypted backup destination**, key
   custody and independent retained-copy location/retention. The prepared access
   directory is not an approved encrypted backup repository.
5. Approve BACKUP-002's exact export scope/consistent snapshot plan from the
   existing DB/Auth/Storage/configuration matrix. Identify secure access for
   Storage bytes/configuration separately; never claim the DB dump covers them.
6. Separately approve an isolated local recovery target, runtime/network changes,
   resource limits and outbound isolation. Explicitly state whether BACKUP-002
   may provision and restore there, or is export-only with restore still gated.

No software-install approval is needed for the already prepared client binaries.
Do not send credentials here. Owner confirmation plus a successful read-only
identity/TLS check is required before claiming source access ready.

## Git, CI and release status

PR #28 OPEN at starting ad85d34, remote fetched; other worktrees preserved.
Run **43032867873** on 7d94feb finished FAILURE: supabase-local failed during
Playwright OS dependency installation because Ubuntu package hosts could not be
resolved. Six other jobs succeeded. This is runner dependency/DNS failure before
journey execution, not an observed occupancy or backup regression. No rerun.
Run **43034985288** on ad85d34 was IN_PROGRESS at this checkpoint (six jobs
successful; supabase-local pending). Last fully successful verified code evidence
remains 43030310112 / 8646f56. Do not infer a pass for a pending/new receipt run.

Recovery remains NOT READY; production NO-GO. Hosted missing Nov 4 hardening and
divergent ledger, absent backup/restore proof, undeployed candidate verification,
physical Android and named TE/HI approval remain open. Client setup closes only
the native-client prerequisite. Proposed next single task: **BACKUP-002**, after
the owner checklist and explicit scope approval. STOP for review.

Sources: [PostgreSQL Windows binaries](https://www.postgresql.org/download/windows/),
[EDB archives](https://www.enterprisedb.com/download-postgresql-binaries),
[Supabase connection methods](https://supabase.com/docs/guides/database/connecting-to-postgres),
[libpq service files](https://www.postgresql.org/docs/current/libpq-pgservice.html),
[libpq password files](https://www.postgresql.org/docs/17/libpq-pgpass.html).
