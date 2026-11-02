// Focused contract checks for the Family care-request vertical slice.
import { before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { asAdmin, asUser, createUser, expectPgError, ids, probeAsAnon, probeAsUser, type Db } from './support/db.ts';

const editor = '20000000-0000-0000-0000-00000000ca01';
const stranger = '20000000-0000-0000-0000-00000000ca02';
const otherCentre = '50000000-0000-0000-0000-00000000ca01';
const inactivePackage = '60000000-0000-0000-0000-00000000ca01';
const plusPackage = '60000000-0000-0000-0000-000000000002';

type Intent = { requestId: string; patientId: string; centreId: string; packageId: string; pickup: string };

before(async () => {
  await createUser(editor);
  await createUser(stranger);
  await asAdmin(async (db) => {
    await db.query(`insert into public.patient_access (patient_id,user_id,access_level,granted_by)
      values ($1,$2,'editor',$3) on conflict do nothing`, [ids.patient, editor, ids.owner]);
    await db.query(`insert into public.centres (id,cluster_id,name,address,location)
      select $1,cluster_id,'Other Centre (synthetic)',address,location from public.centres where id=$2
      on conflict do nothing`, [otherCentre, ids.centre]);
    await db.query(`insert into public.packages (id,code,name,price_per_visit_paise,companion_pay_per_visit_paise,active)
      values ($1,'care_request_inactive','Inactive (synthetic)',0,0,false) on conflict do nothing`, [inactivePackage]);
  });
});

async function intent(offset = 40, time = '17:43:00'): Promise<Intent> {
  const [{ pickup }] = await asAdmin((db) => db.query<{ pickup: string }>(
    `select to_char((((now() at time zone 'Asia/Kolkata')::date + $1::int + $2::time)
       at time zone 'Asia/Kolkata') at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') || 'Z' as pickup`, [offset, time]));
  return { requestId: randomUUID(), patientId: ids.patient, centreId: ids.centre, packageId: ids.basicPackage, pickup };
}

async function submit(db: Db, value: Intent): Promise<string> {
  const [{ schedule_id }] = await db.query<{ schedule_id: string }>(
    'select public.family_request_care($1,$2,$3,$4,$5) as schedule_id',
    [value.requestId, value.patientId, value.centreId, value.packageId, value.pickup]);
  return schedule_id;
}

describe('Family care request contracts', () => {
  test('owner and editor get registered centre and only active existing packages', async () => {
    for (const user of [ids.owner, editor]) {
      const [{ options }] = await probeAsUser(user, (db) => db.query<{ options: { centre_id: string; packages: { id: string; name: string }[] } }>(
        'select public.family_care_options($1) as options', [ids.patient]));
      assert.equal(options.centre_id, ids.centre);
      assert.ok(options.packages.some((p) => p.id === ids.basicPackage));
      assert.ok(!options.packages.some((p) => p.id === inactivePackage));
    }
    for (const user of [ids.viewer, ids.asha, ids.ops, stranger]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select public.family_care_options($1)', [ids.patient])), '42501');
    }
    await expectPgError(probeAsAnon((db) => db.query('select public.family_care_options($1)', [ids.patient])), '42501');
  });

  test('owner/editor can submit; viewers, companions, ops and strangers cannot', async () => {
    const value = await intent();
    for (const user of [ids.owner, editor]) {
      const id = await probeAsUser(user, (db) => submit(db, value));
      assert.equal(id, value.requestId);
    }
    for (const user of [ids.viewer, ids.asha, ids.ops, stranger]) {
      await expectPgError(probeAsUser(user, (db) => submit(db, value)), '42501');
    }
    await expectPgError(probeAsAnon((db) => submit(db, value)), '42501');
  });

  test('owner trip consent is required and never granted by requesting', async () => {
    const value = await intent();
    await expectPgError(probeAsUser(ids.owner, async (db) => {
      await db.query("select public.set_consent($1,'trips',false)", [ids.patient]);
      return submit(db, value);
    }), '42501');
    await expectPgError(probeAsUser(ids.owner, async (db) => {
      await db.query("select public.set_consent($1,'trips',false)", [ids.patient]);
      return db.query('select public.family_care_options($1)', [ids.patient]);
    }), '42501');
  });

  test('rejects another centre, inactive package, past time and sub-minute time', async () => {
    const value = await intent();
    for (const invalid of [
      { ...value, centreId: otherCentre },
      { ...value, packageId: inactivePackage },
      { ...value, packageId: randomUUID() },
      await intent(-1),
      await intent(40, '17:43:30'),
    ]) {
      await expectPgError(probeAsUser(ids.owner, (db) => submit(db, invalid)), '22023');
    }
  });

  test('same-ID retry and different-ID same-slot retry return one schedule', async () => {
    const value = await intent(41);
    await probeAsUser(ids.owner, async (db) => {
      assert.equal(await submit(db, value), value.requestId);
      assert.equal(await submit(db, value), value.requestId);
      assert.equal(await submit(db, { ...value, requestId: randomUUID() }), value.requestId);
      const [{ count }] = await db.query<{ count: number }>(
        'select count(*)::int as count from public.schedules where id=$1', [value.requestId]);
      assert.equal(count, 1);
      const [schedule] = await db.query<{ starts_on: string; ends_on: string; session_minutes: number; primary_companion_id: string | null }>(
        'select starts_on::text,ends_on::text,session_minutes,primary_companion_id from public.schedules where id=$1', [value.requestId]);
      assert.equal(schedule.starts_on, schedule.ends_on);
      assert.equal(schedule.session_minutes, 300);
      assert.equal(schedule.primary_companion_id, null);
    });
  });

  test('a pickup shortly after IST midnight stores the IST date rather than the previous UTC date', async () => {
    const value = await intent(44, '00:15:00');
    const expectedIstDate = new Date(Date.parse(value.pickup) + 330 * 60_000).toISOString().slice(0, 10);
    assert.notEqual(expectedIstDate, new Date(value.pickup).toISOString().slice(0, 10));
    await probeAsUser(ids.owner, async (db) => {
      const id = await submit(db, value);
      const [schedule] = await db.query<{ pickup_date: string; pickup_time: string }>(
        'select starts_on::text as pickup_date,pickup_time::text from public.schedules where id=$1', [id]);
      assert.equal(schedule.pickup_date, expectedIstDate);
      assert.equal(schedule.pickup_time, '00:15:00');
      const [row] = await db.query<{ pickup_at: Date }>(
        'select pickup_at from public.family_care_requests($1) where schedule_id=$2', [ids.patient, id]);
      assert.equal(row.pickup_at.getTime(), Date.parse(value.pickup));
    });
  });

  test('a reused UUID or occupied slot cannot silently change package', async () => {
    const value = await intent(42);
    await asUser(ids.owner, (db) => submit(db, value));
    await expectPgError(probeAsUser(ids.owner, (db) => submit(db, { ...value, packageId: plusPackage })), '22023');
    await expectPgError(probeAsUser(ids.owner, (db) => submit(db, { ...value, requestId: randomUUID(), packageId: plusPackage })), '22023');
  });

  test('existing recurring schedule coverage prevents a duplicate request', async () => {
    const [{ pickup }] = await asAdmin((db) => db.query<{ pickup: string }>(
      `select scheduled_pickup_at::text as pickup from public.trips
       where schedule_id=$1 and scheduled_pickup_at>now() order by scheduled_pickup_at limit 1`, [ids.schedule]));
    assert.ok(pickup);
    await expectPgError(probeAsUser(ids.owner, (db) => submit(db, {
      requestId: randomUUID(), patientId: ids.patient, centreId: ids.centre, packageId: ids.basicPackage, pickup,
    })), '22023');
  });

  test('existing standalone trips and generated trips on inactive schedules cannot duplicate care', async () => {
    const standalone = await intent(46);
    await asAdmin((db) => db.query(`insert into public.trips
      (patient_id,centre_id,scheduled_pickup_at,scheduled_return_at)
      values ($1,$2,$3,$3::timestamptz+interval '300 minutes')`,
    [ids.patient, ids.centre, standalone.pickup]));
    await expectPgError(probeAsUser(ids.owner, (db) => submit(db, standalone)), '22023');

    const inactive = await intent(47);
    const id = await asUser(ids.owner, (db) => submit(db, inactive));
    await asUser(ids.ops, (db) => db.query(
      "select * from public.ops_create_schedule_trips($1,($2::timestamptz at time zone 'Asia/Kolkata')::date,1)", [id, inactive.pickup]));
    await asUser(ids.owner, (db) => db.query('update public.schedules set active=false where id=$1', [id]));
    assert.equal(await probeAsUser(ids.owner, (db) => submit(db, { ...inactive, requestId: randomUUID() })), id);
  });

  test('new ops confirmation rechecks owner consent and denies every non-ops caller', async () => {
    const value = await intent(45);
    const id = await asUser(ids.owner, (db) => submit(db, value));
    for (const user of [ids.owner, ids.viewer, ids.asha, stranger]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.ops_confirm_care_request($1)', [id])), '42501');
    }
    await expectPgError(probeAsAnon((db) => db.query('select * from public.ops_confirm_care_request($1)', [id])), '42501');
    await asUser(ids.owner, (db) => db.query("select public.set_consent($1,'trips',false)", [ids.patient]));
    try {
      await expectPgError(probeAsUser(ids.ops, (db) => db.query('select * from public.ops_confirm_care_request($1)', [id])), '42501');
    } finally {
      await asUser(ids.owner, (db) => db.query("select public.set_consent($1,'trips',true)", [ids.patient]));
    }
    const first = await asUser(ids.ops, (db) => db.query<{ created: boolean }>(
      'select * from public.ops_confirm_care_request($1)', [id]));
    const repeat = await asUser(ids.ops, (db) => db.query<{ created: boolean }>(
      'select * from public.ops_confirm_care_request($1)', [id]));
    assert.equal(first.length, 1);
    assert.equal(first[0].created, true);
    assert.equal(repeat[0].created, false);
  });

  test('Family submit -> ops visibility -> ops confirmation/assignment -> persisted Family status', async () => {
    const value = await intent(43);
    const id = await asUser(ids.owner, (db) => submit(db, value));
    type RequestRow = { schedule_id: string; request_state: string; trip_id: string | null; trip_status: string | null; companion_name: string | null; pickup_at: Date };
    const familyRead = (user = ids.owner as string) => probeAsUser(user, (db) => db.query<RequestRow>(
      'select * from public.family_care_requests($1) where schedule_id=$2', [ids.patient, id]));
    assert.equal((await familyRead())[0].request_state, 'pending');
    assert.equal((await familyRead(ids.viewer))[0].request_state, 'pending');
    const [opsRow] = await probeAsUser(ids.ops, (db) => db.query<RequestRow>(
      'select * from public.ops_care_requests() where schedule_id=$1', [id]));
    assert.equal(opsRow.schedule_id, id);
    assert.equal(opsRow.request_state, 'pending');
    for (const user of [ids.owner, ids.viewer, ids.asha, stranger]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.ops_care_requests()')), '42501');
    }
    for (const user of [ids.asha, ids.ops, stranger]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.family_care_requests($1)', [ids.patient])), '42501');
    }
    await asUser(ids.ops, (db) => db.query(
      'select * from public.ops_confirm_care_request($1)', [id]));
    assert.equal((await familyRead())[0].request_state, 'confirmed');
    await asUser(ids.ops, (db) => db.query('select public.ops_assign_schedule_companions($1,$2,$3)', [id, ids.asha, ids.ravi]));
    const [assigned] = await familyRead();
    assert.equal(assigned.request_state, 'assigned');
    assert.equal(assigned.companion_name, 'Asha Companion (synthetic)');
    assert.equal(assigned.trip_status, 'scheduled');
    await asUser(ids.owner, (db) => db.query("select public.advance_trip($1,'cancelled','Synthetic test')", [assigned.trip_id]));
    assert.equal((await familyRead())[0].request_state, 'cancelled');
  });
});
