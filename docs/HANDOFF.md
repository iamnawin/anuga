# Handoff

## Current: preview switching/refresh usability fix (2026-10-17)

Founder reported the preview was not working properly and confirmed the failing
action was switching apps or refreshing. Sole coordinator, branch
`feat/anu003-family-first-use`, clean task base `22a9969`, same isolated worktree.
Scope is only preview shell, browser regressions and required documentation.

Fixed stale Welcome/app highlighting, selected app lost on reload and iframe
history interfering with browser Back. The shell now owns app-switch history,
keeps the selected path in the URL, intercepts the actual Welcome sign-in links
and marks the active app with aria-current. Mobile controls wrap without label
squeezing/clipping, meet 48px targets, and the frame fills remaining viewport
height beneath the naturally sized header. Existing welcome page, app builds,
Auth/RPC/SQL and browser-local simulated records/sessions remain unchanged.

The screenshot's rightward welcome offset was not reproduced at standard browser
widths: before and after, centring/overflow checks pass at 360/1356/1920px. Do not
claim a diagnosed cause for that particular screenshot. Confirmed functional and
mobile faults have explicit failing-before/passing-after regressions.

Updated the same isolated demo alias https://anuga-interactive-preview.vercel.app,
deployment `dpl_DRzRP9fKc4SVfqzosjoa7ctjWGTT`; immutable URL
https://anuga-interactive-preview-jyrv7bbxq-iamnawins-projects.vercel.app.
Only deployed index.html changed; hashes confirmed all 136 other published
assets match the previous receipt. No app rebuild was needed for a static shell
fix; copying the edited HTML into existing prebuilt output is the entire build
step. A normal full build uses the same source via the existing build script.
Existing Anuga project/domain/backend remain separate.

Exact fresh checks/results and screenshot/deployment/source-hash receipt:
[preview navigation verification](evidence/preview-navigation/README.md).
PASS: entry local/hosted 9/9 each; journey local/hosted 10/10 each including
same-tab role switching and refresh, zero page errors/hosted backend requests;
simulator 6/6. check-all exit 0 (PGlite 157/9 real-only skips, Ops 60, shared Dart
28, Companion 51/3 skips, Family 58/6 skips, all static/build checks pass).
Real backend/native/device/human acceptance not rerun for this shell-only fix.
The commit containing this section records the fix and receipt together; latest
preview publication authority includes its normal branch push, not a PR/merge or
product rollout. Remote CI is not claimed. Native/human/ANU-003 B1-B4 gates remain.
Exact next task: founder refreshes the same demo URL and retries switching apps;
other product work still requires its own task scope.

## Previous: interactive synthetic preview publication (2026-10-17)

Resumed the latest recorded founder-authorized demo task on
`feat/anu003-family-first-use`, base `96bdc59`, in
`D:/AI-Workspace/Repos/anuga-product-inventory`. Preserved the existing supported
ANU-003 implementation and evidence. Sole coordinator writer; other worktrees and
the remaining ANU-002/native/human/rollout gates are unchanged.

Public synthetic demo: https://anuga-interactive-preview.vercel.app.
Actual Family, Companion and Ops web builds use only the unreachable
`synthetic-anuga.invalid` hostname, answered by the demo service worker. IndexedDB
shares simulated visits across role tabs; app sessions remain separate. The
always-visible simulation label and guide describe accounts, reset, limitations
and unavailable features. No hosted Supabase or real-user mutation.

Dedicated Vercel project `anuga-interactive-preview`
(`prj_31olZNOfP2UD4kW24PBp9hB1HVVx`), deployment
`dpl_Bg21GnKrJWod9LaX1MRPgPWPzfSk`. Its production alias hosts only the synthetic
demo; this does not launch M10. The initial preview on the existing `anuga` project
was unsuitable: protection redirects prevented service-worker startup. That
protected draft remains, but is not the delivered demo. Vercel CLI generated a
project automation-bypass token while diagnosing it; no token/cookie is committed.
No protection toggle or existing-domain change. Existing `anuga.vercel.app` still
points at `dpl_FHuVVy4Th8XzxEqQAz3Ekc1ZFyN3`, confirmed by CLI inspection.

