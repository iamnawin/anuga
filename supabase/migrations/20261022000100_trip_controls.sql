-- Trip controls from the 2026-10-22 review (docs/research/anugacare-db-findings-2026-10-22.md):
-- F02 training and suspension, F04 companion reads limited to the detail window,
-- F05 companion start window, F06 required notes.

insert into public.app_settings (key, value, description) values
  ('companion_start_minutes_before', '180',
   'Companion can start a trip (on the way) from this many minutes before pickup');

-- F04: true while a companion may see a trip. Same window and statuses as
-- companion_my_trips(), which stays the companion's read path.
create function private.companion_window_open(
  p_pickup timestamptz, p_return timestamptz, p_status public.trip_status
)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select now() between p_pickup - make_interval(hours => private.setting_int('companion_details_hours_before'))
                   and p_return + make_interval(hours => private.setting_int('companion_details_hours_after'))
     and p_status not in ('cancelled', 'no_show')
$$;

-- F02: assignment needs a trained companion too.
create or replace function private.assert_companion_eligible(p_companion_id uuid, p_patient_id uuid)
returns void
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_ok boolean;
begin
  select true into v_ok
  from public.companions c
  join public.patients p on p.id = p_patient_id
  join public.centres ce on ce.id = p.centre_id
  join public.clusters cl on cl.id = ce.cluster_id
  where c.id = p_companion_id
    and c.active
    and c.verification_status = 'verified'
    and c.training_completed
    and c.cluster_id = cl.id
    and extensions.st_dwithin(c.home_location, p.home_location, cl.companion_radius_m);

  if v_ok is null then
    raise exception 'companion % is not eligible for patient %', p_companion_id, p_patient_id
      using errcode = 'P0001', hint = 'must be verified, trained, active, in the cluster and within its radius';
  end if;
end;
$$;

-- F02: a companion who is no longer active, verified and trained cannot act on
-- trips already assigned to them. Ops can still cancel or reassign.
create function private.assert_companion_can_act()
returns void
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.companions c
    where c.id = auth.uid() and c.active and c.verification_status = 'verified' and c.training_completed
  ) then
    raise exception 'companion is not active' using errcode = '42501';
  end if;
end;
$$;

create or replace function public.verify_pickup_otp(
  p_trip_id uuid, p_code text, p_lat double precision default null, p_lng double precision default null
)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_trip public.trips;
  v_otp public.trip_otps;
  v_max integer := private.setting_int('pickup_otp_max_attempts');
begin
  select * into v_trip from public.trips where id = p_trip_id for update;
  if not found or v_trip.companion_id is distinct from auth.uid() then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  perform private.assert_companion_can_act();
  if v_trip.status <> 'companion_en_route' then
    raise exception 'trip is not awaiting pickup' using errcode = '22023';
  end if;

  select * into v_otp from public.trip_otps where trip_id = p_trip_id for update;
  if not found or v_otp.consumed_at is not null or v_otp.expires_at < now() or v_otp.attempts >= v_max then
    return jsonb_build_object('ok', false, 'reason', 'no_valid_code', 'attempts_left', 0);
  end if;

  if sha256(v_otp.salt || convert_to(coalesce(p_code, ''), 'UTF8')) <> v_otp.otp_hash then
    update public.trip_otps set attempts = attempts + 1 where trip_id = p_trip_id;
    return jsonb_build_object('ok', false, 'reason', 'wrong_code', 'attempts_left', v_max - v_otp.attempts - 1);
  end if;

  update public.trip_otps set consumed_at = now() where trip_id = p_trip_id;
  v_trip := private.apply_transition(v_trip, 'picked_up', 'companion', 'pickup OTP verified',
                                     private.make_point(p_lat, p_lng));
  return jsonb_build_object('ok', true, 'status', v_trip.status);
end;
$$;

create or replace function public.advance_trip(
  p_trip_id uuid,
  p_to_status public.trip_status,
  p_note text default null,
  p_lat double precision default null,
  p_lng double precision default null
)
returns public.trips
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_trip public.trips;
  v_actor public.transition_actor;
begin
  select * into v_trip from public.trips where id = p_trip_id for update;
  if not found then
    raise exception 'not allowed' using errcode = '42501';
  end if;

  v_actor := case
    when v_trip.companion_id = auth.uid() then 'companion'
    when private.is_ops() then 'ops'
    when private.can_edit_patient(v_trip.patient_id) then 'family'
  end;
  if v_actor is null then
    raise exception 'not allowed' using errcode = '42501';
  end if;

  if not exists (
    select 1 from public.trip_transitions
    where from_status = v_trip.status and to_status = p_to_status and actor = v_actor and not requires_otp
  ) then
    raise exception 'transition % -> % not allowed for %', v_trip.status, p_to_status, v_actor
      using errcode = '22023';
  end if;

  if v_actor = 'companion' then
    perform private.assert_companion_can_act();

    -- F05: no starting a trip long before pickup.
    if p_to_status = 'companion_en_route'
       and now() < v_trip.scheduled_pickup_at
                   - make_interval(mins => private.setting_int('companion_start_minutes_before')) then
      raise exception 'too early to start this trip' using errcode = '22023';
    end if;

    -- F06: the companion app requires these notes; so does the database.
    if p_to_status in ('completed', 'issue_reported') and nullif(btrim(p_note), '') is null then
      raise exception 'a note is required for %', p_to_status using errcode = '22023';
    end if;
  end if;

  return private.apply_transition(v_trip, p_to_status, v_actor, p_note, private.make_point(p_lat, p_lng));
end;
$$;

-- F02: ops options show untrained companions as not eligible, same rule as assignment.
create or replace function public.ops_companion_options(p_patient_id uuid)
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
    select c.id, pr.full_name, c.verification_status, c.active, c.training_completed,
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
         (o.active and o.verification_status = 'verified' and o.training_completed and o.within),
         case
           when not o.active then 'inactive'
           when o.verification_status <> 'verified' then 'not_verified'
           when not o.training_completed then 'not_trained'
           when not o.within then 'outside_radius'
         end
  from opts o
  order by (o.active and o.verification_status = 'verified' and o.training_completed and o.within) desc,
           o.distance_m;
end;
$$;

-- F04: a companion reads their own trip rows and events only inside the detail
-- window. Family viewers and ops are unchanged.
create or replace function private.can_view_trip(p_trip_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.trips t
    where t.id = p_trip_id
      and ((t.companion_id = auth.uid()
            and private.companion_window_open(t.scheduled_pickup_at, t.scheduled_return_at, t.status))
           or private.can_view_patient(t.patient_id) or private.is_ops())
  )
$$;

drop policy participants on public.trips;
create policy participants on public.trips for select to authenticated
  using ((companion_id = auth.uid()
          and private.companion_window_open(scheduled_pickup_at, scheduled_return_at, status))
         or private.can_view_patient(patient_id) or private.is_ops());

revoke execute on function
  private.companion_window_open(timestamptz, timestamptz, public.trip_status),
  private.assert_companion_can_act()
from public;
grant execute on function
  private.companion_window_open(timestamptz, timestamptz, public.trip_status)
to authenticated;
