# SCR-AUTH-001 - ANUGA pilot welcome

Status: pilot direction accepted 2026-10-16; detailed spec ready for review, not
implemented or runtime verified. ANU-002; owner Unassigned. Main baseline 64c4603.
FEAT-001; CMP-001/005. [ADR 0006](../../adr/0006-pilot-entry-and-provisioning.md)
owns the founder decision, access-resolution contract and current Auth conflicts.

## User, navigation and annotated layout

A pilot Family member, Patient or Companion opens /. Use board 1 panel 01 as
visual input with ANUGA branding. The desired welcome has two sign-in links:

```text
ANUGA
Scheduled visit support and updates for your family
Test site: invented people and bills; simulated payments
[Family/Patient sign in] -> /family/
[Companion sign in]      -> /companion/
```

Ops retains dedicated /ops/ and /ops/login/ URLs, not a third primary welcome
link. Its existing authenticated routes remain. Patient uses Family sign-in;
patient-level permissions come from patient_access, not a new Auth role. The
link selects an experience and cannot assign profiles.role or patient grants.
Self-service registration is deferred: no Get started/signup/account-creation CTA.
Browser Back returns from the role app to welcome where existing navigation allows.

Current code differs: scripts/build-staging.sh generates a synthetic three-link
chooser (Family, Companion, Ops). Welcome changes are specified only; script,
hosting config, auth and routes remain unchanged in this task. Keep the synthetic
notice on pilot test hosting; no service-availability/verification/clinical promises.

## Components and presentation

Reuse existing mint/teal/navy tokens and system font, 16-24px gutters, 480px readable
column and stacked sign-in links. At least 48px targets, visible focus and logical
reading/tab order. 360/430/1440 widths, dark mode, 200-300% text and en/te/hi must
keep notice and actions usable. Full welcome localization/dark/focus behavior
remains implementation work, not evidence supplied by this concept.

## Data, actions and states

No form fields, patient API calls, writes or notification from welcome. Both links
open existing phone/OTP experiences. Ops users open their dedicated URL directly.
Destination access resolution must consult authorised backend records, including
restored sessions. Confirmed incomplete pilot setup leads to setup pending with
recheck/sign-out; a provisioned wrong role is denied; a backend lookup failure
shows error/retry, never an invented role. Full matrix: ADR 0006 and login OTP spec.

Static welcome has no patient loading/empty/submitting state. Failed navigation
uses browser recovery. Backend error/setup-pending states belong to the destination
access gate, not to a public page probing arbitrary phone/profile records.
Anonymous and every role may see welcome; protected patient/vault data never appears
here. Family owner/editor/patient/viewer and assigned/unassigned companions retain
their current database restrictions.

## Acceptance for future implementation

1. Welcome shows ANUGA and exactly the two primary sign-in links; Ops URL works
   independently without a primary welcome link. No self-registration action.
2. Phone/code flows retain shouldCreateUser=false. Link choice and client metadata
   cannot grant a role/patient permission. Unknown phones cannot register.
3. Backend-confirmed unprovisioned authenticated account shows setup pending;
   lookup failure, wrong role, no patient link and no trips are distinguished.
4. Recheck reads current authorised readiness; sign-out returns to selected login.
   No auto-created role/patient/grant, false completion time or invented contact.
5. Auth restore/reload and sign-out preserve independent sessions across apps.
6. Verify keyboard/screen-reader, all locales, dark/large text and narrow/wide UI
   with synthetic data. Historical chooser evidence is not welcome acceptance.

Before code: scope hosting-script ownership and access/readiness contract work
separately. This documentation task changes neither Auth behavior nor deployment.
