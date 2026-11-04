# AnugaCare physical Android and language acceptance plan

Version: 4 November 2026. Related decision: [production release gate](PRODUCTION_READINESS.md).
**Execution status: NOT TESTED on a physical Android device.** Available automation
and prior desktop captures are linked below; blank results are not passes.

## Entry conditions and test record

The test lead must complete this record for **each device and launch mode**.

| Field | Record before execution |
|---|---|
| Tester / date / timezone | Name; timestamp in IST |
| Device / Android / Chrome | Manufacturer/model, Android version, Chrome version; physical device confirmed |
| Launch mode | Chrome tab **or** installed PWA; separate result sheet for each |
| URL / deployment / source | Exact origin and deployment ID; approved candidate source SHA and app bundle hash |
| Backend / migrations | Project ref; latest applied migration; operator's schema/grants attestation |
| Display | Viewport/display scale/font scale; keyboard language and app locale |
| Accounts | Synthetic Family owner/viewer, Ops and assigned Companion; no real patient records |
| Test data | Exact patient, request/schedule and trip IDs; future pickup in IST, within approved start window |
| Network | Wi-Fi/mobile-data type; how connectivity is interrupted and restored |
| Evidence | Protected screenshot/video/log location, sanitized defect IDs; never OTPs, tokens or signed URLs |

**Source gate:** the current public synthetic alias was verified as PR #21's app
bundle during the audit. PR #22 is open; its November 4 migration was not applied
by the review. A test against that old alias may document baseline behavior but
cannot approve the new issue/pickup/refresh fixes. Stop candidate signoff until
the release operator separately supplies matching source, migrations and URL.
This plan itself does not authorize a rollout or apply any migration.

Use only pre-provisioned synthetic numbers whose test-OTP mappings the backend
operator has verified. Existing fixtures are owner `9000000101`, viewer
`9000000102`, Ops `9000000001`, Companion Asha `9000000201` and backup Ravi
`9000000202`. Obtain the configured synthetic login code securely; it is different
from a newly generated visit pickup code. Do not enter arbitrary/real phone
numbers or send real SMS. Stop if provider behavior/test mappings are uncertain.

Use a trusted computer and separate browser profile for Ops. The phone can switch
between Family and Companion by explicitly signing out; record both account
identities. A second isolated Family observer on a trusted browser can monitor
milestones while the phone runs Companion. Do not assume a Chrome tab and the
installed PWA provide independent simultaneous accounts on the same origin.

The test lead approves additive synthetic test records up front and records their
IDs. Never reset the hosted seed, run demo refresh, edit old active visits, weaken
permissions/time windows or delete records as part of this plan. Record created
records for later separately approved cleanup. Do not test a real payment.

## What automation can and cannot establish

