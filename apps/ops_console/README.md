# Ops console (`@companion/ops_console`)

Next.js (App Router, TypeScript) web console for the ZeroOrigins ops team. A thin client over
the database RPCs in `supabase/migrations/20261008000500_ops_console.sql` and `..0300_trip_workflow.sql`;
every permission is enforced in Postgres, not here.

Screens:

- **Trips** (`/trips`): board by India-time date range and status, late flag, one-tap "assign
  backup", reassign to any companion in the cluster (`ops_trip_board`, `ops_assign_trip_companion`).
- **Schedules** (`/schedules`): weekly patterns with primary/backup assignment
  (`ops_schedule_board`, `ops_assign_schedule_companions`).
- **Exceptions** (`/exceptions`): late, `no_show`, `issue_reported` (`ops_exception_queue`);
  resolve actions come from `trip_transitions` (actor `ops`), never the OTP step.

Companion pickers list every companion in the patient's cluster with distance and eligibility
(`ops_companion_options`); ineligible ones stay selectable so the database's own rejection is shown.

Sign-in is phone OTP through Supabase Auth. On Supabase local the synthetic numbers use code
`123456` (`supabase/config.toml`, `[auth.sms.test_otp]`); ops is `9000000001`. Non-ops accounts
are signed out with a message.

UI strings: `src/lib/messages.ts` (English, Telugu, Hindi; Telugu/Hindi need native review).

## Run locally

```sh
pnpm dlx supabase@2.120.0 start      # from the repo root; needs Docker
cp apps/ops_console/.env.example apps/ops_console/.env.local   # fill ANON_KEY from `supabase status -o env`
pnpm --filter @companion/ops_console dev                       # http://127.0.0.1:3000
```

## Checks

```sh
cd apps/ops_console
pnpm lint && pnpm typecheck && pnpm test     # ESLint, tsc (after next typegen), Vitest
pnpm build
pnpm e2e        # Playwright against Supabase local; run `supabase db reset` first (tests commit data)
```

`pnpm e2e` writes screenshots to `test-results/screenshots` (override with `SCREENSHOT_DIR`).
`@playwright/test` is pinned to 1.56.1, which matches the Chromium preinstalled in Claude Code
cloud sessions; CI installs the same browser build.
