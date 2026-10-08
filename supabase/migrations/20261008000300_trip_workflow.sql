-- Trip workflow: transitions, patient creation, assignment, trip generation,
-- pickup OTP, status changes with family notifications, and read projections.

insert into public.trip_transitions (from_status, to_status, actor, requires_otp)
select f::public.trip_status, t::public.trip_status, a::public.transition_actor, otp
from (values
  -- forward journey
  ('scheduled', 'companion_en_route', 'companion', false),
  ('companion_en_route', 'picked_up', 'companion', true),
  ('picked_up', 'at_centre', 'companion', false),
  ('at_centre', 'handed_over', 'companion', false),
  ('handed_over', 'session_done', 'companion', false),
  ('session_done', 'returning', 'companion', false),
  ('returning', 'dropped_home', 'companion', false),
  ('dropped_home', 'completed', 'companion', false),
  -- patient not available
  ('scheduled', 'no_show', 'companion', false),
  ('companion_en_route', 'no_show', 'companion', false),
  -- family may cancel before the companion sets off
  ('scheduled', 'cancelled', 'family', false)
) v(f, t, a, otp);

-- Companion can raise an issue from any active state.
insert into public.trip_transitions (from_status, to_status, actor)
select s::public.trip_status, 'issue_reported', 'companion'
from unnest(array['companion_en_route', 'picked_up', 'at_centre', 'handed_over',
                  'session_done', 'returning', 'dropped_home']) s;

-- Ops can do every non-OTP companion step (e.g. app failure), cancel any
-- non-terminal trip, and resolve issues. Ops cannot skip the pickup OTP except
-- by resolving an issue_reported trip, which is logged as an ops event.
insert into public.trip_transitions (from_status, to_status, actor)
select from_status, to_status, 'ops' from public.trip_transitions
where actor = 'companion' and not requires_otp;

insert into public.trip_transitions (from_status, to_status, actor)
select s::public.trip_status, 'cancelled', 'ops'
from unnest(array['scheduled', 'companion_en_route', 'picked_up', 'at_centre', 'handed_over',
                  'session_done', 'returning', 'dropped_home', 'issue_reported']) s;

insert into public.trip_transitions (from_status, to_status, actor)
select 'issue_reported', s::public.trip_status, 'ops'
from unnest(array['companion_en_route', 'picked_up', 'at_centre', 'handed_over',
                  'session_done', 'returning', 'dropped_home', 'completed']) s;

-- Internal helpers -----------------------------------------------------------

create function private.make_point(p_lat double precision, p_lng double precision)
returns extensions.geography
language sql immutable set search_path = ''
as $$
  select case when p_lat is null or p_lng is null then null
    else extensions.st_setsrid(extensions.st_makepoint(p_lng, p_lat), 4326)::extensions.geography end
$$;

create function private.notify_patient_family(
  p_trip_id uuid, p_patient_id uuid, p_template text, p_payload jsonb
)
returns void
language sql volatile security definer set search_path = ''
as $$
  insert into public.notifications (trip_id, recipient_id, channel, template, payload)
  select p_trip_id, pa.user_id, ch.channel, p_template, p_payload
  from public.patient_access pa
  cross join (values ('push'::public.notification_channel), ('whatsapp'::public.notification_channel)) ch(channel)
  where pa.patient_id = p_patient_id
$$;

create function private.notify_user(p_trip_id uuid, p_user_id uuid, p_template text, p_payload jsonb)
returns void
language sql volatile security definer set search_path = ''
as $$
  insert into public.notifications (trip_id, recipient_id, channel, template, payload)
  values (p_trip_id, p_user_id, 'push', p_template, p_payload)
$$;

-- Validates that a companion can serve a patient: verified, active, same cluster
-- as the patient's centre, and living within the cluster radius of the patient.
create function private.assert_companion_eligible(p_companion_id uuid, p_patient_id uuid)
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
    and c.cluster_id = cl.id
    and extensions.st_dwithin(c.home_location, p.home_location, cl.companion_radius_m);

  if v_ok is null then
    raise exception 'companion % is not eligible for patient %', p_companion_id, p_patient_id
      using errcode = 'P0001', hint = 'must be verified, active, in the cluster and within its radius';
  end if;
end;
$$;