| Layer | Reproducible check / existing evidence | What it proves |
|---|---|---|
| Local DB and app regression | From repo root, Git Bash: `scripts/check-all.sh` | PGlite allowed/denied rules, lint/typecheck/build, Dart/Flutter format/analyze/widgets; not hosted state or physical runtime |
| Real Supabase CI | [41840577234](https://github.com/iamnawin/anuga/actions/runs/41840577234); `supabase-local` job | Real Auth/Postgres/RLS/Edge behavior, desktop-browser care/issue journeys and test billing |
| Focused care/privacy | `node --test --test-isolation=none supabase/tests/care_requests.test.ts supabase/tests/issue_handling.test.ts` | Request, consent-at-submission, retries, private notes, guarded resume and original pickup facts; does not close the withdrawal defect |
| Family current refresh | `flutter test test/care_request_test.dart test/visit_progress_test.dart test/issue_updates_test.dart` in `apps/family_app` | Fake-backed out-of-order/failure/recovery, status and layout behavior |
| Companion current refresh | `flutter test test/visit_refresh_test.dart test/issue_waiting_test.dart` in `apps/companion_app` | Fake-backed refresh/resume and truthful issue waiting state |
| Shared login/lifecycle layouts | `flutter test test/routing_test.dart test/mobile_readiness_test.dart` in `apps/anugacare_app` | Fake-auth routing/expiry and simulated keyboard/Back/lifecycle; not actual refresh-token expiry or Android OS behavior |
| Catalogue/renderer structure | `node docs/evidence/production-readiness-2026-11-04/audit-static.mjs` | Key/nonempty/basic placeholder checks and notification rendering; not human meaning/approval |
| Safe public metadata | Add `--network` to the scanner | Public HTTP GETs/hash/auth-settings only; no OTP/sign-in or hosted writes |
| Known release failures | Disposable `consent-probe.mjs` and `inventory-local.mjs` in the same evidence directory | Current consent and overlapping-assignment observations; refuse a configured `DATABASE_URL` and never touch hosted data |
| Real device / human language | The checklist below | Must be executed by a person holding the recorded phone; tools cannot mark these passed from browser screenshots |

For a local full-browser rerun, use the existing Supabase-local CI workflow and
fresh disposable seed setup in SETUP; `CARE_REQUEST_JOURNEY=1` is required for the
care/issue specs. They write records. Do not point them at an arbitrary hosted
project or call `scripts/staging-smoke.ts` without verified test-OTP mappings.

## Physical execution checklist

Run D01–D14 in **Chrome**, then again in **installed PWA**. Record
`Pass / Fail / Blocked / Not Tested`, actual result and evidence per case.
Expected results are acceptance criteria, not a claim that they already occur.

| ID | Human action | Required observable result / evidence |
|---|---|---|
| D01 Install and identify | Open exact HTTPS candidate in Chrome; install via Chrome's install/Add to Home screen flow; launch icon; inspect identity/build in the test record | Correct product/origin opens in each mode; no old source substituted. Capture browser/PWA launch context and app build without credentials. Reopen after closing; no blank/stuck load. |
| D02 Login and real keyboard | On phone, choose EN, enter owner test number, request configured synthetic code; try one incorrect code then the correct code; change number and use system Back while keyboard is visible | Invalid code fails without entering account; correct code reaches Family. First Back dismisses IME as appropriate, subsequent Back navigates predictably; changing number clears stale code/error. All fields/actions reachable. No OTP captured. |
| D03 Logout and account switch | Sign out; relaunch; sign in as assigned Companion; sign out and use viewer; try Ops through unified entry | No former patient's name, visit, vault or bill remains. Companion sees only assigned trip essentials; viewer lacks request/OTP/cancel actions; Ops receives console direction rather than Family/Companion home. Record identity names/roles and denial UI without session data. |
| D04 Session expiry/refresh | Backend operator first verifies safe isolation and then revokes **only a disposable synthetic test session** or uses approved staging expiry controls; record the actual access-token expiry/refresh boundary; leave an open detail screen, resume/reload at that boundary; sign in again | Once refresh is required and fails, expired/lost session removes protected data/actions and offers sign-in; recovery restores only authorized current data. A successful silent refresh should preserve a valid session. Revoking a refresh session does not instantly expire an existing access JWT; do not mark a still-valid token as a failure. Record operator action and timing without exposing tokens; restart alone is not expiry proof. No project-wide timeout changes. |
| D05 Family requests care | Owner selects registered synthetic patient/centre and active package; enter future whole-minute pickup in IST; review and submit once | Review shows patient, package and exact IST pickup. One persisted request appears as pending, survives reload and is not labelled confirmed/available prematurely. Record returned schedule/request ID; no appointment/payment promise. |
| D06 Ops fulfils | In isolated Ops browser find exact schedule ID, confirm, assign eligible Asha (and existing backup flow where applicable) | Exact request produces one trip; assignment persists. Family phone refresh/reload shows confirmed/assigned state and actual companion. Record trip ID and assignee; do not alter unrelated trips. |
| D07 Pickup verification | Owner obtains visit pickup code transiently; phone switches to assigned Companion; start within existing start window; try one wrong pickup code then verify correct code | Normal advance cannot bypass verification; wrong code does not pick up; correct verification records picked-up status. Capture original pickup timestamp through the operator's authorized read, not a secret code screenshot. Another companion cannot access/act on this visit. |
| D08 Private issue and waiting | After pickup, report a synthetic issue with a distinctive harmless marker and required note | Blank note is rejected; issue status persists. Companion shows waiting/refresh guidance, not acknowledged dispatch/SLA. Ops sees private marker, time, prior stage and unchanged assignee. Family timeline/inbox/cards show service status and never the private marker. |
| D09 Explicit Ops resume | Operator enters a different harmless internal resolution marker; first dismiss confirmation, then explicitly accept resume to recorded picked-up stage | Dismissal does nothing. Accepted action resumes same stage and assignee; original verified pickup time remains identical; no second OTP pickup or arbitrary stage skip. Refresh/reload both roles. Neither marker appears in any Family UI. Operator records authorized DB/RPC verification, using the existing automated privacy checks for direct-read coverage. |
| D10 Stale incident action | Use two Ops contexts on this **test-created trip**: keep one issue screen stale after the other resolves it; attempt the old resolution, then refresh | Old action is refused and does not replay/change a newer incident. Missing-stage behavior is already SQL-tested; do not corrupt hosted trip data to manufacture it. Record refusal/current status. |
| D11 Finish exact visit | Same Companion records centre, handover, session finished, return, dropped home and completion with required public note; observe Family at each refresh where possible; return phone to Family | Ordered persisted milestones, unchanged assignment, completed status after reload in all roles. Family can read intended handover/completion note, but neither private issue/resolution marker. Final request/trip IDs agree and Ops exception clears. No fake completion shortcut. |
| D12 Poor network and refresh | On phone disable network during reads, refresh, restore it; on a second approved test-created visit interrupt a submit/action response after send, reconnect and explicitly refresh | Failed/denied reads do not leave stale actionable details presented as current. Reconnect recovers persisted state. Exactly one request/transition for one action intent; no queued/automatic replay or duplicate trip. Record network timing and request/trip/event IDs. If send-vs-response timing cannot be established, mark that subcase Not Tested and use controlled network tooling later. |
| D13 Back, background and OS return | Open booking/detail/inbox/record/bill where permitted; use system/browser Back, app switch, lock/unlock, background for approved intervals, swipe app away and relaunch; repeat after logout | Correct navigation and latest authorized state on return; no stuck spinner, duplicate action, resurrected session or previous account data. Observe real keyboard inset and scrolling; simulated lifecycle tests do not substitute for these results. |
| D14 Role/permission summary and evidence | Finish with owner/viewer/assigned/unassigned Companion and Ops spot-checks on new test data; collect sanitized per-case results and manifests | Viewer cannot request/pickup/cancel, Companion cannot view health vault/diagnoses/DOB or Family screens, unauthorized actions are denied by backend tests/operator reads. Never infer all RLS from hidden buttons alone. Record every created test record for later review; do not delete it now. |

If a critical step fails, record the exact last persisted stage and stop dependent
steps. Do not weaken RLS, consent, OTP or time windows to finish the checklist.
The D04 token-boundary expectation follows the
[official Supabase sign-out documentation](https://github.com/supabase/supabase/blob/master/apps/docs/content/guides/auth/signout.mdx).
The operator must verify the chosen revocation scope; do not revoke every session
for a shared test account to manufacture a single-device test.
The known consent-withdrawal failure must be fixed and policy-approved before
real-patient signoff; it is not a reason to experiment on an active real visit.
Test cancellation/rescheduling only as existing-language labels/permissions in the
screen matrix; building or expanding those workflows is outside this task.

## Language and screen matrix

D15: Execute each applicable row in **EN, TE and HI**, normal and **200% text**,
on the smallest supported physical phone/display setting selected by the release
owner. Record untranslated text, clipped/wrapped labels, obstructed buttons,
focus/keyboard/Back behavior and a screenshot reference. Check long realistic
synthetic names and dates; do not assume every overflow is caught by key parity.

| Role/surface | Required states and messages | Reviewer |
|---|---|---|
| Shared sign-in/account | Intro, phone/code validation, code-sent variable, changed number, loading, not-linked, Ops direction, offline error, expired session, sign-out | TE and HI native reviewers + device QA |
| Family bookings/request/detail | Empty/error/denied, patient picker, registered centre/package, date/time validation/review, pending/confirmed/assigned, every existing trip status, issue help, OTP labels, timeline IST timestamps, public note, refresh/recovery | Same |
| Family Updates | Assignment/change, each trip status, issue/resume/completion, no private notes, empty/error/refresh | Same + service/privacy reviewer |
| Family records/privacy | List/upload/view/errors, inaccessible file/PDF limitation, owner/editor/viewer differences, each consent purpose, withdrawal confirmation and resulting behavior | Same + healthcare/service/privacy reviewer |
| Family bills | Amount/month/lines, draft vs issued visibility, test-mode limitations, unsupported live checkout/error; no real payment | Same + finance reviewer |
| Companion list/detail | Previous/Today/Upcoming, empty/error/masked details, early-start explanation/time, each action/stage, wrong/expired/locked pickup code, required note/issue dialog, waiting guidance, closed trip, 108/non-clinical message | Same + healthcare/service reviewer |
| Ops sign-in/trips/schedules | Wrong-role/OTP/error, filters/dates, pending request/confirm/assignment/backup labels, validation, generation summary/count variables, loading/empty/failure | Same + Ops representative |
| Ops exceptions/billing | Internal/private labels, prior/missing stage, explicit resume/cancel confirmation, stale denial, amount/month/fare/bill states, raw diagnostic error detail distinction | Same + Ops/finance/privacy reviewers |
| Notifications | All rendered templates/statuses, date/currency/variable substitution, recipient language preference, note hint, issue wording; rendered in test adapter first | Same + healthcare/service reviewer; actual channel receipt is separately gated |

Approval is not “the text fits.” Reviewers must confirm understandable instructions,
correct healthcare/service meaning, consistent terminology and no claim of clinical
care, emergency dispatch, guaranteed availability or acknowledged issue response.
The report lists the consent/acknowledgement copy that needs reconciliation first.
Do not send a real notification to obtain language approval.

## Result sheet and signoff

Create one result row **per case and launch mode**, and one per language/screen row:

| Case / mode / locale | Actual action and persisted record IDs | Pass / Fail / Blocked / Not Tested | Evidence / defect | Tester / IST timestamp |
|---|---|---|---|---|
| D01–D15, not yet executed | Pending | Not Tested | No physical evidence supplied | Unassigned |

| Approval | Name / date | Approved source, environment, device and evidence | State |
|---|---|---|---|
| Physical-device QA owner | Pending | Pending | Not Tested |
| Telugu native reviewer | Pending | All applicable language matrix rows | Not Tested |
| Hindi native reviewer | Pending | All applicable language matrix rows | Not Tested |
| Healthcare/service wording reviewer | Pending | Meaning/scope/consent/emergency/issue guidance | Blocked until wording/policy reconciled |
| Backend/security operator | Pending | Schema/RLS/OTP/session/private-note parity | Not Tested |
| Release owner | Pending | All applicable production matrix rows closed or explicitly de-scoped with rationale | **NO-GO** |

Attach a retained-record manifest and defects to HANDOFF; cleanup is a separate
approval. A QA or language signature does not authorize deployment, payments or
real patient onboarding. Final founder release approval remains mandatory.
