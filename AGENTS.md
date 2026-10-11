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

## Status (2026-10-11, design streams)

- M0-M9 are merged on main through PR #1. M10 remains gated.
- PR #2, `claude/trusting-bell-4fgv07`, remains open: synthetic hosted staging only, founder setup pending. Read that branch's HANDOFF/SETUP for staging; UI branches do not include staging changes.
- PR #3 / `m3-ops-console` is obsolete. Do not use it.
- Founder now approves visible ANUGA branding; older spec wording about an undecided name is stale. Keep code/package identifiers unchanged.
- S2: supplied concept boards preserved and `docs/design/tokens.md` defines the UI contract. Corrected references are boards 13, 14 and 15.
- S3 ops UI complete with full checks and23 synthetic browser captures; separate PR prepared. S4/S5 remain in review/checks. All branches incorporate S2 PR #4 without staging changes. No main merge or deployment.

## Parallel work and shared documents

One writer per path, isolated worktree/branch and separate PR per stream. S2 precedes S3-S5.

| Stream | Owns | Depends on |
| --- | --- | --- |
| S1 Staging | `.github/workflows/deploy-staging.yml`, `scripts/build-staging.sh`, `scripts/staging-smoke.ts` | founder secrets |
| S2 Tokens | `docs/design/tokens.md`, founder-supplied reference boards | sketches |
| S3 Ops UI | `apps/ops_console/src/app/**`, presentation `src/components/**`; no `src/lib/**` or auth/API logic | S2 |
| S4 Companion UI | `apps/companion_app/lib/` widgets/screens and l10n; no RPC/auth/action logic | S2 |
| S5 Family UI | `apps/family_app/lib/` widgets/screens and l10n; no RPC/auth/payment/upload adapters | S2 |
| S6 Backend | new `supabase/migrations/` files, `supabase/tests/`, `packages/shared_dart/` | none |

Root coordinator alone updates HANDOFF, TASKS, AGENTS status and curated UI evidence in each worktree before its task commit. Workers return receipts and do not edit shared documents. Every task commit includes its documentation updates. Every completed task is pushed and has a PR; do not merge main. Run `scripts/check-all.sh` plus the app checks before each PR and report unavailable checks exactly. UI streams preserve all handlers, state transitions, access rules and data flow. Tap targets at least 48 pixels, high contrast, larger text supported, te/hi for each new en string.
