# ADR 0006: Pilot welcome, backend access and Ops provisioning

- Status: pilot product direction accepted by founder, 2026-10-16.
- Authority: founder's request to review/commit documentation and record ANU-002
  direction. Application/Auth/SQL implementation is not authorized in this task.
- Supersedes D1 and the user-provisioning portion of D2 in the bootstrap audit.

## Direction

1. `/` becomes an ANUGA welcome page with **Family/Patient sign in** and
   **Companion sign in** links to `/family/` and `/companion/`.
2. Ops retains its dedicated `/ops/` entry and `/ops/login/` sign-in URL. It is
   not a third primary welcome-page link. Keep existing protected Ops destinations.
3. A link selects the sign-in experience, never a role or permission. Roles and
   per-patient access come from authorised backend records, enforced by SQL/RLS.
   Patient remains a Family patient_access level, not a new Auth role.
4. Ops provisions pilot users. This is operational responsibility, not a grant
   to create accounts from a browser with service-role credentials or to assign
   roles from submitted client metadata. Self-service registration remains deferred;
   preserve shouldCreateUser=false in all sign-in paths.
5. Authenticated users whose pilot setup is confirmed incomplete by authorised
   backend records receive a clear **setup-pending** state with refresh/recheck and
   sign-out. Suggested copy: “Your pilot account setup is pending. Ops needs to
   finish your access setup.” Translate final copy into en/te/hi before shipping.
   Do not invent a live support contact or promise completion time.

## Required access resolution contract

Resolve session, authorised profile/role and relevant pilot readiness before
displaying protected home data, including restored sessions. No role/grant is
created by clicking a link or completing OTP. Backend readiness representation
and the safe query/RPC contract remain to be specified before implementation.

| Result | Intended presentation |
| --- | --- |
| Signed out | Selected app phone/OTP sign-in |
| Confirmed incomplete pilot provisioning | Setup pending, no protected home or patient data |
| Provisioned account, wrong selected role app | Clear wrong-role denial; no role reassignment |
| Provisioned and authorised for selected experience | Existing role home; existing patient-specific grants still apply |
| Backend/network/profile lookup failure | Error and retry/sign-out, not assumed pending or authorised |
| Authorised family account, no linked patients | Distinguish incomplete provisioning from a legitimate empty or revoked-access state using backend evidence |
| Provisioned companion, no assigned visits | Normal no-trips home, not automatically setup pending |
| Provisioned Ops account, empty board | Normal empty Ops board |

Missing profiles must fail closed. Do not label a transport/permission error as
setup pending. A backend contract must distinguish incomplete provisioning from
revoked access without exposing other users or patient data. Do not use absence
of trips or an app-selected role as a readiness signal.

## Conflicts with existing code (reported before any implementation)

| Current source behavior | Conflict / later work needed |
| --- | --- |
| scripts/build-staging.sh generates a three-link synthetic role chooser | Welcome needs two sign-in links; Ops keeps dedicated URL; hosting-sensitive edit requires scoped implementation |
| Both Flutter login screens reject/sign out any currentRole other than their expected role; Ops AuthProvider collapses absent/error/non-Ops profiles to notOps | No separate confirmed setup-pending outcome; must distinguish lookup failure, missing/incomplete setup and wrong role |
| Flutter app.dart chooses home from auth.isSignedIn on startup | Restored sessions lack a fresh explicit role/readiness gate before home mounting; SQL remains the data boundary |
| Family home displays noPatients for zero links | No explicit provisioning distinction/recheck action; empty links alone do not prove setup pending |
| Migration 0200 handle_new_user inserts profiles; migration 0100 defaults role to family | Default family profile is not evidence that Ops completed pilot provisioning; no explicit pilot readiness field/contract exists |
| create_patient in migration 0300 requires a family profile | Ops user provisioning does not give ops_admin permission to call this RPC or grant consent as an owner |

Current shouldCreateUser=false and database-backed roles align with the direction.
Do not enable signup to make setup pending reachable. An unknown phone with no
Auth account is rejected before OTP; setup pending applies only after a valid
authenticated session and a confirmed incomplete-setup result.

## Remaining boundaries

Define the authorised Ops account-provisioning procedure, readiness source,
role/access assignment, revocation recovery and audit requirements before coding.
Patient/schedule creation actor and consent capture remain separate D2 questions;
Ops must not silently consent for an owner. No new roles, access grants, migration,
RPC, backend workflow, provider, app consolidation or production launch is approved
by this documentation decision. Patient simplified mode and Ops overview metrics
remain separate unimplemented concepts.

Evidence: [audit baseline](../product/AUDIT_BASELINE.md),
[entry](../product/screens/SCR-AUTH-001.md), [OTP/access](../product/screens/SCR-AUTH-003.md),
[ANU-003 dependencies](../delivery/tasks/ANU-003.md).
