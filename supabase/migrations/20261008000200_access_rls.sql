-- Access helpers, grants and row-level security.
--
-- Supabase grants every new public table to anon/authenticated by default.
-- For health data we invert that: revoke everything, then grant per table and
-- per column. RLS is enabled on every table as a second layer.

-- Helpers (private schema is not exposed through the API) ------------------

create function private.setting_int(p_key text)
returns integer
language sql stable security definer set search_path = ''
as $$ select (value #>> '{}')::integer from public.app_settings where key = p_key $$;

create function private.current_app_role()
returns public.user_role
language sql stable security definer set search_path = ''
as $$ select role from public.profiles where id = auth.uid() $$;

create function private.is_ops()
returns boolean
language sql stable security definer set search_path = ''
as $$ select coalesce(private.current_app_role() = 'ops_admin', false) $$;

-- Direct database sessions (migrations, seed, psql) and the service role are
-- trusted backends. API sessions always run as anon/authenticated.
create function private.is_trusted_backend()
returns boolean
language sql stable security definer set search_path = ''
as $$ select auth.uid() is null and coalesce(current_setting('role', true), 'none') in ('none', 'postgres', 'service_role') $$;

create function private.access_level_for(p_patient_id uuid)
returns public.access_level
language sql stable security definer set search_path = ''
as $$ select access_level from public.patient_access where patient_id = p_patient_id and user_id = auth.uid() $$;

create function private.can_view_patient(p_patient_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$ select private.access_level_for(p_patient_id) is not null $$;

create function private.can_edit_patient(p_patient_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$ select coalesce(private.access_level_for(p_patient_id) in ('owner', 'editor'), false) $$;

create function private.can_view_trip(p_trip_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.trips t
    where t.id = p_trip_id
      and (t.companion_id = auth.uid() or private.can_view_patient(t.patient_id) or private.is_ops())
  )
$$;

create function private.write_audit(
  p_action text, p_table text, p_record_id text, p_patient_id uuid, p_details jsonb default '{}'
)
returns void
language sql volatile security definer set search_path = ''
as $$
  insert into public.audit_log (actor_id, action, table_name, record_id, patient_id, details)
  values (auth.uid(), p_action, p_table, p_record_id, p_patient_id, coalesce(p_details, '{}'))
$$;

-- Row-change audit for tables that carry patient data.
create function private.audit_row_change()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  v_row jsonb := to_jsonb(coalesce(new, old));
begin
  perform private.write_audit(
    lower(tg_op),
    tg_table_name,
    coalesce(v_row ->> 'id', (v_row ->> 'patient_id') || ':' || (v_row ->> 'user_id')),
    coalesce(v_row ->> 'patient_id', case when tg_table_name = 'patients' then v_row ->> 'id' end)::uuid
  );
  return null;
end;
$$;

-- Every new auth user gets a profile. The role is never taken from client metadata.
create function private.handle_new_user()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, phone, full_name)
  values (new.id, new.phone, coalesce(new.raw_user_meta_data ->> 'full_name', ''));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

create trigger patients_audit after insert or update or delete on public.patients
  for each row execute function private.audit_row_change();
create trigger patient_access_audit after insert or update or delete on public.patient_access
  for each row execute function private.audit_row_change();
create trigger consents_audit after insert or update or delete on public.consents
  for each row execute function private.audit_row_change();

grant usage on schema private to authenticated;
revoke execute on all functions in schema private from public;
grant execute on function
  private.is_ops(), private.can_view_patient(uuid), private.can_edit_patient(uuid),
  private.can_view_trip(uuid), private.access_level_for(uuid)
to authenticated;

-- Grants ---------------------------------------------------------------------

revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
alter default privileges in schema public revoke all on tables from anon, authenticated;

grant select on public.app_settings, public.clusters, public.centres, public.packages,
  public.trip_transitions to authenticated;
grant select on public.profiles to authenticated;
grant update (full_name, phone, preferred_language) on public.profiles to authenticated;
grant select on public.patients to authenticated;
grant update (full_name, date_of_birth, home_address, home_location, mobility_notes, emergency_contacts)
  on public.patients to authenticated;
grant select on public.patient_access, public.companions, public.trips, public.trip_events,
  public.notifications, public.audit_log to authenticated;
grant select on public.schedules to authenticated;
grant insert (patient_id, package_id, days_of_week, pickup_time, session_minutes, starts_on, ends_on)
  on public.schedules to authenticated;
grant update (days_of_week, pickup_time, session_minutes, ends_on, active) on public.schedules to authenticated;
grant select, insert (user_id, patient_id, purpose), update (withdrawn_at) on public.consents to authenticated;
-- trip_otps: intentionally no grants.

-- RLS --------------------------------------------------------------------------

alter table public.app_settings enable row level security;
alter table public.profiles enable row level security;
alter table public.clusters enable row level security;
alter table public.centres enable row level security;
alter table public.patients enable row level security;
alter table public.patient_access enable row level security;
alter table public.consents enable row level security;
alter table public.companions enable row level security;
alter table public.packages enable row level security;
alter table public.schedules enable row level security;
alter table public.trips enable row level security;
alter table public.trip_otps enable row level security;
alter table public.trip_events enable row level security;
alter table public.trip_transitions enable row level security;
alter table public.notifications enable row level security;
alter table public.audit_log enable row level security;

create policy read_all on public.app_settings for select to authenticated using (true);
create policy read_all on public.clusters for select to authenticated using (true);
create policy read_all on public.centres for select to authenticated using (true);
create policy read_all on public.packages for select to authenticated using (true);
create policy read_all on public.trip_transitions for select to authenticated using (true);

create policy self_or_ops on public.profiles for select to authenticated
  using (id = auth.uid() or private.is_ops());
create policy update_self on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- Companions never match these policies: they reach patient fields only through
-- public.companion_my_trips(), which returns a restricted projection.
create policy family_or_ops on public.patients for select to authenticated
  using (private.can_view_patient(id) or private.is_ops());
create policy editors_or_ops on public.patients for update to authenticated
  using (private.can_edit_patient(id) or private.is_ops())
  with check (private.can_edit_patient(id) or private.is_ops());

create policy own_or_owned_patient_or_ops on public.patient_access for select to authenticated
  using (user_id = auth.uid() or private.access_level_for(patient_id) = 'owner' or private.is_ops());

create policy own_or_owner_or_ops on public.consents for select to authenticated
  using (user_id = auth.uid() or private.access_level_for(patient_id) = 'owner' or private.is_ops());
create policy give_own on public.consents for insert to authenticated
  with check (user_id = auth.uid() and private.can_view_patient(patient_id));
create policy withdraw_own on public.consents for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy self_or_ops on public.companions for select to authenticated
  using (id = auth.uid() or private.is_ops());

create policy family_or_ops on public.schedules for select to authenticated
  using (private.can_view_patient(patient_id) or private.is_ops());
create policy editors_insert on public.schedules for insert to authenticated
  with check (private.can_edit_patient(patient_id) or private.is_ops());
create policy editors_update on public.schedules for update to authenticated
  using (private.can_edit_patient(patient_id) or private.is_ops())
  with check (private.can_edit_patient(patient_id) or private.is_ops());

create policy participants on public.trips for select to authenticated
  using (companion_id = auth.uid() or private.can_view_patient(patient_id) or private.is_ops());

create policy participants on public.trip_events for select to authenticated
  using (private.can_view_trip(trip_id));

create policy own_or_ops on public.notifications for select to authenticated
  using (recipient_id = auth.uid() or private.is_ops());

create policy owner_or_ops on public.audit_log for select to authenticated
  using (private.is_ops() or (patient_id is not null and private.access_level_for(patient_id) = 'owner'));
