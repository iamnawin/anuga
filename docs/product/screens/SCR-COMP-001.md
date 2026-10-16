# SCR-COMP-001 — Companion home

Spec ready for review, not Approved. ANU-004, owner Unassigned. FEAT-003/004;
CMP-002/007/008. Source apps/companion_app/lib/src/screens/trips_screen.dart.

An authenticated companion sees assigned visits through companion_my_trips.
Board 9 panel 31 supplies hierarchy; do not add earnings/profile tabs, unread
counts, map/ETA or unsupported verification badges. Layout: ANUGA + refresh,
language and sign-out → trips heading → Today list → Upcoming list → synthetic
notice. The current Today bucket includes prior-day results returned by the RPC
(date <= today); clarify stale/overdue wording before claiming it means today only.

Mount calls CompanionApi.myTrips with RPC defaults (one day back/fourteen ahead);
SQL returns only assigned trips with restricted essentials. Empty assignment
shows noTrips, not onboarding complete/verification approved. Out-of-window or
cancelled/no-show rows hide patient details; the card keeps permitted centre/time/
status data and uses detailsHidden. A valid session does not grant unrelated trips.

| Action/state | Handler/API | Result and recovery |
| --- | --- | --- |
| Initial load | myTrips → companion_my_trips | Loading, data, empty or generic error; no notification |
| Refresh/pull | Existing _load | Retry; current code keeps previous list during refresh/failure |
| Trip tap | Navigator → SCR-COMP-002 | Restricted trip projection and existing state actions; Back reloads list |
| Language | LanguageMenu | en/te/hi, no API write |
| Sign out | Existing Auth callback | Return to Companion phone login; sign-out failure runtime Unknown |

Permissions: assigned companion can read their projected trips; unassigned
companion receives an empty list, not other patients. Family owner/editor/patient/
viewer, Ops and anonymous cannot use the Companion-only read RPC. Companions never
read vault/diagnoses/DOB; do not fetch those to hide them. An Ops profile has its
own RPCs. Read masking is separate from write authorization and does not prove
that transitions are forbidden outside the visibility window.

Use current teal/mint/navy light/dark theme, scrollable lists, wrapped dates/centre
names, 48px targets and 56px primary where used. Honour uncapped text scaling,
en/te/hi and keyboard/assistive names for refresh/language/sign-out and visit cards.
At 360/430/wide widths, 1.15/2x/3x text and dark mode, all cards and retries remain
reachable. No extra appointment-arrival state or pickup Auth code shortcut.

Acceptance: test assigned/in-window, assigned/masked, no-assignment, request failure
then refresh, prior-day plus future trips, and sign-out/reload/session isolation.
Open a visit then Back and see its updated actual status. Denied roles see no
restricted data. Existing full_trip_test covers role/new-number rejection and a
synthetic journey; historical S4 contains empty/hidden renders. Full zero-trip,
expiry/profile-error and device/native-language evidence remains Unknown today.
D3 onboarding/verification is a separate future task, not a route from this empty state.
