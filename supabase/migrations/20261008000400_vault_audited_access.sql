-- Health vault with audited reads.
--
-- Postgres never fires triggers on SELECT, so read auditing cannot be a trigger.
-- App roles therefore get NO select privilege on vault tables. The only read
-- path is the vault_* functions below, which authorize the caller, write an
-- audit_log row, then return the data in the same transaction.
-- Writes are allowed through RLS and audited by row triggers.

create table public.vault_documents (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients (id) on delete cascade,
  doc_type text not null check (doc_type in ('lab_report', 'prescription', 'discharge_summary', 'receipt', 'other')),
  title text not null,
  storage_path text not null,
  uploaded_by uuid references public.profiles (id) default auth.uid(),
  created_at timestamptz not null default now()
);
create index vault_documents_patient_idx on public.vault_documents (patient_id, created_at);

create table public.vitals (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients (id) on delete cascade,
  kind text not null check (kind in ('weight_pre', 'weight_post', 'bp')),
  value jsonb not null,
  recorded_at timestamptz not null default now(),
  recorded_by uuid references public.profiles (id) default auth.uid()
);
create index vitals_patient_idx on public.vitals (patient_id, recorded_at);

create table public.medicines (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients (id) on delete cascade,
  name text not null,
  dose text not null default '',
  timings text[] not null default '{}',
  stock_count integer check (stock_count >= 0),
  refill_on date,
  created_at timestamptz not null default now()
);
create index medicines_patient_idx on public.medicines (patient_id);

revoke all on public.vault_documents, public.vitals, public.medicines from anon, authenticated;
grant insert (patient_id, doc_type, title, storage_path) on public.vault_documents to authenticated;
grant insert (patient_id, kind, value, recorded_at) on public.vitals to authenticated;
grant insert (patient_id, name, dose, timings, stock_count, refill_on) on public.medicines to authenticated;

alter table public.vault_documents enable row level security;
alter table public.vitals enable row level security;
alter table public.medicines enable row level security;

create policy editors_insert on public.vault_documents for insert to authenticated
  with check (private.can_edit_patient(patient_id));
create policy editors_insert on public.vitals for insert to authenticated
  with check (private.can_edit_patient(patient_id));
create policy editors_insert on public.medicines for insert to authenticated
  with check (private.can_edit_patient(patient_id));

create trigger vault_documents_audit after insert or update or delete on public.vault_documents
  for each row execute function private.audit_row_change();
create trigger vitals_audit after insert or update or delete on public.vitals
  for each row execute function private.audit_row_change();
create trigger medicines_audit after insert or update or delete on public.medicines
  for each row execute function private.audit_row_change();

-- Authorizes a vault read and records it. Family with any access level may read;
-- ops may read only while the patient's owner has an active ops_vault_access
-- consent. Companions have no path. Returns how access was granted.
create function private.authorize_vault_read(p_patient_id uuid, p_table text, p_purpose text)
returns text
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_basis text;
begin
  if private.can_view_patient(p_patient_id) then
    v_basis := 'patient_access';
  elsif private.is_ops() and exists (
    select 1
    from public.consents c
    join public.patient_access pa
      on pa.patient_id = c.patient_id and pa.user_id = c.user_id and pa.access_level = 'owner'
    where c.patient_id = p_patient_id and c.purpose = 'ops_vault_access' and c.withdrawn_at is null
  ) then
    v_basis := 'ops_consent';
  else
    raise exception 'not allowed' using errcode = '42501';
  end if;

  perform private.write_audit('vault_read', p_table, null, p_patient_id,
    jsonb_build_object('basis', v_basis, 'purpose', coalesce(p_purpose, '')));
  return v_basis;
end;
$$;

create function public.vault_list_documents(p_patient_id uuid, p_purpose text default null)
returns setof public.vault_documents
language plpgsql volatile security definer set search_path = ''
as $$
begin
  perform private.authorize_vault_read(p_patient_id, 'vault_documents', p_purpose);
  return query select * from public.vault_documents where patient_id = p_patient_id order by created_at desc;
end;
$$;

create function public.vault_list_vitals(p_patient_id uuid, p_purpose text default null)
returns setof public.vitals
language plpgsql volatile security definer set search_path = ''
as $$
begin
  perform private.authorize_vault_read(p_patient_id, 'vitals', p_purpose);
  return query select * from public.vitals where patient_id = p_patient_id order by recorded_at desc;
end;
$$;

create function public.vault_list_medicines(p_patient_id uuid, p_purpose text default null)
returns setof public.medicines
language plpgsql volatile security definer set search_path = ''
as $$
begin
  perform private.authorize_vault_read(p_patient_id, 'medicines', p_purpose);
  return query select * from public.medicines where patient_id = p_patient_id order by name;
end;
$$;

revoke execute on function
  public.vault_list_documents(uuid, text), public.vault_list_vitals(uuid, text),
  public.vault_list_medicines(uuid, text), private.authorize_vault_read(uuid, text, text)
from public, anon;
grant execute on function
  public.vault_list_documents(uuid, text), public.vault_list_vitals(uuid, text),
  public.vault_list_medicines(uuid, text)
to authenticated;
