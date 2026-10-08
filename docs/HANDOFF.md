# Handoff

Last updated: 2026-10-08 (session 1, local Windows machine)

## Current state

- Milestones **M0 (repo foundation)** and **M1 (database core, permissions, journey in SQL)** are done
  and verified. See `docs/TASKS.md`.
- The whole first journey works at the database layer: ops assigns primary/backup (or a single-trip
  backup) → family sees the booking → companion sets off, verifies the pickup OTP, reaches the
  centre and hands over → session done → return → dropped home → completed with a post-visit note.
  Every step writes a `trip_events` row and push + WhatsApp outbox rows for each family member.
- No app code yet (`apps/` and `packages/` do not exist). No commits yet: the repo is
  initialized on `main` with everything staged-ready but uncommitted.

## Decisions made this session

- ADR 0001: build the MVP now, in parallel with the manual pilot; production launch is gated (M10).
- ADR 0002: grants revoked by default; companions use a restricted, time-windowed projection;
  vault reads only through functions that audit in the same transaction; OTP stored as salted hash.
- ADR 0003: PGlite (Postgres 18 WASM + PostGIS) is the default test database; real Supabase local
  is the authoritative run, still pending.
- Ownership is a `patient_access` row with level `owner` (no `patients.owner_id`).
- Seed and tests share fixed synthetic ids (`supabase/seed/seed.sql`, `ids` in `supabase/tests/support/db.ts`).

## Completed work

- `.gitignore` (secrets, patient data/exports, `.remember/`, `.claude-flow/`, Supabase temp), `.env.example`.
- `docs/PRODUCT_SPEC.md` (requirements extracted from the old `CLAUDE.md`), `docs/TASKS.md`,
  `docs/SETUP.md`, this file, ADRs 0001-0003. `CLAUDE.md` rewritten to point at them; `AGENTS.md` added.
- `supabase/config.toml` via `supabase init` (project_id `companion`, seed path `./seed/seed.sql`).
- Migrations `supabase/migrations/20261008000100..0400_*.sql`, seed, tests (55), CI workflow
  `.github/workflows/db-tests.yml`.

## Checks run (exact commands, all on 2026-10-08)

| Command | Result |
| --- | --- |
| `pnpm install --frozen-lockfile` | pass |
| `pnpm typecheck` | pass (TypeScript 7.0.2) |
| `pnpm db:test` | **55/55 pass**, 11 suites, ~18 s test time (PGlite 0.5.8, Postgres 18.3, PostGIS) |
| `node --test --test-isolation=none supabase/tests/journey.test.ts` | 18/18 pass |
| `node --test ... --test-name-pattern="first journey"` / `"locks after"` | 15/15, 1/1 pass |
| Mutation check: added a SELECT leak on `vitals`; disabled the companion time window | 2 tests failed as expected; files restored |
| `pnpm dlx supabase@2.120.0 --version` | 2.120.0 |
| `flutter --version` (at `D:\AI-Workspace\tools\flutter`) | Flutter 3.47.6, Dart 3.13.5 |

## Checks NOT run (and why)

- `pnpm db:test:supabase` / `supabase start` / `supabase db reset`: no Docker on this machine;
  WSL Ubuntu has no Docker and no passwordless sudo. Migrations have only run on PGlite (PG 18),
  not Supabase's Postgres 17 with the real `auth` schema.
- GitHub Actions workflow: never executed (repo not pushed).
- `flutter doctor` / Android toolchain: not needed until M4; not checked.

## Blockers and risks

- **Push to GitHub needs the founder**: creating a private repo is an outward-facing action. Cloud
  sessions cannot start until the repo is on GitHub.
- PGlite vs Supabase differences may surface on first real run (PostGIS schema, `auth.users` columns,
  default privileges). Fix in a migration, not in the shim.
- Environment notes (machine, not repo): the `watch` plugin's missing `yt-dlp` was installed with
  `uv tool install yt-dlp`; the plugin still reports `needs_key` (optional Groq/OpenAI Whisper key,
  left unset on purpose). The `remember` plugin logs "promo skipped: unknown gate" (harmless plugin
  config parsing; not changed). MCP servers that failed to connect at session start (context7,
  playwright, chrome-devtools, github plugin "Authorization header is badly formatted", ruflo) were
  not used and not modified. The ruflo hook writes `.claude-flow/` into the current directory; it is git-ignored.

## Exact next task

**M2: `packages/shared_dart`** (see `docs/TASKS.md` M2 acceptance):

1. `flutter create --template=package packages/shared_dart` (or `dart create -t package`), add to repo.
2. Model `TripStatus` and the transition table; add a test that compares it with the SQL rows in
   `supabase/migrations/20261008000300_trip_workflow.sql` (write a small script that exports
   `select * from public.trip_transitions` from the PGlite harness to
   `packages/shared_dart/test/fixtures/trip_transitions.json`, and commit the fixture).
3. Typed wrappers for the M1 RPCs (`companion_my_trips`, `family_trip_board`, `advance_trip`,
   `verify_pickup_otp`, `issue_pickup_otp`, ops assignment), behind an interface with a fake for tests.
4. Run `dart analyze` and `dart test`; update `docs/TASKS.md` and this file.

Before M2, if the session has Docker: run the "Optional: real Supabase local" steps in `docs/SETUP.md`
and record the result here.

## Commit-ready checkpoint (run locally)

```sh
git status                      # expect only project files; no .env, .remember/, .claude-flow/, node_modules/
git add -A
git commit -m "feat: database core, permissions and first journey (M0, M1)"
```

## Continue in Claude Code cloud

1. Create a **private** GitHub repo and push (founder action):
   `gh repo create <owner>/companion --private --source . --remote origin --push`
2. In the cloud environment settings, use the setup command from `docs/SETUP.md`:
   `corepack enable && pnpm install --frozen-lockfile && pnpm db:test`
3. Start a cloud session on that repo with:
   > Read CLAUDE.md and docs/HANDOFF.md. Run `pnpm db:test` and record the result. If Docker is
   > available, run the real Supabase local checks from docs/SETUP.md first. Then do the exact next
   > task in docs/HANDOFF.md, run its acceptance checks, and update docs/TASKS.md and docs/HANDOFF.md.
   > Work on a feature branch; do not deploy or enable paid services.
