-- Notification dispatch (M6). The outbox (public.notifications) is drained by a
-- trusted worker (Edge Function or Node, service role). Rows are claimed with a
-- lease so two workers never send the same row; failures retry with exponential
-- backoff up to a limit. Nothing here talks to a provider.

insert into public.app_settings (key, value, description) values
  ('notification_max_attempts', '5', 'Send attempts before a notification is marked failed'),
  ('notification_retry_base_seconds', '60', 'First retry delay; doubles on each further attempt'),
  ('notification_claim_seconds', '120', 'Lease on a claimed notification; expired leases are claimed again');

alter table public.notifications
  add column next_attempt_at timestamptz not null default now(),
  add column claimed_until timestamptz,
  add column last_error text,
  add column provider_message_id text;

drop index public.notifications_pending_idx;
create index notifications_due_idx on public.notifications (next_attempt_at, id) where status = 'pending';

-- What the `test` adapter "sent": the rendered message, so tests and pilots can
-- see exactly what a family would have received. No grants for app roles.
create table public.notification_deliveries (
  id bigint generated always as identity primary key,
  notification_id bigint not null references public.notifications (id) on delete cascade,
  adapter text not null,
  channel public.notification_channel not null,
  recipient_id uuid not null,
  language text not null,
  title text not null,
  body text not null,
  delivered_at timestamptz not null default now()
);
create index notification_deliveries_notification_idx on public.notification_deliveries (notification_id);
alter table public.notification_deliveries enable row level security;
revoke all on public.notification_deliveries from anon, authenticated;
grant select, insert on public.notification_deliveries to service_role;
grant usage on sequence public.notification_deliveries_id_seq to service_role;

-- Only the service role may drive the dispatcher.
create function private.assert_dispatcher()
returns void
language plpgsql stable security definer set search_path = ''
as $$
begin
  if coalesce(current_setting('role', true), 'none') <> 'service_role'
     and coalesce(auth.jwt() ->> 'role', '') <> 'service_role' then
    raise exception 'dispatcher only' using errcode = '42501';
  end if;
end;
$$;

-- Claims up to p_limit due notifications and counts the attempt. Returns what an
-- adapter needs: channel, template, payload, recipient phone and language.
create function public.dispatch_claim_notifications(p_limit integer default 50)
returns table (
  notification_id bigint, channel public.notification_channel, template text, payload jsonb,
  attempts integer, recipient_id uuid, recipient_phone text, recipient_language text
)
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_lease interval := make_interval(secs => private.setting_int('notification_claim_seconds'));
begin
  perform private.assert_dispatcher();

  return query
  with due as (
    select n.id from public.notifications n
    where n.status = 'pending' and n.next_attempt_at <= now()
      and (n.claimed_until is null or n.claimed_until < now())
    order by n.next_attempt_at, n.id
    limit least(greatest(coalesce(p_limit, 50), 1), 500)
    for update skip locked
  ), claimed as (
    update public.notifications n
    set claimed_until = now() + v_lease, attempts = n.attempts + 1
    from due where n.id = due.id
    returning n.*
  )
  select c.id, c.channel, c.template, c.payload, c.attempts, c.recipient_id, p.phone, p.preferred_language
  from claimed c
  join public.profiles p on p.id = c.recipient_id
  order by c.id;
end;
$$;

create function public.dispatch_mark_sent(p_notification_id bigint, p_provider_message_id text default null)
returns void
language plpgsql volatile security definer set search_path = ''
as $$
begin
  perform private.assert_dispatcher();
  update public.notifications
  set status = 'sent', sent_at = now(), claimed_until = null, last_error = null,
      provider_message_id = p_provider_message_id
  where id = p_notification_id and status = 'pending';
  if not found then
    raise exception 'notification % is not pending', p_notification_id using errcode = '22023';
  end if;
end;
$$;

-- Transient failures go back to pending with a backoff; permanent ones (or the
-- last allowed attempt) end as failed. Returns the resulting status.
create function public.dispatch_mark_failed(p_notification_id bigint, p_error text, p_permanent boolean default false)
returns public.notification_status
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_row public.notifications;
  v_base integer := private.setting_int('notification_retry_base_seconds');
begin
  perform private.assert_dispatcher();
  select * into v_row from public.notifications where id = p_notification_id and status = 'pending' for update;
  if not found then
    raise exception 'notification % is not pending', p_notification_id using errcode = '22023';
  end if;

  if p_permanent or v_row.attempts >= private.setting_int('notification_max_attempts') then
    update public.notifications
    set status = 'failed', claimed_until = null, last_error = left(p_error, 1000)
    where id = p_notification_id;
    return 'failed';
  end if;

  update public.notifications
  set claimed_until = null, last_error = left(p_error, 1000),
      next_attempt_at = now() + make_interval(secs => v_base * power(2, greatest(v_row.attempts - 1, 0))::integer)
  where id = p_notification_id;
  return 'pending';
end;
$$;

revoke execute on function private.assert_dispatcher() from public, anon, authenticated;
revoke execute on function
  public.dispatch_claim_notifications(integer),
  public.dispatch_mark_sent(bigint, text),
  public.dispatch_mark_failed(bigint, text, boolean)
from public, anon, authenticated;
grant execute on function
  public.dispatch_claim_notifications(integer),
  public.dispatch_mark_sent(bigint, text),
  public.dispatch_mark_failed(bigint, text, boolean)
to service_role;
