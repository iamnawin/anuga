# ANU-002-VERIFY - current acceptance receipt and remaining checks

Parent [ANU-002](ANU-002.md), FEAT-001/SCR-AUTH-001-007; local owner Codex
coordinator. **Available local automation executed; overall verification Partial.**
F1-F4 are provisional development assumptions, not rollout approval. ANU-003 keeps
its separate home/spec ownership. No real operator designation, real-user backfill,
hosted modification, push, merge or deploy. Latest review permits the local
ANU-002-only commit, without closing remaining acceptance. Historical fixture screenshots
are not current real-Auth acceptance. [Current evidence](../../evidence/anu002-lifecycle/README.md).

## V1 - Real local Auth, permissions and Storage

- [x] Disposable Supabase/Postgres 17.11, real Auth/Admin creation and phone OTP;
  new synthetic Family/Companion/Ops remain pending despite hostile role/state
  metadata, then activate/disable/reactivate through owner-only audited management.
- [x] Unknown phone with create_user=false AND explicit create_user=true refused;
  global signup disabled locally while existing providers stay enabled. Tests use
  configured synthetic OTPs; no real SMS/paid provider or hosted configuration.
- [x] Existing SAME JWT denied immediately on subsequent protected requests after
  disable commit; resolver still reports safe state. SQL/catalog tests cover all
  protected user-definer functions and granted RLS tables. App/service management
  actions denied; stale versions, audit failure and concurrent changes tested.
- [x] Reactivation does not recreate deliberately deleted synthetic patient grants
  or withdrawn consent. Accidental Companion/Ops patient links do not confer Family
  ownership; Companion clinical data remains denied. No lifecycle operator command
  creates patients/grants/consent or claims companion verification.
- [x] Empty and exact populated synthetic cutover; unknown/duplicate/missing-profile/
  role mismatch/audit failure abort; lock timeout leaves no partial cutover. Offline
  dry run matches seven source fixtures (exit 0), unknown extra aborts (exit 1),
  non-synthetic inputs refused before classification.
- [x] Local vault Edge authorisation denies new signing/confirmation after disable.
  Existing 60-second download works after disable then returns 400 after expiry.
  Upload token lifetime measures 7200 seconds and remains usable after disable for
  its issued path; confirmation still 403. Same Storage image with an isolated
  five-second upload configuration rejects expired upload with 400; primary
  configuration unchanged. The full two hours were NOT waited.
- [ ] Real-world operator procedure, reviewed rollout roster, actual F1-F4 approval
  and risk acceptance: explicitly unapproved/not performed. Admin/SMS service
  production behavior is outside the synthetic local tests; no approval invented.

## V2 - Restored sessions, live denial and devices

- [x] Actual combined browser builds, real three-role phone sign-ins, independent
  reloads and Companion sign-out isolation on one loopback origin.
- [x] Active Family/Companion/Ops session makes a protected request after a local
  disable; gate shows disabled without reload. Protected navigation is removed.
  Unit/widget tests cover pending lookup, retry, wrong/missing role, expired local
  session, resume, Auth/access events and stale completion races.
- [x] Both existing Flutter real-Supabase integration files run separately on fresh
  synthetic stacks, exercising allowed/denied RPCs, pickup/journey and vault flows.
- [ ] Android: unavailable; flutter doctor cannot locate Android SDK, and flutter
  devices lists no Android device/emulator. No APK/device acceptance claimed.
- [ ] iOS: no connected iOS device or macOS/Xcode host in this Windows environment.
- [ ] Windows native: detected Windows target, but Visual Studio Build Tools 2019
  lacks required native build components. The apps were verified as web builds,
  not a Windows desktop release.
- [ ] Device cold-start/kill, OS Back, soft keyboard/autofill, offline restore and
  native foreground/background denial must be checked on supported mobile hardware.
  Browser/widget results do not certify those device behaviors.

## V3 - Telugu/Hindi visual and accessibility acceptance

- [x] Actual packaged Flutter web builds and Ops render pending/disabled in en/te/hi
  (18 captures), with real resolver results from an Admin-created synthetic identity.
  State rendering uses a real injected email-auth session only as a fixture; product
  sign-in remains phone-only. Phone-OTP UI has separate real tests.
- [x] All three apps: te at 360/dark and hi at 1440/light, phone validation, actual
  synthetic OTP send and code validation (18 captures). Browser page-error lists
  are empty. Actual scripts shape/read correctly; no missing-glyph acceptance claim
  relies on the earlier font-substituted widget harness.
- [ ] Native-language human review of copy, including provider errors, remains
  unavailable: no named Telugu/Hindi reviewer/signoff. Server Auth error messages
  can remain untranslated; generic fallback/local validation strings are translated.
- [ ] Human screen-reader review (TalkBack/VoiceOver/browser assistive technology),
  mobile keyboard and complete 200-300% accessibility matrix remain unverified.
  Existing large-text widget checks are supplementary, not formal acceptance.

## V4 - Combined local routing and session isolation

- [x] Build combined output locally: welcome /, /family/, /companion/, /ops/ and
  /ops/login/; public client configuration points only at local Supabase. No deploy.
- [x] Same-origin sign-in/reload/sign-out isolation passed with actual Auth, not
  intercepted role responses; existing-session live disable verified for each app.
- [ ] Hosted/deployed verification: not authorised and not run. Local implementation commit does not change release status;
  no feature is newly Released. Actual deployment needs separate rollout authority.

Every pass refers to the exact local logs/results/source hashes in the evidence
receipt. No real account was classified, no real privileged operator designated,
and no consent or approval is inferred from a synthetic authority reference.
Parent ANU-002 remains Partial until unavailable acceptance and rollout gates are
resolved. No ANU-003 home/wizard work is included.
