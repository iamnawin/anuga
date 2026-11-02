# Requested visit through completion

Synthetic backend `vsvkllfgrnlbhdydysny`; desktop Chrome at a 390×844 phone
viewport. This is browser verification, not a physical-phone or Android runtime check.

## Integration

- PR [#19](https://github.com/iamnawin/anuga/pull/19) merged `14118fa`.
- PR [#20](https://github.com/iamnawin/anuga/pull/20) merged `ce90f7c`.
- Both original heads passed seven CI jobs. Combined source `5e2dfc2` passed
  all seven in [run41467176573](https://github.com/iamnawin/anuga/actions/runs/41467176573).
  One Android job needed a retry after a corrupt NDK download; no check was removed.
- Existing synthetic alias [anuga.vercel.app/app/](https://anuga.vercel.app/app/)
  now serves READY `dpl_7sNYcgT1NK6ASuzc2XAEnPNbK5Xm`. Built source `5e2dfc2`
  has exactly the same tree as merged main `ce90f7c`; live app bundle matches.
  See [integration-staging.json](integration-staging.json). Vercel calls this
  alias its production target; it remains the authorized synthetic test site.

## Change

Assignment, the eight forward transitions, pickup OTP, handover note, required
completion note and all three status projections already worked. No migration
or permission change was needed. Family and Companion details now refresh through
their existing guarded RPCs, including on app resume. Reload clears stale details
and actions, rejects older responses, and recovers unknown action outcomes.
Family shows fresh status/assignment and persisted milestone times, including
date/year/seconds in IST. “Latest visit update” means latest trip-event time,
not assignment, refresh time, GPS tracking or notification delivery. No time is
invented before an event exists. Explicit pickup ranges keep opened historical
visits refreshable without changing database access rules.

## Observed journey

Exact schedule `c99b9b35-6a64-4d51-abba-34a7b0bf44e5`, trip
`be9aba9d-9684-4c09-8458-e200849f59bf`, pickup **2 Nov 2026, 21:45 IST**.
Real Auth replies confirmed Family `9000000101`, Ops `9000000001` and
Asha `9000000201`; synthetic user IDs are in [receipt.json](receipt.json).

| Browser check | Result | Evidence |
| --- | --- | --- |
| Family review/submit, persisted pending, concurrent retries | Pass | Same schedule returned; reload reads pending |
| Ops sees, confirms, assigns Asha | Pass | Exact schedule and generated trip; Family reload assigned |
| Asha sees and opens assigned requested visit | Pass | Exact trip in restricted RPC; assigned-visit screenshot |
| On the way → OTP pickup → centre → handover | Pass | Real Family-issued pickup code; matching Family board/timeline after each stage |
| Session done → return → home → completion | Pass | Required completion note persisted; eight milestone timestamps |
| Family refresh/status/latest time | Pass | UI time matches latest persisted event after each stage |
| Completion after reload, all three roles | Pass | Family request, Companion trip and Ops row all completed |
| Physical phone, installed PWA and Android runtime | Blocked | No device/SDK available; support remains intact |
| Telugu/Hindi wording approval | Blocked | Layout checks are separate from native-speaker approval |

The real hosted browser test passed in 28 seconds using the local prebuilt
preview output. Screenshots here were visually inspected. The separately
published feature preview uses these same files; deployment identification is
in `preview.json`. Its Vercel team sign-in is separate from AnugaCare sign-in.

## Checks and retained data

Focused checks: SQL12 (PGlite, not hosted SQL execution), Family18 and
Companion31 widget tests passed. New refresh tests first failed on the old screens.
EN/TE/HI Family progress layouts at 200% passed. Full sequential fast checks and
latest feature CI are recorded in the PR/HANDOFF. No OTPs, tokens or pickup codes
are included in curated artifacts.

Driver corrections covered auth URL query parameters, offscreen fixture cards,
Flutter chip/group semantics and tooltip names. They did not require product or
backend-rule changes. Five distinct synthetic requests/trips were retained across
driver attempts: assigned, on the way, at centre and two completed. Exact current
IDs/states are in [created-records.json](created-records.json). Two submissions
reused the same intent; server retries returned the same schedule. No cleanup,
seed reset, demo_refresh, patient/consent change, fares, invoices or payments ran.

Old hosted fixture cleanup still remains pending; refresh the narrow grouping
fixtures before future grouping checks. The 180-minute start window remains
provisional. Production launch, real data and paid providers remain gated.
