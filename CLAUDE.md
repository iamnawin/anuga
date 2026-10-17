# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Project:** Anuga (ZeroOrigins), codename `companion`; ANUGA wordmark, identifiers unchanged.

## Read first

Read [AGENTS.md](AGENTS.md), [docs/README.md](docs/README.md), current HANDOFF,
assigned task/spec and [working agreement](docs/delivery/WORKING_AGREEMENT.md).
AGENTS and that agreement own policy; architecture/command notes below supplement
them. M10/production remains separately gated (ADR 0001).

## Commands

Separate browser-local synthetic demo: [preview/README.md](preview/README.md).
Build with `node scripts/build-interactive-preview.mjs`, check with
`node --test preview/demo-core.test.mjs` and `node preview/verify-browser.mjs`.
Its isolated Vercel project must never be confused with the live `anuga` project.

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

## ANU-002 entry follow-up (2026-10-17)

Local entry and lifecycle implementation is complete and reviewed. Both Flutter roots and Ops
consume self-only my_account_access after OTP/restore, resume/focus, Auth/access
events and lifecycle-denied requests. Pending, disabled, unconfirmed, wrong role
and retry are distinct. Database RLS and RPC guards enforce current account state
even for old JWTs. Account activation never creates patients/grants/owner consent.
F1-F4 are provisional local assumptions, unapproved for rollout. Local Auth global
signup is disabled while email/SMS providers remain enabled for existing users.
See docs/evidence/anu002-lifecycle/README.md and ANU-002-VERIFY for actual checks,
remaining native/human acceptance. Latest review authorises the ANU-002-only
local commit; no push, merge, deploy or hosted changes.

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
  `0900` payments (invoices, fares, payment state; amounts in paise).
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

## Contribution rules

Use [the single working agreement](docs/delivery/WORKING_AGREEMENT.md), including
DB-enforced access, allowed/denied tests, coordinator-owned shared docs, isolated
worktrees and task-specific commit/publication authority. For prose-only changes,
run documentation checks and state app/database tests not run. Source/permission
changes retain all required app/DB checks. Never edit generated output manually.

## Combined local browser testing

The integration branch combines PR #2 and UI PRs #4-#7. Windows launcher:
`powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-local.ps1`.
Uses only public anon/publishable settings, loopback servers on ports 3100-3102,
separate role sessions and existing synthetic backend. Guide: docs/LOCAL_TESTING.md.
Database access rules, app RPCs and auth adapters are unchanged.

## Historical synthetic site publication (2026-10-11)

PR #8 main merge and combined anuga.vercel.app publication authorized in chat. Build via scripts/build-staging.sh, publish existing project prebuilt with pnpm dlx vercel@59.26.0. Manual deploy-anuga-test.yml supports future publishing; Git auto-deploy disabled to prevent ops-only replacement. Web storage and SDK auth broadcast channels isolated per Flutter app; native defaults, OTP/RPC/RLS rules unchanged. Commands and scope in SETUP; verification in HANDOFF. M10 still gated.

Current task/status is in HANDOFF and WORK_BOARD; historical publication commands
do not authorize a new deployment. Runtime/release receipts remain separately dated.

ANU-002 current local implementation: profiles lifecycle/version + owner-only
management + audit + restrictive RLS/definer guards; self resolver drives both
Flutter and Ops entry. Family-only access-level interpretation prevents clinical/
owner privilege from mismatched-role links. API lifecycle denial rechecks gates.
Global signup disabled in local config, existing email/SMS providers and Admin provisioning retained.
F1-F4 provisional, not rollout approval; docs/evidence/anu002-lifecycle holds actual
local results and ANU-002-VERIFY holds remaining native/human acceptance.
