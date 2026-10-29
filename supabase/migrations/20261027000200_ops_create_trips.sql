-- Ops console "Create trips": generate a schedule's trips for the coming days and report,
-- per pickup date, whether a trip was created or already existed (skipped). Safe to
-- repeat: the unique (schedule_id, scheduled_pickup_at) key never allows a duplicate,
-- and a skipped date keeps its trip as it is (status, companion, notes).
-- ops_generate_trips keeps its signature for the seed and now counts these rows.

create function public.ops_create_schedule_trips(
  p_schedule_id uuid, p_from date default current_date, p_days integer default null
)
returns table (pickup_date date, pickup_at timestamptz, created boolean)
language plpgsql volatile security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  v_schedule public.schedules;
  v_centre_id uuid;
  v_days integer := coalesce(p_days, private.setting_int('trip_generation_days'));
begin
  if not (private.is_ops() or private.is_trusted_backend()) then
    raise exception 'ops only' using errcode = '42501';
  end if;
  if v_days is null or v_days not between 1 and 60 then
    raise exception 'days must be between 1 and 60' using errcode = '22023';
  end if;

  select * into v_schedule from public.schedules where id = p_schedule_id and active;
  if not found then
    raise exception 'active schedule % not found', p_schedule_id using errcode = 'P0002';
  end if;
  select centre_id into v_centre_id from public.patients where id = v_schedule.patient_id;

  return query
  with days as (
    select d::date as day
    from generate_series(greatest(p_from, v_schedule.starts_on), p_from + v_days - 1, interval '1 day') d
  ), slots as (
    select day as slot_day, (day + v_schedule.pickup_time) at time zone v_schedule.timezone as slot_at
    from days
    where extract(isodow from day)::smallint = any (v_schedule.days_of_week)
      and (v_schedule.ends_on is null or day <= v_schedule.ends_on)
  ), inserted as (
    insert into public.trips (schedule_id, patient_id, centre_id, companion_id,
                              scheduled_pickup_at, scheduled_return_at)
    select v_schedule.id, v_schedule.patient_id, v_centre_id, v_schedule.primary_companion_id,
           slot_at, slot_at + make_interval(mins => v_schedule.session_minutes)
    from slots
    on conflict (schedule_id, scheduled_pickup_at) do nothing
    returning scheduled_pickup_at
  )
  select s.slot_day, s.slot_at, exists (select 1 from inserted i where i.scheduled_pickup_at = s.slot_at)
  from slots s
  order by s.slot_at;
end;
$$;

create or replace function public.ops_generate_trips(
  p_schedule_id uuid, p_from date default current_date, p_days integer default null
)
returns integer
language sql volatile security definer set search_path = ''
as $$
  select count(*)::integer from public.ops_create_schedule_trips(p_schedule_id, p_from, p_days) where created
$$;

revoke execute on function public.ops_create_schedule_trips(uuid, date, integer) from public, anon;
grant execute on function public.ops_create_schedule_trips(uuid, date, integer) to authenticated;
