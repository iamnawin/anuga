# Environment setup

Versions below were verified on the founder's Windows 11 machine on 2026-10-08.
Re-verify with the "check" command in each row before relying on them.

## Required now (milestone M1: database)

| Tool | Verified version | Check | Install |
| --- | --- | --- | --- |
| Node.js | 24.14.0 | `node --version` | https://nodejs.org (LTS 24.x) |
| pnpm | 10.33.0 | `pnpm --version` | `corepack enable` then `corepack prepare pnpm@10.33.0 --activate` |
| Git | 2.49.0 | `git --version` | https://git-scm.com |

```sh
pnpm install --frozen-lockfile
pnpm db:test      # PGlite + PostGIS in-process; no Docker needed (~30 s, mostly PostGIS load)
pnpm typecheck    # TypeScript 7 (tsc) over the test harness
```

Run one test file: `node --test --test-isolation=none supabase/tests/journey.test.ts`
Run one test by name: `node --test --test-isolation=none --test-name-pattern="locks after" "supabase/tests/*.test.ts"`

The `first journey` suite is a sequence of dependent steps; filter it by its suite name
(`--test-name-pattern="first journey"`), not by an individual step name.

`--test-isolation=none` makes all test files share one in-process database (PostGIS takes ~15 s
to load). Tests create their own trips; they do not depend on run order across files.

## Required from milestone M3/M4 (apps)

| Tool | Verified version | Check | Install |
| --- | --- | --- | --- |
| Flutter (stable) | 3.47.6, Dart 3.13.5 | `flutter --version` | Windows (no admin): `git clone --depth 1 -b stable https://github.com/flutter/flutter.git D:\AI-Workspace\tools\flutter` and add `D:\AI-Workspace\tools\flutter\bin` to PATH |
| Android SDK / Studio | not installed | `flutter doctor` | Needed only to run on a device/emulator, not for `flutter test` |

On this machine Flutter lives at `D:\AI-Workspace\tools\flutter` and is **not yet on PATH**.
Set `PUB_CACHE=D:\AI-Workspace\tools\pub-cache` to keep the package cache off `C:\Users`.

## Optional: real Supabase local (authoritative database run)

Needs Docker (Docker Desktop on Windows, or Docker Engine on Linux/cloud). Not installed on
the founder's machine; WSL Ubuntu exists but has no Docker and no passwordless sudo.

```sh
pnpm dlx supabase@2.120.0 start          # pulls Postgres 17 + Supabase services (Docker)
pnpm dlx supabase@2.120.0 db reset       # applies supabase/migrations + supabase/seed/seed.sql
cp .env.example .env                    # set DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres
pnpm db:test:supabase                   # same tests against real Supabase
```

Supabase CLI 2.120.0 was verified via `pnpm dlx` (`supabase --version`); `supabase init` generated
`supabase/config.toml`. `supabase start` has **not** been run anywhere yet.

## Secrets and data

- Copy `.env.example` to `.env` for local values. `.env` is git-ignored.
- External integrations default to `test` adapters. Live providers (WhatsApp, FCM, Razorpay, Maps),
  paid tiers, production credentials and public deploys need separate founder authorization.
- Synthetic data only. `supabase/seed/seed.sql` documents its fixed ids.

## Claude Code cloud sessions

Cloud sessions clone the GitHub repo, so the repo must be pushed first (see `docs/HANDOFF.md`).
Setup command for the cloud environment:

```sh
corepack enable && pnpm install --frozen-lockfile && pnpm db:test
```

Do not assume Docker or Flutter exist in the cloud image; check with `docker --version` and
`flutter --version` and record the result in `docs/HANDOFF.md`.
