-- A Family care request is a one-date schedule. Existing ops trip generation
-- confirms it; existing assignment selects the companion. No new table grants,
-- patient-centre permission, prices, payment rules or availability promises.

create function public.family_care_options(p_patient_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
begin
  if private.current_app_role() is distinct from 'family'
     or not private.can_edit_patient(p_patient_id) then
    raise exception 'only this patient''s owner or editor can request care' using errcode = '42501';
  end if;
  if not private.owner_consent_active(p_patient_id, 'trips') then
    raise exception 'the patient''s owner must give trip consent first' using errcode = '42501';
  end if;
  return (
    select jsonb_build_object(
      'centre_id', ce.id, 'centre_name', ce.name,
      'packages', (select coalesce(jsonb_agg(jsonb_build_object('id',pk.id,'name',pk.name) order by pk.name), '[]'::jsonb)
                   from public.packages pk where pk.active))
    from public.patients p join public.centres ce on ce.id=p.centre_id
    where p.id=p_patient_id
  );
end;
$$;

create function public.family_request_care(
  p_request_id uuid, p_patient_id uuid, p_centre_id uuid, p_package_id uuid, p_pickup_at timestamptz
)
returns uuid
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_centre uuid;
  v_date date;
  v_time time;
  v_existing public.schedules;
begin
  if private.current_app_role() is distinct from 'family'
     or not private.can_edit_patient(p_patient_id) then
    raise exception 'only this patient''s owner or editor can request care' using errcode = '42501';
  end if;
  if not private.owner_consent_active(p_patient_id, 'trips') then
    raise exception 'the patient''s owner must give trip consent first' using errcode = '42501';
  end if;
  if p_request_id is null or p_pickup_at is null or p_package_id is null or p_centre_id is null then
    raise exception 'request, centre, package and pickup are required' using errcode = '22023';
  end if;

  -- All submissions for one patient serialize before duplicate detection. This
  -- also catches double submissions that accidentally use different UUIDs.
  select centre_id into v_centre from public.patients where id=p_patient_id for update;
  if v_centre is distinct from p_centre_id then
    raise exception 'choose the patient''s registered centre' using errcode = '22023';
  end if;

  -- A retry after an unknown network result returns the same persisted intent,
  -- even if time has advanced since the original successful submission.
  select * into v_existing from public.schedules where id=p_request_id;
  if found then
    if v_existing.patient_id=p_patient_id and v_existing.package_id=p_package_id
       and v_existing.starts_on=v_existing.ends_on
       and ((v_existing.starts_on+v_existing.pickup_time) at time zone v_existing.timezone)=p_pickup_at then
      return v_existing.id;
    end if;
    raise exception 'request ID already belongs to another care request' using errcode = '22023';
  end if;

  if p_pickup_at<=now() or p_pickup_at<>date_trunc('minute',p_pickup_at) then
    raise exception 'choose a future pickup time in whole minutes' using errcode = '22023';
  end if;
  if not exists (select 1 from public.packages where id=p_package_id and active) then
    raise exception 'choose an existing active package' using errcode = '22023';
  end if;
  v_date := (p_pickup_at at time zone 'Asia/Kolkata')::date;
  v_time := (p_pickup_at at time zone 'Asia/Kolkata')::time;

  -- A disabled pattern does not cancel its generated trips. Standalone trips
  -- also occupy a pickup, so inspect persisted visits before active patterns.
  select s.* into v_existing from public.trips t
  left join public.schedules s on s.id=t.schedule_id
  where t.patient_id=p_patient_id and t.scheduled_pickup_at=p_pickup_at
  order by t.id limit 1;
  if found then
    if v_existing.patient_id=p_patient_id and v_existing.starts_on=v_existing.ends_on
       and v_existing.package_id=p_package_id then
      return v_existing.id;
    end if;
    raise exception 'a visit already exists at this pickup; ask ops to review it' using errcode = '22023';
  end if;

  -- Respect existing single-date and recurring plans rather than creating a
  -- second schedule/trip for the same patient and pickup instant.
  select s.* into v_existing from public.schedules s
  where s.patient_id=p_patient_id and s.active
    and (p_pickup_at at time zone s.timezone)::date>=s.starts_on
    and (s.ends_on is null or (p_pickup_at at time zone s.timezone)::date<=s.ends_on)
    and (p_pickup_at at time zone s.timezone)::time=s.pickup_time
    and extract(isodow from p_pickup_at at time zone s.timezone)::smallint=any(s.days_of_week)
  order by s.id limit 1;
  if found then
    if v_existing.starts_on=v_existing.ends_on and v_existing.package_id=p_package_id then
      return v_existing.id;
    end if;
    raise exception 'a schedule already covers this pickup; ask ops to review it' using errcode = '22023';
  end if;

  insert into public.schedules (id,patient_id,package_id,days_of_week,pickup_time,starts_on,ends_on,created_by)
  values (p_request_id,p_patient_id,p_package_id,array[extract(isodow from v_date)::smallint],v_time,v_date,v_date,auth.uid());
  -- session_minutes keeps its existing database default. No trip, companion,
  -- consent, invoice or payment is created by submitting the request.
  return p_request_id;
end;
$$;

-- New request confirmation keeps the existing ops generator and permissions,
-- but rechecks the owner's consent even if it was withdrawn after submission.
create function public.ops_confirm_care_request(p_schedule_id uuid)
returns table (pickup_date date, pickup_at timestamptz, created boolean)
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_schedule public.schedules;
begin
  perform private.assert_ops();
  select * into v_schedule from public.schedules where id=p_schedule_id for update;
  if not found or not v_schedule.active or v_schedule.starts_on is distinct from v_schedule.ends_on then
    raise exception 'an active one-date care request is required' using errcode = '22023';
  end if;
  if not private.owner_consent_active(v_schedule.patient_id, 'trips') then
    raise exception 'the patient''s owner must give trip consent before confirmation' using errcode = '42501';
  end if;
  return query select * from public.ops_create_schedule_trips(v_schedule.id,v_schedule.starts_on,1);
end;
$$;

-- Shared read projection is private; only the guarded public RPCs may call it.
create function private.care_request_rows(p_patient_id uuid default null)
returns table (
  schedule_id uuid, patient_id uuid, patient_name text, centre_id uuid, centre_name text,
  package_id uuid, package_name text, pickup_at timestamptz, trip_id uuid,
  trip_status public.trip_status, companion_name text, request_state text
)
language sql stable security definer set search_path = ''
as $$
  select s.id,p.id,p.full_name,ce.id,ce.name,pk.id,pk.name,
         (s.starts_on+s.pickup_time) at time zone s.timezone,
         t.id,t.status,cp.full_name,
         case
           when t.id is null then case when s.active then 'pending' else 'inactive' end
           when t.status<>'scheduled' then t.status::text
           when t.companion_id is null then 'confirmed'
           else 'assigned'
         end
  from public.schedules s
  join public.patients p on p.id=s.patient_id
  join public.centres ce on ce.id=p.centre_id
  join public.packages pk on pk.id=s.package_id
  left join public.trips t on t.schedule_id=s.id and t.patient_id=s.patient_id
    and t.scheduled_pickup_at=(s.starts_on+s.pickup_time) at time zone s.timezone
  left join public.profiles cp on cp.id=t.companion_id
  where s.starts_on=s.ends_on and (p_patient_id is null or s.patient_id=p_patient_id)
  order by s.starts_on desc,s.pickup_time desc,s.id;
$$;

create function public.family_care_requests(p_patient_id uuid)
returns table (
  schedule_id uuid, patient_id uuid, patient_name text, centre_id uuid, centre_name text,
  package_id uuid, package_name text, pickup_at timestamptz, trip_id uuid,
  trip_status public.trip_status, companion_name text, request_state text
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if private.current_app_role() is distinct from 'family'
     or not private.can_view_patient(p_patient_id) then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  return query select * from private.care_request_rows(p_patient_id);
end;
$$;

create function public.ops_care_requests()
returns table (
  schedule_id uuid, patient_id uuid, patient_name text, centre_id uuid, centre_name text,
  package_id uuid, package_name text, pickup_at timestamptz, trip_id uuid,
  trip_status public.trip_status, companion_name text, request_state text
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform private.assert_ops();
  return query select * from private.care_request_rows();
end;
$$;

revoke execute on function private.care_request_rows(uuid) from public,anon,authenticated;
revoke execute on function public.family_care_options(uuid),
  public.family_request_care(uuid,uuid,uuid,uuid,timestamptz),public.family_care_requests(uuid),public.ops_care_requests(),
  public.ops_confirm_care_request(uuid)
  from public,anon;
grant execute on function public.family_care_options(uuid),
  public.family_request_care(uuid,uuid,uuid,uuid,timestamptz),public.family_care_requests(uuid),public.ops_care_requests(),
  public.ops_confirm_care_request(uuid)
  to authenticated;
