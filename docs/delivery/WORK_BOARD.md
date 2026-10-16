# Work board

Updated 2026-10-16. This repository board owns task status; GitHub PRs own review.
M0–M10 remain in [TASKS](../TASKS.md). Base for new work is fetched main `64c4603`,
recheck before starting. One active writer/path set, isolated worktrees. None of
the proposed contributors is assigned or running. See [agreement](WORKING_AGREEMENT.md).

| Task | Outcome / status | Owner | Permitted write paths | Dependencies | Branch / PR | Acceptance/evidence |
| --- | --- | --- | --- | --- | --- | --- |
| ANU-001 | Inventory/bootstrap reviewed for scoped commit | Codex coordinator | AGENTS.md, CLAUDE.md, docs/README.md, product/, delivery/, HANDOFF/TASKS, dated spec/token corrections and research preservation | Main + checkpoint input | docs/product-inventory-bootstrap; review commit authorised, no PR/push | [Audit](../product/AUDIT_BASELINE.md); [receipt](tasks/ANU-001.md); no app verification claim |
| ANU-002 | Entry/phone/OTP/access spec review; proposed first task | Unassigned | docs/delivery/tasks/ANU-002.md; docs/product/screens/SCR-AUTH-001.md, SCR-AUTH-002.md, SCR-AUTH-003.md, SCR-OPS-002.md, SCR-FAM-010.md | ADR 0006 welcome/Ops user provisioning accepted; readiness/Auth conflicts and remaining D2; no code edits | Proposed docs/entry-access-spec, not created; no PR | [Package A](tasks/ANU-002.md); all-role/failed-session scenarios and real routes |
| ANU-003 | Family first-use/home spec review; proposed | Unassigned | docs/delivery/tasks/ANU-003.md; docs/product/screens/SCR-FAM-001.md, SCR-FAM-032.md | ANU-002 backend readiness contract; Ops pilot user provisioning accepted; patient/schedule/consent/help still D2 | Proposed docs/family-first-use-spec, not created; no PR | [Package B](tasks/ANU-003.md); four Family levels, no-patient vs no-booking vs denied |
| ANU-004 | Companion first-use review; queued | Unassigned | Not reserved; suggested SCR-COMP-001.md plus its future task receipt | D3 for onboarding claims; assigned projection; separate from package A/B | None | [Companion spec](../product/screens/SCR-COMP-001.md); no-assignment/masked/stale trip cases |
| ANU-005 | Prioritize intake, full visit, records/billing gaps; backlog | Unassigned | None; define one task before editing | Inventory + D2–D8, tokens/contracts as applicable | None | [Feature gaps](../product/FEATURE_MATRIX.md); no bulk feature build authorized |
| ANU-006 | Review/integrate cancellation and weekdays; pending separate authorization | Unassigned integration owner | None reserved by bootstrap; do not change open PR branches | PR #10/#11 common sender coordination; authoritative DB/concurrency/journey checks | feat/weekly-visit-pattern PR #10; feat/companion-cancellation-notification PR #11; both open | [Branch evidence](../product/AUDIT_BASELINE.md); fixture test ≠ merged migration verification |

Sequence after baseline: entry/access → first-time setup/first booking → full visit
→ supporting records/billing/management → pilot readiness. Production is separate
M10. A small operational fix can be scheduled independently with a dedicated owner.

Packages A/B have disjoint write paths. Both read the shared contracts but cannot
edit AGENTS/TASKS/HANDOFF/inventories/tokens/Auth/shared APIs. Coordinator reconciles
receipts and updates shared docs once. The accepted pilot direction needs a readiness/Auth contract; sequence
that contract decision before either package claims implementation readiness.
