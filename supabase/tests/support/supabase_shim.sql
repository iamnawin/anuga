-- Minimal stand-in for the parts of a Supabase database the migrations rely on.
-- Loaded ONLY by the PGlite test harness. Real Supabase (local or hosted)
-- already provides all of this; never apply this file there.

create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;

create schema auth;
-- Includes the GoTrue columns the seed sets so real phone-OTP sign-in finds seeded users.
create table auth.users (
  id uuid primary key,
  instance_id uuid,
  phone text unique,
  email text unique,
  aud text default 'authenticated',
  role text default 'authenticated',
  raw_user_meta_data jsonb not null default '{}',
  confirmation_token text,
  recovery_token text,
  email_change_token_new text,
  email_change text,
  created_at timestamptz not null default now()
);

-- Same resolution order as Supabase's auth.uid().
create function auth.uid() returns uuid language sql stable as $$
  select coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;

create function auth.jwt() returns jsonb language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb
$$;

grant usage on schema auth to anon, authenticated, service_role;
grant execute on all functions in schema auth to anon, authenticated, service_role;

create schema extensions;
grant usage on schema extensions to anon, authenticated, service_role;

-- Supabase's default privileges: every new public object is granted to the API roles.
-- Mirroring them here proves the migrations' explicit revokes actually work.
grant usage on schema public to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
