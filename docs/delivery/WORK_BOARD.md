# Work board

Updated 2026-10-17. This repository board owns task status; GitHub PRs own review.
M0–M10 remain in [TASKS](../TASKS.md). Base for new work is fetched main `64c4603`,
recheck before starting. One active writer/path set, isolated worktrees. None of
the proposed parallel contributors is running. ANU-002 is reserved to the sole
coordinator; ANU-003 remains unassigned. See [agreement](WORKING_AGREEMENT.md).

| Task | Outcome / status | Owner | Permitted write paths | Dependencies | Branch / PR | Acceptance/evidence |
| --- | --- | --- | --- | --- | --- | --- |
| ANU-001 | Inventory/bootstrap committed locally at 69bbb36 | Codex coordinator | AGENTS.md, CLAUDE.md, docs/README.md, product/, delivery/, HANDOFF/TASKS, dated spec/token corrections and research preservation | Main + checkpoint input | docs/product-inventory-bootstrap; 69bbb36, no PR/push | [Audit](../product/AUDIT_BASELINE.md); [receipt](tasks/ANU-001.md); no app verification claim |
| ANU-002 | Implementation locally complete and reviewed; Partial, device/human/rollout gated | Codex coordinator | [Reserved source/spec paths](tasks/ANU-002.md); coordinator shared docs/evidence; BE child sequentially reserves SQL/shared auth; no ANU-003 home paths | [Lifecycle contract](../product/PILOT_ACCESS_CONTRACT.md): F1-F4 provisional locally; actual rollout decisions/roster/operator + remaining native acceptance pending | docs/product-inventory-bootstrap, reviewed local commit over 69bbb36; no PR/push | [Package A](tasks/ANU-002.md); all-role/failed-session scenarios and real routes |
| ANU-002-BE (child) | Backend implementation locally complete/reviewed; rollout gated | Codex coordinator | [Reserved implementation paths](tasks/ANU-002-BE.md); local reservation in receipt | Provisional assumptions only; reviewed real roster/operator required for rollout | No branch/PR | [Migration, permission, rollback and acceptance plan](tasks/ANU-002-BE.md) |
| ANU-002-VERIFY (child) | Available local checks executed; remaining native/human checks open | Codex coordinator for local receipt; native/reviewer Unassigned | [Checks/receipts](tasks/ANU-002-VERIFY.md); reserve per scenario | Backend + resolver/client integration; local Auth/Storage/device/native reviewers | No branch/PR | Local SQL/Auth/Storage/session and te/hi-render evidence; device/native review still unavailable |
| ANU-003 | Family first-use/home spec review; proposed | Unassigned | docs/delivery/tasks/ANU-003.md; docs/product/screens/SCR-FAM-001.md, SCR-FAM-032.md | ANU-002 [local lifecycle contract; rollout gated](../product/PILOT_ACCESS_CONTRACT.md); separate patient/schedule/consent/help D2; zero patient links never imply setup pending | Proposed docs/family-first-use-spec, not created; no PR | [Package B](tasks/ANU-003.md); four Family levels, no-patient vs no-booking vs denied |
| ANU-004 | Companion first-use review; queued | Unassigned | Not reserved; suggested SCR-COMP-001.md plus its future task receipt | D3 for onboarding claims; assigned projection; separate from package A/B | None | [Companion spec](../product/screens/SCR-COMP-001.md); no-assignment/masked/stale trip cases |
| ANU-005 | Prioritize intake, full visit, records/billing gaps; backlog | Unassigned | None; define one task before editing | Inventory + D2–D8, tokens/contracts as applicable | None | [Feature gaps](../product/FEATURE_MATRIX.md); no bulk feature build authorized |
| ANU-006 | Review/integrate cancellation and weekdays; pending separate authorization | Unassigned integration owner | None reserved by bootstrap; do not change open PR branches | PR #10/#11 common sender coordination; authoritative DB/concurrency/journey checks | feat/weekly-visit-pattern PR #10; feat/companion-cancellation-notification PR #11; both open | [Branch evidence](../product/AUDIT_BASELINE.md); fixture test ≠ merged migration verification |

Sequence after baseline: entry/access → first-time setup/first booking → full visit
→ supporting records/billing/management → pilot readiness. Production is separate
M10. A small operational fix can be scheduled independently with a dedicated owner.

Packages A/B have disjoint write paths. Both read the shared contracts but cannot
edit AGENTS/TASKS/HANDOFF/inventories/tokens/Auth/shared APIs. Coordinator reconciles
receipts and updates shared docs once. The lifecycle/readiness contract is implemented locally. Actual rollout authority
and ANU-003 patient/schedule/consent/help decisions remain separate.

Current exception to the initial spec-only packages: founder authorised ANU-002
implementation and coordinator shared-doc updates; latest review authorises the
ANU-002-only local commit, with no push/merge/deploy.
ANU-003 ownership/path set remains unchanged and unassigned. Backend/client paths are
reserved sequentially by the ANU-002-BE child receipt. Historical spec-only restrictions above
apply to the other packages, not the explicitly expanded ANU-002 reservation.
