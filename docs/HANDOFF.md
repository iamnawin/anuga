# Handoff

Last updated: 2026-10-08 (session 2, Claude Code cloud, branch `claude/trusting-bell-4fgv07`)

## Current state

- Done and verified: **M0**, **M1**, **M1a** (real Supabase), **M2** (`packages/shared_dart`),
  **M3** (ops console, `apps/ops_console`), **M4** (companion app, `apps/companion_app`).
- Session 2 started from `9f21c73`. The earlier local M3 attempt was never pushed, so M3 was built
  from scratch here; nothing was duplicated.
- Repository: **https://github.com/iamnawin/anuga** (private). Work is on the branch above with a
  draft PR to `main` (not merged).

## Decisions made

- ADR 0001: build the MVP in parallel with the manual pilot; production launch gated (M10).
- ADR 0002: grants revoked by default; companions use a restricted, time-windowed projection;
  vault reads only through functions that audit in the same transaction; OTP stored as salted hash.
- ADR 0003: PGlite is the default test database; real Supabase (CI job `supabase-local`) is the
  authoritative run.
- M2: `shared_dart` has no Supabase SDK dependency; APIs take an injected `RpcCaller`.
- M3:
  - Ops reads go through ops-only RPCs (migration `0500`) instead of the console joining tables.
    Late threshold (`ops_late_after_minutes`, default 0 = "pickup time passed"), exception lookback
    and maximum board range are `app_settings` rows.
  - `ops_companion_options` lists every companion in the patient's cluster with distance and an
    ineligibility reason; a test proves it agrees with `ops_assign_trip_companion` for every
    companion. The console keeps ineligible companions selectable so the database's own error is shown.
  - Exception actions come from `trip_transitions` (actor `ops`, never `requires_otp`).
  - Console is client-side Next.js with the anon key + user JWT; no service-role key anywhere.
  - Phone OTP on Supabase local: seed `auth.users` rows are now in GoTrue's shape (phone stored
    without `+`, e.g. `919000000001`; `instance_id`, `aud`, non-null token columns and timestamps).
    Test OTP `123456` for the seed numbers only. Supabase Auth refuses phone sign-in without an
    enabled SMS provider, so `config.toml` enables Twilio with fake local placeholders.
  - The ops console uses TypeScript 6 (Next.js needs the TS JS API); root keeps TypeScript 7.
  - `@playwright/test` pinned to 1.56.1 = Chromium build 1194, preinstalled in cloud sessions.
- M4:
  - Companion buttons come from `TripStateMachine` (`lib/src/trip_actions.dart`), never a
    hand-written list; pickup is offered only as OTP verification.
  - Widgets depend on `PhoneAuth` and `CompanionApi`; Postgres errors are mapped to `RpcException`
    in one adapter (`lib/src/supabase_rpc.dart`) so no widget depends on the Supabase SDK.
  - Tests use an in-memory backend that enforces the shared state machine, OTP attempts and
    "not your trip"; a separate test runs the same API layer against Supabase local.
  - Generated localizations (`lib/l10n/generated/`) are not committed; `flutter pub get` creates them.
  - Debug builds allow cleartext only to 10.0.2.2/127.0.0.1/localhost; release stays HTTPS-only.
- Repo hosting: `iamnawin/anuga` is canonical. `iamnawin/companion` (old remote) is not updated;
  delete or archive only on founder request.

## Completed work (session 2)

- `supabase/migrations/20261008000500_ops_console.sql`, `supabase/tests/ops_console.test.ts`
  (15 tests: allowed/denied for each RPC, anon denial, settings-driven late flag, options/RPC agreement).
- `supabase/config.toml` (`[auth.sms]`), `supabase/seed/seed.sql` (GoTrue-shaped users),
  `supabase/tests/support/supabase_shim.sql` (matching columns).
- `apps/ops_console`: login (phone OTP, ops-role gate), `/trips`, `/schedules`, `/exceptions`;
  en/te/hi strings; Vitest unit + component tests; Playwright e2e; README.
- `pnpm-workspace.yaml` (`apps/*`); root scripts unchanged.
- CI (`.github/workflows/db-tests.yml`): new job `ops-console` (lint, typecheck, test, build);
  `supabase-local` now resets the DB after the SQL tests and runs the Playwright suite, uploading
  screenshots and the report as artifact `ops-console-e2e`.
