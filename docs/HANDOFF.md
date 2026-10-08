# Handoff

Last updated: 2026-10-08 (session 1, local Windows machine)

## Current state

- Done and verified: **M0** (repo foundation), **M1** (database core, permissions, journey in SQL),
  **M2** (`packages/shared_dart`: models, trip state machine, RPC client, SQL/Dart contract tests).
- **M1a, real Supabase verification: PENDING.** The CI job `supabase-local` is prepared; the result
  of its first run is recorded under "Checks run" below once observed.
- No app code yet (`apps/` does not exist).
- Repository: **https://github.com/iamnawin/anuga** (private), branch `main`. Remote `origin`.

## Decisions made

- ADR 0001: build the MVP in parallel with the manual pilot; production launch gated (M10).
- ADR 0002: grants revoked by default; companions use a restricted, time-windowed projection;
  vault reads only through functions that audit in the same transaction; OTP stored as salted hash.
- ADR 0003: PGlite is the default test database; real Supabase is the authoritative run (M1a).
- M2: `shared_dart` has no Supabase SDK dependency; APIs take an injected `RpcCaller`.
  The Dart state machine is built from rules (not copied) and tested against `trip_contract.json`,
  which `pnpm contract:export` generates from SQL and `pnpm db:test` guards.
- Repo hosting: `iamnawin/anuga` is the canonical repo (founder instruction). An earlier push went to
  `iamnawin/companion` (private, same M0/M1 commit); it is kept as remote `companion` and is not
  updated further. Delete or archive it only on founder request.

## Completed work

- M0/M1: see `docs/TASKS.md`; migrations `supabase/migrations/20261008000100..0400_*.sql`, seed, tests.
- M2: `packages/shared_dart/` (lib, 16 tests, README), `supabase/scripts/export-trip-contract.ts`,
  `supabase/tests/contract.test.ts`, `supabase/tests/support/contract.ts`.
- Real-Supabase path: `supabase/tests/platform.test.ts` (storage privacy, real `auth.uid()`, anon
  denial), CI job `supabase-local`, `docs/SETUP.md` section "Real Supabase verification".
- CI: `.github/workflows/db-tests.yml` (workflow name `checks`): `db-tests`, `shared-dart`,
  `supabase-local`; actions bumped to v5 (the v4 Node 20 deprecation warning).
- Flutter 3.47.6 configured: user PATH + `PUB_CACHE=D:\AI-Workspace\tools\pub-cache`.

## Checks run (2026-10-08)

| Command | Result |
| --- | --- |
| `pnpm typecheck` | pass |
| `pnpm db:test` (PGlite) | 57 pass, 0 fail, 3 skipped (real-Supabase-only checks) |
| `dart format --output=none --set-exit-if-changed lib test` | pass |
| `dart analyze --fatal-infos` | no issues |
| `dart test` | 16/16 pass |
| Mutation: removed the family-cancel rule from Dart | agreement test failed as expected; restored |
| GitHub Actions on `iamnawin/companion` @ `aa37cc8` (M0/M1) | `db-tests` passed, 55/55 |

## Checks NOT run yet

- **M1a real Supabase run**: not run locally (no Docker on this machine). First attempt is the
  `supabase-local` CI job on the push of this commit.
- Android toolchain / `flutter doctor`: not needed until M4.

## Blockers and risks

- PGlite (Postgres 18) vs Supabase (Postgres 17) differences may surface in `supabase-local`.
  Fix in a new migration, never in the shim.
- Machine notes (not repo): `yt-dlp` installed for the `watch` plugin (still wants an optional
  Whisper key); some MCP servers failed to connect at session start and were not used; the ruflo
  hook writes `.claude-flow/` into the current directory (git-ignored).

## Exact next task

1. **Finish M1a**: open the latest `checks` run on `main`
   (`gh run list --repo iamnawin/anuga --workflow checks --limit 1`). If `supabase-local` failed,
   fix the cause with a new migration or harness change, re-run, and record the result here.
2. Then **M3: ops console** (`docs/TASKS.md` M3): scaffold `apps/ops_console` with Next.js +
   TypeScript (pnpm workspace), phone-OTP login against Supabase local using
   `[auth.sms.test_otp]` with synthetic numbers (no SMS provider), schedules list with
   primary/backup assignment, trips board, reassign a scheduled trip, exception queue.
   Acceptance: lint + typecheck + unit tests; one browser test of "assign backup to a trip".

## Continue in Claude Code cloud

Repository: `https://github.com/iamnawin/anuga` (private). Environment setup command:

```sh
corepack enable && pnpm install --frozen-lockfile && pnpm db:test
```

Prompt:

> Read CLAUDE.md and docs/HANDOFF.md. Run `pnpm db:test` and record the result. Check whether
> Docker is available (`docker --version`); if it is, run the "Real Supabase verification" Path B
> from docs/SETUP.md, otherwise read the latest `supabase-local` job result from GitHub Actions.
> Complete M1a if it is not done, then implement M3 (ops console) per docs/TASKS.md on a feature
> branch, run its acceptance checks, and update docs/TASKS.md and docs/HANDOFF.md with results and
> checks that could not run. Synthetic data and test adapters only; no paid services, production
> credentials or deployments.
