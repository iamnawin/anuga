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
and both scoped design descriptions were retained. Other agents' worktrees and
source branches were not changed.

## Correction and boundaries

Local merge `3945399` includes exact Companion head `8770a0b`; merge `0b20189`
includes exact Welcome head `f5e9eb4`. Browser journeys now use a persisted trip
semantics identifier instead of full-name/time formatting, and follow the actual
pickup, handover checklist and completion-note pages. Exact trip/status replies,
persisted notes, private-note checks and denied reassignment checks remain.

The founder subsequently explicitly selected **include all completed changes,
with legal drafts read-only**. Local merges `07cd48e`, `d2d91e7` and `162d524`
include exact Family `429c0cd`, legal `30bdf3e` and error-handling `76e6e16` heads.
All five source heads are ancestors of the integration branch. Product conflicts
in the wider merge retained the new Family layouts, offline controls and retry
handlers while adopting typed failure notices. Browser assertions combine the
new Family wording with new Companion controls. Legal document approval fields
remain unset; no acceptance flow is enabled.

The new Companion UI belongs to `/app/`. `/companion/` remains the separate
legacy app, with its existing sessions and Android support. Existing signed-in
sessions open their role home; Welcome is a signed-out screen.

No RPC, database, RLS, authentication, provider or migration change is needed.
Deferred Companion onboarding/verification/availability/document contracts remain
deferred. Synthetic publication does not close production or human acceptance gates.

## Verification

- Hosted read-only role/endpoint smoke: 10/10 PASS on November 14.
- Ops lint/typecheck and discovery of both browser journeys: PASS.
- Companion/Welcome integration: unified 153/153 PASS; initial added-test cleanup
  failure corrected. Removing the visit identifier reproduced the expected zero
  matches; restoring it passed. Its cleanup now uses `finally`.
- Companion/Welcome combined staging build: PASS, all four apps and root routing.
- Wider five-branch full repository check: running on the integrated source.
- Full integrated checks, actual browser journeys, release build, PR/CI and
  deployment: in progress; results must be appended before delivery.

Expanded source162d524: scripts/check-all.sh ALL CHECKS PASSED on 2026-11-14 17:51:15 IST. DB209 pass/11 existing skips; Ops70 and lint/typecheck/build; shared39; legacy Companion58/3 existing skips; Family181/6 existing skips; unified157. Format and fatal-info analyzers passed. Logs: ignored artifacts/check-all-combined.log. No new integration CI result or live deployment inferred.

## Preview and first CI receipt


2026-11-14 18:02:22 IST - UI-PUBLICATION PR44: CI43594410252 six jobs SUCCESS (including Android builds), supabase-local failed only at new handover Playwright checkbox .check immediate-state assertion after actual pickup/centre transitions. Test now clicks and polls toBeChecked; no app/guard/backend change. Ops lint/typecheck and two browser-test discovery PASS after fix. Combined release build PASS and preview dpl_EvtXn4Tah4T47681zo1Jdax29z9r READY; preview app SHA256 C3DA804B8FEE7F0052CD35067A8E1D47B795CA03233DE577EE236F9C28B8AFB1 equals local. Actual browser Companion/Family synthetic sign-ins, Today/Visits/Me, essentials, consent and read-only Terms draft verified; four curated desktop PNGs added. Narrow widget matrix passed; browser viewport override did not apply, so these captures are honestly desktop. Live alias unchanged pending replacement CI.


Browser Family console had no errors. Companion console recorded one asynchronous browser-message-channel listener error; no product failure was demonstrated. No hosted trip/consent mutation was performed in the manual browser smoke. Real CI reached the new handover screen before the test synchronization failure. No CI or live publication success is inferred.
