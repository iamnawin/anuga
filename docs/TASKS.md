# Tasks and milestones

### Agent Session - 2026-11-14 17:34:34 IST - UI publication reconciliation checkpoint

**Agent:** Codex, integration and deployment investigation.
**Task ID / Name:** UI-PUBLICATION-20261114.
**Repository / Worktree:** D:/AI-Workspace/Repos/anuga-ui-publication.
**Branch:** fix/ui-publication-2026-11-14.
**Starting commit:** 29a8356ea6c68e01afca962035fefaf6a68d70a3.
**Current commit:** Checkpoint commit identified by Git; integration in progress.
**PR:** Pending integration PR; source PR36 draft/unmerged and PR43 open/unmerged.
**Scope:** Founder requests investigation and correction of missing published Companion and Welcome UI.
**Completed work:** Verified live dpl_Hh646SE3ibGmxdFQe23oYjBsYjuC remains Nov13; Git deployment disabled; Companion36 not merged, Welcome43 not merged. New Companion lives in unified /app/, legacy /companion/ unchanged. Reconciled only six documentation conflicts, preserving both histories; product sources auto-merge.
**Files changed:** Source36 plus additive mandatory tracking.
**Tests and actual results:** Investigation only; integrated checks pending. PR43 latest Supabase failure is obsolete companionTile selector, not merely historical Docker collision.
**CI evidence:** PR43 run43562467546 latest failure at issue_handling.spec.ts154; six jobs pass. No integration CI yet.
**Merge status:** Local integration only; no main merge.
**Deployment and migration status:** Not deployed; no DB changes.
**Decisions and assumptions:** Current founder request authorizes preparing combined synthetic publication; preserve other worktrees and unrelated branches.
**Blockers:** Need update browser journey for actual Companion UI and verify integrated checks.
**Uncommitted changes:** Integration before this checkpoint commit.
**Exact next action:** Incorporate Welcome43, update actual journey selectors/interactions without weakening backend checks, full validation and combined preview.
**Next responsible agent:** Codex.

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

