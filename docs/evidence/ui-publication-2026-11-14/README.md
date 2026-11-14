# Missing live UI investigation - 2026-11-14

Agent: Codex. Worktree: `D:/AI-Workspace/Repos/anuga-ui-publication`.
Task: `UI-PUBLICATION-20261114`. Starting main: `29a8356`.

## Evidence and root cause

The founder entered the main site and reached `/app/`, where Companion still
showed the previous UI. Inspection of the existing production alias returned
deployment `dpl_Hh646SE3ibGmxdFQe23oYjBsYjuC`, created November 13 at 20:32 IST.

| Change | Observed source state at investigation | Publication state |
| --- | --- | --- |
| Root opens unified app | PR #41 merged, main `29a8356` | Published November 13 |
| Phone and OTP redesign | PR #32 merged | Included in existing published source |
| Patient consent screen | PR #33 merged | Included in existing published source |
| Initial Welcome | PR #34 merged | Included in existing published source |
| Family/Patient Home | PR #37 merged | Included in existing published source |
| New Companion screens | PR #36 DRAFT/OPEN, `8770a0b`; runtime `6aea386` | Preview only, `dpl_7vXnp3NqYb3qbYcSSH3xyKJeFVvz` |
| Blended Welcome hero | PR #43 OPEN, `f5e9eb4`; runtime `8a13349` | Not published to the main alias |
| Family Visits/detail/cancellation follow-up | PR #39 DRAFT/OPEN, `429c0cd`, previous seven-job CI PASS | Not published |
| Terms/Privacy reading screens | PR #38 DRAFT/OPEN, `30bdf3e` | Not published; documents DRAFT, acceptance disabled |
| Specific Family error notices and shared failure classifier | Pushed branch `feat/error-handling`, `76e6e16`; no open PR found | Not published; groups 1-3 implemented, 4-6 not started |

`vercel.json` explicitly disables Git deployments. The publication workflow is
manual (`workflow_dispatch`); pushes and green app jobs alone do not update the
alias. The Companion preview was deliberately separate from the live alias and
was built before the new Welcome hero existed.

PR #36 run `43406351667` failed in the browser journey on its obsolete card
selector. PR #43 run `43562467546` passed six jobs; the latest rerun failed at
`issue_handling.spec.ts:154` on the old Companion card selector. The earlier
Docker-port failure recorded in the Welcome publication checkpoint is historical,
not the last observed failure.

Neither implementation was overwritten. In an isolated current-main integration,
product sources merged automatically. Six shared tracking documents conflicted;
their contributions were retained together. `PRODUCT.md` had an add/add conflict,
and both scoped design descriptions were retained. Other worktrees, unpublished
Family follow-up, legal draft and error-handling branches were not changed.

## Correction and boundaries

Local merge `3945399` includes exact Companion head `8770a0b`; merge `0b20189`
includes exact Welcome head `f5e9eb4`. Browser journeys now use a persisted trip
semantics identifier instead of full-name/time formatting, and follow the actual
pickup, handover checklist and completion-note pages. Exact trip/status replies,
persisted notes, private-note checks and denied reassignment checks remain.

The new Companion UI belongs to `/app/`. `/companion/` remains the separate
legacy app, with its existing sessions and Android support. Existing signed-in
sessions open their role home; Welcome is a signed-out screen.

No RPC, database, RLS, authentication, provider or migration change is needed.
Deferred Companion onboarding/verification/availability/document contracts remain
deferred. Synthetic publication does not close production or human acceptance gates.

## Verification

- Hosted read-only role/endpoint smoke: 10/10 PASS on November 14.
- Ops lint/typecheck and discovery of both browser journeys: PASS.
- Full integrated checks, actual browser journeys, release build, PR/CI and
  deployment: in progress; results must be appended before delivery.
