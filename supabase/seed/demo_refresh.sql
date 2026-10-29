-- SYNTHETIC DATA ONLY. Refreshes the demo state on a seeded staging project so every
-- screen has something to show, relative to the time it runs. Safe to run again:
-- today's demo trips are recreated, history and invoices are kept.
--
-- Run in the Supabase dashboard SQL Editor (as postgres) after seed.sql. It leaves:
--   * schedule trips for the next 14 days (Mon/Wed/Fri 07:00, Asha)
--   * past schedule trips still 'scheduled' closed as completed, with a fare
--   * four trips today: Start open (Asha), en route (Ravi), at the centre (Asha),
--     and a late pickup for the exception queue (Ravi)
--   * four completed visits last month, invoiced and issued to the family

do $$
declare
  c_patient constant uuid := '70000000-0000-0000-0000-000000000001';
  c_centre constant uuid := '50000000-0000-0000-0000-000000000001';
  c_schedule constant uuid := '80000000-0000-0000-0000-000000000001';
  c_asha constant uuid := '30000000-0000-0000-0000-000000000001';
  c_ravi constant uuid := '30000000-0000-0000-0000-000000000002';
  c_ops constant uuid := '10000000-0000-0000-0000-000000000001';
  v_last_month date := (date_trunc('month', now() at time zone 'Asia/Kolkata') - interval '1 month')::date;
  v_trip public.trips;
  v_status public.trip_status;
  v_invoice uuid;
begin
  if not exists (select 1 from public.patients where id = c_patient and full_name like '%(synthetic)') then
    raise exception 'synthetic seed patient not found; load supabase/seed/seed.sql first';
  end if;
  -- Test projects only: refuse to touch a database holding a patient not marked synthetic
  -- or an account outside the reserved synthetic numbers (+91 90000 00xxx).
  if exists (select 1 from public.patients where full_name not like '%(synthetic)')
     or exists (select 1 from auth.users where coalesce(phone, '') not like '919000000___') then
    raise exception 'non-synthetic people found; demo_refresh.sql runs on synthetic test projects only';
  end if;

  -- Upcoming schedule trips.
  update public.schedules set active = true, ends_on = null where id = c_schedule;
  perform public.ops_generate_trips(c_schedule, current_date, 14);

  -- Past schedule trips nobody moved: close them as completed visits.
  update public.trips set
    status = 'completed',
    picked_up_at = scheduled_pickup_at,
    completed_at = scheduled_return_at,
    fare_amount_paise = coalesce(fare_amount_paise, 12000),
    post_visit_note = coalesce(post_visit_note, 'Home safely (synthetic demo)'),
    updated_at = now()
  where schedule_id = c_schedule and status = 'scheduled'
    and scheduled_pickup_at < date_trunc('day', now() at time zone 'Asia/Kolkata') at time zone 'Asia/Kolkata';

  -- Today's trips, recreated each run so they stay relative to now.
  delete from public.trips where id in (
    '91000000-0000-0000-0000-000000000001', '91000000-0000-0000-0000-000000000002',
    '91000000-0000-0000-0000-000000000003', '91000000-0000-0000-0000-000000000004');

  insert into public.trips (id, patient_id, centre_id, companion_id, scheduled_pickup_at, scheduled_return_at)
  values
    -- Inside the start window: Asha can press Start.
    ('91000000-0000-0000-0000-000000000001', c_patient, c_centre, c_asha, now() + interval '90 minutes', now() + interval '390 minutes'),
    -- Ravi is on the way: the family can issue a pickup code.
    ('91000000-0000-0000-0000-000000000002', c_patient, c_centre, c_ravi, now() + interval '20 minutes', now() + interval '320 minutes'),
    -- Asha is at the centre with the patient.
    ('91000000-0000-0000-0000-000000000003', c_patient, c_centre, c_asha, now() - interval '2 hours', now() + interval '3 hours'),
    -- Nobody started: shows as a late pickup.
    ('91000000-0000-0000-0000-000000000004', c_patient, c_centre, c_ravi, now() - interval '40 minutes', now() + interval '260 minutes');

  -- Walk the real transitions so the timeline and family updates are filled in.
  select * into v_trip from public.trips where id = '91000000-0000-0000-0000-000000000002';
  v_trip := private.apply_transition(v_trip, 'companion_en_route', 'companion', null, null);

  select * into v_trip from public.trips where id = '91000000-0000-0000-0000-000000000003';
  foreach v_status in array array['companion_en_route', 'picked_up', 'at_centre']::public.trip_status[] loop
    v_trip := private.apply_transition(v_trip, v_status, 'companion', null, null);
  end loop;

  -- Last month's history: four completed visits (ids fixed per month, so reruns add nothing).
  insert into public.trips (id, patient_id, centre_id, companion_id, scheduled_pickup_at, scheduled_return_at,
                            status, picked_up_at, completed_at, fare_amount_paise, post_visit_note)
  select md5('demo-history-' || v_last_month || '-' || n)::uuid, c_patient, c_centre, c_asha,
         p, p + interval '5 hours', 'completed', p, p + interval '5 hours', 12000,
         'Home safely (synthetic demo)'
  from generate_series(0, 3) n
  cross join lateral (select ((v_last_month + n * 7 + 1) + time '07:00') at time zone 'Asia/Kolkata' as p) t
  on conflict (id) do nothing;

  -- Invoice last month and issue it to the family, acting as the synthetic ops admin.
  if not exists (select 1 from public.invoices where patient_id = c_patient and period_start = v_last_month
                 and status <> 'draft') then
    perform set_config('request.jwt.claims', json_build_object('sub', c_ops, 'role', 'authenticated')::text, true);
    v_invoice := public.ops_generate_invoice(c_patient, v_last_month);
    perform public.ops_issue_invoice(v_invoice);
    perform set_config('request.jwt.claims', '', true);
  end if;
end;
$$;

-- What the screens will show.
select
  (select count(*) from public.trips where patient_id = '70000000-0000-0000-0000-000000000001'
     and scheduled_pickup_at > now()) as upcoming_trips,
  (select count(*) from public.trips where id::text like '91000000-%') as todays_demo_trips,
  (select count(*) from public.invoices where patient_id = '70000000-0000-0000-0000-000000000001'
     and status = 'issued') as issued_bills;
