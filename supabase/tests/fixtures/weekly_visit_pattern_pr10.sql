-- Keep cancelled bookings as history, while permitting a fresh booking when
-- Ops explicitly restores a weekday removed by the weekly-pattern editor.
alter table public.trips drop constraint trips_schedule_id_scheduled_pickup_at_key;
create unique index trips_live_schedule_pickup_key
  on public.trips (schedule_id, scheduled_pickup_at) where status <> 'cancelled';

-- Retain the existing generator's cancellation semantics with the new index.
-- The schedule lock serializes generation with weekly-pattern changes.
create or replace function public.ops_generate_trips(
  p_schedule_id uuid, p_from date default current_date, p_days integer default null
)
returns integer
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_schedule public.schedules;
  v_centre_id uuid;
  v_count integer;
begin
  if (private.is_ops() or private.is_trusted_backend()) is not true then
    raise exception 'ops only' using errcode = '42501';
  end if;
  select * into v_schedule from public.schedules where id = p_schedule_id and active for update;
  if not found then
    raise exception 'active schedule % not found', p_schedule_id using errcode = 'P0002';
  end if;
  select centre_id into v_centre_id from public.patients where id = v_schedule.patient_id;

  with days as (
    select d::date as day from generate_series(
      greatest(p_from, v_schedule.starts_on),
      p_from + coalesce(p_days, private.setting_int('trip_generation_days')) - 1, interval '1 day'
    ) d
  ), slots as (
    select (day + v_schedule.pickup_time) at time zone v_schedule.timezone as pickup_at
    from days where extract(isodow from day)::smallint = any(v_schedule.days_of_week)
      and (v_schedule.ends_on is null or day <= v_schedule.ends_on)
  ), inserted as (
    insert into public.trips (schedule_id, patient_id, centre_id, companion_id,
                              scheduled_pickup_at, scheduled_return_at)
    select v_schedule.id, v_schedule.patient_id, v_centre_id, v_schedule.primary_companion_id,
           pickup_at, pickup_at + make_interval(mins => v_schedule.session_minutes)
    from slots where not exists (
      select 1 from public.trips t where t.schedule_id = v_schedule.id and t.scheduled_pickup_at = pickup_at
    )
    on conflict (schedule_id, scheduled_pickup_at) where status <> 'cancelled' do nothing
    returning 1
  ) select count(*) into v_count from inserted;
  return v_count;
end;
$$;

create function public.ops_update_schedule_pattern(
  p_schedule_id uuid, p_days_of_week smallint[], p_expected_days smallint[]
)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_schedule public.schedules;
  v_days smallint[];
  v_trip public.trips;
  v_today date;
  v_centre_id uuid;
  v_cancelled integer := 0;
  v_cancelled_ids uuid[] := array[]::uuid[];
  v_generated integer := 0;
  v_cancel_note constant text := 'Cancelled because weekly schedule changed.';
