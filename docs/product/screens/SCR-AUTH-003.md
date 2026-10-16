# SCR-AUTH-003 / SCR-AUTH-005 / SCR-AUTH-007 — login OTP

Status: Spec ready for review, not Approved. ANU-002, owner Unassigned. FEAT-001;
CMP-004/005/006. This is Auth OTP. Pickup OTP is SCR-FAM-004 / SCR-COMP-003 and
calls issue_pickup_otp/verify_pickup_otp; never use those RPCs for login.

## Entry, layout and fields

Entry is successful send in the matching phone form, same route/widget. Board 1
panel 03. Use ANUGA/language → code sent to normalized number → labelled single
six-digit field → Sign in/Verify → Change number → inline error + test notice.
Single field differs deliberately from six decorative boxes. No fake resend timer.
Default code empty; numeric keyboard, maximum six characters and one-time-code
autofill where supported. Existing isOtpCode validates trimmed six digits before
calling Auth. No hardcoded test code in product input, image-derived countdown or
auto-filled pickup code. Sent-to number is UI state, not a profile update.

## Current action/authorization flow (not the target setup-pending behavior)

| Variant | Verify action and role lookup | Success/exit | Rejection/retry |
| --- | --- | --- | --- |
| Family SCR-AUTH-003 | PhoneAuth.verifyCode → Supabase verifyOTP sms → currentRole from own profiles.role | family → HomeScreen SCR-FAM-001; no patient grant created | Wrong role → signOut, clear code/sent number, notFamily; Auth error remains code step |
| Companion SCR-AUTH-005 | Same injected interface, own adapter | companion → TripsScreen SCR-COMP-001 | Wrong role → signOut and notCompanion; no signup |
| Ops SCR-AUTH-007 | auth.verifyOtp sms → AuthProvider resolves own profile | ops_admin → router.replace('/trips') / hosted `/ops/trips/` | notOps → signOut, phone/code reset, notOps alert |

Change number returns to phone entry. Current Flutter keeps controller text while
switching sent-to state; Ops explicitly clears code. Specify/reset stale code
before any re-send acceptance is claimed; do not silently change it in prose.
Current Ops Change number remains enabled during verify; in-flight change-number
race handling needs inspection. No dedicated Resend exists; changing number and
sending again is the current available path, subject to Auth limits.

Verify emits no visit notification. Auth token storage is handled by existing
adapters/session infrastructure; never copy tokens into UI drafts/logs. Failure
to resolve profiles.role must never display protected data by inventing a role.
Current Flutter startup uses isSignedIn to choose home without an explicit role
recheck in app.dart; document/testing of stale/wrong-role sessions is a follow-up,
not a claim this behavior is fixed. SQL still denies unauthorized RPCs.

## States, permissions and presentation

Code entry, invalid local code, verifying (submit disabled), wrong/expired/provider
error, role resolution, rejected role, accepted/home and change number. Empty
code is validation failure. No assigned visits is a normal provisioned Companion
home state; no patient links needs an authorised readiness/access distinction. Role/profile fetch exceptions and session expiry recovery are Unknown in
current runtime. Do not show a new-account setup success or successful SMS delivery
just because send/verify was mocked.

Owner/editor/patient/viewer share Family Auth; assigned and unassigned companions
share Companion Auth; Ops requires ops_admin. Anonymous/other role never sees
protected destination data. Database checks stay authoritative; UI gate alone is
insufficient. No clinical or vault data is part of Auth.

Same responsive/theme/localization rules as phone spec: 360/430/1440, keyboard,
full text scale, en/te/hi, visible focus, semantic labels and progress/errors,
48px targets. Code field must accept paste/autofill without six tiny focus traps.
Use existing tokens, no clipped sent-to number. Back/change preserves role context.

## Acceptance scenarios

1. Malformed/empty code makes no Auth call. Wrong/expired code leaves a retry path
   and never routes to home. Busy verify prevents duplicate submissions.
2. Valid code resolves authorised backend role, patient grants and pilot readiness
   before home. Confirmed incomplete provisioning shows setup pending; a
   provisioned wrong role is denied. Missing profile/lookup failure fails closed
   and is distinguished by the backend contract, not assumed to be a wrong role.
   Test every cross-role pair; link choice never assigns a role.
3. Distinguish backend-confirmed incomplete Family provisioning from a legitimate
   empty/revoked-access state. A provisioned unassigned companion sees no trips;
   provisioned Ops with no rows sees an empty board. Unknown phone never registers.
4. Refresh/restore, Auth/profile network failure, expiry and Change-number-during-
   verify are explicitly tested/reported; investigate failures before claiming
   complete entry-to-home recovery. Preserve three-app session isolation.
5. All labels/errors are usable via keyboard/screen reader and all three locales,
   dark mode and large text. Pickup codes cannot authenticate an account.

Historical sign-in/session evidence exists; these complete failure/restore cases
were not run in this audit. Ownership of auth adapters/providers is excluded from
documentation packages and future presentation-only tasks; functional fixes need
a separately scoped task and appropriate tests.

## Accepted pilot access direction and implementation conflicts

[ADR 0006](../../adr/0006-pilot-entry-and-provisioning.md) is authoritative: Ops
provisions pilot users; self-service registration is deferred; roles/patient
permissions are authorised backend records. Setup pending is a specified new
state after successful authentication and confirmed incomplete provisioning, not
a currently implemented view or blanket replacement for access denial.

Suggested pending copy: "Your pilot account setup is pending. Ops needs to finish
your access setup." Offer recheck and sign-out; no signup, role selector, invented
contact, patient data or waiting-time promise. Recheck resolves readiness again;
no notification or role/patient mutation. Final text needs en/te/hi and accessible
progress/error feedback. Native/browser Back must not bypass the unresolved gate.

Current Flutter rejects null/mismatched role and startup checks isSignedIn only;
Ops conflates missing/profile error/wrong role as notOps. The automatic default
family profile does not establish Ops provisioning. New readiness representation
and safe access query/RPC must be specified before a functional task; do not
enable signup, infer readiness from no trips, or modify Auth/SQL in this review.
