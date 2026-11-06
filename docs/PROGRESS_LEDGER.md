# AnugaCare progress ledger

Last reconciled: 2026-11-06 15:57:39 IST (Asia/Kolkata)

Statuses are `NOT_STARTED`, `IN_PROGRESS`, `IMPLEMENTED`, `VERIFIED`, `MERGED`
or `BLOCKED`. A higher state is never inferred from a lower one.

## Fixed task weights

The mission has 100 fixed points. Progress is recalculated from the evidence in
the task table, not estimated from chat activity.

| Task | Weight | Status | Dependency | Objective and acceptance | Branch / commit / PR | Tests and evidence | Remaining work / exact next action |
| --- | ---: | --- | --- | --- | --- | --- | --- |
| STATE-001 Durable recovery state | 5 | IN_PROGRESS | None | Execution state, ledger, recovery and release checklist exist; HANDOFF/TASKS agree with Git and CI | `fix/production-operations-hardening` / `d14e55c` / PR #27 | Git/GitHub reconciled 2026-11-06 15:57 IST | Commit and push these records, then change to VERIFIED after diff checks |
| INT-001 Repository and PR audit | 8 | VERIFIED | None | Main, worktrees, local changes, PRs #21-#27, CI and migration chain are inventoried from actual sources | PRs #22-#27; head `d14e55c` | Literal ancestry verified; all six PRs clean/mergeable; 7/7 CI each; latest run `42172886236` | Preserve evidence when bases change during merge |
| INT-002 Hardening stack integration | 10 | IMPLEMENTED | INT-001 | #22-#27 remain compatible and land on main in order without weakening access controls | Current stack ends at PR #27 `d14e55c` | Full suite reached `ALL CHECKS PASSED`; hosted changes none | Rerun corrected gate, make #23 ready, merge/retarget sequentially, verify main CI |
| UI-001 Brand system and reference reconciliation | 7 | IN_PROGRESS | INT-002 | Existing tokens remain authoritative; new boards are stored as source references and mapped to supported capabilities | New UI branch not created | `docs/design/tokens.md` maps prior boards and access deviations | Add the three supplied boards, extend mapping, audit real screens, avoid unsupported maps/calls/clinical copy |
| UI-002 Family experience | 10 | IMPLEMENTED | UI-001 | Supported request, pending, confirmation, assignment, OTP, milestones, refresh and completion screens use real RPC data and accessible states | Existing merged UI plus PR #22 stack | Family widget/API and real-Supabase journey tests green in CI | Audit against new board, fix only verified UX gaps, capture actual screenshots |
| UI-003 Patient-supported experience | 5 | IN_PROGRESS | UI-001 | Deliver the elderly-friendly view permitted by the existing role/access contract; no invented independent role | Existing family/unified app | Current family patient-view behavior exists; contract audit incomplete | Trace role routing and permissions, document supported mode, implement only proven gaps |
| UI-004 Companion experience | 10 | IMPLEMENTED | UI-001, INT-002 | Present the real eight-stage lifecycle, prerequisites, retries and persistence without replacing it with four fictional stages | Existing merged UI plus PR #22 stack | Companion tests and real-Supabase journeys green in CI | Audit grouping/navigation/refresh states against board, fix proven UI gaps, capture actual screenshots |
| NAV-001 Companion navigation handoff | 6 | NOT_STARTED | UI-004 | Use configured real map/navigation capability or an honest external handoff; no fake map, route or ETA | None | No evidence yet | Inventory current location libraries/config and choose the smallest supported action |
| PWA-001 Installability and privacy cache | 8 | IMPLEMENTED | INT-002 | Manifest, icons, scope, service worker, session restore, update and private-cache behavior are verified on deployed staging | PR #20 merged before current stack | Existing PWA readiness tests/docs; physical install not performed | Re-audit current main after stack/UI integration; run desktop checks and prepare physical-device cases |
| QA-001 Complete synthetic journey | 10 | VERIFIED | INT-002, UI-002, UI-004 | Family -> Ops -> Companion -> Family persists with OTP, handover, return, issue privacy and denial controls | PR #27 `d14e55c` | CI `42172886236`: care, issue and combined real-Supabase journeys passed | Re-run after main integration and again against deployed synthetic staging |
| QA-002 Physical mobile and language acceptance | 6 | BLOCKED | PWA-001, REL-002 | Android Chrome/PWA, small-screen/200% text and human Telugu/Hindi wording are signed with real evidence | Not applicable | No physical device or human language approval supplied | Founder runs device plan; named TE/HI and healthcare reviewers sign results |
| REL-001 Main PR/CI completion | 7 | IN_PROGRESS | INT-002 | In-scope stack and later UI release PRs are merged with required CI and exact SHAs recorded | PRs #22-#27 open | All current stack CI green; main unchanged at `21ae9bc` | Complete sequential merges, then create/verify the UI release PR |
| REL-002 Synthetic staging deployment | 8 | NOT_STARTED | REL-001, PWA-001, QA-001 | Exact main commit and compatible migrations deploy only to positively identified synthetic staging; URLs and role workflows are verified | Current staging remains PR #21/main | No November hosted migration or deployment | Verify project identity/history/recovery, migrate, deploy, smoke, then run hosted journey |

## Progress calculation

Current evidence-weighted state at 2026-11-06 15:57 IST:

- Implemented: 56/100 (INT-001, INT-002, UI-002, UI-004, PWA-001, QA-001)
- Verified: 18/100 (INT-001, QA-001)
- Merged into current `main`: 0/100 for this mission's tasks
- Deployed and verified on synthetic staging: 0/100 for this mission's target commit

These figures intentionally exclude earlier main functionality unless it satisfies
a named mission task. Blocked work remains in the denominator.
