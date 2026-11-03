-- Operational incident and Ops notes are not Family-facing visit notes.
-- Existing state, assignment, OTP and transition rules remain unchanged.
begin;

-- Serialize the privacy cutover with visit writes; ordinary reads can continue.
lock table public.trips, public.trip_events, public.notifications in share row exclusive mode;

create table if not exists private.trip_event_internal_notes (
  event_id bigint primary key references public.trip_events (id) on delete cascade,
  note text not null
);
alter table private.trip_event_internal_notes enable row level security;
revoke all on private.trip_event_internal_notes from public, anon, authenticated, service_role;

-- Preserve historical operational text before clearing its public copies.
insert into private.trip_event_internal_notes (event_id, note)
select e.id, e.note from public.trip_events e
where e.note is not null and (e.to_status = 'issue_reported' or e.actor_kind = 'ops')
on conflict (event_id) do nothing;

update public.notifications n
set payload = jsonb_set(n.payload, '{note}', 'null'::jsonb)
from public.trip_events e join private.trip_event_internal_notes i on i.event_id = e.id
where n.trip_id = e.trip_id and n.template = 'trip_status_changed'
  and n.payload ->> 'from_status' is not distinct from e.from_status::text
  and n.payload ->> 'to_status' = e.to_status::text
  and n.payload ->> 'note' = i.note;

-- An old Ops completion may have copied its internal note into the trip row.
-- Do not alter updated_at, status, assignment, pickup/return or completion time.
update public.trips t set post_visit_note = null
where exists (
  select 1 from public.trip_events e
  join private.trip_event_internal_notes i on i.event_id = e.id
  where e.trip_id = t.id and e.actor_kind = 'ops' and e.to_status = 'completed'
    and t.post_visit_note = i.note
);

update public.trip_events e set note = null
where e.note is not null and exists (
  select 1 from private.trip_event_internal_notes i where i.event_id = e.id
);

create or replace function private.apply_transition(
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
  v_event_id bigint;
  v_internal boolean := p_to = 'issue_reported' or p_actor_kind = 'ops';
  v_family_note text;
begin
  v_family_note := case when v_internal then null else p_note end;

  update public.trips set
    status = p_to,
    status_before_issue = case when p_to = 'issue_reported' then p_trip.status else status_before_issue end,
    picked_up_at = case when p_to = 'picked_up' then now() else picked_up_at end,
    completed_at = case when p_to = 'completed' then now() else completed_at end,
    post_visit_note = case when p_to = 'completed' and v_family_note is not null then v_family_note else post_visit_note end,
    updated_at = now()
  where id = p_trip.id
  returning * into v_trip;

  insert into public.trip_events (trip_id, from_status, to_status, actor_id, actor_kind, note, location)
  values (p_trip.id, p_trip.status, p_to, auth.uid(), p_actor_kind, v_family_note, p_location)
  returning id into v_event_id;

  if v_internal and p_note is not null then
    insert into private.trip_event_internal_notes (event_id, note) values (v_event_id, p_note);
  end if;

  perform private.notify_patient_family(
    p_trip.id, p_trip.patient_id, 'trip_status_changed',
    jsonb_build_object('trip_id', p_trip.id, 'from_status', p_trip.status, 'to_status', p_to, 'note', v_family_note)
  );
  return v_trip;
end;
$$;
revoke execute on function private.apply_transition(
  public.trips, public.trip_status, public.transition_actor, text, extensions.geography
) from public, anon, authenticated, service_role;

-- Same Ops-only projection and signature, now including its restricted note.
create or replace function public.ops_exception_queue()
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
    select coalesce(i.note, e.note) as note, e.created_at
    from public.trip_events e
    left join private.trip_event_internal_notes i on i.event_id = e.id
    where e.trip_id = t.id order by e.id desc limit 1
  ) ev on true
  where (t.status = 'scheduled' and now() > t.scheduled_pickup_at + v_late
         and t.scheduled_pickup_at >= v_since)
     or (t.status in ('no_show', 'issue_reported') and t.updated_at >= v_since)
  order by case t.status when 'issue_reported' then 0 when 'scheduled' then 1 else 2 end,
           t.scheduled_pickup_at;
end;
$$;

-- Exception-screen actions must still refer to the same unresolved incident.
-- The existing advance_trip() remains the transition/actor authority.
create or replace function public.ops_resolve_visit_issue(
  p_trip_id uuid,
  p_expected_since timestamptz,
  p_to_status public.trip_status,
  p_note text default null
)
returns public.trips
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_trip public.trips;
  v_since timestamptz;
  v_latest_status public.trip_status;
begin
  perform private.assert_ops();
  select * into v_trip from public.trips where id = p_trip_id for update;
  if not found or v_trip.status <> 'issue_reported' then
    raise exception 'the visit issue changed; refresh the exception queue' using errcode = '22023';
  end if;

  select e.created_at, e.to_status into v_since, v_latest_status
  from public.trip_events e where e.trip_id = p_trip_id order by e.id desc limit 1;
  if v_latest_status is distinct from 'issue_reported'::public.trip_status
     or v_since is distinct from p_expected_since then
    raise exception 'the visit issue changed; refresh the exception queue' using errcode = '22023';
  end if;
  if p_to_status is null or (p_to_status <> 'cancelled'
      and (v_trip.status_before_issue is null or p_to_status is distinct from v_trip.status_before_issue)) then
    raise exception 'resume only the recorded prior stage, or explicitly cancel' using errcode = '22023';
  end if;
  return public.advance_trip(p_trip_id, p_to_status, p_note);
end;
$$;
revoke execute on function public.ops_resolve_visit_issue(uuid, timestamptz, public.trip_status, text)
  from public, anon, authenticated, service_role;
grant execute on function public.ops_resolve_visit_issue(uuid, timestamptz, public.trip_status, text)
  to authenticated;

commit;