Fresh checks: simulator 6/6; local browser 8/8; scripts/check-all.sh exit 0
(PGlite 157/9 environment skips, Ops 60, shared Dart 28, Companion 51/3 skips,
Family 58/6 skips; all lint/format/analyze/typecheck/build checks pass).
Hosted browser outcome, deployment hashes and final publication receipt:
[interactive preview evidence](evidence/interactive-preview/README.md).
The initial hosted harness timed out waiting for slow assets/network-idle despite
rendered Family UI. Final harness waits for actual screen assertions and uses
HTTP/1 in this environment; no app behavior was changed to make the test pass.

Latest preview authority supersedes the previous no-commit/push/deploy boundary
for these owned ANU-003/demo changes only. Commit and normal branch push are
included; no merge or PR creation. Build artifacts, environment files, cookies
and local diagnostics remain ignored. [Usage/build guide](../preview/README.md).
The commit containing this receipt records the supported UI and demo together;
its branch includes the previously reviewed ANU-001/ANU-002 ancestor commits.
Source/publication commit `f2d57155f6ea4917206a23d667027e6bc55c4cd3` was pushed
normally to `origin/feat/anu003-family-first-use`; `git ls-remote` confirmed that
exact remote head and the working tree was clean. This subsequent documentation
receipt records the actual push; no application or deployment change. No PR or
merge was created. Remote CI results are not claimed by the local check receipt.
No ancestral backend migration was applied to hosted Supabase. Final hosted
browser checks passed 8/8, zero page errors/hosted Supabase requests. Final staged
review: 74 owned files, 311 local Markdown links valid, no credential-pattern or
forbidden-artifact findings, whitespace check clean. Logs normalized to UTF-8/LF.
Exact next task: founder tries the demo; review the supported ANU-003 diff and
resolve its B1-B4 decisions before implementing intake/help/Patient-mode changes.
No further feature task, main merge or product deployment is inferred.

## Previous: ANU-003 supported Family first-use slice (2026-10-17)

Owner Codex coordinator, sole writer; branch feat/anu003-family-first-use in the
isolated inventory worktree. Base 96bdc59527d6f2277f484d09eb057c925147b849 confirmed
ancestor/HEAD; fetched main 64c4603. Clean on entry. All this task's changes remain
uncommitted; nothing staged, pushed, merged, deployed or modified on hosted systems.
Other worktrees/owners, ANU-002 Auth/lifecycle, backend and shared APIs untouched.

Supported slice locally implemented: home loading, neutral zero-linked-patient
state, generic error versus explicit denial with visible Refresh; booking-range
caption, empty/error/loading and visible/pull refresh. Reload hides previous
patient/visit data, rejects late completions and preserves a still-authorised
selected UUID; changed selection/access resets Bookings. Existing visit actions,
owner consent, records/bills permission gates and Patient routing preserved.
No unsupported create/setup/help/calendar/simplified-mode controls added.

Checks PASS: scripts/check-all.sh (PGlite 157/9 real-only skips; Ops 60; shared Dart 28;
Companion 51/3 skips; Family 58/6 skips, all format/analyze/lint/typecheck/build checks).
State tests 9/9; five failed on the old implementation, four pre-existing permission
scenarios passed. Last targeted rerun includes an explicit loading assertion added
after full-suite success. Preview web build PASS with absolute output path; 15 actual
web fixture scenarios PASS, including en/te/hi, dark/light, 360/430/1440 and 1.15/2/3x
text plus keyboard focus/scroll captures. No browser page/console errors. Glyphs,
empty/error/loading, large text and reused navigation visually inspected.
All preview data are labelled synthetic UI fixtures, NOT real Auth/DB acceptance.
[Receipt, exact commands/limitations and changed-file hashes](evidence/anu003/README.md).

Specific blockers/recommendations in ANU-003 B1-B4: approve patient intake/schedule
workflow within existing Family-only patient creation and owner/editor/Ops schedule
permissions; specify explicit owner-consent capture before future intake invokes
create_patient; supply one approved non-emergency help URI; decide any future
simplified Patient-mode routing. Recommendation preserves current Family routing,
permissions and purpose-consent UI. No real help destination found; no fake action.

