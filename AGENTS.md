# AGENTS.md

Mandatory entry point for every coding agent. CLAUDE.md adds architecture notes;
the single policy is [working agreement](docs/delivery/WORKING_AGREEMENT.md).

## Read before editing

1. [docs/README.md](docs/README.md) and [current HANDOFF](docs/HANDOFF.md).
2. [PRODUCT_SPEC](docs/PRODUCT_SPEC.md), [screen inventory](docs/product/SCREEN_INVENTORY.md),
   [feature/access matrix](docs/product/FEATURE_MATRIX.md), assigned work-board task/spec.
3. [Agreement](docs/delivery/WORKING_AGREEMENT.md), [tokens](docs/design/tokens.md),
   [TASKS history](docs/TASKS.md), [SETUP](docs/SETUP.md).
4. Fetch origin; record branch/base SHA and local changes. Read current main's
   handoff, not a stale local branch. Preserve other worktrees/uncommitted work.

## Non-negotiables

- Database grants/RLS/restricted functions enforce permissions; no app-only check.
  Every changed access rule needs allowed and denied tests.
- Companions never see vault data, diagnoses or date of birth. Vault reads use
  audited functions; Ops needs active owner ops_vault_access consent.
- Synthetic data only; no emergencies, clinical tasks or medicine sales. No real
  patient data, paid providers or production/public deploy without separate authority.
- Reuse app/handler/contracts. Styling does not alter Auth/RPC/data flow, DB rules
  or tokens. Keep two Flutter apps, Ops Next.js, shared Dart and Supabase.
- One writer per reserved path set, isolated worktree/branch. Coordinator alone
  updates shared inventories, HANDOFF, TASKS, status and curated evidence from receipts.
- 48px targets, high contrast, uncapped large text, dark/keyboard support; every
  new en string needs te/hi. Images do not approve features/prices/permissions.
- Never infer completion/release from milestones, screenshots or PR numbers.
  Record acceptance and environment/SHA separately; unknown stays Unknown.
- Keep docs current per task/authorized commit, including checks/skips. Task-specific
  commit/push/PR/publication boundaries override historical automation. Never edit
  generated outputs or commit secrets, build output or local tool state.

## Checks

Use pnpm for Node, uv/uvx for Python. Tool versions in SETUP. Source changes retain:

```sh
pnpm install --frozen-lockfile
pnpm db:test
pnpm typecheck
scripts/check-all.sh
cd apps/ops_console && pnpm lint && pnpm typecheck && pnpm test
cd apps/companion_app && flutter pub get && flutter analyze --fatal-infos && flutter test
cd apps/family_app && flutter pub get && flutter analyze --fatal-infos && flutter test
```

SQL/shared-contract changes: new migrations only, one at a time; run
`pnpm contract:export`, both contract suites and authoritative real-Supabase tests.
Prose-only tasks validate links/IDs/coverage/whitespace and record runtime not run;
do not run all app tests just for prose. No tools installation in bootstrap.

## Status (2026-10-17)

Main `64c4603` includes M0-M9 and combined synthetic apps via #8/#9. Historical
source `de8f72a`, CI/deployment/session receipts: docs/evidence/hosted-test.
This audit did not reverify live runtime; M10 remains gated.
PR #10 (`c561a9d`, weekdays/range wording) and #11 (`1a91a68`, cancellation notices)
are open/unmerged, absent from main/release. #2/#4-#7 remain open but integrated by
#8; #3 is obsolete. Recheck remote state before integration.

ANU-001 bootstrap reviewed against acceptance criteria; founder authorised its
documentation-only commit on docs/product-inventory-bootstrap. Initial checkpoint
5ec8f77 remains on the original branch. No push/PR/issues/merge/deploy or additional
agents. ADR 0006 records ANU-002 pilot welcome/two sign-in links, dedicated Ops URL,
Ops user provisioning and backend-authorised setup-pending direction; current Auth
conflicts and remaining readiness/patient-consent contracts are documented.
ANU-002 implementation is locally complete and reviewed: lifecycle/backend,
authoritative entry gates and available local checks pass. Overall ANU-002 remains
Partial/unreleased for device, human language/accessibility and rollout acceptance.
F1-F4 remain provisional development assumptions; no real operator or roster
approval is inferred. No activation creates patient grants/consent.
Latest founder request authorises review fixes and an ANU-002-only local commit.
No push, merge, deploy or hosted changes. Source/evidence and remaining checks:
docs/evidence/anu002-review/README.md and docs/delivery/tasks/ANU-002-VERIFY.md.
Sole implementation writer remains the coordinator; one read-only backend review
completed without edits. ANU-003 was inspected only and remains separately owned,
unassigned and documentation-only; see the review receipt for exact dependencies.
