-- Ops console read models (M3). Ops already has RLS read access to the base
-- tables; these functions join them into the shapes the console needs, so the
-- console never assembles patient data from several tables itself.
-- Every function here is ops-only and raises 42501 for anyone else.

insert into public.app_settings (key, value, description) values
  ('ops_late_after_minutes', '0',
   'Exception queue marks a trip late when it is still scheduled this many minutes after planned pickup'),
  ('ops_exception_lookback_days', '7',
   'Exception queue shows no_show and issue_reported trips from this many days back'),
  ('ops_board_max_days', '62', 'Largest date range the ops trip board returns in one call');

create function private.assert_ops()
returns void
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not private.is_ops() then
    raise exception 'ops only' using errcode = '42501';
  end if;
end;
$$;

-- Weekly patterns with patient, centre and the fixed primary + backup companion.
create function public.ops_schedule_board()
returns table (
  schedule_id uuid, patient_id uuid, patient_name text, centre_name text, cluster_id uuid,
  package_name text, days_of_week smallint[], pickup_time time, timezone text, active boolean,
  primary_companion_id uuid, primary_companion_name text,
  backup_companion_id uuid, backup_companion_name text, upcoming_trips integer
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform private.assert_ops();

  return query
  select s.id, p.id, p.full_name, ce.name, ce.cluster_id, pk.name, s.days_of_week, s.pickup_time,
         s.timezone, s.active, s.primary_companion_id, pp.full_name, s.backup_companion_id, bp.full_name,
         (select count(*)::integer from public.trips t
          where t.schedule_id = s.id and t.status = 'scheduled' and t.scheduled_pickup_at > now())
  from public.schedules s
  join public.patients p on p.id = s.patient_id
  join public.centres ce on ce.id = p.centre_id
  join public.packages pk on pk.id = s.package_id
  left join public.profiles pp on pp.id = s.primary_companion_id
  left join public.profiles bp on bp.id = s.backup_companion_id
  order by s.active desc, p.full_name, s.pickup_time;
end;
$$;

-- Trips in a date range, optionally filtered by status. is_late follows the
-- same rule as the exception queue.
create function public.ops_trip_board(
  p_from timestamptz,
  p_to timestamptz,
  p_statuses public.trip_status[] default null
)
returns table (
  trip_id uuid, scheduled_pickup_at timestamptz, scheduled_return_at timestamptz,
  status public.trip_status, status_before_issue public.trip_status,
  patient_id uuid, patient_name text, centre_name text, cluster_id uuid,
  companion_id uuid, companion_name text, schedule_id uuid,
  primary_companion_id uuid, primary_companion_name text,
  backup_companion_id uuid, backup_companion_name text,
  is_late boolean, updated_at timestamptz
)
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_late interval := make_interval(mins => private.setting_int('ops_late_after_minutes'));
begin
  perform private.assert_ops();
  if p_from is null or p_to is null or p_to < p_from
     or p_to - p_from > make_interval(days => private.setting_int('ops_board_max_days')) then
    raise exception 'invalid date range' using errcode = '22023',
      hint = 'from must be before to, within ops_board_max_days';
  end if;

  return query
  select t.id, t.scheduled_pickup_at, t.scheduled_return_at, t.status, t.status_before_issue,
         p.id, p.full_name, ce.name, ce.cluster_id, t.companion_id, cp.full_name, t.schedule_id,
         s.primary_companion_id, pp.full_name, s.backup_companion_id, bp.full_name,
         (t.status = 'scheduled' and now() > t.scheduled_pickup_at + v_late), t.updated_at
  from public.trips t
  join public.patients p on p.id = t.patient_id
  join public.centres ce on ce.id = t.centre_id
  left join public.profiles cp on cp.id = t.companion_id
  left join public.schedules s on s.id = t.schedule_id
  left join public.profiles pp on pp.id = s.primary_companion_id
  left join public.profiles bp on bp.id = s.backup_companion_id
  where t.scheduled_pickup_at between p_from and p_to
    and (p_statuses is null or t.status = any (p_statuses))
  order by t.scheduled_pickup_at, p.full_name;
end;
$$;

-- Trips that need ops attention: late (still scheduled after pickup time),
-- no_show and issue_reported, with the latest event note.
create function public.ops_exception_queue()
returns table (
  trip_id uuid, kind text, status public.trip_status, status_before_issue public.trip_status,
  scheduled_pickup_at timestamptz, patient_id uuid, patient_name text, centre_name text,
  companion_id uuid, companion_name text, backup_companion_id uuid, backup_companion_name text,
  last_note text, since timestamptz
)
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_late interval := make_interval(mins => private.setting_int('ops_late_after_minutes'));
  v_since timestamptz := now() - make_interval(days => private.setting_int('ops_exception_lookback_days'));
begin
  perform private.assert_ops();

  return query
  select t.id,
         case when t.status = 'scheduled' then 'late' else t.status::text end,
         t.status, t.status_before_issue, t.scheduled_pickup_at, p.id, p.full_name, ce.name,
         t.companion_id, cp.full_name, s.backup_companion_id, bp.full_name,
         ev.note, coalesce(ev.created_at, t.scheduled_pickup_at)
  from public.trips t
  join public.patients p on p.id = t.patient_id
  join public.centres ce on ce.id = t.centre_id
  left join public.profiles cp on cp.id = t.companion_id
  left join public.schedules s on s.id = t.schedule_id
  left join public.profiles bp on bp.id = s.backup_companion_id
  left join lateral (
    select e.note, e.created_at from public.trip_events e
    where e.trip_id = t.id order by e.id desc limit 1
  ) ev on true
  where (t.status = 'scheduled' and now() > t.scheduled_pickup_at + v_late
         and t.scheduled_pickup_at >= v_since)
     or (t.status in ('no_show', 'issue_reported') and t.updated_at >= v_since)
  order by case t.status when 'issue_reported' then 0 when 'scheduled' then 1 else 2 end,
           t.scheduled_pickup_at;
end;
$$;

-- Companions in the patient's cluster with the reason each one is or is not
-- eligible. Uses the same rule as private.assert_companion_eligible; the
-- assignment RPCs remain the authority and are tested against this list.
create function public.ops_companion_options(p_patient_id uuid)
returns table (
  companion_id uuid, full_name text, verification_status public.verification_status, active boolean,
  distance_m integer, radius_m integer, eligible boolean, reason text
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform private.assert_ops();
  if not exists (select 1 from public.patients where id = p_patient_id) then
    raise exception 'patient % not found', p_patient_id using errcode = 'P0002';
  end if;

  return query
  with opts as (
    select c.id, pr.full_name, c.verification_status, c.active,
           extensions.st_distance(c.home_location, p.home_location)::integer as distance_m,
           cl.companion_radius_m as radius_m,
           extensions.st_dwithin(c.home_location, p.home_location, cl.companion_radius_m) as within
    from public.patients p
    join public.centres ce on ce.id = p.centre_id
    join public.clusters cl on cl.id = ce.cluster_id
    join public.companions c on c.cluster_id = cl.id
    join public.profiles pr on pr.id = c.id
    where p.id = p_patient_id
  )
  select o.id, o.full_name, o.verification_status, o.active, o.distance_m, o.radius_m,
         (o.active and o.verification_status = 'verified' and o.within),
         case
           when not o.active then 'inactive'
           when o.verification_status <> 'verified' then 'not_verified'
           when not o.within then 'outside_radius'
         end
  from opts o
  order by (o.active and o.verification_status = 'verified' and o.within) desc, o.distance_m;
end;
$$;

revoke execute on function private.assert_ops() from public, anon, authenticated;
revoke execute on function
  public.ops_schedule_board(),
  public.ops_trip_board(timestamptz, timestamptz, public.trip_status[]),
  public.ops_exception_queue(),
  public.ops_companion_options(uuid)
from public, anon;
grant execute on function
  public.ops_schedule_board(),
  public.ops_trip_board(timestamptz, timestamptz, public.trip_status[]),
  public.ops_exception_queue(),
  public.ops_companion_options(uuid)
to authenticated;
