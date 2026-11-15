-- Opt-in service-aware reservations. Existing visits keep their original rules.
begin;

create table public.visit_plans (
  trip_id uuid primary key references public.trips(id) on delete cascade,
  stays_through_session boolean not null,
  outbound_companion_id uuid not null references public.companions(id),
  return_companion_id uuid not null references public.companions(id),
  outbound_start_at timestamptz not null,
  outbound_end_at timestamptz not null,
  return_prepare_at timestamptz not null,
  return_arrive_by timestamptz not null,
  expected_ready_at timestamptz not null,
  return_end_at timestamptz not null,
  handed_over_at timestamptz,
  centre_ready_at timestamptz,
  return_departed_at timestamptz,
  return_arrived_at timestamptz,
  return_verified_at timestamptz,
  version uuid not null default gen_random_uuid(),
  created_at timestamptz not null default now(),
  check(outbound_start_at < outbound_end_at and (handed_over_at is not null or outbound_end_at < return_prepare_at)
    and return_prepare_at < return_arrive_by and return_arrive_by < expected_ready_at
    and expected_ready_at < return_end_at),
  check(not stays_through_session or outbound_companion_id=return_companion_id)
);
alter table public.visit_plans enable row level security;
revoke all on public.visit_plans from public,anon,authenticated,service_role;

create table private.return_pickup_otps (
  trip_id uuid primary key references public.trips(id) on delete cascade,
  assignee_id uuid not null references public.companions(id),
  salt bytea not null, otp_hash bytea not null,
  expires_at timestamptz not null, attempts integer not null default 0,
  consumed_at timestamptz
);
alter table private.return_pickup_otps enable row level security;
revoke all on private.return_pickup_otps from public,anon,authenticated,service_role;

-- Every reservation includes the travel allowance entered by Ops. An overrun
-- stays occupied until a real handover/completion; clocks never finish work.
create function private.companion_reservations(p_companion uuid,p_except uuid default null)
returns table(trip_id uuid,starts_at timestamptz,ends_at timestamptz,working boolean)
language sql stable security definer set search_path='' as $$
  select t.id,t.scheduled_pickup_at,
    case when t.status='completed' then greatest(t.scheduled_return_at,t.completed_at)
         when t.status<>'scheduled' and t.scheduled_return_at<now() then 'infinity'::timestamptz
         else t.scheduled_return_at end,
    t.status not in ('scheduled','completed') and
      (t.status<>'issue_reported' or t.status_before_issue<>'scheduled')
  from public.trips t where t.companion_id=p_companion and t.id is distinct from p_except
    and t.status not in ('cancelled','no_show') and not exists(select 1 from public.visit_plans p where p.trip_id=t.id)
  union all
  select t.id,p.outbound_start_at,
    case when t.status='completed' then case when p.stays_through_session then greatest(p.return_end_at,t.completed_at)
                                           else coalesce(p.handed_over_at,p.outbound_end_at) end
         when p.stays_through_session then case when t.status<>'scheduled' and p.return_end_at<now() then 'infinity'::timestamptz else p.return_end_at end
         when p.handed_over_at is not null then p.handed_over_at
         when t.status<>'scheduled' and p.outbound_end_at<now() then 'infinity'::timestamptz else p.outbound_end_at end,
    t.status not in ('scheduled','completed') and (p.stays_through_session or p.handed_over_at is null)
  from public.visit_plans p join public.trips t on t.id=p.trip_id
  where p.outbound_companion_id=p_companion and t.id is distinct from p_except
    and t.status not in ('cancelled','no_show')
  union all
  select t.id,p.return_prepare_at,
    case when t.status='completed' then greatest(p.return_end_at,t.completed_at)
         when p.handed_over_at is not null and p.return_end_at<now() then 'infinity'::timestamptz else p.return_end_at end,
    p.return_departed_at is not null and t.status<>'completed'
  from public.visit_plans p join public.trips t on t.id=p.trip_id
  where not p.stays_through_session and p.return_companion_id=p_companion
    and t.id is distinct from p_except and t.status not in ('cancelled','no_show')
$$;

