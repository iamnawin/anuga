-- Core schema for the first journey: people, places, schedules, trips.
-- Health vault tables live in 20261008000400_vault_audited_access.sql.

create schema if not exists extensions;
create extension if not exists postgis with schema extensions;

create schema if not exists private;
revoke all on schema private from public;

-- Enums ---------------------------------------------------------------------

create type public.user_role as enum ('family', 'companion', 'ops_admin');
create type public.access_level as enum ('owner', 'editor', 'viewer', 'patient');
create type public.trip_status as enum (
  'scheduled', 'companion_en_route', 'picked_up', 'at_centre', 'handed_over',
  'session_done', 'returning', 'dropped_home', 'completed',
  'cancelled', 'no_show', 'issue_reported'
);
create type public.transition_actor as enum ('companion', 'ops', 'family');
create type public.verification_status as enum ('pending', 'verified', 'suspended');
create type public.cluster_status as enum ('planned', 'open', 'paused');
create type public.consent_purpose as enum ('trips', 'vault', 'ops_vault_access');
create type public.notification_channel as enum ('push', 'whatsapp', 'sms');
create type public.notification_status as enum ('pending', 'sent', 'failed');

-- Config (business values live here, never in code) -------------------------

create table public.app_settings (
  key text primary key,
  value jsonb not null,
  description text not null default ''
);

insert into public.app_settings (key, value, description) values
  ('companion_details_hours_before', '12', 'Companion sees patient trip details from this many hours before pickup'),
  ('companion_details_hours_after', '6', 'Companion keeps trip details this many hours after the planned return'),
  ('trip_generation_days', '28', 'Rolling window of trips generated from a schedule'),
  ('pickup_otp_ttl_minutes', '720', 'Pickup OTP validity'),
  ('pickup_otp_max_attempts', '5', 'Wrong OTP entries before the code is locked');

-- People ----------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role public.user_role not null default 'family',
  full_name text not null default '',
  phone text,
  preferred_language text not null default 'en' check (preferred_language in ('en', 'te', 'hi')),
  created_at timestamptz not null default now()
);

-- Places ----------------------------------------------------------------------

create table public.clusters (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  status public.cluster_status not null default 'planned',
  companion_radius_m integer not null default 3000 check (companion_radius_m between 500 and 10000),
  min_patients_to_open integer not null default 10,
  min_companions_to_open integer not null default 4,
  created_at timestamptz not null default now()
);

create table public.centres (
  id uuid primary key default gen_random_uuid(),
  cluster_id uuid not null references public.clusters (id),
  name text not null,
  address text not null,
  location extensions.geography(Point, 4326) not null,
  phone text,
  created_at timestamptz not null default now()
);

-- Patients and who may see them ---------------------------------------------
-- Ownership is a patient_access row with level 'owner' (single source of truth).

