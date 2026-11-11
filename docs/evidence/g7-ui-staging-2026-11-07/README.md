# G7 UI staging evidence

Latest approved read-only task (11 November): see
[synthetic staging attestation](STAGING_ATTESTATION.md). CI `43030310112` passed
seven jobs on `8646f56`. Current live definitions prove all three Nov 4 hardening
effects are missing; recovery is not ready. CLI access now works; earlier access
failure entries below are historical. No hosted changes or merges occurred.

## Task 4 recovery and delivery review (2026-11-11)

Recovered by Codex from `e80ffd028614a93ef20d1657001144fef755dfcd` on
`feat/g7-ui-staging`, PR #28 OPEN, ready for review, unmerged. GitHub run
`42363763847` is completed/success and has all seven required jobs successful
on that exact SHA. Existing artifacts and checks were reused; no application
build or runtime test was repeated during this recovery.

| Recovery category | Actual state / evidence |
| --- | --- |
| Completed and verified | Tasks 1-3 implementation; Task 4 automated app/DB checks, real-Supabase journeys, web build and CI APK; 17 retained journey screenshots. CI `42363763847` on recovered head; artifact run `42342439646` retained. |
| Implemented but not verified | Candidate behavior on the existing hosted staging project; source implementation exists but has not been deployed/attested there. |
| Partially completed | Broader PWA acceptance: manifest/base/icons and build are verified; current candidate browser install/cache/offline and physical-phone acceptance remain incomplete. |
| Not started | New work in this session beyond this receipt; no new feature, integration, merge or deployment. |
| Blocked | Physical Android Chrome/PWA, human TE/HI meaning approval, hosted migration-history/recovery attestation. Supabase access failure is the last observed Nov 7 result and was not re-probed on Nov 11. |

Local retained screenshot count was checked: 17 `pr28-*.png` files. Retained APK
SHA-256 was rechecked and matches
`206BFB44BCBA7881C3C3D02E338A8AFA66C2E635ACCC16D8A2279FC881660A0C`.
These are CI/disposable-environment captures, not a hosted preview or phone test.
The prior Task 4 complete entry means its automated evidence package, not all G7
or deployed-PWA acceptance. No new staging URL/deployment is claimed.

The current branch lacks UX_AUDIT/UX_IMPLEMENTATION_PLAN; both were read from
Gemini's remote workstream at `d75cf071ef5e54d5b47415aac612a11b8b08545f`
using `git show`. Their registers were not copied or changed. PR #29/V2 and
PR #30 remain separate. Stop for founder review after this documentation push.

Checkpoint: 2026-11-07 10:39 IST

## Scope and source

- Branch: `feat/g7-ui-staging`
- UI source commits: Family `0644dd9`, Companion `8eb152e`
- Documentation checkpoint: `d002ac0`
- Base main: `ea6d142`
- Hosted staging: unchanged; still the earlier PR #21 baseline
- Real patient data, paid providers, production and app-store publication: not used

## Implemented UI

Family/Patient-view and Companion visit detail now include a presentation-only
nine-segment progress strip using the exact ordered non-terminal trip states. The
exact localized status text and Family persisted event timeline remain the
accessible source of truth. Family issue handling derives progress from the last
persisted public non-issue event; private issue/Ops notes remain absent. Cancelled,
no-show and unresolved Companion issue screens do not show linear progress.

No API, RPC, migration, permission, action key, OTP prerequisite, note rule,
assignment behavior or session behavior changed.

## Local validation

`scripts/check-all.sh` passed on `8eb152e`:

| Check | Actual result |
| --- | --- |
| Root database/type checks | 209 pass, 11 environment-only skips, 0 fail |
| Ops console | lint 0 errors / 1 pre-existing hooks warning; typecheck, 70 tests and production build pass |
| Shared Dart | format/analyze clean; 29 tests pass |
| Companion | format/analyze clean; 66 tests pass, 3 environment-only skips |
| Family | format/analyze clean; 61 tests pass, 6 environment-only skips |
| Unified AnugaCare | format/analyze clean; 39 tests pass |

Focused tests were written and observed failing before implementation, then pass.
They cover nine segments and representative progress positions, issue fallback, terminal
hiding, denied/reassigned/failed refresh clearing, resumed persisted state and
narrow 200% English/Telugu/Hindi layouts.

## PWA and build evidence

The unified release web build completed with `--base-href /app/` and the existing
committed public synthetic project configuration.

- Manifest: `AnugaCare`, standalone, start URL `.`, theme `#00666B`
- Icons: four (192/512 plus two maskable)
- Generated base href: `/app/`
- Generated service worker and bootstrap: present
- The generated worker unregisters itself and has no fetch handler. Its presence
  does not prove offline launch or caching; those remain unverified on the target.
- `main.dart.js` SHA-256:
  `9317FDE602C67200A9CBCF367D3F4B61C717951A9DB432DD98EFA11BB96E8CA1`