ANU-002 implementation remains locally complete at 96bdc59; overall Partial for
native/device, human te/hi/accessibility, actual F1-F4 rollout approval, roster and
operator. Its ANU-002-VERIFY and all saved evidence remain unchanged. New real Auth/
Storage/device/hosted runs were not needed for this UI-only change and not performed.
In-app browser connection failed due an environment module-mode problem; existing
Playwright/Edge fallback used locally. First preview build failed on Windows
relative shader-output paths; absolute output worked. Initial Hindi captures
preceded fallback-font readiness; final captures wait for fonts/network and replace
them. Lazy-list text matching/scrolling in the capture harness corrected before pass.

Exact next task: review this uncommitted supported slice and its scope/evidence;
resolve B1-B4 before any new creation/help/Patient-mode UI. Native/human acceptance
and later rollout authority remain separate. Do not commit/push/merge/deploy or
start another task without its task authority. Local visual server/browser closed.

## Previous: ANU-002 reviewed local implementation commit (2026-10-17)

Implementation locally complete; ANU-002 remains Partial for device, human
language/accessibility and rollout acceptance. Sole implementation writer Codex
coordinator; read-only backend review made no edits. Branch
docs/product-inventory-bootstrap, implementation base 69bbb36, fetched main 64c4603.
Latest founder authority permits this ANU-002-only local commit. No push, merge,
deploy, hosted changes, real-user classification or real operator designation.
Actual F1-F4 approval, rollout roster/operator and M10 remain gated.

Review PASS: no concrete permission escalation, existing-session bypass, unsafe
backfill or audit defect. Added exact operator-audit details and idempotent retry
assertions, corrected task RPC-coverage wording and obsolete current status text.
No production code changed during review. Saved implementation hashes/results
were checked; curated ignored .log evidence explicitly included after secret scan.
Full scope/findings/evidence and exact ANU-003 dependency report:
[review receipt](evidence/anu002-review/README.md). The commit containing that
receipt is the reviewed implementation commit; use git log on the receipt for SHA.

Fresh review checks PASS: all fast checks (PGlite 157/9 skips; Ops 60; shared Dart 28;
Companion 51/3 skips; Family 49/6 skips), strengthened lifecycle 11/11, root typecheck,
and fresh real local PostgreSQL/Auth/Edge 166/166 zero skips. Previous real Auth/
Storage/Flutter/browser/locale/session results were inspected, not relabelled as
newly rerun. The same unchanged production code underlies both evidence sets.
Synthetic local stack stopped; task-started Docker daemon stopped with no other
containers running. No local credentials/build output are included in the commit.

Signed URLs: preissued download remains usable until observed 60s expiry; upload
claims 7200s lifetime and survives disable. Actual expiry rejection tested with a
separate same-image 5s probe; full two hours not observed. New signing/confirmation
is denied. Cached data/in-flight work cannot be recalled; hosted TTLs unknown.

Remaining checks: no Android SDK/device, no iOS/macOS/Xcode, incomplete Windows
native prerequisites; mobile lifecycle/keyboard/offline, human te/hi copy review,
screen readers and full accessibility matrix. ANU-002-VERIFY lists all open checks.

ANU-003 inspected only: unassigned documentation package owning its task file,
SCR-FAM-001 and SCR-FAM-032 only. Lifecycle/readiness contract resolved locally;
its old unresolved wording needs its owner's reconciliation. Patient/schedule
creation authority/procedure, owner consent capture, help destination and Patient-
home routing remain open. Current create_patient stays Family-only. Existing-state
specification can proceed while recording these blockers; new controls/code cannot
be inferred. No ANU-003 edit, assignment, branch creation or implementation here.
Exact next task: assign remaining acceptance or separately authorise ANU-003's
bounded spec review using the reviewed ANU-002 commit as a read-only contract.

## Previous: ANU-002 lifecycle locally implemented (2026-10-17)

