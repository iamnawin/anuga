# Synthetic staging verification — 2026-10-31

Site: https://anuga.vercel.app/app/. Tested application source:
`e18a0d23db35b59ebbdb31fb8eff1e4f6c452ff6` (merged PR #17).
Vercel deployment: `dpl_BcdNXbscaAv1U1rqUh15GzodHxA7`, READY, live alias confirmed
through authenticated Vercel inspect/API. See [deployment.json](deployment.json).
The live `/app/main.dart.js` SHA256 matches the existing local staging artifact.
Follow-up: [draft PR #18](https://github.com/iamnawin/anuga/pull/18).
The unique deployment URL returned Vercel authentication HTML and was excluded
from the asset comparison. Vercel calls this target `production`; it remains the
founder-authorized synthetic test site, not an authorized real-data launch.

## Fixture walkthrough

Use only the existing seeded **synthetic** Supabase project, SQL Editor as postgres.
There is no connected Supabase execution tool in this session. Do not reset the
seed or run `demo_refresh.sql`.

Before execution, review [companion_trip_groups.sql](../../../supabase/seed/companion_trip_groups.sql).
It inserts or updates exactly these `public.trips` primary keys:

| ID | Pickup in Asia/Kolkata | Status / expected group |
| --- | --- | --- |
| `92000000-0000-0000-0000-000000000001` | Yesterday 23:59:59.999999 | completed / Previous |
| `92000000-0000-0000-0000-000000000002` | Today 12:00 | scheduled / Today |
| `92000000-0000-0000-0000-000000000003` | Tomorrow 10:00 | scheduled / Upcoming |

All three use synthetic patient `70000000-0000-0000-0000-000000000001`, centre
`50000000-0000-0000-0000-000000000001`, and Asha
`30000000-0000-0000-0000-000000000001`, phone `919000000201`, role companion.
The script verifies that identity and refuses non-synthetic people, foreign ID
collisions, and fixture trips with OTP/event/notification/invoice dependencies.
Reruns update in place; the old fixture's recognized signatures can be upgraded.
No schedules, invoices, permissions, auth or settings are changed. The Previous
trip's microsecond duration is a date-boundary fixture, not a journey test.

1. Run the complete fixture file. Expect exactly three result rows with Asha's
   phone and Previous/Today/Upcoming; record `pickup_ist` and `verify_before_ist`.
2. Run it again to verify safe rerun. Do not advance these trips, issue pickup
   codes or generate an invoice from them.
3. Sign into `/app/` as Asha `9000000201`, entering the code directly in the
   browser. Confirm session user ID/phone separately from the SQL assignment.
4. Refresh and inspect each heading and its qualifying pickup date. Previous
   follows Upcoming and may require scrolling.
5. Finish before `verify_before_ist`. At midnight, rerun and refresh.

The actual migrated `companion_my_trips()` default list range is pickup between
`now() - interval '1 day'` and `now() + interval '14 days'`, inclusive. Patient
details use a separate restricted window; a listed masked trip is expected.
The last microsecond of yesterday maximizes Previous visibility for the current
IST day. At the next midnight it is outside the rolling range, and Today and
Upcoming change groups. Execution has no 22:00 cutoff, but no fixture can keep
all three original date groups indefinitely under these rules. A long-running
SQL transaction crossing midnight also requires rerun in a fresh transaction.

Optional cleanup: review and execute
[companion_trip_groups_cleanup.sql](../../../supabase/seed/companion_trip_groups_cleanup.sql).
It deletes only the three exact IDs with expected identity, status and ownership
marker. It refuses dependent records, preventing cascading deletes or invoice
link nulling. Repeated cleanup is safe. Do not replace it with prefix deletion.

## Browser verification ledger

Pass requires direct browser evidence; local/widget tests are not browser passes.
No OTPs or session tokens belong in this receipt.
Founder supplied the hosted SQL Editor's three matching rows, with verification
deadline `2026-11-01 00:00:00` IST; see
[fixture-hosted-result.json](fixture-hosted-result.json). This is user-supplied
hosted evidence, not agent execution. Two runs were requested; the final rows
alone do not independently establish the execution count. No cleanup executed.

| Check | Result | Evidence / next requirement |
| --- | --- | --- |
| Deployment contains PR #17 | Pass | Authenticated live alias lookup and deployment source metadata; asset hash in deployment.json |
| Family identity `9000000101` | Pass | Browser diagnostic projected only stored session user ID `20000000-0000-0000-0000-000000000001` and phone `919000000101`; family RPC-backed home loaded |
| Family home | Pass | Native Chrome screenshot: Lakshmi Rao (synthetic), Synthetic Dialysis Centre 1 |
| Family bookings | Pass | Native Chrome screenshot: Nov 6/9/11/13 07:00 scheduled cards with Asha; not confused with companion My trips |
| Family navigation | Pass | Records showed synthetic monthly labs; Bills showed September invoice; Updates rendered visit messages; Bookings → Nov 2 detail → in-app Back returned to list |
| Family logout | Pass | Sign out returned to blank shared sign-in; browser reload retained sign-in with no family patient/cards |
| Asha identity `9000000201` | Pass | Live `auth/v1/user` 200: ID `30000000-0000-0000-0000-000000000001`, phone `919000000201`; see companion-access.json |
| Previous | Pass | On `/app/`, scrolled after Upcoming: Previous → Fri 30 Oct, 23:59, Completed; RPC includes exact fixture 0001 |
| Today | Pass | On `/app/`: Today → Sat 31 Oct, 12:00, Scheduled; RPC includes exact fixture 0002 |
| Upcoming | Pass | On `/app/`: Upcoming → Sun 1 Nov, 10:00, Scheduled, patient details masked; RPC includes exact fixture 0003 |
| Companion refresh | Pass | Ordinary top Refresh cleared old cards, showed Loading, then restored current trips with no error |
| Companion stale-response handling | Pass | Browser-only injected-response ordering test: held response 1, displayed real populated response 2, released older response as empty `[]`; current Today/Upcoming cards remained, not replaced by empty state. Hook counted exactly 2 requests and was removed |
| Retry — injected-error test | Pass | Temporarily rejected only companion trip-list fetches (2 failures), observed generic error and visible recovery control labelled Refresh; restored fetch, clicked recovery control, observed Loading then current trips with error removed |
| Account switching | Pass | Same `/app/`: Family logout/reload had no cards; Asha identity then confirmed by live auth endpoint; companion My trips replaced Family navigation/records/bills with no prior Family view retained |
| Ops routing via `/app/` | Blocked | Pending `9000000001` sign-in; expected “Use the ops console” and unified session cleared, not automatic authenticated console transfer |
| Protected-view restrictions | Pass | In authenticated Asha browser: companion RPC 200 with 9 rows; family and ops RPCs 403/42501; direct patients read 200/zero rows. Separate `/family/` also refused Asha. See companion-access.json |

Browser fallback: browser access host unavailable; native `@oai/sky` controls used.
Early UI actions were interrupted by user input; refreshed state before retrying.
The user stopped Computer Use with Escape, then explicitly resumed verification.
Pre-existing console listener errors were observed; their origin was not isolated,
so this receipt does not claim a clean browser console.
Injected test hooks matched only `/rpc/companion_my_trips`; they did not change
server behavior, permissions or hosted data. Normal fetch was restored and a
browser reload cleared temporary globals after the tests. Denied-access probes
and injected errors are intentional test events, not ordinary application failures.

## Local validation

Fixture tests use a throwaway PGlite database even when `DATABASE_URL` exists;
they never execute the fixture against hosted Supabase. They load the actual
migrations and seed, exercise IST midnight, 21:59:59, 22:00, 23:59 and the final
microsecond, plus expiry, reruns, guards, collisions and cleanup dependencies.
Boundary cases freeze only the fixture clock and pass explicit list bounds to
the unchanged RPC. A separate real-clock case calls default RPC bounds.

- Focused fixture suite: 16 passed. Original SQL exposed seven failures.
- Full PGlite suite: 170 passed, 8 skipped, 0 failed (includes 16 fixture tests).
- `pnpm typecheck`: passed; `git diff --check`: passed.
- `scripts/check-all.sh`: exit 0, ALL CHECKS PASSED. Ops lint/typecheck/build and
  54 Vitest; shared Dart 27; companion analyze/tests 47 passed, 3 skipped;
  family analyze/tests 35 passed, 6 skipped; unified analyze/tests 22 passed.
  Formatting, root install/typecheck and database suite passed. Final log:
  ignored `artifacts/staging-verification/check-all-final.log`. An earlier run
  caught a UTF-8 BOM while SQL was being edited; corrected before final run.
- Real Supabase, Playwright/full journey, device testing: not run locally;
  Docker unavailable. PGlite tests do not establish hosted execution.

Initial PR CI `41210470804` at `ec86d55`: SQL step passed 178/178 (162 against
real local Supabase and 16 fixture tests against throwaway PGlite). The job then
failed installing Chromium: `ubuntu-latest` resolved to Ubuntu 26.04, which
pinned Playwright 1.56.1 explicitly refuses. Browser/Flutter journey steps were
skipped. Only `supabase-local.runs-on` is pinned to `ubuntu-24.04` to restore the
existing browser checks without a dependency upgrade.
Version-specific requirements:
[Playwright 1.56.1](https://github.com/microsoft/playwright/blob/v1.56.1/docs/src/intro-js.md#system-requirements).
Rerun [41210884363](https://github.com/iamnawin/anuga/actions/runs/41210884363)
at `e200f58` passed all seven jobs; see [ci.json](ci.json). SQL 178/178 includes
162 real-Supabase tests and 16 PGlite fixture tests. Ops browser and both real-DB
Flutter journey tests passed; full test-billing/notification journey reported
JOURNEY PASSED; all three Android debug APK jobs passed.
Subsequent receipt commit changes documentation/evidence only. Its workflow may
run separately; the completed code-bearing run above is the validation evidence.

The provisional 180-minute companion start window is unchanged. Production
launch, real data and paid providers remain gated.
