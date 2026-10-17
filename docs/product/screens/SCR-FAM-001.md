# SCR-FAM-001 — Family home and first-use bookings

Supported first-use slice implemented locally; ANU-003 remains Partial for blocked
setup/help/Patient-mode interactions and remaining acceptance. Owner Codex coordinator. FEAT-002/003;
CMP-002/007/008/011/013. Sources: home_screen.dart and bookings_tab.dart in
apps/family_app/lib/src/screens. Branch feat/anu003-family-first-use from reviewed ANU-002 96bdc59.
[Current receipt](../../evidence/anu003/README.md); no commit/deploy.

## Scenario, layout and navigation

An existing family profile signs in and sees only patients linked by patient_access.
Reference board 4 panels 13–14 and board 7 panel 25. Preserve the existing four
destinations, not a new simplified patient mode or calendar editor.

```text
ANUGA                        privacy | language | sign out
Patient label / actual full name / centre
[Patient picker, only when more than one]
Bookings: actual visit cards (date, status, centre, companion as returned)
Bookings | Records | Bills | Updates
```

No fake greeting identity, avatar, verification badge, backup profile or next-visit
claim without returned data. Home is mounted after Family login; booking tap pushes
TripScreen and Back returns/reloads the booking list. Privacy pushes ConsentScreen;
sign-out returns to login. Tabs use existing widgets. Initial selected patient is
the first RPC result (SQL full-name order). Refresh preserves the selected UUID
if still returned, otherwise selects the first remaining patient. A changed
selection/access level resets to Bookings; all patient content unmounts during
revalidation. A failed load removes prior data and offers Refresh.

## Actions, data and states

| Trigger | Handler/data | Result | Failure/recovery/notification |
| --- | --- | --- | --- |
| Mount home | FamilyApi.myPatients → family_my_patients | Loading → first linked patient or no patients | Explicit error/denial with Refresh; no previous patient data or empty-state inference |
| Select patient | Local _selected from returned list | Correct patient context; keyed booking/records/bills children reload | Do not retain another patient's sensitive content; no mutation/notification |
| Open bookings | FamilyApi.tripBoard(patientId) → family_trip_board | Existing list/empty; pull refresh; viewer note | Visible Refresh and pull refresh; clear previous rows before reload, show error/denial separately from empty |
| Tap visit | Existing Navigator to TripScreen | Server-backed timeline and authorized actions | See FEAT-004; no new capability inferred from card |
| Records/Bills/Updates/Privacy | Existing child widgets/APIs | Current per-role content/denial | Do not fetch unauthorized vault/bill data to hide afterward |
| Language/sign out | Existing callbacks | Locale update / Auth signOut → login | Sign-out failure handling not verified; no patient mutation |

First-use scenarios are distinct: (a) unknown number cannot register via login;
(b) existing family profile with zero patient links gets noPatients text; (c) linked
patient with zero bookings gets noTrips; (d) revoked links may produce no patients
or a later DB denial, while request failure is an error. None alone proves
incomplete pilot provisioning. Zero-patient home hides tabs and privacy actions, explains current links neutrally
and offers Refresh; there is no create patient/setup path. No Add loved one/Contact Ops CTA is offered without an implemented authorised path. Ops is the accepted pilot user-provisioning owner
(ADR 0006); the readiness mechanism is resolved by the committed ANU-002 self resolver.
Patient/schedule workflow actor and explicit owner-consent capture, plus a real
help destination, still need decisions before new setup controls.
Intended access gate shows setup pending only for backend-confirmed incomplete
provisioning; zero patient links alone is not that signal. Distinguish revoked
access, legitimate empty home and lookup error; recheck/sign-out must not create
patient/access records. A missing/revoked grant can return the same empty list as a never-linked account;
copy does not claim which happened. Explicit 42501 remains permission denial.

## Patient-access matrix

| Capability | Owner | Editor | Patient | Viewer |
| --- | --- | --- | --- | --- |
| Own linked patient picker/bookings/timeline | Yes | Yes | Yes | Yes + view-only note |
| Pickup code | Allowed states | Allowed states | Allowed states | No |
| Cancel trip | Scheduled only | Scheduled only | No | No |
| Records read | Audited | Audited | Audited | Audited |
| Add photo | With owner vault consent | With owner vault consent | No | No |
| Bills / payment | Read + owner pay | Read only | Denied | Denied |
| Change purpose consent | Yes | No | No | No |

Assigned/unassigned companions, Ops and anonymous are not Family-home actors;
family_my_patients enforces family profile and linked access. Ops uses its separate
board; consented Ops vault access is not a Family role. No app-side-only permission.

## Responsive/accessibility and acceptance

Use existing tokens/themes and CarePanel/Heading. Patient header/picker scrolls
within its current bounded region; tab content stays reachable. Long names wrap;
large translated navigation can scroll horizontally. At 360x640 and 430 width,
keyboard/focus, dark mode and 1.15/2x/3x text, every tab and patient switch remains
operable; no artificial text-scale cap. New strings require en/te/hi, 48px targets,
56px primary and visible labels/focus.

1. Zero linked patients and zero bookings are tested separately using synthetic
   adapters; displayed message does not promise a nonexistent next step.
2. Owner/editor/patient/viewer get exactly the above actions, backed by allowed/
   denied SQL tests; revoked/unrelated access returns no other patient's data.
3. Two long-name patients switch correctly from every tab without stale content;
   back from detail reloads bookings. Failure/retry and sign-out are specified
   with the existing handlers. Initial-load retry is now implemented.
4. Empty state explains known status without claiming a booking was created.
   Remaining D2 resolves patient creation/consent/help before adding a CTA.
5. All locales/themes/large-text settings preserve hierarchy and controls.

Current regression evidence: home_states_test covers empty refresh, generic/denied
initial-load retry, immediate stale-data removal on revalidation/revocation, failed
booking refresh/retry, late prior-patient responses/selection preservation and all
four existing permission levels through visit/back navigation. Existing full app,
Auth/records/bills/consent tests also run. Local browser captures use labelled
synthetic fixtures and actual production widgets; native/human acceptance remains
open. No onboarding, RPC addition, patient creation or vault-right change.

Bookings retain the backend default range now()-1day through now()+14days; a visible
caption and truthful empty card describe that range. No calendar/routine editor,
map, companion verification badge, avatar or invented next visit from board4:13-14
is added. Refresh is keyboard/touch accessible; loading/error/empty content scrolls
at large text. Reuses CarePanel/CareHeading, existing familyTheme and navigation.
