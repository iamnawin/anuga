# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Project:** AnugaCare, dialysis companion service (ZeroOrigins), codename `companion` (ADR 0006).

## Read first

1. `docs/HANDOFF.md`: current state, last checks run, blockers and the **exact next task**.
2. `docs/PRODUCT_SPEC.md`: product requirements, roles, scope limits, data model and access rules.
3. `docs/TASKS.md`: milestones with acceptance criteria. Work one milestone at a time.
4. `Pilot BRD.md`: business case for the manual pilot. `docs/adr/`: decisions that changed the spec.
5. `docs/ARCHITECTURE.md`: what is built, how the parts connect, flows, integration status, how to test.

Founder decision (ADR 0001): build the MVP now, in parallel with the manual pilot. Production
launch is a separate, gated milestone (M10).

## Commands

```sh
pnpm install --frozen-lockfile
pnpm db:test            # all DB tests on PGlite + PostGIS (no Docker), ~30 s
pnpm typecheck          # tsc over supabase/tests
node --test --test-isolation=none supabase/tests/vault.test.ts                                   # one file
node --test --test-isolation=none --test-name-pattern="locks after" "supabase/tests/*.test.ts"    # one test
pnpm db:test:supabase   # same tests against real Supabase local (needs Docker + DATABASE_URL)
pnpm contract:export    # regenerate packages/shared_dart/test/fixtures/trip_contract.json from SQL
scripts/e2e-journey.sh  # M7 journey across apps on Supabase local (see docs/SETUP.md)
scripts/check-all.sh    # every fast CI check (no Docker): run before each push

# packages/shared_dart (run inside that folder)
dart pub get && dart analyze --fatal-infos && dart test
dart test test/trip_state_machine_test.dart          # one file
dart test --name "wrong OTP"                          # one test

# apps/companion_app or apps/family_app (run inside that folder)
flutter pub get && flutter analyze --fatal-infos && flutter test

# apps/ops_console (run inside that folder)
pnpm lint && pnpm typecheck && pnpm test && pnpm build
pnpm e2e                                              # Playwright vs Supabase local; db reset first
```

`--test-isolation=none` is required: all files share one in-process database. The `first journey`
suite is sequential; filter it by suite name, not by step. Tool versions and Flutter/Supabase local
setup: `docs/SETUP.md`. Flutter 3.47.6 / Dart 3.13.5 is at `D:\AI-Workspace\tools\flutter\bin`
(on the user PATH; open a new terminal) with `PUB_CACHE=D:\AI-Workspace\tools\pub-cache`.

## Architecture

Monorepo (pnpm workspace: `apps/*`). Built so far: `supabase/`, `packages/shared_dart`,
`apps/ops_console` (Next.js), `apps/companion_app` and `apps/family_app` (Flutter).
`supabase/functions/notify-dispatch` (notification outbox), `vault-files` (signed URLs for the
private vault bucket), `payments` + `payments-webhook` (test-mode payments; shared code in `_shared/`).

The database is the security boundary; apps are thin clients over RPCs:

- **Migrations** (`supabase/migrations/`, applied in filename order):
  `0100` core schema, `0200` grants + RLS + `private.*` helpers, `0300` trip workflow RPCs,
  `0400` vault with audited reads, `0500` ops console read RPCs (`ops_*_board`, exception queue,
  companion options), `0600` family read RPCs (patients with access level, timeline, inbox),
  `0700` notification dispatch (service-role claim/mark RPCs, `notification_deliveries`),
  `0800` vault storage (private bucket, server-generated paths, signed-URL RPCs) and consents,
  `0900` payments (invoices, fares, payment state; amounts in paise),
  `20261022000100` trip controls (training/suspension, companion start window, required notes,
  companion trip reads limited to the detail window), `20261027000100` `start_allowed_at` in
  `companion_my_trips()`, `20261027000200` `ops_create_schedule_trips()` (per-date created/skipped
  result behind the ops "Create trips" button; `ops_generate_trips` counts its created rows).
- **Demo data** for the hosted synthetic project: `supabase/seed/demo_refresh.sql` (run in the
  dashboard SQL editor; refuses non-synthetic patients or accounts). See SETUP → Hosted staging.
- **Grants are revoked by default.** Supabase normally grants every public table to API roles;
  migration `0200` revokes that. Any new table needs explicit grants and RLS policies in its migration.