create function private.assert_reservation(p_companion uuid,p_trip uuid,p_from timestamptz,p_to timestamptz,p_start boolean default false)
returns void language plpgsql volatile security definer set search_path='' as $$
begin
  perform 1 from public.companions where id=p_companion for update;
  if exists(select 1 from private.companion_reservations(p_companion,p_trip) r
    where ((not p_start or exists(select 1 from public.visit_plans p where p.trip_id=r.trip_id or p.trip_id=p_trip))
           and p_from<r.ends_at and p_to>r.starts_at) or (p_start and r.working)) then
    raise exception 'companion has a conflicting reserved assignment' using errcode='22023';
  end if;
end;$$;

-- Match the original trigger's service-role boundary, now accounting for plans.
create or replace function private.enforce_companion_occupancy()
returns trigger language plpgsql volatile security definer set search_path='' as $$
declare p public.visit_plans; changed boolean; starting boolean;
begin
  if coalesce(current_setting('role',true),'none') not in ('authenticated','service_role') then return new;end if;
  select * into p from public.visit_plans where trip_id=new.id;
  if found then
    if current_setting('role',true)='service_role' and tg_op='UPDATE' and new.status is distinct from old.status then
      raise exception 'planned visits require actor-authorized actions' using errcode='42501';end if;
    if new.companion_id is distinct from p.outbound_companion_id
       or new.scheduled_pickup_at<>old.scheduled_pickup_at or new.scheduled_return_at<>old.scheduled_return_at then
      raise exception 'use the visit plan controls' using errcode='22023';
    end if;
    -- Planned starts are guarded by advance_trip / companion_return_action.
    return new;
  end if;
  if tg_op='INSERT' then changed:=true;starting:=false;
  else
    changed:=new.companion_id is distinct from old.companion_id
      or new.scheduled_pickup_at is distinct from old.scheduled_pickup_at
      or new.scheduled_return_at is distinct from old.scheduled_return_at;
    starting:=new.status not in ('scheduled','issue_reported','completed','cancelled','no_show')
      and old.status in ('scheduled','issue_reported');
    if new.companion_id is distinct from old.companion_id and old.status<>'scheduled' then
      raise exception 'only scheduled trips can be reassigned' using errcode='22023';end if;
  end if;
  if new.companion_id is null or new.status in ('cancelled','no_show') or not(changed or starting) then return new;end if;
  -- Idempotent recurring generation skips an already existing schedule/slot.
  if tg_op='INSERT' and new.schedule_id is not null and exists(select 1 from public.trips t
    where t.schedule_id=new.schedule_id and t.scheduled_pickup_at=new.scheduled_pickup_at) then return new;end if;
  perform private.assert_reservation(new.companion_id,new.id,new.scheduled_pickup_at,new.scheduled_return_at,starting);
  return new;
end;$$;

create function private.visit_plan_json(p public.visit_plans)
returns jsonb language sql stable security definer set search_path='' as $$
  select to_jsonb(p) || jsonb_build_object(
    'outbound_companion_name',(select pr.full_name from public.profiles pr where pr.id=p.outbound_companion_id),
    'return_companion_name',(select pr.full_name from public.profiles pr where pr.id=p.return_companion_id))
$$;

create function private.queue_visit_return_reminders(p_trip uuid)
returns void language plpgsql volatile security definer set search_path='' as $$
declare p public.visit_plans;t public.trips;
begin
  select * into p from public.visit_plans where trip_id=p_trip;
  if not found then return;end if;
  select * into t from public.trips where id=p_trip;
  delete from public.notifications where trip_id=p_trip and status='pending'
    and template in('visit_return_reminder','visit_return_late');
  if t.status in('completed','cancelled','no_show') then return;end if;
  if p.return_departed_at is null then
    insert into public.notifications(trip_id,recipient_id,channel,template,payload,next_attempt_at)
    values(p_trip,p.return_companion_id,'push','visit_return_reminder',
      jsonb_build_object('trip_id',p_trip,'ready_at',p.expected_ready_at,'arrive_by',p.return_arrive_by),p.return_prepare_at);
  end if;
  if not p.stays_through_session and p.return_arrived_at is null then
    insert into public.notifications(trip_id,recipient_id,channel,template,payload,next_attempt_at)
    select p_trip,pr.id,'push','visit_return_late',jsonb_build_object('trip_id',p_trip),p.return_arrive_by
    from public.profiles pr where pr.role='ops_admin';
  end if;
