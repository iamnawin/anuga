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

## Current recovery point

- Active branch: `fix/production-operations-hardening`
- Expected HEAD/remote: `d14e55c6244d51743f110b3f4cd2bbfd4aaebea0`
- Expected main: `21ae9bc2ad4ae4e5bb3befd8b4b27a8b3b1bd65c`
- Expected open stack: PR #22 -> #23 -> #24 -> #25 -> #26 -> #27
- Expected latest green run: `42172886236`, seven successful jobs
- Expected hosted state: no November 3/4 hardening rollout; public synthetic
  staging still corresponds to the merged PR #21 baseline.

If any expectation is false, stop the mutating step and reconcile it first.

## Resume the active work

1. Finish `STATE-001` and push its documentation checkpoint to PR #27.
2. Inspect `.unlazy/g7-synthetic-staging/GATES.md`; it is intentionally ignored.
3. Rerun the corrected full local gate from the repository root:

   ```powershell
   node C:\Users\Naveen\.agents\skills\unlazy\scripts\gate-check.mjs --approve --timeout 3600 --root D:\AI-Workspace\Repos\anuga-trips-fix --cwd D:\AI-Workspace\Repos\anuga-trips-fix .unlazy/g7-synthetic-staging/GATES.md
   ```

4. Confirm the output records G2 as met. Do not treat earlier wrapper failures
   (wrong cwd, WSL bash, extra expectation suffix) as product failures.
5. Review PR #23's current docs, mark it ready, then merge/retarget PRs #22-#27
   sequentially to `main`. Recheck CI after every base/head mutation.
6. Start new UI/reference work from the resulting main on a separate branch.

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
