# ANU-003 supported Family first-use receipt

17 October 2026. Owner Codex coordinator, sole writer. Branch
`feat/anu003-family-first-use`, isolated worktree
`D:/AI-Workspace/Repos/anuga-product-inventory`; clean entry and confirmed base
**96bdc59527d6f2277f484d09eb057c925147b849** containing the reviewed ANU-002.
Fetched main remains `64c4603`. Supported slice implemented locally; **ANU-003
remains Partial** for blocked interactions and remaining acceptance. Uncommitted;
no push, merge, deploy, hosted environment or real-user changes. Other contributors'
worktrees, Auth, SQL, shared APIs and design tokens remain untouched.

## Completed behavior

- Active Family accounts with no returned patients see a neutral current-link
  explanation and Refresh. No invitation/setup completion claim, pending inference
  or working-looking patient creation/help control.
- Patient lookup has loading, generic error and explicit permission-denial states,
  with visible retry/refresh. Patient header, privacy action and tabs are removed
  while revalidating or after failure/empty results. Old patient data is not kept
  underneath an error.
- Refresh retains the selected patient UUID if still authorised; otherwise selects
  the first returned patient. Selection/access-level changes reset to Bookings.
  Late responses cannot replace newer results; switching patients unmounts their
  keyed content.
- Bookings shows the existing API's yesterday-to-two-weeks range, a truthful empty
  panel, loading and error/denied states. Visible Refresh supplements pull refresh;
  empty lists remain scrollable. Old visit rows are removed before reload and on
  failure, including permission denial. Visit/back navigation reload remains.
- Existing owner/editor/patient/viewer actions, Records/Bills/Updates/Privacy,
  purpose-consent controls and Patient routing are preserved. No patient, schedule,
  grant, consent or lifecycle write was added.

Reused `CarePanel`, `CareHeading`, `familyTheme`, Material controls and existing
patient picker/tab navigation. New/changed copy is present in en/te/hi. Inspected
design board4:13–14 and board7:25 before editing; retain their readable patient/visit
hierarchy while omitting unsupported calendar, routine editor, verified avatar,
map, help/request and simplified-mode claims. No new dependencies.

The UI skill's context loader found no PRODUCT.md. Added a short Family context
file pointing to the existing approved product/access/token/spec documents; no
new visual identity or approval is inferred. The newer-skill advisory was not used
to update/install tools during this task.

## Actual verification

| Check | Actual result | Evidence |
| --- | --- | --- |
| New state regressions against original UI | Five failed, four existing permission-level scenarios passed | [Red run](state-red.txt) |
| `flutter test test/home_states_test.dart`, final source | **9 passed**, zero skips; includes explicit loading, neutral empty refresh, initial error/denial retry, revocation/stale-data removal, failed visit refresh/retry, selection/late results and four permission levels through visit/back | [Final targeted run](state-green.txt) |
| `bash scripts/check-all.sh` | PASS: PGlite **157 pass / 9 real-only skips**; Ops lint/typecheck/build and **60 tests**; shared Dart format/analyze **28 tests**; Companion format/analyze **51 pass / 3 skips**; Family format/analyze **58 pass / 6 skips** | [Full log](check-all.txt) |
| Targeted Dart formatting | Five affected Dart files unchanged by final format check | Command receipt in handoff |
| Explicit Flutter web fixture build | PASS with absolute output path; actual production widgets and existing synthetic adapters | [Build](build-preview.txt) |
| `node scripts/verify-family-first-use.mjs` | **15 scenario passes**, no page/console errors; 24 captures including large-text scroll, keyboard focus and error recovery | [Results](browser-results.json), [screenshots](screenshots/) |
| Source/scope, local links, whitespace and credential-pattern checks | See final machine-readable results | [Scope](scope.json), [source hashes and changed paths](source-hashes.json) |

The full-suite run preceded one additional loading assertion; the final targeted
9/9 run covers it. The only existing test edit updates the old empty-copy
expectation and checks Refresh. No failing permission check was removed/weakened.
Existing database tests exercise allowed/denied patient, schedule, consent and
lifecycle permissions. No SQL/shared-contract change requires a new migration.

Visual command (existing Flutter/Playwright/Edge only; no tool installation):

```sh
cd apps/family_app
flutter build web --target=test/home_preview.dart --output=<absolute-repo-path>/artifacts/anu003/preview
cd ../..
node scripts/verify-family-first-use.mjs
```

The test entry point is explicitly selected and never imported by production
`main.dart`. Local server binds only `127.0.0.1:3111` and closes with the browser.
Fixtures are labelled synthetic; this is actual Flutter-web rendering, **not real
Auth/DB/device acceptance**. Locale/theme/scale come from fixture parameters.
Scenarios cover home empty/loading/error/denied, bookings empty/loading/error/
denied, populated/multiple patients; en/te/hi, 360/430/1440, light/dark and
1.15/2/3x text. Visually inspected empty/retry/denial/loading/populated views,
Telugu/Hindi glyphs, narrow large text/scroll and keyboard focus. The existing
bounded patient-header scroll and horizontal navigation at large text remain.

Exploratory capture issues were corrected: initial Hindi shots preceded fallback
font readiness, and Flutter merged/lazy semantics required substring matching and
scrolling. Final captures wait for the expected state and font/network readiness.
An initial Windows relative-output shader build failed; absolute output succeeded.
Existing non-failing wasm/font-tree-shaking warnings remain. In-app browser setup
failed on the environment's module-mode configuration; repository Playwright with
Edge was the local fallback. These are not hidden product/permission changes.

No new real Auth/Storage/SMS/device/hosted runs were performed for this UI-only
slice. ANU-002's remaining Android/iOS/Windows-native, human Telugu/Hindi copy,
screen-reader/full accessibility and actual F1-F4 rollout/roster/operator checks
remain open in [ANU-002-VERIFY](../../delivery/tasks/ANU-002-VERIFY.md). Glyph rendering
does not establish linguistic correctness or native accessibility acceptance.

## Specific blockers

These are decisions, not permission changes made by this task:

| ID | Decision needed | Recommended option, still unapproved | Affected interaction |
| --- | --- | --- | --- |
| B1 | Pilot patient-intake actor/procedure and schedule creation/edit workflow | Retain Family-only `create_patient`; retain existing owner/editor/Ops schedule RLS. Specify the reviewed workflow/payload before adding UI. | Add patient, first booking, manage routine absent |
| B2 | Explicit agreement to `create_patient`'s owner/trips-consent effects and separate purpose-consent capture | Capture explicit informed action in future intake; reuse owner-only purpose changes in ConsentScreen. Activation/linking never implies consent. | No automatic patient/grant/consent creation |
| B3 | Approved non-emergency help URI, label, audience and availability | Use one reviewed destination once supplied. None was found in code/docs; do not invent a phone or request feature. | Help/Contact Ops/Call absent |
| B4 | Whether/how simplified Patient concept25 replaces or supplements Family home | Keep current Family route and four destinations until explicitly agreed; no new Auth role. | Simplified mode/router not implemented |

Patient provisioning is separate from account provisioning, patient links and
owner consent. No recommended option constitutes founder approval. These blockers
do not prevent the implemented read-only first-use states. Next: review this
uncommitted slice; resolve B1-B4 before extending controls or routing. Native/human
acceptance and later rollout authorization remain separate.
