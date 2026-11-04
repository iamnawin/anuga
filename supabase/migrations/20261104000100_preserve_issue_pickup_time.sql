-- Resuming an incident at picked_up is not a second verified pickup.
-- Preserve the original pickup fact; the resume still records its own event time.
begin;

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
    picked_up_at = case when p_to = 'picked_up' and p_trip.status <> 'issue_reported' then now() else picked_up_at end,
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

commit;
