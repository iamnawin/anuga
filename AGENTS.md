# AGENTS.md

## Permanent incremental delivery and agent handoff (2026-11-11)

The founder's current checkpoint policy governs delivery: complete ONE feature
at a time, inspect existing implementation, implement only missing scope, run
focused checks plus necessary regression/security checks, review evidence,
commit separately, push/create or update its PR, update the records below, then
STOP for user review. Do not begin the next unrelated feature or perform a merge
or deployment past that review checkpoint. Reuse successful expensive checks
when their commit and environment match; never infer deployment from a push.

Ownership is isolated:

- Codex: PR #28, `feat/g7-ui-staging`,
  `D:\AI-Workspace\Repos\anuga-trips-fix`; technical integration, migrations
  and synthetic staging validation.
- Gemini: PR #29 and independent UI Redesign V2 in
  `D:\AI-Workspace\Ideas\Anuga`. Do not change or merge this workstream without
  an explicit integration decision.
- PR #30 is the independent Next.js security workstream.

Before changes, read HANDOFF, TASKS, EXECUTION_STATE, PROGRESS_LEDGER and relevant
specifications/evidence. Read UX_AUDIT and UX_IMPLEMENTATION_PLAN where present;
if they exist only on another workstream, read via Git without importing or
rewriting that agent's register. Inspect Git status, branch, worktrees and active
ownership; never reset, overwrite, force-push or delete another agent's work.

After every task/batch and before a long operation or interruption, update
`docs/HANDOFF.md`, `docs/TASKS.md`, `docs/EXECUTION_STATE.md` and
`docs/PROGRESS_LEDGER.md` on the agent's own branch. Update task-specific UX
registers only for owned scope. Preserve prior entries. Record actual IST start
and checkpoint times, real agent identity/role, task ID, worktree, starting and
verified ending commit, PR state, changed files, actual executed/skipped/blocked
checks, CI/artifact references, merge/deployment/migration states, blockers,
uncommitted paths, review status, exact next action and next responsible agent.
Use Unknown / Not tested / Not deployed where appropriate. A task is handed off
only when those records agree with Git and external evidence.

Use this HANDOFF block for each new checkpoint:

```markdown
### Agent Session - [Actual IST checkpoint date/time]

**Agent:**
**Role / responsibility:**
**Session start (IST):**
**Task ID / Name:**
**Repository / Worktree:**
**Branch:**
**Starting commit:**
**Current commit:**
**PR:**
**Scope:**
**Completed work:**
**Files changed:**
**Tests and actual results:**
**CI evidence:**
**Merge status:**
**Deployment and migration status:**
**Decisions and assumptions:**
**Blockers:**
**Uncommitted changes:**
**Exact next action:**
**Next responsible agent:**
```

This supplements the historical policies below without erasing ownership,
privacy, synthetic-data or production safety boundaries.

Instructions for any coding agent (Codex, Gemini, Claude Code, others) working in this repository.
Claude Code also reads `CLAUDE.md`, which has the same rules plus architecture notes.

## Read first

1. `docs/HANDOFF.md`: current state and the exact next task.
2. `docs/PRODUCT_SPEC.md`: shared product requirements, scope limits, data model and access rules.
3. `docs/TASKS.md`: milestones and acceptance criteria.
4. `docs/SETUP.md`: verified tool versions and setup commands.
5. `docs/ARCHITECTURE.md`: what is built, how the parts connect, flows, integration status, how to test.

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
- LIVE https://anuga.vercel.app serves root chooser and /ops/, /family/, /companion/. All four routes HTTP 200 and real three-role sign-in/reload/isolated sign-out pass. Source de8f72a, deployment dpl_FHuVVy4Th8XzxEqQAz3Ekc1ZFyN3. PR #9 merged at 37bdae2c; code CI 38150546061 passed all six jobs, real Supabase 150/150, full journey/test billing and both APKs. Main app code exactly matches verified published source. Final receipt is docs-only; its new CI may be running. Next: founder manual active-window visit from LOCAL_TESTING. M10 remains gated.
- 2026-10-20: founder chose Salesforce as a one-way ops copy; Supabase stays the system of record (ADR 0005, milestone M9a, stream S6). PR #2 now carries only that decision; main already has its staging work.

## Current delivery note (2026-11-03)

PRs #19/#20/#21 are merged. PR #21 merge `21ae9bc` is published to the existing
synthetic site; its seven-job CI and focused authenticated post-deployment smoke
passed. PWA feature iteration remains first; Android/APK support is preserved.
The issue-handling branch keeps operational notes private and uses explicit,
stale-safe Ops resolution through existing transitions. Read HANDOFF for its PR,
preview and actual verification status. Underway reassignment remains unsupported.
Physical-phone/native-speaker checks and hosted fixture cleanup remain pending;
refresh narrow fixtures before grouping checks. The 180-minute window remains
provisional; production launch, real data and paid providers stay gated.

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
