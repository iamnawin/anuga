# Anuga: product inventory and delivery structure

Prepared 16 October 2026. Proposed structure for Naveen and contributors. This file is a reviewable plan and local Codex instruction, not a claim that the repository has already adopted it.

## 1. Establish the baseline before building more screens

PR numbers count changes; they do not measure product completeness. M0–M9 completion establishes the tested scope of those milestones. It does not mean every concept panel, onboarding journey, operational process or production dependency is finished.

Remote evidence checked for this plan:

- `AGENTS.md`: existing read order, database access rules, isolated worktrees, one writer per path, coordinator ownership of shared documents and app validation commands.
- `docs/HANDOFF.md` and `docs/TASKS.md`: milestone and synthetic publication history; these are substantial historical records, not a screen inventory.
- `docs/design/tokens.md`: visual rules and mappings from 15 reference boards. The file explicitly distinguishes implemented presentation from omitted capabilities.
- `docs/PRODUCT_SPEC.md`: product intent, roles, architecture and scope. Some statements are stale: its brand header conflicts with the newer approved ANUGA design contract, and some “later” model notes lag completed milestones. Preserve history and reconcile current statements using dated evidence.
- PR #10 remains OPEN and UNMERGED at `c561a9d`; its base is main `64c4603`. It changes weekly visit patterns and trip-range wording. Its implementation must not be counted as part of main or the deployed application.

Sources:

- https://github.com/iamnawin/anuga/blob/main/AGENTS.md
- https://github.com/iamnawin/anuga/blob/main/docs/HANDOFF.md
- https://github.com/iamnawin/anuga/blob/main/docs/TASKS.md
- https://github.com/iamnawin/anuga/blob/main/docs/PRODUCT_SPEC.md
- https://github.com/iamnawin/anuga/blob/main/docs/design/tokens.md
- https://github.com/iamnawin/anuga/pull/10

Limits: this check did not inspect Naveen's local uncommitted changes, every reference image, all source files or the live UI. The recent research cleanup may exist only locally. The local audit below must include it and record its exact branch and SHA. Do not overwrite local research with older remote copies.

## 2. Keep the existing application structure

Keep the current monorepo and its existing Family Flutter, Companion Flutter, Ops Next.js, shared Dart and Supabase boundaries during this documentation task. Do not move files or consolidate apps to make a folder diagram look cleaner. Whether users eventually install one role-based mobile app is a separate architecture decision.

Use one linked documentation entry point. Reuse equivalent existing files rather than introducing duplicates:

| Path | Purpose | Update owner |
| --- | --- | --- |
| `AGENTS.md` | Short mandatory rules and read order for every coding agent | Coordinator |
| `CLAUDE.md` | Claude entry point referencing the same rules; avoid a second conflicting policy | Coordinator |
| `docs/README.md` | Start here: links to product, inventories, roadmap, setup and handoff | Coordinator |
| `docs/PRODUCT_SPEC.md` | Current product requirements and permissions, with links to decisions | Coordinator |
| `docs/design/tokens.md` | Existing design tokens and interaction rules | Design owner |
| `docs/product/SCREEN_INVENTORY.md` | Every screen, dialog and meaningful view state linked to code and design | Coordinator from contributor receipts |
| `docs/product/COMPONENT_INVENTORY.md` | Reused components, variants, locations and consumers | Coordinator from contributor receipts |
| `docs/product/FEATURE_MATRIX.md` | Capabilities across UI, API, data, permissions, testing and release | Coordinator |
| `docs/product/screens/<screen-id>.md` | Detailed specification for a screen entering active design/development | Assigned screen owner |
| `docs/delivery/WORK_BOARD.md` | Current tasks, owners, branches, dependencies and PRs | Coordinator |
| `docs/delivery/WORKING_AGREEMENT.md` | Contribution rules, path ownership and completion criteria | Coordinator |
| `docs/delivery/tasks/<task-id>.md` | Scope, acceptance criteria and handoff receipt for one active work package | Assigned task owner |
| `docs/adr/` | Existing ADR location, or its actual equivalent: decisions and tradeoffs | Decision owner + coordinator |
| `docs/HANDOFF.md` | Concise current snapshot and exact next step, linked to detailed evidence | Coordinator |
| `docs/TASKS.md` | Existing milestone history and phase-level acceptance, linked to work board | Coordinator |

