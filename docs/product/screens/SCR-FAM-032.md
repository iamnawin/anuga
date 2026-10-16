# SCR-FAM-032 — simplified Patient home (design screen 25)

Concept specification for review, pending decision; not Approved or implemented.
ANU-003, owner Unassigned. FEAT-015; design board 7:25, linked visit concept 26.
Current patient-level users enter the existing Family HomeScreen SCR-FAM-001.
No distinct Patient-home route or automatically selected simplified mode exists.

Scenario: a patient wants their next actual visit and a few clear actions. The
concept shows greeting, next visit, assigned companion, My visits, I need help and
My reports. Use only data already returned and authorized; do not assume the
logged-in name equals the selected patient or invent a next appointment.

Proposed layout for review: ANUGA/language/sign-out → selected patient context →
actual upcoming visit or truthful empty state → My visits / Reports. Help/call
controls remain blocked until a real contact source and destination are scoped.
Keep the design's large-text hierarchy without importing map/verified-avatar claims.
Whether this replaces Family home for patient access level, or is a user preference,
is unresolved; do not introduce a new Auth role or role router from this image.

| Action/state | Existing support | Missing decision / behavior |
| --- | --- | --- |
| Load linked patient | family_my_patients | Multiple-patient default/selection must preserve real grant context |
| View visits | family_trip_board; existing booking/detail widgets | Simplified layout not built; next-visit selection must be specified |
| Show pickup code | issue_pickup_otp in allowed states | This is visit OTP, never login OTP |
| Read reports | Audited vault path | No PDF viewer; no access to another patient's data |
| Ask help/call/request | Concept only | Actual support/family contacts and request workflow are not integrated |

Patient may read linked visits/vault and issue pickup OTP in permitted states;
cannot cancel/advance return states, pay invoices, upload vault photos or change
owner consent. Owner/editor/viewer keep their existing Family behavior; Companion,
Ops and anonymous are not patient-mode actors. Backend permissions remain unchanged.

Specify loading, zero linked patients, no future visits, hidden/revoked access,
network error/retry and restored-session cases. No fake visit, assignment or help
success. At 360x640/430/wide, en/te/hi, light/dark and 1.15/2x/3x scaling, prioritize
actual visit time/status and 48px targets/56px primary, visible focus and spoken
labels. Do not clip text or hide navigation needed to exit the view.

Acceptance for a later authorized implementation: patient-level routing decision
recorded; actual empty/populated/error states; permitted/denied actions enforced
by SQL; back to visit/home works; no unsupported help control; existing owner/
editor/viewer behavior preserved. No runtime or implementation evidence for this
new destination exists. Review alongside SCR-FAM-001 before scheduling code work.