COMP-V2 DELIVERED FOR REVIEW (2026-11-13 15:34:45 IST):
[Draft PR36](https://github.com/iamnawin/anuga/pull/36), tested source
`6aea386c9061a604297b05ca7db4a44e1ab9f6de`, base main. C3-C18 supported portions
implemented/tested; C1/C2/C19/C20 and missing-contract portions deferred. Full
check-all PASS; final unified146/analyze/release-web PASS. Source CI seven jobs
observed running, Supabase Preview skipped; no CI pass inferred. Not merged or
deployed; no hosted mutation/migration, real data or production gate closure.
Physical/native-language acceptance pending. See latest HANDOFF and
[receipt](evidence/companion-screens-v2/README.md). Next: founder draft review.


COMP-V2 delivery checkpoint 2026-11-13 15:32:34 IST: foundation committed as
`beddacb2b9a2b609cc35d70a768bfd60233232ff` after planning `2d619e2`.
Final source unified146 tests/analyze PASS; release web rebuild PASS (exit0,
50.1s; existing font warning). Journey source/tests and 21 synthetic PNGs are
being committed next. Draft PR/push pending; no merge/deploy/hosted mutations.


COMP-V2 (2026-11-13 15:31:56 IST): Supported C3-C18 IMPLEMENTED/locally TESTED in
`feat/companion-screens-v2`; C1/C2/C19/C20 and documented missing-contract
portions DEFERRED. Full check-all PASS; final unified146/analyze PASS. Privacy,
EN/TE/HI dark/light/200% and native-handoff-URI checks included; human device/
language acceptance NOT performed. Draft PR pending; no merge/deploy/migration.
Exact commands, screen/reference map and gaps: [receipt](evidence/companion-screens-v2/README.md).
Historical UX/release weights and launch gates are unchanged.


COMP-V2 checkpoint (2026-11-13 15:16 IST): Codex owns isolated
`feat/companion-screens-v2` from main `b834b53` for founder-requested unified
Companion screens. Supported UI in progress; C1/C2/C19/C20 and missing-contract
portions deferred. Plan, reference mapping and actual checks:
[COMP-V2 receipt](evidence/companion-screens-v2/README.md). Draft PR only; no merge,
deploy, hosted migration or production gate closure. Historical entries preserved.


## Authorized source merge — 2026-11-13 14:09:07 IST

- [x] All current UI changes pushed; latest #29/#32/#33/#34 heads had seven CI
      successes each. Final independent review clear; no job reruns/admin bypass.
- [x] Merged #29 baseline, #32 login, #33 Consent, #34 Welcome into main in order.
- [x] Main d22dc27 file tree exactly equals tested Welcome1cac74a tree.
- [x] Preserved original branches/worktrees and unrelated open #28/#30/#31.
- [x] Updated merge receipt/state; no deployment, hosted changes or migrations.
- [ ] Newly triggered main CI final result (run43394513880 observed running).
- [ ] Physical Pixel/native-language and remaining production-release acceptance.
- Source merge is approved/completed; earlier unmerged stop notes below are
  historical. No production gate promotion or automatic deployment authorization.


## Delivered — 2026-11-13 13:49:48 IST

- [x] Consent separately committed/pushed b5e9142, [PR #33](https://github.com/iamnawin/anuga/pull/33), CI7 SUCCESS.
- [x] Welcome separately committed/pushed b464716, [PR #34](https://github.com/iamnawin/anuga/pull/34), source CI3 SUCCESS/4 IN_PROGRESS.
- [x] Mandatory handoff, actual images/comparisons/test evidence and Pixel plan
      published. Same Wi-Fi preview http://192.168.31.252:3114/app/ HTTP200.
- [ ] Founder Pixel/native-language acceptance; latest Welcome CI final result.
- No merge/deploy/production approval. STOP for review; prior checklists below
  are dated checkpoints, not missing new implementations.


## Two-screen delivery checkpoint — 2026-11-13 13:44:37 IST

- [x] Consent built/verified FIRST, b5e9142 pushed to #33; seven-job CI SUCCESS.
- [x] Welcome implemented separately on feat/welcome-review; valid sessions bypass
      entry, both actions use existing phone/OTP/database-role path.
- [x] Supplied clean artwork asset; Flutter text/controls/three languages; original
      images retained in docs/design/screens-01-04; exact image hashes match.
- [x] Unified87, Family94/6 skip, analyzers/format/release build PASS; broad fast
      suite's Family OOM recovered by complete sequential runs, no timeouts relaxed.
- [x] Each screen has nine actual browser render configs and24 layout test cases;
      360/390, both themes, en/te/hi and2× text; comparison sheets recaptured.
- [x] Missing approved Privacy Policy URL and standing support scope reported.
- [ ] Welcome commit/push/separate PR (next), then founder Pixel/native approval.
- Preview: http://192.168.31.252:3114/app/. Sign out for Welcome; Family Privacy
  and consent for04. No merge/deploy/hosted changes or release gate promotion.


2026-11-12 19:43:23 IST: Consent committed/pushed b5e9142, PR #33 OPEN based
on #32. Welcome now IN_PROGRESS on separate feat/welcome-review based on #33.
Earlier pending-commit checklist below is preserved as historical checkpoint.


## Screens 04 Consent then 01 Welcome — 2026-11-12 19:40:46 IST

- [x] PR #32 baseline ca22a5d checked, OPEN, CI43211837626 seven SUCCESS.
- [x] Isolated feat/consent-review worktree, all three supplied images in docs/design.
- [x] Consent server values/per-row permissions, explicit diff-only Save, standing
      support hierarchy, conditional new grant/withdrawal and partial-error recovery.
- [x] Family94/6 skip, unified49, full fast suite/analyzers/build and DB6 allowed/
      denied checks PASS; 24 layout cases, nine browser capture configs verified.
- [x] Gaps reported: no approved Privacy Policy destination; no per-request support
      permission; parent vault Off does not implicitly revoke existing support.
- [ ] Consent commit/push/new PR before Welcome implementation.
- [ ] Welcome signed-out entry, supplied illustration, same phone route for both
      actions, existing sessions/OTP/locale/role contracts preserved and verified.
- [ ] Welcome screenshots/comparisons, final handoff and same-Wi-Fi Pixel review.
- Evidence and gates: `screenshots/consent-welcome/README.md`. No merge/deploy.


## LOGIN-001 Pixel follow-up (2026-11-12 17:11:22 IST)

- [x] Correction e5a5b95 pushed to #32; CI 43211668116 IN_PROGRESS at 17:14:24 IST.
      Later evidence-only receipt normalizes JSON line endings; no app change.

- [x] Reproduced founder dark-mode logo block; original PNG itself transparent.
- [x] Removed backing, reduced/centered lockup with gaps; dark wordmark readable.
- [x] Selector row/card right edge and 48px target verified; field/button aligned;
      short hints in en/te/hi, visible Mobile number label retained.
- [x] Final unified 49 tests, analyze, release web build, scoped format/diff PASS.
- [x] Running phone/OTP/menu at 360/390 light/dark captured and visually checked;
      comparison includes labelled old-build reproduction, not the actual Pixel file.
- [x] Prior baseline CI 43208909014/20206f4 SUCCESS, all seven; no manual reruns.
- [ ] New correction commit's automatic PR checks (PR #32 rollup).
- [ ] Founder Pixel retest of both normal/light and dark modes; approval pending.
- Evidence: `screenshots/login-review/README.md` Pixel follow-up; same Wi-Fi URL
  http://192.168.31.252:3113/app/. STOP at login; no other feature or gate promotion.


## LOGIN-001 — isolated unified phone/OTP rebuild (2026-11-12)

- [x] Implementation 30b49bb pushed to [PR #32](https://github.com/iamnawin/anuga/pull/32),
      stacked on #29; source CI 43208610616 IN_PROGRESS at 16:53:06 IST.
      Latest PR check rollup remains authoritative; no pass/merge/deploy inferred.

- [x] Compared origin/main with PR #29; separate `feat/unified-login-review`
      worktree based on #29 `d75cf07`. PR #28/#29/#30 preserved.
- [x] Founder reference and approved original logo provenance recorded in
      `screenshots/login-review/README.md`; historical board 1 panels 02–03 retained.
- [x] Phone/OTP presentation, exact-key language preference and keyboard Verify
      footer implemented. Auth handlers, validation, role/RPC/RLS contracts reused.
- [x] Full fast check-all suite passed (DB 209 pass/11 skip, Ops 70, shared 29,
      Companion 58/3 skip, Family 58/6 skip, unified 43). Extra pending-verify
      regression subsequently passed: unified 44 total.
- [x] EN/TE/HI 360px real-font captures and explicit TE/HI selection→reload checks.
- [x] Final comparison/overlay, hosted verification receipt and independent review.
      Unified final count 45, including scrolled phone→OTP regression.
- [ ] Founder phone/keyboard, logo/layout and native-language approval.
- Login review only. No merge/deploy/migrations or readiness gate promotion.
- Evidence/manual phone plan: `screenshots/login-review/README.md`. Current source
  CI pending creation; E2E discovery is not journey execution. Review URL
  http://192.168.31.252:3113/app/ (phone access/IME not yet tested).


## Complete UI/UX Modernization Workstream — Gemini CLI (2026-11-09) `[~]` (PR #29 7/7 CI green at `c4ced74`/`631ac5d` & Vercel Preview `dpl_6673mDsp1iZULg4uPa4SD8HPz2kC` READY; product decisions `DEC-01`/`DEC-02`/`DEC-05`, human `QA-002` & staging `REL-002` remain open)

Authoritative audit register: `docs/UX_AUDIT.md`. Phased execution tracker: `docs/UX_IMPLEMENTATION_PLAN.md`.
Isolated branch: `feat/anugacare-ui-modernization` in `D:\AI-Workspace\Ideas\Anuga` (branched from `origin/main` `ea6d142`, **PR #29** `https://github.com/iamnawin/anuga/pull/29`).
Vercel Preview (team sign-in, non-prod): `https://anuga-ptkyex1az-iamnawins-projects.vercel.app` (`dpl_6673mDsp1iZULg4uPa4SD8HPz2kC`, built from `631ac5d` / code `c4ced74`).
Concurrent Codex stream: PR #28 (`feat/g7-ui-staging` in `D:\AI-Workspace\Repos\anuga-trips-fix`).

- [x] `WP-0`: Permanent Multi-Agent Handoff Policy in `AGENTS.md`, permanent UX audit register (`docs/UX_AUDIT.md` covering `UX-01`–`UX-08`, 5 product recommendations, and open founder decisions), implementation plan (`docs/UX_IMPLEMENTATION_PLAN.md`), and cross-agent handoff updates (`71fb555`).
- [x] `WP-1`: Shared visual system & reusable components (`care_ui.dart`, `CareEmergencyBanner`, 9-stage `_VisitProgressStrip` compatible with PR #28).
- [~] `WP-2`: Entry/authentication (`anugacare_app`) and Family experience modernization (`UX-01` & `UX-02` `Tested`; `UX-03` inline OTP card `Tested`, server re-read requires `DEC-01`; `UX-05` summary card `Tested`, native picker requires E2E selector update).
- [~] `WP-3`: Patient-access priority experience and Companion experience modernization (`UX-02` `Tested`; `UX-04` visual separation `Tested`, time-gating `no_show` & intermediate step confirmations require `DEC-02`; `UX-08` emergency banner & 9-stage progress strip `Tested`, `tel:` launcher requires `url_launcher` approval).
- [~] `WP-4`: Ops Console modernization across `globals.css` and `exceptions/page.tsx` (`UX-07` visual hierarchy & 0 lint warnings `Tested`; auto-confirmation on companion assignment requires `DEC-05`).
- [~] `WP-5`: Localization (`EN` / `TE` / `HI` terminology cleanup for `UX-06` in `app_te.arb` & `app_hi.arb` `Tested`; English `Ops` strings retained for existing test contracts; flagged for human review `QA-002`), responsive mobile/tablet layouts, and 200% text-scaling accessibility.
- [x] `WP-6`: Full regression verification (`pnpm db:test` 209/209, `ops_console` 70/70, `shared_dart` 29/29, `family_app` 58/58, `companion_app` 58/58, `anugacare_app` 39/39) and **PR #29** (`c4ced74`) passing all 7 GitHub Actions CI jobs in run `42625907826` (`db-tests`, `shared-dart`, `ops-console`, `companion-app`, `family-app`, `anugacare-app`, `supabase-local`).

## Autonomous integration, UI and synthetic staging mission (2026-11-06 / 2026-11-07) `[~]`

Authoritative atomic task status and fixed weights live in
`docs/PROGRESS_LEDGER.md`; resume instructions live in `docs/RECOVERY.md`.

- [x] `STATE-001`: durable execution/recovery records pushed at `7a06f1b`;
      corrected full local Unlazy gate passes.
- [x] `INT-001`: reconcile main, worktrees, PRs #21-#27, CI and migrations.
- [x] `INT-002`: integrate the implemented/green #22-#27 stack into main in
      dependency order (`a8109ae`, `5b838b6`, `8d175b4`, `038fb67`, `88b0c0b`, `ea6d142`).
- [x] `UI-001`: reconcile the three new reference boards with approved tokens and
      supported functionality; 17 PR #28 screenshots retained from CI `42342439646`.
- [~] `UI-002` / `UI-003` / `UI-004`: Codex PR #28 (`feat/g7-ui-staging`, `7fa7cb2`) implements the 9-stage progress strip (CI `42343362420` 7/7 green); Gemini `feat/anugacare-ui-modernization` implements full `UX-01`â€“`UX-08` UI/UX modernization in parallel.
- [ ] `NAV-001`: verify configured navigation capability; prefer a truthful
      external handoff over fabricated map/ETA UI.
- [~] `PWA-001`: prior implementation exists; target deployed install/session/
      cache behavior and physical-device acceptance remain open.
- [x] `QA-001`: current PR #27 (`42203978157`) and PR #28 (`42343362420`) real-Supabase CI journeys pass; rerun after UI modernization integration and on deployed synthetic staging.
- [!] `QA-002`: physical Android and human Telugu/Hindi/healthcare wording review
      require named people and remain NOT TESTED.
- [~] `REL-001`: #22-#27 merged to `main` (`ea6d142`); PR #28 reviewed and green (`7fa7cb2`); Gemini UI modernization PR in progress on `feat/anugacare-ui-modernization`.
- [!] `REL-002`: Vercel identity inspected (`dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`); Supabase management token unavailable (`Access token not provided`); hosted migrations and deployment remain blocked.

Current mission progress: implemented 73/100, verified 65/100, merged 23/100,
deployed-and-verified 0/100. See the ledger for evidence and calculation rules.

## PR #27 CI fixture repair (2026-11-06) `[x]`

- [x] Inspect run `42167845149`, uploaded screenshots/receipt, job/server logs,
      seed intervals, assignment RPC and occupancy trigger.
- [x] Prove the 11:45 care request overlapped Asha's seeded Friday 07:00-12:00 visit;
      the database correctly refused and rolled back with SQLSTATE `22023`.
- [x] Use unoccupied seeded Ravi as primary and assert the assignment RPC response
      before checking UI state; do not weaken enforcement or increase timeouts.
- [x] Focused Ops lint/typecheck/unit tests and care/occupancy database tests pass.
- [x] Full local check-all and corrected-head CI `42170840666`: all seven jobs pass.
- [x] Verify #22 -> #27 base references and make PR #26 a literal ancestor of PR #27 without force-push.
- G6 technical CI passes; G7 physical/language and G8 hosted/release evidence remain open.

## Production operations hardening (2026-11-05) `[~]`

- [x] Remove unsupported outbound issue acknowledgement in EN/TE/HI.
- [x] Redact raw provider/database error text from core notification/vault/payment paths.
- [x] Add read-only schema attestation and executable operations/recovery runbooks.
- [x] Verify focused runtime checks 36/36 and disposable read-only SQL execution.
- [x] Final technical source CI `42041948258`: all seven jobs pass at `618af1d`.
- [ ] Hosted attestation, named owners, alert receipt and isolated recovery/rollback/incident drill.
- [ ] Provider/payment/retention decisions and final release approval; NO-GO remains.

## Session recovery hardening (2026-11-04) `[~]`

- [x] Reproduce and fix delayed auth/role response races in Ops and unified app.
- [x] Add four Ops regressions and two Flutter regressions; focused checks pass.
- [x] Final full automated regression/CI for the session fix (PR #25, seven jobs).
- [ ] Physical expiry/account-switch receipts.
- No production readiness, device or translation approval is implied.

## Production hardening (2026-11-04) `[~]`

- [x] Record founder consent/occupancy decisions; retain pending pricing/buffer/safety approvals.
- [x] Reproduce three consent defects and add DB projection/RLS/action enforcement.
- [x] Verify consent/assignment races against real Postgres and final-source CI.
- [x] Complete scoped scheduling/auth/notification hardening and operational runbooks.
- [x] Reconcile the existing 31 release rows with actual evidence.
- [ ] Physical Android, human language, environment/recovery and founder release signoffs.
- NO-GO remains; code-test completion does not authorize real patient activity.

## Production readiness audit (2026-11-04) `[x]` audit / `[!]` release

- [x] Verify source/PR/CI and current synthetic deployment with fresh metadata/hash.
- [x] Map automated journey/auth/refresh/privacy coverage and real-device gaps.
- [x] Audit EN/TE/HI keys/placeholders/renderers; prepare unsigned human approval plan.
- [x] Inventory disposable seed and historical demo manifests; propose safe cleanup.
- [x] Reproduce consent and overlap gaps without hosted writes; review security/ops gates.
- [x] Publish readiness report, 31-row matrix and physical Android test plan on working branch.
- [ ] Close P0 trip-consent behavior and establish an attested real-data boundary.
- [ ] Close applicable P1 device/language/auth, capacity/pricing, provider/finance,
      privacy/retention, monitoring/backup/rollback/incident and release gates.
- [ ] Founder release approval before any real patient activity. NO-GO remains.
- Reports: `docs/PRODUCTION_READINESS.md`, `docs/ANDROID_TEST_PLAN.md`.
- Delivery: draft PR #23 against `feat/visit-issue-handling`; both PRs remain unmerged.
- No deletion, real SMS/payment, deployment, merge or new feature workflow authorized.

## Request Care and issue acceptance review (2026-11-04) `[x]`

- [x] Trace care submission/confirmation/assignment through issue and resolution.
- [x] Reproduce and fix pickup-time rewrite on incident resume with additive SQL.
- [x] Reproduce and fix Family stale refresh/failure cards using existing guards.
- [x] Add SQL/widget regressions and real-browser pickup timestamp assertion.
- [x] Final local gates: focused SQL, nine Family care tests, full check-all.
- [x] Real-Supabase/browser CI: seven jobs pass at `335b58b`, run `41840577234`.
- [x] Record final evidence and update open PR #22; no merge/deploy authorized.
- Manual device/wording checks and underway takeover policy remain outside this review.

## Visit issue -> explicit Ops resolution -> Family status (2026-11-03) `[~]`

- [x] Review/merge #21; publish synthetic staging; focused post-deploy smoke.
- [x] Private operational notes across persisted Family read paths (ADR0008).
- [x] Ops stage/assignment context; explicit, stale-safe resolution; no restart fallback.
- [x] Truthful Family/Companion guidance and Updates refresh/resume.
- [x] Focused checks and sequential check-all; hosted issue/resolution/completion demo.
- [x] Record hosted migration, exact IDs, screenshots and scoped synthetic effects.
- [ ] Founder feature PR/preview review; latest-head CI status is tracked on the PR.
- Blocked product decision: safe underway takeover; existing reassignment remains scheduled-only.
- Physical phone/native wording and cleanup pending; production remains gated.

## Assigned visit -> companion journey -> Family progress (2026-11-02) `[~]`

- [x] Integrate #19/#20, combined CI7 green, publish existing synthetic staging.
- [x] Fresh guarded Family/Companion detail reads; persisted Family milestone time.
- [x] Hosted browser: request -> ops assignment -> OTP/all8 stages -> all roles Completed.
- [x] Focused SQL12/Family18/Companion31; no backend-rule or permission change.
- [x] Final sequential check-all passed; feature preview READY; evidence recorded.
- [x] PR #21 opened with preview and concise evidence.
- [ ] Founder review; latest-head CI status is linked on PR #21.
- Physical phone/wording and cleanup remain pending; production stays gated.


## Authorized PR #19 + #20 integration (2026-11-02) `[~]`

- [x] Both latest heads: seven green CI jobs; combined diff review has no blocker.
- [x] PR #19 merged14118fa; preserve both implementations and evidence.
- [ ] Combined CI, PR #20 merge, existing synthetic staging publication.
- [ ] Next slice: assigned companion visit and persisted Family progress.


## First Family care request (2026-11-02) `[x]`

- [x] Authorized patient/registered centre/existing package/ISTpickup -> review/submit.
- [x] Persisted one-date schedule visible in Family before trip generation and in ops.
- [x] Owner consent/permissions, retry identity and server duplicate guards.
- [x] Existing ops confirmation/assignment -> truthful persisted Family status.
- [x] Hosted synthetic browser demo, screenshots and focused SQL/API/UI checks.
- [x] PR #20 opened, protected synthetic preview READY; care/dispatch isolation regression19/19.
- Evidence and preview: `docs/evidence/care-request-2026-11-02/README.md`.
- Remaining: CI/PR review, phone/wording verification and scoped fixture cleanup;
  no production launch or new pricing/availability/payment/cancellation rules.

## PWA-first mobile readiness (2026-11-01) `[~]`

- [x] New feature branch from main after PR #18; preserve Android/APK support.
- [x] Reproduce/fix OTP route Back; clear stale OTP/error when changing number.
- [x] Release web build uses existing synthetic backend; no deployment.
- [x] Chrome installability diagnostics; EN/TE/HI phone-viewport screenshots.
- [x] Fresh Family/Asha/Ops identities, navigation/back, reload/logout/switching,
      companion injected-error recovery, Ops direction (no /ops/ journey).
- [x] New 15-widget matrix: narrow layout, 200% text, keyboard inset, lifecycle.
- [x] Desktop browser-history Back, offline Refresh/reconnect, browser freeze/resume.
- [ ] Phone home-screen installation, actual keyboard/system Back/OS resume.
- [ ] Native-speaker wording approval, separate from layout review.
- [x] Sequential local check-all passes; focused matrix rerun passes.
- [x] PR #19 opened; automated CI status tracked in its checks tab.
- [x] Sync SETUP, app README, architecture, spec/ADR delivery note and agent entry docs.
- Carry forward fixture cleanup pending, refresh fixtures before grouping checks;
  180-minute start window provisional; production/real-data/paid-provider gates.
- Evidence: `docs/evidence/pwa-readiness-2026-11-01/README.md`.


## Synthetic staging verification (2026-10-31; Ops completed Nov 1) `[x]`

- [x] Confirm PR #17 (`e18a0d2`) on live alias by deployment/source metadata and
      bundle evidence: `dpl_BcdNXbscaAv1U1rqUh15GzodHxA7`.
- [x] Narrow three-trip Asha fixture at all IST execution times, midnight deadline,
      guarded reruns/cleanup; 16 PGlite tests. No application access-rule change.
- [x] Full fast checks pass: database 170/8 skipped, ops 54, shared Dart 27,
      companion 47/3 skipped, family 35/6 skipped, unified 22.
- [x] Family 9000000101 identity, home, bookings/detail/back, navigation and logout/reload.
- [x] Founder-supplied hosted fixture output matches all three rows; deadline
      2026-11-01 00:00 IST. Rerun count not independently evidenced.
- [x] Asha identity/Previous/Today/Upcoming on `/app/`.
- [x] Browser refresh, stale responses, Retry (**injected-error test**).
- [x] Browser Family â†’ Asha switching and Asha protected-view denials.
- [x] Ops 9000000001 live identity, console guidance, cleared session and
      Back to sign in navigation; sanitized ops-access.json. No new /ops/ journey.
- [x] Follow-up PR #18 opened. Founder now authorizes ready/merge after final-head
      CI passes, respecting protections. No deployment under this follow-up.
- [x] Code CI 41210884363 at e200f58: all seven jobs pass, SQL 178/178 (162 real
      Supabase + 16 PGlite fixture), ops browser 7, real-DB Flutter and full journey,
      three APK builds. Initial Ubuntu 26.04/Playwright install failure fixed by
      pinning only the Supabase job to Ubuntu 24.04.
- Evidence and exact blockers: `docs/evidence/staging-verification-2026-10-31/README.md`.
- F05 180 minutes remains provisional; M10/real data/paid providers remain gated.

## Founder sketch UI streams (2026-10-11)

- [x] S2: inspect all 15 concept boards and seven previous ops screenshots; preserve source boards; define tokens and existing-screen mappings in `docs/design/tokens.md`.
- [x] S3: ops UI delivered as separate OPEN PR #5; full local checks pass; 23 browser captures. See that branch's docs/evidence/s3-ui/README.md.
- [x] S4: companion UI delivered as separate OPEN PR #6; full local checks pass; 38 curated widget captures. See that branch's docs/evidence/s4-ui/README.md.
- [x] S5: family/patient UI delivered as separate OPEN PR #7; full local checks pass; 25 curated widget captures. See that branch's docs/evidence/s5-ui/README.md.
- Runtime evidence, exact checks, differences and testing instructions must accompany each UI PR. No features are inferred from concept-only panels. Staging PR #2 is a separate dependency; PR #3 is obsolete.

Build one milestone at a time. A milestone is done only when its acceptance checks have run and
passed; record results (and checks that could not run) in `docs/HANDOFF.md`.

Goal of M1-M7, the **first working journey**: ops assigns a companion â†’ family sees the booking â†’
companion completes pickup and hospital handover â†’ family receives status â†’ return journey completes.

Status: `[x]` done and verified Â· `[~]` in progress Â· `[ ]` not started Â· `[!]` blocked

## M0. Repo foundation `[x]`

- [x] Git repo, `.gitignore` (secrets, patient data, generated session state excluded), `.env.example`
- [x] `docs/PRODUCT_SPEC.md`, `docs/TASKS.md`, `docs/HANDOFF.md`, `docs/SETUP.md`, ADRs 0001-0003
- [x] `CLAUDE.md` and `AGENTS.md` point to the spec; BRD/CLAUDE.md conflict resolved (ADR 0001)
- [x] pnpm workspace root, Supabase CLI config (`supabase/config.toml`)

Acceptance: `pnpm install --frozen-lockfile` succeeds; `git status` shows no `.env`, `.remember/` or `node_modules/`.

## M1. Database core, permissions and the journey in SQL `[x]`

- [x] Schema: profiles, clusters, centres, patients, patient_access, consents, companions, packages,
      schedules (primary + backup), trips, trip_otps, trip_events, trip_transitions, notifications,
      audit_log, app_settings, vault_documents, vitals, medicines
- [x] Grants revoked by default; per-table/column grants; RLS on every table
- [x] RPCs: `create_patient`, `ops_assign_schedule_companions`, `ops_assign_trip_companion`,
      `ops_generate_trips`, `issue_pickup_otp`, `verify_pickup_otp`, `advance_trip`,
      `family_trip_board`, `companion_my_trips`, `vault_list_documents|vitals|medicines`
- [x] Synthetic seed with fixed ids
- [x] Tests: allowed + denied for each rule, full journey, exceptions, audited vault reads

Acceptance (all met 2026-10-08): `pnpm db:test` 55/55 pass on PGlite; `pnpm typecheck` clean;
mutation check (leak vault SELECT, disable companion window) makes tests fail.
Real Supabase run: passed, see M1a.

## M1a. Real Supabase verification `[x]`

Run the M1 suite on real Supabase (Postgres 17, real `auth` schema and roles, `storage` schema).
Path: CI job `supabase-local` (`supabase start`, `supabase db reset`, `pnpm db:test:supabase`);
manual path in `docs/SETUP.md`. `supabase/tests/platform.test.ts` adds storage-privacy, real
`auth.uid()` and anon-denial checks (skipped on PGlite).

Acceptance (met 2026-10-08, GitHub Actions run 37748137710 on `iamnawin/anuga` @ `487d409`):
all 4 migrations and the seed applied; `pnpm db:test:supabase` 60/60 pass, 0 skipped.
Real phone-OTP sign-in through Supabase Auth: covered since M3 (Playwright). Still not covered
(arrives with M8): private bucket policies and signed URLs.

## M2. Shared Dart package `[x]`

- [x] `packages/shared_dart` (pure Dart, no SDK dependency): `TripStatus`, `TransitionActor`,
      `TripStateMachine`, models for every M1 RPC result, `CompanionApi` / `FamilyApi` / `OpsApi`
      over an injected `RpcCaller`
- [x] Contract: `pnpm contract:export` writes `test/fixtures/trip_contract.json` from SQL;
      `supabase/tests/contract.test.ts` fails on SQL drift; Dart test fails on Dart drift
- [x] Flutter SDK configured (user PATH, `PUB_CACHE` on D:), commands documented in `docs/SETUP.md`
- [x] CI: `shared-dart` job (format, analyze --fatal-infos, test); actions bumped to v5

Acceptance (met 2026-10-08): `dart test` 16/16; `dart analyze --fatal-infos` clean; format check
clean; mutation (remove one Dart rule) fails the agreement test; `pnpm db:test` 57 pass, 3 skipped
(real-Supabase-only), `pnpm typecheck` clean.

## M3. Ops console: assign and monitor `[x]`

`apps/ops_console` (Next.js 16, TypeScript, pnpm workspace). Phone-OTP login against Supabase local
(`[auth.sms.test_otp]` in `supabase/config.toml` with synthetic numbers; no SMS provider).

- [x] Migration `0500_ops_console.sql`: `ops_schedule_board`, `ops_trip_board` (date/status filter,
      late flag), `ops_exception_queue`, `ops_companion_options` (eligibility + reason). Ops only;
      late threshold, lookback and board range in `app_settings`. Allowed + denied tests for each.
- [x] Phone OTP on Supabase local: seed `auth.users` rows in GoTrue's shape; test OTP `123456`.
- [x] Schedules list with primary/backup assignment (`ops_assign_schedule_companions`), showing
      eligibility errors from the database.
- [x] Trips board filtered by date/status; one-tap backup and reassign (`ops_assign_trip_companion`).
- [x] Exception queue: `issue_reported`, `no_show`, late; resolve actions derived from `trip_transitions`.
- [x] English, Telugu, Hindi strings (Telugu/Hindi drafted by the dev team; need native review).

Acceptance (met 2026-10-08, Claude Code cloud session with Docker): `pnpm lint`, `pnpm typecheck`,
`pnpm test` (Vitest 36/36), `pnpm build` pass; Playwright 6/6 against Supabase local, including
"ops signs in with phone OTP and assigns the backup companion to a trip"; screenshots in
`docs/screenshots/m3/`. `pnpm db:test` 72 pass / 3 skipped; `pnpm db:test:supabase` 75/75.
CI: job `ops-console`; Playwright added to `supabase-local`. GitHub Actions run 37769970593
(PR iamnawin/anuga#1): all jobs green, Playwright 6/6 on real Supabase in CI.

## M4. Companion app: run a trip `[x]`

`apps/companion_app` (Flutter 3.47.6, Android first) over `packages/shared_dart`.

- [x] Phone-OTP sign-in (no sign-up), companion-role gate.
- [x] Today/upcoming from `companion_my_trips` (restricted fields; hidden outside the window).
- [x] Check-in buttons from the shared state machine (`lib/src/trip_actions.dart`); pickup only via
      `verify_pickup_otp` with attempts left; optional handover note; return legs; required
      post-visit note; issue report with description; confirmed no-show; "call 108" notice.
- [x] English, Telugu, Hindi (ARB); text >= 1.15x, 56 dp buttons, light/dark high-contrast theme.
- [x] Android: INTERNET permission; debug-only cleartext to Supabase local (10.0.2.2).

Acceptance (met 2026-10-08, cloud session): `flutter analyze --fatal-infos` clean; format clean;
`flutter test` 41 pass + 1 skipped (widget tests for all 12 trip states, OTP errors, reassignment
and conflict errors, notes; full trip through the app widgets against a fake backend that enforces
the shared state machine). Mutation (offer pickup without OTP) fails 6 tests.
Extra: `test/supabase_local_test.dart` ran the companion journey on Supabase local (ops assigns,
viewer denied OTP, owner issues it, wrong then right code, return legs, completion, 8 family
notifications): pass. CI: job `companion-app` (+ `flutter build apk --debug`); the Supabase journey
runs in `supabase-local`.

## M5. Family app: booking and live status `[x]`

`apps/family_app` (Flutter 3.47.6, Android first) over `FamilyApi`.

- [x] Migration `0600_family_app.sql`: `family_my_patients` (with access level),
      `family_trip_timeline` (no locations or actor ids), `my_notifications` (push inbox).
      Allowed + denied tests (`supabase/tests/family_app.test.ts`).
- [x] `shared_dart`: `AccessLevel` (rules mirror SQL), `FamilyPatient`, `TripEvent`,
      `InboxNotification`; shared `RpcException`, `PhoneAuth` and India helpers (the companion app
      now uses them too).
- [x] Booking board (`family_trip_board`) with backup-covering label; visit timeline; pickup code
      (owner/editor/patient, only while awaiting pickup); cancel a scheduled visit (owner/editor,
      confirm + reason); updates inbox; patient picker; en/te/hi.

Acceptance (met 2026-10-08, cloud session): `flutter analyze --fatal-infos` clean; format clean;
`flutter test` 17 pass + 1 skipped, including "a viewer never sees the pickup code button, in any
status" and the access-level x status matrix; full app flow against a fake backend.
`test/supabase_local_test.dart` on Supabase local: viewer refused code and cancel by the database,
companion picks up with the owner's code, family cannot cancel once started, timeline and inbox
correct, companions refused the family read models: pass. `pnpm db:test` 81 pass / 3 skipped;
`pnpm db:test:supabase` 84/84; `dart test` (shared_dart) 24/24. CI: job `family-app`; the family
journey runs in `supabase-local`.

## M6. Notifications dispatch `[x]`

Edge Function `supabase/functions/notify-dispatch` (Deno entry; runtime-neutral core tested in Node).

- [x] Migration `0700_notification_dispatch.sql`: `dispatch_claim_notifications` (lease +
      `skip locked`, counts the attempt), `dispatch_mark_sent`, `dispatch_mark_failed`
      (exponential backoff, final `failed` after `notification_max_attempts`, or at once when
      permanent); service role only. `notification_deliveries` records what the `test` adapter "sent".
- [x] Adapters from env: `test` by default for push, WhatsApp and SMS; `fcm`/`whatsapp`/`sms`
      need `NOTIFY_LIVE_PROVIDERS_AUTHORIZED=yes` and are not implemented, so the function refuses
      to start with them. No live provider calls.
- [x] Messages in en/te/hi by the recipient's `preferred_language`. Status words only: a
      companion note (free text, may mention health) never leaves the database; the message says
      "open the app to read the companion's note" (found and fixed during M7).

Acceptance (met 2026-10-08, cloud session): `dispatcher_unit.test.ts` (13: rendering, adapter
selection, retry decisions, REST store); `dispatch.test.ts` (8: permissions, lease, expired lease,
backoff 60/120/240/480 s then failed, permanent failure, and a trip status change delivered to
owner and viewer in their languages via the test adapter, nothing sent twice).
`dispatch_function.test.ts` on Supabase local with the edge runtime: anon refused (403); service
role call delivers a status change. `pnpm db:test` 102 pass / 5 skipped; `pnpm db:test:supabase`
107/107. Scheduling the function needs a hosted project (M10).

## M7. End-to-end journey across apps `[x]`

`scripts/e2e-journey.sh` runs the first working journey in order against Supabase local, with the
real clients: the ops console in a browser (Playwright `e2e/journey.spec.ts`), the companion and
family Dart API layers (`test/journey_test.dart` in each app, same adapters as the apps) and the
`notify-dispatch` Edge Function. Helper: `scripts/journey.ts` (setup, dispatch checks, report).

Steps: today's visit (40 min ahead) -> ops assigns the backup in the console -> family sees the
booking covered by the backup; viewer refused the code, owner issues it -> companion sets off,
wrong code refused, family code accepted, centre, handover note -> dispatcher delivers; check that
no companion note leaves the database -> family timeline + inbox show the handover -> return
journey, completion note -> dispatch -> family sees completed -> ops board shows completed,
exception queue clear.

Acceptance (met 2026-10-08, cloud session): journey passed on Supabase local in ~60 s; evidence in
`docs/evidence/m7/` (log + 2 screenshots). The run first caught a real defect: notes were copied
into outbound messages; fixed in `messages.ts`, and the journey now fails if a note leaks (proved
against the stale function). CI: the journey runs at the end of `supabase-local` and uploads the
`journey` artifact. Flutter UIs on a device/emulator are not part of the run (no Android SDK in the
cloud session); their widgets are covered by the M4/M5 widget tests.

## M8. Vault UI and storage `[x]`

- [x] Migration `0800_vault_storage.sql`: private bucket `vault` (10 MB; JPEG/PNG/WebP/PDF; no
      object policies for app roles); `vault_create_document` (owner/editor + owner's vault
      consent; server-generated path; direct inserts revoked), `vault_upload_target`,
      `vault_mark_uploaded` (service role), `vault_document_download` (audited vault read, URL
      lifetime from `app_settings`); vault writes need the owner's vault consent;
      `family_consents`, `set_consent` (owner only, audited).
- [x] Edge Function `vault-files`: authorizes as the caller, then signs upload/download URLs.
- [x] Family app: Records tab (list, add report photo, view image via signed URL, pending state),
      Privacy and consent screen (per-purpose switches, confirm on withdraw), en/te/hi.
- [ ] PDF upload/view in the app: needs a file picker / viewer package (founder decision, see HANDOFF).
- [ ] Deleting existing vault data on withdrawal: the backlog deletion job (retention decision).

Acceptance (met 2026-10-08): SQL `vault_storage.test.ts` 11 (allowed/denied for every rule);
`vault_files_unit.test.ts` 6; `vault_files_function.test.ts` on Supabase local (upload -> confirm
-> viewer download, bytes match, read audited, companion/ops/anon refused, no direct or public
storage access, no overwrite); family app widget tests (access level x consent, upload sequence,
viewer, consent switches) and its Supabase-local vault test. `pnpm db:test` 120 pass / 6 skipped;
`pnpm db:test:supabase` 126/126; M7 journey still passes.

## M9. Payments (test mode) `[x]`

- [x] Migration `0900_payments.sql`: `invoices`, `invoice_lines`, `payments` (paise; no direct
      grants; audited). Fares: `ops_record_trip_fare` (pass-through at cost; frozen once billed).
      Invoices per patient and India-time month: completed visits at the package price + fares +
      the package's monthly fee (`ops_generate_invoice`, `ops_issue_invoice` notifies the owner,
      `ops_invoices`). Family: `family_invoices` / `family_invoice_lines` (owner and editors,
      issued bills only). Payments: `payment_start` (owner), `payment_set_order`,
      `payment_captured` (service role; idempotent; amount must match).
- [x] Edge Functions `payments` and `payments-webhook` (HMAC-signed bodies only). Adapter `test`
      by default; Razorpay adapter accepts only `rzp_test_` keys without founder authorization.
- [x] Ops console: fare entry for completed trips; Billing page (generate/rebuild draft, issue).
- [x] Family app: Bills tab (owner and editors), bill lines, test-mode payment for the owner.
- [x] Dispatcher: `invoice_issued` message with the amount in rupees (en/te/hi).
- [x] M7 journey extended: fare -> invoice -> bill notification -> owner pays -> ops sees paid.
- [!] Razorpay test-mode run: needs Razorpay test API keys and a webhook registration
      (not available). Razorpay Checkout in the app and UPI Autopay: founder decisions.

Acceptance (met 2026-10-08): SQL `payments.test.ts` 9; `payments_unit.test.ts` 10 (adapter
selection, order request, webhook signatures, handler); `payments_function.test.ts` on Supabase
local (forged webhook refused, signed webhook pays once, owner-only, test completion);
ops console Vitest 52, Playwright 7 + journey; family app 35 tests; journey passes with billing.
`pnpm db:test` 140 pass / 8 skipped; `pnpm db:test:supabase` 148/148.
Assumption to confirm: only `completed` visits are billed (`app_settings.billable_trip_statuses`).

## M9a. Salesforce ops copy (ADR 0005) `[ ]`

Stream S6 (backend). Supabase stays the system of record; Salesforce gets a one-way copy.

- [x] Decision and field allow-list: `docs/adr/0005-salesforce-ops-copy.md` (2026-10-20).
- [ ] Migration: `crm_outbox` (no app-role grants), triggers on patients, schedules, profiles,
      patient_access, companions, centres, clusters, trips and invoices that enqueue allow-listed fields only.
- [ ] Service-role claim/mark RPCs (same pattern as `notification_deliveries`).
- [ ] Edge function `crm-sync`: `test` adapter by default; `salesforce` adapter upserts on
      `Anuga_Id__c` with OAuth client credentials. Credentials in Supabase secrets only.
- [ ] Tests. Allowed: the service role claims rows; a trip update enqueues the allow-listed fields.
      Denied: app roles can't read or write the outbox; changes to date of birth, vault or medicines
      enqueue nothing; the payload never contains a never-sent field.
- [ ] Salesforce Developer Edition org with the synthetic seed: objects, External ID fields,
      Private org-wide default, renewal and on-time reports.
- [!] Real data, a paid org on Hyperforce India, a DPA and the privacy-notice update: gated with M10.

Acceptance: a fresh `pnpm db:test` passes with the new allowed and denied tests; one synthetic
journey shows up in the dev org with no never-sent field anywhere.

## M10. Production launch `[!]` gated

Blocked by: pilot go/no-go metrics, health-tech legal review, brand name, Supabase Mumbai project,
paid services authorization, breach runbook with a named owner, real-Supabase test run;
for Salesforce (ADR 0005): a paid Hyperforce India org, a DPA and the privacy-notice update.
Not started without explicit founder approval.

## Research cleanup (2026-10-12, local/uncommitted)

Checkpoint update (2026-10-16): founder authorized committing the retained research,
design inputs and handoff before the documentation bootstrap. Earlier no-commit
wording below records the prior task boundary. Application/runtime checks are not
repeated for the checkpoint; product inventory is the next authorized task.

- [x] Review three research documents; qualify unsupported competitor claims and old-snapshot gap counts.
- [x] Inspect four generated `.claude-flow` JSON artifacts and remove only that hook-output folder; preserve documents/screenshots.
- [x] Update HANDOFF; separate proposed N1-N5 operations from X1 mobile consolidation; keep business policies pending.
- [ ] Founder policy review and reconcile gaps against current main/PR #10 before implementation planning.
- No app/dependency/migration/config changes; no commit, push, deploy or publish authorized.

## AnugaCare hardening (2026-10-22) `[~]`

Branch `feat/anugacare-hardening`. Source: external review `docs/research/anugacare-db-findings-2026-10-22.md`.

- [x] Brand AnugaCare in user-facing names (ADR 0006); ids and package names unchanged.
- [x] Mobile readiness and framework analysis: `docs/research/anugacare-mobile-analysis.md`
      (keep Flutter, merge into one app, ops stays web).
- [x] Migration `20261022000100_trip_controls.sql`: F02 training required for assignment and
      companions must be active, verified and trained to act; F04 companion reads of `trips` and
      `trip_events` limited to the detail window; F05 companion start window
      (`app_settings.companion_start_minutes_before`, 180 placeholder); F06 notes required for
      companion `completed` and `issue_reported`. 9 allowed/denied tests in `trip_controls.test.ts`.
- [ ] Founder decisions, then fixes: F01 consent withdrawal, F03 companion occupancy, F07 price per visit.
- [ ] **Pending founder decision:** F05 start window. The 180-minute window is implemented (one
      `app_settings` row) but remains a provisional product value, not an approved business rule.
- [x] Real-DB Flutter tests (`supabase_local_test.dart` in both apps) have ops start the seed
      trip, which can be days ahead; the 40-minute journey (`scripts/e2e-journey.sh`) still covers
      a companion starting inside the window.
- [x] Companion app: "Start" is disabled before the window and says when it opens. Migration
      `20261027000100` adds `start_allowed_at` to `companion_my_trips()` from the same setting, so the
      app never hard-codes the window; the button enables itself when the window opens.
- [ ] X1 one mobile app (first slice: see "Unified AnugaCare entry" below), release signing, push,
      offline queue, live family refresh (analysis section 6).
- [x] Logo (2026-10-27): founder artwork in `docs/logo/`; app icons, favicons, Android launcher
      icons, sign-in screens and the site root page. Open: SVG master, Android adaptive icons.
- [x] Next.js 16.4.0 -> 16.4.3 (2 critical, 1 high advisory fixed in 16.4.1; `pnpm audit` clean).

Coordination (PR: see `docs/HANDOFF.md`; draft, not merged):

| Item | Owner | Status |
|---|---|---|
| This PR (`feat/anugacare-hardening`) | iamnawin (with Claude Code) | Implemented; not merged; migration not applied; not deployed |
| F01 / F03 / F07 / F05 window decisions | Founder | Blocked on decision |
| PR #10 weekly visit pattern, PR #11 cancellation notification | Unassigned | Open; independent of this PR except `docs/HANDOFF.md` |
| PRs #3 to #7 | Unassigned | Content already on main via #8; candidates to close |

- Affected modules: `supabase/migrations` (new `20261022000100`, redefines `advance_trip`,
  `verify_pickup_otp`, `ops_companion_options`, `private.assert_companion_eligible`,
  `private.can_view_trip`, `trips` policy `participants`), `supabase/tests`, ops console
  (`api.ts`, `messages.ts`, e2e spec), both Flutter apps (brand strings, real-DB tests), docs, CI.
- Dependencies: PR #11 redefines `private.apply_transition` and PR #10 `ops_generate_trips`;
  neither is touched here. Whoever merges second rebases `docs/HANDOFF.md` and re-runs `pnpm db:test`.
  Their migrations are dated `20261012...`, before this one: if this PR lands first, rename them
  to a later timestamp so hosted `supabase db push` does not see out-of-order migrations.
- Rule for parallel work: a later migration that redefines one of the functions above must start
  from this PR's version, or the F02/F04/F05/F06 checks are silently dropped.

## Unified AnugaCare entry, X1 first slice (2026-10-26) `[~]`

PR #13, merged to main 2026-10-29. ADR 0007 accepted (founder approved the unified-app direction,
2026-10-29). Owner: iamnawin with Claude Code.

- [x] `apps/anugacare_app`: one phone/OTP sign-in, no role picker; home from `profiles.role`
      (family home, companion trips); ops accounts sent to the console; other roles refused.
- [x] Checking, failed lookup with retry, expired session (on launch and while a home is open).
- [x] en/te/hi for the new screens (te/hi need native review); family and companion screens mounted
      unchanged through `lib/family_app.dart` and `lib/companion_app.dart`.
- [x] `scripts/check-all.sh` and CI job `anugacare-app` (format, analyze, test, debug APK).
- [x] 21 widget tests; screenshots in `docs/evidence/unified-entry/`.
- [ ] Final application id (ADR 0006 point 4), release signing, store listing.
- [ ] Run against Supabase local on a device or emulator (not done: no Docker, no device here).
- [ ] Family home clips at 200% text (patient card, bottom navigation): pre-existing, family app.
- [ ] Retire the standalone family and companion entry points once the unified app ships.

## Demo data, Create trips, unified app on the test site (2026-10-27) `[~]`

Branch `feat/anugacare-brand` (PR #16).

- [x] `supabase/seed/demo_refresh.sql`: current demo state on the hosted synthetic project; safe to
      rerun; refuses non-synthetic patients or accounts.
- [x] Migration `20261027000200_ops_create_trips.sql`: `ops_create_schedule_trips()` returns each
      pickup date as created or skipped; no duplicates (unique schedule + pickup time); 1-60 days;
      ops or trusted backend only. `ops_generate_trips` now counts its created rows.
- [x] Ops console Schedules: **Create trips** button with the per-date result (en/te/hi; te/hi
      need native review).
- [x] Test site: unified app at `/app/`.
- [x] Apply `20261027000200` to the hosted synthetic project (dashboard SQL editor; founder, 2026-10-28) and run `demo_refresh.sql`.
- [ ] Nightly automatic trip generation (not built; ops presses Create trips for now).
- [ ] Pending founder decisions, unchanged: F01, F03, F07 and whether no-shows are billed.

## Stack merged, staging check, companion trips fix (2026-10-29) `[~]`

- [x] PRs #12, #13, #14, #16 merged to main in order (merge commits cf83d00, a18e046, 5075857,
      f68c271); main CI green on f68c271. No human reviews on these PRs (bot comments only).
- [x] Staging, ops: Create trips pressed twice on a Mon/Wed/Fri schedule: 7 created / 5 skipped,
      then 0 created / 12 skipped.
- [ ] Staging, signed in: family home/bookings/navigation/logout, companion trips/navigation,
      account switching leaves no earlier account's data, ops and unauthorized accounts refused
      protected views. Waiting on the founder to enter the hosted test code.
- [x] Companion trips (also the unified app's companion home): past trips listed under
      **Previous** instead of **Today**; a slower earlier refresh can no longer replace a newer
      result; refresh clears old cards; visible Retry after an error; `previous` string in en/te/hi
      (te/hi need native review). Ported from the uncommitted ANU-004 worktree.
- [ ] F05: the 180-minute window is implemented but remains a provisional product value, not an
      approved business rule.

## Backlog (from spec, unscheduled)

Requests ("I need..."), medicine refill reminders, live companion location during active trips,
H3 density views and cluster density gate in ops console, monthly bill view, family invites with
roles, trip data export for pilot metrics, deletion job for consent withdrawal.

## Combined local testing (2026-10-11)

- [x] Combine tokens, all three UI streams and PR #2 browser support on integration/local-anuga from current main. Source PRs #2/#4-#7 preserved.
- [x] Full fast checks and separate app lint/analyze/tests; three release web builds; loopback HTTP and server boundary smoke passed.
- [x] Inspect latest source CI: all jobs passed on PR #2 and #4-#7, including real-Supabase journeys.
- [x] Local launcher and independent browser origins, synthetic accounts, active-window visit fixture and walkthrough in docs/LOCAL_TESTING.md.
- [!] Authenticated manual visit: synthetic hosted project Phone provider is disabled. Founder dashboard steps in LOCAL_TESTING; local Docker unavailable. No secrets in chat.
- [x] Integration PR #8 opened: https://github.com/iamnawin/anuga/pull/8. No main merge/deploy command; existing PRs intact. Existing Vercel Git automation created previews, recorded in HANDOFF.
- [x] Integration CI 38145315706 at 719361c: all six jobs pass, real Supabase 150/150 with zero skips, ops browser 7 pass, full cross-app journey and test billing pass, both debug APKs pass. Final receipt only docs and restored staging-script executable bit; no product changes after tested SHA.
- [ ] Founder manual browser journey after Phone-provider/test-number dashboard setup.

## Founder-authorized combined publication (2026-10-11)

- [x] Founder authorized PR #8 main merge and existing anuga.vercel.app synthetic publication; PR #8 merged, main CI passed all six jobs.
- [x] Hosted Phone enabled; real synthetic allowed/denied/CORS smoke passes.
- [x] Same-origin storage and BroadcastChannel regression reproduced/fixed; real browser sign-ins, independent reloads and isolated sign-out pass.
- [x] Final fast checks, separate app checks and all three web release builds pass; guarded Windows build output cleanup/sub-path support.
- [x] Authenticated Vercel CLI; existing project configured for prebuilt combined site, no new project or paid service.
- [x] Publish combined prebuilt to anuga.vercel.app: dpl_FHuVVy4Th8XzxEqQAz3Ekc1ZFyN3 at de8f72a. Four routes HTTP 200; three real role sign-ins/reloads and isolated companion sign-out pass.
- [x] Hosting fix PR #9 opened; source CI 38150546061 running. Documentation-only live receipt checked with git diff --check.
- [x] Publish fix PR #9 merged at 37bdae2c. Code CI 38150546061/de8f72a: six jobs pass, real Supabase 150/150 zero skips, ops browser 7 pass, full journey/test billing and APKs. Main product source matches deployed/tested code. Final doc-only receipt checked, no app rerun; receipt/main CI may be running.
- [ ] Founder manual active-window visit. Additive synthetic fixture and walkthrough remain in LOCAL_TESTING.

## Research/design push checkpoint (2026-10-22)

- [x] Preserve the unpushed research/design checkpoint on a separate branch.
- [x] Add the founder UI mockup PDF; ignore generated `.omx/` session state.
- Validation: whitespace checks and PDF structure checks; full check script blocked
  at installation because Node is unavailable to WSL pnpm. See HANDOFF.

### Agent Session - 2026-11-14 11:22 IST - COMP-V2 preview publication

**Agent:** Codex, delivery coordinator. First observed session clock 11:17:53 IST; checkpoint 11:22 IST.
**Task ID / Name:** COMP-V2-PREVIEW / publish companion screens for founder testing.
**Repository / Worktree:** D:\AI-Workspace\Repos\anuga-companion-screens-v2.
**Branch:** feat/companion-screens-v2.
**Starting commit:** fbbc13bac8b5089d4862b350c92725b8116859f7.
**Current commit:** Runtime/deployed source fbbc13b; this documentation commit identified by Git metadata.
**PR:** https://github.com/iamnawin/anuga/pull/36 (OPEN, DRAFT).
**Scope:** Founder requested commit/push and Vercel test availability; synthetic preview only.
**Completed work:** Confirmed source already committed and remote head identical; git push reported Everything up-to-date. Built all four apps with existing public synthetic settings and deployed a prebuilt preview to the existing anuga project.
**Files changed:** HANDOFF, TASKS, EXECUTION_STATE, PROGRESS_LEDGER, UX_AUDIT, UX_IMPLEMENTATION_PLAN documentation only. No runtime/config/backend changes.
**Tests and actual results:** scripts/build-staging.sh exit 0 (Ops and all three Flutter release web builds). Existing Cupertino font warning remains. Authenticated Vercel CLI curl /app/ returned HTTP 200. No browser sign-in/journey or physical-phone test in this session. git diff --check passed before receipt; repeated before commit.
**CI evidence:** https://github.com/iamnawin/anuga/actions/runs/43406351667 on fbbc13b: db-tests, shared-dart, ops-console, companion-app, family-app, anugacare-app SUCCESS; supabase-local FAILURE at care_request.spec.ts:207, old group locator matching time and Lakshmi Rao not found. Supabase Preview SKIPPED. No all-green CI claim.
**Merge status:** Not merged; draft PR remains open.
**Deployment and migration status:** Preview READY, dpl_7vXnp3NqYb3qbYcSSH3xyKJeFVvz, https://anuga-648ez5abn-iamnawins-projects.vercel.app/app/ . Existing live alias unchanged. No hosted migrations/data mutation. Inspector: https://vercel.com/iamnawins-projects/anuga/7vXnp3NqYb3qbYcSSH3xyKJeFVvz .
**Decisions and assumptions:** Existing vercel.json disables Git deployment; push alone cannot publish. Used existing manual prebuilt deployment; no automatic deployment config changed. New screens are unified /app/, not legacy /companion/. Preview may require Vercel team sign-in.
**Blockers:** CI journey locator failure unresolved; browser/native/language acceptance pending. No production gate closed.
**Uncommitted changes:** This six-file documentation receipt before commit; generated artifacts ignored.
**Exact next action:** Commit/push receipt to same branch, verify remote SHA, founder opens preview /app/ and signs in with synthetic companion 9000000201 or 9000000202. Resolve journey CI before merge.
**Next responsible agent:** Founder for preview test; Codex for requested fixes.
