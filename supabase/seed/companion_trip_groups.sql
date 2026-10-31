-- SYNTHETIC DATA ONLY: three grouping fixtures for Asha (+919000000201).
-- Run this file in the seeded synthetic project's SQL Editor as postgres.
-- Changes only the three exact 9200...001/002/003 trips below; no schedules,
-- invoices, auth, settings, grants or RPC changes. Reruns update in place.
-- Refuses collisions and trips used by a workflow/invoice; do not interact with
-- these trips beyond viewing. Cleanup: companion_trip_groups_cleanup.sql.
--
-- All grouping dates use Asia/Kolkata; this runs at ANY time of day:
--   Previous: completed, last microsecond of yesterday; return/completion at
--             midnight (intentionally a boundary fixture, not a real journey).
--   Today: scheduled, noon today (may already be past; grouping is by date).
--   Upcoming: scheduled, 10:00 tomorrow.
-- The RPC's default pickup range is now()-1 day through now()+14 days.
-- Previous remains listed through this IST day's final microsecond, then expires
-- at the next midnight. Today/Upcoming also change groups then. Run again and
-- refresh after midnight; never widen permissions to keep yesterday's fixture.
-- The result below shows the deadline. Near midnight, finish before it or rerun.

do $$
declare
  c_ids constant uuid[] := array[
    '92000000-0000-0000-0000-000000000001', '92000000-0000-0000-0000-000000000002',
    '92000000-0000-0000-0000-000000000003']::uuid[];
  c_patient constant uuid := '70000000-0000-0000-0000-000000000001';
  c_centre constant uuid := '50000000-0000-0000-0000-000000000001';
  c_asha constant uuid := '30000000-0000-0000-0000-000000000001';
  v_today timestamptz := date_trunc('day', now() at time zone 'Asia/Kolkata') at time zone 'Asia/Kolkata';
  v_previous timestamptz := v_today - interval '1 microsecond';
  v_current timestamptz := v_today + interval '12 hours';
  v_upcoming timestamptz := v_today + interval '1 day 10 hours';
  v_count integer;
begin
  if exists (select 1 from public.patients where full_name not like '%(synthetic)')
     or exists (select 1 from auth.users where coalesce(phone, '') not like '919000000___') then
    raise exception 'non-synthetic people found; companion_trip_groups.sql runs on synthetic test projects only';
  end if;
  if not exists (select 1 from public.profiles p join auth.users u on u.id = p.id
                 where p.id = c_asha and p.role = 'companion' and u.phone = '919000000201')
     or not exists (select 1 from public.patients where id = c_patient and full_name like '%(synthetic)') then
    raise exception 'synthetic companion Asha (+919000000201) or patient not found; do not reset hosted seed';
  end if;

  perform 1 from public.trips where id = any(c_ids) for update;
  if exists (select 1 from public.trips t where t.id = any(c_ids) and not (
      t.patient_id = c_patient and t.centre_id = c_centre and t.companion_id is not distinct from c_asha
      and t.schedule_id is null and t.fare_amount_paise is null and t.status_before_issue is null
      and ((t.id = c_ids[1] and t.status = 'completed' and coalesce(t.post_visit_note, '') in
              ('Synthetic companion_trip_groups.sql: Previous', 'Home safely (synthetic Previous check)'))
        or (t.id in (c_ids[2], c_ids[3]) and t.status = 'scheduled'
            and (t.post_visit_note is null or t.post_visit_note = 'Synthetic companion_trip_groups.sql: ' ||
                 case when t.id = c_ids[2] then 'Today' else 'Upcoming' end))))) then
    raise exception 'fixed trip IDs are not pristine fixture-owned records; no changes made';
  end if;
  if exists (select 1 from public.trip_events where trip_id = any(c_ids))
     or exists (select 1 from public.trip_otps where trip_id = any(c_ids))
     or exists (select 1 from public.notifications where trip_id = any(c_ids))
     or exists (select 1 from public.invoice_lines where trip_id = any(c_ids)) then
    raise exception 'fixture trips have dependent workflow or invoice records; no changes made';
  end if;

  insert into public.trips (id, patient_id, centre_id, companion_id, scheduled_pickup_at, scheduled_return_at,
                            status, picked_up_at, completed_at, post_visit_note)
  values
    (c_ids[1], c_patient, c_centre, c_asha, v_previous, v_today,
     'completed', v_previous, v_today, 'Synthetic companion_trip_groups.sql: Previous'),
    (c_ids[2], c_patient, c_centre, c_asha, v_current, v_current + interval '5 hours',
     'scheduled', null, null, 'Synthetic companion_trip_groups.sql: Today'),
    (c_ids[3], c_patient, c_centre, c_asha, v_upcoming, v_upcoming + interval '5 hours',
     'scheduled', null, null, 'Synthetic companion_trip_groups.sql: Upcoming')
  on conflict (id) do update set
    scheduled_pickup_at = excluded.scheduled_pickup_at, scheduled_return_at = excluded.scheduled_return_at,
    status = excluded.status, picked_up_at = excluded.picked_up_at, completed_at = excluded.completed_at,
    post_visit_note = excluded.post_visit_note
  where public.trips.patient_id = c_patient and public.trips.centre_id = c_centre
    and public.trips.companion_id = c_asha and public.trips.schedule_id is null
    and public.trips.fare_amount_paise is null and public.trips.status_before_issue is null
    and public.trips.status = excluded.status
    and (public.trips.post_visit_note = excluded.post_visit_note
      or (public.trips.id = c_ids[1] and public.trips.post_visit_note = 'Home safely (synthetic Previous check)')
      or (public.trips.id in (c_ids[2], c_ids[3]) and public.trips.post_visit_note is null));
  get diagnostics v_count = row_count;
  if v_count <> 3 then raise exception 'concurrent non-fixture-owned collision; no changes made'; end if;
end $$;

-- Authenticated identity must still be confirmed in the browser; this verifies
-- the fixture assignment only. Fractional seconds expose the midnight boundary.
select t.id, u.phone as companion_phone, t.status,
       to_char(t.scheduled_pickup_at at time zone 'Asia/Kolkata', 'YYYY-MM-DD HH24:MI:SS.US') as pickup_ist,
       case when (t.scheduled_pickup_at at time zone 'Asia/Kolkata')::date < (now() at time zone 'Asia/Kolkata')::date
              then 'Previous'
            when (t.scheduled_pickup_at at time zone 'Asia/Kolkata')::date = (now() at time zone 'Asia/Kolkata')::date
              then 'Today' else 'Upcoming' end as expected_group,
       date_trunc('day', now() at time zone 'Asia/Kolkata') + interval '1 day' as verify_before_ist
from public.trips t join auth.users u on u.id = t.companion_id
where t.id in ('92000000-0000-0000-0000-000000000001', '92000000-0000-0000-0000-000000000002',
               '92000000-0000-0000-0000-000000000003')
order by t.scheduled_pickup_at;
