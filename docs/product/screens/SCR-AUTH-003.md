# SCR-AUTH-003 / SCR-AUTH-005 / SCR-AUTH-007 — login OTP and access gate

ANU-002 owner Codex coordinator. Locally complete implementation; overall acceptance Partial, local implementation based on
69bbb36; main 64c4603. Pilot direction accepted by ADR 0006; local lifecycle implemented and reviewed; native/human acceptance and rollout remain gated. FEAT-001; CMP-002/004/005/006.

## Entry and form

Successful send opens the existing single six-digit Auth OTP field at the same
Family/Companion root or dedicated Ops login route. Retain ANUGA, selected role,
normalized sent-to number, Sign in, Change number and synthetic notice. Field
accepts paste/autofill and numeric keyboard; isOtpCode validates before Auth call.
No six-box focus trap, fake timer, embedded test code or self-registration.

All apps use existing Auth SMS verify, and sendCode keeps shouldCreateUser=false.
Busy verify disables submit, field edits and Change number. Flutter shows progress;
Ops exposes role=status. Change number clears code/error; successful send also
clears stale code. Wrong/expired/provider failure stays retryable at the code step.
Changing number and sending again is the current resend path, subject to provider
limits. Unexpected errors use en/te/hi generic copy; server Auth errors may remain
server-language text. No notification, patient/grant/profile write follows login.

## Verified account-state/role routing (current working tree)

| Role app | Lookup before protected home | Outcome |
| --- | --- | --- |
| Family | my_account_access state=active and role=family after OTP/restore/resume/access events | family enters existing HomeScreen; home RPCs/RLS load current linked patients/levels |
| Companion | Same self resolver, active + companion | companion enters existing TripsScreen; assigned projection controls data |
| Ops | AuthProvider self resolver, active + ops_admin on restore/Auth events/focus/recheck | ops_admin enters /trips, hosted /ops/trips/ |

A role link never selects a role. Patient is a patient_access level within Family,
not a new Auth role or separately implemented Patient home. Owner/editor/patient/
viewer remain subject to existing SQL/RLS; gate acceptance grants nothing.

Flutter root checks before home mounts, and removes deeper routes on resume
revalidation. Expired session on resume returns to login; request sequencing ignores
older role responses. PhoneAuth now exposes Auth/access events; Flutter also rechecks on those events
and lifecycle-denied protected RPCs. Family Edge lifecycle denial also invalidates
the gate. Ordinary per-patient permission denial does not reset the account gate.
Ops hides protected children during role resolution and ignores stale responses
after sign-out/newer checks. Existing app-specific storage/channel isolation is
unchanged; actual same-origin sign-ins/reloads/sign-out isolation passed locally.

| Current result | Presentation/recovery |
| --- | --- |
| No session | Selected app phone login |
| Account lookup running | Loading, no protected home requests |
| Other known role | Wrong-role denial; Flutter signs out then offers another number; Ops retains its denial/sign-out flow |
| Missing own profile | Access unconfirmed, Refresh and Sign out; no automatic sign-out or pending claim |
| Query/transport failure | Access-check error, Refresh and Sign out; no inferred denial/pending |
| Explicit pending | Setup-pending explanation, Recheck and Sign out; no home |
| Explicit disabled | Disabled-access explanation, Recheck/Sign out; no home |
| Active + expected role | Existing home; no patient/trip rows stays the existing empty state |

## Authoritative lifecycle states (implemented locally)

[ADR 0006](../../adr/0006-pilot-entry-and-provisioning.md) requires setup pending
for explicitly incomplete provisioning. The [pilot access contract](../PILOT_ACCESS_CONTRACT.md)
defines an owner-operated pending/active/disabled record, self-only resolver,
disable enforcement, audit and backfill decisions. The new migration implements these locally; hosted schema remains unchanged.
Entry now consumes my_account_access, never infers readiness from profiles.role.

Implemented confirmed pending UI: "Your pilot account setup is pending. Ops needs to
finish your access setup." Recheck and Sign out, no protected data or completion
promise. Explicit disabled state denies access even with stale grants/JWT; missing
evidence is unconfirmed, and query failure is an error. Pending/disabled screens and DB enforcement now have real local Auth/SQL/browser
evidence. Native/human acceptance and rollout approval are still open; see
[current receipt](../../evidence/anu002-lifecycle/README.md).

## Permissions, usability and verification

Auth OTP never calls issue_pickup_otp/verify_pickup_otp; trip pickup code is a
different flow. Companions still cannot access vault/diagnosis/DOB. Account
provisioning does not create patients or owner consent; ANU-003 owns Family
first-use and remains separate. No patient wizard or access grant was added.

Keep 48px controls, existing tokens/light-dark, full text scaling and en/te/hi.
Scrollable layouts and labelled fields preserve keyboard access. Error gate is a
live region; full screen-reader/native-language review remains unverified.

Regression tests: both auth_access_test.dart suites cover pending lookup without
home RPCs, cross-role/missing/error results, retry, resume/expiry, stale lookup
races, invalid phone/code, unknown number, expired code, stale-code clearing and
busy send. Ops auth_access.test.tsx covers role matrix, errors/recheck and a late
profile response after sign-out. Local visual and full-suite results/skips live
in [ANU-002 receipt](../../delivery/tasks/ANU-002.md). This is not a release.