Sole owner Codex coordinator, branch docs/product-inventory-bootstrap, worktree
D:/AI-Workspace/Repos/anuga-product-inventory. HEAD 69bbb36 and fetched main
64c4603 unchanged. Existing uncommitted work preserved. No commit, push, merge,
deploy, hosted changes, real-user classification or real operator designation.
F1-F4 defaults are provisional local-development assumptions, NOT rollout approval.
ANU-002 remains Partial/unreleased; ANU-003 remains separately owned/unassigned.

Implemented new pending/active/disabled state/version migration, safe self-only
resolver, audited/CAS owner-only management, restrictive RLS and every user-definer
RPC guard. Existing sessions are denied on subsequent protected requests after
disable. No grants/consent restoration; Companion/Ops patient links cannot confer
Family/clinical rights. Both Flutter gates/Ops consume authoritative state and
invalidate on lifecycle-denied requests; ordinary patient denial stays distinct.
Local Auth globally disables signup while preserving email/SMS provider sign-in.
No historical migrations, package/lockfiles, ANU-003 home/spec paths or prior
research/design/evidence were changed by this lifecycle step.

Verification: fast check-all PASS (PGlite 157/9 skips; Ops 60; shared Dart 28;
Companion 51/3 skips; Family 49/6 skips, plus formatting/analyze/lint/typecheck/build).
Fresh real Supabase suite 166/166, zero skips. Fresh real Flutter Companion 1/1,
Family 2/2. Contract export unchanged (51 transitions), root typecheck PASS.
Real Auth all roles with SAME JWT, denied management, grant/consent non-restoration,
local Storage and browser sign-in/reload/sign-out isolation PASS. Actual en/te/hi
pending/disabled views, live existing-session disable and te/hi phone/OTP capture
checks PASS; 42 curated screenshots. Exact commands/logs/source hashes and changed
paths: [current receipt](evidence/anu002-lifecycle/README.md). Scope check preserves
all 465 starting files (414 byte-identical, 51 reserved extensions); all 182
protected paths unchanged. Local documentation links and whitespace checks pass;
nothing staged.

Storage residual: preissued download works until measured 60s expiry (then 400);
preissued upload works with a measured 7200s lifetime even after disable. New signing
and confirmation denied. Same-image isolated 5s upload probe expired with 400;
we did not wait two hours. Cached data/in-flight work are not recalled.

Not verified: Android SDK/device absent; no iOS/macOS/Xcode; Windows native build
prerequisites incomplete. No native-language human te/hi review, screen-reader
acceptance or complete device/accessibility matrix. No actual rollout F1-F4
approval/reviewed real roster/operator. Hosted settings/TTLs/SMS remain unknown.
[ANU-002-VERIFY](delivery/tasks/ANU-002-VERIFY.md) owns those explicit open checks.

Exact next task: assign native/device and human-review acceptance; record actual
rollout decisions separately. For further local engineering use the contract and
BE receipt, not older historical blocker text below. ANU-003's Family first-use
spec remains a separate reservation with patient/schedule actor, owner-consent and
help dependencies; no home/wizard implementation is authorised by this receipt.
Task-specific no-commit/push/merge/deploy boundary still applies. Test server and
all eight task-local Supabase containers stopped; isolated expiry probe removed.
No other containers were running; task-started Docker daemon stopped afterward.

## Previous follow-up: ANU-002 backend preparation (2026-10-16)

Latest request is documentation only. All preceding uncommitted entry code and
evidence are preserved. HEAD 69bbb36 and fetched main 64c4603 unchanged; branch
docs/product-inventory-bootstrap. No code/SQL edit, migration/provisioning action,
commit, push, merge or deploy. ANU-002 remains Partial/unreleased.

[Access contract](product/PILOT_ACCESS_CONTRACT.md) now fixes the technical design:
profiles account_state/version, self-only resolver, owner-operated private command,
existing audit_log, restrictive RLS plus complete user-RPC active guards, exact
reviewed synthetic backfill in one atomic migration. No new table/role/service.
Source inspection found direct-UID trip/notification paths, so role-helper changes
alone would be insufficient. Old JWT requests must be denied after disable commit;
in-flight work/issued URLs/cached data limits are explicit.

