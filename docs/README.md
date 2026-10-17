# Anuga documentation

Interactive synthetic demo: https://anuga-interactive-preview.vercel.app.
[Usage/build guide](../preview/README.md), [publication evidence](evidence/interactive-preview/README.md).
[Switching/refresh fix and verification](evidence/preview-navigation/README.md),
source commit `1d25ada`, pushed to `feat/anu003-family-first-use`.
It runs browser-local fixtures in a separate Vercel project; real backend, native,
human-language/accessibility and rollout acceptance remain separate.

Start here. Audit date: 16 October 2026. Implementation baseline: `main` at
`64c4603e5812358f6030ab8c9038747a93ba9b40`. This is a product inventory, not a
claim that M0–M9 cover every design or that the live site was retested today.

1. [Current handoff](HANDOFF.md): branch, checks, blockers and exact next task.
2. [Product requirements](PRODUCT_SPEC.md) and [decisions](adr/).
3. [Audit baseline](product/AUDIT_BASELINE.md): local work, main, PRs and release evidence.
4. [Screens and every reference panel](product/SCREEN_INVENTORY.md),
   [components](product/COMPONENT_INVENTORY.md), [features](product/FEATURE_MATRIX.md).
5. [Work board](delivery/WORK_BOARD.md) and [working agreement](delivery/WORKING_AGREEMENT.md).
6. [Design contract](design/tokens.md), [setup](SETUP.md), [synthetic walkthrough](LOCAL_TESTING.md).
7. [Milestone history](TASKS.md); [research](research/anuga-market-feature-study.md) is
   attributed input, not approved scope. [Supplied bootstrap brief](research/product-inventory-bootstrap-brief.md)
   is a proposal; current task authorization and the working agreement govern execution.

Pilot direction: [ADR 0006](adr/0006-pilot-entry-and-provisioning.md) records the
ANUGA welcome, two sign-in links, dedicated Ops URL and Ops-provisioned users.
ANU-002 implementation is locally complete and reviewed: lifecycle/backend and
authoritative entry gates under
F1-F4 provisional development assumptions, NOT rollout approval.
[Contract](product/PILOT_ACCESS_CONTRACT.md), [backend receipt](delivery/tasks/ANU-002-BE.md),
[actual local evidence](evidence/anu002-lifecycle/README.md) and
[remaining checks](delivery/tasks/ANU-002-VERIFY.md) distinguish local verification
from native acceptance/release. [Review and commit receipt](evidence/anu002-review/README.md).
The earlier ANU-002-only local-commit boundary is historical. Authorized separate
synthetic-preview publication includes the owned ANU-003 source and ANU-002
ancestors on `feat/anu003-family-first-use`, now pushed. No merge, real-user
rollout, hosted backend change or existing live-site replacement is authorized.

Current partial task: [ANU-002: implement entry and role access](delivery/tasks/ANU-002.md).
Its companion package [ANU-003: specify Family first-use](delivery/tasks/ANU-003.md)
now has an explicitly expanded UI/spec reservation on feat/anu003-family-first-use;
the coordinator owns its supported slice. [Current ANU-003 receipt](evidence/anu003/README.md).
Patient/schedule creation, consent/help and Patient routing stay separately gated. The coordinator owns
shared receipts; no parallel writers are running. Detailed slice specs: [entry](product/screens/SCR-AUTH-001.md),
[phone sign-in](product/screens/SCR-AUTH-002.md), [login OTP](product/screens/SCR-AUTH-003.md),
[consent 04](product/screens/SCR-FAM-010.md), [role homes 13/25/31/41](product/screens/ROLE_HOMES.md).

Use the [screen template](product/screens/TEMPLATE.md) and [task template](delivery/tasks/TEMPLATE.md)
only when scheduling work. Do not create an empty spec for every concept. Repository
WORK_BOARD owns task status; GitHub PRs own code review. No second tracker is active.
