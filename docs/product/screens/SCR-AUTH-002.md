# SCR-AUTH-002 / SCR-AUTH-004 / SCR-AUTH-006 — phone sign-in

Status: Spec ready for review; not Approved. ANU-002, owner Codex coordinator. FEAT-001;
CMP-002/003/005/006. One behavior contract, three existing implementations.

| Screen | Entry / source | Success destination |
| --- | --- | --- |
| SCR-AUTH-002 Family | `/family/` signed out; `apps/family_app/lib/src/screens/login_screen.dart` | SCR-AUTH-003 code state |
| SCR-AUTH-004 Companion | `/companion/` signed out; `apps/companion_app/lib/src/screens/login_screen.dart` | SCR-AUTH-005 code state |
| SCR-AUTH-006 Ops | `/ops/login/`; `apps/ops_console/src/app/login/page.tsx` | SCR-AUTH-007 code state |

## User, layout and data

An existing synthetic account holder signs into the selected role. A new number
does not create an account. All three adapters set shouldCreateUser=false. Current
source does not offer a registration route. Pilot users are provisioned by Ops
([ADR 0006](../../adr/0006-pilot-entry-and-provisioning.md)); self-service
registration remains deferred. The authorised procedure/readiness contract,
patient/schedule creation and owner consent capture still need specification.

Reference board 1 panel 02. Annotated order: ANUGA + language control → role-specific
heading → synthetic notice → labelled phone field and format hint → Send code →
inline error. Family/Companion currently position their notice differently; retain
meaning and role identity. Use the established 18px body/28px heading, 24px padding,
teal primary and readable mint panel. No welcome illustration or unsupported
marketing/privacy promise is required. Never hide test-site context.

Field: phone text, initially empty; telephone keyboard/autofill. Validate with
existing normalizeIndianMobile (10-digit Indian mobile / accepted +91 form),
not a second regex or default country selector. The normalized E.164 phone is
transient UI state. Invalid input gets a localized message without an API call.

## Actions and state flow

| Action | Caller/input | API/handler | Result/notification | Failure/recovery |
| --- | --- | --- | --- | --- |
| Send code | Signed-out user; normalized phone | Flutter PhoneAuth.sendCode; Ops auth.signInWithOtp | Sent-to phone stored; code step; Auth delivery only, no trip outbox event | Keep input and show Auth error; retry permitted by provider, no invented countdown |
| Change language | Any user; en/te/hi | Existing LanguageMenu/I18nProvider | Same form/input in selected locale; no write | Missing translation is a release gap |
| Back | Browser/system navigation | Existing navigation; no new account route | Prior entry where available | Native back-to-root policy needs design review; no new router in UI-only task |

Idle → invalid phone OR sending (disable submit) → code sent OR server error.
No patient/empty state belongs before authentication. Request failure/rate limit
must not masquerade as successful send. Flutter catches PhoneAuthException and
unexpected errors; Ops catches returned/thrown SDK errors. Busy forms disable
submit, phone/code edits and Change number, with visible progress. Successful
resend and Change number clear stale code. Provider Auth errors remain server
messages; unexpected failures use translated generic copy. Setup-pending now uses my_account_access pending state; disabled is separate,
and neither is inferred from an unknown phone.

## Permission and accessibility contract

Family/Patient sign-in shares /family/; Companion uses /companion/ and Ops its
dedicated /ops/login/. Role is read from authorised backend records, never the
selected link or client metadata. Every Family access level is a family profile
at login; patient grant is resolved
after sign-in. Assigned/unassigned companions may authenticate; assignment controls
their home data. Ops needs ops_admin. Selecting a role never changes profiles.role.
Anonymous users can request Auth verification but cannot read app data. No patient
details/vault/diagnosis/DOB are requested in login. Provider configuration still
governs account existence and test delivery.

Single scrollable column at 360/430, bounded readable width on desktop; keep the
keyboard from obscuring actions, full text scaling and dark tokens. Label/control
association and telephone autofill; tab order language → phone → submit. Visible
focus, at least 48px targets/56px primary Flutter, 4.5:1 body contrast. Translate
new labels/errors en/te/hi; native-speaker review is pending. Proposed acceptance
includes announcing send/error progress to assistive technology; current support
must be inspected/tested, not presumed.

## Acceptance

1. Valid existing synthetic number enters its matching login-OTP step once per
   submission; malformed input makes no Auth request. Server rejection preserves
   number and an actionable localized error; busy prevents duplicate submits.
2. Unknown number never creates a profile/user or implies onboarding succeeded.
3. Role heading and synthetic notice remain readable at narrow/wide/keyboard,
   dark and 200–300% text in all three locales.
4. Existing Auth adapters, RPC/SQL permissions and independent session keys stay
   unchanged in any later presentation-only implementation.

Existing evidence: Family full_app_test, Companion full_trip_test, Ops e2e; historical
S3–S5 visuals and hosted session receipt. Local widget/browser checks now cover validation, busy send, unknown-phone and
wrong/expired-code recovery; see ANU-002 receipt. Live provider/device checks not
run. Dependencies:
provider/test-phone setup and the ADR 0006 access-resolution contract. Confirmed
incomplete provisioning after authentication must show setup pending; unknown
phones rejected before Auth do not get silently registered. The local gate is implemented and verified; hosted behavior is unchanged. Exact
help/contact destination is Unknown; do not invent a working support button.