end;$$;

create function private.refresh_return_reminders()
returns trigger language plpgsql volatile security definer set search_path='' as $$
begin
  if tg_table_name='trips' then
    perform private.queue_visit_return_reminders(new.id);
  else
    perform private.queue_visit_return_reminders(new.trip_id);
  end if;
  return new;
end;$$;
create trigger plan_return_reminders after insert or update on public.visit_plans
for each row execute function private.refresh_return_reminders();
create trigger trip_return_reminders after update of status on public.trips
for each row execute function private.refresh_return_reminders();

create function public.ops_plan_visit(p_trip_id uuid,p_outbound_start timestamptz,p_outbound_end timestamptz,
  p_return_start timestamptz,p_return_end timestamptz,p_outbound_companion uuid,p_return_companion uuid)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare t public.trips;p public.visit_plans;stays boolean;
begin
  perform private.assert_ops();
  select * into t from public.trips where id=p_trip_id for update;
  if not found then raise exception 'trip not found' using errcode='P0002';end if;
  if t.status<>'scheduled' or exists(select 1 from public.visit_plans where trip_id=t.id) then
    raise exception 'an unplanned scheduled visit is required' using errcode='22023';end if;
  perform private.assert_trip_consent(t.patient_id);
  select pk.companion_stays_through_session into stays from public.schedules s join public.packages pk on pk.id=s.package_id where s.id=t.schedule_id;
  if stays is null then raise exception 'a booked package is required' using errcode='22023';end if;
  if p_outbound_start is null or p_outbound_end is null or p_return_start is null or p_return_end is null
    or p_outbound_start>t.scheduled_pickup_at or p_outbound_end<=t.scheduled_pickup_at
    or p_outbound_end>=p_return_start or p_return_start>t.scheduled_return_at-interval '30 minutes'
    or p_return_end<=t.scheduled_return_at then raise exception 'valid travel-inclusive time blocks required' using errcode='22023';end if;
  if stays and p_outbound_companion is distinct from p_return_companion then
    raise exception 'stay-assist requires one companion' using errcode='22023';end if;
  perform private.assert_companion_eligible(p_outbound_companion,t.patient_id);
  perform private.assert_companion_eligible(p_return_companion,t.patient_id);
  perform 1 from public.companions where id in (p_outbound_companion,p_return_companion) order by id for update;
  perform private.assert_reservation(p_outbound_companion,t.id,p_outbound_start,case when stays then p_return_end else p_outbound_end end);
  if not stays then perform private.assert_reservation(p_return_companion,t.id,p_return_start,p_return_end);end if;
  insert into public.visit_plans(trip_id,stays_through_session,outbound_companion_id,return_companion_id,
    outbound_start_at,outbound_end_at,return_prepare_at,return_arrive_by,expected_ready_at,return_end_at)
  values(t.id,stays,p_outbound_companion,p_return_companion,p_outbound_start,p_outbound_end,
    p_return_start,t.scheduled_return_at-interval '15 minutes',t.scheduled_return_at,p_return_end) returning * into p;
  update public.trips set companion_id=p_outbound_companion,updated_at=now() where id=t.id;
  perform private.write_audit('plan_visit_legs','trips',t.id::text,t.patient_id);
  return private.visit_plan_json(p);
end;$$;

create function public.ops_visit_plans()
returns jsonb language plpgsql stable security definer set search_path='' as $$
begin
  perform private.assert_ops();
  return coalesce((select jsonb_agg(private.visit_plan_json(p)||jsonb_build_object('status',t.status,
    'patient_id',t.patient_id,'patient_name',pa.full_name,'centre_name',ce.name,
    'return_due',not p.stays_through_session and now()>=p.return_prepare_at and p.return_departed_at is null,
    'return_late',not p.stays_through_session and now()>p.return_arrive_by and p.return_arrived_at is null) order by p.expected_ready_at)
    from public.visit_plans p join public.trips t on t.id=p.trip_id join public.patients pa on pa.id=t.patient_id
    join public.centres ce on ce.id=t.centre_id where t.status not in ('completed','cancelled','no_show')),'[]'::jsonb);
