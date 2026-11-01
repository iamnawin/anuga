-- SYNTHETIC DATA ONLY. Optional cleanup after grouping verification.
-- Deletes ONLY the three exact fixture IDs with their expected identity/marker.
-- Refuses workflow/OTP/notification/invoice dependencies, so nothing cascades and
-- no invoice link is nulled. Already absent rows are safe. No prefix deletion.
do $$
declare
  c_ids constant uuid[] := array[
    '92000000-0000-0000-0000-000000000001', '92000000-0000-0000-0000-000000000002',
    '92000000-0000-0000-0000-000000000003']::uuid[];
begin
  if exists (select 1 from public.patients where full_name not like '%(synthetic)')
     or exists (select 1 from auth.users where coalesce(phone, '') not like '919000000___') then
    raise exception 'non-synthetic people found; cleanup runs on synthetic test projects only';
  end if;
  if not exists (select 1 from public.profiles p join auth.users u on u.id = p.id
                 where p.id = '30000000-0000-0000-0000-000000000001' and p.role = 'companion'
                   and u.phone = '919000000201') then
    raise exception 'synthetic companion Asha (+919000000201) not found';
  end if;
  perform 1 from public.trips where id = any(c_ids) for update;
  if exists (select 1 from public.trips t where t.id = any(c_ids) and not (
      t.patient_id = '70000000-0000-0000-0000-000000000001'
      and t.centre_id = '50000000-0000-0000-0000-000000000001'
      and t.companion_id is not distinct from '30000000-0000-0000-0000-000000000001'::uuid
      and t.schedule_id is null and t.fare_amount_paise is null and t.status_before_issue is null
      and t.status = case when t.id = c_ids[1] then 'completed'::public.trip_status else 'scheduled'::public.trip_status end
      and coalesce(t.post_visit_note, '') = 'Synthetic companion_trip_groups.sql: ' ||
          case when t.id = c_ids[1] then 'Previous' when t.id = c_ids[2] then 'Today' else 'Upcoming' end)) then
    raise exception 'fixed trip IDs are not pristine fixture-owned records; no cleanup performed';
  end if;
  if exists (select 1 from public.trip_events where trip_id = any(c_ids))
     or exists (select 1 from public.trip_otps where trip_id = any(c_ids))
     or exists (select 1 from public.notifications where trip_id = any(c_ids))
     or exists (select 1 from public.invoice_lines where trip_id = any(c_ids)) then
    raise exception 'fixture trips have dependent workflow or invoice records; no cleanup performed';
  end if;
  delete from public.trips where id = any(c_ids);
end $$;
