# AnugaCare production readiness and release gate

Audit: **4 November 2026 (IST)**. Decision: **NO-GO for real patient onboarding**.

This is an audit of existing functionality, not authorization to launch. Core
Request Care, visit progress and issue handling are built and tested. A passing
feature review or CI run does not close the production gates below. No deployment,
merge, hosted migration, deletion, real SMS or payment was performed by this audit.

## Evidence boundary and release identity

Reviewed checkout: `D:\AI-Workspace\Repos\anuga-trips-fix`, initially clean on
`feat/visit-issue-handling` at `fd6c8dc53b45c7bbca01609ed9ca64f28028a5e4`.
Audit work is isolated on `docs/production-readiness-2026-11-04`, based on that
commit; application, database, build and workflow files are unchanged.
Documentation delivery: [draft PR #23](https://github.com/iamnawin/anuga/pull/23)
targets the unmerged feature branch. Its new CI is separate from the audited
product runs below; no success is inferred for a pending documentation run.

| Item | Verified state and evidence |
|---|---|
| Main / care / visit progress | Fetched main `21ae9bc`; PR #20 Request Care and PR #21 visit progress are merged. PR #21 merge was independently confirmed through GitHub metadata. |
| Work after `63b3ed6` | `335b58b` fixes original-pickup-time preservation on incident resume and stale Family booking refreshes; `fd6c8dc` records acceptance only. [Review receipt](evidence/issue-review-2026-11-04/README.md). |
| Issue handling PR | [PR #22](https://github.com/iamnawin/anuga/pull/22) is **OPEN, not merged**, head `fd6c8dc` at audit start. A non-null GitHub `merge_commit_sha` on an open PR is not evidence of a merge; `merged=false` and `merged_at=null` were checked. |
| Code-bearing CI | [41840577234](https://github.com/iamnawin/anuga/actions/runs/41840577234), source `335b58b`: **seven successful jobs**, real Supabase SQL/Edge checks, Ops browser tests, both care/issue browser journeys, full notification/test-billing journey and Android builds. [Exact summary](evidence/issue-review-2026-11-04/ci-summary.json). Product source at `fd6c8dc` is identical. |
| Documentation-head CI | `fd6c8dc` [run 41842285891](https://github.com/iamnawin/anuga/actions/runs/41842285891) also completed successfully: all seven jobs. [Repository snapshot](evidence/production-readiness-2026-11-04/repository-state.json) records the refreshed result. |
| Fresh local checks | Complete `scripts/check-all.sh` exited **0**, `ALL CHECKS PASSED`, during this audit. [Audit execution receipt](evidence/production-readiness-2026-11-04/checks.json). Environment-dependent skips are not hosted verification. |
| Current public synthetic deployment | Read-only authenticated Vercel inspect: `dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`, READY, Vercel target `production`. Public `/`, `/app/`, `/ops/login/`, `/family/`, `/companion/` GETs return 200. `main.dart.js` SHA-256 `116d8357eeee44b120d2ac617b844a5066dfafead42b961e87ce28cd6c6b0758` matches the PR #21 receipt/source `21ae9bc`. This attests that app bundle, not every asset or hosted policy. [HTTP/hash](evidence/production-readiness-2026-11-04/static-audit.json), [CLI metadata](evidence/production-readiness-2026-11-04/environment.json). |
| Issue preview / hosted schema | Historical protected preview is source `8f922ed`, not the November 4 fixes. Founder-reported application of `20261103000100` is historical evidence; no current authenticated schema dump/migration-history read was available. `20261104000100` was not applied by the previous review or this audit. Current hosted equivalence is **unverified**. |

**The Vercel production target is the existing synthetic test site, not an
approved real-patient production environment.** No separate real-data project,
production data inventory or production access configuration was attested.

Status meanings: **Pass** applies only to the named evidence/layer; **Fail** is an
observed unmet requirement; **Blocked** needs an owner decision/access/authorization;
**Not Tested** lacks execution evidence. P0 stops real-data onboarding; P1 must close
before the corresponding release capability; P2 is a bounded coverage/copy gap.

## Release gate matrix

| ID / requirement | Existing implementation | Evidence | Status | Severity | Responsible role | Required next action |
|---|---|---|---|---|---|---|
| R01 Candidate integration | PR #22 contains private notes, guarded resolution and Nov 4 fixes | GitHub PR #22; identity table above | Blocked | P1 | Founder / release owner | Review candidate and explicitly authorize any later integration; no automatic merge. |
| R02 Candidate CI and Android preservation | Seven-job checks, web build and debug APK builds | CI 41840577234; fresh local check-all | Pass | P1 | Engineering | Retain gates; rerun relevant checks after actual fixes/source changes. APK compilation is not a physical run or release signing. |
| R03 Synthetic public site identity | PR #21 app bundle is served; manual publication workflow | HTTP/hash and Vercel snapshot | Pass | P1 | Release owner | Keep synthetic-only; do not use old public app/preview to sign off PR #22. |
| R04 Source/schema parity in intended release | Private-notes and pickup-preservation migrations exist | `20261103000100...sql`, `20261104000100...sql`; historical migration receipt | Blocked | P0 | DB operator / release owner | Attest migration history, definitions/grants and matching app assets in the chosen environment under a separately approved rollout. |
| R05 Complete core journey | Real Auth/Postgres/RLS request, assignment, OTP, all stages and Family persisted reads | `e2e/care_request.spec.ts:60`, `e2e/issue_handling.spec.ts:47`; CI | Pass | P1 | QA / engineering | Preserve automated regression and repeat D01–D14 on the exact candidate/device. |
| R06 Physical Android Chrome and installed PWA | Desktop browser and widget evidence only | PWA receipt; `environment.json` lists Windows/Chrome/Edge only | Not Tested | P1 | Named device tester | Execute [Android plan](ANDROID_TEST_PLAN.md), attach device/build evidence for both modes. |
| R07 Session expiry/refresh/revocation and switch recovery | Unified fake-auth expiry tests; historical desktop hosted sign-in/logout/switch | `routing_test.dart:202,218`; PWA receipt | Not Tested | P1 | Auth engineer / device QA | Test real refresh failure/revocation at the actual access-token expiry/refresh boundary, OS suspend/relaunch and cross-account data clearing. Revoking a refresh session is not immediate expiry of an existing access JWT. |
| R08 Async auth identity race | Role resolution awaits in both entry points without a generation token | `AuthProvider.tsx:33-43`; unified `app.dart:80-98` | Not Tested | P1 | Auth engineer | Add delayed-role-versus-signout/session-ended regressions; fix only reproduced stale identity behavior. No DB bypass was established. |
| R09 Latest Family status / offline action recovery | Generation guards, clear-on-read-failure, mutation recovery and refresh/resume | Family `care_request_test.dart:82,103`; `visit_progress_test.dart`; Companion `visit_refresh_test.dart` | Pass | P1 | Engineering / QA | Pass applies to widgets; execute real-network D10–D12, including a lost mutation response without duplicate action. |
| R10 RLS, roles and direct access | Grants/RLS; DB role from profiles; restricted Companion/vault projections | `access.test.ts`, `trip_controls.test.ts`, vault tests; real-DB CI | Pass | P0 | DB/security owner | Keep allowed/denied tests and verify the actual release environment, not only local migrations. |
| R11 Private incident/Ops notes | Private sidecar; redacted events/outbox; Ops-only queue | `issue_handling.test.ts`; browser 4 RPC/3 table checks with Ops positive control | Pass | P0 | DB/security owner | Attest hosted cutover/backfill and no Family exposure in intended environment; preserve public companion handover/completion notes. |
| R12 Trip-consent withdrawal | Founder approved blocking all Companion actions/fresh details; additive DB trigger/RLS/projection and early pickup check implemented | `20261104000200_trip_consent_enforcement.sql`; `consent_withdrawal.test.ts`; [execution receipt](evidence/production-hardening-2026-11-04/README.md) | Blocked | **P0** | DB/security + Ops/release owner | Local 3 pass, 1 concurrency case awaits real Postgres CI. Verify hosted parity and approved active-visit safety workflow; fresh reads cannot erase already downloaded data. No emergency override. |
| R13 Pickup OTP | Hashed/expiring/attempt-limited/one-use, assigned eligible companion; no bypass | `journey.test.ts:60-96,169`; `trip_controls.test.ts` | Pass | P0 | DB/security owner | Verify effective hosted settings and same negative cases after rollout. Pickup OTP is separate from login SMS OTP. |
| R14 Real-data environment and login OTP | Explicit synthetic backend; no real-data environment attestation; client uses `shouldCreateUser:false` | ADR 0004; workflow public anon config; public auth settings | Blocked | **P0** | Founder / backend operator | Name/attest production project/region and separate credentials, data, test-phone map and provider configuration. Remove test bypasses from real-data auth; verify approved real OTP/rate limits/session controls without an unauthorized send. |
| R15 Hosted auth configuration matches staging policy | Phone enabled; public settings report `disable_signup=false`, provider `twilio`; actual test map/credentials not read | Fresh `static-audit.json`; LOCAL_TESTING says disable new signups | Fail | P1 | Backend operator | Review and correct intended seeded-staging signup policy; verify no paid SMS can be triggered. Client flag alone is not a server signup policy. No arbitrary OTP was requested. |
| R16 Vault privacy, consent and file access | Audited restricted functions/private bucket/short signed URLs | vault SQL/function tests; `20261008000800...:31-40,73-96,157-175` | Pass | P0 | DB/privacy owner | Verify hosted bucket policies, object access and signed URL expiry. PGlite has no real Storage schema. |
| R17 Retention/withdrawal/deletion | Consent records exist; withdrawal deletion/retention job unfinished | TASKS M8/backlog; PRODUCT_SPEC section 7 | Blocked | P1 | Founder / privacy counsel / DB operator | Approve retention and deletion policy, including backups/logs and signed-link expiry; implement/verify the approved behavior before real health records. No cleanup/delete performed here. |
| R18 Companion capacity | Eligible assignment exists; overlapping intervals both accepted | Fresh [local inventory/probe](evidence/production-readiness-2026-11-04/local-inventory.json); spec section 4 nearest free companion | Fail | P1 | Founder / ops + DB engineer | Define occupied interval/travel/backup semantics and an enforceable conflict control or explicitly approved operational control; test concurrent conflicting assignments. Do not add a matching platform. |
| R19 Pricing/default start policy | Bills use latest schedule/package price; 180-minute start window provisional | `20261008000900_payments.sql:114-141`; TASKS F05/F07 | Blocked | P1 | Founder / finance + DB owner | Decide agreed effective visit price, no-show treatment and start window; prevent later package edits silently repricing history under that decision. No new pricing invented here. |
| R20 Production payment collection | Signed/idempotent/amount-checked test backend; Family rejects non-test checkout | `_shared/payments.ts`; `payments.test.ts`; `bills_tab.dart:131` | Fail | P1 | Founder / finance / payments owner | Approve the actual collection/reconciliation/refund/support process; implement and sandbox-verify the chosen app flow if required. No live charge or automatic provider activation. |
| R21 Notifications and dispatch | Outbox/inbox, retry/lease and test adapter; live adapters throw unimplemented | `notify-dispatch/adapters.ts:71-83`; dispatch tests | Fail | P1 | Ops / backend owner | Establish approved live channel and working scheduler/retry alerting, or explicitly approve a documented manual service process. Test delivery separately from inbox/test receipts. |
| R22 Truthful outbound issue wording | App guidance is cautious; notification renderer says “our team is on it” | `notify-dispatch/messages.ts:19`; no acknowledgement/SLA mechanism | Fail | P1 before live messaging | Product / language / backend owner | Remove the unsupported acknowledgement claim in EN/TE/HI before enabling outbound messages; preserve status-only privacy. |
| R23 EN/TE/HI catalogue structure | All named catalogues have matching keys/placeholders/nonempty strings | Fresh static audit: 380 keys per locale; 51 rendered notification cases | Pass | P2 | Engineering | Keep structural checks; this is not semantic/medical-language approval or exhaustive ICU parsing. |
| R24 All-screen translation and human approval | Draft translations and partial layout tests; raw Ops DB details remain English | Ops `errors.ts`, `ErrorMessage.tsx`; language matrix below | Not Tested | P1 | Telugu/Hindi reviewers + healthcare/service reviewer | Review all current screen/error/status/notification states; sign each language and semantic issue. Decide whether raw technical details remain secondary Ops diagnostics. |
| R25 Small-screen/accessibility coverage | Named widgets at 200%, historical browser captures; not every current page | PWA/mobile, care, progress and issue widget suites | Not Tested | P1 device / P2 remaining layout | Device QA | Render full D15 matrix, real keyboard/Back, long data and 200% text; fix clipping or unreachable actions found. |
| R26 Synthetic cleanup and production exclusion | Stable seed; exact hosted demo manifests; no current admin inventory | Inventory section below; read-only source/HTTP observations | Blocked | P1 (R14 separately stops real-data onboarding) | Backend operator + release owner | Inventory intended environment, approve retain/delete manifest and backup/restore proof first. No deletion is authorized by this report. Prove real-data production is seed-free before onboarding. |
| R27 Secrets and supply chain | Public anon client config; no tracked `.env`; narrow pattern scan empty; production Node audit zero; limited inspected scope | `environment.json`, `static-audit.json`, env examples | Pass | P1 | Security / platform owner | Verify hosted secret scopes/rotation and historical secrets; assess Flutter/Deno/dev/container dependencies separately. Zero Node advisories is not a full security certification. |
| R28 Monitoring and redacted logs | Audit events/vault reads exist; Sentry not built | ARCHITECTURE integration table; Edge handlers; no operational runbooks | Fail | P1 | Named ops/security owner | Define monitoring, redaction/access/retention, dispatcher/payment failure alerts and escalation; exercise alert receipt. Do not log OTPs, tokens, signed URLs or health notes. |
| R29 Backups, Storage restore, rollback, incident recovery | No `docs/runbooks/` or restore/rollback exercise receipt; cloud settings inaccessible | Fresh path check; PRODUCT_SPEC section 7; TASKS M10 | Not Tested | P1 | Platform/DB + incident commander | Attest backup coverage/RPO/RTO, restore DB+Storage+Auth/config in isolation, document app/schema compatibility rollback and incident ownership; run recovery exercise. Never assume DB backup includes Storage bytes. |
| R30 Account/service onboarding and operational continuity | Seeded accounts; restricted provisioning functions and manual Ops trip generation | ARCHITECTURE sections 6/9; source workflows | Blocked | P1 | Founder / trained ops owner | Approve documented patient/access/consent/companion provisioning, daily trip coverage and exception responsibility. A new onboarding UI/cron system is not mandated by this audit. |
| R31 Final release/legal/pilot approval | Explicit M10 founder gate; no release signoff or pilot metric receipt | TASKS M10; PRODUCT_SPEC sections 7/8; ADR 0001 | Blocked | P1 | Founder / privacy/legal / ops | Collect existing pilot go/no-go evidence and health-tech legal/privacy review; approve brand, responsibilities and launch scope. Spec legal dates are not independently verified legal advice. |

## Coverage interpretation and gaps

The full automated care and issue journeys use real Auth, Postgres, RPCs and RLS,
but the Flutter UI is **desktop Chromium at a phone viewport**. The CI API journeys
also are not Android UI tests. The earlier hosted browser demo is historical proof,
not a physical phone result and not a test of the newly served candidate.

Already covered: IST midnight, request retries/collisions, allowed/denied roles,
consent at request/confirmation, pickup OTP attempts/consumption, required notes,
stage/assignment consistency, stale/reissued/missing-stage Ops resolution,
private-note isolation, original pickup time, reload agreement and completion.
Family/Companion widgets cover out-of-order reads, failed reads, explicit refresh,
resume, reassignment/masked projections and uncertain action recovery.

Not established: real Android install/IME/system Back/OS termination and token
refresh, real lost-response mutations, all-page language approval, production
dashboard settings, restore/rollback/incident execution and live provider delivery.
Auth delayed-role races need controlled regression tests, not an exploit claim.
The Ops schedules loader (`src/app/schedules/page.tsx:40-51`) also lacks the newer
request-generation/clear-on-failure pattern; test overlapping refresh/failure there
before relying on its freshest displayed state (P2; DB checks remain authoritative).
No cancellation/rescheduling feature work is included.

## Translation audit and approval queue

The read-only [scanner](evidence/production-readiness-2026-11-04/audit-static.mjs)
loaded actual UTF-8 catalogues and notification render functions. Results:

| Catalogue | EN keys | TE keys | HI keys | Missing/extra/empty/token-name mismatches |
|---|---:|---:|---:|---|
| Unified login/account | 27 | 27 | 27 | None detected |
| Family | 138 | 138 | 138 | None detected |
| Companion | 74 | 74 | 74 | None detected |
| Ops | 141 | 141 | 141 | None detected |

None of the TE/HI catalogue values exactly equals its EN value or lacks its native
script. All **51** template/status/language render cases are nonempty, have no
unresolved tokens detected and exclude the private probe marker. This does not
prove linguistic correctness, complete ICU grammar, appropriate clinical meaning,
rendered fit or correct recipient language configuration in production.

Manual/source exceptions and priorities:

- Standalone Companion screens hardcode the proper brand `AnugaCare` at login,
  trip and trip-list titles; this is not an untranslated sentence. Review brand
  spelling as part of language approval, not an automatic find/replace.
- Ops intentionally displays original DB/network error details under translated
  summaries (`errors.ts:10-32`, `ErrorMessage.tsx:15`), so “all errors translated”
  is false. Patient/centre/person/package names are data, not catalogue keys;
  synthetic catalogue names such as Basic/Plus are not proof of UI translation.
- Confirm consent withdrawal semantics, required issue/post-visit notes, emergency
  108/non-clinical guidance, pickup-code sharing, cancellation labels already in
  the app, dates/currency and payment/test-mode limitations with human reviewers.
- Fix/approve the outbound acknowledgement claim (R22), and ensure no language
  promises clinical advice, live location, guaranteed availability or delivered
  alerts that the implementation cannot establish.
- Long status, patient/centre names, dialogs and buttons risk wrapping; existing
  200% tests cover named cases, not all Family records/consents/bills and current
  Ops schedules/exceptions/billing combinations. [D15](ANDROID_TEST_PLAN.md#language-and-screen-matrix)
  is the execution matrix. Native-speaker healthcare/service approval is unsigned.

## Synthetic inventory and safe cleanup proposal

**Current hosted row/account/object/log counts are unverified.** No admin database
connection or Storage/log listing was available or used. Public app availability
and an anonymous denied patients read do not inventory authenticated data.

| Inventory layer | Observed scope | Retain / review |
|---|---|---|
| Unchanged seed in a fresh disposable DB | 7 Auth users/profiles; 1 patient; 2 access links; 2 consents; 4 companions; 1 centre/cluster/schedule; 3 packages; 6 date-dependent trips; 6 notifications; 1 vault metadata row, vital and medicine; 0 events/OTPs/deliveries/invoices/payments | Preserve source fixtures and fixed IDs. Exact counts are the 4 Nov local seed snapshot, not hosted counts. [Local inventory](evidence/production-readiness-2026-11-04/local-inventory.json). |
| Seed accounts | Ops `9000000001`; owner `9000000101`; viewer `9000000102`; companions `9000000201`–`9000000204` | Keep for disposable/local CI and approved synthetic staging; never create them/test bypasses in real-data auth. Do not publish login codes in new evidence. |
| Hosted demo receipts | Three manifests list 12 distinct one-date schedules / 9 linked trips, including pending, assigned and underway records | [Care](evidence/care-request-2026-11-02/created-records.json), [progress](evidence/visit-progress-2026-11-02/created-records.json), [issue](evidence/issue-handling-2026-11-03/created-records.json). These are historical candidate IDs, not a current live inventory or blanket deletion approval. |
| Previous grouping fixture | 3 exact IDs with marker/identity/dependency guards | `supabase/seed/companion_trip_groups.sql` and `_cleanup.sql`; review state before deciding retention. Do not run cleanup now. |
| Storage | Private `vault` bucket is created only where Supabase Storage exists; seed has report metadata/path | Real file existence, pending uploads, orphan objects, policies and signed-link lifetimes need authenticated inventory. PGlite has no Storage objects table. |
| Notifications, private notes, billing, audit/logs | Events/outbox/deliveries/sidecar and finance relations have dependencies and audit/retention implications | Inventory by exact candidate trip/patient IDs. Never purge financial/audit history as incidental demo cleanup. |
| Environment | Public build settings target synthetic `vsvkllfgrnlbhdydysny`; Git auto-deploy disabled, publication workflows manual; `.env.example` only tracked env files | Hosted secrets, test-phone map, real SMS credentials, region/plan, backups and a separate production project are unverified. Public settings show signups enabled, contrary to seeded-staging instructions. |

Procedure for a **future separately authorized** cleanup:

1. Operator identifies exact project ref, region, account, bucket and environment;
   record a read-only preflight count plus allow-list manifest. Stop on unknown or
   real records. Do not infer environment from the Vercel target name.
2. Reconcile every receipt ID against current owner, status, assignee, schedule,
   dependencies and active work. Founder/ops marks **retain**, **archive**, or
   **candidate delete** individually. Keep seed/automated-test sources untouched.
3. Export a protected DB backup with grants/migrations and relevant Auth state;
   inventory/copy Storage bytes and object metadata separately. Record checksums,
   backup access/expiry and restore evidence. Never commit backups or credentials.
4. Rehearse restore and the proposed exact-ID cleanup on an isolated disposable
   copy. Measure before/after counts and confirm retained login/journey fixtures.
   Do not use `demo_refresh.sql`, reset, seed reload or prefix-wide deletion.
5. Prepare a reviewed, parameterized transactional cleanup with expected row
   counts/ownership guards and rollback-on-mismatch. Inspect foreign keys first:
   patient/user cascades, trip-event/private-note dependencies, notification
   delivery references and invoice-line `ON DELETE SET NULL` can erase evidence
   or alter billing. No executable deletion is supplied or run in this audit.
6. Obtain explicit approval of the exact manifest, environment, backup and impact.
   Only then execute the reviewed procedure. Storage removal is a separate,
   non-atomic step after DB approval and durable backup; Auth account removal comes
   after dependency review. Provider/dashboard logs need retention-owner approval.
7. Verify approved counts, retained accounts, RLS/privacy and full synthetic
   journey; inspect pending notifications so cleanup cannot send stale alerts.
   Record actual actions and restore/rollback result. Revoke orphan test sessions.
8. Separately attest real-data production contains no seed/demo IDs, synthetic
   accounts/test OTP map, sample vault objects or staging endpoints. Query for
   expected identifiers as well as markers; absence of `(synthetic)` text alone is
   insufficient. Real environment is **Not Tested**, not assumed clean.

## Smallest remaining work before real patient onboarding

1. **P0 — Founder + DB/privacy:** decide and fix R12 trip-consent enforcement with
   tests; select and attest a separate real-data boundary (R14/R26). No patient
   data enters current synthetic staging. Retain safe handling of underway visits.
2. **P1 — Engineering:** close auth-race/real-expiry gaps; decide enforceable
   occupancy, effective pricing/start policy; preserve existing core flows. Review
   PR #22 and later attest matching source/schema under an approved rollout.
3. **P1 — Device QA + language reviewers:** execute the Android plan in Chrome
   and installed PWA on the selected candidate; approve EN/TE/HI service/health
   wording and fix defects found. Physical and human approval remain unsigned.
4. **P1 — Founder/ops/finance:** approve and validate real OTP, notifications and
   payment/collection procedures, truthful messages, patient/role provisioning,
   trip coverage and exception escalation. Keep unapproved integrations disabled;
   a real payment transaction needs separate authorization.
5. **P1 — Platform/security/privacy:** verify hosted permissions/secrets, approved
   retention/deletion, monitoring/redaction/alerts, DB+Storage backups, restore,
   compatible rollback and incident response with named owners and drill evidence.
6. **P1 — Release owner:** reconcile cleanup and seed-free production evidence,
   existing pilot criteria, counsel/privacy/brand review and every applicable row
   above. Obtain explicit release approval **before** enabling real patients.

Native store signing is a separate requirement if native distribution is selected:
the existing release Gradle config signs with debug keys. PWA-first onboarding does
not require rebuilding Android or inventing a store launch. Salesforce remains
unimplemented/disabled; its extra processor/DPA/hosting gates apply before enabling
real-data sync, not as a reason to rebuild the core product. GPS, maps, new matching,
cancellation/rescheduling and other backlog features are not introduced by this audit.

## Source and evidence index

Paths below resolve the shorthand references used in the matrix; line numbers
refer to audited product source `fd6c8dc` (identical to tested `335b58b`).

- [Request contracts](../supabase/tests/care_requests.test.ts),
  [private-note/resolution contracts](../supabase/tests/issue_handling.test.ts),
  [core RLS/access tests](../supabase/tests/access.test.ts),
  [pickup OTP journey](../supabase/tests/journey.test.ts).
- [Effective trip controls](../supabase/migrations/20261022000100_trip_controls.sql),
  [Companion read/start projection](../supabase/migrations/20261027000100_companion_start_time.sql),
  [care request/confirm consent checks](../supabase/migrations/20261102000100_family_care_requests.sql),
  [private note migration](../supabase/migrations/20261103000100_private_visit_issue_notes.sql),
  [pickup preservation migration](../supabase/migrations/20261104000100_preserve_issue_pickup_time.sql).
- [Real care browser journey](../apps/ops_console/e2e/care_request.spec.ts),
  [real issue browser journey](../apps/ops_console/e2e/issue_handling.spec.ts),
  [CI workflow](../.github/workflows/db-tests.yml).
- [Ops auth lifecycle](../apps/ops_console/src/components/AuthProvider.tsx),
  [unified lifecycle/routing](../apps/anugacare_app/lib/src/app.dart),
  [routing widget tests](../apps/anugacare_app/test/routing_test.dart),
  [mobile readiness widgets](../apps/anugacare_app/test/mobile_readiness_test.dart).
- [Family care/refresh tests](../apps/family_app/test/care_request_test.dart),
  [Family detail progress tests](../apps/family_app/test/visit_progress_test.dart),
  [Family issue/Updates tests](../apps/family_app/test/issue_updates_test.dart),
  [Companion refresh tests](../apps/companion_app/test/visit_refresh_test.dart).
- [Ops raw diagnostic policy](../apps/ops_console/src/lib/errors.ts),
  [Ops catalogue](../apps/ops_console/src/lib/messages.ts),
  [Family consent wording](../apps/family_app/lib/l10n/app_en.arb),
  [notification renderers](../supabase/functions/notify-dispatch/messages.ts),
  [live adapter refusal](../supabase/functions/notify-dispatch/adapters.ts).
- [Vault storage/authorization](../supabase/migrations/20261008000800_vault_storage.sql),
  [billing price/amount/authorization](../supabase/migrations/20261008000900_payments.sql),
  [payment adapter/signature guards](../supabase/functions/_shared/payments.ts),
  [Family payment limitation](../apps/family_app/lib/src/screens/bills_tab.dart).
- [Prior physical-readiness limits](evidence/pwa-readiness-2026-11-01/README.md),
  [synthetic environment decision](adr/0004-hosted-staging.md),
  [M10 gates](TASKS.md), [product scope and pilot criteria](PRODUCT_SPEC.md).