create table public.patients (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  date_of_birth date,
  home_address text not null,
  home_location extensions.geography(Point, 4326) not null,
  centre_id uuid not null references public.centres (id),
  mobility_notes text not null default '',
  emergency_contacts jsonb not null default '[]' check (jsonb_typeof(emergency_contacts) = 'array'),
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.patient_access (
  patient_id uuid not null references public.patients (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  access_level public.access_level not null,
  granted_by uuid references public.profiles (id),
  granted_at timestamptz not null default now(),
  primary key (patient_id, user_id)
);
create unique index patient_access_one_owner on public.patient_access (patient_id) where access_level = 'owner';
create index patient_access_user_idx on public.patient_access (user_id);

create table public.consents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  patient_id uuid not null references public.patients (id) on delete cascade,
  purpose public.consent_purpose not null,
  granted_at timestamptz not null default now(),
  withdrawn_at timestamptz
);
create index consents_patient_idx on public.consents (patient_id, purpose) where withdrawn_at is null;

-- Companions --------------------------------------------------------------------

create table public.companions (
  id uuid primary key references public.profiles (id) on delete cascade,
  cluster_id uuid not null references public.clusters (id),
  home_location extensions.geography(Point, 4326) not null,
  verification_status public.verification_status not null default 'pending',
  background_check_on date,
  training_completed boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Packages, schedules, trips -----------------------------------------------------

create table public.packages (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  price_per_visit_paise integer not null check (price_per_visit_paise >= 0),
  monthly_fee_paise integer not null default 0 check (monthly_fee_paise >= 0),
  companion_pay_per_visit_paise integer not null check (companion_pay_per_visit_paise >= 0),
  companion_stays_through_session boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.schedules (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients (id) on delete cascade,
  package_id uuid not null references public.packages (id),
  -- ISO weekdays: 1 = Monday ... 7 = Sunday
  days_of_week smallint[] not null
    check (cardinality(days_of_week) > 0 and days_of_week <@ array[1, 2, 3, 4, 5, 6, 7]::smallint[]),
  pickup_time time not null,
  -- Planned time from pickup until the patient is ready for the return leg.
  session_minutes integer not null default 300 check (session_minutes between 60 and 600),
  timezone text not null default 'Asia/Kolkata',
  starts_on date not null default current_date,
  ends_on date,
  primary_companion_id uuid references public.companions (id),
  backup_companion_id uuid references public.companions (id),
  active boolean not null default true,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (primary_companion_id <> backup_companion_id),
  check (ends_on is null or ends_on >= starts_on)
);
create index schedules_patient_idx on public.schedules (patient_id);

create table public.trips (
  id uuid primary key default gen_random_uuid(),
  schedule_id uuid references public.schedules (id) on delete set null,
  patient_id uuid not null references public.patients (id) on delete cascade,
  centre_id uuid not null references public.centres (id),
  companion_id uuid references public.companions (id),
  scheduled_pickup_at timestamptz not null,
  scheduled_return_at timestamptz not null,
  status public.trip_status not null default 'scheduled',
  status_before_issue public.trip_status,
  picked_up_at timestamptz,
  completed_at timestamptz,
  fare_amount_paise integer check (fare_amount_paise >= 0),
  post_visit_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (schedule_id, scheduled_pickup_at),
  check (scheduled_return_at > scheduled_pickup_at)
);
create index trips_patient_time_idx on public.trips (patient_id, scheduled_pickup_at);
create index trips_companion_time_idx on public.trips (companion_id, scheduled_pickup_at);
create index trips_status_idx on public.trips (status, scheduled_pickup_at);

-- OTP secrets are never readable by app roles (no grants at all).
create table public.trip_otps (
  trip_id uuid primary key references public.trips (id) on delete cascade,
  otp_hash bytea not null,
  salt bytea not null,
  attempts integer not null default 0,
  expires_at timestamptz not null,
  issued_by uuid references public.profiles (id),
  issued_at timestamptz not null default now(),
  consumed_at timestamptz
);

-- Append-only: app roles get SELECT only; writes happen inside definer functions.
create table public.trip_events (
  id bigint generated always as identity primary key,
  trip_id uuid not null references public.trips (id) on delete cascade,
  from_status public.trip_status,
  to_status public.trip_status not null,
  actor_id uuid references public.profiles (id),
  actor_kind public.transition_actor,
  note text,
  location extensions.geography(Point, 4326),
  created_at timestamptz not null default now()
);
create index trip_events_trip_idx on public.trip_events (trip_id, id);

-- Allowed state changes, as data so apps can render the same rules.
create table public.trip_transitions (
  from_status public.trip_status not null,
  to_status public.trip_status not null,
  actor public.transition_actor not null,
  requires_otp boolean not null default false,
  primary key (from_status, to_status, actor)
);

-- Outbox: one row per recipient per channel. A dispatcher (service role) sends them.
create table public.notifications (
  id bigint generated always as identity primary key,
  trip_id uuid references public.trips (id) on delete cascade,
  recipient_id uuid not null references public.profiles (id) on delete cascade,
  channel public.notification_channel not null,
  template text not null,
  payload jsonb not null default '{}',
  status public.notification_status not null default 'pending',
  attempts integer not null default 0,
  created_at timestamptz not null default now(),
  sent_at timestamptz
);
create index notifications_pending_idx on public.notifications (status, created_at) where status = 'pending';
create index notifications_recipient_idx on public.notifications (recipient_id, created_at);

-- Audit log: append-only, no FK on patient_id so entries outlive deletions.
create table public.audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid,
  action text not null,
  table_name text,
  record_id text,
  patient_id uuid,
  details jsonb not null default '{}',
  at timestamptz not null default now()
);
create index audit_log_patient_idx on public.audit_log (patient_id, at);