Use GitHub PRs for code review. Initially, the repository work board owns task status; do not maintain a second independent tracker in a spreadsheet or Notion. If a GitHub Project becomes authoritative later, document that switch and make repository summaries links to it.

Do not create an empty specification file for every imagined component. Inventory first; expand a specification when the work is scheduled.

## 3. Model product completeness explicitly

Use stable identifiers, not PR numbers, for product work:

- Screens: `SCR-AUTH-001`, `SCR-FAM-001`, `SCR-COMP-001`, `SCR-OPS-001`.
- Reused components: `CMP-001` and a descriptive name.
- Features: `FEAT-001` and a descriptive name.
- Tasks: `ANU-001` and a descriptive name.

IDs remain stable if a screen or file is renamed. Individual buttons and labels are normally documented inside a screen/component specification; give them separate IDs only when reuse or behavior warrants it.

### Screen inventory fields

Record: ID; name; role and patient access level; route or navigation entry; platform; reference board filename/panel; preferred corrected reference; design status; implementation status; source path; API/RPC; dependent feature/component IDs; missing states; owner; task/branch/PR; validation evidence and SHA; release/deployment evidence; unresolved decisions.

For each screen, separately track:

| Dimension | Suggested values |
| --- | --- |
| Design | Not specified / Concept / Spec ready / Approved |
| Implementation | Missing / Partial / Implemented |
| Verification | Not run / Partial / Passed / Failed / Blocked |
| Release | Local only / Open PR / On main / Synthetic staging / Production |

Record unknown explicitly and add an evidence note. A conceptual design is not implementation. A passing widget test is not a verified deployed journey. A PR screenshot is not evidence that its branch was released.

### Initial audit targets, not newly verified implementation claims

The design contract already documents these distinctions:

| Area | Documented baseline | Audit question |
| --- | --- | --- |
| Login | Existing role-specific phone sign-in was styled | Is the complete entry-to-sign-in-to-role-home journey clear and functional? |
| Root page | Handoff describes a synthetic role chooser | Is a public product home/onboarding experience required, and what should it do? |
| Family home | Patient picker and existing bookings were mapped | What does a first-time user with no patient or booking see? |
| Patient setup | Board 2 panels 05–08 were intentionally unbuilt | Which fields, creator roles and consent steps are required? |
| Recurring setup | Board 13 panels 09–12 were not implemented as a wizard | Separate actual PR #10 weekday edits from missing intake/setup and checkout |
| Companion onboarding | Board 9 panels 29–30 were intentionally unbuilt | Which verification steps are operational/manual, and which belong in software? |
| Companion trip | Existing actions follow the shared state machine | Are all transitions, recovery paths and restricted fields understandable in the UI? |
| Records | Photo flow exists in the documented scope; PDF gaps are recorded | Which advertised record actions actually work, for which access levels? |
| Ops | Existing boards, assignments, exceptions and billing were styled | Which creation, management and first-run screens remain absent? |

For each concept panel, classify it as mapped to a screen, superseded, duplicate, later scope, excluded or awaiting a decision. No panel should silently disappear. Images are design input; they do not approve prices, permissions or features.

### Component inventory fields

Record ID; name; scope/platform; existing source location; consumers; token usage; variants; interaction and accessibility behavior; localization; loading/error/disabled behavior; tests; owner and status.

Start with actual components and repeated patterns: application shell, navigation, phone field, OTP input, primary/secondary/destructive buttons, form field, validation summary, visit card, status chip, timeline, empty state, loading state, retry banner and confirmation dialog. Discover their real names and files. Share visual and behavior contracts across Flutter and web; do not pretend Dart and React can import one implementation.

### Feature matrix fields

Record ID; user outcome; roles; related screens; UI status; API/data status; permissions status; tests; external provider readiness; configuration/deployment status; blockers; task and evidence.

Example distinction: a cancellation database function may exist while companion notification coverage is missing. “Backend exists” and “user can complete the workflow” must remain separate.

## 4. Design a screen before implementing it

Each active screen specification must include:

1. User, purpose and concrete scenario.
2. Entry point, route and exit/back destinations.
3. Annotated layout and reference panel, with explicit differences.
4. Component list and token use.
5. Fields, defaults, validation and data source; no invented demo data in product logic.
6. Every action: caller, input, RPC/API, resulting state, notification and failure response.
7. Loading, empty, no-access, validation, network failure, submitting, success and retry states where relevant.
8. Permission matrix covering family owner/editor/patient/viewer, assigned/unassigned companion and Ops as applicable.
9. Narrow/wide layout, keyboard/focus, large text, dark mode and English/Telugu/Hindi behavior.
10. Testable acceptance criteria, dependencies and pending business decisions.

Form draft state belongs in UI code; authorization and allowed business transitions remain enforced by the database. An attractive button must not imply an unsupported action.

## 5. Enable two developers or different AI models to work safely

One active owner per task and path set. Each contributor uses an isolated branch/worktree based on a recorded base SHA. Do not share a mutable checkout between agents.

Before starting, reserve a work-board row with task ID, owner, permitted paths, dependencies, branch and expected acceptance criteria. If two tasks need the same shared file, sequence that change or give it a dedicated owner. Git merges alone do not resolve incompatible API assumptions.

| Contributor | Example work | Boundary |
| --- | --- | --- |
| Developer A / AI A | Auth/entry screen specification and later implementation | Agreed auth presentation paths only |
| Developer B / AI B | Family-home specification and later implementation | Agreed Family presentation paths only |
| Backend owner | Required RPC/model/permission changes | Migrations, shared contract and database tests |
| Coordinator | Cross-task decisions, inventories, integration and shared handoff | Shared documentation and integration branch |

These are proposed assignments, not a license to run concurrent writers immediately. Confirm real source paths first. Shared tokens and contracts must stabilize before dependent implementation; mock adapters may support isolated UI work but cannot count as completed integration.

Contributor start checklist:

- Read AGENTS, current handoff, task, screen spec and relevant architecture/design contracts.
- Confirm base SHA, branch, owner and clean/understood worktree state.
- State permitted paths and dependencies; report conflicts before expanding scope.
- Reuse existing components and handlers.

Contributor finish receipt:

- Task and screen/feature IDs; branch and commit when available.
- Changed files and resulting behavior.
- Exact checks run and results; clearly label skipped/blocked checks.
- Screenshots for changed UI only, using synthetic data.
- API/permission changes, intentional reference deviations and remaining gaps.
- PR link when authorized; next integration step.

Only the coordinator updates shared inventories, AGENTS status, TASKS and HANDOFF from those receipts. Contributors update their own task/specification files. This preserves the existing one-writer rule.

## 6. Rules to add or reconcile in agent entry points

- Read the current inventory and assigned task before editing.
- Never infer completion from a milestone checkmark, design image or PR number.
- Never mark work Done without acceptance evidence; never mark it released without an environment/SHA receipt.
- Do not redesign or refactor unrelated screens while implementing a task.
- Do not change database access rules, shared contracts or design tokens as a side effect of styling.
- Every new string needs en/te/hi support; preserve the existing 48px target and larger-text rules.
- No companion access to vault data, diagnoses or date of birth; permission changes require allowed and denied tests.
- Keep founder policy questions pending rather than coding assumed charges, cutoffs or verification claims.
- A temporary demo, mock or placeholder is explicitly labelled and excluded from completion claims.
- Stop at a handoff boundary with a task-specific receipt so another model can resume without rereading chat history.
- Resolve outdated instructions in place using current evidence and a dated decision; avoid accumulating contradictory “current” status sections.

This plan does not grant new merge, deployment, paid-provider or real-patient-data authority. For the bootstrap task below, documentation-only and no commit/push/merge/deploy overrides older automatic push rules.

## 7. Delivery sequence

Keep M0–M10 as existing historical milestones. Add product-completion work packages rather than renumbering the project.

| Order | Work package | Exit condition |
| --- | --- | --- |
| 1 | Baseline and inventory | All design panels accounted for; code, local changes, main, open PRs and release evidence separated |
| 2 | Entry and access experience | Public/root purpose decided; login, OTP, role routing, denied access and first-use states specified |
| 3 | First-time setup and first booking | Patient/intake/schedule workflow fully specified, with actor and permission decisions |
| 4 | Full visit experience | Family, Companion and Ops screens cover the existing state machine and identified operational gaps |
| 5 | Records, billing and supporting management | Each scoped feature has complete permissions, error states and provider-readiness evidence |
| 6 | Pilot readiness | Cross-role user walkthrough, accessibility/localization checks and release prerequisites satisfied |

