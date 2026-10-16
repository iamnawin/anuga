# Working agreement

Current rules, reconciled 2026-10-16. [AGENTS](../../AGENTS.md) is the mandatory
agent entry point; this agreement owns contribution policy. [WORK_BOARD](WORK_BOARD.md)
owns task status. M0–M10 history remains in [TASKS](../TASKS.md).

## Start and ownership

1. Read docs/README, current HANDOFF, product/design contracts, inventories and
   the assigned task/spec. Fetch and record current main, branch/base SHA and
   clean or understood local state. Do not overwrite another worktree's changes.
2. Coordinator reserves a board row: one active owner per task and permitted
   path set; list dependencies, acceptance criteria, branch and expected receipt.
   Each contributor uses an isolated branch/worktree from the recorded base.
   Do not share a mutable checkout or assume all open PRs are absent from main.
3. One writer per path. Contributors own their task/specification files only
   until implementation is explicitly scoped. Cross-boundary edits require
   sequencing or a dedicated contract owner. Report conflicts before expanding.
4. Coordinator alone updates shared inventories, WORK_BOARD, HANDOFF, TASKS,
   AGENTS status and curated evidence from receipts. Contributors do not race
   to update these files. Design owner owns tokens/reference corrections;
   backend owner owns SQL/shared contracts. Stabilize dependencies before UI work.

## Product and security boundaries

Keep Family Flutter, Companion Flutter, Ops Next.js, shared Dart and Supabase
boundaries. No app consolidation as incidental cleanup. Reuse existing components
and handlers; UI styling does not change auth, RPCs, transitions, tokens or RLS.
Transient form drafts belong in UI; database grants/RLS/restricted functions
enforce permission and business transitions. Each access change requires allowed
and denied tests. Companions never read vault, diagnoses or date of birth. Vault
reads use audited functions; Ops requires active owner ops_vault_access consent.

Synthetic data only. No emergencies, clinical tasks or medicine sales. No real
patient data, paid provider or production/public deploy without separate founder
authorization. A historical deployment approval is not recurring deploy approval.
Keep fee/cutoff/retention/onboarding questions pending; images do not set policy.
Mock/demo adapters must be labelled and cannot establish integrated completion.

Ask before adding a third-party SDK that receives patient data or anything
clinical. Record any decision changing PRODUCT_SPEC in docs/adr/. Keep feature
branches small and main releasable. Existing .claude/specs and steering files are
optional workflow context, not a second conflicting product policy.

Use pnpm for Node and uv/uvx for Python; no new tools/dependencies without need.
Never edit generated Dart/Supabase output manually. New en strings need te/hi.
Follow existing tokens, 48px targets, high contrast, uncapped larger text, keyboard
focus, and loading/empty/denied/error/retry/submitting/success states.

## Definition of ready

- Stable task and screen/feature IDs, purpose, actor/access levels, entry/back
  paths, owned files and dependencies are explicit.
- Screen spec includes annotated layout/reference differences, components,
  fields/validation/data source, action → handler → API → state/notification,
  permission matrix, states, accessibility/localization and acceptance scenarios.
- Policy/contract questions are decided or excluded with a visible blocker.
  Spec ready is not founder Approved; record approval evidence before that label.

## Definition of done and release

- Acceptance criteria have evidence at the actual branch/SHA. Record exact
  checks run, results, skipped checks and why; no completion by PR number or
  milestone checkbox. Review diff against owned scope and existing contracts.
- UI implementation: screenshots with synthetic data, narrow/wide, dark,
  keyboard/large text and en/te/hi; run app checks and scripts/check-all.sh before
  PR. DB/shared changes: allowed/denied tests, both PGlite and authoritative real
  Supabase, export SQL/Dart contract and run both suites. Refer to SETUP commands.
- Prose-only tasks: validate links, IDs, coverage, current-state consistency and
  whitespace. Do not run the full app suite for prose; explicitly say runtime
  was not verified. Historical test receipts stay historical.
- GitHub PRs provide review. Commit/push/PR follows task-specific authorization;
  no automatic merge/deploy. Founder authorised the initial checkpoint and then
  explicitly authorised review/correction and a bootstrap-only commit on 2026-10-16.
  That supersedes the earlier uncommitted-review boundary. No issues/PRs,
  push, merge, deploy, tools installation or additional agents in this task.
- Design, implementation, verification and release are independent dimensions.
  Record an environment/deployed SHA receipt before calling a feature released.
  Source/fixture/widget evidence does not prove today's deployed behavior.

## Contributor finish receipt

Task/screen/feature IDs; branch/base/resulting commit if any; changed paths and
behavior; reused code; exact checks/results/skips; synthetic screenshots for UI;
permission/API changes; reference deviations; unresolved decisions; PR link if
authorized; next integration step. Coordinator integrates that receipt into shared
docs in the same authorized task commit. Stop at the handoff boundary; do not
implement the next task merely because the previous spec is complete.

Historic stream ownership (S1–S6) remains useful for implementation planning,
but active reservations in WORK_BOARD take precedence. No contributors are
currently reserved for the two proposed packages. Git merges alone do not settle
contract disagreements. If GitHub Projects later becomes authoritative, document
the switch and replace repository statuses with links; do not run two trackers.
