# Audit baseline — 2026-10-16

## Provenance and scope

Auditor/coordinator: Codex, solo. Audit branch `docs/product-inventory-bootstrap`,
worktree `D:/AI-Workspace/Repos/anuga-product-inventory`, created from fetched main
`64c4603e5812358f6030ab8c9038747a93ba9b40`. Initial worktree status was clean.
No merges or cherry-picks. No application code, migration, dependency, generated
contract, provider setting or source location changed.

Original checkout `D:/AI-Workspace/Ideas/Anuga` is on `claude/trusting-bell-4fgv07`.
Founder requested a commit first: checkpoint `5ec8f776145cb44c4f97feaa254e1ee46981e89f`
preserves the research, fifteen boards, Excalidraw source and local HANDOFF/TASKS
receipts. `.omx/` remains excluded. Markdown line endings were normalized for the
checkpoint whitespace check; historical text was preserved. Research and its four
screenshots are copied here unchanged. Design PNGs already exist on main; those
copies are reused. The Excalidraw file remains in the checkpoint; it embeds the
original 12-board concept set and is not a second approved screen contract.

### Excalidraw reconciliation (2026-10-16 follow-up)

Parsed the original checkpoint's docs/design/Anuga.excalidraw: 12 active image
elements, 12 embedded files, zero text elements. Extracted all 12 images into
ignored audit artifacts and visually inspected them. They cover printed screens
01-48 in the twelve groups described by the founder. Controls are raster content,
not editable Excalidraw fields/buttons. Embedded images are not byte-identical to
the standalone PNG files; correspondence below is visual, not a file hash match.

The embedded recurring board retains 2024 dates and the old Basic waiting claim;
Family management retains specific medicine examples and wrong bottom navigation;
Ops management retains Family Owner headings and unsafe companion/centre vault
history examples. These correspond to older standalone boards 3, 6 and 12.
Prefer corrected standalone boards 13, 14 and 15 respectively, as already required
by tokens.md. Excalidraw itself has not been edited or brought up to date.

Thus 12 embedded boards = 48 original concepts; 15 standalone boards = 60 panel
instances including 12 superseded instances. They are not 60 distinct screens.
Printed numbers remain design references; SCR IDs track implementation views.
First slice explicitly includes consent 04 plus destinations 13/25/31/41, with
new patient mode and Ops overview capabilities still marked unimplemented.

The older checkout's 2026-10-13 cancellation receipt says implementation is
uncommitted. Fresh Git/PR evidence supersedes that claim: cancellation worktree
HEAD is `1a91a68`, its status was clean, and PR #11 is open. Historical research
proposals are retained with their original dates; this baseline governs current
status. Research market assertions were not researched again in this task.

## Main, PRs and release are different

Read-only commands: `git fetch origin`, `git rev-parse origin/main`, `git worktree list`,
`git status --short`, `gh pr list --state open`, `gh pr view 10` and `gh pr view 11`
(including head/base/files). PR status checked 2026-10-16; check again before integration.

| Evidence | State at audit | Meaning |
| --- | --- | --- |
| Main `64c4603` | Current fetched baseline | Inventories describe these source files unless explicitly marked otherwise |
| PR #10, `c561a9d27a2098c3ee5932b60e4e09ceb6ccb46e` | Open, base `64c4603` | Existing schedule weekday editor and trip-range wording; not intake/new schedule/checkout; not on main |
| PR #11, `1a91a68dbd51d34ecabe5add505855029b8ec684` | Open, base `64c4603` | General companion cancellation notices; PR #10 SQL is a test fixture, not integration; not on main |
| PR #2 and #4–#7 | Still open | Changes integrated via #8; open status alone does not mean absent from main |
| PR #3 | Open obsolete duplicate | Do not use as a base |
| PR #8 / #9 | Merged according to main history and handoff | Combined UI / hosting and session fixes |
| Checkpoint `5ec8f77` | Local commit on historical branch | Research/design input only; not application release |
| This documentation branch | Bootstrap review commit authorised 2026-10-16 | No PR, push, merge or deploy; see ANU-001 receipt |

