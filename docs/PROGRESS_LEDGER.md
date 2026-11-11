# AnugaCare progress ledger

Last reconciled: 2026-11-11 19:41:54 IST (Asia/Kolkata)

BACKUP-ACCESS-001 (Codex; start 19:36:44 IST, source ad85d34, #28 OPEN):
prerequisites PARTIAL, BACKUP-002 BLOCKED. Native portable PG17.11 clients
installed outside Git; four version checks pass and hashes recorded. Restricted
libpq service template/comment-only password file prepared. Owner must confirm
official endpoint, privately supply existing password/project CA, encryption/key
custody, export scope and isolated target approval. Hosted connectivity/restore
NOT TESTED. WSL Docker CLI exists but no daemon socket; no Desktop install.
Receipt: `evidence/g7-ui-staging-2026-11-07/BACKUP_ACCESS_001.md`.
CI 43032867873 failed in runner DNS/Playwright dependency install; 43034985288
in progress at checkpoint. No rerun, source mutation, backup, restore, merge or
deploy. REL-002 remains BLOCKED; weights unchanged. STOP for review.

BACKUP-001 (Codex, approved follow-up; starting `7d94feb`, PR #28): BLOCKED for
backup/restore. Official supported method, local prerequisites and complete
coverage matrix reviewed. No Docker/pg_dump/psql or discovered protected direct
DB connection. Passwordless CLI remote dump creates a temporary login role, which
current authority prohibits; not attempted. No protected backup artifact/checksum
or isolated restore evidence exists. Receipt: `evidence/g7-ui-staging-2026-11-07/BACKUP_001.md`.
No ATTEST-001 repeat or test/build rerun. Stop for review. Proposed next task:
BACKUP-ACCESS-001 prerequisites. REL-002 remains BLOCKED; weights unchanged.

ATTEST-001 (Codex, approved read-only follow-up): observation complete on source
`8646f56`; CI `43030310112` finished SUCCESS, seven jobs, no reruns. Live project
identity confirmed; nine legacy history rows and 16 function-body comparisons
prove three Nov 4 hardening effects absent, while five later manual application
groups have inspected code present. Backup listing has no usable restore point;
PITR false. Detailed receipt: `evidence/g7-ui-staging-2026-11-07/STAGING_ATTESTATION.md`.
REL-002 remains BLOCKED by confirmed drift/recovery gaps, no longer missing CLI
access. This is a completed attestation, not a completed rollout: weights do not
change. Publish receipt on #28 then STOP. Proposed next task: synthetic backup/
recovery readiness, subject to founder review. Earlier dated records follow.

TASK4-RECOVERY (Codex): recovered `e80ffd0`, verified completed seven-job CI
`42363763847`, counted 17 retained screenshots and rechecked the retained APK
hash. Automated Task 4 evidence package is complete. Hosted/physical PWA,
device and human-language acceptance remain blocked/unverified, not completed.
Current action is documentation delivery on PR #28, then STOP for founder review.
Do not automatically merge or resume Task 5. Proposed next task after review:
read-only hosted identity/migration/recovery attestation. No progress weights
change from recovery or documentation alone. Historical records below remain.

Current Task 5 checkpoint: PR #28 `7fa7cb2`, CI `42343362420` seven successful
jobs; independent review ready to merge, no Critical/Important findings.
UI-002/UI-004 screenshot collection is complete; their next action is the
candidate's hosted verification after migration prerequisites. REL-002 is
BLOCKED: Supabase management access returned `Access token not provided`.
Vercel access works and confirms the unchanged existing synthetic deployment.
NAV-001 remains open because no configured map provider or navigation handoff
has been delivered. PWA deployed cache/install/session checks remain open.

Statuses are `NOT_STARTED`, `IN_PROGRESS`, `IMPLEMENTED`, `VERIFIED`, `MERGED`
or `BLOCKED`. A higher state is never inferred from a lower one.

## Fixed task weights

The mission has 100 fixed points. Progress is recalculated from the evidence in
the task table, not estimated from chat activity.

| Task | Weight | Status | Dependency | Objective and acceptance | Branch / commit / PR | Tests and evidence | Remaining work / exact next action |
| --- | ---: | --- | --- | --- | --- | --- | --- |
| STATE-001 Durable recovery state | 5 | MERGED | None | Execution state, ledger, recovery and release checklist exist; HANDOFF/TASKS agree with Git and CI | Checkpoints `7a06f1b`, `c9cbf9f`; merged through PR #27 at `ea6d142` | Diff checks and corrected full-suite gate pass | Preserve these files at every later checkpoint |
| INT-001 Repository and PR audit | 8 | MERGED | None | Main, worktrees, local changes, PRs #21-#27, CI and migration chain are inventoried from actual sources | Evidence merged through PR #27 | Literal ancestry, diffs, migrations and seven-job CI verified before each merge | Reconcile again before deployment |
| INT-002 Hardening stack integration | 10 | MERGED | INT-001 | #22-#27 remain compatible and land on main in order without weakening access controls | Merge commits `a8109ae`, `5b838b6`, `8d175b4`, `038fb67`, `88b0c0b`, `ea6d142` | Final head CI `42203978157` 7/7; main run `42205624861` queued; hosted changes none | Wait for final main CI; retain undeployed state until hosted prerequisites pass |
| UI-001 Brand system and reference reconciliation | 7 | VERIFIED | INT-002 | Existing tokens remain authoritative; new boards are stored as source references and mapped to supported capabilities | `feat/g7-ui-staging` / `17b6021`; evidence through `1e956fc` | Three inputs mapped; 17 actual PR #28 screenshots inspected; no blocking visual defect | Preserve mapping and source labels through merge/deploy |
| UI-002 Family experience | 10 | VERIFIED | UI-001 | Supported request, pending, confirmation, assignment, OTP, milestones, refresh and completion screens use real RPC data and accessible states | `feat/g7-ui-staging` / `0644dd9` | RED then GREEN progress regressions; analyze clean; 61 pass / 6 environment skips; full check-all green | Capture authenticated branch CI screens and reverify real-Supabase journey |
| UI-003 Patient-supported experience | 5 | VERIFIED | UI-001 | Deliver the elderly-friendly view permitted by the existing role/access contract; no invented independent role | Same Family view / `0644dd9` | Existing role contract retained; Family/Patient-view progress and 200% EN/TE/HI tests pass | Human device/language approval remains QA-002 |
| UI-004 Companion experience | 10 | VERIFIED | UI-001, INT-002 | Present the real nine-state lifecycle, prerequisites, retries and persistence without replacing it with four fictional states | `feat/g7-ui-staging` / `8eb152e` | RED then GREEN progress/refresh regressions; analyze clean; 66 pass / 3 environment skips; full check-all green | Capture authenticated branch CI screens and reverify real-Supabase journey |
| NAV-001 Companion navigation handoff | 6 | NOT_STARTED | UI-004 | Use configured real map/navigation capability or an honest external handoff; no fake map, route or ETA | None | No evidence yet | Inventory current location libraries/config and choose the smallest supported action |
| PWA-001 Installability and privacy cache | 8 | IMPLEMENTED | INT-002 | Manifest, icons, scope, service worker, session restore, update and private-cache behavior are verified on deployed staging | PR #20 merged before current stack | Existing PWA readiness tests/docs; physical install not performed | Re-audit current main after stack/UI integration; run desktop checks and prepare physical-device cases |
| QA-001 Complete synthetic journey | 10 | VERIFIED | INT-002, UI-002, UI-004 | Family -> Ops -> Companion -> Family persists with OTP, handover, return, issue privacy and denial controls | PR #28 head `1e956fc` | CI `42342439646` 7/7: care, issue and combined real-Supabase journeys pass; 17 screenshots retained | Re-run against deployed synthetic staging |
| QA-002 Physical mobile and language acceptance | 6 | BLOCKED | PWA-001, REL-002 | Android Chrome/PWA, small-screen/200% text and human Telugu/Hindi wording are signed with real evidence | Not applicable | No physical device or human language approval supplied | Founder runs device plan; named TE/HI and healthcare reviewers sign results |
| REL-001 Main PR/CI completion | 7 | IN_PROGRESS | INT-002 | In-scope stack and later UI release PRs are merged with required CI and exact SHAs recorded | #22-#27 merged; draft PR #28 head `1e956fc` | PR #28 CI `42342439646` 7/7; APK and screenshots reviewed | Complete final review/docs, mark ready, final CI, then merge normally |
| REL-002 Synthetic staging deployment | 8 | BLOCKED | REL-001, PWA-001, QA-001 | Exact main commit and compatible migrations deploy only to positively identified synthetic staging; URLs and role workflows are verified | ATTEST-001 on PR #28 source `8646f56` | Identity verified; three Nov 4 effects missing; history diverges; no usable backup/PITR/restore proof | Founder reviews attestation, then authorizes one backup/recovery task; no rollout yet |

## Progress calculation

Current evidence-weighted state at 2026-11-07 11:02 IST:

- Implemented: 73/100 (STATE-001, INT-001, INT-002, UI-001, UI-002, UI-003, UI-004, PWA-001, QA-001)
- Verified: 65/100 (STATE-001, INT-001, INT-002, UI-001, UI-002, UI-003, UI-004, QA-001)
- Merged into current `main`: 23/100 (STATE-001, INT-001, INT-002)
- Deployed and verified on synthetic staging: 0/100 for this mission's target commit

These figures intentionally exclude earlier main functionality unless it satisfies
a named mission task. Blocked work remains in the denominator.
