# Handoff

Updated 2026-10-16. Branch `docs/product-inventory-bootstrap`, isolated worktree
`D:/AI-Workspace/Repos/anuga-product-inventory`, audited main base
`64c4603e5812358f6030ab8c9038747a93ba9b40`. Founder authorised reviewing/correcting and committing bootstrap files only;
the task commit records the result. No push/merge/deploy.
Start at [docs/README](README.md). Prior main receipts are preserved intact in
[historical handoff](HANDOFF_HISTORY_2026-10-16.md).

## Excalidraw clarification (2026-10-16 follow-up)

Parsed and visually inspected all 12 original embedded image boards: 48 numbered
concepts, not editable controls. Standalone PNGs total 15 because corrected boards
13/14/15 supersede older 3/6/12; Excalidraw still contains the older versions.
AUDIT_BASELINE records observed differences and preserves printed numbers 01-48.
Added consent 04 and Patient-home 25 specs; ROLE_HOMES explicitly maps 13/25/31/41
and distinguishes the unbuilt simplified mode/Ops metrics. Contributor paths remain
disjoint. Docs checks only; no app change or Excalidraw edit. Follow-up evidence is retained; this review authorises the scoped documentation
commit only. No push/merge/deploy. Pilot direction is now recorded in ADR 0006.

## Current task and result

Founder asked to read the supplied Markdown and commit existing work first, then
explicitly selected "Carry out the documentation bootstrap." Initial checkpoint
`5ec8f776145cb44c4f97feaa254e1ee46981e89f` on historical branch
`claude/trusting-bell-4fgv07` preserves research/design and older handoff/task edits.
It does not contain cancellation implementation. Local .omx state was excluded.

Completed documentation: linked start page; screen inventory (36 existing views/
dialogs, 22 absent dedicated concept views); 14 component contracts; 21 feature
records; work board/agreement/templates; entry/phone/login OTP/three role-home
specifications; dated correction of stale brand/model/storage/current-status text.
All 15 boards visually inspected: 60 panel instances/48 distinct concepts, including
12 superseded instances. No application or SQL implementation in this task.

Evidence and scope caveats: [audit baseline](product/AUDIT_BASELINE.md),
[screen ledger](product/SCREEN_INVENTORY.md), [features/permissions](product/FEATURE_MATRIX.md),
[task receipt](delivery/tasks/ANU-001.md). Research/screenshots copied from checkpoint;
original research dates and historical claims retained. Supplied brief copied as
reference, not an independent source of execution authority. No tools installed, additional agents, issues, push/PR, merge, deploy or publish.
Founder subsequently authorised a bootstrap-only commit after this review.

## Current code, PR and release boundaries

Main `64c4603`; PR #10 `c561a9d` remains open/unmerged (weekday editing/range wording).
PR #11 `1a91a68` is open/unmerged (general companion cancellation notice). Fresh PR
evidence supersedes the old local receipt saying cancellation was uncommitted;
that implementation worktree status was clean. Neither feature is on main or
proved deployed. PR #2/#4-#7 remain open but their integrated changes are on main;
#3 is obsolete. Do not merge/cherry-pick any PR as part of this documentation.

Historical synthetic release source `de8f72a` and deployment/CI/session receipts
are in docs/evidence/hosted-test. No current hosted browser/schema probe was made.
Main-based inventories are source inspection, not a fresh app verification claim.
M0-M9 history is preserved; M10/production/real data/paid providers remain gated.

## Checks and limits

Final acceptance review PASS: 38 bootstrap paths, 260 resolving local links,
99 unique declared IDs, all 60 panel instances and 18 source screen/route files;
research/brief/archive preserved. ANU-002/003 owned spec sets are disjoint.
Fresh node artifacts/bootstrap-review/validate.cjs and git diff --check pass.
The helper and manifest are ignored local audit artifacts, excluded from commit.


- Initial checkpoint: staged whitespace check passed; Excalidraw JSON parsed,
  all 19 PNG signatures checked. Only .omx remained untracked in that checkout.
- Bootstrap: documentation links, unique declared IDs, 60-panel coverage, source
  path coverage, copied-input identity, docs-only scope and whitespace checks
  are recorded with final results in ANU-001 receipt.
- Initial docs audit PASS (before follow-ups): 35 paths, 243 resolving local links, 99 unique declared
  IDs, 60 panel instances, 18 mapped screen/route source files; copied research
  and historical archive preserved. No out-of-scope edits; whitespace clean.
- Not run: app/database suites, runtime/browser/device checks, native-language
  review, hosted schema/deployment verification. Fresh worktree has no dependency
  install; no installs or builds permitted in this documentation task. Existing
  test-source assertions and historical green receipts are not current passes.

## Blockers and exact next task

D1 is resolved: ANUGA welcome with Family/Patient and Companion links, Ops dedicated
URL. Ops provisions pilot users; self-service registration is deferred. Backend
records determine roles/patient access; confirmed unprovisioned authenticated users
need setup pending. ADR 0006 records current Auth conflicts (null-role rejection,
no readiness state, Flutter restore gate) before any code change. Remaining D2:
authorised provisioning/readiness procedure, patient/schedule creation, consent
and help route. D3 verification process; D4
cutoffs/charges/compensation; D5 readiness/active return; D6 needs/preferences; D7
PDF/providers/retention; D8 mobile consolidation remain visible in AUDIT_BASELINE.

Recommended next task: specify readiness/provisioning contracts under [ANU-002 entry and access spec](delivery/tasks/ANU-002.md),
then authorize one implementation slice with exact source-path ownership.
[ANU-003 Family first-use](delivery/tasks/ANU-003.md) is a disjoint proposed spec
package; no contributors have been started. Coordinator owns shared docs.
Do not start either implementation in this run. Bootstrap acceptance review and pilot direction are included in the founder-authorised
bootstrap commit. No push/merge/deploy; no application code changed.
