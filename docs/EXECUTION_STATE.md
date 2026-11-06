# AnugaCare execution state

Last reconciled: 2026-11-06 16:05:39 IST (Asia/Kolkata)

## Mission

Integrate the validated issue-handling and production-hardening stack, modernize
the supported AnugaCare role experiences without inventing backend capability,
and publish a testable build only to the existing synthetic staging environment.
Production, real patient data, paid providers and app-store publication remain
out of scope.

## Active checkout

- Repository: `D:\AI-Workspace\Repos\anuga-trips-fix`
- Branch: `fix/production-operations-hardening`
- HEAD: `7a06f1be69d9200aebdc8d1087bc92838a16a604`
- Remote: `origin/fix/production-operations-hardening` at the same SHA
- Working tree: tracked files clean; `.unlazy/` is the only untracked local
  execution state and must remain uncommitted.
- `origin/main`: `21ae9bc2ad4ae4e5bb3befd8b4b27a8b3b1bd65c`

## Latest verified checkpoint

- PRs #22-#27 form a literal dependency chain from `main` through PR #27.
- Every PR is open, mergeable and has seven successful required CI jobs.
- PR #27 code/docs head `d14e55c` passed CI run `42172886236` (7/7). Durable
  recovery commit `7a06f1b` is pushed and CI run `42203363529` is in progress.
- The corrected Unlazy G2 gate reran the complete `scripts/check-all.sh` suite on
  `7a06f1b` and passed at 16:05 IST (exit 0, expectation matched).
- No PR in #22-#27 has been merged. No November migration has been applied to
  hosted staging. Staging still represents merged PR #21/main.

## Active task

`INT-002`: wait for the pushed documentation checkpoint CI, then integrate the
validated #22-#27 stack into main in dependency order.

## Next safe action

1. Commit and push the `STATE-001` verification receipt.
2. Wait for all seven CI jobs on the resulting PR #27 head.
3. Mark PR #23 ready only after confirming its documentation remains accurate.
4. Merge PRs #22-#27 into `main` in dependency order, retargeting each stacked
   PR to `main` after its predecessor merges and waiting for required CI.
5. Create a new main-based UI/release branch for reference-board reconciliation,
   supported UI evolution and staging evidence. Do not mix new UI work into the
   already-validated hardening stack.

## Current blockers and boundaries

- Physical Android Chrome/PWA testing requires the founder's real device.
- Telugu and Hindi healthcare/service wording requires named human reviewers.
- Hosted migration/deployment is blocked until synthetic project identity,
  migration history and a usable recovery path are positively verified.
- Independent Patient sign-in is not assumed; current role contracts decide the
  supported patient experience.
- Embedded navigation, live GPS/ETA, real calls, payments and medical checklists
  shown in concept art are not authorized unless backed by existing code and
  configuration.

## Resume command

`cd /d D:\AI-Workspace\Repos\anuga-trips-fix`

Then follow `docs/RECOVERY.md` before changing files.
