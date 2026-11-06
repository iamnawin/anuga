-- Founder-approved pilot rule: one occupied visit per Companion. No travel
-- buffer, pricing or new handover exceptions. Privileged maintenance/seed writes
-- remain owner operations; authenticated and service-role writes are guarded.
begin;

create function private.enforce_companion_occupancy()
returns trigger
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_assignment boolean;
  v_start boolean := false;
begin
  if coalesce(current_setting('role', true), 'none') not in ('authenticated', 'service_role') then
    return new;
  end if;

  if tg_op = 'INSERT' then
    v_assignment := true;
  else
    v_assignment := new.companion_id is distinct from old.companion_id
      or new.scheduled_pickup_at is distinct from old.scheduled_pickup_at
      or new.scheduled_return_at is distinct from old.scheduled_return_at;
    v_start := new.status not in ('scheduled', 'issue_reported', 'completed', 'cancelled', 'no_show')
      and old.status in ('scheduled', 'issue_reported');
    if new.companion_id is distinct from old.companion_id and old.status <> 'scheduled' then
      raise exception 'only scheduled trips can be reassigned' using errcode = '22023';
    end if;
  end if;

  if new.companion_id is null then return new; end if;
  if not v_assignment and not v_start then return new; end if;
  if new.status in ('cancelled', 'no_show') then return new; end if;

  -- Competing assignments/starts for this Companion wait on one database row.
  -- The conflict SELECT runs after the lock, with the latest committed snapshot.
  perform 1 from public.companions where id = new.companion_id for update;

  if exists (
    select 1 from public.trips t
    where t.companion_id = new.companion_id and t.id <> new.id
      and t.status not in ('cancelled', 'no_show')
      -- ops_generate_trips is idempotent: an existing schedule/slot is skipped
      -- by its unique constraint, not treated as a second assignment.
      and not (tg_op = 'INSERT' and new.schedule_id is not null
               and t.schedule_id is not distinct from new.schedule_id
               and t.scheduled_pickup_at = new.scheduled_pickup_at)
      and (
        (v_start and (t.status not in ('scheduled', 'completed')
          and (t.status <> 'issue_reported' or t.status_before_issue is distinct from 'scheduled'::public.trip_status)))
        or
        (v_assignment and new.scheduled_return_at > t.scheduled_pickup_at
          and new.scheduled_pickup_at < case
            when t.status = 'completed' then greatest(t.scheduled_return_at, t.completed_at)
            when t.status <> 'scheduled' and t.scheduled_return_at < clock_timestamp()
              then 'infinity'::timestamptz
            else t.scheduled_return_at
          end)
      )
  ) then
    raise exception 'companion has a conflicting occupied visit' using errcode = '22023';
  end if;
  return new;
end;
$$;

create trigger companion_occupancy before insert or update of companion_id, scheduled_pickup_at, scheduled_return_at, status
on public.trips for each row execute function private.enforce_companion_occupancy();

revoke all on function private.enforce_companion_occupancy()
from public, anon, authenticated, service_role;

commit;