Links: [PR #10](https://github.com/iamnawin/anuga/pull/10),
[PR #11](https://github.com/iamnawin/anuga/pull/11).

Historical release evidence (E-RELEASE): [deployment](../evidence/hosted-test/deployment.json),
[browser session receipt](../evidence/hosted-test/published-session-receipt.json),
[CI receipt](../evidence/hosted-test/ci-summary.json). Source
`de8f72abcaf7d00480ee6b8c9978f5cb8c09f812`, deployment
`dpl_FHuVVy4Th8XzxEqQAz3Ekc1ZFyN3`, synthetic site `https://anuga.vercel.app`.
Receipt records root, `/ops/login/`, `/family/`, `/companion/` HTTP 200, three-role
sign-in/reload/sign-out isolation and CI run 38150546061 (six jobs, real Supabase
150/150, Ops browser 7, full journey). These are prior receipts, not fresh checks.
Per-screen/per-state deployed acceptance is Unknown unless that receipt actually
covers it. Production: not released; M10 remains gated.

## Inspection and limits

- Visually opened every PNG in `docs/design/`: 15 boards, four panels each;
  60 instances, 48 unique printed panel numbers. Corrected 13/14/15 supersede
  3/6/12. See the exhaustive panel ledger in SCREEN_INVENTORY.
- Inspected all app screen/route files, shared phone/API/models/state-machine
  contracts, auth adapters/providers, Ops presentation components and RPC wrappers.
  Located test files and inspected targeted first-use/role/transition assertions.
  Inventories cite exact paths; tests located or read are not tests executed.
- Inspected migrations 0100–0900 for actor/access boundaries, projections,
  consent, notification and payment support; PR file lists separate pending work.
- Read AGENTS, CLAUDE, PRODUCT_SPEC, TASKS, SETUP, design contract, ADRs 0001–0004,
  UI evidence receipts and local research. No PROJECT_MEMORY or Graphify report
  exists in this checkout. Graphify generation is deferred: no tool installation
  or generated map is necessary to this documentation audit.
- Read available Obsidian Project Index and Decisions; Preferences and
  Mistakes-To-Avoid were unavailable at the configured paths. No vault write.
- No local app launched: fresh worktree has no installed dependencies, and this
  task excludes installation. No browser/device/backend/live schema inspection,
  native-language review or full app tests. Runtime verification is Not run today.
- No clinical, fee, cutoff, verification, contact or consent policy is approved
  by a concept image. Initial audit introduced no business policy; the subsequent founder-approved
  pilot entry/provisioning direction is recorded separately in ADR 0006.

## Decisions and remaining founder input

| Key | Decision | Dependency |
| --- | --- | --- |
| D1 | Resolved: ANUGA welcome, Family/Patient and Companion sign-in links; Ops dedicated URL | ADR 0006; ANU-002 local two-link welcome implemented/verified, unreleased |
| D2 | Pilot users provisioned by Ops; authenticated incomplete setup gets setup pending; self-registration deferred | ADR 0006 accepted direction. ANU-002 role/restore/error fixes local; lifecycle/resolver/backfill/disabled enforcement locally complete and reviewed under provisional F1-F4; actual rollout operator/roster and patient/schedule/consent unresolved |
| D3 | Which companion identity/background/training steps are manual, and who attests them? | Onboarding; no verified badge without evidence |
| D4 | Cancellation cutoff, late/no-show billing, waiting grace and compensation | Policy-dependent N2/N5; do not invent prices |
| D5 | Readiness actors, actual arrival/waiting measurement and active-return reassignment | Workflow beyond existing transitions |
| D6 | Mobility exclusions, preference/gender collection and consent | Structured needs/matching |
| D7 | PDF picker/viewer, real checkout/providers and retention after withdrawal | Supporting feature readiness; separate authorization |
| D8 | One role-based mobile app and final store identifiers | Separate architecture decision; keep two Flutter apps now |

See [FEATURE_MATRIX](FEATURE_MATRIX.md) for product gaps and [WORK_BOARD](../delivery/WORK_BOARD.md)
for bounded follow-ups. No missing decision is silently implemented.

ANU-002 working-tree evidence supersedes baseline entry implementation claims only;
see [access contract](PILOT_ACCESS_CONTRACT.md) and [receipt](../delivery/tasks/ANU-002.md).
Implementation base 69bbb36, main 64c4603; latest review permits the owned local
commit only. No remote integration or release change.
