-- Companion app: say when "Start" becomes possible instead of letting the companion
-- tap it and get refused by advance_trip (F05). Same setting as advance_trip, so the
-- app never hard-codes the window. Adds start_allowed_at to companion_my_trips().

drop function public.companion_my_trips(timestamptz, timestamptz);

create function public.companion_my_trips(
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
