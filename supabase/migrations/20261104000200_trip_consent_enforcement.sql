-- Withdrawal blocks fresh Companion details and actions, including existing JWTs.
-- Ops and Family retain their separately authorized history/operational access.
begin;

-- Serialize consent changes and Companion transitions on the patient row. This
-- covers direct, RLS-authorized consent writes as well as set_consent(). A call
-- already in flight linearizes before or after withdrawal, never a cached JWT flag.
create function private.lock_consent_patient()
returns trigger
language plpgsql volatile security definer set search_path = ''
as $$
begin
  perform 1 from public.patients where id = new.patient_id for update;
  return new;
end;
$$;
create trigger consent_patient_lock before insert or update on public.consents
for each row execute function private.lock_consent_patient();

create function private.assert_trip_consent(p_patient_id uuid)
returns void
language plpgsql volatile security definer set search_path = ''
as $$
begin
  perform 1 from public.patients where id = p_patient_id for update;
  if not private.owner_consent_active(p_patient_id, 'trips') then
    raise exception 'the patient''s owner must give trip consent first' using errcode = '42501';
  end if;
end;
$$;

create function private.enforce_companion_trip_consent()
returns trigger
language plpgsql volatile security definer set search_path = ''
as $$
begin
  if private.current_app_role() = 'companion' and old.companion_id = auth.uid() then
    perform private.assert_trip_consent(old.patient_id);
  end if;
  return new;
end;
$$;
create trigger companion_trip_consent before update of status on public.trips
for each row execute function private.enforce_companion_trip_consent();

create or replace function private.can_view_trip(p_trip_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.trips t
    where t.id = p_trip_id
      and ((t.companion_id = auth.uid()
            and private.owner_consent_active(t.patient_id, 'trips')
            and private.companion_window_open(t.scheduled_pickup_at, t.scheduled_return_at, t.status))
           or private.can_view_patient(t.patient_id) or private.is_ops())
  )
$$;

drop policy participants on public.trips;
create policy participants on public.trips for select to authenticated
  using ((companion_id = auth.uid()
          and private.owner_consent_active(patient_id, 'trips')
          and private.companion_window_open(scheduled_pickup_at, scheduled_return_at, status))
         or private.can_view_patient(patient_id) or private.is_ops());

revoke all on function private.lock_consent_patient(), private.enforce_companion_trip_consent(), private.assert_trip_consent(uuid)
from public, anon, authenticated, service_role;

create or replace function public.companion_my_trips(
  p_from timestamptz default now() - interval '1 day',
  p_to timestamptz default now() + interval '14 days'
)
returns table (
  trip_id uuid, scheduled_pickup_at timestamptz, scheduled_return_at timestamptz,
  status public.trip_status, centre_name text, centre_address text, details_visible boolean,
  patient_name text, home_address text, home_lat double precision, home_lng double precision,
  mobility_notes text, emergency_contacts jsonb, start_allowed_at timestamptz
)
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_before interval := make_interval(hours => private.setting_int('companion_details_hours_before'));
  v_after interval := make_interval(hours => private.setting_int('companion_details_hours_after'));
  v_start interval := make_interval(mins => private.setting_int('companion_start_minutes_before'));
begin
  if auth.uid() is null or private.current_app_role() is distinct from 'companion' then
    raise exception 'companions only' using errcode = '42501';
  end if;

  return query
  with mine as (
    select t.*, (now() between t.scheduled_pickup_at - v_before and t.scheduled_return_at + v_after
                 and t.status not in ('cancelled', 'no_show')
                 and private.owner_consent_active(t.patient_id, 'trips')) as visible
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
         case when m.visible then p.emergency_contacts end,
         m.scheduled_pickup_at - v_start
  from mine m
  join public.patients p on p.id = m.patient_id
  join public.centres ce on ce.id = m.centre_id
  order by m.scheduled_pickup_at;
end;
$$;

revoke execute on function public.companion_my_trips(timestamptz, timestamptz) from public, anon;
grant execute on function public.companion_my_trips(timestamptz, timestamptz) to authenticated;

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
  perform private.assert_trip_consent(v_trip.patient_id);
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


commit;
