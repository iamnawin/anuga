# SCR-OPS-002 — Ops trips home

Spec ready for review, not Approved. ANU-002, owner Unassigned. FEAT-001/003/009;
CMP-001/005/008/014. Source apps/ops_console/src/app/trips/page.tsx and OpsShell.

Ops login redirects to /trips (hosted /ops/trips/); /ops/ itself is SCR-OPS-001
redirect. Reference board 11 panel 41. Preserve four actual destinations: Trips,
Schedules, Exceptions, Billing. No overview count tiles or patient intake route.
Layout: mint sidebar/wrapped narrow nav → topbar language/user/sign-out → heading
and refresh → start-day/range/status filters → error/success → labelled trip table.

Defaults come from existing state: India-time today, 7-day range, all statuses.
Range choices 1/3/7/14 and real trip status values; use istRange to call ops_trip_board.
PR #10 improves range wording but is open and not this baseline. Date filter
changes and Refresh reload; list stays visible during later requests. Error and
initial loading may coexist in current code; do not claim comprehensive recovery
semantics without a test. Zero rows shows trips.empty, not a fake schedule.

| Action | Handler/API/input | State/output/notification |
| --- | --- | --- |
| Load/filter/refresh | api.tripBoard(from,to,statuses) | Loading/list/empty/error; no write or notification |
| Assign backup/pick companion | ReassignTrip → ops_companion_options / ops_assign_trip_companion | Scheduled-only, SQL eligibility; busy/error/saved, refresh; existing assignment notifications |
| Fare on completed trip | FareEditor → ops_record_trip_fare(paise) | Validate rupees; save/error; immutable once billed |
| Navigate/sign out | OpsShell links/Auth signOut | Existing destination / login; no role creation |

Only ops_admin passes the shell/profile gate and SQL Ops checks. Owner/editor/
patient/viewer, assigned/unassigned companions and anonymous are denied. A view
with zero trips is not permission denial. No vault reads on trips home; consented
Ops vault access uses a different audited path, absent from this UI.

Follow existing CSS/tokens: 48px controls, 18px body, semantic table headers,
visible focus, labelled horizontally scrollable table region, wrapping filters/nav
below 900px, readable en/te/hi, dark scheme and 200–300% text at 360/430/1440.
No fabricated aggregates, sample prices or language-only icon without a label.

Acceptance: valid Ops login/reload reaches trips; all denied role pairs go to login
without app data. Empty DB board stays truthful and refreshable; API failure permits
retry. Date/range/status inputs shape actual RPC arguments, with correct India-day
boundaries. Scheduled assignment succeeds/rejects ineligible companions; active
trip does not offer reassignment. Sign-out preserves other apps' sessions. Verify
keyboard/table scroll/large-text/locale/dark behavior with synthetic data.

Existing evidence: Ops e2e covers role, assignment/eligibility, schedules, exception,
billing and locale; S3 and E-RELEASE receipts are historical. No new browser checks.
New-patient/schedule creation, readiness, metrics and PR #10 integration are separate
scope. This first slice adds no RPC/auth/provider change or production authorization.
