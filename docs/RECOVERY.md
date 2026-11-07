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

## Current recovery point (2026-11-07)

- Active branch: `feat/g7-ui-staging`; PR #28.
- Verified checkpoint: `7fa7cb22bb806d90352630df945325f486eaddaa`.
- Expected main: `ea6d142fb0ab6662b64369a3bdb0704f14d3e1e9` until PR #28 merges.
- PRs #22-#27 are merged; do not repeat their integration.
- Latest verified CI: `42343362420`, seven successful jobs on `7fa7cb2`.
- Expected hosted state: no November 3/4 hardening rollout; public synthetic
  staging still corresponds to the merged PR #21 baseline.

If any expectation is false, stop the mutating step and reconcile it first.

## Resume the active work

1. Read the current execution state and latest GitHub PR #28 metadata. Tasks 1-4
   have implementation and CI evidence; resume Task 5.
2. Inspect `.unlazy/g7-synthetic-staging/GATES.md`; it is local untracked state.
3. If runtime changes require a new full check, use the reviewed gate command:

   ```powershell
   node C:\Users\Naveen\.agents\skills\unlazy\scripts\gate-check.mjs --approve --timeout 3600 --root D:\AI-Workspace\Repos\anuga-trips-fix --cwd D:\AI-Workspace\Repos\anuga-trips-fix .unlazy/g7-synthetic-staging/GATES.md
   ```

4. Finish current PR documentation, confirm seven green jobs, then merge #28
   under the existing founder authorization after review.
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