end;$$;

create function public.ops_reassign_visit_return(p_trip_id uuid,p_expected_version uuid,p_companion_id uuid)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare t public.trips;p public.visit_plans;
begin
  perform private.assert_ops();select * into t from public.trips where id=p_trip_id for update;
  select * into p from public.visit_plans where trip_id=p_trip_id for update;
  if not found or p.version is distinct from p_expected_version or p.stays_through_session
     or t.status not in ('handed_over','session_done') or p.return_departed_at is not null then
    raise exception 'return plan changed or already started' using errcode='22023';end if;
  if now()>=p.return_end_at then raise exception 'return block expired; replan before replacement' using errcode='22023';end if;
  perform private.assert_trip_consent(t.patient_id);
  perform private.assert_companion_eligible(p_companion_id,t.patient_id);
  perform 1 from public.companions where id in(p.return_companion_id,p_companion_id) order by id for update;
  perform private.assert_reservation(p_companion_id,t.id,p.return_prepare_at,p.return_end_at);
  update public.visit_plans set return_companion_id=p_companion_id,version=gen_random_uuid() where trip_id=t.id returning * into p;
  delete from private.return_pickup_otps where trip_id=t.id;
  perform private.write_audit('reassign_return_leg','trips',t.id::text,t.patient_id);
  perform private.notify_patient_family(t.id,t.patient_id,'trip_status_changed',jsonb_build_object('trip_id',t.id,'to_status',t.status));
  return private.visit_plan_json(p);
end;$$;

-- Move old entry points behind wrappers so old clients cannot bypass leg rules.
alter function public.advance_trip(uuid,public.trip_status,text,double precision,double precision) set schema private;
alter function private.advance_trip(uuid,public.trip_status,text,double precision,double precision) rename to advance_trip_legacy;
revoke all on function private.advance_trip_legacy(uuid,public.trip_status,text,double precision,double precision) from public,anon,authenticated,service_role;

create function public.advance_trip(p_trip_id uuid,p_to_status public.trip_status,p_note text default null,
  p_lat double precision default null,p_lng double precision default null)
returns public.trips language plpgsql volatile security definer set search_path='' as $$
declare t public.trips;p public.visit_plans;a public.transition_actor;
begin
  select * into t from public.trips where id=p_trip_id for update;
  select * into p from public.visit_plans where trip_id=p_trip_id for update;
  if not found then return private.advance_trip_legacy(p_trip_id,p_to_status,p_note,p_lat,p_lng);end if;
  a:=case when private.is_ops() then 'ops' when private.can_edit_patient(t.patient_id) then 'family'
    when auth.uid()=case when p.handed_over_at is null then p.outbound_companion_id else p.return_companion_id end then 'companion' end;
  if a is null then raise exception 'not allowed' using errcode='42501';end if;
  if not exists(select 1 from public.trip_transitions where from_status=t.status and to_status=p_to_status and actor=a and not requires_otp) then
    raise exception 'transition not available' using errcode='22023';end if;
  if a='companion' then
    perform private.assert_companion_can_act();perform private.assert_trip_consent(t.patient_id);
    if p_to_status in('handed_over','session_done','returning') then raise exception 'use confirmed handover/return controls' using errcode='22023';end if;
    if p_to_status='companion_en_route' then
      if now()<p.outbound_start_at or now()>=p.outbound_end_at then raise exception 'outbound block not open' using errcode='22023';end if;
      perform private.assert_reservation(p.outbound_companion_id,t.id,now(),case when p.stays_through_session then p.return_end_at else p.outbound_end_at end,true);
    end if;
    if p_to_status in('completed','issue_reported') and nullif(btrim(p_note),'') is null then raise exception 'note required' using errcode='22023';end if;
  end if;
  if p_to_status in('session_done','returning') then raise exception 'use centre-ready and return verification controls' using errcode='22023';end if;
  t:=private.apply_transition(t,p_to_status,a,p_note,private.make_point(p_lat,p_lng));
  if p_to_status='handed_over' then update public.visit_plans set handed_over_at=now(),version=gen_random_uuid() where trip_id=t.id;end if;
  return t;
end;$$;

