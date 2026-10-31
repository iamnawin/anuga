# Tasks and milestones

## Synthetic staging verification (2026-10-31) `[~]`

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
- [x] Browser Family → Asha switching and Asha protected-view denials.
- [ ] Ops 9000000001 identity/routing through `/app/`.
- [x] Draft follow-up PR #18 opened; no merge or deploy under this task.
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

Goal of M1-M7, the **first working journey**: ops assigns a companion → family sees the booking →
companion completes pickup and hospital handover → family receives status → return journey completes.

Status: `[x]` done and verified · `[~]` in progress · `[ ]` not started · `[!]` blocked

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
