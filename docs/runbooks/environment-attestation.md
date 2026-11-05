# Environment and schema attestation

Status: **BLOCKED for the real-patient environment**. This is an executable
operator procedure, not a completed hosted assessment. It closes evidence gaps
R04/R14/R15/R26/R27 only after the release owner accepts the resulting receipt.
The [31-row release matrix](../PRODUCTION_READINESS.md) remains the source of truth.

## Identity and access preflight

The release owner and DB operator first record the following in a protected
receipt. Do not place credentials, patient records or full dashboard exports in Git.

| Required identity | Actual value / evidence |
|---|---|
| Operator and independent reviewer | Pending named people |
| Intended environment and permission ticket | Pending; synthetic / real-data production / isolated recovery |
| Supabase organisation, project ref, region and plan | Pending dashboard attestation; require approved India region |
| Vercel project, origin, deployment ID and Git source SHA | Pending candidate-specific receipt |
| Source branch, commit, PR dependency/base and seven-job CI run | Pending final technical candidate |
| DB connection target and approved read-only access | Pending; match Connect dashboard to project ref |
| Backup/restore, Auth, Storage and release owners | Pending named people |

The current known Supabase ref `vsvkllfgrnlbhdydysny` and `anuga.vercel.app` are
**synthetic staging**. Vercel's `production` target name does not establish a
real-data boundary. Stop if an endpoint, connection target, source SHA or operator
identity is missing or mismatched. Do not infer that a separate project exists.

## Read-only source and hosted comparison

From the reviewed repository, capture these commands' output. They do not merge,
deploy, request OTPs or change hosted data:

```powershell
git status --short
git branch --show-current
git rev-parse HEAD
gh pr view 22 --json number,state,baseRefName,headRefName,headRefOid,mergedAt
gh pr view 23 --json number,state,baseRefName,headRefName,headRefOid,mergedAt
gh run view <CANDIDATE_RUN_ID> --json headSha,conclusion,jobs
Get-ChildItem -LiteralPath supabase/migrations -Filter *.sql |
  Sort-Object Name | Get-FileHash -Algorithm SHA256 |
  Select-Object Path,Hash
node docs/evidence/production-readiness-2026-11-04/audit-static.mjs --network
```

The last command GETs the current public synthetic routes/auth settings only; it
does not attest an arbitrary production project. Do not mistake earlier passing
CI for the candidate SHA, an open PR's merge test SHA for a merge, or HTTP 200 for
an authenticated journey. Preserve PR22 -> PR23 and the hardening PR dependencies.

1. In Vercel, open the intended project's **Deployments** entry. Record immutable
   deployment ID, source commit, build settings, origins and environment scope.
   Inspect environment **variable names and scopes**, with values concealed.
   Compare the built app's public Supabase URL/key role with the intended project.
   Only public anon/publishable keys may be in client assets. Server/service-role
   credentials must be scoped to trusted functions, never Flutter/Next public env.
2. In Supabase, open the same project using the recorded ref. Use **Connect** to
   configure a protected libpq service named `anuga_attest` outside the repository;
   store the password in a protected password file. Do not put URLs/passwords in
   commands, screenshots or shell history. A second protected service
   `anuga_candidate_local` must point to a disposable Supabase instance built from
   the exact candidate migrations, using a compatible PostgreSQL/platform version.
