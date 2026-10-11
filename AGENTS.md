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

## Status (2026-10-11, founder-authorized synthetic publication)

- M0-M9 and the combined redesigned apps are on main through PR #8 (3c6f2ac), founder-authorized merge. Final source and main CI passed six jobs, real Supabase/full journey and APKs. M10 remains gated.
- Founder explicitly approved publishing the combined synthetic version at anuga.vercel.app. This replaces the earlier no-main-merge/no-deploy instruction for this task; no real data or paid providers authorized.
- PR #2 and #4-#7 remain intact, their changes integrated by #8. PR #3 remains obsolete. ANUGA branding approved; identifiers unchanged.
- Hosted Phone is now enabled and synthetic role allowed/denied smoke passes. Same-origin Flutter auth storage and BroadcastChannel isolation verified by real browser sign-ins/reloads/sign-out. Native auth settings, RPCs, DB access rules and tests preserved.
- LIVE https://anuga.vercel.app serves root chooser and /ops/, /family/, /companion/. All four routes HTTP 200 and real three-role sign-in/reload/isolated sign-out pass. Source de8f72a, deployment dpl_FHuVVy4Th8XzxEqQAz3Ekc1ZFyN3. PR #9 contains necessary hosting fixes; CI 38150546061 pending remaining jobs before its authorized merge. All local fast/app checks/web builds pass. See latest HANDOFF.

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

## Integration authorization (2026-10-11)

Founder explicitly requested one combined main-based integration branch/PR incorporating PR #2 and #4-#7, local servers and connected synthetic testing. The coordinator may reconcile the previously isolated stream paths and shared documents for this branch only. Source PRs remain intact. No deployment or main merge.

Integration PR #8 is OPEN: https://github.com/iamnawin/anuga/pull/8. Local release apps and checks pass. Integration CI at 719361c passed all six jobs (run 38145315706), real Supabase 150/150, full journey/test billing and both APKs. Final receipt changes docs and restores the staging script's executable bit only. Founder Phone test-provider setup blocks authenticated manual browser testing. No main merge or agent deploy command; existing Vercel Git automation created previews, recorded in HANDOFF.

## Publication authorization

Founder explicitly approved merge of PR #8 and publishing all three synthetic apps at anuga.vercel.app. Necessary same-origin session isolation, combined build/config/workflow changes and follow-up PR merge are within this deployment task. Previous stream write limits apply to UI work; the coordinator owns these deployment integration fixes and shared receipts. No real-data or paid-provider launch.
