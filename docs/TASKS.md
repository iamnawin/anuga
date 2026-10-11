# Tasks and milestones

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
Still not covered (arrives with M3/M8): real phone-OTP sign-in through Supabase Auth, private
bucket policies and signed URLs.

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

## M3. Ops console: assign and monitor `[~]`

`apps/ops_console` (Next.js, TypeScript, pnpm). Phone-OTP login against Supabase local
(`[auth.sms.test_otp]` in `supabase/config.toml` with synthetic numbers; no SMS provider).

- Schedules list with primary/backup assignment (`ops_assign_schedule_companions`), showing
  eligibility errors from the database.
- Trips board filtered by date/status; reassign a scheduled trip (`ops_assign_trip_companion`).
- Exception queue: `issue_reported`, `no_show`, late (pickup time passed, still `scheduled`).

Acceptance: lint + typecheck + unit tests pass; Playwright (or equivalent) test drives
"assign backup to a trip" against Supabase local or a recorded test adapter; screenshots in PR.

Status 2026-10-11: code complete. Local: lint, typecheck, 13 unit tests, build pass. Playwright
`e2e/assign-backup.spec.ts` (allowed + denied) wired into CI `supabase-local`; not yet run.

## M4. Companion app: run a trip `[ ]`

`apps/companion_app` (Flutter, Android first). Today/upcoming from `companion_my_trips`,
check-in buttons from allowed transitions, OTP entry (`verify_pickup_otp`), handover note,
return legs, complete with post-visit note, issue report. Large tap targets; en/te/hi strings from day one.

Acceptance: `flutter analyze` clean; widget tests for each trip state; integration test of the
full trip against a fake API client from `shared_dart`.

## M5. Family app: booking and live status `[ ]`

`apps/family_app` (Flutter). Booking board (`family_trip_board`), trip timeline (`trip_events`),
issue pickup OTP, cancel a scheduled trip, notification inbox (`notifications`).

Acceptance: as M4, plus a test that a viewer-level user cannot see the OTP button.

## M6. Notifications dispatch `[ ]`

Supabase Edge Function (or worker) that drains `notifications` with adapters:
`test` (records to a table/log) by default; FCM and WhatsApp adapters behind env flags, unused
until a provider is authorized. Retries with `attempts`, `status`.

Acceptance: unit tests for adapter selection and retry; integration test that a status change
produces a delivered record via the test adapter. No live provider calls.

## M7. End-to-end journey across apps `[ ]`

Run the first journey across ops console + companion app + family app against Supabase local
(or the cloud environment's equivalent). CI runs `pnpm db:test` and app tests.

Acceptance: one scripted run, with evidence (logs/screenshots), of the full journey; CI green.

## M8. Vault UI and storage `[ ]`

Private storage bucket, upload via family app, signed URLs issued only after `vault_list_documents`
authorization (audited). Consent screens per purpose with withdraw.

## M9. Payments (test mode) `[ ]`

Razorpay adapter in test mode only; plan/per-visit billing; fare pass-through per trip.
Activating live Razorpay needs founder authorization.

## M10. Production launch `[!]` gated

Blocked by: pilot go/no-go metrics, health-tech legal review, brand name, Supabase Mumbai project,
paid services authorization, breach runbook with a named owner, real-Supabase test run.
Not started without explicit founder approval.

## Backlog (from spec, unscheduled)

Requests ("I need..."), medicine refill reminders, live companion location during active trips,
H3 density views and cluster density gate in ops console, monthly bill view, family invites with
roles, trip data export for pilot metrics, deletion job for consent withdrawal.
