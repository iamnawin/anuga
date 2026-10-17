-- ANU-002. Local-development assumptions only; F1-F4 are NOT rollout approval.
-- Nonempty databases require a complete reviewed manifest on this owner connection:
-- anuga.pilot_backfill_manifest = [{id, role, state, authority_ref}, ...].
-- No inference from a default Family role, patient grants, phone or client metadata.
begin;
set local lock_timeout = '5s';
lock table auth.users, public.profiles in share row exclusive mode;

do $migration$
declare
  manifest jsonb := coalesce(nullif(current_setting('anuga.pilot_backfill_manifest', true), '')::jsonb, '[]');
  row_count integer;
begin
  if jsonb_typeof(manifest) <> 'array' then raise exception 'backfill manifest must be an array'; end if;
  select count(*) into row_count from public.profiles;
  if exists (select 1 from auth.users u left join public.profiles p on p.id=u.id where p.id is null)
    or row_count <> jsonb_array_length(manifest)
    or exists (select 1 from jsonb_array_elements(manifest) m group by m->>'id' having count(*)<>1)
    or exists (
      select 1 from public.profiles p full join jsonb_array_elements(manifest) m on (m->>'id')::uuid=p.id
      where p.id is null or m is null or p.role::text is distinct from m->>'role'
        or coalesce(m->>'state','') not in ('pending','active','disabled')
        or coalesce(trim(m->>'authority_ref'),'')=''
    ) then raise exception 'backfill aborted: unknown, missing, duplicate or mismatched profile/manifest'; end if;
end;
$migration$;

alter table public.profiles
  add column account_state text not null default 'pending' check(account_state in ('pending','active','disabled')),
  add column account_state_version bigint not null default 1 check(account_state_version > 0);

do $backfill$
declare m jsonb;
begin
  for m in select value from jsonb_array_elements(coalesce(nullif(current_setting('anuga.pilot_backfill_manifest',true),'')::jsonb,'[]')) loop
    update public.profiles set account_state=m->>'state' where id=(m->>'id')::uuid;
    perform private.write_audit('account_backfilled','profiles',m->>'id',null,
      jsonb_build_object('old_state',null,'new_state',m->>'state','old_role',m->>'role','new_role',m->>'role',
      'version',1,'source','migration','authority_ref',m->>'authority_ref','database_actor',session_user));
  end loop;
end;
$backfill$;

create function private.account_is_active() returns boolean
language sql stable security definer set search_path=''
as $$ select exists(select 1 from public.profiles where id=auth.uid() and account_state='active') $$;

create function private.assert_active_account() returns void
language plpgsql stable security definer set search_path=''
as $$ begin
  -- Additional guard only: the original function's backend/role permissions still apply.
  if not private.account_is_active() and not private.is_trusted_backend() then
    raise exception 'account access required' using errcode='42501', hint='account_access_required';
  end if;
end $$;

create or replace function private.current_app_role() returns public.user_role
language sql stable security definer set search_path=''
as $$ select role from public.profiles where id=auth.uid() and account_state='active' $$;
create or replace function private.access_level_for(p_patient_id uuid) returns public.access_level
language sql stable security definer set search_path=''
as $$ select access_level from public.patient_access where patient_id=p_patient_id and user_id=auth.uid() and private.current_app_role()='family' $$;
create or replace function private.can_view_trip(p_trip_id uuid) returns boolean
language sql stable security definer set search_path=''
as $$ select private.account_is_active() and exists(select 1 from public.trips t where t.id=p_trip_id
  and (t.companion_id=auth.uid() or private.can_view_patient(t.patient_id) or private.is_ops())) $$;

-- AND with every existing row policy; definer functions require their own guards below.
do $policies$
declare t record;
begin
  for t in select c.relname from pg_class c join pg_namespace n on n.oid=c.relnamespace
    where n.nspname='public' and c.relkind='r' and c.relrowsecurity loop
    execute format('create policy account_active on public.%I as restrictive for all to authenticated using (private.account_is_active()) with check (private.account_is_active())',t.relname);
  end loop;
end;
$policies$;

-- Preserve each existing RPC body, signature and ACL; add the guard before its work.
-- Fail migration if a new user RPC has an unsupported language/body: no silent bypass.
do $rpc_guards$
declare f record; definition text;
begin
  for f in select p.oid,p.proname,l.lanname from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    join pg_language l on l.oid=p.prolang where n.nspname='public' and p.prosecdef
    and has_function_privilege('authenticated',p.oid,'EXECUTE') loop
    definition := pg_get_functiondef(f.oid);
    if f.lanname<>'plpgsql' or definition !~* '\mbegin\M' then
      raise exception 'unsupported authenticated RPC: %',f.proname;
    end if;
    execute regexp_replace(definition,'\mbegin\M',E'begin\n  perform private.assert_active_account();','i');
  end loop;
end;
$rpc_guards$;