- `flutter_service_worker.js` SHA-256:
  `DBFBE64AE5BE5B462ABB97338EB9AF783ED4ED57A8C73A53C2A44488A26F6416`
- source manifest SHA-256:
  `58123CAFA777A1EB627EF63C2F7E71AE38A406242848799989AAF0254446749A`

Local Android build is BLOCKED by the workstation, not failed: no Android SDK or
`ANDROID_HOME`. The branch GitHub workflow is the authoritative APK builder.

## Navigation decision

No map or navigation UI is shipped in this task. The three Flutter pubspec files
have no direct map, geolocation or `url_launcher` dependency; `url_launcher`
appears only transitively in lockfiles. The restricted Companion projection has
addresses but no authorized route, live location or provider ETA. Adding the
concept board's embedded map would therefore fabricate capability and add an
unapproved provider/privacy boundary. Existing state-machine navigation through
the visit remains unchanged.

## Actual baseline screenshots

These are real CI screenshots from PR #27 head `c9cbf9f`, run `42203978157`,
retained as the before-state visual audit. They are not generated concept art:

- `docs/screenshots/g7/baseline-companion-underway-c9cbf9f.png`
- `docs/screenshots/g7/baseline-family-service-issue-c9cbf9f.png`
- `docs/screenshots/g7/baseline-family-completed-c9cbf9f.png`
- `docs/screenshots/g7/baseline-ops-trips-c9cbf9f.png`
- `docs/screenshots/g7/baseline-ops-exceptions-c9cbf9f.png`

Visual inspection found no clipped text, horizontal overflow, hidden primary CTA,
logo distortion or broken card boundary in these captured states. The baseline's
missing at-a-glance lifecycle progress is the focused defect addressed by
`0644dd9` and `8eb152e`.

Updated authenticated screenshots, real-Supabase journeys and the debug APK are
pending the branch CI run after the release PR is opened. Physical Android/PWA
installation and human Telugu/Hindi meaning approval remain NOT TESTED.

First PR run `42341585083` passed all seven jobs and produced the Android APK,
but exposed an evidence-only defect: Playwright cleared the care-request output
directory when the subsequent issue spec started. The workflow now places those
screenshots under repository `artifacts/care-request`, outside Playwright's
cleaned output, and the Companion issue screenshot scrolls to its exact current
status so the progress strip is visible. Runtime behavior is unchanged; a fresh
CI run must verify the corrected evidence bundle.

## Release checkpoint: 2026-11-07 15:52 IST

Documentation head `7fa7cb2` also passed all seven jobs in `42343362420`.
Independent read-only review of `ea6d142..7fa7cb2` returned ready to merge with
no Critical or Important findings. Minor documentation inaccuracies are corrected
in the release receipt. The reviewer did not run tests or access hosted services.

Read-only Vercel inspection confirms account `iamnawin`, project `anuga`, alias
`anuga.vercel.app`, READY deployment `dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`.
Supabase `projects list` failed with `Access token not provided`. No management
connection or hosted migration-history/backup access was available. Required
next action: authenticate an authorized Supabase staging operator locally or
provide an operator receipt for project identity, migration history and usable
recovery coverage. Never paste credentials into chat. Hosted rollout is BLOCKED.

## Final branch CI and artifact review

PR #28 head `1e956fc` passed all seven required jobs in run `42342439646`:
database, shared Dart, Ops, Companion, Family, unified AnugaCare and real
Supabase. The real-Supabase job passed SQL/Edge tests, Ops browser E2E, Companion
and Family journeys, Request Care -> Ops -> Companion -> Family, private issue/
explicit resume, the combined billing/notification journey and artifact upload.

The corrected artifact contains all 12 care-request screenshots and all five
issue-handling screenshots. Curated copies are under `docs/screenshots/g7/` with
`pr28-care-` and `pr28-issue-` prefixes. Visual inspection found:

- no clipped labels, horizontal overflow, hidden primary CTA, overlapping
  controls, broken card boundary or logo distortion in captured screens;
- Family request/review copy truthfully distinguishes submission from confirmed
  availability;
- Family assigned/at-centre/completed views show persisted data and the new
  nine-stage progress without private incident text;
- Companion assigned view shows restricted essentials, exact status and the
  new progress strip; no vault/diagnosis/DOB or fictional map/ETA appears;
- Ops pending/assigned/completed and exception views remain readable and expose
  internal issue context only to Ops.

CI Android debug APK:

- size: 159,679,563 bytes
- SHA-256:
  `206BFB44BCBA7881C3C3D02E338A8AFA66C2E635ACCC16D8A2279FC881660A0C`

This proves automated buildability, not physical installation. Real Android
Chrome/installed-PWA behavior and human Telugu/Hindi meaning remain NOT TESTED.