create function private.apply_transition(
  p_trip public.trips,
  p_to public.trip_status,
  p_actor_kind public.transition_actor,
  p_note text,
  p_location extensions.geography
)
returns public.trips
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_trip public.trips;
begin
  update public.trips set
    status = p_to,
    status_before_issue = case when p_to = 'issue_reported' then p_trip.status else status_before_issue end,
    picked_up_at = case when p_to = 'picked_up' then now() else picked_up_at end,
    completed_at = case when p_to = 'completed' then now() else completed_at end,
    post_visit_note = case when p_to = 'completed' and p_note is not null then p_note else post_visit_note end,
    updated_at = now()
  where id = p_trip.id
  returning * into v_trip;

  insert into public.trip_events (trip_id, from_status, to_status, actor_id, actor_kind, note, location)
  values (p_trip.id, p_trip.status, p_to, auth.uid(), p_actor_kind, p_note, p_location);

  perform private.notify_patient_family(
    p_trip.id, p_trip.patient_id, 'trip_status_changed',
    jsonb_build_object('trip_id', p_trip.id, 'from_status', p_trip.status, 'to_status', p_to, 'note', p_note)
  );

  return v_trip;
end;
$$;

-- RPCs -------------------------------------------------------------------------

-- Family member creates a patient and becomes its owner.
create function public.create_patient(
  p_full_name text,
  p_home_address text,
  p_home_lat double precision,
  p_home_lng double precision,
  p_centre_id uuid,
  p_date_of_birth date default null,
  p_mobility_notes text default '',
  p_emergency_contacts jsonb default '[]'
)
returns uuid
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_patient_id uuid;
begin
  if auth.uid() is null or private.current_app_role() is distinct from 'family' then
    raise exception 'only family accounts can create patients' using errcode = '42501';
  end if;

  insert into public.patients (full_name, date_of_birth, home_address, home_location, centre_id,
                               mobility_notes, emergency_contacts, created_by)
  values (p_full_name, p_date_of_birth, p_home_address, private.make_point(p_home_lat, p_home_lng),
          p_centre_id, coalesce(p_mobility_notes, ''), coalesce(p_emergency_contacts, '[]'), auth.uid())
  returning id into v_patient_id;

  insert into public.patient_access (patient_id, user_id, access_level, granted_by)
  values (v_patient_id, auth.uid(), 'owner', auth.uid());

  insert into public.consents (user_id, patient_id, purpose) values (auth.uid(), v_patient_id, 'trips');

  return v_patient_id;
end;
$$;

-- Ops sets the fixed primary + backup companion for a weekly pattern and moves
-- future, not-yet-started trips that had no companion or the old primary.
create function public.ops_assign_schedule_companions(
  p_schedule_id uuid, p_primary_id uuid, p_backup_id uuid
)
returns public.schedules
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_schedule public.schedules;
  v_old_primary uuid;
begin
  if not (private.is_ops() or private.is_trusted_backend()) then
    raise exception 'ops only' using errcode = '42501';
  end if;
  if p_primary_id is null or p_backup_id is null or p_primary_id = p_backup_id then
    raise exception 'primary and backup must be two different companions' using errcode = '22023';
  end if;

  select * into v_schedule from public.schedules where id = p_schedule_id for update;
  if not found then
    raise exception 'schedule % not found', p_schedule_id using errcode = 'P0002';
  end if;

  perform private.assert_companion_eligible(p_primary_id, v_schedule.patient_id);
  perform private.assert_companion_eligible(p_backup_id, v_schedule.patient_id);

  v_old_primary := v_schedule.primary_companion_id;

  update public.schedules
  set primary_companion_id = p_primary_id, backup_companion_id = p_backup_id, updated_at = now()
  where id = p_schedule_id
  returning * into v_schedule;

  update public.trips
  set companion_id = p_primary_id, updated_at = now()
  where schedule_id = p_schedule_id
    and status = 'scheduled'
    and scheduled_pickup_at > now()
    and (companion_id is null or companion_id = v_old_primary);

  perform private.write_audit('assign_schedule_companions', 'schedules', p_schedule_id::text,
    v_schedule.patient_id, jsonb_build_object('primary', p_primary_id, 'backup', p_backup_id));
  perform private.notify_user(null, p_primary_id, 'schedule_assigned',
    jsonb_build_object('schedule_id', p_schedule_id, 'role', 'primary'));
  perform private.notify_user(null, p_backup_id, 'schedule_assigned',
    jsonb_build_object('schedule_id', p_schedule_id, 'role', 'backup'));
  perform private.notify_patient_family(null, v_schedule.patient_id, 'companion_assigned',
    jsonb_build_object('schedule_id', p_schedule_id));

  return v_schedule;
end;
$$;