- **`private` schema** holds `security definer` helpers (`is_ops`, `can_view_patient`,
  `access_level_for`, `apply_transition`, ...). All definer functions use `set search_path = ''`
  and fully qualified names (`public.`, `extensions.` for PostGIS, `auth.`).
- **Trip state machine is data**: `public.trip_transitions` (from, to, actor, requires_otp).
  `advance_trip()` derives the actor (companion on the trip, ops, family editor) and checks this
  table; `picked_up` is reachable only through `verify_pickup_otp()`. `apply_transition()` updates
  the trip, appends `trip_events` and writes family notifications to the `notifications` outbox.
- **Companions** never read `patients`; they use `companion_my_trips()` (restricted fields, time window
  from `app_settings`). **Vault** tables have no SELECT grant; reads go through `vault_list_*()`,
  which audit in the same transaction (SELECT cannot fire triggers). See ADR 0002.
- **Trusted backend**: `private.is_trusted_backend()` lets the seed / service role call ops RPCs
  without a user JWT.
- **Tests** (`supabase/tests/`): `support/db.ts` boots PGlite with `support/supabase_shim.sql`
  (auth schema, API roles, Supabase default grants), all migrations and `supabase/seed/seed.sql`.
  `asUser` commits like a real request; `probeAsUser` rolls back. Seed ids are in `ids`.
- **SQL/Dart contract**: `TripStateMachine` in `packages/shared_dart` rebuilds the transitions from
  the same rules as the migration. Both sides are tested against the committed
  `trip_contract.json`; change SQL, run `pnpm contract:export`, update Dart, run both suites.
- **Dart API layer** takes an injected `RpcCaller` (apps pass `supabase.rpc`), so the package has no SDK dependency.
- **Business values** (prices, radius, windows, OTP limits, late threshold) live in `packages`,
  `clusters` and `app_settings`, never in code.
- **Auth**: phone OTP. Seed `auth.users` rows are shaped for GoTrue (phone without `+`, non-null
  token columns); `supabase/config.toml` has local-only test OTPs (`123456`) for the seed numbers.
- **Flutter apps** take `CompanionApi`/`FamilyApi` + a `PhoneAuth` by injection; buttons come from
  `TripStateMachine`; Postgres errors become `RpcException` in `lib/src/supabase_rpc.dart` only.
- **Notifications**: `apply_transition()` writes the outbox; `notify-dispatch` drains it with
  the service role. Adapters default to `test`; live providers are gated and not implemented.
- **Vault files**: no storage policies for app roles. `vault-files` asks the database as the caller,
  then signs URLs with the service role. Vault writes need the owner's `vault` consent.
- **Ops console** is a client-side Next.js app using the anon key + the user's JWT; it never holds
  a service-role key. RPC wrappers in `src/lib/api.ts` take an injectable client for tests.

## Rules for this repo

- Every access rule gets an allowed and a denied test. Run `pnpm db:test` before declaring a change done.
- After each milestone, update `docs/TASKS.md` and `docs/HANDOFF.md` (including checks that could not run).
- Synthetic data only; never real patient data, production credentials, paid services or public
  deploys without separate founder authorization. External integrations use `test` adapters.
- Ask before adding any third-party SDK that receives patient data, or anything clinical.
- Write an ADR in `docs/adr/` for any decision that changes `docs/PRODUCT_SPEC.md`.
- UI: large tap targets, high contrast, English + Telugu + Hindi from day one; many users are elderly.
- Feature branches and small commits; `main` stays releasable.
- `.claude/` contains a spec workflow (kfc): specs in `.claude/specs/<feature>/`, steering in `.claude/steering/`.

## Combined local browser testing

The integration branch combines PR #2 and UI PRs #4-#7. Windows launcher:
`powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-local.ps1`.
Uses only public anon/publishable settings, loopback servers on ports 3100-3102,
separate role sessions and existing synthetic backend. Guide: docs/LOCAL_TESTING.md.
Database access rules, app RPCs and auth adapters are unchanged.

## Founder-authorized synthetic site publication

PR #8 main merge and combined anuga.vercel.app publication authorized in chat. Build via scripts/build-staging.sh, publish existing project prebuilt with pnpm dlx vercel@59.26.0. Manual deploy-anuga-test.yml supports future publishing; Git auto-deploy disabled to prevent ops-only replacement. Web storage and SDK auth broadcast channels isolated per Flutter app; native defaults, OTP/RPC/RLS rules unchanged. Commands and scope in SETUP; verification in HANDOFF. M10 still gated.
