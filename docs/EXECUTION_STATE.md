# AnugaCare execution state

Last reconciled: 2026-11-06 16:20:09 IST (Asia/Kolkata)

## Mission

Integrate the validated issue-handling and production-hardening stack, modernize
the supported AnugaCare role experiences without inventing backend capability,
and publish a testable build only to the existing synthetic staging environment.
Production, real patient data, paid providers and app-store publication remain
out of scope.

## Active checkout

- Repository: `D:\AI-Workspace\Repos\anuga-trips-fix`
- Branch: `feat/g7-ui-staging`
- HEAD: `ea6d142fb0ab6662b64369a3bdb0704f14d3e1e9`
- Remote branch: not pushed yet; branch starts exactly at `origin/main`
- Working tree: tracked files clean; `.unlazy/` is the only untracked local
  execution state and must remain uncommitted.
- `origin/main`: `ea6d142fb0ab6662b64369a3bdb0704f14d3e1e9`

## Latest verified checkpoint

- PRs #22-#27 were merged to main in dependency order at 16:17-16:19 IST:
  `a8109ae`, `5b838b6`, `8d175b4`, `038fb67`, `88b0c0b`, `ea6d142`.
- Final PR #27 head `c9cbf9f` passed CI run `42203978157` (7/7), including
  every real-Supabase journey. Main run `42205624861` is queued on `ea6d142`.
- The corrected Unlazy G2 gate reran the complete `scripts/check-all.sh` suite on
  `7a06f1b` and passed at 16:05 IST (exit 0, expectation matched).
- No November migration has been applied to hosted staging and the new main has
  not been deployed. Staging still represents the earlier PR #21 baseline.

## Active task

`UI-001`: reconcile the three supplied concept boards with the existing design
contract, store them as reference inputs, and audit actual role screens before
making targeted UI changes.

## Next safe action

1. Commit and push this merge receipt on `feat/g7-ui-staging`.
2. Preserve the three supplied boards under `docs/design/` as concept inputs and
   extend `docs/design/tokens.md` with supported/deferred mappings.
3. Audit the running Family/Patient-view/Companion/Ops UI and current navigation/
   PWA implementation; identify only evidence-backed gaps.
4. Implement targeted changes with widget/browser regressions and actual
   screenshots, then open a release PR.
5. Wait for final main/release CI before any hosted migration or deployment.

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