create function public.companion_confirm_centre_handover(p_trip_id uuid,p_staff_received boolean,p_note text default null)
returns public.trips language plpgsql volatile security definer set search_path='' as $$
declare t public.trips;p public.visit_plans;
begin
  select * into t from public.trips where id=p_trip_id for update;
  select * into p from public.visit_plans where trip_id=p_trip_id for update;
  if not found or auth.uid() is distinct from p.outbound_companion_id then raise exception 'not allowed' using errcode='42501';end if;
  perform private.assert_companion_can_act();perform private.assert_trip_consent(t.patient_id);
  if t.status<>'at_centre' or p_staff_received is not true then raise exception 'staff receipt confirmation required' using errcode='22023';end if;
  t:=private.apply_transition(t,'handed_over','companion',p_note,null);
  update public.visit_plans set handed_over_at=now(),version=gen_random_uuid() where trip_id=t.id;
  return t;
end;$$;

create function public.ops_confirm_centre_ready(p_trip_id uuid,p_expected_version uuid,p_confirmation text)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare t public.trips;p public.visit_plans;
begin
  perform private.assert_ops();select * into t from public.trips where id=p_trip_id for update;
  select * into p from public.visit_plans where trip_id=p_trip_id for update;
  if not found or p.version is distinct from p_expected_version or t.status<>'handed_over'
    or nullif(btrim(p_confirmation),'') is null then raise exception 'current handover and centre confirmation required' using errcode='22023';end if;
  perform private.assert_trip_consent(t.patient_id);
  perform private.apply_transition(t,'session_done','ops',p_confirmation,null);
  update public.visit_plans set centre_ready_at=now(),version=gen_random_uuid() where trip_id=t.id returning * into p;
  return private.visit_plan_json(p);
end;$$;

create function public.ops_reschedule_visit_return(p_trip_id uuid,p_expected_version uuid,p_ready_at timestamptz,
  p_return_start timestamptz,p_return_end timestamptz)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare t public.trips;p public.visit_plans;
begin
  perform private.assert_ops();select * into t from public.trips where id=p_trip_id for update;
  select * into p from public.visit_plans where trip_id=p_trip_id for update;
  if not found or p.version is distinct from p_expected_version or t.status not in('scheduled','handed_over','session_done')
    or p.return_departed_at is not null or p_ready_at is null or p_return_start is null or p_return_end is null
    or (p_ready_at<=now() and p.centre_ready_at is null) or p_return_end<=now() or p_return_start>p_ready_at-interval '30 minutes'
    or (p.handed_over_at is null and p_return_start<=p.outbound_end_at) or p_return_end<=p_ready_at then
    raise exception 'valid current unstarted return plan required' using errcode='22023';end if;
  perform private.assert_trip_consent(t.patient_id);
  perform 1 from public.companions where id in(p.outbound_companion_id,p.return_companion_id) order by id for update;
  perform private.assert_reservation(p.return_companion_id,t.id,
    case when p.stays_through_session then p.outbound_start_at else p_return_start end,p_return_end);
  update public.visit_plans set expected_ready_at=p_ready_at,return_prepare_at=p_return_start,
    return_arrive_by=p_ready_at-interval '15 minutes',return_end_at=p_return_end,version=gen_random_uuid()
    where trip_id=t.id returning * into p;
  delete from private.return_pickup_otps where trip_id=t.id;
  perform private.write_audit('reschedule_return','trips',t.id::text,t.patient_id);
  return private.visit_plan_json(p);
end;$$;

