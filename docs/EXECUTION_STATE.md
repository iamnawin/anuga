# AnugaCare execution state

Last reconciled: 2026-11-09 17:00:00 IST (Asia/Kolkata)

## Mission

Integrate the validated issue-handling and production-hardening stack, modernize
the supported AnugaCare role experiences (`UX-01`–`UX-08`) without inventing backend
capability, and publish a testable build only to the existing synthetic staging
environment. Production, real patient data, paid providers and app-store
publication remain out of scope.

## Concurrent Active Checkouts (Two Isolated Workstreams)

### 1. Gemini Workstream (UI/UX Modernization)
- **Agent:** Gemini (Antigravity — Lead UI/UX Engineer)
- **Repository / Worktree:** `D:\AI-Workspace\Ideas\Anuga`
- **Branch:** `feat/anugacare-ui-modernization` (based on `origin/main` `ea6d142fb0ab6662b64369a3bdb0704f14d3e1e9`)
- **Active Task:** `WP-0` (`71fb555`) through `WP-6` implemented and verified locally (`pnpm db:test` 209/209, `ops_console` 70/70 + build, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39); pushing and opening PR on `feat/anugacare-ui-modernization`.

### 2. Codex Workstream (PR #28 & Synthetic Staging Release)
- **Agent:** Codex
- **Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-trips-fix`
- **Branch:** `feat/g7-ui-staging` (PR #28, checkpoint `7fa7cb2` / `e80ffd0`, CI `42343362420` 7/7 green)
- **Active Task:** Task 5 release review and hosted staging verification (currently blocked on `SUPABASE_ACCESS_TOKEN` for hosted migration history verification).

## Latest verified checkpoint

- PRs #22-#27 were merged to `main` in dependency order (`a8109ae`, `5b838b6`, `8d175b4`, `038fb67`, `88b0c0b`, `ea6d142`).
- Codex's PR #28 (`feat/g7-ui-staging`, head `7fa7cb2`) passed all seven CI jobs in run `42343362420` and completed independent review with zero Critical/Important findings.
- Gemini completed `WP-0` (`71fb555`) and `WP-1`–`WP-6` (`UX-01`–`UX-08` UI/UX modernization across `anugacare_app`, `family_app`, `companion_app`, and `ops_console`) on isolated branch `feat/anugacare-ui-modernization`, with all 463 automated tests passing locally.
- No November migration (`20261104000100`–`20261104000300`) has been applied to hosted staging (`anuga.vercel.app`, deployment `dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`), which still serves the PR #21 (`21ae9bc`) baseline.

## Active tasks by agent

- **Gemini (`D:\AI-Workspace\Ideas\Anuga` on `feat/anugacare-ui-modernization`):**
  1. Commit and push `WP-1`–`WP-6` to `origin/feat/anugacare-ui-modernization` and open the GitHub PR targeting `main` (without merging).
- **Codex (`D:\AI-Workspace\Repos\anuga-trips-fix` on `feat/g7-ui-staging`):**
  1. Complete PR #28 merge when ready, reconcile with `feat/anugacare-ui-modernization`, and verify hosted Supabase operator access before applying November migrations and deploying to synthetic staging.

## Current blockers and boundaries

- Physical Android Chrome/PWA testing requires the founder's real device (`QA-002`).
- Telugu and Hindi healthcare/service wording requires named human reviewers (`QA-002`).
- Hosted migration/deployment is blocked until synthetic project identity,
  migration history and a usable recovery path are positively verified (`REL-002`).
- Independent Patient sign-in is not assumed; current role contracts decide the
  supported patient experience.
- Embedded navigation, live GPS/ETA, real calls, payments and medical checklists
  shown in concept art are not authorized unless backed by existing code and
  configuration.

## Resume command

`cd /d D:\AI-Workspace\Ideas\Anuga` (for Gemini UI workstream) or `cd /d D:\AI-Workspace\Repos\anuga-trips-fix` (for Codex PR #28 / staging workstream).

Then follow `docs/RECOVERY.md` and `docs/HANDOFF.md` before changing files.
