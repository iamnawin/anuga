# SCR-FAM-001 — Family home and first-use bookings

Spec ready for review, not Approved. ANU-003, owner Unassigned. FEAT-002/003;
CMP-002/007/008/011/013. Sources: home_screen.dart and bookings_tab.dart in
apps/family_app/lib/src/screens. Main 64c4603; runtime not checked today.

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
the first RPC result (SQL full-name order), not a fabricated default patient.

## Actions, data and states

| Trigger | Handler/data | Result | Failure/recovery/notification |
| --- | --- | --- | --- |
| Mount home | FamilyApi.myPatients → family_my_patients | Loading → first linked patient or no patients | Current initial-load error text has no retry control; retry is an acceptance gap, not implemented |
| Select patient | Local _selected from returned list | Correct patient context; keyed booking/records/bills children reload | Do not retain another patient's sensitive content; no mutation/notification |
| Open bookings | FamilyApi.tripBoard(patientId) → family_trip_board | Existing list/empty; pull refresh; viewer note | Error text; refresh retries; no routine setup CTA currently |
| Tap visit | Existing Navigator to TripScreen | Server-backed timeline and authorized actions | See FEAT-004; no new capability inferred from card |
| Records/Bills/Updates/Privacy | Existing child widgets/APIs | Current per-role content/denial | Do not fetch unauthorized vault/bill data to hide afterward |
| Language/sign out | Existing callbacks | Locale update / Auth signOut → login | Sign-out failure handling not verified; no patient mutation |

First-use scenarios are distinct: (a) unknown number cannot register via login;
(b) existing family profile with zero patient links gets noPatients text; (c) linked
patient with zero bookings gets noTrips; (d) revoked links may produce no patients
or a later DB denial, while request failure is an error. None alone proves
incomplete pilot provisioning. Existing zero-patient home hides tabs; there
is no create patient/setup path or refresh button. Do not invent a functioning
Add loved one/Contact Ops CTA. Ops is the accepted pilot user-provisioning owner
(ADR 0006); the readiness mechanism, patient/schedule actor and consent flow,
plus a real recovery destination, still need definition before implementation.
Intended access gate shows setup pending only for backend-confirmed incomplete
provisioning; zero patient links alone is not that signal. Distinguish revoked
access, legitimate empty home and lookup error; recheck/sign-out must not create
patient/access records. This target differs from current noPatients text.

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
   before any new UI implementation; initial-load retry gap remains recorded.
4. Empty state explains known status without claiming a booking was created.
   Remaining D2 resolves patient creation/consent/help before adding a CTA.
5. All locales/themes/large-text settings preserve hierarchy and controls.

Evidence: full_app_test contains no-linked-patient/viewer assertions; S5 receipt
contains two-patient/3x-text renders. These were not rerun. This spec does not
approve onboarding, RPC additions, patient creation or changes to current vault rights.
