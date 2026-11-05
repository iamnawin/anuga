-- Read-only catalogue attestation. No patient rows, object paths, tokens or secrets.
-- Run with psql -X -v ON_ERROR_STOP=1 or in the intended project's SQL Editor.
-- A successful transaction is an observation, not a production approval.
begin transaction isolation level repeatable read read only;
set local statement_timeout = '30s';
set local lock_timeout = '5s';

select 'identity' as section, current_database() as database_name,
       current_user as database_role, current_setting('server_version') as postgres_version,
       current_setting('transaction_read_only') as transaction_read_only;

select 'required_relations' as section, name, to_regclass(name) is not null as present
from (values ('supabase_migrations.schema_migrations'), ('auth.users'),
             ('storage.buckets'), ('storage.objects'), ('public.consents'),
             ('private.trip_event_internal_notes')) as required(name)
order by name;

-- Migration records attest versions, not that definitions have not drifted.
-- Supabase must have this relation. Missing/denied is a failed observation.
select 'migration_versions' as section, version
from supabase_migrations.schema_migrations order by version;

select 'app_roles' as section, rolname, rolsuper, rolbypassrls, rolcanlogin
from pg_catalog.pg_roles
where rolname in ('anon', 'authenticated', 'service_role') order by rolname;

select 'relations' as section, n.nspname as schema_name, c.relname,
       c.relkind, c.relrowsecurity as rls_enabled, c.relforcerowsecurity as rls_forced,
       encode(sha256(convert_to(coalesce(c.relacl::text, ''), 'UTF8')), 'hex') as acl_sha256
from pg_catalog.pg_class c join pg_catalog.pg_namespace n on n.oid = c.relnamespace
where (n.nspname in ('public', 'private') and c.relkind in ('r', 'p', 'v', 'm', 'S'))
   or (n.nspname = 'storage' and c.relname in ('objects', 'buckets'))
order by n.nspname, c.relname;

select 'columns' as section, table_schema, table_name, column_name, ordinal_position,
       data_type, udt_schema, udt_name, is_nullable, is_identity, is_generated,
       encode(sha256(convert_to(coalesce(column_default, ''), 'UTF8')), 'hex') as default_sha256
from information_schema.columns
where table_schema in ('public', 'private')
order by table_schema, table_name, ordinal_position;

select 'table_grants' as section, n.nspname as schema_name, c.relname,
       case when a.grantee = 0 then 'PUBLIC' else pg_get_userbyid(a.grantee) end as grantee,
       a.privilege_type, a.is_grantable
from pg_catalog.pg_class c join pg_catalog.pg_namespace n on n.oid = c.relnamespace
cross join lateral aclexplode(coalesce(c.relacl, acldefault(
  case when c.relkind = 'S' then 'S'::"char" else 'r'::"char" end, c.relowner))) a
where n.nspname in ('public', 'private', 'auth', 'storage')
  and (a.grantee = 0 or pg_get_userbyid(a.grantee) in ('anon', 'authenticated', 'service_role'))
order by n.nspname, c.relname, grantee, a.privilege_type;

select 'column_grants' as section, table_schema, table_name, column_name,
       grantee, privilege_type, is_grantable
from information_schema.column_privileges
where table_schema in ('public', 'private')
  and grantee in ('PUBLIC', 'anon', 'authenticated', 'service_role')
order by table_schema, table_name, column_name, grantee, privilege_type;

select 'policies' as section, schemaname, tablename, policyname, permissive, roles, cmd,
       encode(sha256(convert_to(coalesce(qual, ''), 'UTF8')), 'hex') as using_sha256,
       encode(sha256(convert_to(coalesce(with_check, ''), 'UTF8')), 'hex') as check_sha256
from pg_catalog.pg_policies
where schemaname in ('public', 'private', 'auth', 'storage')
order by schemaname, tablename, policyname;

select 'functions' as section, n.nspname as schema_name, p.proname,
       pg_get_function_identity_arguments(p.oid) as arguments,
       p.prosecdef as security_definer, p.provolatile, p.proconfig,
       encode(sha256(convert_to(pg_get_functiondef(p.oid), 'UTF8')), 'hex') as definition_sha256,
       encode(sha256(convert_to(coalesce(p.proacl::text, ''), 'UTF8')), 'hex') as acl_sha256
from pg_catalog.pg_proc p join pg_catalog.pg_namespace n on n.oid = p.pronamespace
where n.nspname in ('public', 'private') and p.prokind in ('f', 'p')
order by n.nspname, p.proname, arguments;

select 'function_grants' as section, n.nspname as schema_name, p.proname,
       pg_get_function_identity_arguments(p.oid) as arguments,
       case when a.grantee = 0 then 'PUBLIC' else pg_get_userbyid(a.grantee) end as grantee,
       a.privilege_type, a.is_grantable
from pg_catalog.pg_proc p join pg_catalog.pg_namespace n on n.oid = p.pronamespace
cross join lateral aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a
where n.nspname in ('public', 'private') and p.prokind in ('f', 'p')
  and (a.grantee = 0 or pg_get_userbyid(a.grantee) in ('anon', 'authenticated', 'service_role'))
order by n.nspname, p.proname, arguments, grantee;

select 'constraints' as section, n.nspname as schema_name, c.relname, k.conname, k.contype,
       encode(sha256(convert_to(pg_get_constraintdef(k.oid), 'UTF8')), 'hex') as definition_sha256
from pg_catalog.pg_constraint k join pg_catalog.pg_class c on c.oid = k.conrelid
join pg_catalog.pg_namespace n on n.oid = c.relnamespace
where n.nspname in ('public', 'private') order by n.nspname, c.relname, k.conname;

select 'triggers' as section, n.nspname as schema_name, c.relname, t.tgname, t.tgenabled,
       encode(sha256(convert_to(pg_get_triggerdef(t.oid), 'UTF8')), 'hex') as definition_sha256
from pg_catalog.pg_trigger t join pg_catalog.pg_class c on c.oid = t.tgrelid
join pg_catalog.pg_namespace n on n.oid = c.relnamespace
where not t.tgisinternal and n.nspname in ('public', 'private', 'auth', 'storage')
order by n.nspname, c.relname, t.tgname;

select 'default_grants' as section, coalesce(n.nspname, '(all schemas)') as schema_name,
       d.defaclobjtype,
       encode(sha256(convert_to(d.defaclacl::text, 'UTF8')), 'hex') as acl_sha256
from pg_catalog.pg_default_acl d left join pg_catalog.pg_namespace n on n.oid = d.defaclnamespace
where n.nspname in ('public', 'private', 'auth', 'storage') or d.defaclnamespace = 0
order by schema_name, d.defaclobjtype, acl_sha256;

rollback;
