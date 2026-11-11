# AnugaCare execution state

Last reconciled: 2026-11-11 19:41:54 IST (Asia/Kolkata)

Current assignment: BACKUP-ACCESS-001, approved from ad85d34. Native PostgreSQL
17.11 clients verified; protected service/password-file scaffolding prepared
outside Git. Prerequisites PARTIAL: owner endpoint/password/CA, encryption/custody,
scope and target approvals pending. No backup/restore. Publish sanitized receipt
and STOP for review. No source role/data/schema change or rollout.

## Mission

Integrate the validated issue-handling and production-hardening stack, modernize
the supported AnugaCare role experiences without inventing backend capability,
and publish a testable build only to the existing synthetic staging environment.
Production, real patient data, paid providers and app-store publication remain
out of scope.

## Active checkout

- Repository: `D:\AI-Workspace\Repos\anuga-trips-fix`
- Branch: `feat/g7-ui-staging`
- Latest verified source checkpoint: `8646f569a58a9b1508af23c6e0aa19c672bc93a6`.
- Remote branch: `origin/feat/g7-ui-staging`; obtain current HEAD using Git.
- Working tree: tracked files clean; `.unlazy/` is the only untracked local
  execution state and must remain uncommitted.
- `origin/main`: `ea6d142fb0ab6662b64369a3bdb0704f14d3e1e9`

## Latest verified checkpoint

- Task 1 `17b6021`: the three supplied boards, supported/deferred mapping,
  product/design context and executable UI release plan are committed.
- Task 2 `0644dd9`: Family/Patient-view shows the real nine-state persisted
  progress. Family analyze is clean; 61 tests pass and 6 environment-only tests
  skip.
- Task 3 `8eb152e`: Companion shows the same nine-state progress without changing
  actions or RPCs. Companion analyze is clean; 66 tests pass and 3 environment-
  only tests skip.
- Task 4 full `scripts/check-all.sh` passes on `8eb152e`: database 209 pass / 11
  environment skips; Ops 70 pass plus production build (one pre-existing lint
  warning); shared Dart 29 pass; Companion 66/3; Family 61/6; unified app 39 pass.
- PRs #22-#27 were merged to main in dependency order at 16:17-16:19 IST:
  `a8109ae`, `5b838b6`, `8d175b4`, `038fb67`, `88b0c0b`, `ea6d142`.
- Final PR #27 head `c9cbf9f` passed CI run `42203978157` (7/7), including
  every real-Supabase journey. Main run `42205624861` passed on `ea6d142`.
- PR #28 checkpoint `7fa7cb2` passed all seven jobs in `42343362420`.
- Independent review returned ready to merge, no Critical/Important findings.
- The corrected Unlazy G2 gate reran the complete `scripts/check-all.sh` suite on
  `7a06f1b` and passed at 16:05 IST (exit 0, expectation matched).
- No November migration has been applied to hosted staging and the new main has
  not been deployed. Staging still represents the earlier PR #21 baseline.

## Active task

Current checkpoint supersedes the historical task pointer below:
BACKUP-ACCESS-001 receipt `evidence/g7-ui-staging-2026-11-07/BACKUP_ACCESS_001.md`.
Starting ad85d34, #28 OPEN. Windows native 17.11 clients pass version checks;
protected source service template/password file outside Git contains no password.
WSL Docker CLI exists, no daemon socket; no Docker Desktop installed. Hosted
connection/CA/password unavailable; no recovery target provisioned. Recovery NOT
READY. CI 43032867873 failed in runner DNS/Playwright dependency installation;
43034985288/ad85d34 in progress; no reruns or assumed success.

BACKUP-001: documented supported method and full DB/Auth/Storage/configuration
coverage. Docker/pg_dump/psql unavailable; no discovered protected direct libpq
connection. Passwordless CLI dump can create a temporary hosted role, forbidden
under current scope. No backup/target/restore created. Receipt:
`docs/evidence/g7-ui-staging-2026-11-07/BACKUP_001.md`.
Starting receipt commit `7d94feb`; its CI `43032867873` is IN_PROGRESS, not a pass.
Prior verified CI `43030310112` succeeded; no jobs/builds rerun by BACKUP-001.

## Next safe action

BACKUP-ACCESS-001 overrides the older numbered steps: push this receipt then STOP.
Founder completes its owner checklist; propose BACKUP-002 with exact export scope
and separate target approval. No dump/restore/migration starts automatically.

1. Commit/push the BACKUP-001 blocker/coverage receipt and tracking updates to #28.
2. STOP for founder review; do not merge, export through a role-changing path,
   apply migrations, restore to source or deploy.
3. Proposed next single task: BACKUP-ACCESS-001, owner-provided protected direct
   database connection and compatible dump tooling, plus restore-target decision.
4. Do not reset credentials/create roles or provision paid resources to unblock
   this without separate authorization. Migration repair/application stays gated.
5. Gemini PR #29/V2 and security PR #30 remain independent and untouched.

## Current blockers and boundaries

- Physical Android Chrome/PWA testing requires the founder's real device.
- Telugu and Hindi healthcare/service wording requires named human reviewers.
- Supabase management access now works and positively identifies synthetic
  `anuga` / `vsvkllfgrnlbhdydysny`, Mumbai, ACTIVE_HEALTHY.
- Hosted parity FAIL: missing pickup preservation, consent/OTP/read denial and
  occupancy enforcement. Migration-history timestamps diverge from all 17 local
  files; manual applications must be reconciled before any push.
- Recovery NOT READY: no listed backup, PITR false, no verified restore artifact.
- Last public deployment observation remains
  `dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`; not re-deployed in this task.
- Independent Patient sign-in is not assumed; current role contracts decide the
  supported patient experience.
- Embedded navigation, live GPS/ETA, real calls, payments and medical checklists
  shown in concept art are not authorized unless backed by existing code and
  configuration.

## Resume command

`cd /d D:\AI-Workspace\Repos\anuga-trips-fix`

Then follow `docs/RECOVERY.md` before changing files.
