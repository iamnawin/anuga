# Handoff

Last updated: 2026-10-08 (session 1, local Windows machine)

## Current state

- Done and verified: **M0** (repo foundation), **M1** (database core, permissions, journey in SQL),
  **M2** (`packages/shared_dart`: models, trip state machine, RPC client, SQL/Dart contract tests).
- **M1a, real Supabase verification: done.** CI job `supabase-local` applied all migrations and the
  seed on Supabase local (CLI 2.120.0, Postgres 17) and passed 60/60 tests, 0 skipped.
- No app code yet (`apps/` does not exist).
- Repository: **https://github.com/iamnawin/anuga** (private), branch `main`. Remote `origin`.

## Decisions made

- ADR 0001: build the MVP in parallel with the manual pilot; production launch gated (M10).
- ADR 0002: grants revoked by default; companions use a restricted, time-windowed projection;
  vault reads only through functions that audit in the same transaction; OTP stored as salted hash.
- ADR 0003: PGlite is the default test database; real Supabase (CI job `supabase-local`) is the
  authoritative run and now passes.
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
| Actions `iamnawin/anuga` run 37745321667 @ `c1468fe` | `db-tests`, `supabase-local` failed: `setup-node@v5` auto-cache looked for pnpm before `corepack enable`. Fixed in `39913c0` (`package-manager-cache: false`) |
| Actions run 37745477238 @ `39913c0` | `db-tests`, `shared-dart` pass; `supabase-local`: migrations + seed applied, all 60 tests passed, then the step hung (open `pg` connection kept `node --test` alive); run cancelled. Reproduced locally; fixed in `487d409` (`--test-force-exit`, `--test-timeout`, job `timeout-minutes: 20`) |
| **Actions run 37748137710 @ `487d409`** | **all green**: `db-tests` 57 pass / 3 skipped (PGlite); `shared-dart` pass; **`supabase-local` 60/60 pass, 0 skipped (real Supabase)** |

## Checks NOT run yet

- Real Supabase locally: no Docker on this machine; verified in CI instead (above).
- Real phone-OTP sign-in via Supabase Auth and private storage bucket policies: not built yet (M3, M8).
- Android toolchain / `flutter doctor`: not needed until M4.

## Blockers and risks

- PGlite (Postgres 18) and Supabase (Postgres 17) agree today; if they diverge, fix in a new
  migration, never in the shim. `supabase-local` in CI is the authority.
- Machine notes (not repo): `yt-dlp` installed for the `watch` plugin (still wants an optional
  Whisper key); some MCP servers failed to connect at session start and were not used; the ruflo
  hook writes `.claude-flow/` into the current directory (git-ignored).

## Exact next task

**M3: ops console** (`docs/TASKS.md` M3), on a feature branch:

1. Scaffold `apps/ops_console` with Next.js + TypeScript as a pnpm workspace package
   (add `pnpm-workspace.yaml`); keep the root `db:test` scripts working.
2. Enable phone-OTP sign-in for Supabase local only: `[auth.sms] enable_signup = true` and
   `[auth.sms.test_otp]` with the synthetic seed numbers (`+919000000001` ops, etc.); no SMS provider.
3. Screens: schedules list with primary/backup assignment (`ops_assign_schedule_companions`,
   showing database eligibility errors), trips board by date/status, reassign a scheduled trip
   (`ops_assign_trip_companion`), exception queue (`issue_reported`, `no_show`, late).
4. Acceptance: lint + typecheck + unit tests; one browser test of "assign backup to a trip" against
   Supabase local (add it to the `supabase-local` CI job); update `docs/TASKS.md` and this file.

## Continue in Claude Code cloud

Repository: `https://github.com/iamnawin/anuga` (private). Environment setup command:

```sh
corepack enable && pnpm install --frozen-lockfile && pnpm db:test
```

Prompt:

> Read CLAUDE.md and docs/HANDOFF.md. Run `pnpm db:test` and record the result. Then do the
> "Exact next task" in docs/HANDOFF.md (M3, ops console) on a feature branch named `m3-ops-console`.
> If Docker is available (`docker --version`), use docs/SETUP.md "Real Supabase verification"
> Path B for local checks; otherwise rely on the `supabase-local` GitHub Actions job. Run the M3
> acceptance checks, open a pull request to `main` (do not merge), and update docs/TASKS.md and
> docs/HANDOFF.md with results and any checks that could not run. Synthetic data and test adapters
> only; no paid services, production credentials or deployments.