begin
  if private.is_ops() is not true then
    raise exception 'ops only' using errcode = '42501';
  end if;
  select array_agg(distinct d order by d) into v_days from unnest(p_days_of_week) d;
  if p_days_of_week is null or cardinality(p_days_of_week) not between 1 and 4
     or cardinality(v_days) <> cardinality(p_days_of_week)
     or array_position(p_days_of_week, null) is not null
     or not (v_days <@ array[1,2,3,4,5,6,7]::smallint[]) then
    raise exception 'select one to four different weekdays' using errcode = '22023';
  end if;
  select * into v_schedule from public.schedules where id = p_schedule_id for update;
  if not found then
    raise exception 'schedule not found' using errcode = 'P0002';
  end if;
  v_today := (clock_timestamp() at time zone v_schedule.timezone)::date;
  if not v_schedule.active or v_schedule.ends_on < v_today then
    raise exception 'schedule is paused or has ended' using errcode = '22023';
  end if;
  if p_expected_days is null or not (p_expected_days @> v_schedule.days_of_week
     and p_expected_days <@ v_schedule.days_of_week) then
    raise exception 'weekly schedule changed; refresh before saving' using errcode = '40001';
  end if;

  update public.schedules set days_of_week = v_days, updated_at = now() where id = p_schedule_id;
  -- Row locks make a concurrent companion check-in win or wait safely. The
  -- status/time predicates exclude every started, terminal and past booking.
  for v_trip in
    select * from public.trips where schedule_id = p_schedule_id
      and status = 'scheduled' and scheduled_pickup_at > clock_timestamp()
      and not (extract(isodow from scheduled_pickup_at at time zone v_schedule.timezone)::smallint = any(v_days))
    order by id for update
  loop
    if v_trip.scheduled_pickup_at <= clock_timestamp() then
      continue;
    end if;
    perform public.advance_trip(v_trip.id, 'cancelled', v_cancel_note);
    if v_trip.companion_id is not null then
      perform private.notify_user(v_trip.id, v_trip.companion_id, 'trip_status_changed',
        jsonb_build_object('trip_id', v_trip.id, 'to_status', 'cancelled'));
    end if;
    v_cancelled := v_cancelled + 1;
    v_cancelled_ids := array_append(v_cancelled_ids, v_trip.id);
  end loop;

  select centre_id into v_centre_id from public.patients where id = v_schedule.patient_id;
  for v_trip in
    with days as (
      select d::date as day from generate_series(greatest(v_today, v_schedule.starts_on),
        v_today + private.setting_int('trip_generation_days') - 1, interval '1 day') d
    ), slots as (
      select (day + v_schedule.pickup_time) at time zone v_schedule.timezone as pickup_at
      from days where extract(isodow from day)::smallint = any(v_days)
        and (v_schedule.ends_on is null or day <= v_schedule.ends_on)
    )
    insert into public.trips (schedule_id, patient_id, centre_id, companion_id,
                              scheduled_pickup_at, scheduled_return_at)
    select v_schedule.id, v_schedule.patient_id, v_centre_id, v_schedule.primary_companion_id,
           pickup_at, pickup_at + make_interval(mins => v_schedule.session_minutes)
    from slots where pickup_at > clock_timestamp() and not exists (
      select 1 from public.trips t where t.schedule_id = p_schedule_id and t.scheduled_pickup_at = pickup_at
        and (t.status <> 'cancelled' or not exists (
          select 1 from public.audit_log a where a.action = 'update_schedule_pattern'
            and a.table_name = 'schedules' and a.record_id = p_schedule_id::text
            and a.details->'cancelled_trip_ids' ? t.id::text
        ))
    )
    on conflict (schedule_id, scheduled_pickup_at) where status <> 'cancelled' do nothing
    returning *
  loop
    insert into public.trip_events (trip_id, to_status, actor_id, actor_kind, note)
      values (v_trip.id, 'scheduled', auth.uid(), 'ops', 'Created from weekly schedule.');
    perform private.notify_patient_family(v_trip.id, v_trip.patient_id, 'trip_status_changed',
      jsonb_build_object('trip_id', v_trip.id, 'to_status', 'scheduled'));
    if v_trip.companion_id is not null then
      perform private.notify_user(v_trip.id, v_trip.companion_id, 'trip_assigned',
        jsonb_build_object('trip_id', v_trip.id));
    end if;
    v_generated := v_generated + 1;
  end loop;

  if v_days is distinct from v_schedule.days_of_week or v_cancelled > 0 or v_generated > 0 then
    perform private.write_audit('update_schedule_pattern', 'schedules', p_schedule_id::text,
      v_schedule.patient_id, jsonb_build_object('previous_days', v_schedule.days_of_week,
        'days', v_days, 'cancelled', v_cancelled, 'generated', v_generated,
        'cancelled_trip_ids', to_jsonb(v_cancelled_ids)));
  end if;
  return jsonb_build_object('cancelled', v_cancelled, 'generated', v_generated);
end;
$$;

revoke execute on function public.ops_update_schedule_pattern(uuid, smallint[], smallint[]) from public, anon;
grant execute on function public.ops_update_schedule_pattern(uuid, smallint[], smallint[]) to authenticated;