Only business F1-F4 need founder answers: authority/operator, actual existing roster,
disable/reactivation operational effects, and issued-capability expiry acceptance.
Recommended defaults in the contract are not approval or consent.
[ANU-002-BE](delivery/tasks/ANU-002-BE.md) is a narrow prepared implementation
package, Unassigned/not executing; [ANU-002-VERIFY](delivery/tasks/ANU-002-VERIFY.md)
explicitly queues real Auth/Storage/old-JWT, device, te/hi visual/accessibility and
combined-local session/routing acceptance. Backend/UI verification has not occurred.
ANU-003 remains separately owned/unassigned; no home/spec/consent changes.

Exact next task: record real F1-F4 answers and a reviewed synthetic roster; coordinator
reserves one backend owner/path set, then executes ANU-002-BE only with new task
authority. After backend, separately reserve resolver-client integration and the
verification tasks. Do not infer setup pending from no patients or treat matching
legacy role as pilot approval.

Validation passed: 118 local documentation links, whitespace/scope checks; only
nine existing docs and two new task docs changed. All other 454 pre-existing
files, including all 19 prior tested source files, are byte-identical to step entry.
Runtime suites are not rerun for prose; results below remain prior local
evidence. Historical release evidence remains historical.

## Previous: ANU-002 partial implementation (2026-10-16)

Sole owner Codex coordinator; branch docs/product-inventory-bootstrap, worktree
D:/AI-Workspace/Repos/anuga-product-inventory. HEAD remains 69bbb36; fetched main
64c4603. Clean at entry; all current changes intentionally **uncommitted**. No push,
merge, PR or deploy; no additional agents. Original checkpoint/research preserved.

Implemented locally: two-link ANUGA welcome with en/te/hi/dark/focus/large text;
existing phone/OTP with busy locks and stale-code clearing; Flutter role checks
before restored/post-OTP home and on resume, expiry/race handling; Ops lookup
errors vs missing profiles vs wrong-role denial with recheck/sign-out. Existing
SQL/RPC patient permissions, session isolation and no-self-signup remain unchanged.
No patient/grant/consent creation or ANU-003 home/wizard work.

[Task/reserved paths/acceptance](delivery/tasks/ANU-002.md),
[backend contract and specific blocker](product/PILOT_ACCESS_CONTRACT.md),
[evidence/source hashes/screenshots](evidence/anu002/README.md). Current status is
Partial, local verification only, not released. Matching legacy roles still enter
existing home; default Family profile does not prove Ops-approved provisioning.

Checks: scripts/check-all.sh exit 0; DB 142 pass/8 skips; Ops 58; shared Dart 27;
Companion 49 pass/3 skips; Family 45 pass/6 skips. Lint/typecheck/build, Dart
format/analyze pass. Shell syntax/whitespace pass. Browser four welcome/five Ops
scenarios pass; 16 English Flutter renders inspected from font-adjusted test
harness. te/hi Flutter glyph fallback/native review unverified. Real Supabase,
provider OTP/journey, three-role session smoke, combined build, device and screen
reader not run (environment/scope). Historical release evidence stays historical.

**Blocker/exact next task:** within ANU-002 reserve backend lifecycle paths; decide
authorised operator/audit, legacy-user backfill, disable/reactivation treatment
of grants/trips/owner obligations; implement service-managed state/self-only
resolver and DB-wide disabled-session enforcement with allowed/denied real-stack
tests. Only then wire setup-pending/disabled UI. Missing profile remains
unconfirmed, not pending. No migration or implicit permission grant was added.
ANU-003 stays separately unassigned and depends on that result plus distinct
patient/schedule creator, owner-consent and help decisions.

## Historical: completed ANU-001 bootstrap receipt

The remainder records the preceding bootstrap task; its task-specific scope/next
steps are superseded by the current ANU-002 receipt above. Bootstrap commit 69bbb36
exists locally; this follow-up remains uncommitted.

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
