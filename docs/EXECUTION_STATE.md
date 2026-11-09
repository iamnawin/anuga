# AnugaCare execution state

Last reconciled: 2026-11-09 19:15:00 IST (Asia/Kolkata)

## Mission

Integrate the validated issue-handling and production-hardening stack, modernize
the supported AnugaCare role experiences (`UX-01`–`UX-08`) without inventing backend
capability, and publish a testable build only to the existing synthetic staging
environment. Production, real patient data, paid providers and app-store
publication remain out of scope.

## Concurrent Active Checkouts (Two Isolated Workstreams)

### 1. Gemini CLI Workstream (UI/UX Modernization — PR #29)
- **Agent:** Gemini CLI (Antigravity — Lead UI/UX Engineer)
- **Repository / Worktree:** `D:\AI-Workspace\Ideas\Anuga`
- **Branch:** `feat/anugacare-ui-modernization` (based on `origin/main` `ea6d142fb0ab6662b64369a3bdb0704f14d3e1e9`)
- **Pull Request:** **PR #29** (`https://github.com/iamnawin/anuga/pull/29`, OPEN, `MERGEABLE`)
- **Active Task:** `WP-0` (`71fb555`), `WP-1`–`WP-6` (`d22c39d`), and CI fix (`c4ced74`) pushed and verified in **GitHub Actions CI run `42625907826` (`7/7` jobs `SUCCESS`)**. `UX-01` and `UX-02` verified resolved; `UX-03`–`UX-08` documented as `Partial` / `Requires Product Decision` where backend/test/dependency contracts apply.

### 2. Codex Workstream (PR #28 & Synthetic Staging Release)
- **Agent:** Codex
- **Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-trips-fix`
- **Branch:** `feat/g7-ui-staging` (PR #28, checkpoint `7fa7cb2` / `e80ffd0`, CI `42343362420` 7/7 green)
- **Active Task:** Task 5 release review and hosted staging verification (currently blocked on `SUPABASE_ACCESS_TOKEN` for hosted migration history verification).

## Latest verified checkpoint

- PRs #22-#27 were merged to `main` in dependency order (`a8109ae`, `5b838b6`, `8d175b4`, `038fb67`, `88b0c0b`, `ea6d142`).
- Codex's PR #28 (`feat/g7-ui-staging`, head `7fa7cb2` / `e80ffd0`) passed all seven CI jobs in run `42343362420` and completed independent review with zero Critical/Important findings.
- Gemini CLI's **PR #29** (`feat/anugacare-ui-modernization`, head `c4ced74`) passed **all seven CI jobs in run `42625907826`** (`db-tests`, `shared-dart`, `ops-console`, `companion-app`, `family-app`, `anugacare-app`, `supabase-local`), incorporates PR #28's exact 9-stage `_VisitProgressStrip` keys and state mapping, and preserves all backend RLS/OTP/consent/occupancy contracts.
- No November migration (`20261104000100`–`20261104000300`) has been applied to hosted staging (`anuga.vercel.app`, deployment `dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`), which still serves the PR #21 (`21ae9bc`) baseline because `SUPABASE_ACCESS_TOKEN` is missing in the CLI environment (`REL-002`).

## Active tasks by agent

- **Gemini CLI (`D:\AI-Workspace\Ideas\Anuga` on `feat/anugacare-ui-modernization` / PR #29):**
  1. PR #29 is green (`42625907826`, 7/7 jobs) and ready for founder/Codex integration review. Do not merge or deploy without `REL-002` hosted migration verification.
- **Codex (`D:\AI-Workspace\Repos\anuga-trips-fix` on `feat/g7-ui-staging` / PR #28):**
  1. Reconcile/merge PR #28 and PR #29, and verify hosted Supabase operator access (`SUPABASE_ACCESS_TOKEN`) before applying the three November 4 migrations and deploying to synthetic staging.

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
