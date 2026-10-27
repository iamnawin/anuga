# Handoff

## Demo data, Create trips, unified app on the test site (2026-10-27)

Branch `feat/anugacare-brand` (PR #16). Not merged.

- `supabase/seed/demo_refresh.sql` (SETUP → Hosted staging): makes every screen show current
  synthetic data; refuses to run on a database with non-synthetic patients or accounts.
- Migration `20261027000200_ops_create_trips.sql` + ops console Schedules → **Create trips**:
  shows each pickup date as created or already scheduled; repeat presses create nothing new.
- `scripts/build-staging.sh` builds the unified app to `/app/` and links it from the root page.
- Billing and no-show rules untouched; F01, F03, F07 and no-show billing remain founder decisions.
- Checks: `pnpm db:test` 154 pass / 8 skipped (2 new: created/skipped with no duplicates; family,
  companion and out-of-range refused); ops lint, typecheck, 54 Vitest pass; demo_refresh run twice
  on PGlite and refused with a non-synthetic patient or phone (throwaway test, not committed).
- Not run: Playwright e2e and real-Supabase tests (no Docker).

Exact next task: apply `20261027000200` to the hosted synthetic project, run `demo_refresh.sql`,
then test both roles on the unified app at anuga.vercel.app/app/.

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
  provider or ops console change. `PRODUCT_SPEC` §5a updated.
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
  `అనుగాకేర్` / `अनुगाकेयर` need a native check. Trademark search open (M10).
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
- Options turned down: Salesforce as the main database (a rewrite of M2–M9, with access checks
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
| `scripts/e2e-journey.sh` with billing | **JOURNEY PASSED**: bill ₹550 (visit ₹400 + fare ₹150), owner notified, paid in test mode, ops sees paid; evidence `docs/evidence/m7/` |
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