-- Eligibility is about the assigned candidate, not just the requesting Ops account.
do $eligibility$
declare definition text;
begin
  definition := pg_get_functiondef('private.assert_companion_eligible(uuid,uuid)'::regprocedure);
  execute replace(definition,'and c.active',
    'and c.active and exists (select 1 from public.profiles ap where ap.id=c.id and ap.account_state=''active'')');
  definition := pg_get_functiondef('public.dispatch_claim_notifications(integer)'::regprocedure);
  execute replace(definition,'where n.status = ''pending''',
    'where exists (select 1 from public.profiles ap where ap.id=n.recipient_id and ap.account_state=''active'') and n.status = ''pending''');
end;
$eligibility$;

-- No target user argument, no grants/consent or diagnostic/audit details in output.
create function public.my_account_access() returns jsonb
language plpgsql stable security definer set search_path=''
as $$ declare p public.profiles; begin
  if auth.uid() is null then raise exception 'sign in required' using errcode='42501'; end if;
  select * into p from public.profiles where id=auth.uid();
  if not found then return jsonb_build_object('state','unconfirmed','role',null); end if;
  return jsonb_build_object('state',p.account_state,'role',case when p.account_state='active' then p.role::text else null end);
end $$;

create function private.audit_account_access() returns trigger
language plpgsql security definer set search_path=''
as $$ declare context jsonb; changed boolean; begin
  if tg_op='INSERT' then
    if new.account_state<>'pending' or new.account_state_version<>1 or new.role<>'family' then
      raise exception 'new accounts must start pending with the default role' using errcode='42501';
    end if;
    perform private.write_audit('account_created','profiles',new.id::text,null,
      jsonb_build_object('old_state',null,'new_state',new.account_state,'new_role',new.role,
      'version',1,'source','auth_creation','reason','identity created; not activation approval'));
    return new;
  end if;
  changed := new.account_state is distinct from old.account_state or new.role is distinct from old.role;
  if new.account_state_version<>old.account_state_version then
    raise exception 'account version is managed internally' using errcode='42501';
  end if;
  if not changed then return new; end if;
  if coalesce(current_setting('role',true),'none') not in ('none','postgres') or auth.uid() is not null then
    raise exception 'database owner required for account management' using errcode='42501';
  end if;
  context := nullif(current_setting('anuga.account_change_context',true),'')::jsonb;
  if coalesce(trim(context->>'reason'),'')='' or coalesce(trim(context->>'operator_ref'),'')=''
    or coalesce(trim(context->>'authority_ref'),'')='' then
    raise exception 'account change requires operator and authority context' using errcode='42501';
  end if;
  if new.role<>old.role and old.account_state<>'pending' then
    raise exception 'role reassignment requires separate review' using errcode='42501';
  end if;
  if new.account_state<>old.account_state and not (
    (old.account_state='pending' and new.account_state in ('active','disabled')) or
    (old.account_state='active' and new.account_state='disabled') or
    (old.account_state='disabled' and new.account_state='active')) then
    raise exception 'unsupported account transition' using errcode='22023';
  end if;
  new.account_state_version := old.account_state_version+1;
  perform private.write_audit('account_access_changed','profiles',new.id::text,null,
    context || jsonb_build_object('old_state',old.account_state,'new_state',new.account_state,
      'old_role',old.role,'new_role',new.role,'version',new.account_state_version,
      'source','operator','database_actor',session_user));
  return new;
end $$;
create trigger profile_account_access before insert or update on public.profiles
  for each row execute function private.audit_account_access();

create function private.configure_pilot_account(p_user_id uuid,p_expected_version bigint,p_state text,
  p_role public.user_role,p_reason text,p_operator_ref text,p_authority_ref text) returns jsonb
language plpgsql volatile security definer set search_path=''
as $$ declare p public.profiles; previous_context text; begin
  select * into p from public.profiles where id=p_user_id for update;
  if not found then raise exception 'profile missing; repair separately' using errcode='22023'; end if;
  if p_expected_version is distinct from p.account_state_version then
    raise exception 'account version conflict' using errcode='40001';
  end if;
  if p_state is null or p_state not in ('pending','active','disabled') or coalesce(trim(p_reason),'')=''
    or coalesce(trim(p_operator_ref),'')='' or coalesce(trim(p_authority_ref),'')='' then
    raise exception 'state, reason, operator and authority references required' using errcode='22023';
  end if;
  previous_context := current_setting('anuga.account_change_context',true);
  perform set_config('anuga.account_change_context',jsonb_build_object('reason',p_reason,
    'operator_ref',p_operator_ref,'authority_ref',p_authority_ref)::text,true);
  update public.profiles set account_state=p_state,role=coalesce(p_role,role) where id=p_user_id returning * into p;
  perform set_config('anuga.account_change_context',coalesce(previous_context,''),true);
  return jsonb_build_object('state',p.account_state,'role',p.role,'version',p.account_state_version);
end $$;

revoke all on function private.configure_pilot_account(uuid,bigint,text,public.user_role,text,text,text),
  private.audit_account_access(),private.account_is_active(),private.assert_active_account() from public,anon,authenticated,service_role;
grant execute on function private.account_is_active() to authenticated;
revoke all on function public.my_account_access() from public,anon,service_role;
grant execute on function public.my_account_access() to authenticated;

commit;