- Screenshots: `docs/screenshots/m3/`.
- M4: `apps/companion_app` (login, trips list, trip screen, en/te/hi ARB, Android manifest),
  42 Flutter tests, README; CI job `companion-app` (format, analyze, test, debug APK build) and the
  Supabase-local companion journey in `supabase-local`.

## Checks run (2026-10-08, cloud session, Node 24.21.0 via nvm, Docker 29.8.2)

| Command | Result |
| --- | --- |
| `pnpm install --frozen-lockfile` | pass |
| `pnpm typecheck` (root) | pass |
| `pnpm db:test` (PGlite) | 75 tests: 72 pass, 0 fail, 3 skipped (real-Supabase-only) |
| `supabase db reset` + `pnpm db:test:supabase` (Supabase local in this session, CLI 2.120.0, Postgres 17) | **75/75 pass, 0 skipped** |
| Mutation: removed the ops guard from `ops_exception_queue` | "family and companions are denied" failed as expected; restored |
| Phone OTP via GoTrue REST | ops number + `123456` signs in; wrong code `otp_expired`; unknown number `Signups not allowed` |
| `apps/ops_console`: `pnpm lint`, `pnpm typecheck`, `pnpm build` | pass |
| `apps/ops_console`: `pnpm test` (Vitest) | 36/36 pass |
| `apps/ops_console`: `pnpm e2e` (Playwright vs Supabase local) | **6/6 pass**: non-ops account rejected; ops OTP sign-in + assign backup (persisted after reload); ineligible companion rejected with DB message; schedule primary/backup validation + swap; companion-reported issue appears in exception queue and ops resolves it; Telugu/Hindi switch |
| GitHub Actions run 37769970593 @ M3 commit (PR iamnawin/anuga#1) | all green: `db-tests`, `shared-dart`, `ops-console`, `supabase-local` (75/75 SQL + Playwright 6/6 on real Supabase) |
| Flutter 3.47.6 / Dart 3.13.5 (Linux archive, this session) | installed |
| `apps/companion_app`: `dart format` check, `flutter analyze --fatal-infos` | clean |
| `apps/companion_app`: `flutter test` | 41 pass, 1 skipped (Supabase-only) |
| Mutation: offer pickup without the OTP | 6 tests failed as expected; restored |
| `flutter test test/supabase_local_test.dart` vs Supabase local | pass: ops assigns backup, viewer denied OTP, owner issues it, wrong then right code, return legs, completion note, 8 ordered family notifications |

## Checks NOT run yet

- Telugu and Hindi strings have not been reviewed by a native speaker.
- Ops console on a hosted Supabase project: none exists (gated, M10).
- Private storage bucket policies and signed URLs: M8.
- Android SDK is not installed in the cloud session: `flutter build apk --debug` runs only in CI
  (`companion-app` job). No emulator or device run yet.

## Blockers and risks

- PGlite (Postgres 18) and Supabase (Postgres 17) agree today; `supabase-local` in CI is the authority.
- PGlite does not serialize JS arrays for enum-array parameters; tests pass array literals (`{a,b}`).
- Supabase Auth limits OTP requests per number (~5 s locally); the Playwright suite signs in once
  and reuses the saved session.
- `[auth.sms.test_otp]` and the fake Twilio values are local-only. A hosted project needs a real
  SMS provider (founder authorization; paid service) and must not get test OTPs.

## Exact next task

**M5: family app** (`docs/TASKS.md` M5): `apps/family_app` (Flutter) using `FamilyApi` from
`packages/shared_dart`: booking board (`family_trip_board`), trip timeline (`trip_events`), issue the
pickup OTP (owner/editor/patient only), cancel a scheduled trip, notification inbox
(`notifications`). Reuse the companion app's patterns (injected API/auth, `RpcException` adapter,
ARB en/te/hi, fake backend). Acceptance: as M4, plus a test that a viewer-level user cannot see
the OTP button; add a `family-app` CI job.

## Continue in Claude Code cloud

Setup command for the cloud environment:

```sh
. /opt/nvm/nvm.sh && nvm install 24 && corepack enable && pnpm install --frozen-lockfile && pnpm db:test
```

For Supabase local in a cloud session: `nohup dockerd &` (as root), then `docs/SETUP.md` Path B.
