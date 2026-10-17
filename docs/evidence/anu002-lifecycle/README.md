# ANU-002 lifecycle: local implementation receipt

Receipt date **17 October 2026 (Asia/Calcutta)**. Sole writer: Codex coordinator.
Worktree `D:/AI-Workspace/Repos/anuga-product-inventory`, branch
`docs/product-inventory-bootstrap`, unchanged HEAD
`69bbb366212cbde94e74f0ba8c015d889254fd7e`; fetched main
`64c4603e5812358f6030ab8c9038747a93ba9b40`. All implementation is uncommitted.
No hosted modification, real-user classification, real operator designation,
commit, push, merge or deploy. **F1-F4 are provisional local assumptions and remain
unapproved for rollout. ANU-002 is Partial; nothing is newly Released.**

## Implementation and ownership

[Contract](../../product/PILOT_ACCESS_CONTRACT.md),
[BE task](../../delivery/tasks/ANU-002-BE.md),
[verification task](../../delivery/tasks/ANU-002-VERIFY.md).
The new migration implements pending/active/disabled plus version, self-only
`my_account_access()`, owner-only audited management, restrictive policies on
23 RLS tables and active guards on 31 authenticated definer RPCs. The resolver is
the sole inactive-account exception. Existing JWTs cannot bypass the current DB
state; app/service callers cannot manage accounts. Candidate assignment and new
notification claims also exclude inactive accounts.

Family patient grants and owner consent remain independent. Lifecycle commands
create neither patients nor grants/consent and do not restore revoked records.
Malformed Companion/Ops patient links cannot confer Family/clinical authority.
This required hardening the existing access-level helper, with a red/green
regression. Trusted service branches retain their original checks.

Both Flutter apps and Ops read the self resolver, distinguish pending, disabled,
unconfirmed, wrong-role and retry, and recheck on restore/resume/focus, Auth/access
events and lifecycle-denied requests. Protected navigation is removed on recheck;
ordinary patient permission denial does not reset account state. No polling or
instant remote erasure of an idle/cached screen is claimed. Existing welcome,
phone OTP and app-specific session storage/channel behavior are reused.

Local Auth global signup is disabled; email/SMS provider switches remain enabled.
Provider-level disabling was rejected by the real OTP test because it prevents
provisioned users signing in. With the corrected configuration, known synthetic
phones receive OTP and both unknown `create_user=false` and explicit
`create_user=true` requests return 422. Hosted settings remain unknown/unchanged.

No ANU-003 task/home/spec paths, historical migrations, package/lockfiles, design,
research or prior evidence files were changed in this lifecycle step. Earlier
uncommitted entry code is preserved and extended only in the reserved paths.
[File manifest](source-manifest.json) records exact hashes and baseline preservation.
[Scope validation](scope-validation.json): all 465 starting files remain; 414 are
byte-identical, 51 intentionally extended in the reservation, plus 12 new source/
documentation files and the curated evidence directory. All 182 protected paths
are unchanged; 336 local Markdown links resolve, whitespace checks pass, no files
are staged and HEAD is unchanged.

## Actual verification

All commands use the existing toolchain/dependencies. Dedicated disposable local
Supabase project `anuga-anu002-local`: API loopback 54321, PostgreSQL 17.11 on 54322,
Storage image `v1.79.36`. No paid SMS: configured synthetic phone OTPs only.
Reset synthetic fixtures between state-mutating suites; no real account roster.

