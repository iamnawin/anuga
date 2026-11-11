# AnugaCare mission recovery

Use this procedure after a closed chat, context loss, crash or new agent session.
Do not rely on chat history as the source of truth.

## Restore context

1. Open `D:\AI-Workspace\Repos\anuga-trips-fix`.
2. Read, in order: `AGENTS.md`, `docs/EXECUTION_STATE.md`,
   `docs/PROGRESS_LEDGER.md`, this file, `docs/HANDOFF.md`, `docs/TASKS.md`,
   `docs/PRODUCT_SPEC.md`, `docs/ARCHITECTURE.md` and
   `docs/RELEASE_CHECKLIST.md`.
3. Run read-only reconciliation:

   ```powershell
   git status --short --branch
   git worktree list --porcelain
   git fetch origin --prune --tags
   git log -1 --format='%H %cI %s' HEAD
   git log -1 --format='%H %cI %s' origin/main
   gh pr list --repo iamnawin/anuga --state open --limit 100
   gh run list --repo iamnawin/anuga --limit 12
   ```

4. Compare actual branch, SHA, PR, CI, migrations and deployment evidence with
   `EXECUTION_STATE.md` and `PROGRESS_LEDGER.md`. Correct documentation before
   resuming if they differ.
5. Preserve every unrelated dirty path. `.unlazy/` is expected local execution
   state and must not be committed.

## Current recovery point (2026-11-11)

LATEST: BACKUP-ACCESS-001 supersedes the pointers below. Starting ad85d34,
sanitized receipt `evidence/g7-ui-staging-2026-11-07/BACKUP_ACCESS_001.md`.
Native PG17.11 clients now available under D:\AI-Workspace\Tools, so the earlier
no-tooling observation is historical. Restricted outside-Git source libpq files
are scaffolding only: password absent, CA absent, official endpoint confirmation
pending. WSL Docker CLI exists; daemon socket absent. No backup/restore exists.
Founder must complete the receipt's six-item checklist and approve BACKUP-002
scope. STOP; do not dump/restore, repair history, apply migrations, merge or deploy.

BACKUP-001 supersedes the active-task pointer below: method/coverage receipt
`evidence/g7-ui-staging-2026-11-07/BACKUP_001.md` documents BLOCKED export/restore.
Starting source `7d94feb`, PR #28. No backup created; do not look for a dump or
claim readiness. No Docker/pg_dump/psql or discovered protected direct connection.
Do not invoke passwordless `db dump --remote`, including dry-run, because it can
create a hosted login role. No ATTEST-001 repeat, migrations, deploy or merge.
Publish the sanitized receipt and STOP. Next proposed task is BACKUP-ACCESS-001
after founder review, not automatic migration-history reconciliation.

Latest approved task ATTEST-001 is complete; receipt at
`evidence/g7-ui-staging-2026-11-07/STAGING_ATTESTATION.md`.
Source `8646f56`, CI `43030310112` SUCCESS seven jobs. Supabase management access
now works. Live definitions confirm missing Nov 4 pickup/consent/occupancy fixes,
divergent history and no proven usable backup. Publish receipt then STOP for
review. Do not follow the historical missing-token or auto-rollout steps below.
Proposed next single task is backup/recovery readiness under new approval.

- Active branch: `feat/g7-ui-staging`; PR #28.
- Verified checkpoint: `e80ffd028614a93ef20d1657001144fef755dfcd`.
- Expected main: `ea6d142fb0ab6662b64369a3bdb0704f14d3e1e9` until PR #28 merges.
- PRs #22-#27 are merged; do not repeat their integration.
- Latest verified CI: `42363763847`, seven successful jobs on `e80ffd0`.
- Expected hosted state: no November 3/4 hardening rollout; public synthetic
  staging still corresponds to the merged PR #21 baseline.

If any expectation is false, stop the mutating step and reconcile it first.

## Resume the active work

1. Read current state and PR #28 metadata. Task 4 automated verification is
   complete. The founder requires a review checkpoint before the next feature.
2. Inspect `.unlazy/g7-synthetic-staging/GATES.md`; it is local untracked state.
3. If runtime changes require a new full check, use the reviewed gate command:

   ```powershell
   node C:\Users\Naveen\.agents\skills\unlazy\scripts\gate-check.mjs --approve --timeout 3600 --root D:\AI-Workspace\Repos\anuga-trips-fix --cwd D:\AI-Workspace\Repos\anuga-trips-fix .unlazy/g7-synthetic-staging/GATES.md
   ```

4. Finish Task 4 documentation, push it to #28, and STOP for user review. Do not
   merge #28 or resume Task 5 without the checkpoint being reviewed.
5. Supabase management access is missing (`projects list`: access token not
   provided). Hosted migration history and backup/recovery remain unverified.
   Vercel access works; do not deploy the new client until DB prerequisites pass.
6. Obtain authenticated Supabase operator access outside chat, then read migration
   history and backup coverage before applying only missing ordered migrations.

## Recovery safety rules

- Never reset, force-push, delete a worktree, drop/reset a hosted database, or
  overwrite another agent's changes as a recovery shortcut.
- Never expose secrets, OTP values or real patient information in docs, logs,
  screenshots or chat.
- Do not deploy until synthetic project identity, migration history and recovery
  prerequisites are verified.
- Generated concept boards are design inputs, not actual application evidence.
- Physical-device and human-language gates remain manual until signed.

## Required checkpoint receipt

At every natural stop, update `EXECUTION_STATE.md` and `PROGRESS_LEDGER.md`, append
history to `HANDOFF.md`, synchronize the relevant `TASKS.md` section, and record:
branch, SHA, PR state, tests, deployment/migration state, unresolved decisions and
the exact next safe action.
