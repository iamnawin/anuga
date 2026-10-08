-- Family app read models (M5). Family members already reach these rows through
-- RLS; the functions give the app stable shapes without table access, and keep
-- columns the app must not show (event locations, actor ids) out of the result.

-- Patients the caller can see, with their access level. The level decides what
-- the app offers: pickup OTP (owner, editor, patient) and cancel (owner, editor).
create function public.family_my_patients()
returns table (
  patient_id uuid, full_name text, access_level public.access_level, centre_name text
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if auth.uid() is null or private.current_app_role() is distinct from 'family' then
    raise exception 'family accounts only' using errcode = '42501';
  end if;

  return query
  select p.id, p.full_name, pa.access_level, ce.name
  from public.patient_access pa
  join public.patients p on p.id = pa.patient_id
  join public.centres ce on ce.id = p.centre_id
  where pa.user_id = auth.uid()
  order by p.full_name;
end;
$$;

-- Status timeline of one trip, oldest first. No locations or actor ids.
create function public.family_trip_timeline(p_trip_id uuid)
returns table (
  event_id bigint, from_status public.trip_status, to_status public.trip_status,
  actor_kind public.transition_actor, note text, created_at timestamptz
)
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_patient_id uuid;
begin
  select patient_id into v_patient_id from public.trips where id = p_trip_id;
  if v_patient_id is null or not (private.can_view_patient(v_patient_id) or private.is_ops()) then
    raise exception 'not allowed' using errcode = '42501';
  end if;

  return query
  select e.id, e.from_status, e.to_status, e.actor_kind, e.note, e.created_at
  from public.trip_events e
  where e.trip_id = p_trip_id
  order by e.id;
end;
$$;

-- The caller's in-app inbox: push-channel notifications, newest first. The
-- WhatsApp copies of the same events are for the dispatcher, not the inbox.
create function public.my_notifications(p_limit integer default 50)
returns table (
  notification_id bigint, trip_id uuid, template text, payload jsonb, created_at timestamptz
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not allowed' using errcode = '42501';
  end if;

  return query
  select n.id, n.trip_id, n.template, n.payload, n.created_at
  from public.notifications n
  where n.recipient_id = auth.uid() and n.channel = 'push'
  order by n.id desc
  limit least(greatest(coalesce(p_limit, 50), 1), 200);
end;
$$;

revoke execute on function
  public.family_my_patients(),
  public.family_trip_timeline(uuid),
  public.my_notifications(integer)
from public, anon;
grant execute on function
  public.family_my_patients(),
  public.family_trip_timeline(uuid),
  public.my_notifications(integer)
to authenticated;