create function public.companion_return_action(p_trip_id uuid,p_action text)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare t public.trips;p public.visit_plans;
begin
  select * into t from public.trips where id=p_trip_id for update;
  select * into p from public.visit_plans where trip_id=p_trip_id for update;
  if not found or auth.uid() is distinct from p.return_companion_id then raise exception 'not allowed' using errcode='42501';end if;
  perform private.assert_companion_can_act();perform private.assert_trip_consent(t.patient_id);
  if t.status not in ('handed_over','session_done') then raise exception 'return not available' using errcode='22023';end if;
  if p_action='depart' and p.return_departed_at is null then
    if now()<p.return_prepare_at or now()>=p.return_end_at then raise exception 'return block not open; contact Ops to replan' using errcode='22023';end if;
    perform private.assert_reservation(auth.uid(),t.id,now(),p.return_end_at,true);
    update public.visit_plans set return_departed_at=now(),version=gen_random_uuid() where trip_id=t.id returning * into p;
  elsif p_action='arrive' and (p.return_departed_at is not null or p.stays_through_session) and p.return_arrived_at is null then
    if p.stays_through_session and p.centre_ready_at is null then raise exception 'centre confirmation required' using errcode='22023';end if;
    update public.visit_plans set return_departed_at=coalesce(return_departed_at,now()),return_arrived_at=now(),version=gen_random_uuid() where trip_id=t.id returning * into p;
  else raise exception 'return action changed' using errcode='22023';end if;
  perform private.write_audit('return_'||p_action,'trips',t.id::text,t.patient_id);
  return private.visit_plan_json(p);
end;$$;

create function public.ops_issue_return_code(p_trip_id uuid)
returns text language plpgsql volatile security definer set search_path='' as $$
declare t public.trips;p public.visit_plans;code text;salt bytea;
begin
  perform private.assert_ops();select * into t from public.trips where id=p_trip_id for update;
  select * into p from public.visit_plans where trip_id=p_trip_id for update;
  if not found or t.status<>'session_done' or p.centre_ready_at is null or p.return_arrived_at is null then
    raise exception 'centre ready confirmation and companion arrival required' using errcode='22023';end if;
  perform private.assert_trip_consent(t.patient_id);
  code:=lpad(((('x'||substr(replace(gen_random_uuid()::text,'-',''),1,8))::bit(32)::bigint)%1000000)::text,6,'0');
  salt:=uuid_send(gen_random_uuid());
  insert into private.return_pickup_otps(trip_id,assignee_id,salt,otp_hash,expires_at)
    values(t.id,p.return_companion_id,salt,sha256(salt||convert_to(code,'UTF8')),now()+interval '15 minutes')
    on conflict(trip_id) do update set assignee_id=excluded.assignee_id,salt=excluded.salt,otp_hash=excluded.otp_hash,
      expires_at=excluded.expires_at,attempts=0,consumed_at=null;
  perform private.write_audit('issue_return_code','trips',t.id::text,t.patient_id);return code;
end;$$;

create function public.verify_return_pickup(p_trip_id uuid,p_code text)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare t public.trips;p public.visit_plans;o private.return_pickup_otps;maximum integer:=private.setting_int('pickup_otp_max_attempts');
begin
  select * into t from public.trips where id=p_trip_id for update;
  select * into p from public.visit_plans where trip_id=p_trip_id for update;
  if not found or auth.uid() is distinct from p.return_companion_id then raise exception 'not allowed' using errcode='42501';end if;
  perform private.assert_companion_can_act();perform private.assert_trip_consent(t.patient_id);
  if t.status<>'session_done' or p.return_arrived_at is null or p.centre_ready_at is null then raise exception 'return not ready' using errcode='22023';end if;
  select * into o from private.return_pickup_otps where trip_id=t.id for update;
  if not found or o.assignee_id<>auth.uid() or o.consumed_at is not null or o.expires_at<now() or o.attempts>=maximum then
    return jsonb_build_object('ok',false,'reason','no_valid_code','attempts_left',0);end if;
  if sha256(o.salt||convert_to(coalesce(p_code,''),'UTF8'))<>o.otp_hash then
    update private.return_pickup_otps set attempts=attempts+1 where trip_id=t.id;
    return jsonb_build_object('ok',false,'reason','wrong_code','attempts_left',maximum-o.attempts-1);end if;
  update private.return_pickup_otps set consumed_at=now() where trip_id=t.id;
  perform private.apply_transition(t,'returning','companion','Return pickup verified',null);
  update public.visit_plans set return_verified_at=now(),version=gen_random_uuid() where trip_id=t.id;
  return jsonb_build_object('ok',true,'status','returning');
end;$$;

-- Private data for planned visits is available only through the leg projection.
create or replace function private.can_view_trip(p_trip_id uuid)
returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.trips t where t.id=p_trip_id and (private.can_view_patient(t.patient_id) or private.is_ops()
   or (not exists(select 1 from public.visit_plans p where p.trip_id=t.id) and t.companion_id=auth.uid()
     and private.owner_consent_active(t.patient_id,'trips') and private.companion_window_open(t.scheduled_pickup_at,t.scheduled_return_at,t.status))))
