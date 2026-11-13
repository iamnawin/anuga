# AnugaCare execution state

## Screen 04 checkpoint — 2026-11-12 19:40:46 IST

Codex isolated `feat/consent-review` at D:\AI-Workspace\Repos\anuga-consent-welcome,
base #32/ca22a5d (seven-job CI SUCCESS). Consent implemented/locally verified;
full check-all PASS, Family94/6 skip, unified49, focused DB6, real render evidence.
Source support is standing patient access and policy URL absent: documented,
not invented. Commit/push Consent PR before starting Welcome. Current user
explicitly authorizes Welcome next; after both screens STOP for Pixel review.
No merge/deploy/hosted mutation. New local port3114; old3113 untouched.


Pixel correction pushed as e5a5b95 to #32, observed 2026-11-12 17:14:24 IST;
CI 43211668116 IN_PROGRESS. Later receipt only normalizes evidence JSON CRLF and
records the source SHA; no app change. PR rollup is authoritative for later CI.
49 local tests/analyze/web/capture evidence complete; STOP for founder retest.


## LOGIN-001 Pixel correction — 2026-11-12 17:11:22 IST

Same PR #32/branch/worktree, starting 20206f4. Founder reported Pixel dark failure;
opaque widget backing removed, smaller spaced transparent lockup, readable dark
wordmark, compact hints and aligned controls verified. Unified 49/analyze/web
build PASS; real Chromium 360/390 light/dark phone/OTP/menu captures PASS. Baseline
CI 43208909014/20206f4 seven SUCCESS; new correction's PR checks not yet known.
No hosted calls/SMS/migrations/deploy/merge. Evidence in screenshots/login-review.
Push then STOP for founder Pixel retest at http://192.168.31.252:3113/app/.


## LOGIN-001 delivered for review — 2026-11-12 16:53:06 IST

Source `30b49bb72b60aadd32ba3f7426a766536e276f38` pushed to isolated [PR #32](https://github.com/iamnawin/anuga/pull/32),
base #29 branch. #28/#29 verified unchanged/open. CI source run 43208610616 was
IN_PROGRESS (seven jobs) at this observation; use PR checks for newer receipt
commits/results. No job rerun, merge/deploy or success inference. Implementation,
local tests and screenshots ready; human approval is still open. STOP at login.


## LOGIN-001 review checkpoint — 2026-11-12 16:50:49 IST

Implementation and local verification complete: final unified 45 tests, analyze,
full fast suite (before final two regressions), real 1.15×/2× en/te/hi captures,
language persistence and hosted synthetic verify/role/reload evidence. Final
OTP sends stubbed; earlier query-string stub miss/rate-limit is documented.
Independent review clear. Deliver isolated PR then STOP for founder phone/login
and native-language review. GitHub CI not yet created; no merge/deploy or gate
promotion. Phone URL and full limitations: screenshots/login-review/README.md.


## LOGIN-001 active checkpoint — 2026-11-12 16:31:44 IST

Codex owns `D:\AI-Workspace\Repos\anuga-login-review`, branch
`feat/unified-login-review`, based on PR #29/d75cf07. Login-only changes are
isolated; PR #28 stays at 6b8e63c and #29/#30 are untouched. Full fast suite passed;
unified 44 after the additional pending-verify regression. EN/TE/HI browser
captures and explicit locale persistence verified. Final hosted verification and
comparison receipt in progress. Do not infer a deploy, merge or patient approval.
PR #28 remains authoritative for later BACKUP-ACCESS-001/ATTEST-001 evidence;
the inherited November 9 recovery entries below are historical.


Last reconciled: 2026-11-09 19:45:00 IST (Asia/Kolkata)

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
- **Vercel Preview:** `https://anuga-ptkyex1az-iamnawins-projects.vercel.app` (`dpl_6673mDsp1iZULg4uPa4SD8HPz2kC`, `READY`, `target: null`, built from `631ac5d` / code `c4ced74`)
- **Active Task:** `WP-0` (`71fb555`), `WP-1`–`WP-6` (`d22c39d`), CI fix (`c4ced74`), and docs (`631ac5d`) pushed and verified in **GitHub Actions CI runs `42625907826` and `42628795153` (`7/7` jobs `SUCCESS`)**. Synthetic Supabase (`vsvkllfgrnlbhdydysny`) identity, migration history, backup state, and RPC compatibility verified read-only; non-production Vercel preview deployed for Android phone testing.

### 2. Codex Workstream (PR #28 & Synthetic Staging Release)
- **Agent:** Codex
- **Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-trips-fix`
- **Branch:** `feat/g7-ui-staging` (PR #28, checkpoint `7fa7cb2` / `e80ffd0`, CI `42343362420` 7/7 green)
- **Active Task:** Task 5 release review and hosted staging verification (owns PR #28 integration and `REL-002` hosted migration application).

## Latest verified checkpoint

- PRs #22-#27 were merged to `main` in dependency order (`a8109ae`, `5b838b6`, `8d175b4`, `038fb67`, `88b0c0b`, `ea6d142`).
- Codex's PR #28 (`feat/g7-ui-staging`, head `7fa7cb2` / `e80ffd0`) passed all seven CI jobs in run `42343362420` and completed independent review with zero Critical/Important findings.
- Gemini CLI's **PR #29** (`feat/anugacare-ui-modernization`, code `c4ced74`, docs `631ac5d`) passed **all seven CI jobs in runs `42625907826` and `42628795153`**, verified read-only RPC compatibility against `https://vsvkllfgrnlbhdydysny.supabase.co` (`scripts/staging-smoke.ts` 10/10 pass), and deployed non-production Vercel preview `dpl_6673mDsp1iZULg4uPa4SD8HPz2kC` at `https://anuga-ptkyex1az-iamnawins-projects.vercel.app` (`/`, `/app/`, `/ops/`, `/family/`, `/companion/` all HTTP 200).
- Hosted synthetic Supabase (`vsvkllfgrnlbhdydysny`, `ap-south-1`, Postgres `17.11.0.003`) was inspected via Supabase CLI without applying migrations: `supabase_migrations.schema_migrations` lists the 9 Oct 9 remote entries (`20261009154050`–`20261009160202`), Oct 22–Nov 3 migrations were applied via SQL Editor, and the three Nov 4 hardening migrations (`20261104000100`–`20261104000300`) remain unapplied on remote (`remote: ""`). `supabase backups list` reports `walg_enabled: true`, `pitr_enabled: false`, `backups: []`. Live production alias `https://anuga.vercel.app` (`dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`) remains untouched on PR #21 (`21ae9bc`).

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
