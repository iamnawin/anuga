# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Project:** Dialysis Companion App (ZeroOrigins), codename `companion` (brand name not final).

## Read first

1. `docs/HANDOFF.md`: current state, last checks run, blockers and the **exact next task**.
2. `docs/PRODUCT_SPEC.md`: product requirements, roles, scope limits, data model and access rules.
3. `docs/TASKS.md`: milestones with acceptance criteria. Work one milestone at a time.
4. `Pilot BRD.md`: business case for the manual pilot. `docs/adr/`: decisions that changed the spec.

Founder decision (ADR 0001): build the MVP now, in parallel with the manual pilot. Production
launch is a separate, gated milestone (M10).

## Commands

```sh
pnpm install --frozen-lockfile
pnpm db:test            # all DB tests on PGlite + PostGIS (no Docker), ~30 s
pnpm typecheck          # tsc over supabase/tests
node --test --test-isolation=none supabase/tests/vault.test.ts                                   # one file
node --test --test-isolation=none --test-name-pattern="locks after" "supabase/tests/*.test.ts"    # one test
pnpm db:test:supabase   # same tests against real Supabase local (needs Docker + DATABASE_URL in .env)
```

`--test-isolation=none` is required: all files share one in-process database. The `first journey`
suite is sequential; filter it by suite name, not by step. Tool versions and Flutter/Supabase local
setup: `docs/SETUP.md`. Flutter is installed at `D:\AI-Workspace\tools\flutter` (not on PATH).

## Architecture

Monorepo. Built so far: `supabase/` only. Planned: `apps/family_app`, `apps/companion_app` (Flutter),
`apps/ops_console` (Next.js), `packages/shared_dart`, `supabase/functions` (Edge Functions).

The database is the security boundary; apps are thin clients over RPCs:

- **Migrations** (`supabase/migrations/`, applied in filename order):
  `0100` core schema, `0200` grants + RLS + `private.*` helpers, `0300` trip workflow RPCs,
  `0400` vault with audited reads.
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
- **Business values** (prices, radius, windows, OTP limits) live in `packages`, `clusters` and
  `app_settings`, never in code.

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