$$;
drop policy participants on public.trips;
create policy participants on public.trips for select to authenticated using(private.can_view_trip(id));

alter function public.companion_my_trips(timestamptz,timestamptz) set schema private;
alter function private.companion_my_trips(timestamptz,timestamptz) rename to companion_my_trips_legacy;
revoke all on function private.companion_my_trips_legacy(timestamptz,timestamptz) from public,anon,authenticated,service_role;
create function public.companion_my_trips(p_from timestamptz default now()-interval '1 day',p_to timestamptz default now()+interval '14 days')
returns table(trip_id uuid,scheduled_pickup_at timestamptz,scheduled_return_at timestamptz,status public.trip_status,
  centre_name text,centre_address text,details_visible boolean,patient_name text,home_address text,home_lat double precision,
  home_lng double precision,mobility_notes text,emergency_contacts jsonb,start_allowed_at timestamptz)
language sql stable security definer set search_path='' as $$
  select l.* from private.companion_my_trips_legacy(p_from,p_to) l
  where not exists(select 1 from public.visit_plans p where p.trip_id=l.trip_id)
$$;

create function public.companion_visit_board(p_from timestamptz default now()-interval '1 day',p_to timestamptz default now()+interval '14 days')
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare result jsonb;
begin
  if private.current_app_role()<>'companion' or auth.uid() is null then raise exception 'companions only' using errcode='42501';end if;
  select coalesce(jsonb_agg(to_jsonb(l)),'[]'::jsonb) into result from public.companion_my_trips(p_from,p_to) l;
  return result || coalesce((select jsonb_agg(jsonb_build_object(
    'trip_id',t.id,'scheduled_pickup_at',t.scheduled_pickup_at,'scheduled_return_at',p.expected_ready_at,'status',t.status,
    'centre_name',ce.name,'centre_address',ce.address,'details_visible',access.visible,
    'patient_name',case when access.visible then pa.full_name end,
    'home_address',case when access.visible then pa.home_address end,
    'home_lat',case when access.visible then extensions.st_y(pa.home_location::extensions.geometry) end,
    'home_lng',case when access.visible then extensions.st_x(pa.home_location::extensions.geometry) end,
    'mobility_notes',case when access.visible then pa.mobility_notes end,
    'emergency_contacts',case when access.visible then pa.emergency_contacts else '[]'::jsonb end,
    'start_allowed_at',p.outbound_start_at,'visit_plan',private.visit_plan_json(p),
    'can_outbound',auth.uid()=p.outbound_companion_id and p.handed_over_at is null,
    'can_return',auth.uid()=p.return_companion_id))
    from public.visit_plans p join public.trips t on t.id=p.trip_id join public.patients pa on pa.id=t.patient_id join public.centres ce on ce.id=t.centre_id
    cross join lateral(select private.owner_consent_active(t.patient_id,'trips')
      and t.status not in('cancelled','no_show') and
      ((auth.uid()=p.outbound_companion_id and (p.handed_over_at is null or p.stays_through_session) and now() between p.outbound_start_at-interval '1 hour' and p.return_end_at)
       or(auth.uid()=p.return_companion_id and now() between p.return_prepare_at-interval '1 hour' and p.return_end_at+interval '2 hours')) as visible) access
    where (auth.uid()=p.return_companion_id or auth.uid()=p.outbound_companion_id)
      and t.scheduled_pickup_at between p_from and p_to),'[]'::jsonb);
end;$$;

