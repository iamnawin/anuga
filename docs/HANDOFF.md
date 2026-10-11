# Handoff

## Final UI delivery receipt (2026-10-11)

This worktree is ui/s5-family. S2-S5 are pushed, OPEN, based on main, with the same committed S2 contract incorporated in each UI stream. No merge or deployment was performed.

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


## S5 UI delivery (2026-10-11)

Branch ui/s5-family, main plus S2 PR #4 commits. Fourteen authorized files: theme,nine existing screens,one reused presentation helper and three ARB titles. Teal ANUGA/mint/navy home/visits/records/privacy/bills/inbox. All callbacks,keys,API,role gates,payment/upload adapters and tests retained. No separate patient mode or concept-only capability. Header/picker bounded scroll, long dropdown rows wrap, scaled navigation can scroll; large system text remains uncapped.

Final scripts/check-all.sh exit0; all install/typecheck/lint/build/format/analyze pass. PGlite140/8skips,ops52,shared27,companion39/3skips,family35/6skips. Separate family analyze clean/tests35/6. Seven widget scenarios pass with missed taps fatal;114 PNGs generated,25 curated. At360x640/3x long-name/two-patient test opens picker,switches patient,and reaches inbox. Evidence/mapping/differences/test commands: docs/evidence/s5-ui/README.md. Diff whitespace clean and independent focused source review passed. Logs artifacts/s5-check-all.log,s5-analyze.log,s5-tests.log,s5-visual.log.

Not run: device/emulator,real-Supabase journey/permissions (Docker absent),hosted staging,native-language review. Evidence is real-widget/synthetic API rendering with harness-only readable fonts and synthetic report fixture; no auth/security/device claim. PR status: separate S5 PR prepared,no merge/deploy. S2 open PR #4,S3 PR #5,S4 PR #6. Exact next task: open S5 PR,record all PR links,then founder review/test existing flows with synthetic backend; staging requires PR #2 and dashboard steps.


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
