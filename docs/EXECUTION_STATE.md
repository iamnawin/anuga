# AnugaCare execution state

Last reconciled: 2026-11-11 19:20:15 IST (Asia/Kolkata)

Current assignment: ATTEST-001 read-only synthetic Supabase attestation, approved
after Task 4 review. Observation complete; publish receipt then STOP for review.
No migration, role/RLS/data change, deployment or PR merge is authorized.

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

ATTEST-001: current hosted catalog corroborates all three Nov 4 hardening
migrations' effects are missing. Nine legacy history rows omit five later
partially verified manual applications. Backup listing has no restore points and
PITR is disabled. Supabase access is now available. Full sanitized receipt:
`docs/evidence/g7-ui-staging-2026-11-07/STAGING_ATTESTATION.md`.
CI `43030310112` completed SUCCESS: seven jobs on source `8646f56`.

## Next safe action

1. Commit/push the completed ATTEST-001 receipt and tracking updates to PR #28.
2. STOP for founder review; do not merge, apply migrations or deploy.
3. Proposed next single task after review: establish a usable synthetic backup/
   recovery artifact and isolated restore validation under explicit authorization.
4. Migration-history repair and three-migration rollout require later review.
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
