# AnugaCare execution state

Last reconciled: 2026-11-07 10:35:10 IST (Asia/Kolkata)

## Mission

Integrate the validated issue-handling and production-hardening stack, modernize
the supported AnugaCare role experiences without inventing backend capability,
and publish a testable build only to the existing synthetic staging environment.
Production, real patient data, paid providers and app-store publication remain
out of scope.

## Active checkout

- Repository: `D:\AI-Workspace\Repos\anuga-trips-fix`
- Branch: `feat/g7-ui-staging`
- HEAD: `8eb152e61d9db83c350998aec090c876d9911924`
- Remote branch: not pushed yet; branch is three commits ahead of `origin/main`
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
  every real-Supabase journey. Main run `42205624861` is queued on `ea6d142`.
- The corrected Unlazy G2 gate reran the complete `scripts/check-all.sh` suite on
  `7a06f1b` and passed at 16:05 IST (exit 0, expectation matched).
- No November migration has been applied to hosted staging and the new main has
  not been deployed. Staging still represents the earlier PR #21 baseline.

## Active task

Plan Task 4: build unified web/PWA and Android artifacts, prepare actual visual/
navigation/PWA evidence, then push the release branch for real-Supabase CI
screenshots.

## Next safe action

1. Commit and push this Task 1-3 handoff checkpoint.
2. Build unified release web/PWA and debug APK against the committed public
   synthetic configuration; record artifact hashes without committing builds.
3. Add the Task 4 evidence receipt and clearly record that local real-Supabase
   screenshots are unavailable because Docker/Supabase CLI are absent.
4. Push `feat/g7-ui-staging`, open the release PR, and use its disposable
   real-Supabase CI artifacts for updated authenticated screenshots.
5. Wait for all seven required jobs and review screenshots before merge or any
   hosted migration/deployment.

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