-- Ops swaps the companion on one upcoming trip (e.g. primary unavailable -> backup).
create function public.ops_assign_trip_companion(p_trip_id uuid, p_companion_id uuid)
returns public.trips
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_trip public.trips;
begin
  if not private.is_ops() then
    raise exception 'ops only' using errcode = '42501';
  end if;

  select * into v_trip from public.trips where id = p_trip_id for update;
  if not found then
    raise exception 'trip % not found', p_trip_id using errcode = 'P0002';
  end if;
  if v_trip.status <> 'scheduled' then
    raise exception 'only scheduled trips can be reassigned' using errcode = '22023';
  end if;

  perform private.assert_companion_eligible(p_companion_id, v_trip.patient_id);

  update public.trips set companion_id = p_companion_id, updated_at = now()
  where id = p_trip_id returning * into v_trip;

  perform private.write_audit('assign_trip_companion', 'trips', p_trip_id::text, v_trip.patient_id,
    jsonb_build_object('companion', p_companion_id));
  perform private.notify_user(p_trip_id, p_companion_id, 'trip_assigned', jsonb_build_object('trip_id', p_trip_id));
  perform private.notify_patient_family(p_trip_id, v_trip.patient_id, 'companion_changed',
    jsonb_build_object('trip_id', p_trip_id));

  return v_trip;
end;
$$;

-- Generates trips for a schedule over a rolling window. Idempotent.
create function public.ops_generate_trips(
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
  if not (private.is_ops() or private.is_trusted_backend()) then
    raise exception 'ops only' using errcode = '42501';
  end if;

  select * into v_schedule from public.schedules where id = p_schedule_id and active;
  if not found then
    raise exception 'active schedule % not found', p_schedule_id using errcode = 'P0002';
  end if;
  select centre_id into v_centre_id from public.patients where id = v_schedule.patient_id;

  with days as (
    select d::date as day
    from generate_series(
      greatest(p_from, v_schedule.starts_on),
      p_from + coalesce(p_days, private.setting_int('trip_generation_days')) - 1,
      interval '1 day'
    ) d
  ), slots as (
    select (day + v_schedule.pickup_time) at time zone v_schedule.timezone as pickup_at
    from days
    where extract(isodow from day)::smallint = any (v_schedule.days_of_week)
      and (v_schedule.ends_on is null or day <= v_schedule.ends_on)
  ), inserted as (
    insert into public.trips (schedule_id, patient_id, centre_id, companion_id,
                              scheduled_pickup_at, scheduled_return_at)
    select v_schedule.id, v_schedule.patient_id, v_centre_id, v_schedule.primary_companion_id,
           pickup_at, pickup_at + make_interval(mins => v_schedule.session_minutes)
    from slots
    on conflict (schedule_id, scheduled_pickup_at) do nothing
    returning 1
  )
  select count(*) into v_count from inserted;

  return v_count;
end;
$$;

-- Family (owner, editor or the patient) issues a fresh 6-digit pickup code and
-- shares it with the companion at the door. Only a salted hash is stored.
create function public.issue_pickup_otp(p_trip_id uuid)
returns text
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_trip public.trips;
  v_code text;
  v_salt bytea;
begin
  select * into v_trip from public.trips where id = p_trip_id;
  if not found or coalesce(private.access_level_for(v_trip.patient_id) in ('owner', 'editor', 'patient'), false) is false then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  if v_trip.status not in ('scheduled', 'companion_en_route') then
    raise exception 'trip is not awaiting pickup' using errcode = '22023';
  end if;

  -- gen_random_uuid() uses a cryptographic RNG; take 32 random bits for the code.
  v_code := lpad(((('x' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))::bit(32)::bigint) % 1000000)::text, 6, '0');
  v_salt := uuid_send(gen_random_uuid());

  insert into public.trip_otps (trip_id, otp_hash, salt, attempts, expires_at, issued_by, issued_at, consumed_at)
  values (p_trip_id, sha256(v_salt || convert_to(v_code, 'UTF8')), v_salt, 0,
          now() + make_interval(mins => private.setting_int('pickup_otp_ttl_minutes')), auth.uid(), now(), null)
  on conflict (trip_id) do update set
    otp_hash = excluded.otp_hash, salt = excluded.salt, attempts = 0,
    expires_at = excluded.expires_at, issued_by = excluded.issued_by,
    issued_at = excluded.issued_at, consumed_at = null;

  perform private.write_audit('issue_pickup_otp', 'trips', p_trip_id::text, v_trip.patient_id);
  return v_code;
end;
$$;

