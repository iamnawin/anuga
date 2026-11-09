# AGENTS.md

Instructions for any coding agent (Codex, Gemini, Claude Code, others) working in this repository.
Claude Code also reads `CLAUDE.md`, which has the same rules plus architecture notes.

## Read first

1. `docs/HANDOFF.md`: current state and the exact next task.
2. `docs/PRODUCT_SPEC.md`: shared product requirements, scope limits, data model and access rules.
3. `docs/TASKS.md`: milestones and acceptance criteria.
4. `docs/EXECUTION_STATE.md` and `docs/PROGRESS_LEDGER.md`: live multi-agent execution state and evidence-weighted task ledger.
5. `docs/UX_AUDIT.md` and `docs/UX_IMPLEMENTATION_PLAN.md`: permanent UX/accessibility audit register (`UX-01`â€“`UX-08`) and UI modernization work packages.
6. `docs/SETUP.md`: verified tool versions and setup commands.
7. `docs/ARCHITECTURE.md`: what is built, how the parts connect, flows, integration status, how to test.

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

## Permanent Multi-Agent Handoff Policy (Mandatory for All Agents)

This rule applies permanently to **every** AI agent working on AnugaCare (`Gemini CLI`, `Antigravity / Gemini`, `Codex`, `Claude Code`, `Cursor`, or any future agent). Every agent must leave the repository understandable to the next agent without relying on chat history.

### 1. Mandatory Agent Identification
Every work session must record:
- **Agent name:** `Gemini` / `Codex` / `Claude Code` / `Cursor` / `Other`
- **Agent role and responsibility**
- **Task name and task ID**
- **Session start date/time in IST (`Asia/Kolkata`)**
- **Session completion or checkpoint date/time in IST**
- **Repository / worktree path**
- **Git branch and starting commit**
- **Final commit and PR, if applicable**

Never invent an agent identity, timestamp, commit SHA, or CI result.

### 2. Read Before Work
Before making changes, every agent must read `AGENTS.md`, `docs/HANDOFF.md`, `docs/TASKS.md`, `docs/EXECUTION_STATE.md`, `docs/PROGRESS_LEDGER.md`, `docs/UX_AUDIT.md`, and relevant task specifications/evidence. Inspect the actual Git working tree and `git worktree list`, identify other agents' active ownership, and avoid overlapping changes.

### 3. Concurrent Agent Ownership & Worktree Isolation
- **Codex** currently owns **PR #28** (`feat/g7-ui-staging` in `D:\AI-Workspace\Repos\anuga-trips-fix`), technical integration, Supabase migrations, and synthetic staging validation.
- **Gemini** owns the **independent UI/UX modernization workstream** (`feat/anugacare-ui-modernization` in `D:\AI-Workspace\Ideas\Anuga`).
- Never modify, reset, overwrite, force-push, or delete another agent's worktree or active branch.
- Shared documentation (`HANDOFF.md`, `TASKS.md`, `EXECUTION_STATE.md`, `PROGRESS_LEDGER.md`, `UX_AUDIT.md`) is updated on the agent's own branch and reconciled during integration without discarding another agent's entries.

### 4. Mandatory Documentation After Every Task & Before Context Exhaustion
After every completed task, batch, or before context exhaustion / agent switching, update `docs/HANDOFF.md`, `docs/TASKS.md`, `docs/EXECUTION_STATE.md`, `docs/PROGRESS_LEDGER.md`, and task-specific registers (`docs/UX_AUDIT.md`, `docs/UX_IMPLEMENTATION_PLAN.md`). Never claim a task is merged, deployed, tested, approved, or production-ready without evidence.

### 5. Required `HANDOFF.md` Entry Format
Every checkpoint in `docs/HANDOFF.md` must include this structured block with real values (`Not tested`, `Not deployed`, `Unknown`, or `Not applicable` where appropriate):

```markdown
### Agent Session â€” [Actual IST date/time]

**Agent:**
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

### 6. Documentation Completion Gate & Historical Preservation
A task is not handed off until implementation, executed/blocked checks, `HANDOFF.md`, `TASKS.md`, `EXECUTION_STATE.md`, `PROGRESS_LEDGER.md`, commit SHA, PR status, and exact next action are recorded. Preserve historical evidence under `docs/evidence/` and never erase previous agent contributions, timestamps, failed tests, or deployment history.
