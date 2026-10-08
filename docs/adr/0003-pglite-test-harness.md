# ADR 0003: PGlite harness for database tests, real Supabase as the authoritative run

- Status: accepted
- Date: 2026-10-08

## Context

The founder's Windows machine has no Docker and no Postgres, and installing them needs admin
rights. Supabase local (`supabase start`) requires Docker. Every RLS rule still needs allowed
and denied tests that run on every change.

## Decision

Tests are plain SQL driven from Node's built-in test runner (`supabase/tests/*.test.ts`).
By default they run against PGlite (Postgres 18 compiled to WASM, with PostGIS), loaded with
`supabase/tests/support/supabase_shim.sql` (auth schema, API roles, Supabase default grants),
all migrations, and the synthetic seed. With `DATABASE_URL` set, the same tests run against a
real database prepared by `supabase db reset`.

## Consequences

- `pnpm db:test` runs anywhere Node 24 runs, including CI and cloud sessions without Docker.
- PGlite is Postgres 18; hosted Supabase is Postgres 17. The shim only approximates Supabase's
  auth schema. A run against real Supabase local is required before production launch.
- The shim mirrors Supabase's default grants so the migrations' revokes are actually exercised.