| Check | Actual result | Evidence |
| --- | --- | --- |
| `bash scripts/check-all.sh`, without real-stack env | PASS: PGlite 157 passed/9 real-only skips; Ops lint/typecheck/build and 60 tests; shared Dart format/analyze and 28 tests; Companion format/analyze 51 passed/3 integration skips; Family format/analyze 49 passed/6 integration skips | [Full fast log](check-all.log) |
| `pnpm db:test:supabase` with local DB/Auth/Edge env, fresh reset and corrected Auth config | **166 passed, zero skipped, zero failures**; includes deny management, same old caller claims, all protected RPCs/RLS, audit failure rollback, grant/consent non-restoration, concurrent CAS and migration lock timeout | [Real suite](real-db-tests.log), [catalog surface](permission-surface.json) |
| Companion `flutter test test/supabase_local_test.dart`, fresh local reset | 1 passed, zero skips; real phone OTP and full trip/denied access | [Companion](companion-real.log) |
| Family same command, separately reset | 2 passed, zero skips; real journey and consent/upload/view/refusals | [Family](family-real.log) |
| `pnpm contract:export`, both contract suites, root `pnpm typecheck` | PASS; 51 transitions exported, existing contract fixture unchanged | Fast/real logs and unchanged fixture hash |
| `node --env-file=<ignored local env> scripts/verify-pilot-local.ts` | PASS; real new Admin-created accounts remain pending despite metadata; three roles activate/disable/reactivate with SAME JWT; management denied; missing grant/withdrawn consent remain missing | [Auth/Storage results](real-auth-storage.json) |
| `node supabase/scripts/pilot-backfill.ts <inventory> <roster>` | Seven exact synthetic matches exit 0; added unknown exit 1. Unit tests also reject duplicates, wrong role/state/authority and non-synthetic inputs before classification. Populated migration independently tested for exact manifest/audit/atomic abort | [Matched](backfill-matched.json), [Unknown](backfill-unknown.json), [synthetic inventory](inventory.json), [synthetic roster](roster.json) |
| `node scripts/web-session-smoke.mjs`, local combined site and local test OTP | PASS: three actual phone sign-ins, independent reloads, Companion sign-out leaves Family/Ops signed in | [Session results](session-receipt.json), [log](session-smoke.log) |
| `node --env-file=<ignored local env> scripts/verify-pilot-browser.mjs` | PASS: 18 real resolver pending/disabled app/locale cases and 3 live existing-session disable cases without reload; page error lists empty | [Browser results](browser-results.json) |
| `node --env-file=<ignored local env> scripts/verify-pilot-locales.mjs` | PASS: all three apps, te 360/dark and hi 1440/light, phone validation/real synthetic OTP send/code validation; 18 captures, no page errors | [Locale results](browser-locales.json) |

42 curated [screenshots](screenshots/) comprise 18 lifecycle views, 3 live disables,
18 phone/OTP views and 3 session captures. State-view fixtures inject an actual
Admin-created synthetic email-auth session only to render states; role responses
are never intercepted. Product entry remains phone-only and has separate actual
OTP/browser tests. Representative te/hi, dark/light/narrow/wide views and all three
live-disabled views were visually inspected. This proves rendering, not human
language or formal accessibility acceptance. Earlier widget-harness font issues
are not used as current visual acceptance.

The [red clinical-role regression](role-boundary-red.log) failed before the helper
fix and [green run](role-boundary-green.log) passed after it. Final complete suites
supersede early exploratory runs and an incomplete first real-suite invocation.

## File URL expiry and residual access

Measured through actual local Auth, Edge and Storage:

- A download issued before disable still returned **200**; its signed lifetime
  was **60 seconds**, and the same URL returned **400 after expiry**.
- An upload issued before disable still accepted its issued-path upload (**200**).
  Its signed lifetime was **7200 seconds**. New URL requests and confirmation were
  denied after disable, so the uploaded object was not confirmed through that
  user's application permissions.
- An isolated copy of the **same Storage image**, configured for a five-second
  upload lifetime, rejected the expired token with **400**. Primary configuration
  stayed unchanged. We did **not** wait two hours or claim that full-duration
  observation. [Expiry probe](upload-expiry.json).

Disabling blocks subsequent DB/Edge authorization. It does not revoke already
issued file capabilities, erase cached/downloaded data, cancel in-flight requests
or undo already-authorised trusted service work. Idle screens learn on recheck or
their next protected request. Immediate file revocation needs separate scope if
F4 is rejected; local measurements do not establish hosted TTLs. General signed
download semantics are also documented by [Supabase](https://supabase.com/docs/guides/storage/serving/downloads).

## Remaining acceptance and exact next task

- Android SDK absent; no Android device/emulator detected. No mobile APK/device
  cold start, OS Back, keyboard/autofill, offline restore or background acceptance.
- No iOS device or macOS/Xcode host. Windows target is detected but native build
  prerequisites are incomplete (Visual Studio Build Tools 2019).
- No named Telugu/Hindi native-language reviewer; provider error copy may still
  be server-language text. No TalkBack/VoiceOver/human screen-reader acceptance or
  complete 200-300% device accessibility matrix.
- No actual rollout F1-F4 approval, reviewed real roster or named real operator.
  No hosted/deployed test was authorised. Real SMS provider behavior is unverified.

Next: assign the remaining device/human acceptance checks in ANU-002-VERIFY and
record actual rollout decisions separately. ANU-003 remains separately owned;
its next step is its existing Family first-use specification, dependent on
patient/schedule creation authority, owner consent and help destination. This
receipt does not authorise starting its implementation or publishing ANU-002.

Failed cutover rolls back the whole transaction. Recovery after cutover is an
audited/versioned per-account fix-forward, never blanket activation, guard removal
or consent/grant replay. Synthetic disable/reactivate/CAS/audit-failure tests cover
that bounded recovery; no production recovery or release rehearsal is claimed.

Local cleanup: combined loopback test server and all eight task-local Supabase
containers stopped successfully. Isolated expiry container removed. No other
containers were running; task-started Docker daemon stopped afterward. Ignored
local artifacts remain available, with credentials excluded from curated evidence.
