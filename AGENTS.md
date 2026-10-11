# AGENTS.md

Instructions for any coding agent (Codex, Gemini, Claude Code, others) working in this repository.
Claude Code also reads `CLAUDE.md`, which has the same rules plus architecture notes.

## Read first

1. `docs/HANDOFF.md`: current state and the exact next task.
2. `docs/PRODUCT_SPEC.md`: shared product requirements, scope limits, data model and access rules.
3. `docs/TASKS.md`: milestones and acceptance criteria.
4. `docs/SETUP.md`: verified tool versions and setup commands.

## Commands

```sh
pnpm install --frozen-lockfile
pnpm db:test       # database tests (PGlite + PostGIS, no Docker)
pnpm typecheck
scripts/check-all.sh   # every fast CI check in one go (run before pushing)
cd apps/ops_console && pnpm lint && pnpm typecheck && pnpm test   # ops console
cd apps/companion_app && flutter pub get && flutter analyze --fatal-infos && flutter test   # companion app
cd apps/family_app && flutter pub get && flutter analyze --fatal-infos && flutter test      # family app
```

## Non-negotiables

- Patient permissions are enforced in the database (grants, RLS, restricted functions). Never move
  an access check into app code only.
- Companions never see vault data, diagnoses or date of birth. Vault reads only via audited functions.
- No emergencies, no clinical tasks, no medicine sales (see spec section 1).
- Synthetic data only. No production credentials, paid services or public deploys without founder authorization.
- Every access rule has allowed and denied tests. Update `docs/TASKS.md` and `docs/HANDOFF.md` after each milestone.
- Package managers: pnpm for Node, uv for Python.

## Status (2026-10-11)

- Done on `main` (PR #1): M0-M9. Database + RLS, `shared_dart`, ops console (Next.js), companion and
  family apps (Flutter, en/te/hi), notification dispatch, end-to-end journey, vault storage,
  test-mode payments. M10 (production) is gated on founder approval.
- PR #2 (green, not merged): hosted staging. Supabase project `anuga` (synthetic) + one Vercel
  preview with `/ops/`, `/family/`, `/companion/`. Founder dashboard steps in `docs/SETUP.md`.
- PR #3 / branch `m3-ops-console`: obsolete duplicate of M3. Do not build on it.
- Next: UI to match the founder's sketches in `docs/design/`. Details: `docs/HANDOFF.md`, "Exact next task".
- Before starting: `git fetch` and read `origin/main:docs/HANDOFF.md`; a stale local `main` caused PR #3.

## Parallel work

Agents may run in parallel only on these streams, each on its own branch from `main` and its own PR.
One writer per path; if a stream needs a file another stream owns, stop and note it in the PR.

| Stream | Owns (writes only here) | Depends on |
| --- | --- | --- |
| S1 Staging deploy | `.github/workflows/deploy-staging.yml`, `scripts/build-staging.sh`, `scripts/staging-smoke.ts` | founder secrets |
| S2 Design tokens | `docs/design/tokens.md` (colours, type scale, spacing, tap sizes from the sketches) | sketches |
| S3 Ops console UI | `apps/ops_console/src/app/**`, `apps/ops_console/src/components/**` (not `src/lib/`) | S2 |
| S4 Companion app UI | `apps/companion_app/lib/` widgets/screens and l10n (not `supabase_rpc.dart`, `auth.dart`) | S2 |
| S5 Family app UI | `apps/family_app/lib/` widgets/screens and l10n (not `supabase_rpc.dart`, `auth.dart`) | S2 |
| S6 Backend backlog | `supabase/migrations/` (new files only), `supabase/tests/`, `packages/shared_dart/` | none |

- UI streams (S3-S5) are UI-only: no RPC, auth, access-rule or data-flow changes. Keep tap targets
  large, high contrast, and add te/hi strings for every new en string.
- Only S6 adds migrations, one at a time; after a SQL change run `pnpm contract:export` and both suites.
- Each stream runs `scripts/check-all.sh` (plus its app's tests) before opening a PR and updates
  `docs/HANDOFF.md` with what it ran and what it could not run.
