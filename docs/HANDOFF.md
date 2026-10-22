# Handoff

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