These are planning packages; prioritize their tasks after the audit. A small operational fix can proceed independently if its ownership and dependencies are explicit. Production launch remains separate and gated.

First design slice: entry → sign-in → phone OTP → role-specific home, including a new account/no patient/no assigned visit scenario. Validate what already works before replacing it. Authentication OTP and visit pickup OTP are different interactions and must not be confused.

## 8. Paste this into Codex in the local Anuga repository

```text
Create Anuga's repository-based product inventory and contributor workflow before further feature development. This is a documentation and design-specification task. Work autonomously from the actual local checkout; do not assume chat history is authoritative.

Read AGENTS.md, CLAUDE.md, docs/HANDOFF.md, docs/PRODUCT_SPEC.md, docs/TASKS.md, docs/SETUP.md, docs/design/tokens.md, ADRs and the local research documents. Inspect git status, branch, base SHA, current main, PR #10 and other relevant open work using read-only operations. Preserve uncommitted work. Distinguish local-only, open-PR, main and deployed states. Do not merge or cherry-pick.

Inspect all design-reference boards visually, including corrected/superseded versions, and map every panel. Inspect source routes, screens, dialogs, widgets/components, handlers, shared models, RPCs and relevant tests. Use the app locally with synthetic data if practical. Do not equate design screenshots or test assertions with current runtime behavior. Clearly record any inaccessible or unverified area.

Reuse equivalent existing documentation. Establish:
1. docs/README.md as the linked start page.
2. docs/product/SCREEN_INVENTORY.md with stable screen IDs and separate design, implementation, verification and release dimensions.
3. docs/product/COMPONENT_INVENTORY.md mapping actual reused components, variants, paths, consumers, accessibility and localization.
4. docs/product/FEATURE_MATRIX.md separating UI, API/data, permissions, integration/provider readiness and release evidence.
5. docs/delivery/WORK_BOARD.md with task IDs, owners/unassigned, permitted paths, dependencies, branches, PRs and acceptance/evidence links.
6. docs/delivery/WORKING_AGREEMENT.md: one writer per path, isolated branches/worktrees, contract coordination, coordinator-owned shared docs, contributor receipts, definition of ready and definition of done.
7. Screen and task templates. Create detailed specifications only for the first entry/login/OTP/role-home design slice, not hundreds of empty files.

Each inventory row must cite actual evidence or say Unknown. Account for every reference panel as mapped, superseded, duplicate, deferred, excluded or decision-needed. Include all roles and Family access levels. Record loading, empty, denied, failure/retry, validation and first-use states. Distinguish login OTP from pickup OTP.

Reconcile stale current-state statements in the relevant docs without erasing historical receipts. Keep AGENTS.md and CLAUDE.md concise and consistent by linking to one set of working rules. Preserve current security, package-manager and testing requirements. Keep M0-M10 history; do not use PR10 as a completeness measure. App consolidation remains a separate decision.

Do not modify application code, migrations, dependencies, production settings or provider configuration. Do not move source files or install tools. Do not run additional agents. Do not create GitHub issues, commit, push, merge, deploy or publish. This task-specific boundary overrides older automatic push instructions.

Validate documentation links, ID uniqueness, inventory coverage and consistency with inspected code. Do not run the whole application test suite just for prose changes; mark runtime checks not run, and do not claim app verification. Update HANDOFF and TASKS with links and the exact next task.

Finish with: audited SHA/branch and local-change caveats; screens/components/features by evidence-backed status; all new/updated paths; unresolved founder decisions; two disjoint contributor work packages with explicit owned paths/dependencies; and one recommended first design task. Do not start implementing that next task in this run.
```

## 9. Bootstrap acceptance criteria

- Another developer can start from docs/README.md and identify what exists, what is missing and what task to take without reading the chat.
- All design panels and implemented screens are accounted for, with corrected references preferred.
- The inventory distinguishes backend support, UI completion, real integration and deployment.
- PR #10 and local-only work are not silently counted as main.
- Two proposed contributors have disjoint write paths or an explicit shared-contract dependency.
- Agent entry points agree on rules and link to the same working agreement.
- The first entry/login/role-home design slice has actionable specifications and acceptance criteria.
- Remaining unknowns and business decisions are visible rather than hidden behind “Done.”
