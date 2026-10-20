# Handoff

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