-- Companion enters the code at pickup. Wrong codes return ok=false instead of
-- raising, so the attempt counter is committed.
create function public.verify_pickup_otp(
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

-- Every other status change. The caller's relationship to the trip decides
-- which transitions apply (companion on the trip, ops, or family editor).
create function public.advance_trip(
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

  return private.apply_transition(v_trip, p_to_status, v_actor, p_note, private.make_point(p_lat, p_lng));
end;
$$;

-- Family booking board: upcoming trips with companion display names.
create function public.family_trip_board(
  p_patient_id uuid,
  p_from timestamptz default now() - interval '1 day',
  p_to timestamptz default now() + interval '14 days'
)
returns table (
  trip_id uuid, scheduled_pickup_at timestamptz, scheduled_return_at timestamptz,
  status public.trip_status, centre_name text, companion_name text,
  primary_companion_name text, backup_companion_name text
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not (private.can_view_patient(p_patient_id) or private.is_ops()) then
    raise exception 'not allowed' using errcode = '42501';
  end if;

  return query
  select t.id, t.scheduled_pickup_at, t.scheduled_return_at, t.status, ce.name,
         cp.full_name, pp.full_name, bp.full_name
  from public.trips t
  join public.centres ce on ce.id = t.centre_id
  left join public.profiles cp on cp.id = t.companion_id
  left join public.schedules s on s.id = t.schedule_id
  left join public.profiles pp on pp.id = s.primary_companion_id
  left join public.profiles bp on bp.id = s.backup_companion_id
  where t.patient_id = p_patient_id
    and t.scheduled_pickup_at between p_from and p_to
  order by t.scheduled_pickup_at;
end;
$$;

-- Companion's restricted projection. Patient fields are returned only inside
-- the configured window around each trip; outside it they are null.
-- Never returns vault data, diagnoses or date of birth.
create function public.companion_my_trips(
  p_from timestamptz default now() - interval '1 day',
  p_to timestamptz default now() + interval '14 days'
)
returns table (
  trip_id uuid, scheduled_pickup_at timestamptz, scheduled_return_at timestamptz,
  status public.trip_status, centre_name text, centre_address text, details_visible boolean,
  patient_name text, home_address text, home_lat double precision, home_lng double precision,
  mobility_notes text, emergency_contacts jsonb
)
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_before interval := make_interval(hours => private.setting_int('companion_details_hours_before'));
  v_after interval := make_interval(hours => private.setting_int('companion_details_hours_after'));
begin
  if auth.uid() is null or private.current_app_role() is distinct from 'companion' then
    raise exception 'companions only' using errcode = '42501';
  end if;

  return query
  with mine as (
    select t.*, (now() between t.scheduled_pickup_at - v_before and t.scheduled_return_at + v_after
                 and t.status not in ('cancelled', 'no_show')) as visible
    from public.trips t
    where t.companion_id = auth.uid()
      and t.scheduled_pickup_at between p_from and p_to
  )
  select m.id, m.scheduled_pickup_at, m.scheduled_return_at, m.status, ce.name, ce.address, m.visible,
         case when m.visible then p.full_name end,
         case when m.visible then p.home_address end,
         case when m.visible then extensions.st_y(p.home_location::extensions.geometry) end,
         case when m.visible then extensions.st_x(p.home_location::extensions.geometry) end,
         case when m.visible then p.mobility_notes end,
         case when m.visible then p.emergency_contacts end
  from mine m
  join public.patients p on p.id = m.patient_id
  join public.centres ce on ce.id = m.centre_id
  order by m.scheduled_pickup_at;
end;
$$;

-- Execute rights: nothing for anon; app RPCs for authenticated only.
revoke execute on all functions in schema public from public, anon;
revoke execute on all functions in schema private from public;
grant execute on function
  public.create_patient(text, text, double precision, double precision, uuid, date, text, jsonb),
  public.ops_assign_schedule_companions(uuid, uuid, uuid),
  public.ops_assign_trip_companion(uuid, uuid),
  public.ops_generate_trips(uuid, date, integer),
  public.issue_pickup_otp(uuid),
  public.verify_pickup_otp(uuid, text, double precision, double precision),
  public.advance_trip(uuid, public.trip_status, text, double precision, double precision),
  public.family_trip_board(uuid, timestamptz, timestamptz),
  public.companion_my_trips(timestamptz, timestamptz)
to authenticated;
grant execute on function private.is_ops(), private.can_view_patient(uuid), private.can_edit_patient(uuid),
  private.can_view_trip(uuid), private.access_level_for(uuid)
to authenticated;
