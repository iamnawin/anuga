-- SYNTHETIC DATA ONLY. Names, phones and locations are invented.
-- Never load real patient data into dev or test databases.
--
-- Fixed ids (referenced by tests and local app development):
--   1000...0001 ops admin        2000...0001 family owner      2000...0002 family viewer
--   3000...0001 companion Asha (primary, ~0.5 km)   3000...0002 companion Ravi (backup, ~1.9 km)
--   3000...0003 companion Far (outside radius, ~9 km)   3000...0004 companion Pending (unverified)

-- Rows are shaped the way Supabase Auth (GoTrue) reads them, so phone-OTP sign-in
-- works on Supabase local: default instance id, audience, phone without '+'
-- (GoTrue's storage format), confirmed phone, and empty strings for token
-- columns and timestamps that GoTrue cannot read as NULL. Local OTP codes: supabase/config.toml.
insert into auth.users (instance_id, id, aud, role, phone, phone_confirmed_at, raw_user_meta_data,
                        confirmation_token, recovery_token, email_change_token_new, email_change,
                        created_at, updated_at)
select '00000000-0000-0000-0000-000000000000', u.id::uuid, 'authenticated', 'authenticated', u.phone, now(),
       jsonb_build_object('full_name', u.full_name), '', '', '', '', now(), now()
from (values
  ('10000000-0000-0000-0000-000000000001', '919000000001', 'Ops Admin (synthetic)'),
  ('20000000-0000-0000-0000-000000000001', '919000000101', 'Kiran Rao (synthetic)'),
  ('20000000-0000-0000-0000-000000000002', '919000000102', 'Meena Rao (synthetic)'),
  ('30000000-0000-0000-0000-000000000001', '919000000201', 'Asha Companion (synthetic)'),
  ('30000000-0000-0000-0000-000000000002', '919000000202', 'Ravi Companion (synthetic)'),
  ('30000000-0000-0000-0000-000000000003', '919000000203', 'Far Companion (synthetic)'),
  ('30000000-0000-0000-0000-000000000004', '919000000204', 'Pending Companion (synthetic)')
) u(id, phone, full_name);

update public.profiles set role = 'ops_admin' where id = '10000000-0000-0000-0000-000000000001';
update public.profiles set role = 'companion' where id::text like '30000000-%';

insert into public.clusters (id, name, status, companion_radius_m) values
  ('40000000-0000-0000-0000-000000000001', 'Synthetic Cluster A', 'open', 3000);

insert into public.centres (id, cluster_id, name, address, location, phone) values
  ('50000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001',
   'Synthetic Dialysis Centre 1', '1 Example Road, Hyderabad (synthetic)',
   extensions.st_setsrid(extensions.st_makepoint(78.4200, 17.4800), 4326)::extensions.geography, '+919000000901');

insert into public.packages (id, code, name, price_per_visit_paise, monthly_fee_paise,
                             companion_pay_per_visit_paise, companion_stays_through_session) values
  ('60000000-0000-0000-0000-000000000001', 'basic', 'Basic', 40000, 0, 25000, false),
  ('60000000-0000-0000-0000-000000000002', 'plus', 'Plus', 75000, 0, 40000, true),
  ('60000000-0000-0000-0000-000000000003', 'family_care', 'Family Care', 75000, 99900, 40000, true);

insert into public.companions (id, cluster_id, home_location, verification_status, background_check_on, training_completed) values
  ('30000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001',
   extensions.st_setsrid(extensions.st_makepoint(78.4100, 17.4960), 4326)::extensions.geography, 'verified', '2026-09-01', true),
  ('30000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000001',
   extensions.st_setsrid(extensions.st_makepoint(78.3900, 17.5050), 4326)::extensions.geography, 'verified', '2026-09-01', true),
  ('30000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000001',
   extensions.st_setsrid(extensions.st_makepoint(78.4900, 17.5200), 4326)::extensions.geography, 'verified', '2026-09-01', true),
  ('30000000-0000-0000-0000-000000000004', '40000000-0000-0000-0000-000000000001',
   extensions.st_setsrid(extensions.st_makepoint(78.4060, 17.4940), 4326)::extensions.geography, 'pending', null, false);

insert into public.patients (id, full_name, date_of_birth, home_address, home_location, centre_id,
                             mobility_notes, emergency_contacts, created_by) values
  ('70000000-0000-0000-0000-000000000001', 'Lakshmi Rao (synthetic)', '1958-04-12',
   '22 Sample Colony, Hyderabad (synthetic)',
   extensions.st_setsrid(extensions.st_makepoint(78.4050, 17.4950), 4326)::extensions.geography,
   '50000000-0000-0000-0000-000000000001', 'Uses a walking stick; needs help on stairs',
   '[{"name": "Kiran Rao (synthetic)", "phone": "+919000000101", "relation": "son"}]',
   '20000000-0000-0000-0000-000000000001');

insert into public.patient_access (patient_id, user_id, access_level, granted_by) values
  ('70000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'owner', '20000000-0000-0000-0000-000000000001'),
  ('70000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'viewer', '20000000-0000-0000-0000-000000000001');

insert into public.consents (user_id, patient_id, purpose) values
  ('20000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000001', 'trips');

insert into public.vault_documents (patient_id, doc_type, title, storage_path, uploaded_by) values
  ('70000000-0000-0000-0000-000000000001', 'lab_report', 'Monthly labs (synthetic)',
   'vault/70000000-0000-0000-0000-000000000001/labs-synthetic.pdf', '20000000-0000-0000-0000-000000000001');
insert into public.vitals (patient_id, kind, value, recorded_by) values
  ('70000000-0000-0000-0000-000000000001', 'weight_pre', '{"kg": 61.5}', '20000000-0000-0000-0000-000000000001');
insert into public.medicines (patient_id, name, dose, timings, stock_count, refill_on) values
  ('70000000-0000-0000-0000-000000000001', 'Synthetic Medicine A', '1 tablet', '{morning}', 20, current_date + 10);

-- Mon/Wed/Fri 07:00 IST, Basic package.
insert into public.schedules (id, patient_id, package_id, days_of_week, pickup_time, session_minutes,
                              timezone, starts_on, created_by) values
  ('80000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000001',
   '60000000-0000-0000-0000-000000000001', '{1,3,5}', '07:00', 300, 'Asia/Kolkata', current_date,
   '20000000-0000-0000-0000-000000000001');

select public.ops_assign_schedule_companions('80000000-0000-0000-0000-000000000001',
  '30000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002');
select public.ops_generate_trips('80000000-0000-0000-0000-000000000001', current_date, 14);