create function public.family_visit_plan(p_trip_id uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $$
declare t public.trips;p public.visit_plans;
begin
  select * into t from public.trips where id=p_trip_id;
  if not found or not private.can_view_patient(t.patient_id) then raise exception 'not allowed' using errcode='42501';end if;
  select * into p from public.visit_plans where trip_id=t.id;
  if not found then return null;end if;
  return jsonb_build_object('stays_through_session',p.stays_through_session,'expected_ready_at',p.expected_ready_at,
    'return_companion_name',(select full_name from public.profiles where id=p.return_companion_id),
    'centre_ready_at',p.centre_ready_at,'return_departed_at',p.return_departed_at,'return_arrived_at',p.return_arrived_at);
end;$$;

create or replace function public.family_trip_board(p_patient_id uuid,
  p_from timestamptz default now()-interval '1 day',p_to timestamptz default now()+interval '14 days')
returns table(trip_id uuid,scheduled_pickup_at timestamptz,scheduled_return_at timestamptz,
  status public.trip_status,centre_name text,companion_name text,primary_companion_name text,backup_companion_name text)
language plpgsql stable security definer set search_path='' as $$
begin
  if not(private.can_view_patient(p_patient_id) or private.is_ops()) then raise exception 'not allowed' using errcode='42501';end if;
  return query select t.id,t.scheduled_pickup_at,coalesce(p.expected_ready_at,t.scheduled_return_at),t.status,ce.name,
    cp.full_name,pp.full_name,bp.full_name
  from public.trips t join public.centres ce on ce.id=t.centre_id
  left join public.visit_plans p on p.trip_id=t.id
  left join public.profiles cp on cp.id=case when p.handed_over_at is not null then p.return_companion_id else t.companion_id end
  left join public.schedules s on s.id=t.schedule_id
  left join public.profiles pp on pp.id=s.primary_companion_id left join public.profiles bp on bp.id=s.backup_companion_id
  where t.patient_id=p_patient_id and t.scheduled_pickup_at between p_from and p_to order by t.scheduled_pickup_at;
end;$$;

create or replace function public.my_notifications(p_limit integer default 50)
returns table(notification_id bigint,trip_id uuid,template text,payload jsonb,created_at timestamptz)
language plpgsql stable security definer set search_path='' as $$
begin
  if auth.uid() is null then raise exception 'not allowed' using errcode='42501';end if;
  return query select n.id,n.trip_id,n.template,n.payload,n.created_at from public.notifications n
  where n.recipient_id=auth.uid() and n.channel='push'
    and (n.template not in('visit_return_reminder','visit_return_late') or n.next_attempt_at<=now())
  order by n.id desc limit least(greatest(coalesce(p_limit,50),1),200);
end;$$;

revoke all on function private.companion_reservations(uuid,uuid),private.assert_reservation(uuid,uuid,timestamptz,timestamptz,boolean),
  private.visit_plan_json(public.visit_plans) from public,anon,authenticated,service_role;
revoke all on function private.queue_visit_return_reminders(uuid),private.refresh_return_reminders()
from public,anon,authenticated,service_role;
revoke all on function public.ops_plan_visit(uuid,timestamptz,timestamptz,timestamptz,timestamptz,uuid,uuid),
  public.ops_visit_plans(),public.ops_reassign_visit_return(uuid,uuid,uuid),public.ops_confirm_centre_ready(uuid,uuid,text),
  public.ops_reschedule_visit_return(uuid,uuid,timestamptz,timestamptz,timestamptz),
  public.companion_confirm_centre_handover(uuid,boolean,text),
  public.companion_return_action(uuid,text),public.ops_issue_return_code(uuid),public.verify_return_pickup(uuid,text),
  public.companion_visit_board(timestamptz,timestamptz),public.family_visit_plan(uuid),
  public.companion_my_trips(timestamptz,timestamptz),public.advance_trip(uuid,public.trip_status,text,double precision,double precision)
from public,anon;
grant execute on function public.ops_plan_visit(uuid,timestamptz,timestamptz,timestamptz,timestamptz,uuid,uuid),
  public.ops_visit_plans(),public.ops_reassign_visit_return(uuid,uuid,uuid),public.ops_confirm_centre_ready(uuid,uuid,text),
  public.ops_reschedule_visit_return(uuid,uuid,timestamptz,timestamptz,timestamptz),
  public.companion_confirm_centre_handover(uuid,boolean,text),
  public.companion_return_action(uuid,text),public.ops_issue_return_code(uuid),public.verify_return_pickup(uuid,text),
  public.companion_visit_board(timestamptz,timestamptz),public.family_visit_plan(uuid),
  public.companion_my_trips(timestamptz,timestamptz),public.advance_trip(uuid,public.trip_status,text,double precision,double precision)
to authenticated;
commit;
