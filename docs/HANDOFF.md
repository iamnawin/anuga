# Handoff

Pixel correction delivery observation, **2026-11-12 17:14:24 IST**: implementation
`e5a5b95d7805e6a598389822255d621ca2857327` pushed to the existing PR #32.
Run [43211668116](https://github.com/iamnawin/anuga/actions/runs/43211668116)
observed seven jobs IN_PROGRESS; no new pass inferred. A staged check flagged
Windows CRLF in the generated transparency JSON; this later evidence-only receipt
normalizes it to LF, after which diff check passes. No application change after
e5a5b95, no build/test rerun for formatting. Latest PR checks may refer to this
receipt commit. Same Wi-Fi server remains available; STOP for Pixel retest.


### Agent Session - 2026-11-12 17:11:22 IST — LOGIN-001 Pixel correction

**Agent:** Codex.
**Role / responsibility:** PR #32 isolated login layout correction.
**Session start (IST):** 2026-11-12 16:59:53.
**Task ID / Name:** LOGIN-001-Pixel / light and dark phone/OTP layout.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-login-review`.
**Branch:** `feat/unified-login-review`.
**Starting commit:** `20206f46a1520404dfeb97595fd271fa7c2a5f07`.
**Current commit:** Starting 20206f4; ending implementation/documentation commit
contains this entry (exact SHA is Git metadata of this receipt).
**PR:** #32 OPEN, same base #29 branch; #28/#29/#30/V2 unchanged.
**Scope:** Founder-reported Pixel dark layout defect; 360/390 light/dark renders.
**Completed work:** Removed erroneous opaque logo wrapper; transparent original
logo reduced to 224px with 24px gaps. Dark wordmark/tagline use readable light
ink; upper teal/marigold retained. Right-aligned selector row/card gutter and
48px tap target checked; same field/button padding; short en/te/hi hints.
**Files changed:** Unified login screen, three ARBs, login_review_test.dart;
pixel-fix screenshots/results/comparison/transparency evidence; HANDOFF/TASKS/
EXECUTION_STATE/PROGRESS_LEDGER, UX registers, design tokens and readiness notes.
No asset bytes, theme system, auth adapter, role routing, RLS or migration edits.
**Tests and actual results:** Four new cases RED on old UI, then final unified
49 PASS; analyze PASS; release web build PASS; scoped format/diff PASS.
Real release Chromium Pixel emulation: phone/OTP and opened menu at both widths
and both themes PASS. Four logo-corner alpha/render checks PASS. Independent
review clear and final screenshots visually inspected. Not a physical retest.
**CI evidence:** Prior 20206f4 run 43208909014 completed SUCCESS (seven jobs),
observed 17:06:51 IST; no successful job rerun. New commit requires its automatic
PR check rollup; no new CI pass inferred. Focused checks used for this UI-only fix.
**Merge status:** #32 unmerged; source PRs preserved.
**Deployment and migration status:** No deployment/migrations/hosted mutations.
All hosted traffic blocked/intercepted in visual tests; OTP stub header asserted,
no SMS or real Auth calls. Local preview PID 35976 unchanged, LAN HTTP 200.
**Decisions and assumptions:** Both normal/light and dark follow OS/browser.
Original transparent PNG unchanged; mask's 70% boundary tied to that approved
asset. Founder Pixel image reviewed in chat, no local file path supplied; the
comparison labels the old running-build reproduction rather than claiming it
is the actual Pixel screenshot. No invented dark mockup.
**Blockers:** Prior Pixel acceptance FAILED by founder report; corrected build
awaits Pixel retest and approval. Native TE/HI wording and existing production
gates remain open. New PR CI result not yet available before push.
**Uncommitted changes:** Intended code/docs/evidence before commit only; ignored
tools/builds/public config remain local, no secrets/backups staged.
**Exact next action:** Push correction to #32 then STOP. Founder refreshes
http://192.168.31.252:3113/app/ on same Wi-Fi and retests both themes/phone/OTP/
language selector/keyboard. No merge/deploy or next feature.
**Next responsible agent:** Founder reviewer; Codex on feedback.


### Agent Session - 2026-11-12 16:53:06 IST — LOGIN-001 delivery

**Agent:** Codex.
**Role / responsibility:** Isolated login owner; final evidence/handoff.
**Session start (IST):** 2026-11-12 16:11:55.
**Task ID / Name:** LOGIN-001 / unified phone and SMS verification review.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-login-review`.
**Branch:** `feat/unified-login-review`.
**Starting commit:** `d75cf071ef5e54d5b47415aac612a11b8b08545f` (#29 baseline).
**Current commit:** Implementation `30b49bb72b60aadd32ba3f7426a766536e276f38`
pushed; this later documentation-only receipt records its delivery.
**PR:** [#32 OPEN](https://github.com/iamnawin/anuga/pull/32), base
`feat/anugacare-ui-modernization`. Not main. #28 6b8e63c and #29 d75cf07 confirmed
unchanged/open; #30 and V2 preserved.
**Scope:** Login-only delivery described in the detailed session below.
**Completed work:** Phone/OTP rebuild, explicit locale persistence, keyboard and
scroll recovery, regression tests, original-logo/reference/before/after/overlay
and 12 locale/scale captures, independent review, local phone server and PR.
**Files changed:** 46 implementation/evidence/doc paths in 30b49bb; this receipt
updates tracking only. No auth adapters, RLS, roles or migrations changed.
**Tests and actual results:** Full fast suite PASS; final unified 45 and analyze
PASS; Ops lint/typecheck/two E2E discoveries PASS. Local business E2E not run.
Final hosted verify/role/reload PASS, send stubbed; exact limits/error history in
`screenshots/login-review/README.md` and `browser-results.json`.
**CI evidence:** [43208610616](https://github.com/iamnawin/anuga/actions/runs/43208610616)
on 30b49bb observed seven jobs IN_PROGRESS at 16:53:06 IST. Supabase Preview
integration SKIPPED. No successful result inferred and no job rerun requested.
Documentation pushes may create a newer run; the PR check rollup is authoritative.
**Merge status:** #32 OPEN/unmerged, source PRs unchanged.
**Deployment and migration status:** No agent deployment or migration. Local
server PID 35976, loopback/LAN HTTP 200; physical-phone access not tested.
**Decisions and assumptions:** Current founder image/compact OTP wording approved
the implementation direction; final appearance/native language/device acceptance
still require review. Earlier OTP matcher miss and unverified SMS delivery are
explicitly disclosed, rather than treated as a successful stubbed run.
**Blockers:** Founder phone/IME and native TE/HI signoff; CI result not yet known
at this observation. PR #28 hosted hardening/recovery gates remain blocked.
**Uncommitted changes:** Only this sanitized documentation receipt before commit;
ignored build/capture tools/public configuration remain local. No secrets staged.
**Exact next action:** Push this receipt to #32, STOP for founder login review at
http://192.168.31.252:3113/app/ on same Wi-Fi. Do not begin another feature or
BACKUP-002; do not merge/deploy.
**Next responsible agent:** Founder reviewer; Codex on specific feedback.


### Agent Session - 2026-11-12 16:50:49 IST

**Agent:** Codex.
**Role / responsibility:** Isolated unified login implementation and verification.
**Session start (IST):** 2026-11-12 16:11:55.
**Task ID / Name:** LOGIN-001 / approved phone-entry and SMS verification rebuild.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-login-review`.
**Branch:** `feat/unified-login-review` (stacked on PR #29).
**Starting commit:** `d75cf071ef5e54d5b47415aac612a11b8b08545f`.
**Current commit:** Ending implementation commit contains this entry; resolve via
Git. PR number/push receipt to be appended after creation, never guessed.
**PR:** Isolated review PR pending creation against feat/anugacare-ui-modernization;
#28 stays 6b8e63c, #29 stays d75cf07, #30/V2 preserved. None merged.
**Scope:** Unified phone/OTP only, explicit locale persistence, focused regression
tests, selector compatibility, real before/after/reference captures and phone URL.
**Completed work:** Reused #29 baseline, approved PNGs and existing theme. White
card, full phone lockup/compact OTP symbol, new action copy, language menu, exact
anuga-language preference. Single Verify footer above IME and step scroll reset.
Auth validation/handlers and database-role routing/RPC/RLS unchanged.
**Files changed:** Unified login/main/root callback, three ARBs, direct existing
shared_preferences dependency/lock classification, unmodified logo asset, tests;
two existing Ops E2E mobile selector helpers; design contract; screenshot evidence;
HANDOFF/TASKS/EXECUTION_STATE/PROGRESS_LEDGER/readiness matrix/dashboard.
**Tests and actual results:** check-all PASS (DB 209/11 skip; Ops 70 + build;
shared 29; Companion 58/3 skip; Family 58/6 skip; unified 43 then final 45).
Final unified analyze PASS. Ops lint/typecheck + two E2E test discovery PASS
after selectors; business journeys not locally executed. Regression RED→GREEN for
keyboard visibility and scroll reset; busy verify/IME expiry regression PASS.
EN/TE/HI 360px and 2× real-font captures, explicit language→reload PASS.
**CI evidence:** Current branch CI not yet created; local results above only.
No GitHub success inferred. Final hosted synthetic verify/role/reload observation
2026-11-12 16:48:28 IST passed for Family/Companion/Ops. Final sends stubbed;
no business writes. See screenshots/login-review/browser-results.json.
**Merge status:** Not merged; source PRs preserved.
**Deployment and migration status:** Not deployed; no migrations or hosted
business data/roles/users/RLS/provider configuration changes. Synthetic Auth
sessions exercised. Local hidden server PID 35976; LAN/loopback HTTP 200.
**Decisions and assumptions:** Current founder image supersedes historical board
1 panel 02; OTP follows panel 03 plus written compact-card direction. Original
logo proportions/platform font retained; no new font/provider dependencies.
Earlier query-bearing capture OTP URLs escaped the initial stub and reached
staging Auth for synthetic numbers (rate-limit error). Final matcher/header
assertion correct this. Actual SMS delivery is unverified; no code/token artifacts.
**Blockers:** Founder login acceptance, physical Android/IME and native TE/HI
wording remain unverified. Current CI pending. PR #28's hosted hardening/recovery
gates remain blocked; inherited November 9 attestation below is historical.
**Uncommitted changes:** Intended implementation/docs/evidence before commit;
ignored artifacts/builds/public build config remain outside Git.
**Exact next action:** Push isolated login review PR, append factual PR/commit/CI
receipt, then STOP for founder review at http://192.168.31.252:3113/app/ (same
Wi-Fi; phone reachability untested). No next feature, merge/deploy or BACKUP-002.
**Next responsible agent:** Founder login reviewer; Codex only after feedback.


## Gemini CLI Final Review, Synthetic Supabase Attestation & PR #29 Vercel Preview (2026-11-09 19:45 IST)

- **Location of Full Audit & Plan:**
  - Permanent UX & Accessibility Register: `docs/UX_AUDIT.md`
  - Phased UI Modernization Plan: `docs/UX_IMPLEMENTATION_PLAN.md`
- **Gemini Feature Branch, PR & CI:**
  - Branch: `feat/anugacare-ui-modernization` (branched from `origin/main` `ea6d142fb0ab6662b64369a3bdb0704f14d3e1e9`)
  - Worktree: `D:\AI-Workspace\Ideas\Anuga` (isolated from Codex's `D:\AI-Workspace\Repos\anuga-trips-fix` worktree on `feat/g7-ui-staging` / PR #28)
  - Pull Request: **PR #29** (`https://github.com/iamnawin/anuga/pull/29`, OPEN, `MERGEABLE`)
  - Commits on `feat/anugacare-ui-modernization`: `71fb555` (`WP-0`), `d22c39d` (`WP-1`–`WP-6`), `c4ced74` (BookingsTab card semantic merging fix + `dart format`), `631ac5d` (documentation receipt)
  - **GitHub Actions CI Run `42628795153` on `631ac5d` (and `42625907826` on `c4ced74`) — ALL 7 JOBS PASSED (`SUCCESS`):**
    1. `db-tests`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42628795153/job/129199387586`)
    2. `shared-dart`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42628795153/job/129199387309`)
    3. `ops-console`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42628795153/job/129199387371`)
    4. `companion-app`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42628795153/job/129199387257`)
    5. `family-app`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42628795153/job/129199387456`)
    6. `anugacare-app`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42628795153/job/129199386939`)
    7. `supabase-local`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42628795153/job/129199387510` — real Postgres 17 + Auth + RLS + Edge Functions + Playwright `care_request.spec.ts` + `issue_handling.spec.ts` + `scripts/e2e-journey.sh`)
- **Synthetic Supabase Identity, Hosted Migration History & Recovery Path (`vsvkllfgrnlbhdydysny`):**
  - **Project Identity (`npx supabase projects list`):** Project `anuga`, ref `vsvkllfgrnlbhdydysny`, org `dmujucbsijrezfsvgpno`, region `ap-south-1` (Mumbai), status `ACTIVE_HEALTHY`, Postgres `17.11.0.003` (`ga`), created `2026-10-09T14:15:37.430054Z`.
  - **Hosted Migration History (`npx supabase migration list --project-ref vsvkllfgrnlbhdydysny`):** Remote `supabase_migrations.schema_migrations` records 9 initial remote timestamps (`20261009154050`, `20261009154129`, `20261009154301`, `20261009154343`, `20261009154419`, `20261009154511`, `20261009160002`, `20261009160126`, `20261009160202`) corresponding to `20261008000100`–`20261008000900`. Subsequent Oct 22–Nov 3 migrations (`20261022000100`–`20261103000100`) were applied via the dashboard SQL Editor without CLI migration-table tracking, and the three Nov 4 hardening migrations (`20261104000100`, `20261104000200`, `20261104000300`) remain unapplied on remote (`remote: ""`). Per explicit instruction, **no migrations were automatically applied**.
  - **Available Recovery Path (`npx supabase backups list --project-ref vsvkllfgrnlbhdydysny`):** `{"region":"ap-south-1","walg_enabled":true,"pitr_enabled":false,"backups":[],"physical_backup_data":{}}`. Automated physical snapshots and PITR are not enabled on the current plan; synthetic staging recovery relies on the deterministic local migration chain (`supabase/migrations/20261008000100_core_schema.sql`..`20261104000300_companion_occupancy.sql`) + `supabase/seed/seed.sql` and the operator procedures in `docs/runbooks/environment-attestation.md` and `docs/runbooks/production-operations.md`.
  - **Read-Only Backend Compatibility Verification:** `node scripts/staging-smoke.ts` passed all 10 allowed/denied role & Edge Function checks against `https://vsvkllfgrnlbhdydysny.supabase.co`, and read-only RPC verification confirmed HTTP 200 across `family_my_patients`, `family_trip_board` (18 trips), `family_care_requests` (13 requests), `companion_my_trips` (17 trips), `ops_trip_board` (18 trips), `ops_schedule_board` (14 schedules), and `ops_exception_queue` (6 items).
- **PR #29 Vercel Preview Deployment (Non-Production, `https://anuga.vercel.app` Untouched):**
  - Built prebuilt static bundle via `scripts/build-staging.sh` from commit `631ac5d` (code SHA `c4ced74`) and deployed as a **Preview** (`target: null`) to project `iamnawins-projects/anuga`:
  - **Preview URL (Vercel team sign-in):** `https://anuga-ptkyex1az-iamnawins-projects.vercel.app` (routes: `/`, `/app/`, `/ops/`, `/family/`, `/companion/`)
  - **Deployment ID:** `dpl_6673mDsp1iZULg4uPa4SD8HPz2kC` (`READY`)
  - **Inspector URL:** `https://vercel.com/iamnawins-projects/anuga/6673mDsp1iZULg4uPa4SD8HPz2kC`
  - **Live Synthetic Production Alias Untouched:** `https://anuga.vercel.app` remains on `dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN` (PR #21 `21ae9bc`).

### Agent Session — 2026-11-09 19:45 IST

**Agent:** Gemini CLI (Antigravity — Lead UI/UX Engineer & Independent Product Analyst)
**Task ID / Name:** Synthetic Supabase Attestation, PR #29 CI Confirmation & Vercel Preview Deployment (`dpl_6673mDsp1iZULg4uPa4SD8HPz2kC`)
**Repository / Worktree:** `D:\AI-Workspace\Ideas\Anuga`
**Branch:** `feat/anugacare-ui-modernization`
**Starting commit:** `631ac5d` (code commit `c4ced74`)
**Current commit:** `631ac5d` (plus this documentation receipt commit)
**PR:** **PR #29** (`https://github.com/iamnawin/anuga/pull/29`)
**Scope:**
1. Verify synthetic Supabase project identity (`npx supabase projects list`), hosted migration history (`npx supabase migration list --project-ref vsvkllfgrnlbhdydysny`), and backup/recovery path (`npx supabase backups list --project-ref vsvkllfgrnlbhdydysny`) without applying migrations.
2. Confirm PR #29's latest CI run (`42628795153` on `631ac5d`) is 7/7 green and preserve Codex PR #28's integration ownership.
3. Verify read-only RPC compatibility against `https://vsvkllfgrnlbhdydysny.supabase.co` (`scripts/staging-smoke.ts` + role RPC probes).
4. Build `scripts/build-staging.sh` and deploy a non-production Vercel preview (`dpl_6673mDsp1iZULg4uPa4SD8HPz2kC`) on `iamnawins-projects/anuga` without merging to `main` or altering `https://anuga.vercel.app`.
**Completed work:**
- Verified project `anuga` (`vsvkllfgrnlbhdydysny`, `ap-south-1`, `ACTIVE_HEALTHY`, Postgres `17.11.0.003`), migration table state, and backup state (`pitr_enabled: false`, `backups: []`).
- Verified PR #29 CI run `42628795153` (`631ac5d`) passed all 7 jobs (`anugacare-app`, `companion-app`, `db-tests`, `family-app`, `ops-console`, `shared-dart`, `supabase-local`).
- Ran `node scripts/staging-smoke.ts` (10/10 pass) and read-only RPC checks across Family, Companion, and Ops against `https://vsvkllfgrnlbhdydysny.supabase.co`.
- Built `artifacts/staging/.vercel/output` via `scripts/build-staging.sh` and deployed Preview `dpl_6673mDsp1iZULg4uPa4SD8HPz2kC` at `https://anuga-ptkyex1az-iamnawins-projects.vercel.app`, confirming HTTP 200 across `/`, `/app/`, `/ops/login/`, `/family/`, and `/companion/` via `vercel curl`.
**Files changed:** `docs/HANDOFF.md`, `docs/TASKS.md`, `docs/EXECUTION_STATE.md`, `docs/PROGRESS_LEDGER.md`
**Tests and actual results:**
- GitHub Actions CI run `42628795153` on `631ac5d`: **7/7 jobs PASSED (`SUCCESS`)**.
- `node scripts/staging-smoke.ts` against `https://vsvkllfgrnlbhdydysny.supabase.co`: **10/10 checks PASSED**.
- Read-only RPC compatibility check against `https://vsvkllfgrnlbhdydysny.supabase.co`: `family_my_patients` (200), `family_trip_board` (200, 18 trips), `family_care_requests` (200, 13 requests), `companion_my_trips` (200, 17 trips), `ops_trip_board` (200, 18 trips), `ops_schedule_board` (200, 14 schedules), `ops_exception_queue` (200, 6 items).
- `scripts/build-staging.sh`: Built `/ops/`, `/family/`, `/companion/`, `/app/`, and `/` into `artifacts/staging/.vercel/output` (`exit 0`).
- `vercel curl` route verification on `https://anuga-ptkyex1az-iamnawins-projects.vercel.app`: HTTP 200 verified.
**CI evidence:** Run `42628795153` (`https://github.com/iamnawin/anuga/actions/runs/42628795153`) — 7/7 green on `631ac5d`; Run `42625907826` — 7/7 green on `c4ced74`.
**Merge status:** Not merged (PR #29 open and `MERGEABLE` against `main`; Codex owns PR #28 integration).
**Deployment and migration status:**
- **Preview Deployed:** `https://anuga-ptkyex1az-iamnawins-projects.vercel.app` (`dpl_6673mDsp1iZULg4uPa4SD8HPz2kC`, `READY`, `target: null`, Vercel team sign-in).
- **Production Alias Untouched:** `https://anuga.vercel.app` (`dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`) was not modified.
- **Migrations:** Zero migrations applied. The three Nov 4 SQL hardening migrations (`20261104000100`–`20261104000300`) remain unapplied on `vsvkllfgrnlbhdydysny` until Codex/founder reconciles the remote `schema_migrations` table and applies them for `REL-002`.
**Decisions and assumptions:**
- Deployed PR #29 as a non-production Vercel Preview (`target: null`) on `iamnawins-projects/anuga` (`https://anuga-ptkyex1az-iamnawins-projects.vercel.app`), matching the exact preview workflow used for PR #20, PR #21, and PR #22 without altering `https://anuga.vercel.app` or Codex's PR #28.
**Blockers:**
- `REL-002` (for promoting `main` to `https://anuga.vercel.app`): Hosted `vsvkllfgrnlbhdydysny` has `pitr_enabled: false` / `backups: []`, and `supabase_migrations.schema_migrations` only tracks the 9 Oct 9 timestamps while Oct 22–Nov 3 migrations were run in the SQL Editor and Nov 4 migrations (`20261104000100`–`20261104000300`) are not yet applied on remote.
- `QA-002`: Physical Android phone testing by the founder on `https://anuga-ptkyex1az-iamnawins-projects.vercel.app/app/` and human Telugu/Hindi healthcare copy signoff remain `Not tested`.
**Uncommitted changes:** None after committing this documentation receipt (built `artifacts/staging/` is gitignored).
**Exact next action:**
1. Founder opens `https://anuga-ptkyex1az-iamnawins-projects.vercel.app/app/` in Android Chrome (signed into Vercel team `iamnawins-projects`), signs in with synthetic Family owner `919000000101` / OTP `123456`, and runs the mobile walkthrough (`QA-002`).
2. Codex/founder reconciles PR #28 and PR #29 on `main` and applies the three Nov 4 SQL migrations on `vsvkllfgrnlbhdydysny` when ready to promote to `https://anuga.vercel.app`.
**Next responsible agent:** Founder (Android Chrome preview testing on `https://anuga-ptkyex1az-iamnawins-projects.vercel.app`) / Codex (PR #28 integration & `REL-002` staging promotion).

## Gemini CLI Final Review, CI Verification & Codex Integration Readiness (2026-11-09 19:15 IST)

- **Location of Full Audit & Plan:**
  - Permanent UX & Accessibility Register: `docs/UX_AUDIT.md`
  - Phased UI Modernization Plan: `docs/UX_IMPLEMENTATION_PLAN.md`
- **Gemini Feature Branch, PR & CI:**
  - Branch: `feat/anugacare-ui-modernization` (branched from `origin/main` `ea6d142fb0ab6662b64369a3bdb0704f14d3e1e9`)
  - Worktree: `D:\AI-Workspace\Ideas\Anuga` (isolated from Codex's `D:\AI-Workspace\Repos\anuga-trips-fix` worktree on `feat/g7-ui-staging` / PR #28)
  - Pull Request: **PR #29** (`https://github.com/iamnawin/anuga/pull/29`, OPEN, `MERGEABLE`)
  - Commits on `feat/anugacare-ui-modernization`: `71fb555` (`WP-0`), `d22c39d` (`WP-1`–`WP-6`), `c4ced74` (BookingsTab card semantic merging fix + `dart format`)
  - **GitHub Actions CI Run `42625907826` on `c4ced74` — ALL 7 JOBS PASSED (`SUCCESS`):**
    1. `db-tests`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42625907826/job/129189526516`)
    2. `shared-dart`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42625907826/job/129189526919`)
    3. `ops-console`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42625907826/job/129189527093`)
    4. `companion-app`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42625907826/job/129189527055`)
    5. `family-app`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42625907826/job/129189527076`)
    6. `anugacare-app`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42625907826/job/129189526843`)
    7. `supabase-local`: `SUCCESS` (`https://github.com/iamnawin/anuga/actions/runs/42625907826/job/129189527363` — real Postgres 17 + Auth + RLS + Edge Functions + Playwright `care_request.spec.ts` + `issue_handling.spec.ts` + `scripts/e2e-journey.sh`)
- **Strict Reassessment of `UX-01` through `UX-08`:**
  - `UX-01` (**Tested / In PR #29**): Compacted `HomeScreen` patient summary header so normal viewports never trigger nested scroll conflicts, and unified `BookingsTab` care-request (`Key('care-request-<scheduleId>')`) and booking (`Key('booking-<tripId>')`) cards with styled pill status badges that preserve Flutter Web card semantic node merging for Playwright E2E (`care_request.spec.ts`).
  - `UX-02` (**Tested / In PR #29**): Updated `_run()` in both Family and Companion `TripScreen` so transient or step-eligibility action errors keep authorized visit details (`_booking` / `_trip`) on screen alongside `Key('error')`, while `isNotAllowed` permission revocations and `_load()` / `_reload()` failures immediately clear all visit state.
  - `UX-03` (**Partial — UI Complete; Requires Product Decision DEC-01 for Server Re-Read**): Persisted the issued 6-digit Pickup OTP in ephemeral widget memory (`_activePickupCode`) and rendered `Key('active-pickup-code-card')` inline on Family/Patient `TripScreen` after the modal dialog closes while `_canIssueCode` remains true; cleared automatically on refresh, disposal, or status progression past pickup. Server-side re-read after app kill requires a salted-hash/encrypted-column product decision (`DEC-01`).
  - `UX-04` (**Partial — Requires Product Decision DEC-02**): Visually separated Companion primary forward actions (`FilledButton`) from exception actions (`action-noShow`, `action-reportIssue`) with a dedicated section divider. However, `action-noShow` remains enabled in `scheduled` before `startAllowedAt` because existing `apps/companion_app/test/trip_screen_test.dart` (`before the start window, Start is disabled with a reason and No-show is enabled`) and `TripStateMachine` explicitly assert this contract, and `arrived_at_centre` / `dialysis_in_progress` / `ready_for_return` / `return_underway` still execute immediately without a confirmation dialog. Time-gating `no_show` until `pickup_at + grace_minutes` and adding intermediate-step confirmations require founder decision `DEC-02`.
  - `UX-05` (**Partial — UI Summary Card Complete; Native Picker Requires E2E Selector Update**): Structured `CareRequestScreen` patient summary, registered dialysis centre presentation, and review card (`Key('care-review-summary')`). Direct keyboard entry on `Key('care-date')` and `Key('care-time')` is intentionally retained because Playwright E2E `apps/ops_console/e2e/care_request.spec.ts` calls `.fill()` directly on those fields.
  - `UX-06` (**Partial — TE/HI Copy Updated; Requires Human `QA-002` Review & English Test Contract Decision**): Replaced phonetic Telugu/Hindi `"Ops"` (`ఆప్స్` / `ऑप्स`) with natural team phrasing (`మా బృందం` / `हमारी टीम` / `ఆపరేషన్స్ బృందం` / `ऑपरेशंस टीम`) and standardized Telugu `"Companion"` to gender-neutral respectful `సహచరులు`. English `app_en.arb` strings (`Pending ops confirmation`, `Ops confirmed`) remain unchanged to satisfy existing widget/E2E assertions (`care_request_test.dart`, `care_request.spec.ts`), and native human signoff (`QA-002`) remains open.
  - `UX-07` (**Partial — Visual Hierarchy Complete; Auto-Confirmation Requires Product Decision DEC-05**): Enhanced Ops Console card/table elevation, alert borders, and severity left-border indicators (`.card-issue_reported`, `.card-late`) in `globals.css`, and fixed the React effect ref cleanup warning in `exceptions/page.tsx` (`0` lint warnings). Unconfirmed care requests on `/schedules` still require clicking `Confirm request` before `Assign primary & backup` because `ops_assign_schedule_companions` enforces `status = 'active'` in SQL (`DEC-05`).
  - `UX-08` (**Partial — 9-Stage Progress Strip & Banner Complete; One-Tap `tel:` Dialer Requires Dependency Approval**): Added reusable `CareEmergencyBanner` (`Call 108`) and the 9-stage persisted `_VisitProgressStrip` (`Key('visit-progress')`, `Key('visit-progress-stage-$i')`, `Key('visit-progress-current-$i')`) across Family and Companion `TripScreen`, matching Codex PR #28 keys and status mapping. Interactive `tel:108` / contact dialing is not yet wired because `url_launcher` is not in `pubspec.yaml` (`NAV-001` / founder dependency approval).
- **Integration Compatibility with Codex's PR #28 (`feat/g7-ui-staging`):**
  - PR #28 (`e80ffd0`) touches only 2 runtime files (`apps/family_app/lib/src/screens/trip_screen.dart` in `0644dd9` and `apps/companion_app/lib/src/screens/trip_screen.dart` in `8eb152e`), 3 widget test files, and 3 E2E screenshot output path lines (`1e956fc`).
  - PR #29 (`c4ced74`) already includes the exact `_visitProgressStatuses`, `_progressStatus`, and `_VisitProgressStrip` (`Key('visit-progress')`, `Key('visit-progress-stage-$index')`, `Key('visit-progress-current-$index')`) from PR #28 plus all PR #28 widget tests (`apps/family_app/test/visit_progress_test.dart`, `apps/companion_app/test/trip_screen_test.dart`).
- **Vercel Preview & Hosted Synthetic Supabase Status (`REL-002`):**
  - `Vercel CLI` (`59.26.0`) is authenticated as `iamnawin`; existing live synthetic deployment at `https://anuga.vercel.app` (`dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`) remains on PR #21 (`21ae9bc`).
  - `Supabase CLI` (`2.120.0`) fails `projects list` with `AccessTokenRequiredError: Access token not provided. Supply an access token by running supabase login or setting the SUPABASE_ACCESS_TOKEN environment variable.`
  - Because the three November 4 migrations merged to `main` (`20261104000100_preserve_issue_pickup_time.sql`, `20261104000200_trip_consent_enforcement.sql`, `20261104000300_companion_occupancy.sql`) cannot be verified or applied to hosted synthetic Supabase (`vsvkllfgrnlbhdydysny`) without `SUPABASE_ACCESS_TOKEN`, deploying a new Vercel preview/staging build against `vsvkllfgrnlbhdydysny` is blocked by `REL-002`.

### Agent Session — 2026-11-09 19:15 IST

**Agent:** Gemini CLI (Antigravity — Lead UI/UX Engineer & Independent Product Analyst)
**Task ID / Name:** PR #29 Final Review, CI Repair (`c4ced74`), Skill-Guided UI/UX Reassessment & Codex PR #28 Integration Preparation
**Repository / Worktree:** `D:\AI-Workspace\Ideas\Anuga`
**Branch:** `feat/anugacare-ui-modernization`
**Starting commit:** `d22c39d`
**Current commit:** `c4ced74` (plus documentation receipt commit on push)
**PR:** **PR #29** (`https://github.com/iamnawin/anuga/pull/29`)
**Scope:**
1. Discover installed skills in Gemini CLI (`C:\Users\Naveen\.gemini\config\skills\`) and read `SKILL.md` instructions (`frontend-design`, `mobile-design`, `ui-ux-designer`, `ui-skills`, `flutter-expert`, `wcag-audit-patterns`, `e2e-testing`, `ui-visual-validator`, `code-reviewer`, `verification-before-completion`, `lint-and-validate`; verify `EGM` and `Unlazy` are not installed in Gemini CLI).
2. Investigate PR #29 GitHub CI run `42610717334` failures (`dart format` check in Flutter jobs and `BookingsTab` `Chip` semantic node split in `supabase-local` Playwright `care_request.spec.ts`), fix them cleanly in `c4ced74`, and verify all 7 CI jobs pass in run `42625907826`.
3. Compare PR #29 (`c4ced74`) against Codex's PR #28 (`feat/g7-ui-staging`, `e80ffd0`), confirming 100% compatibility on the 9-stage `_VisitProgressStrip`, keys, paused `issue_reported` behavior, and completed milestones.
4. Perform visual inspection of narrow-viewport (`360px`) EN/TE/HI `100%` and `200%` screenshots and downloaded PR #29 CI E2E screenshots (`01-companion-underway.png` through `05-ops-completed.png`).
5. Reassess `UX-01` through `UX-08` honestly, distinguishing fully resolved items (`UX-01`, `UX-02`) from `Partial` / `Requires Product Decision` items (`UX-03`–`UX-08`).
6. Check Vercel and Supabase CLI access for preview deployment and record the exact `SUPABASE_ACCESS_TOKEN` blocker (`REL-002`).
**Completed work:**
- Fixed `apps/family_app/lib/src/screens/bookings_tab.dart` to replace `Chip` with a styled pill `Container` so pickup time and status text merge into the parent `Card` semantic node on Flutter Web.
- Formatted all Dart files with `dart format` (`0` formatting diffs).
- Pushed `c4ced74` to `origin/feat/anugacare-ui-modernization` and verified GitHub Actions run `42625907826` passed all 7 jobs (`db-tests`, `shared-dart`, `ops-console`, `companion-app`, `family-app`, `anugacare-app`, `supabase-local`).
- Downloaded and visually inspected the PR #29 `care-request-preview` artifact screenshots (`01-companion-underway.png`–`05-ops-completed.png`) alongside the repository's narrow-viewport EN/TE/HI `100%` and `200%` screenshots.
- Updated `docs/UX_AUDIT.md`, `docs/UX_IMPLEMENTATION_PLAN.md`, `docs/HANDOFF.md`, `docs/TASKS.md`, `docs/EXECUTION_STATE.md`, and `docs/PROGRESS_LEDGER.md`.
**Files changed:** `apps/family_app/lib/src/screens/bookings_tab.dart`, `apps/anugacare_app/lib/src/screens/account_status_screen.dart`, `apps/anugacare_app/lib/src/screens/login_screen.dart`, `apps/companion_app/lib/src/screens/trip_screen.dart`, `apps/family_app/lib/src/screens/care_request_screen.dart`, `apps/family_app/lib/src/screens/trip_screen.dart`, `apps/family_app/test/trip_screen_test.dart`, `docs/UX_AUDIT.md`, `docs/UX_IMPLEMENTATION_PLAN.md`, `docs/HANDOFF.md`, `docs/TASKS.md`, `docs/EXECUTION_STATE.md`, `docs/PROGRESS_LEDGER.md`
**Tests and actual results:**
- Local `dart format --output=none --set-exit-if-changed` across `shared_dart`, `family_app`, `companion_app`, `anugacare_app`: Passed (`0` changed).
- Local `apps/family_app`: `flutter analyze --fatal-infos` passed (`0` issues), `flutter test --concurrency=1` passed (`58/58` passed, `6` skipped for real Supabase).
- GitHub Actions CI run `42625907826` on `c4ced74`: **7/7 jobs PASSED (`SUCCESS`)**, including `supabase-local` (real Postgres 17 + GoTrue + Edge Functions + Playwright `care_request.spec.ts` + `issue_handling.spec.ts` + `scripts/e2e-journey.sh`) and both debug Android APK builds.
**CI evidence:** Run `42625907826` (`https://github.com/iamnawin/anuga/actions/runs/42625907826`) — 7/7 green on `c4ced74`.
**Merge status:** Not merged (PR #29 open and `MERGEABLE` against `main`).
**Deployment and migration status:** Not deployed. Zero migrations added or modified by PR #29. Hosted synthetic Supabase (`vsvkllfgrnlbhdydysny`) still awaits operator verification/application of merged Nov 4 migrations (`20261104000100`–`20261104000300`), which is blocked on `SUPABASE_ACCESS_TOKEN` (`REL-002`). Live synthetic site `https://anuga.vercel.app` (`dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`) continues serving PR #21 (`21ae9bc`).
**Decisions and assumptions:**
- Treated Codex's PR #28 (`0644dd9`, `8eb152e`) 9-stage progress strip as the authoritative baseline; PR #29 uses the exact same keys and status mapping.
- Reclassified `UX-03`, `UX-04`, `UX-05`, `UX-06`, `UX-07`, and `UX-08` as `Partial` / `Requires Product Decision` where full behavioral resolution requires SQL/RPC contract changes (`DEC-01`, `DEC-02`, `DEC-05`), E2E test selector updates (`UX-05`, `UX-06` English), new package dependencies (`url_launcher` for `UX-08`), or human native-speaker signoff (`QA-002`).
**Blockers:**
- `REL-002`: `SUPABASE_ACCESS_TOKEN` is required to verify and apply the merged Nov 4 migrations (`20261104000100`–`20261104000300`) on `vsvkllfgrnlbhdydysny` before deploying PR #28 / PR #29 to Vercel staging (`https://anuga.vercel.app`).
- `QA-002`: Physical Android phone testing by the founder and human Telugu/Hindi healthcare copy signoff remain `Not tested`.
**Uncommitted changes:** None after committing this documentation receipt (only gitignored/untracked `.swarm/` and `docs/logo/` remain untouched).
**Exact next action:**
1. Founder or Codex supplies `SUPABASE_ACCESS_TOKEN` to verify/apply the three merged Nov 4 migrations on `vsvkllfgrnlbhdydysny`.
2. Merge PR #28 and PR #29 (or merge PR #29 directly as a superset of PR #28's runtime `trip_screen.dart` changes after keeping PR #28's 3-line E2E screenshot path diff in `1e956fc`).
3. Deploy the unified web bundle (`/`, `/ops/`, `/family/`, `/companion/`) to Vercel and run physical Android phone testing (`QA-002`).
**Next responsible agent:** Founder / Codex (resolve `SUPABASE_ACCESS_TOKEN` for `REL-002`, coordinate PR #28/#29 merge, and run physical Android phone validation).

### Agent Session — 2026-11-09 17:00 IST

**Agent:** Gemini (Antigravity — Lead UI/UX Engineer & Independent Product Analyst)
**Task ID / Name:** `WP-1` through `WP-6` / Complete AnugaCare UI/UX Modernization (`UX-01`–`UX-08`)
**Repository / Worktree:** `D:\AI-Workspace\Ideas\Anuga`
**Branch:** `feat/anugacare-ui-modernization`
**Starting commit:** `71fb555` (`WP-0` checkpoint on `feat/anugacare-ui-modernization`, branched from `ea6d142`)
**Current commit:** Pending `WP-1`–`WP-6` commit (recorded on push/PR)
**PR:** Opening on `feat/anugacare-ui-modernization` targeting `main` (do not merge)
**Scope:** Implement and verify `WP-1` (shared visual system & 9-stage progress strip), `WP-2` (Entry/Auth & Family `UX-01`, `UX-02`, `UX-03`, `UX-05`, `UX-08`), `WP-3` (Patient-Access & Companion `UX-02`, `UX-04`, `UX-08`), `WP-4` (Ops Console `UX-07`), `WP-5` (EN/TE/HI terminology `UX-06`), and `WP-6` (regression tests & full check-all verification).
**Completed work:** Implemented all UI/UX modernization changes across `anugacare_app`, `family_app`, `companion_app`, and `ops_console`; added widget regressions for the 9-stage progress strip, inline pickup OTP persistence after modal close (`UX-03`), and non-destructive action error handling (`UX-02`); executed the complete local verification suite across all packages.
**Files changed:** `apps/anugacare_app/lib/src/screens/account_status_screen.dart`, `apps/anugacare_app/lib/src/screens/login_screen.dart`, `apps/companion_app/lib/l10n/app_hi.arb`, `apps/companion_app/lib/l10n/app_te.arb`, `apps/companion_app/lib/l10n/generated/app_localizations_*.dart`, `apps/companion_app/lib/src/screens/trip_screen.dart`, `apps/companion_app/lib/src/screens/trips_screen.dart`, `apps/companion_app/test/trip_screen_test.dart`, `apps/family_app/lib/l10n/app_hi.arb`, `apps/family_app/lib/l10n/app_te.arb`, `apps/family_app/lib/l10n/generated/app_localizations_*.dart`, `apps/family_app/lib/src/screens/bookings_tab.dart`, `apps/family_app/lib/src/screens/care_request_screen.dart`, `apps/family_app/lib/src/screens/care_ui.dart`, `apps/family_app/lib/src/screens/home_screen.dart`, `apps/family_app/lib/src/screens/trip_screen.dart`, `apps/family_app/test/trip_screen_test.dart`, `apps/family_app/test/visit_progress_test.dart`, `apps/ops_console/src/app/exceptions/page.tsx`, `apps/ops_console/src/app/globals.css`, `docs/UX_AUDIT.md`, `docs/UX_IMPLEMENTATION_PLAN.md`, `docs/HANDOFF.md`, `docs/TASKS.md`, `docs/EXECUTION_STATE.md`, `docs/PROGRESS_LEDGER.md`
**Tests and actual results:**
- Root TypeScript (`pnpm typecheck`): Passed (0 errors)
- Database contract suite (`pnpm db:test`): Passed (209 passed, 0 failed, 11 skipped for real Supabase/concurrency)
- Ops Console (`apps/ops_console`): `pnpm lint` passed (0 errors, 0 warnings), `pnpm typecheck` passed, `pnpm test` passed (9 files, 70/70 tests), `pnpm build` passed (9/9 static routes)
- `packages/shared_dart`: `dart analyze --fatal-infos` passed (0 issues), `dart test` passed (29/29 tests)
- `apps/family_app`: `flutter gen-l10n` & `flutter analyze --fatal-infos` passed (0 issues), `flutter test --concurrency=1` passed (58 passed, 0 failed, 6 skipped for real Supabase/e2e)
- `apps/companion_app`: `flutter gen-l10n` & `flutter analyze --fatal-infos` passed (0 issues), `flutter test --concurrency=1` passed (58 passed, 0 failed, 3 skipped for real Supabase/e2e)
- `apps/anugacare_app`: `flutter gen-l10n` & `flutter analyze --fatal-infos` passed (0 issues), `flutter test --concurrency=1` passed (39/39 passed, 0 failed — including EN/TE/HI 1.0x & 2.0x text scaling, tap-target/contrast checks, and role routing)
**CI evidence:** Base `ea6d142` green (`42205624861`); PR CI will run upon pushing `feat/anugacare-ui-modernization`.
**Merge status:** Not merged (opening PR on `feat/anugacare-ui-modernization`).
**Deployment and migration status:** Not deployed; zero migrations added or modified.
**Decisions and assumptions:** Preserved `action-noShow` enabled in `scheduled` before the start window per existing `trip_screen_test.dart` contract and solved `UX-04` via visual section separation (`Divider`). Preserved English strings asserted by `care_request_test.dart` while upgrading Telugu and Hindi customer-facing copy (`UX-06`).
**Blockers:** Physical Android device verification and named human Telugu/Hindi healthcare review (`QA-002`) remain `Not tested`. Hosted staging rollout (`REL-002`) remains blocked on `SUPABASE_ACCESS_TOKEN`.
**Uncommitted changes:** None after committing `WP-1`–`WP-6` (only untracked local `.swarm/` and `docs/logo/` remain untracked).
**Exact next action:** Commit and push `WP-1`–`WP-6` to `origin/feat/anugacare-ui-modernization`, open the GitHub PR targeting `main`, and coordinate reconciliation with Codex's PR #28.
**Next responsible agent:** Codex / Founder (review PR #28 and the new UI modernization PR; provide `SUPABASE_ACCESS_TOKEN` for hosted staging and complete `QA-002` human device/language review).

### Agent Session — 2026-11-09 15:40 IST

**Agent:** Gemini (Antigravity — Lead UI/UX Engineer & Independent Product Analyst)
**Task ID / Name:** `WP-0` / Permanent Multi-Agent Handoff Policy, UX Audit Register (`UX-01`–`UX-08`) & Modernization Plan
**Repository / Worktree:** `D:\AI-Workspace\Ideas\Anuga`
**Branch:** `feat/anugacare-ui-modernization`
**Starting commit:** `ea6d142fb0ab6662b64369a3bdb0704f14d3e1e9` (`origin/main`)
**Current commit:** `71fb555`
**PR:** Pushed to `origin/feat/anugacare-ui-modernization`
**Scope:** Establish permanent multi-agent handoff policy in `AGENTS.md`, record the complete independent UX audit (`docs/UX_AUDIT.md`) and phased implementation plan (`docs/UX_IMPLEMENTATION_PLAN.md`), preserve Codex's Task 5 / PR #28 state, and prepare isolated branch `feat/anugacare-ui-modernization`.
**Completed work:** Created `docs/UX_AUDIT.md` and `docs/UX_IMPLEMENTATION_PLAN.md`; updated `AGENTS.md`, `README.md`, `docs/HANDOFF.md`, `docs/TASKS.md`, `docs/EXECUTION_STATE.md`, and `docs/PROGRESS_LEDGER.md` while preserving Codex's Task 5 checkpoint entries.
**Files changed:** `AGENTS.md`, `README.md`, `docs/UX_AUDIT.md`, `docs/UX_IMPLEMENTATION_PLAN.md`, `docs/HANDOFF.md`, `docs/TASKS.md`, `docs/EXECUTION_STATE.md`, `docs/PROGRESS_LEDGER.md`
**Tests and actual results:** `apps/ops_console`: `pnpm lint` passed, `pnpm typecheck` passed, `pnpm test` passed (9 files, 70/70 tests).
**CI evidence:** Base commit `ea6d142` (`origin/main`) passed CI run `42205624861`; Codex's PR #28 head `7fa7cb2` passed CI run `42343362420` (7/7 jobs).
**Merge status:** Not merged.
**Deployment and migration status:** Not deployed; no migrations added or modified.
**Decisions and assumptions:** All UI/UX modernization runs in `D:\AI-Workspace\Ideas\Anuga` on `feat/anugacare-ui-modernization`.
**Blockers:** Hosted staging migration/rollout remains blocked on `SUPABASE_ACCESS_TOKEN`.
**Uncommitted changes:** Committed at `71fb555`.
**Exact next action:** Proceed to `WP-1`–`WP-6`.
**Next responsible agent:** Gemini.

## Task 5 release review and hosted access checkpoint (2026-11-07 15:52 IST â€” Codex in `anuga-trips-fix`)

Completed on `feat/g7-ui-staging` (PR #28): independent review of `ea6d142..7fa7cb2`
returned ready to merge, no Critical/Important findings. PR #28 documentation
checkpoint `7fa7cb2` passed all seven jobs in `42343362420`. Read-only Vercel
access confirms project `anuga` and READY deployment
`dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`. Supabase management `projects list` fails
with `Access token not provided`; hosted migration history and recovery coverage
cannot be verified. Task 5 remains IN_PROGRESS for PR completion and BLOCKED for
hosted rollout on Codex's workstream. Physical Android and human Telugu/Hindi
acceptance remain NOT TESTED.

## PR #22-#27 dependency stack merged (2026-11-06 16:20 IST)

After corrected local check-all and final PR #27 CI `42203978157` passed all
seven jobs, the authorized stack was merged to `main` in dependency order:
#22 `a8109ae`, #23 `5b838b6`, #24 `8d175b4`, #25 `038fb67`, #26 `88b0c0b`,
#27 `ea6d142`. Main run `42205624861` ran on final commit `ea6d142`. No hosted
migration or deployment occurred.

## Durable checkpoint validation (2026-11-06 16:05 IST)

Recovery state commit `7a06f1b` is pushed on PR #27. The corrected ignored
Unlazy G2 oracle reran the complete `scripts/check-all.sh` suite on that exact
head and passed (exit 0, expected success marker matched). PR CI run
`42203363529` is in progress; do not merge until all seven jobs pass. `STATE-001`
is VERIFIED. Active task is `INT-002`: sequential #22-#27 integration after CI.
No runtime file, hosted migration, deployment or synthetic record changed.

## Persistent mission recovery checkpoint (2026-11-06 15:57 IST)

The autonomous integration/UI/synthetic-staging mission now has durable state in
`docs/EXECUTION_STATE.md`, `docs/PROGRESS_LEDGER.md`, `docs/RECOVERY.md` and
`docs/RELEASE_CHECKLIST.md`. GitHub was freshly reconciled: `origin/main` remains
PR #21 merge `21ae9bc`; PRs #22-#27 are open in a literal dependency chain,
mergeable/CLEAN, and each has seven successful CI jobs. PR #27 is `d14e55c` and
CI `42172886236` is green. No stack PR, November hosted migration or target
staging deployment has occurred.

The full local suite on `d14e55c` reached `ALL CHECKS PASSED`; the ignored
Unlazy ledger still needs one clean evidence rerun after correcting its matcher.
The three new Family/Patient/Companion boards are reference inputs only. They do
not authorize maps/ETA, calls, clinical checklists, payments, expanded Patient
access or a four-stage replacement for the real visit lifecycle. Next: commit
and push this recovery checkpoint, rerun the corrected local gate, then merge
#22-#27 sequentially before starting new UI work from main. Physical Android and
human Telugu/Hindi approval remain separate, unperformed gates.

## PR #27 care-request CI fixture repair (2026-11-06)

Latest run `42167845149` failed only the real-Supabase care-request browser
journey. At 11:05 IST on Friday it requested 11:45-16:45 and selected Asha,
while the fresh seed already occupied Asha from 07:00-12:00. The database
correctly returned SQLSTATE `22023` and rolled the assignment back; the form
was neither stale nor timing out on a successful write. The journey now selects
unoccupied Ravi as primary, signs in as Ravi, and asserts the assignment RPC is
HTTP 200 before checking rendered state. Full local check-all passes. Corrected
head `4a05c29` passes all seven jobs in CI `42170840666`, including care, issue,
combined journeys and Android builds. G6 is restored; human/external G7/G8 stay
open. PR #26 is now a literal ancestor of #27. No occupancy, product or hosted
data behavior changed.

## Production operations hardening (2026-11-05)

Stacked after consent PR #24 and session PR #25. Truthful issue notifications,
sensitive error classes, a read-only catalogue attestation and executable
operations/recovery runbooks are prepared. Focused runtime tests are 35/35 and
the attestation SQL executes read-only in the disposable harness. See
`docs/PRODUCTION_READINESS_DASHBOARD.md` and the production-hardening evidence.
Hosted attestation, alert/recovery/incident drills, physical Android and human
language review remain open. NO-GO; no deploy/merge/cleanup/provider activation.

Final technical source `618af1d` on PR #27 passed all seven jobs in CI
`42041948258`; the stacked PR #26 run `42041948190` also passed all seven jobs.
The production hardening stack is PR #24 consent, #25 session recovery, #26
Companion occupancy and #27 operations. Seven of nine `PRODUCTION_GATES.md`
acceptance gates are met. G7 physical Android/native-language approval and G8
production boundary/recovery/safety/release attestations remain open.

## Session lifecycle hardening (2026-11-04)

`fix/production-session-recovery` invalidates late role/bootstrap responses after
logout/expiry/account switching in Ops and the unified Flutter app. Four Ops
regressions failed before and pass after; unified routing has 24 passing cases.
See `docs/evidence/production-hardening-2026-11-04/auth.md`. Real-device/session
expiry and language approval remain open. No hosted settings or token TTL changed.

## Production hardening in progress (2026-11-04)

Founder approved blocking Companion actions/details after trip-consent withdrawal
and one occupied visit per Companion, including late completion and concurrent
assignment enforcement. Pricing/buffers and the active-visit Ops safety workflow
remain gated. See `PRODUCTION_GATES.md` and
`docs/evidence/production-hardening-2026-11-04/README.md` for scoped execution.
Consent fix is on `fix/production-consent-enforcement`, after audit PR23. No
hosted migration, cleanup, merge, real SMS/payment or deployment authorized.

## Production readiness audit (2026-11-04)

**NO-GO for real patient onboarding.** Read `docs/PRODUCTION_READINESS.md` for
the 31-row release matrix, evidence boundaries, priorities and exact remaining
tasks. `docs/ANDROID_TEST_PLAN.md` is the executable Chrome/installed-PWA and
EN/TE/HI human test plan. Existing historical feature evidence is linked, not
replaced. Audit branch: `docs/production-readiness-2026-11-04`, based on `fd6c8dc`.
Draft audit PR: https://github.com/iamnawin/anuga/pull/23, targeted to
`feat/visit-issue-handling` to avoid mixing unmerged product changes into the
audit diff. New documentation-branch CI is separate from the verified product CI.

Fresh disposable probes reproduce trip-consent withdrawal leaving details/start
enabled (P0) and overlapping assignments accepted (P1). No hosted data changed.
Catalogue keys/placeholders match (27 unified / 138 Family / 74 Companion / 141
Ops per locale); 51 notification render cases pass structural/private-marker
checks. Human meaning approval and physical Android tests remain unperformed.
Current session discovers only Windows/Chrome/Edge devices.

PR #22 remains OPEN; main/current public synthetic app is PR #21 `21ae9bc`.
Read-only Vercel inspect and fresh app hash match deployment
`dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`; the November 4 fixes are not published there.
CI `41840577234` at code `335b58b` and `41842285891` at docs head `fd6c8dc` both
pass seven jobs. Fresh full local check-all passed. Production Node dependency
audit: zero advisories across 106 dependencies; this is not a historical/Flutter/
Deno security certification. Public auth settings expose signups enabled, contrary
to the seeded-staging setup instruction; no OTP request was made.

Hosted DB rows/Storage/logs, production tenancy/settings and backups are unverified.
Cleanup is a backup-first, exact-manifest proposal only. New audit scripts and
sanitized observations live in `docs/evidence/production-readiness-2026-11-04/`.
No runtime/migration/build/workflow changes, provider activation, deletion, main
merge or deployment. Next: founder assigns privacy/DB, device/language, ops/finance
and release owners to the report's remaining gates; do not start cancellation/
rescheduling or treat feature GATES.md as production approval.


## Request Care and issue review (2026-11-04)

Review scope confirmed by founder: latest issue handling plus Request Care
integration, on `feat/visit-issue-handling` (PR #22). The Ideas checkout is an
older hardening branch; current feature worktree is `Repos/anuga-trips-fix`.

Reproduced and fixed two defects: Ops resume after pickup replaced verified
pickup time; overlapping/failed Family booking refreshes could show stale cards.
New additive migration `20261104000100_preserve_issue_pickup_time.sql` retains
the original pickup fact. Family bookings reuses the existing guarded refresh
pattern. Added failing-before/passing-after SQL/widget tests and a browser
pickup-preservation assertion. Scope, acceptance mapping, current validation and
rollout limits: `docs/evidence/issue-review-2026-11-04/README.md`, `GATES.md`.

Focused SQL, all nine Family care-request tests and the complete sequential
check-all script passed. Fresh read-only review found no remaining blocker.
Corrected source `335b58b` passed all seven jobs in CI `41840577234`: real
Supabase SQL/Edge checks, care-request and issue browser journeys (including
pickup-time preservation), full billing/notification journey and Android builds.
The final receipt changes docs/gates only; product source still matches that SHA.
No merge, hosted migration or deployment has been performed. PR #22's old
preview is not this fix's preview.

Next: founder reviews PR #22 and the new migration/receipt. Apply
`20261104000100` after the previous private-notes migration before publishing
the corrected source, only as part of an authorized rollout. No original pickup
timestamps are guessed or backfilled. Review acceptance gates: five met, zero
unmet or abandoned; device/wording and takeover policy remain separate work.


## Visit issue and explicit Ops resolution (2026-11-03)

PR #21 reviewed at e5907ae: no blockers, seven CI jobs passed (41471118832).
Founder-authorized merge `21ae9bc` published to synthetic anuga.vercel.app,
READY `dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`; live app hash matches. Focused
read-only Family completed-visit refresh smoke passed; existing visit untouched.

Branch `feat/visit-issue-handling` reuses existing issue reporting/queue/actions.
Private issue/all Ops notes now stay out of Family events, inbox, raw reads and
mutation replies. A guarded row-locked resolution checks the exact current issue
timestamp and recorded prior stage before existing `advance_trip`; no fallback
restart, new transition, OTP bypass or underway reassignment. Ops actions require
explicit confirmation. Family/Companion service guidance and Updates refresh
are truthful; a short status badge remains readable at 200% in EN/TE/HI.

Founder applied migration20261103000100 in SQL Editor (success); preflight found
zero historical note copies. Hosted synthetic browser issue after OTP pickup ->
Ops sees private note/stage/assignment -> explicit same-stage resume -> all three
roles Completed passed. Family four RPCs/three direct tables exclude both private
markers; underway reassignment denied. Focused SQL32/Ops30/Family24/Companion34 and
sequential check-all passed (DB190/8skip, Ops66, shared29, Companion57/3skip,
Family55/6skip, unified37); status clipping received a targeted regression fix.
Evidence/actual IDs, retained records and preview are in
`docs/evidence/issue-handling-2026-11-03/`. Next: review the feature branch's PR and
preview, with latest CI tracked there. This new slice is not authorized for merge.
Preview: https://anuga-8hftd37pw-iamnawins-projects.vercel.app/app/ and /ops/;
READY `dpl_Hx1U8Qmo66T8fKyPg3uvj5bLrPzd`, product source `8f922ed` (team sign-in).
Final hosted rerun passed in 34.5 seconds after the label fix. Two new synthetic
schedules/trips are retained, both completed; exact IDs are in created-records.json.

Underway takeover still needs founder rules for handover, pickup verification
and responsibility. Existing active trips were not changed by the demo. Scoped
cleanup, physical phone and native-wording checks remain pending. Android stays;
180-minute window provisional; production/real data/paid providers gated.

## Assigned visit and Family progress (2026-11-02)

PRs #19/#20 merged14118fa/ce90f7c after combined seven-job CI41467176573
(NDK download retry only). Synthetic anuga.vercel.app now READY deployment
`dpl_7sNYcgT1NK6ASuzc2XAEnPNbK5Xm`; built5e2dfc2 tree equals merged main,
live app bundle matches. Separate clean integration worktree preserved.

Branch `feat/visit-progress` from combined main: existing companion stages and
OTP/notes already worked. Added guarded detail Refresh/resume and stale-read
protection; Family status/assignment and full IST milestone timestamps come from
persisted reads. No migration, permission or transition change. Hosted browser
journey passed all eight stages on new requestc99b9b35/tripbe9aba9d; each Family
refresh matched, all roles reloaded Completed. Focused SQL12/Family18/Companion31
passed; full sequential check-all passed (DB182/8skip, ops58, shared29,
Companion54/3skip, Family49/6skip, unified37). READY feature preview
https://anuga-ndumyejey-iamnawins-projects.vercel.app/app/ (Vercel team sign-in),
deployment dpl_GHJaZapWqQpPnL4vNeSHAyTCCfqp, product source e09ba86.
PR #21: https://github.com/iamnawin/anuga/pull/21 (open, not merged).
Next: founder preview/PR review; latest-head CI status is linked on the PR.
Do not merge the new slice automatically. Evidence:
`docs/evidence/visit-progress-2026-11-02/README.md`. Five new synthetic requests/
trips retained across driver attempts, exact IDs/states inventoried; no cleanup.
Physical phone/wording gaps and old fixture cleanup remain. Android preserved;
180-minute start window provisional; production/real data/paid providers gated.


## PR #19 + #20 integration (2026-11-02)

Founder authorized merging both and publishing to existing synthetic staging.
PR #19 merged at 14118fa; its latest head1c6e072 passed all seven CI jobs
(run41388577371). PR #20 head a25d777 passed seven jobs (run41426141224).
Read-only combined review found no blocker; product/workflow merge cleanly.
Both historical receipts below are retained. Combined CI and staging publication
will be checked before the assigned-visit progress slice on a new branch.
Physical phone/wording and hosted cleanup gaps remain; Android retained,
180-minute window provisional, production/real data/paid providers gated.


## Family care-request slice (2026-11-02)

Branch `feat/family-care-request` from main09a74f8; PR #19 remains separate. PR #20:
https://github.com/iamnawin/anuga/pull/20. Working preview (Vercel team sign-in):
https://anuga-9qi06zoi3-iamnawins-projects.vercel.app/app/ and /ops/;
READY dpl_EB72Cb7QJqnF7oycpuD3y1fVbqtV, source93c028b. Browser demo used the
same prebuilt output on loopback with the hosted backend. No production promotion.
Initial CI caught a shared-test editor grant leak; scoped fixture cleanup fixed
care/dispatch19/19. Latest CI tracked on PR #20; no product/schema change for fix.

Implemented registered-patient/centre/package/ISTpickup review/submit, persisted
one-date schedule requests, backend-derived Family status and existing ops
confirmation/assignment. Owner/editor access and owner trips consent enforced
in SQL; confirmation rechecks consent. UUID and natural-slot duplicate guards.
User applied migration20261102000100; hosted browser journey passed: request
11b3459b-ca11-4d28-b626-892c2fedd956 -> ops confirms/assigns -> Family reloads assigned
tripd185a2fb-fe5c-4618-8e70-5711f9c6bdce. Concurrent HTTP retries returned the same ID.
Focused SQL11/shared2/FamilyUI7/ops22 passed; no historical manual verification.
Preview/evidence and exact five created synthetic schedules/two trips are in
`docs/evidence/care-request-2026-11-02/README.md`; cleanup not executed. Registered
centre only; no appointment, price, availability or payment promise. Next: PR/CI
and preview review; phone/wording checks pending. Android preserved, F05 provisional,
production/real data/paid providers gated. Previous grouping fixtures still need
refresh before reuse; their hosted cleanup remains pending.

Repository overview (2026-11-02): added the previously missing root README with
approved branding, synthetic screenshots, PWA-first/Android-preserved status,
quick-start commands and links to the source-of-truth docs. No application or
backend behavior changed; included in PR #19.

Documentation audit (2026-11-01): synchronized SETUP, app README, architecture,
PRODUCT_SPEC delivery priority, ADR0007 update and agent entry notes with the
PWA-first direction and preserved Android support. HANDOFF/TASKS/evidence were
already updated. CI at `4116517` passed all seven jobs (41311699371); subsequent
changes are docs only, with current checks tracked in PR #19. Phone unavailable
confirmed by founder; device/wording gaps and production gates remain explicit.

## PWA-first mobile readiness (2026-11-01)

Founder prioritized PWA; existing Android/APK support stays. Isolated feature
branch `feat/anugacare-mobile-readiness` starts from current main `09a74f8`
(PR #18 merged after all seven final-head jobs passed, run 41308362201).
Fixed reproduced Flutter OTP route-back behavior and cleared stale code/error
when changing number. No auth/RLS/backend access-rule changes.
Release web build against the existing synthetic backend passed; local build
`apps/anugacare_app/build/web`, ready-to-serve copy under
`artifacts/pwa-readiness/site/app`. Chrome installability diagnostics pass;
EN/TE/HI sign-in and populated homes visually reviewed at 360x780.
Fresh hosted-auth browser checks confirm Family/Asha/Ops identities, Family
navigation/detail/back/session reload, logout/account switching, companion
injected-error recovery and Ops guidance. No new signed-in /ops/ journey.
New widget matrix: 15 passed (360x640, each locale at1x/2x, keyboard inset,
route Back, role guidance, lifecycle/logout). Native/installed-PWA Back,
actual keyboard, OS resume/termination and phone installation remain Blocked:
no SDK/emulator/phone. Wording approval is separate and outstanding.
Existing unified CI APK retains Android support and now gets public synthetic
backend settings plus an uploaded artifact; native runtime remains unverified.
Sequential check-all exit0 (PGlite170/8 skips, ops54, shared27, companion47/3
skips, family35/6 skips, unified37); final focused15 matrix rerun passed.
Full result ledger/screenshots: `docs/evidence/pwa-readiness-2026-11-01/README.md`.
No deployment. Hosted fixture cleanup pending; refresh fixtures before new
grouping checks. F05 180 minutes provisional; production/real data/paid providers
gated. Follow-up PR: https://github.com/iamnawin/anuga/pull/19. Automated CI
status is tracked on its checks tab. Next manual step: phone PWA installation,
keyboard/system Back/background checks and native-speaker wording approval
when a phone is available.
Follow-up desktop browser checks also Pass: browser-history Back from OTP
stays on /app/ and returns to phone entry; offline Refresh shows an error then
recovers after reconnect; frozen/active lifecycle retains Asha view; logout and
reload remain signed out. Sanitized followup-results.json and offline screenshot
are in the same evidence folder. No product code changed in this follow-up.
Latest code/docs head 3c31c1c passed all seven jobs (run41310853678); subsequent
follow-up changes contain evidence/docs only; latest checks are on PR #19.


## Staging verification takeover (2026-10-31)

Current worktree `D:\AI-Workspace\Repos\anuga-trips-fix`, branch
`docs/staging-verification-2026-10-30`. Started clean; other worktrees preserved.
PR #17 is merged at `e18a0d23db35b59ebbdb31fb8eff1e4f6c452ff6`. Live alias verified
through authenticated Vercel inspect/API: READY deployment
`dpl_BcdNXbscaAv1U1rqUh15GzodHxA7`, source exactly that merge commit. Live Flutter
bundle hash matches the existing staging artifact. No new deployment performed.

- Fixed `supabase/seed/companion_trip_groups.sql`: any execution time in IST,
  Previous at yesterday's last microsecond, Today noon, Upcoming tomorrow 10:00.
  The RPC's rolling 24-hour lookback means Previous expires at next IST midnight;
  rerun/refresh then. Patient-detail permissions unchanged.
- Synthetic/Asha guards, exact three IDs, collision and dependency refusals;
  reruns update in place. Separate cleanup refuses dependencies and foreign
  ownership. No hosted SQL run by the agent; `demo_refresh.sql` not run.
- Family `9000000101`: session identity projected in browser as
  `20000000-0000-0000-0000-000000000001` / `919000000101`. Home/bookings,
  Records/Bills/Updates navigation, booking detail/back, logout and reload PASS.
- Asha on `/app/`: live auth endpoint confirms `30000000-...-0001` /
  `919000000201`. Previous (Oct 30 23:59 Completed), Today (Oct 31 noon), Upcoming
  (Nov 1 10:00 masked) PASS; all three exact fixture IDs in her RPC result.
  Ordinary refresh clears cards then restores them. Overlapping-response test
  delivered older empty result after newer populated result; populated cards
  stayed. Retry **injected-error test** PASS: error and visible Refresh recovery
  control, then successful reload. Temporary fetch hooks removed and page
  reloaded. Family â†’ Asha switching and Asha logout PASS.
- Asha protected reads: own trips 200/9 rows; family/ops RPCs 403/42501; direct
  patients read zero rows. Sanitized auth/access output in companion-access.json.
- Full fast checks exit 0: PGlite 170 pass/8 skipped, ops 54, shared Dart 27,
  companion 47/3 skipped, family 35/6 skipped, unified 22. All format/analyze,
  lint/typecheck/build checks passed. 16 fixture tests cover real SQL/RPC windows,
  IST boundaries, guards, reruns and cleanup; local PGlite only.
- Full ledger and SQL walkthrough:
  `docs/evidence/staging-verification-2026-10-31/README.md`; sanitized deployment
  evidence alongside it. No OTPs or session tokens recorded in repository files.

Founder supplied matching hosted SQL output for all three fixture rows, with
deadline `2026-11-01 00:00:00` IST (recorded in `fixture-hosted-result.json`).
Agent did not execute hosted SQL; the final rows do not prove rerun count.
Draft follow-up PR: https://github.com/iamnawin/anuga/pull/18; code CI at
`ec86d55`: https://github.com/iamnawin/anuga/actions/runs/41210470804.
SQL passed 178/178 (162 real Supabase, 16 PGlite fixture tests); browser install
failed because latest runner became Ubuntu 26.04, unsupported by Playwright
1.56.1. Pinned only that job to Ubuntu 24.04. Rerun `41210884363` at `e200f58`
passed all seven jobs: SQL 178/178, ops browser 7, both real-DB Flutter tests,
full JOURNEY PASSED and three debug APKs. `ci.json` records tested source.
No app changes; remaining receipt changes are docs only.

Ops completion (2026-11-01): repeated authorized synthetic sign-in on `/app/`.
Live verification response 200 confirms `10000000-0000-0000-0000-000000000001` /
`919000000001`. Observed Use the ops console and operations-account guidance;
unified session cleared. Back to sign in returned blank shared sign-in without
prior account views. No automatic console transfer/link; no new /ops/ journey.
Passive identity observer removed. Sanitized result: `ops-access.json` beside
the ledger. All requested browser ledger rows now Pass. Receipt head `e15f21d`
passed all seven CI jobs (run `41212055526`).
Exact next task: push this docs-only Ops receipt, confirm CI on its final head,
then mark PR #18 ready and merge under founder authorization and repository
protections. No deployment. Oct 31 fixture deadline has passed; rerun the narrow
fixture for future grouping checks. Hosted cleanup was not run; two hosted runs
are not independently proven.
The 180-minute start window remains provisional; real data, paid providers and
production launch remain gated. This section supersedes historical next tasks.

## Stack merged, staging check, companion trips fix (2026-10-29)

Founder authorized merging PRs #12 -> #13 -> #14 -> #16 in order. All four merged (merge commits
cf83d00, a18e046, 5075857, f68c271); main is f68c271 and its CI passed all 7 jobs. No human
reviews exist on these PRs; the only comments are from the `ecc-tools` bot. Stacked PRs had to go
through GitHub's async merge endpoint; #16 needed a no-change `-s ours` merge of main (main's tree
equalled #16's old base) before it could retarget. No force push.

- **Deployment:** none triggered. Vercel Git deploys are off and both deploy workflows are manual.
  The live build (`dpl_AXCU2dk617jCXhNzinmEfUgq5ADb`, from 8539c3c) has the same tree as main.
  `/`, `/app/`, `/ops/schedules/`, `/family/`, `/companion/` return 200.
- **Hosted migrations:** `20261022000100`, `20261027000100`, `20261027000200` all applied.
- **Staging, ops (done):** Create trips on a Mon/Wed/Fri 07:00 schedule: first press 7 created /
  5 skipped, second press 0 created / 12 skipped; upcoming trips 5 -> 12.
- **Staging, companion `+919000000201` on `/app/` (done; founder entered the code):** My trips
  lists 6 upcoming trips (details only for the nearest; others say details appear closer to
  pickup); trip detail opens, Start disabled with "You can start from 4:00AM", back returns to the
  list. With this session, from the page: `companion_my_trips` 200; `ops_exception_queue` 403
  "ops only"; `family_my_patients` 403 "family accounts only"; direct `patients` read 0 rows.
  Sign-out returns to the shared sign-in and removes the `anuga-app-auth` session.
- **Staging, not yet done:** family on `/app/` (home, bookings, navigation, logout), whether the
  family home shows any companion data after the switch, and an ops account on `/app/`. Blocked
  on the founder entering the hosted test code.
- **ADR 0007 accepted:** founder approved the unified-app direction.
- **F05:** the 180-minute companion start window is implemented (one `app_settings` row, enforced
  in the database and shown in the app) but remains a provisional product value, not an approved
  business rule.
- **Companion trips fix** (branch `fix/companion-trips-today`): `TripsScreen` listed past trips
  under Today; now they go under a new **Previous** heading. Also: a slower earlier refresh cannot
  replace a newer result, refresh clears old cards, Retry button after an error, `previous` string
  in en/te/hi (te/hi need native review). The unified app's companion home uses the same screen.
  Ported from the uncommitted ANU-004 worktree (`anuga-product-inventory`, left untouched); its
  doc edits target the unmerged ANU-002/003 docs and its screenshots show the old title, so they
  were not ported.
- Checks: companion `flutter analyze --fatal-infos` clean, `flutter test` 47 pass / 3 skipped
  (new `trips_states_test.dart`, 4 tests; 3 fail on the old screen); unified app analyze clean,
  22 pass (new Previous-not-Today test fails on the old screen). Not run: full
  `scripts/check-all.sh`, real-Supabase tests (no Docker).

Exact next task: finish the signed-in staging checks above; then publish the fix to anuga.vercel.app
(manual deploy, separate authorization) and check a past trip in `/app/` as companion.

## Demo data, Create trips, unified app on the test site (2026-10-27)

Branch `feat/anugacare-brand` (PR #16), pushed (3e91a3b), not merged. Published to anuga.vercel.app
(deployment `dpl_AXCU2dk617jCXhNzinmEfUgq5ADb`): `/`, `/app/`, `/ops/schedules/`, `/family/`, `/companion/`
return 200 and the console bundle calls `ops_create_schedule_trips`. 2026-10-28: founder applied
migration `20261027000200` to the hosted synthetic project in the SQL editor (function present,
`authenticated` can execute) and ran `demo_refresh.sql`: 7 upcoming trips, 4 today, 1 issued bill.

- `supabase/seed/demo_refresh.sql` (SETUP â†’ Hosted staging): makes every screen show current
  synthetic data; refuses to run on a database with non-synthetic patients or accounts.
- Migration `20261027000200_ops_create_trips.sql` + ops console Schedules â†’ **Create trips**:
  shows each pickup date as created or already scheduled; repeat presses create nothing new.
- `scripts/build-staging.sh` builds the unified app to `/app/` and links it from the root page.
- Billing and no-show rules untouched; F01, F03, F07 and no-show billing remain founder decisions.
- Checks: `pnpm db:test` 154 pass / 8 skipped (2 new: created/skipped with no duplicates; family,
  companion and out-of-range refused); ops lint, typecheck, 54 Vitest pass; demo_refresh run twice
  on PGlite and refused with a non-synthetic patient or phone (throwaway test, not committed).
- Not run: Playwright e2e and real-Supabase tests (no Docker).

Exact next task: test Create trips (press twice) in `/ops/` and both roles on the unified app at
anuga.vercel.app/app/.

## Logo and Next.js patch (2026-10-27)

Branch `feat/anugacare-brand`, stacked on `feat/companion-start-window`. Not merged, not deployed.

- Founder logo in `docs/logo/` (see its README). Generated with `scripts/make-brand-icons.py`:
  web icons, favicons and Android launcher icons for the three Flutter apps, the ops console
  favicon, the symbol on every sign-in screen and the lockup on the site root page. Web manifests
  now use `#00666B` / `#F7FBFA` instead of the Flutter default blue.
- `next` and `eslint-config-next` 16.4.0 -> 16.4.3: 2 critical (unauthenticated RCE) and 1 high
  advisory, fixed from 16.4.1. `pnpm audit --prod` reports none.
- Checks: `scripts/check-all.sh` ALL CHECKS PASSED (PGlite 152 / 8 skipped, ops 52, shared Dart 27,
  companion 43 / 3, family 35 / 6, unified 21); sign-in tests assert the symbol is shown.
  `scripts/build-staging.sh` built the site; headless Edge screenshots of root, family and ops
  sign-in show the logo.

Exact next task: apply migrations `20261022000100` and `20261027000100` to the hosted synthetic
project, publish this build to anuga.vercel.app, smoke test, then add test.anugacare.com.

## Unified AnugaCare entry, X1 first slice (2026-10-26)

Branch `feat/anugacare-unified-entry`, stacked on `feat/anugacare-hardening` (PR #12, open, head
f9285b8). Draft PR, not merged, not deployed. Owner: iamnawin with Claude Code.

- New `apps/anugacare_app` (ADR 0007, proposed): one phone/OTP sign-in, no role picker, home from
  `profiles.role`; ops accounts sent to the console, other roles refused; checking, retry and
  expired-session states. Family and companion screens mounted unchanged through new
  `lib/family_app.dart` / `lib/companion_app.dart`; both apps still build alone. No SQL, RPC, auth
  provider or ops console change. `PRODUCT_SPEC` Â§5a updated.
- `scripts/check-all.sh` and CI job `anugacare-app` added; both run `flutter pub get` in the family
  and companion apps first (their generated l10n is gitignored).
- Evidence and reference-research ledger: `docs/evidence/unified-entry/README.md`.
- Checks run (each check-all step, sequentially; Flutter tests with `--concurrency=1` for memory):
  install, `pnpm typecheck` pass; `pnpm db:test` 150 pass / 1 fail / 8 skipped; ops lint,
  typecheck, 52 Vitest pass, `next build` blocked; shared_dart 27; companion 39 / 3 skipped;
  family 35 / 6 skipped; anugacare 21; all analyze clean; `git diff --check` clean.
- Failures, both outside this branch's files:
  - `access.test.ts` "a companion sees only trips assigned to them" depends on the clock: PR #12's
    F04 window hides seed trips (Mon/Wed/Fri 07:00 from `current_date`) at some times of day.
    Failed at 19:20 IST on a Monday. Fix belongs in PR #12 (create an in-window trip in the test).
  - Local `next build` stops with Next.js `SecurityFatalError` (16.4.0 flagged as vulnerable);
    the same build passed in CI. A Next.js upgrade is a dependency change not made here.
- CI on the draft PR (run 40337051931): `anugacare-app` (including debug APK), family, companion,
  shared-dart, ops-console pass. `db-tests` and `supabase-local` fail on the same clock test (real
  Supabase: 158 pass / 1 fail), so CI did not reach the ops e2e, real-DB Flutter tests or journey.
- Not run locally: real-Supabase tests, Playwright e2e, journey (no Docker); `flutter build apk`
  (no Android SDK); device or emulator run.

Exact next task: review the draft PR and accept or change ADR 0007; fix the two failures above in
their own branches; then a device run against Supabase local.

## Companion start window in the app (2026-10-27)

Branch `feat/companion-start-window`, stacked on `feat/anugacare-unified-entry` (PR #13). Not pushed,
not merged, migration not applied to hosted, not deployed.

- Migration `20261027000100_companion_start_time.sql` recreates `companion_my_trips()` with
  `start_allowed_at` (pickup minus `companion_start_minutes_before`); execute re-granted to
  `authenticated` only.
- `CompanionTrip.startAllowedAt` (nullable; older servers leave Start enabled). Trip screen disables
  Start and shows "You can start from {time}" until then, and enables it on a timer.
  Telugu/Hindi strings for `startOpensAt` need a native check.
- Checks: new DB test passes with the migration, fails without it; `scripts/check-all.sh` ALL CHECKS
  PASSED (PGlite 152 pass / 8 skipped; shared Dart 27; companion 43 / 3 skipped; family 35 / 6;
  unified app 21). The ops build first stopped on a Next.js security advisory notice and passed on
  retry; no upgrade run. Not run: real Supabase, Playwright, journey (CI covers them).

## AnugaCare hardening (2026-10-22)

Branch `feat/anugacare-hardening` from the old checkpoint branch with main `de28006` merged in
(TASKS/HANDOFF conflicts resolved by keeping both sides). Published as a draft PR for review.

Status, kept separate: implemented = yes; merged = no; hosted migration applied = no;
deployed = no. F05 window (180 min) is a placeholder pending founder decision.

- Brand: AnugaCare (ADR 0006). Only user-facing strings changed. Telugu/Hindi spellings
  `à°…à°¨à±à°—à°¾à°•à±‡à°°à±` / `à¤…à¤¨à¥à¤—à¤¾à¤•à¥‡à¤¯à¤°` need a native check. Trademark search open (M10).
- Analysis: `docs/research/anugacare-mobile-analysis.md`. No APK exists (CI builds but does not
  upload; no Android SDK here). Hosted web bundles scanned: anon key only, no service key, no
  third-party SDKs, no source maps. REA ran on the family bundle but ran out of memory on dart2js
  output (partial). Recommendation: keep Flutter, merge the two apps, ops console stays web.
- DB fixes F02, F04, F05, F06 in `supabase/migrations/20261022000100_trip_controls.sql`.
  Ops console shows the new `not_trained` reason. The ops Playwright spec now has ops start
  Ravi's trip (seed trips can be days ahead, past the companion start window).
- Checks run: `pnpm db:test` 151 pass / 8 skipped / 0 fail (was 142/8); new tests fail 8/9 with
  the migration removed (the 9th checks family/ops access is kept); `pnpm typecheck`;
  `pnpm contract:export` no drift; `scripts/check-all.sh` ALL CHECKS PASSED; ops lint, typecheck,
  52 Vitest; both Flutter apps analyze clean, family 35 pass / 6 skipped, companion 39 / 3.
- Not run: `pnpm db:test:supabase`, Playwright e2e, `scripts/e2e-journey.sh` (no Docker). CI
  covers them on push. Hosted staging DB not migrated (no deploy authorized).

- 2026-10-23: real-DB Flutter tests (both `supabase_local_test.dart`) now have ops start the seed
  trip, since it can be past the start window. Rollout order and verification are in the PR body.

Exact next task: founder answers on F01 consent, F03 occupancy, F07 pricing and the F05 window;
review the draft PR; then merge, migrate and deploy in the order given in the PR.

## Architecture walkthrough (2026-10-20)

Added `docs/ARCHITECTURE.md`, written from the code on main (64c4603). It covers the
components, the database layers, who calls what, the flows (sign-in, schedules, a visit,
notifications, vault, billing), integration status, how to test each part, and the gaps for
real customers.

Key findings:
- WhatsApp, push and SMS have only the outbox and a `test` adapter.
- `notify-dispatch` isn't scheduled or deployed to the hosted project.
- Google Maps and Sentry aren't built.
- Razorpay works with test keys only, and the family app has no checkout.
- There are no onboarding screens: patients, families, companions and schedules come from SQL
  or the seed.
- Nothing generates trips on a schedule.

Docs only; checks: `git diff --check`.

## Salesforce decision (2026-10-20)

Branch `claude/trusting-bell-4fgv07` (PR #2). Main was merged in first, taking main's version of
every file: PR #8 and #9 already carry all of PR #2's staging work, so PR #2 now only adds this
decision. Docs only; no code, migration or secret changed.

- Founder chose to keep the built apps and Supabase as the system of record. Salesforce gets a
  one-way, minimum-field copy for ops, CRM and pilot reporting. Recorded in
  `docs/adr/0005-salesforce-ops-copy.md`; spec 5a and 7 updated; new milestone M9a in `docs/TASKS.md`.
- Options turned down: Salesforce as the main database (a rewrite of M2â€“M9, with access checks
  moving out of Postgres); Salesforce alone (throws away the apps).
- Gated with M10: real data in Salesforce, a paid Hyperforce India org, a DPA and the
  privacy-notice update. A Developer Edition org with the synthetic seed is fine for building.
- Checks: `git diff --check` only. App and DB suites not run: no code changed.
- Risk to confirm: the 2026-10-11 hosted notes give the synthetic sign-in code as `123456`,
  which ADR 0004 says not to use for staging. Founder to confirm or change it in the dashboard.

Exact next task (stream S6): build M9a.
1. Migration `crm_outbox` and the allow-list triggers.
2. Claim and mark RPCs.
3. Allowed and denied tests.
4. Edge function `crm-sync` with the `test` adapter.
5. Run `pnpm db:test` and `scripts/check-all.sh`.

Salesforce-side setup (objects, `Anuga_Id__c`, Private org-wide default, integration user) waits
for the founder's Developer Edition org.

## Founder-authorized combined publication (2026-10-11)

FINAL: PR #8 merged at 3c6f2ac; necessary hosting/session fix PR #9 merged at 37bdae2cb77240ae06bfd000e6520613fd51903f. Published code de8f72a passed all six jobs in https://github.com/iamnawin/anuga/actions/runs/38150546061: real Supabase 150/150 with zero skips, ops browser 7 pass, both app real-Supabase tests, full JOURNEY PASSED through notifications/test billing, both APK builds. Main app/build/security/workflow contents exactly match the tested/published code; later commits are shared receipts only. Final documentation-only receipt checked with git diff --check, app tests not repeated; main push/receipt CI may be running, distinct from the completed code-bearing run above. CI receipt: docs/evidence/hosted-test/ci-summary.json.

Founder next: open https://anuga.vercel.app and select Ops, Family, Companion in separate tabs. Phones 9000000001 / 9000000101 / 9000000202 and configured synthetic sign-in code 123456. For an immediate complete visit, run the additive synthetic visit SQL in docs/LOCAL_TESTING.md through the synthetic project's SQL Editor, then assign Ravi in Ops, generate pickup code in Family and complete pickup/centre/return/note in Companion; refresh Family summary. No seed reset or weaker time window. Optional payments secret remains dashboard-only. Source PRs #2/#4-#7 remain intact; M10/real data/paid providers not authorized.

LIVE: https://anuga.vercel.app serves the ANUGA chooser and all three redesigned apps: /ops/login/, /family/, /companion/. Published source de8f72a, Vercel deployment dpl_FHuVVy4Th8XzxEqQAz3Ekc1ZFyN3, unique URL https://anuga-4z0392uxl-iamnawins-projects.vercel.app. All four routes HTTP 200. Published real-browser sign-ins for ops/owner/Ravi, independent reloads and companion sign-out isolation PASS, zero page errors. Synthetic data only; no service-role key in apps. Evidence: docs/evidence/hosted-test/deployment.json and published-session-receipt.json.

Necessary hosting fix PR #9: https://github.com/iamnawin/anuga/pull/9, now merged. This live/PR-link historical receipt changed docs only; app tests not repeated. Final verified code CI and merge receipt are above. Founder may open the live site now; an active-window synthetic visit still needs the SQL fixture in LOCAL_TESTING for a full manual visit.

Founder explicitly answered yes to merging PR #8 and publishing all three redesigned synthetic apps at anuga.vercel.app. This supersedes the earlier no-merge/no-deploy restriction for this test-site task only. M10 and real-data/paid-provider launch remain gated.

PR #8 merged at 3c6f2ace0ff96d2c6f7583b4745fe0829d9b78aa. Its final head cbe3b20 CI run 38146021839 passed all six jobs; merged main run 38148157637 also passed. Source PRs #2/#4-#7 remain intact; #3 is obsolete. New branch deploy/combined-test-site carries necessary combined-hosting fixes and receipts.

Changes: web-only persisted session keys in both Flutter entry points; native settings unchanged. Browser bootstrap scopes the SDK's fixed Supabase BroadcastChannel per app, while retaining same-app tab sync and leaving other channels unchanged. Real browser regression reproduced cross-role session overwrite with storage keys alone, then passed after channel isolation. Auth adapters, RPCs, RLS/grants, migrations, shared Dart, payment/vault handlers and their tests are unchanged.

Build fixes: Git Bash path conversion excluded for sub-paths, guarded cleanup of generated .vercel/output only (preserves Vercel project link), local CanvasKit resources, ANUGA/mint/teal landing with three app links. New scripts/web-session-smoke.mjs tests real sign-ins, independent reloads and companion sign-out without losing ops/family sessions. Manual publish Anuga synthetic test site workflow builds/prebuilt-publishes all three; Git auto-deploy disabled via root vercel.json so later pushes cannot replace it with ops-only output.

Checks: final scripts/check-all.sh native exit 0, PGlite 142 pass/8 real-Supabase skips, ops 52, shared Dart 27, companion 39/3 environment skips, family 35/6 environment skips; all format/analyze/lint/typecheck/build steps pass. Separate ops lint/typecheck/test and both Flutter analyze --fatal-infos/test pass. Final three web release builds pass. Existing upstream non-failing wasm/font warnings retained. Shell/JS syntax and whitespace checks pass. Hosted synthetic staging-smoke passes allowed/denied roles, anon denial and both function CORS. Real local combined-site browser sign-ins/reloads/isolated sign-out pass with zero page errors. Evidence: docs/evidence/hosted-test and ignored artifacts/integration.

Hosting access: founder completed Vercel CLI device sign-in. Existing anuga project verified by ID prj_OIgy0tgFWjWwiCZVoTTHqiE9ktHN/team_t3I2D0lrJ02PZ2a0AgeKV2gr. Changed rootDirectory/framework from apps/ops_console/Next.js to repository root/Other for prebuilt combined publication; previous settings snapshot is ignored artifacts/integration/vercel-before.json. No new project, paid service, database migration or secret in app. GitHub repository deployment secrets are not configured; today's publish uses authenticated CLI. Future manual Actions publication needs dashboard-scoped VERCEL_TOKEN and STAGING_TEST_OTP stored only in Actions secrets.

Not run locally: Docker real-Supabase full automated journey and Android device/emulator; authoritative merged-main CI passed real Supabase/full journey and both APKs. Native te/hi review not run. New deployment fix PR CI and published-site verification pending at this receipt.

Exact next task: publish the tested prebuilt output to existing anuga Vercel production target (synthetic test only), verify root/ops/family/companion and real independent role sign-ins, then record exact URL/deployment/CI results and merge the necessary publish fix PR after checks. Founder may need the documented additive synthetic visit SQL to put a booking inside the existing companion detail window; never reload hosted seed or weaken that rule.

## Combined local integration (2026-10-11)

Branch: `integration/local-anuga`, from fetched `origin/main` at `32d6631`. This section supersedes every historical next task below. PR #2 and #4-#7 remain OPEN and intact; PR #3 is obsolete. No main merge, deploy command or staging workflow run.

Integration PR #8: https://github.com/iamnawin/anuga/pull/8, OPEN. All six CI jobs PASS at `719361cf2eb730f9f23ea8d5df9d5777927c74fe`, run https://github.com/iamnawin/anuga/actions/runs/38145315706. Earlier integration `dff8319` run 38145263013 also passed all six jobs. Real Supabase: **150/150, zero skipped**, standalone ops Playwright **7 passed**, both companion/family real-Supabase tests and full `JOURNEY PASSED` through notifications and test billing. Both debug APK builds pass. Receipt: docs/evidence/integration/ci-summary.json.

Final receipt also restores PR #2's executable bit on scripts/build-staging.sh (Windows snapshot checkout lost that bit), clarifies synthetic hosted test-phone setup and normalizes documentation. No product source changes after the tested SHA. Shell syntax and final source snapshot/whitespace checks pass; full app checks not repeated for documentation and file-mode-only receipt. The final receipt push starts another CI run; the exact completed code-bearing SHA above is the verified result, not a claim about a pending receipt-head run.

Automation side effect: the existing Git-linked Vercel project `anuga` automatically posted completed preview checks when this branch/PR was pushed. The agent did not invoke a deploy command/workflow, open a preview or change Vercel settings. Preview protection was not independently verified. Local testing uses loopback only. No public deployment was requested or manually performed; do not claim that repository automation created no deployment.

Combined exact tracked source snapshots: PR #4 tokens/reference boards at `6076473`, PR #5 ops presentation at `b5b8d2e`, PR #6 companion widgets/l10n at `74728ab`, PR #7 family widgets/l10n at `378db4d`, plus PR #2 web scaffolds, Next export config, staging scripts/manual workflow, CORS wrapper/tests and setup ADR at `299a9bf`. Shared docs retain token decisions, each UI receipt and staging context. Took per-path snapshots instead of merging duplicate cherry-pick histories. Migrations, grants/RLS, RPCs, auth adapters, state machine, payment/vault handlers, shared Dart, tests and lockfiles are unchanged. The two existing Edge entry points only carry PR #2's tested CORS wrapper.

New: scripts/start-local.ps1 builds the actual Next export and Flutter web apps with the existing synthetic project's public anon settings. scripts/serve-local.mjs serves on loopback only, separate origins for independent role sessions. Rejects server keys and unrelated backend hosts. No package/dependency changes. Guide and synthetic visit SQL: docs/LOCAL_TESTING.md. Updated SETUP/CLAUDE for commands.

Checks: `C:/Program Files/Git/bin/bash.exe scripts/check-all.sh` native exit 0. Frozen pnpm install/root typecheck, ops lint/typecheck/build and all Dart format/analyze passed. PGlite 142 passed / 8 real-Supabase skips (PR #2 adds 2 CORS tests), ops 52, shared Dart 27, companion 39 / 3 environment skips, family 35 / 6 environment skips. Separate ops `pnpm lint`, `pnpm typecheck`, `pnpm test` passed. Separate both apps `flutter analyze --fatal-infos`, `flutter test` passed with same counts. `scripts/start-local.ps1` built all three release web apps. Flutter emits non-failing upstream Cupertino-font and wasm-dry-run warnings; no dependencies changed to suppress them. HTTP smoke: ops login/trips and both Flutter roots 200; traversal 403; unsupported POST 405. `node --check scripts/serve-local.mjs` and `git diff --check` passed.

Latest source CI inspected: PR #2 run 38131473596, #4 run 38135461326, #5 run 38135464723, #6 run 38135468540, #7 run 38135471172. All six jobs passed on each latest source head, including supabase-local. #7 logs explicitly show `JOURNEY PASSED` with real auth, pickup OTP, handover, return, note, notifications and test billing. This is source-branch CI evidence, not yet integration-head evidence.

Local backend probe: synthetic project auth settings HTTP 200, phone sign-in DISABLED, signups currently enabled. Vault and payments OPTIONS both 204 with browser CORS. No OTP requested, no hosted data changed. Docker/Android SDK unavailable, so local real-Supabase suites/connected journey/device run cannot run. Authenticated local browser journey and hosted smoke require founder phone setup; no mocked journey substituted. In-app Browser bootstrap failed before connection (global Node ESM issue); repository Playwright with installed Edge verifies real local builds instead. Native te/hi review not run.

Apps started: http://127.0.0.1:3100/login/ (ops 9000000001), http://127.0.0.1:3101/ (owner 9000000101), http://127.0.0.1:3102/ (backup Ravi 9000000202). Launcher session stays running; rebuild/restart command in LOCAL_TESTING. Use the founder-chosen hosted test sign-in code, not an assumed 123456; pickup code comes from the family booking.

Exact next task: founder enables Phone test sign-in for the five synthetic numbers in LOCAL_TESTING, disables new signups and sets the dashboard test code. Founder runs the documented additive synthetic-visit SQL (seed dates are old), then completes one visit across the three local tabs. Completed integration CI proves the connected automated journey on a fresh local Supabase stack; the founder's authenticated browser visit remains untested until hosted Phone setup. No Vercel/GitHub deploy secret or public deployment is needed. Optional test payments need dashboard PAYMENTS_WEBHOOK_SECRET; no secret goes into chat or app. Keep source PRs and integration PR #8 open and do not merge main.

## Final UI delivery receipt (2026-10-11)

This worktree is ui/s2-design-tokens. S2-S5 are pushed, OPEN, based on main, with the same committed S2 contract incorporated in each UI stream. No merge or deployment was performed.

| Stream | Branch | PR | Review evidence |
| --- | --- | --- | --- |
| S2 | ui/s2-design-tokens | https://github.com/iamnawin/anuga/pull/4 | docs/design/tokens.md, supplied15 boards and full panel mappings |
| S3 | ui/s3-ops-console | https://github.com/iamnawin/anuga/pull/5 | docs/evidence/s3-ui/README.md on S3:23 browser captures |
| S4 | ui/s4-companion | https://github.com/iamnawin/anuga/pull/6 | docs/evidence/s4-ui/README.md on S4:38 curated widget captures |
| S5 | ui/s5-family | https://github.com/iamnawin/anuga/pull/7 | docs/evidence/s5-ui/README.md on S5:25 curated widget captures |

Each branch ran scripts/check-all.sh to native exit0 before its PR. Frozen install/root typecheck,ops lint/typecheck/build,all Dart format/analyze passed. Exact final counts per branch: PGlite140pass/8 real-Supabase skips; ops52pass; shared Dart27pass; companion39pass/3 environment skips; family35pass/6 environment skips. Separate changed-app checks passed. S3 browser capture23cases, S4 render matrix5cases, S5 render matrix7cases passed. Final code/ownership/whitespace review passed; auth/RPC/adapters/migrations/access rules/tests/lockfiles unchanged. Documentation-only final receipt checked with git diff --check; app tests not repeated for this receipt.

Limits: S3 real local Next app used browser-intercepted synthetic responses, so it is presentation evidence. S4/S5 actual Flutter widget rendering used synthetic fake APIs and harness-only readable fonts; it is not device/real auth verification. Docker and connected Android device/emulator are unavailable; main-based mobile apps have Android scaffolds, while web staging remains separate PR #2. Real-Supabase suite/journey, device run, hosted staging and native-language review were not run. No security tests were weakened or manually skipped. Original checkout on claude/trusting-bell-4fgv07 and its untracked .omx/design input are preserved.

Founder commands and screen-by-screen differences are in each evidence README. Ops: documented local Supabase env then pnpm dev in apps/ops_console, http://localhost:3000/login. Mobile: flutter pub get then flutter run with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY on a connected device; local Android emulator URL http://10.0.2.2:54321. Only public/anon keys in apps.

Exact next task: founder reviews PR #4-#7 and the screenshots, then exercises the existing flows using synthetic backend/device setup. No agent merge is authorized. Hosted testing still needs PR #2 and founder dashboard steps from its SETUP; PR #3 is obsolete. M10/production remains gated. Resolve review feedback only within each stream's owned paths.


## S2 design handoff (2026-10-11)

Branch: `ui/s2-design-tokens`, from fetched `origin/main`. PR #2 remains OPEN and supplies staging context only; PR #3 is obsolete. This section supersedes the historical next task below for UI work. Founder now approves ANUGA visible branding, overriding older undecided-name wording; identifiers remain unchanged.

Changes: visually inspected 15 supplied concept PNGs and all seven previous ops screenshots. Preserved supplied PNGs, created `docs/design/tokens.md` with observed/adjusted colours, typography, focus/tap sizes, dark-mode extension, corrected-board precedence, complete screen mapping, scope differences and stream plan. Added current stream ownership/status to AGENTS and TASKS. No product code changed. Root coordinator owns shared docs and curated evidence for app workers.

Checks run: `C:/Program Files/Git/bin/bash.exe scripts/check-all.sh`, exit 0. Frozen pnpm install, root typecheck pass; PGlite 140 pass / 8 real-Supabase-only skips; ops lint/typecheck/build pass and 52 tests pass; shared Dart format/analyze pass and 27 tests pass; companion format/analyze pass, 39 tests pass / 3 Supabase-only skips; family format/analyze pass, 35 tests pass / 6 Supabase-only skips. `git diff --check` passes. Independent read-only token review: no material issues.

Not run: real-Supabase suites/journey (Docker unavailable); device/emulator checks (not part of documentation-only S2); hosted staging (founder dashboard steps remain separate); native Telugu/Hindi review. In-app browser bootstrap failed before browser connection because its kernel treats `require` as ESM; app streams may use repository Playwright tooling for local synthetic evidence. Graphify report absent; the supplied product spec, existing app files and token contract provide the bounded UI map.

PR status: https://github.com/iamnawin/anuga/pull/4 OPEN; no merge or deploy. Documentation line endings corrected after the initial commit; final diff whitespace check passes. Exact next task: incorporate this S2 commit into main-based `ui/s3-ops-console`, `ui/s4-companion`, `ui/s5-family` isolated worktrees, implement only assigned presentation paths, run full checks/app checks, capture local evidence and open separate PRs. No new auth/RPC/access/payment behavior or concept-only capabilities.

Last updated: 2026-10-08 (session 2, Claude Code cloud, branch `claude/trusting-bell-4fgv07`)

## Research/design push checkpoint (2026-10-22)

Founder requested committing and pushing the pending changes. Branch:
`checkpoint/research-design-2026-10-22`, based on local `5ec8f77`. This new branch
preserves the unpushed research/design checkpoint without overwriting the divergent
remote `claude/trusting-bell-4fgv07` branch. Added the founder's UI mockup PDF and
ignored `.omx/` generated logs/state, consistent with the existing checkpoint rule.
No application, database, dependency or deployment changes.

Checks: `git diff --check` and staged whitespace check; PDF header/trailer checked.
`scripts/check-all.sh` attempted through Bash but stopped at dependency installation:
WSL pnpm could not find Node (`exec: node: not found`). No application or database
suite completed; this checkpoint is documentation/assets only.

Exact next task: review this checkpoint against current main and carry forward the
research/design inputs as needed. Do not use this historical checkout as the current
implementation baseline. Push this branch to origin; no merge or deploy authorized.

## Documentation checkpoint (2026-10-16)

Founder authorized committing the existing local research/design work before the
product-inventory bootstrap. Branch: `claude/trusting-bell-4fgv07`, baseline
`299a9bf`. This checkout is historical; fetched `origin/main` is the implementation
baseline for the next task. Preserve the research reconciliation and cancellation
worktree pointers below as dated receipts, not current runtime verification.

Checkpoint scope: three research documents, four public-site screenshots, fifteen
design boards, the Excalidraw source, and existing HANDOFF/TASKS edits. Local `.omx/`
logs/state are excluded. No application, SQL, dependency or provider changes.
Checks: staged whitespace checks passed; design JSON parsed and PNG signatures checked. App/database/runtime
checks are not run for this documentation checkpoint. No merge or deployment.
Exact next task: carry out the supplied product-inventory documentation bootstrap
from current main, preserving these local inputs and separating evidence by branch.

## Cancellation validation complete (2026-10-13)

Implementation remains uncommitted in `D:/AI-Workspace/Repos/anuga-cancellation`,
branch `feat/companion-cancellation-notification`, main base `64c4603`.
The missing-local-tools blocker below is resolved. Real local Supabase suite:
157 passed, zero skips, including simultaneous cancellations. Companion notices
delivered safely in en/te/hi through real Edge/test adapter with no repeated-dispatch
duplicate. Full browser/Dart/Edge journey PASSED, including existing test-mode billing.
Typecheck, unchanged contract export and final diff review passed. No extra app,
migration or test-source changes in this continuation; implementation worktree's
HANDOFF/TASKS/AGENTS/SETUP record the validation and reproducible local-tool setup.
Local Supabase/Docker services and keep-alive stopped; Docker autostart disabled;
tools/images retained. Implementation worktree handoff is the authoritative receipt
and lists the exact uncommitted files ready for review.
PR #10 remains OPEN, unchanged and unmerged. No commit, push, PR creation, deployment
or new business policy. No validation blockers remain. Exact next task: founder
reviews the uncommitted implementation diff; commit/PR requires separate authorization.
Ops intake and app consolidation are separate tasks. Earlier research inputs preserved.

## Implementation continuation pointer (2026-10-12)

Founder authorized the companion cancellation notice task after the research review.
Implementation is uncommitted on `feat/companion-cancellation-notification` in
`D:/AI-Workspace/Repos/anuga-cancellation`, based on current main `64c4603`.
Read that worktree's `docs/HANDOFF.md` for changed files, runtime results and blockers.
One new migration reuses the shared transition/outbox with cancellation-only duplicate
protection; unchanged PR #10 SQL is a rolled-back test fixture, not a merge.
Final PGlite: 148 passed, 9 skipped; typecheck passed; contract unchanged. Real
Supabase/concurrent PG/full connected journey remain blocked by missing local tools.
No commit, push, merge or deploy. This older checkout's research/TASKS/design inputs
are preserved; no application implementation belongs here. Next: review the new
worktree diff and run outstanding real-Supabase checks in a disposable environment.

## Current-main / PR #10 research reconciliation (2026-10-12)

Working checkout remains `claude/trusting-bell-4fgv07` at `299a9bf`; research
documents are untracked and the previous cleanup's HANDOFF/TASKS edits are retained.
Fetched origin and compared main `64c4603e5812358f6030ab8c9038747a93ba9b40` with
OPEN PR #10 head `c561a9d27a2098c3ee5932b60e4e09ceb6ccb46e` using GitHub CLI,
`git show`, `git grep` and branch diff. No checkout/merge/app modification.
This section supersedes historical next-task statements below for this review.

Updated only the three research documents and this handoff. Matrix section 5 now
separates current main from PR #10: main has combined redesigned web hosting and
independent sessions; PR #10 implements existing-pattern weekday editing and future
unstarted replacement, with companion notifications for that specific cancellation
path. It remains unmerged; no claim about today's hosted schema or live feature.
Intake/new-patient/new-schedule/generation UI, pause/end/individual moves, automatic
generation, readiness/waiting capture, early warnings/reminders, structured needs,
general companion cancellation notices and policy features remain gaps. Receipts,
invites, metrics, availability/earnings and unified mobile packaging remain deferred.

Return permissions resolved from code (unchanged in PR #10): assigned companions
and Ops can advance handed_over -> session_done -> returning. Owner/editor have
only the family scheduled -> cancelled transition; patient/viewer cannot advance
return states. Patient's pickup-OTP permission is not return permission. No independent
ready RPC exists. Ops companion reassignment accepts scheduled trips only, including
no special issue-resolution or return-leg reassignment. Companion read projection
masks patient essentials outside its time window; transition writes do not check
that window. Missing readiness does not prove an overrun; event timestamps do not
measure actual companion arrival/waiting. Preserve those boundaries pending review.

Correction to previous cleanup: Ops can read vault data through audited functions
when the patient's owner has active ops_vault_access consent (0400, vault.test.ts).
Ops has no vault-write grant; companions remain denied. Matrix corrected accordingly.

Smallest recommended next implementation: one slice of N5, notify the currently
assigned companion on every authorized cancellation using existing outbox/template.
No new billing/cutoff/reason policy, provider or screen. Acceptance in proposal
section 0 covers Family/Ops allowed cases, all denied actors, no-assignment, rollback,
concurrent/retry behavior, safe en/te/hi content and exact-one notification including
PR #10 integration. A single writer must replace/reconcile its explicit pattern
sender; do not add a duplicate or blindly merge that branch. This is a recommendation,
not code-change/merge/deployment authorization.

Founder business decisions pending: cancellation cutoff; no-show/late-cancel billing;
overrun grace/charges; waiting compensation; consented companion gender/preference
collection; mobility service exclusions. New-owner onboarding, independent-ready
actors, active return reassignment and scheduler/cost need separate scope review.
App consolidation and final id remain a separate pre-store-release decision, not an
operational prerequisite; do not combine them with the notification slice.

Validation: source refs/PR state, scope diff, SQL/helpers and existing test-source
inspection; local document links/whitespace and changed-path checks. No application
or database tests executed: this is source analysis/documentation only. Existing
historical CI results are not a fresh test result. No new browser research, competitor
submission, APK inspection, artifact cleanup, commit, push, deploy or publication.
Prior TASKS edits, design/screenshots and .omx inputs preserved; integration worktree
unchanged. Exact next task: review the proposed notification slice and its acceptance
criteria, then authorize implementation separately; policy-dependent N1-N5 extensions
and consolidation stay pending. Resume from current main, not this old checkout.

## Research cleanup handoff (2026-10-12)

Branch/worktree: `claude/trusting-bell-4fgv07` at `299a9bf`,
`D:/AI-Workspace/Ideas/Anuga`. Latest local task: founder requested cleanup of
Claude's three uncommitted research documents and generated hook artifacts only.
This section supersedes this checkout's old next-task instructions for this task.
Historical deployment/PR status below is stale: current product context is in
`D:/AI-Workspace/Repos/anuga-integration/docs/HANDOFF.md` (`feat/weekly-visit-pattern`).
That handoff records role-based consolidation as a recommendation, not implemented,
and PR #10 scheduling work as unmerged. Do not rebuild its completed work from here.

Completed:
- Read AGENTS, HANDOFF, the three research documents, and all four generated JSON files.
- Corrected the unsupported recurring-dialysis exclusivity claim: Hospy360 advertises
  monthly dialysis support and digniMuv regular bookings. Competitor private-app
  scheduling/backup workflows are unknown; Anuga superiority is not established.
- Distinguished visible forms/public vendor statements from verified service behavior;
  removed unsourced no-show outcome, app-rating and one-hour will-call assertions.
  Narrowed universal intake, reminder, cancellation and user-expectation claims.
- Marked the gap matrix/counts as the old `299a9bf` snapshot; later main/PR #10
  work must be reconciled before planning. Corrected the vault row to exclude Ops.
- Kept N1-N5 as proposed operational priorities, X1 app consolidation as a separate
  pre-store-release workstream, and all business policies/final app id pending.
  Removed implied ops ownership/vault access and unapproved mobility booking blocks.
- Corrected proposed waiting metrics (readiness-to-returning is a response interval,
  not actual waiting) and return reassignment: the existing RPC only accepts scheduled
  trips, so active return reassignment remains unresolved. Readiness actor scope also
  needs review. Preserved database security and existing trip states in the proposal.
- Inspected `.claude-flow`: command-memory logs, neural counters, policy receipts
  and ledger anchors from Ruflo post-command hooks; no substantive research.
  Parsed all four JSON files, checked resolved path/no reparse points and exact count,
  then removed only that folder. Three documents and four internal-reference PNGs retained.

Validation: targeted official-page checks for Hospy360 and Ride Health; migration
0300 reassignment/cancellation checks and vault test-source review; matrix row-count,
Markdown local-link, retained screenshot and whitespace checks. No completed browser
research was repeated, no APK inspected, no competitor forms submitted. digniMuv's
how-it-works page timed out and HosFriend's policy page was inaccessible to the web
tool; original findings remain attributed vendor observations, not freshly verified.
App/database tests were not run: no app code, dependencies, migrations or config changed.
Documents and cleanup remain local/uncommitted by explicit founder instruction;
no commit, push, deploy or publication. Original `.omx/` and design inputs untouched.

Outstanding decisions: cancellation cutoff; no-show/late-cancellation billing;
overrun grace and whether extra time is billed; companion gender collection/consent;
final single mobile app id. Proposed owner onboarding, readiness actors, mobility
service limits, scheduling mechanism/cost and active return reassignment also need
scope/access review. No new policy values approved; numerical examples are test inputs.

Exact next task: founder reviews the cleaned research and resolves required policy
choices. Before any implementation, reconcile the snapshot matrix against current
main and PR #10, then agree one small operational slice. Keep consolidation planning
separate. No implementation, rollout or publication is authorized by this cleanup.

## Historical handoff (before current research cleanup)

Last updated: 2026-10-11 (session 3, Claude Code local Windows, branch `staging-handoff` pushed onto
`claude/trusting-bell-4fgv07` = PR iamnawin/anuga#2). Session 2: 2026-10-09, Claude Code cloud.

## Current state

- Done and verified: **M0**, **M1**, **M1a** (real Supabase), **M2** (`packages/shared_dart`),
  **M3** (ops console, `apps/ops_console`), **M4** (companion app, `apps/companion_app`),
  **M5** (family app, `apps/family_app`), **M6** (notification dispatch, `supabase/functions/notify-dispatch`),
  **M7** (end-to-end journey, `scripts/e2e-journey.sh`), **M8** (vault storage and consent),
  **M9** (payments in test mode). **M10** (production launch) is gated on founder approval.
- Session 2 started from `9f21c73`. The earlier local M3 attempt was never pushed, so M3 was built
  from scratch here; nothing was duplicated.
- Repository: **https://github.com/iamnawin/anuga** (private). Work is on the branch above with a
  draft PR to `main` (not merged).

- Repository: **https://github.com/iamnawin/anuga** (private). M3-M9 were merged to `main` in
  iamnawin/anuga#1 (2026-10-09).
- **Hosted staging (ADR 0004, founder-approved 2026-10-09, synthetic data only):** Supabase project
  `anuga` (`vsvkllfgrnlbhdydysny`, Mumbai) has all nine migrations, the seed (6 trips) and the
  `vault-files` + `payments` functions (with CORS for browsers). Web apps deploy to the Vercel
  project `anuga-staging` (`/ops/`, `/family/`, `/companion/`, preview deploys behind Vercel
  Authentication) via the manual **deploy staging** workflow. The founder's Git-linked Vercel
  project `anuga` auto-deploys the ops console only and is not the staging site.
  Setup and remaining founder steps: `docs/SETUP.md`, "Hosted staging".

## Decisions made

- ADR 0001: build the MVP in parallel with the manual pilot; production launch gated (M10).
- ADR 0002: grants revoked by default; companions use a restricted, time-windowed projection;
  vault reads only through functions that audit in the same transaction; OTP stored as salted hash.
- ADR 0003: PGlite is the default test database; real Supabase (CI job `supabase-local`) is the
  authoritative run.
- M2: `shared_dart` has no Supabase SDK dependency; APIs take an injected `RpcCaller`.
- M3:
  - Ops reads go through ops-only RPCs (migration `0500`) instead of the console joining tables.
    Late threshold (`ops_late_after_minutes`, default 0 = "pickup time passed"), exception lookback
    and maximum board range are `app_settings` rows.
  - `ops_companion_options` lists every companion in the patient's cluster with distance and an
    ineligibility reason; a test proves it agrees with `ops_assign_trip_companion` for every
    companion. The console keeps ineligible companions selectable so the database's own error is shown.
  - Exception actions come from `trip_transitions` (actor `ops`, never `requires_otp`).
  - Console is client-side Next.js with the anon key + user JWT; no service-role key anywhere.
  - Phone OTP on Supabase local: seed `auth.users` rows are now in GoTrue's shape (phone stored
    without `+`, e.g. `919000000001`; `instance_id`, `aud`, non-null token columns and timestamps).
    Test OTP `123456` for the seed numbers only. Supabase Auth refuses phone sign-in without an
    enabled SMS provider, so `config.toml` enables Twilio with fake local placeholders.
  - The ops console uses TypeScript 6 (Next.js needs the TS JS API); root keeps TypeScript 7.
  - `@playwright/test` pinned to 1.56.1 = Chromium build 1194, preinstalled in cloud sessions.
- M4:
  - Companion buttons come from `TripStateMachine` (`lib/src/trip_actions.dart`), never a
    hand-written list; pickup is offered only as OTP verification.
  - Widgets depend on `PhoneAuth` and `CompanionApi`; Postgres errors are mapped to `RpcException`
    in one adapter (`lib/src/supabase_rpc.dart`) so no widget depends on the Supabase SDK.
  - Tests use an in-memory backend that enforces the shared state machine, OTP attempts and
    "not your trip"; a separate test runs the same API layer against Supabase local.
  - Generated localizations (`lib/l10n/generated/`) are not committed; `flutter pub get` creates them.
  - Debug builds allow cleartext only to 10.0.2.2/127.0.0.1/localhost; release stays HTTPS-only.
  - Android application ids are `com.zeroorigins.companion_app` / `com.zeroorigins.family_app`
    (`in.zeroorigins` is invalid: `in` is a Java keyword). Provisional until the brand is final;
    an id cannot change after a Play Store release.
- M5:
  - Family reads go through RPCs (migration `0600`): `family_my_patients` (with access level),
    `family_trip_timeline` (no locations or actor ids), `my_notifications` (push-channel inbox).
  - `AccessLevel.canIssuePickupOtp` / `canChangeTrips` in `shared_dart` mirror the SQL checks and
    only hide buttons; tests show the database refuses the viewer regardless.
  - `RpcException`, `PhoneAuth` and the India helpers moved into `shared_dart`; both apps use them.
    The small Supabase adapters (`supabase_rpc.dart`, `auth.dart`) are duplicated per app on purpose
    (keeps `shared_dart` SDK-free).
  - Neither Flutter app lets new users sign up yet (`shouldCreateUser: false`); family invites are backlog.
- M6:
  - The outbox is drained by an Edge Function with the service role. Claims use a lease
    (`claimed_until`) plus `for update skip locked`; a crashed worker's rows are re-claimed after
    the lease. The database owns retry policy (backoff 60 s doubling; `failed` after 5 attempts).
  - Dispatcher core is runtime-neutral TypeScript (Node tests import it; Deno serves it).
    Root `tsconfig.json` type-checks `supabase/functions/**` except the Deno `index.ts` entries.
  - Live adapters (FCM, WhatsApp, SMS) are not implemented: choosing one stops the function
    with a configuration error, with or without `NOTIFY_LIVE_PROVIDERS_AUTHORIZED=yes`.
  - Messages carry status words only. Companion notes (free text, may mention health) never
    leave the database; the message says "open the app to read the companion's note". Found by
    the M7 journey, which now fails if a note leaks into a delivered message.
- M7:
  - The journey chains the real clients (browser for the ops console; the apps' Dart API layers
    with the same adapters) rather than device UIs, which the cloud session cannot run.
  - It creates its own visit 40 minutes ahead, so the companion's details window is open.
  - Evidence is committed in `docs/evidence/m7/`; CI uploads a fresh `journey` artifact each run.
- M8:
  - No app role touches storage: the `vault` bucket is private with no object policies; the
    `vault-files` Edge Function signs URLs with the service role only after the database
    authorizes the caller (their JWT). Downloads reuse `authorize_vault_read`, so each is audited.
  - Security fix: `vault_documents` no longer accepts direct inserts. Before M8 an editor could
    insert a row whose `storage_path` pointed at another patient's file; paths are now generated
    by `vault_create_document`.
  - Vault writes (documents, vitals, medicines) need the owner's active `vault` consent; the seed
    now includes it. Withdrawal blocks new writes at once; existing data stays until the backlog
    deletion job (needs a retention decision).
  - **Founder review requested (dependencies):** the family app added `image_picker` and `http`
    (official flutter.dev / dart.dev packages; on-device photo picking and the PUT to the signed
    URL; no third-party service receives data). PDF upload and in-app PDF viewing are deferred:
    they need a non-official file picker or viewer package, so they wait for a decision.
  - Supabase signs upload URLs for 2 hours (not configurable); each is for one server-chosen path
    and cannot overwrite.
- M9:
  - Money is integer paise; prices come from `packages`; fares are recorded per trip by ops and
    passed through at cost; a fare on an issued invoice is frozen.
  - Invoices are per patient and India-time calendar month, generated and issued by ops.
    **Assumption to confirm:** only `completed` visits are billed (`billable_trip_statuses`);
    no-show billing is a founder decision.
  - Payment state changes only through the database: `payment_start` (owner) and the
    service-role `payment_captured` (idempotent, amount must match). Provider webhooks are
    authenticated by HMAC body signature (`payments-webhook`, `verify_jwt = false`).
  - The family app pays only in test mode; with a live provider it says checkout is not in this
    build (the Razorpay Checkout SDK receives payment data: founder decision).
  - The M7 journey now also covers billing (fare -> invoice -> bill notification -> owner pays).
- Repo hosting: `iamnawin/anuga` is canonical. `iamnawin/companion` (old remote) is not updated;
  delete or archive only on founder request.

## Completed work (session 2)

- `supabase/migrations/20261008000500_ops_console.sql`, `supabase/tests/ops_console.test.ts`
  (15 tests: allowed/denied for each RPC, anon denial, settings-driven late flag, options/RPC agreement).
- `supabase/config.toml` (`[auth.sms]`), `supabase/seed/seed.sql` (GoTrue-shaped users),
  `supabase/tests/support/supabase_shim.sql` (matching columns).
- `apps/ops_console`: login (phone OTP, ops-role gate), `/trips`, `/schedules`, `/exceptions`;
  en/te/hi strings; Vitest unit + component tests; Playwright e2e; README.
- `pnpm-workspace.yaml` (`apps/*`); root scripts unchanged.
- CI (`.github/workflows/db-tests.yml`): new job `ops-console` (lint, typecheck, test, build);
  `supabase-local` now resets the DB after the SQL tests and runs the Playwright suite, uploading
  screenshots and the report as artifact `ops-console-e2e`.
- Screenshots: `docs/screenshots/m3/`.
- M4: `apps/companion_app` (login, trips list, trip screen, en/te/hi ARB, Android manifest),
  42 Flutter tests, README; CI job `companion-app` (format, analyze, test, debug APK build) and the
  Supabase-local companion journey in `supabase-local`.
- M5: migration `0600_family_app.sql` + `supabase/tests/family_app.test.ts` (9 tests);
  `shared_dart` additions (24 tests); `apps/family_app` (login, patients, bookings, visit screen,
  updates inbox, en/te/hi), 18 Flutter tests, README; CI job `family-app`; family journey in
  `supabase-local`.
- M6: migration `0700_notification_dispatch.sql`; `supabase/functions/notify-dispatch/` (index,
  dispatcher, adapters, messages, REST store, README); tests `dispatcher_unit.test.ts` (13),
  `dispatch.test.ts` (8), `dispatch_function.test.ts` (2, real Supabase only); `asServiceRole`
  test helper; `supabase-local` CI keeps the edge runtime and passes the API keys to the SQL tests.

## Checks run (2026-10-08, cloud session, Node 24.21.0 via nvm, Docker 29.8.2)

| Command | Result |
| --- | --- |
| `pnpm install --frozen-lockfile` | pass |
| `pnpm typecheck` (root) | pass |
| `pnpm db:test` (PGlite) | 75 tests: 72 pass, 0 fail, 3 skipped (real-Supabase-only) |
| `supabase db reset` + `pnpm db:test:supabase` (Supabase local in this session, CLI 2.120.0, Postgres 17) | **75/75 pass, 0 skipped** |
| Mutation: removed the ops guard from `ops_exception_queue` | "family and companions are denied" failed as expected; restored |
| Phone OTP via GoTrue REST | ops number + `123456` signs in; wrong code `otp_expired`; unknown number `Signups not allowed` |
| `apps/ops_console`: `pnpm lint`, `pnpm typecheck`, `pnpm build` | pass |
| `apps/ops_console`: `pnpm test` (Vitest) | 36/36 pass |
| `apps/ops_console`: `pnpm e2e` (Playwright vs Supabase local) | **6/6 pass**: non-ops account rejected; ops OTP sign-in + assign backup (persisted after reload); ineligible companion rejected with DB message; schedule primary/backup validation + swap; companion-reported issue appears in exception queue and ops resolves it; Telugu/Hindi switch |
| GitHub Actions run 37769970593 @ M3 commit (PR iamnawin/anuga#1) | all green: `db-tests`, `shared-dart`, `ops-console`, `supabase-local` (75/75 SQL + Playwright 6/6 on real Supabase) |
| Flutter 3.47.6 / Dart 3.13.5 (Linux archive, this session) | installed |
| `apps/companion_app`: `dart format` check, `flutter analyze --fatal-infos` | clean |
| `apps/companion_app`: `flutter test` | 41 pass, 1 skipped (Supabase-only) |
| Mutation: offer pickup without the OTP | 6 tests failed as expected; restored |
| GitHub Actions run 37771498732 @ `58704f1` (M4) | `companion-app` **failed** at `flutter build apk`: namespace `in.zeroorigins...` is not a valid Java package (`in` is a keyword). Fixed by moving both apps to `com.zeroorigins.*`; all other jobs green (incl. the companion journey on real Supabase) |
| `pnpm db:test` after migration 0600 | 84 tests: 81 pass, 3 skipped |
| `pnpm db:test:supabase` after migration 0600 | 84/84 |
| `packages/shared_dart`: format, `dart analyze --fatal-infos`, `dart test` | clean; 24/24 |
| `apps/family_app`: format, `flutter analyze --fatal-infos`, `flutter test` | clean; 17 pass, 1 skipped (Supabase-only) |
| `apps/companion_app` after the shared_dart refactor | clean; 39 pass, 1 skipped |
| Family journey vs Supabase local (`apps/family_app/test/supabase_local_test.dart`) | pass |
| Companion journey vs Supabase local, re-run after refactor | pass |
| GitHub Actions run 37772851410 @ `ccd05a1` (M5) | **all 6 jobs green**, including both debug APK builds and the companion + family journeys on real Supabase |
| `pnpm db:test` after migration 0700 | 107 tests: 102 pass, 5 skipped (real-Supabase-only) |
| `pnpm db:test:supabase` with the edge runtime and API keys | **107/107** |
| `curl` to the local Edge Function | anon: 403 `forbidden`; service role: `{"claimed":6,"sent":6,"retrying":0,"failed":0}` (seed notifications) |
| GitHub Actions run 37773927485 @ `82c8bb0` (M6) | all 6 jobs green |
| `scripts/e2e-journey.sh` (Supabase local, this session) | **JOURNEY PASSED**; log + screenshots in `docs/evidence/m7/` |
| Same journey against the stale Edge Function (before restart) | failed as intended: "companion notes leaked into outbound messages" |
| `pnpm db:test` / `pnpm db:test:supabase` after the note fix | 103 pass, 5 skipped / 108/108 |
| Companion + family `flutter test` (journey files skip without env) | 39 pass, 3 skipped / 17 pass, 4 skipped |
| GitHub Actions run 37775111000 @ `8c4c59e` (M7) | `companion-app` failed: `dart format` on `journey_test.dart` (edited after formatting). Fixed in `f8e1ad5`; added `scripts/check-all.sh` to run every fast check before a push. All other jobs green, including the M7 journey in CI |
| GitHub Actions run 37776658154 @ `f8e1ad5` (M8 server) | **all 6 jobs green** |
| `scripts/check-all.sh` (M8 final) | all checks passed: PGlite 120 pass / 6 skipped; ops console 36; shared_dart 26; companion 39 + 3 skipped; family 29 + 5 skipped |
| `pnpm db:test:supabase` with the vault bucket and `vault-files` function | **126/126** |
| Family app Supabase-local tests (journey + vault) | 2/2 pass |
| M7 journey after M8 | pass |
| GitHub Actions run 37778744211 @ `38c7265` (M9 server) | **all 6 jobs green** |
| GitHub Actions run 37780635910 @ `8ea7b88` (M9 final) | **all 6 jobs green**, including the journey with billing on real Supabase |
| `scripts/check-all.sh` (M9 final) | all passed: PGlite 140 pass / 8 skipped; ops console 52; shared_dart 27; companion 39 + 3 skipped; family 35 + 6 skipped |
| `pnpm db:test:supabase` (incl. vault and payments functions) | **148/148** |
| Ops console Playwright (standalone) | 7 pass (+4 journey tests skipped outside the journey) |
| `scripts/e2e-journey.sh` with billing | **JOURNEY PASSED**: bill â‚¹550 (visit â‚¹400 + fare â‚¹150), owner notified, paid in test mode, ops sees paid; evidence `docs/evidence/m7/` |
| `flutter test test/supabase_local_test.dart` vs Supabase local | pass: ops assigns backup, viewer denied OTP, owner issues it, wrong then right code, return legs, completion note, 8 ordered family notifications |

## Checks NOT run yet

- Telugu and Hindi strings have not been reviewed by a native speaker.
- Ops console on a hosted Supabase project: none exists (gated, M10).

- Staging (2026-10-09): migrations, seed and security advisors checked through the Supabase
  connector (advisors: only intended findings: deny-all RLS tables, RPCs callable by signed-in
  users, password checks unused with phone OTP). The live functions and web apps could not be
  reached from the cloud session (network policy denies `*.supabase.co`); `deploy staging` runs
  `scripts/staging-smoke.ts` from GitHub instead, once `VERCEL_TOKEN` and `STAGING_TEST_OTP` exist.
- Private storage bucket policies and signed URLs: M8.
- Android SDK cannot be installed in the cloud session (the proxy denies `dl.google.com`):
  `flutter build apk --debug` runs only in CI (`companion-app`, `family-app`). No emulator or
  device run yet.

## Blockers and risks

- PGlite (Postgres 18) and Supabase (Postgres 17) agree today; `supabase-local` in CI is the authority.
- PGlite does not serialize JS arrays for enum-array parameters; tests pass array literals (`{a,b}`).
- Supabase Auth limits OTP requests per number (~5 s locally); the Playwright suite signs in once
  and reuses the saved session.
- `[auth.sms.test_otp]` and the fake Twilio values are local-only. A hosted project needs a real
  SMS provider (founder authorization; paid service) and must not get test OTPs.

## Exact next task

M0-M9 are done. **M10 (production launch) must not start without explicit founder approval.**

1. **Founder review** of PR iamnawin/anuga#1 and these decisions (they block further scope):
   - Bill no-show visits? (`app_settings.billable_trip_statuses`, currently completed only)
   - Approve `image_picker` + `http` in the family app (official packages, on-device)?
   - PDF upload/viewing (needs a non-official file picker/viewer package)?
   - Razorpay: provide **test-mode** keys + webhook registration to exercise the Razorpay adapter;
     approve the Razorpay Checkout SDK in the family app; UPI Autopay for monthly plans?
   - Retention and deletion on consent withdrawal (needed for the deletion job).
   - Native-speaker review of Telugu and Hindi strings (all three apps + notification texts).
2. **Next non-gated work** (backlog, no founder input needed), recommended order:
   - Deletion job for consent withdrawal, once retention is decided (DPDP: as easy to withdraw).
   - Medicine refill reminders (`medicines.refill_on`, outbox notification; no clinical logic).
   - Family invites with roles (owner adds editor/viewer by phone; `patient_access`).
   - Trip data export for pilot metrics (on-time pickups, no-shows; synthetic data in tests).

## Continue in Claude Code cloud

Setup command for the cloud environment:

```sh
. /opt/nvm/nvm.sh && nvm install 24 && corepack enable && pnpm install --frozen-lockfile && pnpm db:test
```

For Supabase local in a cloud session: `nohup dockerd &` (as root), then `docs/SETUP.md` Path B.

## Historical staging context from PR #2 (superseded next task)

- `[auth.sms.test_otp]` and the fake Twilio values are local-only. Staging uses dashboard test
  numbers with a founder-chosen code (ADR 0004); production needs a real SMS provider (paid,
  founder authorization) and no test numbers.
- The Supabase connector times out on statements that drop or delete (it waits for a confirmation
  it cannot show). Such migrations must be run in the staging dashboard SQL editor.

## Session 3 (2026-10-11): founder feedback, duplicate PR, design work next

- **Founder feedback:** "I can't see or test the UI." The only live link is the Git-linked Vercel
  project `anuga` (ops console only); its login is a bare form that cannot sign in until staging
  phone auth is set up (step 0 below). The screens are plain and do not yet follow the founder's
  design sketches. "Not connected" = no hosted link where all three apps talk to one backend yet;
  PR #2 provides exactly that once merged and deployed.
- **Founder design sketches** (made in an image tool) are being copied into `docs/design/`.
  Not in the repo yet. They are the visual baseline for all three apps (see step 1b).
- **Duplicate work, do not use:** a local session built an older, separate M3 on branch
  `m3-ops-console` (PR iamnawin/anuga#3, conflicts with `main`). It started from a stale local
  `main` and never saw PR #1. Recommended: close PR #3 and delete the branch (awaiting founder OK).
  Lesson: always `git fetch` and read `origin/main:docs/HANDOFF.md` before starting.
- Founder answers this session: wants a hosted test link (Vercel preview approved), sketches to
  drive the UI, and parallel agents for the remaining work (plan in `AGENTS.md`, "Parallel work").
- Nothing in code changed this session; only `docs/HANDOFF.md` and `AGENTS.md`.

## Exact next task

M0-M9 are done. **M10 (production launch) must not start without explicit founder approval.**

0. **Finish staging (founder, ~5 min):** phone test numbers + code, `PAYMENTS_WEBHOOK_SECRET`,
   a Vercel token, and the GitHub secrets `VERCEL_TOKEN` + `STAGING_TEST_OTP` (`docs/SETUP.md`).
   Then run **deploy staging** and confirm the smoke test passes.
1a. **Merge PR iamnawin/anuga#2** (green, mergeable; `workflow_dispatch` only appears from `main`),
   then Actions -> **deploy staging** -> Run. Share the preview URL from the run summary with the founder.
1b. **UI to match the founder's sketches** (`docs/design/`), one branch per app, in parallel
   (`AGENTS.md`, "Parallel work"): shared design tokens first (colours, type scale, 48 px+ targets,
   high contrast, en/te/hi), then ops console, companion app, family app. UI-only: no change to
   RPCs, auth or access rules. Compare each screen with its sketch and list intentional differences.
1. **Founder review** of PR iamnawin/anuga#1 and these decisions (they block further scope):
   - Bill no-show visits? (`app_settings.billable_trip_statuses`, currently completed only)
   - Approve `image_picker` + `http` in the family app (official packages, on-device)?
   - PDF upload/viewing (needs a non-official file picker/viewer package)?
   - Razorpay: provide **test-mode** keys + webhook registration to exercise the Razorpay adapter;
     approve the Razorpay Checkout SDK in the family app; UPI Autopay for monthly plans?
   - Retention and deletion on consent withdrawal (needed for the deletion job).
   - Native-speaker review of Telugu and Hindi strings (all three apps + notification texts).
2. **Next non-gated work** (backlog, no founder input needed), recommended order:
   - Deletion job for consent withdrawal, once retention is decided (DPDP: as easy to withdraw).
   - Medicine refill reminders (`medicines.refill_on`, outbox notification; no clinical logic).
   - Family invites with roles (owner adds editor/viewer by phone; `patient_access`).
   - Trip data export for pilot metrics (on-time pickups, no-shows; synthetic data in tests).

## Continue in Claude Code cloud

Setup command for the cloud environment:

```sh
. /opt/nvm/nvm.sh && nvm install 24 && corepack enable && pnpm install --frozen-lockfile && pnpm db:test
```

For Supabase local in a cloud session: `nohup dockerd &` (as root), then `docs/SETUP.md` Path B.

## S3 UI delivery (2026-10-11)

Branch ui/s3-ops-console, main plus S2 PR #4 commits; no staging code. Six presentation files changed: globals.css, OpsShell, login/layout, trips and billing. Mint sidebar, ANUGA branding, teal controls, navy hierarchy, accessible scroll regions and dark/narrow layouts. Existing handlers/providers/RPC/roles/payment data flow and tests preserved. Schedules/exceptions inherit the shared styling.

Full scripts/check-all.sh exit 0; install/root typecheck, ops lint/typecheck/build, all Dart format/analyze pass. PGlite 140 pass/8 skips, ops 52, shared Dart 27, companion 39/3 skips, family 35/6 skips. Separate ops lint/typecheck/test pass52. Whitespace clean and independent UI behavior review found no remaining S3 issue. Local real Next app + browser-intercepted synthetic fixtures captured23 screenshots: zero page errors/page-wide overflow/sub48-high controls at1440/360/430, dark, te/hi and200% text. Evidence/mappings/differences/startup instructions: docs/evidence/s3-ui/README.md. Logs: artifacts/s3/check-all-final.log and ops-*.log.

Not run: real-Supabase journey/permissions (Docker absent), hosted staging/native-language review. In-app browser tooling failed bootstrap; repository Playwright/Edge used. PR status: ready for separate UI PR, no merge/deploy. Exact next task: finish S4/S5 checks and review, open their separate PRs, then founder tests with synthetic backend; staging requires PR #2 plus dashboard steps.


## S4 UI delivery (2026-10-11)

Branch ui/s4-companion, main plus S2 PR #4 commits. Seven authorized files: theme, three screens and en/te/hi ARB titles. Teal ANUGA/mint/navy presentation, route essentials/status panels and scrollable dialogs. All callbacks, keys, OTP/state-machine actions, time-window projection and tests retained. Distinct terminal glyphs preserve meaning; localized titles verified as Unicode.

Final scripts/check-all.sh exit0, all install/typecheck/lint/build/format/analyze phases pass. PGlite140/8skips,ops52,shared27,companion39/3skips,family35/6skips. Separate companion analyze clean,tests39/3. Five widget-render matrix tests pass,165 captures generated;38 curated screenshots/mappings/differences and founder commands in docs/evidence/s4-ui/README.md. Diff whitespace clean. Independent review's text-color finding fixed and validated in light/dark renders. Logs artifacts/s4/check-all.log,analyze.log,flutter-test.log,screenshots.log.

Not run: device/emulator,real-Supabase journey (Docker absent),hosted staging,native-language review. Evidence uses real Flutter widgets with synthetic fake APIs and font substitution in ignored harness only; not real auth/security/device validation. PR status: separate S4 PR prepared, no merge/deploy. S3 open at https://github.com/iamnawin/anuga/pull/5. Exact next task: finish S5 review/checks and PR, then founder review and local synthetic device testing; staging separately gated on PR #2 dashboard steps.


## S5 UI delivery (2026-10-11)

Branch ui/s5-family, main plus S2 PR #4 commits. Fourteen authorized files: theme,nine existing screens,one reused presentation helper and three ARB titles. Teal ANUGA/mint/navy home/visits/records/privacy/bills/inbox. All callbacks,keys,API,role gates,payment/upload adapters and tests retained. No separate patient mode or concept-only capability. Header/picker bounded scroll, long dropdown rows wrap, scaled navigation can scroll; large system text remains uncapped.

Final scripts/check-all.sh exit0; all install/typecheck/lint/build/format/analyze pass. PGlite140/8skips,ops52,shared27,companion39/3skips,family35/6skips. Separate family analyze clean/tests35/6. Seven widget scenarios pass with missed taps fatal;114 PNGs generated,25 curated. At360x640/3x long-name/two-patient test opens picker,switches patient,and reaches inbox. Evidence/mapping/differences/test commands: docs/evidence/s5-ui/README.md. Diff whitespace clean and independent focused source review passed. Logs artifacts/s5-check-all.log,s5-analyze.log,s5-tests.log,s5-visual.log.

Not run: device/emulator,real-Supabase journey/permissions (Docker absent),hosted staging,native-language review. Evidence is real-widget/synthetic API rendering with harness-only readable fonts and synthetic report fixture; no auth/security/device claim. PR status: separate S5 PR prepared,no merge/deploy. S2 open PR #4,S3 PR #5,S4 PR #6. Exact next task: open S5 PR,record all PR links,then founder review/test existing flows with synthetic backend; staging requires PR #2 and dashboard steps.


Local integration browser receipt: repository Playwright/Edge opened all three real release builds, enabled Flutter semantics and entered each synthetic phone. Three HTTP 200, zero page errors or failed requests, all input values confirmed. No login submitted because Phone is disabled. Proof: docs/evidence/integration. Full logs in ignored artifacts/integration. Historical docs were reconciled using UTF-8 source snapshots and normalized to LF after Windows shell encoding changed historical punctuation. No product code changed in this correction; diff whitespace check rerun. Next: open integration PR, inspect CI, founder configures synthetic phone auth and completes LOCAL_TESTING walkthrough.
