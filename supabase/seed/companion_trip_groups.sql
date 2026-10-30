-- SYNTHETIC DATA ONLY. Gives the synthetic companion Asha (+919000000201) one trip in each
-- group of the companion trips screen: Previous, Today and Upcoming. Times are relative to
-- when it runs, in Asia/Kolkata. Safe to run again: it replaces its own three trips only.
--
-- Run in the Supabase dashboard SQL Editor (as postgres) on the seeded synthetic project.
-- The app lists trips from 24 hours ago onward, so the Previous trip (23:59 IST yesterday)
-- stays listed until 23:59 IST today: check the screen on the same IST day, or run it again.
--   * Previous: completed, 23:59 IST yesterday
--   * Today:    scheduled, one hour from now (runs only before 22:00 IST)
--   * Upcoming: scheduled, 10:00 IST tomorrow
-- Remove afterwards: delete from public.trips where id::text like '92000000-%';

do $$
declare
  c_patient constant uuid := '70000000-0000-0000-0000-000000000001';
  c_centre constant uuid := '50000000-0000-0000-0000-000000000001';
  c_asha constant uuid := '30000000-0000-0000-0000-000000000001';
  v_today timestamptz := date_trunc('day', now() at time zone 'Asia/Kolkata') at time zone 'Asia/Kolkata';
  v_previous timestamptz := v_today - interval '1 minute';
  v_current timestamptz := now() + interval '1 hour';
  v_upcoming timestamptz := v_today + interval '1 day 10 hours';
begin
  -- Test projects only: same guard as demo_refresh.sql.
  if exists (select 1 from public.patients where full_name not like '%(synthetic)')
     or exists (select 1 from auth.users where coalesce(phone, '') not like '919000000___') then
    raise exception 'non-synthetic people found; companion_trip_groups.sql runs on synthetic test projects only';
  end if;
  if not exists (select 1 from public.profiles p join auth.users u on u.id = p.id
                 where p.id = c_asha and p.role = 'companion' and u.phone = '919000000201')
     or not exists (select 1 from public.patients where id = c_patient and full_name like '%(synthetic)') then
    raise exception 'synthetic companion Asha (+919000000201) or patient not found; load supabase/seed/seed.sql first';
  end if;
  if (now() at time zone 'Asia/Kolkata')::time >= time '22:00' then
    raise exception 'run between 00:00 and 22:00 IST, so the Today trip is still today';
  end if;

  delete from public.trips where id in (
    '92000000-0000-0000-0000-000000000001', '92000000-0000-0000-0000-000000000002',
    '92000000-0000-0000-0000-000000000003');
  insert into public.trips (id, patient_id, centre_id, companion_id, scheduled_pickup_at, scheduled_return_at,
                            status, picked_up_at, completed_at, post_visit_note)
  values
    ('92000000-0000-0000-0000-000000000001', c_patient, c_centre, c_asha, v_previous, v_previous + interval '5 hours',
     'completed', v_previous, v_previous + interval '5 hours', 'Home safely (synthetic Previous check)'),
    ('92000000-0000-0000-0000-000000000002', c_patient, c_centre, c_asha, v_current, v_current + interval '5 hours',
     'scheduled', null, null, null),
    ('92000000-0000-0000-0000-000000000003', c_patient, c_centre, c_asha, v_upcoming, v_upcoming + interval '5 hours',
     'scheduled', null, null, null);
end $$;

-- The three trips, their companion's phone and the group the screen should show them in.
select t.id, u.phone as companion_phone, t.status,
       to_char(t.scheduled_pickup_at at time zone 'Asia/Kolkata', 'Dy DD Mon HH24:MI') as pickup_ist,
       case (t.scheduled_pickup_at at time zone 'Asia/Kolkata')::date - (now() at time zone 'Asia/Kolkata')::date
         when -1 then 'Previous' when 0 then 'Today' else 'Upcoming' end as expected_group
from public.trips t join auth.users u on u.id = t.companion_id
where t.id::text like '92000000-%'
order by t.scheduled_pickup_at;
