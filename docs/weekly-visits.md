# Weekly visits and Trips range

Founder request, 2026-10-12: choose 1, 2, 3 or 4 visits per week and select that many weekdays. Also clarify the Trips date-range filter. Founder chose replacement of future unstarted visits rather than retaining the old pattern.

## Implementation plan

- Add allowed/denied database tests first, then a new migration with an Ops-only atomic `ops_update_schedule_pattern` RPC. Validate distinct ISO weekdays, lock the schedule and affected bookings, reject a stale pattern, keep matching bookings and cancel removed weekdays through existing audited transitions. Generate replacement bookings in the configured rolling window. Never touch past or started visits.
- Keep cancelled rows and their history. A partial unique index permits a new booking when a weekday removed by this editor is later re-added. The existing generator continues to respect all cancellations; this editor only rebooks its own pattern cancellations, never individual cancellations.
- Add a separate inline weekly-pattern editor with a 1-4 dropdown and exactly that many weekday checkboxes. Preserve the existing companion editor. Translate all labels and errors into en/te/hi. Rename the Trips range to Show next, with 1 day, 3 days, 1 week and 2 weeks; keep numeric query ranges unchanged.
- Verify database/API/form tests, contract export, scripts/check-all.sh, separate app checks and CI including real Supabase/journey. Review desktop/mobile rendering and deployment requirements. Open a PR from main; no automatic main merge or publication of a UI whose RPC is missing.

## Boundaries

No clinical frequency advice, auth changes, vault access, production data or paid provider. No existing trip deletion. The migration changes booking uniqueness, not grants/RLS/state-machine rules. Current backend lacks a general schedule editor, so the new RPC is necessary for the explicitly requested replacement behavior. No Graphify report is present; this bounded feature uses the spec, migration definitions and existing tests as its map.

## Test the change

Ops: Weekly schedules > Change weekly visits > choose a count > select the same number of weekdays > Save weekly visits. Refresh Trips to see new bookings and retained cancellation history. Started and past visits must remain unchanged. Saving the same pattern twice must not duplicate visits or notifications. Family and Companion see their existing restricted projections after refresh.

Hosted rollout: apply `supabase/migrations/20261012000100_weekly_visit_pattern.sql` to the synthetic `anuga` project before publishing the updated combined web build. Do not reset the hosted seed. Founder dashboard instructions and final checks will be recorded in HANDOFF.