3. The DB operator inspects [production-attestation.sql](../../scripts/production-attestation.sql)
   and runs it in the project's SQL Editor, or uses the existing `psql` client:

   ```powershell
   # ReceiptDir is a pre-created access-restricted directory outside the repo.
   # Set it to the approved absolute path; never use a shared/synced folder.
   psql -X --dbname=service=anuga_attest --set=ON_ERROR_STOP=1 --csv `
     --file=scripts/production-attestation.sql `
     --output="$ReceiptDir/hosted-catalogue.csv"
   if ($LASTEXITCODE) { throw 'Hosted attestation incomplete; do not approve' }
   psql -X --dbname=service=anuga_candidate_local --set=ON_ERROR_STOP=1 --csv `
     --file=scripts/production-attestation.sql `
     --output="$ReceiptDir/candidate-catalogue.csv"
   if ($LASTEXITCODE) { throw 'Candidate attestation incomplete; do not approve' }
   Compare-Object (Get-Content "$ReceiptDir/candidate-catalogue.csv") `
     (Get-Content "$ReceiptDir/hosted-catalogue.csv")
   Get-FileHash "$ReceiptDir/hosted-catalogue.csv" -Algorithm SHA256
   Get-FileHash "$ReceiptDir/candidate-catalogue.csv" -Algorithm SHA256
   ```

   The SQL uses a read-only consistent transaction, timeouts and catalogues only.
   It exports migration versions, app role flags, columns, constraints, triggers,
   RLS state/policy hashes, search paths/security-definer flags, definition hashes
   and effective table/column/function grants. It never calls app RPCs, mutates
   consent, claims notifications, or reads patient/auth/object records. Missing
   migration history or a query error means **unverified**, not an empty pass.
4. Review differences, rather than requiring whole-file byte equality. Identity,
   platform-managed Auth/Storage objects, owner ACL fingerprints and PostgreSQL
   formatting can legitimately differ. Review every app-owned `public`/`private`
   definition, grant and policy, and custom Auth triggers/Storage policies against
   the same platform version. Never dismiss a role/grant difference as cosmetic.
   Migration versions alone cannot detect a manually replaced function. Missing
   private-note/consent/occupancy functions or unexpected app grants stop release.
5. Confirm `anon`/`authenticated` are neither superusers nor RLS-bypass roles.
   Service-role bypass belongs only to trusted backend functions. Inspect Auth's
   profile-creation trigger and private-note table grants. Companions must not get
   patient/vault/diagnosis/DOB data and Family must not get private issue/Ops notes.
   Run allowed/denied API tests only in the approved synthetic candidate environment;
   a DB-owner catalogue query does not prove app-role behavior.

No dump, migration repair, `db pull`, `db push`, reset or dashboard edit is needed
for this observation. In particular, Supabase `db pull` can create local migrations
and may affect migration history; it is not used as a read-only attestation.

## Dashboard checks that catalogue SQL cannot prove

| Surface and responsible role | Inspect without revealing secrets | Passing evidence / stop condition |
|---|---|---|
| Supabase **Authentication** configuration; Auth operator | Phone provider, signup policy, redirect allow-list, OTP rate limits/expiry, CAPTCHA/abuse control selection, session limits, test-phone map, allowed seed identities | Intended production has no test OTP bypass/seed accounts, staging is restricted to seeded logins. Record values with phone/codes/keys redacted. The audit observed staging signups enabled; reconcile explicitly. No test SMS send is authorized here. |
| Supabase **Storage**; storage operator | `vault` private status, size/MIME limits, API grants/policies, signed-link TTL and access checks; current object inventory via authorized UI | Confirm no public objects, no direct client upload/download bypass and approved retention. Do not export names/paths containing patient IDs into Git. A DB backup does not contain file bytes. |
| Supabase **Edge Functions**; backend owner | Exact deployed function version/source, JWT verification, secret variable names, `NOTIFY_*`, `PAYMENTS_*` modes and payment-key test/live prefix only | Default test adapters stay selected. No service key in browser assets; no unauthorized provider credentials or live mode. Source/config unavailable -> unverified. |
| Vercel/GitHub; release owner | Environment scoping, protected/manual publication controls, reviewers and restricted deployment credentials | `vercel.json` disables Git auto deployment; synthetic publication workflow is manual. Dashboard organisation/member permissions and production approval rules need separate proof. Do not dispatch a publication workflow. |
| Data separation; DB/privacy operator | Exact seed/demo identity inventory, storage samples, test notifications/log retention, production dataset provenance | Use the existing [cleanup proposal](../PRODUCTION_READINESS.md#synthetic-inventory-and-safe-cleanup-proposal) and exact manifests. No delete is approved. Absence of the word synthetic does not prove seed-free data. |
| Backups/security; platform owner | Region, backup coverage/retention/PITR and restore availability, audit/log access, alert destinations and secret rotation ownership | Attach the [recovery drill receipt](production-operations.md#backup-and-isolated-recovery-drill). A dashboard toggle or backup timestamp is not a successful restore. |

Dashboard labels may vary; use the project's configuration pages, not screenshots
from a different project. Do not alter settings just to make a checklist green.

## Attestation receipt

```text
Decision: BLOCKED / VERIFIED FOR SYNTHETIC CANDIDATE / VERIFIED FOR APPROVED PRODUCTION
Operator / independent reviewer / time (UTC and IST):
Authorizing ticket and exact environment / project ref / region / plan:
Source SHA / PR chain / CI run / deployment ID / asset SHA256:
Applied migration versions / catalogue artifact SHA256 / differences reviewed:
Auth / Storage / Edge / Vercel configuration evidence locations (redacted):
Synthetic exclusion inventory / backup and restore receipt references:
Allowed/denied API test result and exact environment:
Missing access, mismatches and next owner action:
Approval owner and scope (observation never authorizes deploy/real patients):
```

Current receipt: **not executed against a hosted database, Storage, production
Auth or backup dashboard**. The source procedure does not close those gates.
