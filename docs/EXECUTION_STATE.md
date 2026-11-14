# AnugaCare execution state

2026-11-14 11:07:49 IST - WELCOME-HERO-20261113 DELIVERED: PR #43 https://github.com/iamnawin/anuga/pull/43 OPEN/unmerged, implementation8a13349825b89b08aa590b128d677efadb2649c3. All required local checks passed and24 release screenshots/12configs captured with zerohostedcalls. This later delivery receipt is documentation only. No main merge/deployment/other component integration; STOP for founder visual review.


2026-11-14 10:56:30 IST - WELCOME-HERO-20261113 on isolated feat/welcome-hero-arch from29a8356. Hero-only edit implemented: separate transparent arch asset, original preserved; theme-aware side/lower alpha, natural foreground, no rectangularclip/crop, solidbackgroundbeforeheadline. Logo/copy/controls/navigation unchanged. Focused40/fullunified93/analyze/releasebuild PASS;12 browserconfigs360/390 light/dark EN/TE/HI,24screenshots,language/actions PASS,hostedcalls0. Required sequential check-all PASS (DB209/11skip, Ops70/build, shared29, Companion58/3skip, Family109/6skip, unified93); final diff/visual review clear. Commit/push own PR, then STOP for visual review. No merge or hosted deployment; other components untouched.


2026-11-13 20:31:07 IST - ROOT-ENTRY-20261113: founder explicitly requests main URL Welcome instead of chooser. Own fix/welcome-root-entry from e8e0063 changes only root routing/fallback in scripts/build-staging.sh; six tracking files/evidence record it. Local syntax/config/order/no-loop checks PASS and existing application bundles byte-identical. Live redeploy/test pending. No other agent component merge authorized; #40 remains unmerged, other worktrees untouched. Signed-in session behavior and production gates unchanged. Next: publish and verify own root fix.


### Agent Session - 2026-11-13 19:46:19 IST - FAMILY-V2 group1-CI-tab-semantics

**Agent:** Codex; Family/Patient UI implementation and verification.
**Task ID / Name:** FAMILY-V2 / group1-CI-tab-semantics.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-family-screens-v2`.
**Branch:** `feat/family-screens-v2`.
**Starting commit:** b834b53fbc19952e86161d3bdb049354dfb78291.
**Current commit:** 35a20fc83656489e0468f81946f5027517661dfe; this checkpoint is included in the next task commit.
**PR:** Draft only; see evidence README for current link.
**Scope:** Approved six-group Family screen specification; no Companion/auth/backend changes.
**Completed work / Files changed:** Replacement CI43438812876: sixSUCCESS, supabase-localFAILED on rolebutton Visits selector. Corrected both existing browser journeys to role tab for Visits/More, with4 passing unified semantic-role assertions. Production widgets unchanged. Repeated scripts/check-all.sh ALL CHECKS PASSED (Family109/6skip, unified91). No weakened backend assertions or new skips. Next: replacement CI on this fix, thenGroup2.
**Tests and actual results / CI evidence:** See group ledger in docs/evidence/family-screens-v2/README.md; no unrecorded pass implied.
**Merge status:** Not merged.
**Deployment and migration status:** Not deployed; no migrations or hosted mutations.
**Decisions and assumptions:** Approved url_launcher ^6.3.3 for dialer only. Deferred contracts explicitly listed in evidence.
**Blockers:** Support number, profile/routine/address/latest-history/notification lookup/overdue/upload-limit/legal contracts deferred.
**Uncommitted changes:** Intended group changes before task commit; other worktrees preserved.
**Exact next action:** Complete current group checks/docs/push, verify CI, continue next approved group.
**Next responsible agent:** Codex.

**BACKEND FOLLOW-UP (not implemented here):** Make family_invoices and family_invoice_lines owner-only reads. Add allowed owner and denied editor/viewer/patient database tests, including direct RPC access. Existing SQL still permits editor reads; UI hiding does not change that boundary.


### Agent Session - 2026-11-13 19:31:13 IST - FAMILY-V2 group1-CI-navigation-fix

**Agent:** Codex; Family/Patient UI implementation and verification.
**Task ID / Name:** FAMILY-V2 / group1-CI-navigation-fix.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-family-screens-v2`.
**Branch:** `feat/family-screens-v2`.
**Starting commit:** b834b53fbc19952e86161d3bdb049354dfb78291.
**Current commit:** 5283415bac05ddac8ae5faf001ba46ef2b4efbce; this checkpoint is included in the next task commit.
**PR:** Draft only; see evidence README for current link.
**Scope:** Approved six-group Family screen specification; no Companion/auth/backend changes.
**Completed work / Files changed:** Group1 source5283415 pushed to draftPR37 byiamnawin. CI43437185702: sixSUCCESS, supabase-localFAILED on obsolete Request care landing selector. Adapted only two existing Ops browser-test files for Home->Visits after sign-in/reload and More confirmed signout; retained backend assertions. Playwright discovery2 PASS (not execution), Docker unavailable locally. Repeated scripts/check-all.sh ALL CHECKS PASSED: Family109/6skip, unified91 and unchanged broad counts. Replacement CI pending; do not startGroup2 until corrected.
**Tests and actual results / CI evidence:** See group ledger in docs/evidence/family-screens-v2/README.md; no unrecorded pass implied.
**Merge status:** Not merged.
**Deployment and migration status:** Not deployed; no migrations or hosted mutations.
**Decisions and assumptions:** Approved url_launcher ^6.3.3 for dialer only. Deferred contracts explicitly listed in evidence.
**Blockers:** Support number, profile/routine/address/latest-history/notification lookup/overdue/upload-limit/legal contracts deferred.
**Uncommitted changes:** Intended group changes before task commit; other worktrees preserved.
**Exact next action:** Complete current group checks/docs/push, verify CI, continue next approved group.
**Next responsible agent:** Codex.

