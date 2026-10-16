-- Only cancellation push notices are deduplicated. This also tolerates PR #10's
-- existing explicit sender after the shared transition helper has sent the notice.
create unique index notifications_cancelled_push_key
  on public.notifications (trip_id, recipient_id)
  where channel = 'push' and template = 'trip_status_changed'
    and payload ->> 'to_status' = 'cancelled';

create or replace function private.notify_user(p_trip_id uuid, p_user_id uuid, p_template text, p_payload jsonb)
returns void
language sql volatile security definer set search_path = ''
as $$
  insert into public.notifications (trip_id, recipient_id, channel, template, payload)
  values (p_trip_id, p_user_id, 'push', p_template, p_payload)
  on conflict (trip_id, recipient_id)
    where channel = 'push' and template = 'trip_status_changed'
      and payload ->> 'to_status' = 'cancelled'
    do nothing
$$;

-- Keep transition authorization, event history and family notifications intact.
-- The caller holds the trip row lock; notification and cancellation commit together.
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

  if p_to = 'cancelled' and v_trip.companion_id is not null then
    perform private.notify_user(v_trip.id, v_trip.companion_id, 'trip_status_changed',
      jsonb_build_object('trip_id', v_trip.id, 'to_status', 'cancelled'));
  end if;

  return v_trip;
end;
$$;
