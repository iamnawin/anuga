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

## Flutter / Dart (M2 onward)

| Tool | Verified version | Check | Install |
| --- | --- | --- | --- |
| Flutter (stable) | 3.47.6, Dart 3.13.5 | `flutter --version` | Windows (no admin): `git clone --depth 1 -b stable https://github.com/flutter/flutter.git D:\AI-Workspace\tools\flutter` |
| Android SDK / Studio | not installed | `flutter doctor` | Needed only to run apps on a device/emulator (M4+), not for `dart test` |

Configured on this machine (2026-10-08, user scope, reversible): `D:\AI-Workspace\tools\flutter\bin`
appended to the user `Path`, and `PUB_CACHE=D:\AI-Workspace\tools\pub-cache`. Open a new terminal
for them to take effect. Analytics disabled (`flutter --disable-analytics`, `dart --disable-analytics`).

```sh
cd packages/shared_dart
dart pub get
dart format --output=none --set-exit-if-changed lib test
dart analyze --fatal-infos
dart test                                     # 16 tests
dart test test/trip_state_machine_test.dart   # one file
dart test --name "wrong OTP"                  # one test
```

## Ops console (M3 onward)

`apps/ops_console` is a pnpm workspace package (`pnpm-workspace.yaml`); the root
`pnpm install --frozen-lockfile` installs it. It uses TypeScript 6 (Next.js type-checks through the
TypeScript JS API, which TypeScript 7 no longer ships); the root test harness keeps TypeScript 7.

```sh
cd apps/ops_console
pnpm lint && pnpm typecheck && pnpm test && pnpm build
pnpm e2e    # needs Supabase local (below) and apps/ops_console/.env.local
```

`.env.local` (git-ignored) takes `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` from
`supabase status -o env` (`API_URL`, `ANON_KEY`). Local sign-in: phone `9000000001` (ops),
code `123456`. Test OTPs exist only in `supabase/config.toml` for the synthetic seed numbers; never
configure them on a hosted project. Supabase Auth refuses phone sign-in unless an SMS provider is
enabled, so the local config enables Twilio with fake placeholder values; test numbers never reach it.

## Real Supabase verification (Docker)

**Status: passing** (GitHub Actions run 37748137710, 60/60, 0 skipped). PGlite results alone do not count; keep `supabase-local` green.

Covers: migrations on Postgres 17 with Supabase's real `auth` schema and roles; every RLS/grant
test; audited vault reads; `auth.uid()` from request JWT claims; no public storage buckets
(`supabase/tests/platform.test.ts`, skipped on PGlite); real phone-OTP sign-in through Supabase
Auth (ops console Playwright suite, M3). Private-bucket signed URLs arrive with M8.

**Path A, GitHub Actions (no local Docker needed):** job `supabase-local` in
`.github/workflows/db-tests.yml` runs on every push to `main` and every PR:
`supabase start -x studio,edge-runtime,logflare,vector,imgproxy`, then `supabase db reset`, then
`pnpm db:test:supabase` with `DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres`,
then `supabase db reset` again and the ops console Playwright suite.

**Path B, any machine or cloud session with Docker:**

```sh
pnpm dlx supabase@2.120.0 start
pnpm dlx supabase@2.120.0 db reset          # migrations + supabase/seed/seed.sql
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres pnpm db:test:supabase
pnpm dlx supabase@2.120.0 stop --no-backup
```

Tests commit data; run `db reset` before each run against the same local stack.

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

Verified in a cloud session on 2026-10-08: the image had Node 22 (too old for
`--test-isolation`), so Node 24 was installed with nvm (`. /opt/nvm/nvm.sh && nvm install 24`).
The Docker CLI was present but the daemon was not running; `dockerd` started as root
(`nohup dockerd &`), images pulled through the proxy, and Path B below ran end to end
(Supabase local, phone OTP, Playwright with the preinstalled Chromium). Flutter is not
preinstalled; the 3.47.6 Linux archive downloads from `storage.googleapis.com`.