**BACKEND FOLLOW-UP (not implemented here):** Make family_invoices and family_invoice_lines owner-only reads. Add allowed owner and denied editor/viewer/patient database tests, including direct RPC access. Existing SQL still permits editor reads; UI hiding does not change that boundary.


### Agent Session - 2026-11-13 19:20:13 IST - FAMILY-V2 group1

**Agent:** Codex; Family/Patient UI implementation and verification.
**Task ID / Name:** FAMILY-V2 / group1.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-family-screens-v2`.
**Branch:** `feat/family-screens-v2`.
**Starting commit:** b834b53fbc19952e86161d3bdb049354dfb78291.
**Current commit:** b834b53fbc19952e86161d3bdb049354dfb78291; this checkpoint is included in the next task commit.
**PR:** Draft only; see evidence README for current link.
**Scope:** Approved six-group Family screen specification; no Companion/auth/backend changes.
**Completed work / Files changed:** F12/F13/F34/F35 and access-specific shell built. Added15 Home regressions and4 unified access/session tests, existing navigation expectations adapted. Final scripts/check-all.sh PASS: DB209/11skip, Ops70, shared29, Companion58/3skip, Family109/6skip, unified91; analyzers/format PASS. Nine actual renders; reviewer findings fixed. Source changes confined to Family UI/l10n and app tests; no app.dart/auth/adapter/Companion source edits.
**Tests and actual results / CI evidence:** See group ledger in docs/evidence/family-screens-v2/README.md; no unrecorded pass implied.
**Merge status:** Not merged.
**Deployment and migration status:** Not deployed; no migrations or hosted mutations.
**Decisions and assumptions:** Approved url_launcher ^6.3.3 for dialer only. Deferred contracts explicitly listed in evidence.
**Blockers:** Support number, profile/routine/address/latest-history/notification lookup/overdue/upload-limit/legal contracts deferred.
**Uncommitted changes:** Intended group changes before task commit; other worktrees preserved.
**Exact next action:** Complete current group checks/docs/push, verify CI, continue next approved group.
**Next responsible agent:** Codex.

**BACKEND FOLLOW-UP (not implemented here):** Make family_invoices and family_invoice_lines owner-only reads. Add allowed owner and denied editor/viewer/patient database tests, including direct RPC access. Existing SQL still permits editor reads; UI hiding does not change that boundary.


### Agent Session - 2026-11-13 19:05:48 IST - FAMILY-V2 startup

**Agent:** Codex; Family/Patient UI implementation and verification.
**Task ID / Name:** FAMILY-V2 / startup.
**Repository / Worktree:** `D:\AI-Workspace\Repos\anuga-family-screens-v2`.
**Branch:** `feat/family-screens-v2`.
**Starting commit:** b834b53fbc19952e86161d3bdb049354dfb78291.
**Current commit:** b834b53fbc19952e86161d3bdb049354dfb78291; this checkpoint is included in the next task commit.
**PR:** Draft only; see evidence README for current link.
**Scope:** Approved six-group Family screen specification; no Companion/auth/backend changes.
**Completed work / Files changed:** Isolated main-based branch created. Baseline flutter test: Family 94 passed/6 existing skips; unified 87 passed. Dependency resolution passed. Specification and four boards inspected; existing adapters retained.
**Tests and actual results / CI evidence:** See group ledger in docs/evidence/family-screens-v2/README.md; no unrecorded pass implied.
**Merge status:** Not merged.
**Deployment and migration status:** Not deployed; no migrations or hosted mutations.
**Decisions and assumptions:** Approved url_launcher ^6.3.3 for dialer only. Deferred contracts explicitly listed in evidence.
**Blockers:** Support number, profile/routine/address/latest-history/notification lookup/overdue/upload-limit/legal contracts deferred.
**Uncommitted changes:** Intended group changes before task commit; other worktrees preserved.
**Exact next action:** Complete current group checks/docs/push, verify CI, continue next approved group.
**Next responsible agent:** Codex.

**BACKEND FOLLOW-UP (not implemented here):** Make family_invoices and family_invoice_lines owner-only reads. Add allowed owner and denied editor/viewer/patient database tests, including direct RPC access. Existing SQL still permits editor reads; UI hiding does not change that boundary.


MERGED TO MAIN — 2026-11-13 14:09:07 IST: founder authorized current UI stack;
#29→#32→#33→#34 all merged, main source d22dc2738d4ff962d22d0eb776213f812a8c9b85.
Exact tree equals tested1cac74a, all seven source checks per PR passed. Original
heads/branches/worktrees intact. #28/#30/#31 remain open/separate. Main automatic
CI43394513880 observed running, not yet a pass. Markdown-only receipt follows.
No deploy/migration/hosted mutation; physical/native and production NO-GO gates
unchanged. Finish receipt merge, report state and STOP; no next feature/deploy.


DELIVERED FOR REVIEW — 2026-11-13 13:49:48 IST: Consent #33/b5e9142 (CI7 SUCCESS),
Welcome #34/b464716 (DB/shared/Ops SUCCESS, four jobs running in43392256735).
Both OPEN/unmerged, dependency #32→#33→#34; #32 preserved. Documentation-only
receipt follows source; current #34 checks authoritative. Code/tests/build/
comparisons published, same-Wi-Fi preview HTTP200. STOP for founder review at
http://192.168.31.252:3114/app/; sign out for Welcome, Family privacy for Consent.
No production gate closed, no merge/deploy/hosted mutation or further task.


Final local checkpoint 2026-11-13 13:44:37 IST: both requested screens implemented
and locally verified, Consent FIRST in #33/b5e9142 (all7CI SUCCESS), Welcome now
ready for separate commit/PR on feat/welcome-review. Unified87/Family94 tests,
analyzers and recovered release build PASS. Final Welcome9 browser configs and
comparisons inspected; all hosted calls blocked. No incomplete screenshot step.
Earlier Windows OOM/thread failures retained in evidence; sequential tests and
Nov13 build recovered without code weakening. Server PID14468, port3114 ready.
Next: push Welcome PR receipt, STOP for Pixel/native review. No merge/deploy.


Recovery checkpoint 2026-11-13 13:36:41 IST: resumed original two-screen task on
feat/welcome-review, uncommitted Welcome changes preserved. Consent #33/b5e9142
is pushed, OPEN/unmerged; no Welcome PR yet. Prior exact code tests: unified87
PASS, Family94/6 skip PASS sequentially; final analyzer PASS. Broad recheck had
Windows Dart OOM at Family stage; sequential runs recovered every case. Nov12
final release recapture build failed creating DartWorker under low host memory.
Nov13 host has more free memory; rerunning only interrupted release build with
--no-wasm-dry-run, no app/workflow/dependency changes. Next: recapture final
Welcome, compare, update handoff, commit/push separate PR and STOP for Pixel.


Welcome working checkpoint 2026-11-12 20:04:06 IST: implementation is local on
feat/welcome-review from b5e9142/#33. Root pushes existing phone login with route
guard, both CTAs share handler, valid sessions unchanged. Unified87 tests PASS,
analyzer PASS. Initial build/analyze process sessions interrupted by tool reset;
analyzer completed on retry, release build retry in progress. Screenshots/final
PR/handoff pending; do not report Welcome pushed or merged. #33 CI now all seven
SUCCESS. Next: build, capture/compare both themes/widths/locales/large text, finish
checks and separate Welcome PR, then Pixel review. No hosted mutations/deploy.


2026-11-12 19:43:23 IST: Consent complete locally and pushed b5e9142 to #33 OPEN,
base #32. Welcome now starts on separate feat/welcome-review from that exact
checkpoint, same owned worktree. #33 remains unchanged for independent review.
Full Consent evidence recorded below; no source PR merge/deploy/hosted mutation.


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
