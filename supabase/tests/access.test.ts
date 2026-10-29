// Row-level security and grants: every rule has an allowed and a denied case.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, createTrip, createUser, expectPgError, ids, probeAsAnon, probeAsUser } from './support/db.ts';

const stranger = '20000000-0000-0000-0000-0000000000ff';

describe('patients', () => {
  test('owner and viewer can read their patient', async () => {
    for (const user of [ids.owner, ids.viewer]) {
      const rows = await probeAsUser(user, (db) => db.query('select id from public.patients'));
      assert.deepEqual(rows.map((r) => r.id), [ids.patient]);
    }
  });

  test('ops can read patients', async () => {
    const rows = await probeAsUser(ids.ops, (db) => db.query('select id from public.patients'));
    assert.equal(rows.length, 1);
  });

  test('a family account without patient_access sees nothing', async () => {
    await createUser(stranger);
    const rows = await probeAsUser(stranger, (db) => db.query('select id from public.patients'));
    assert.equal(rows.length, 0);
  });

  test('companions cannot read the patients table, even for their own trips', async () => {
    const rows = await probeAsUser(ids.asha, (db) => db.query('select id from public.patients'));
    assert.equal(rows.length, 0);
  });

  test('anon has no table privileges', async () => {
    await expectPgError(probeAsAnon((db) => db.query('select id from public.patients')));
  });

  test('owner can update; viewer update affects nothing', async () => {
    const updated = await probeAsUser(ids.owner, (db) =>
      db.query(`update public.patients set mobility_notes = 'x' where id = $1 returning id`, [ids.patient]));
    assert.equal(updated.length, 1);
    const denied = await probeAsUser(ids.viewer, (db) =>
      db.query(`update public.patients set mobility_notes = 'x' where id = $1 returning id`, [ids.patient]));
    assert.equal(denied.length, 0);
  });

  test('direct insert is not granted; create_patient makes the caller owner', async () => {
    await expectPgError(probeAsUser(ids.owner, (db) =>
      db.query(`insert into public.patients (full_name, home_address, home_location, centre_id)
                values ('x', 'y', null, $1)`, [ids.centre])));
    const access = await probeAsUser(stranger, async (db) => {
      const [{ id }] = await db.query<{ id: string }>(
        `select public.create_patient('New Patient (synthetic)', 'Addr', 17.49, 78.40, $1) as id`, [ids.centre]);
      return db.query('select access_level from public.patient_access where patient_id = $1', [id]);
    });
    assert.deepEqual(access, [{ access_level: 'owner' }]);
  });

  test('companions cannot create patients', async () => {
    await expectPgError(probeAsUser(ids.asha, (db) =>
      db.query(`select public.create_patient('x', 'y', 17.49, 78.40, $1)`, [ids.centre])));
  });
});

describe('profiles', () => {
  test('users read only their own profile; ops read all', async () => {
    const own = await probeAsUser(ids.owner, (db) => db.query('select id from public.profiles'));
    assert.deepEqual(own.map((r) => r.id), [ids.owner]);
    const all = await probeAsUser(ids.ops, (db) => db.query('select id from public.profiles'));
    assert.ok(all.length >= 7);
  });

  test('users cannot change their own role', async () => {
    await expectPgError(probeAsUser(ids.owner, (db) =>
      db.query(`update public.profiles set role = 'ops_admin' where id = $1`, [ids.owner])));
  });
});

describe('trips and schedules', () => {
  test('family sees trips of their patient; strangers see none', async () => {
    const family = await probeAsUser(ids.viewer, (db) => db.query('select id from public.trips'));
    assert.ok(family.length > 0);
    const none = await probeAsUser(stranger, (db) => db.query('select id from public.trips'));
    assert.equal(none.length, 0);
  });

  test('a companion sees only trips assigned to them', async () => {
    // Seed trips fall inside the companion read window only at some times of day.
    const tripForAsha = await createTrip(600);
    const tripForRavi = await createTrip(600, ids.ravi);
    const asha = await probeAsUser(ids.asha, (db) => db.query<{ id: string }>('select id from public.trips'));
    assert.ok(asha.some((t) => t.id === tripForAsha));
    assert.ok(!asha.some((t) => t.id === tripForRavi));
    const ravi = await probeAsUser(ids.ravi, (db) => db.query<{ id: string }>('select id from public.trips'));
    assert.ok(ravi.some((t) => t.id === tripForRavi));
  });

  test('nobody can write trips directly', async () => {
    for (const user of [ids.owner, ids.asha, ids.ops]) {
      await expectPgError(probeAsUser(user, (db) => db.query(`update public.trips set status = 'completed'`)));
    }
  });

  test('family cannot set companions on a schedule directly', async () => {
    await expectPgError(probeAsUser(ids.owner, (db) =>
      db.query(`update public.schedules set primary_companion_id = $1 where id = $2`, [ids.ravi, ids.schedule])));
  });

  test('trip_otps is unreadable for every app role', async () => {
    for (const user of [ids.owner, ids.asha, ids.ops]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.trip_otps')));
    }
  });

  test('trip_events are append-only for app roles', async () => {
    await expectPgError(probeAsUser(ids.ops, (db) => db.query('delete from public.trip_events')));
  });
});

describe('companion restricted projection', () => {
  test('returns only trip-essential patient fields inside the window', async () => {
    const tripId = await createTrip(60);
    const rows = await probeAsUser(ids.asha, (db) => db.query('select * from public.companion_my_trips()'));
    const trip = rows.find((r) => r.trip_id === tripId);
    assert.ok(trip);
    assert.equal(trip.details_visible, true);
    assert.equal(trip.patient_name, 'Lakshmi Rao (synthetic)');
    assert.equal(trip.mobility_notes, 'Uses a walking stick; needs help on stairs');
    assert.ok(Array.isArray(trip.emergency_contacts));
    for (const forbidden of ['date_of_birth', 'patient_id', 'otp_hash', 'storage_path']) {
      assert.ok(!(forbidden in trip), `projection must not expose ${forbidden}`);
    }
  });

  test('hides patient details outside the time window', async () => {
    const farTrip = await createTrip(5 * 24 * 60);
    const rows = await probeAsUser(ids.asha, (db) => db.query('select * from public.companion_my_trips()'));
    const trip = rows.find((r) => r.trip_id === farTrip);
    assert.ok(trip);
    assert.equal(trip.details_visible, false);
    assert.equal(trip.patient_name, null);
    assert.equal(trip.home_address, null);
    assert.equal(trip.home_lat, null);
  });

  test('does not include trips assigned to another companion', async () => {
    const tripForRavi = await createTrip(90, ids.ravi);
    const rows = await probeAsUser(ids.asha, (db) => db.query('select trip_id from public.companion_my_trips()'));
    assert.ok(!rows.some((r) => r.trip_id === tripForRavi));
  });

  test('family and ops accounts cannot call it', async () => {
    await expectPgError(probeAsUser(ids.owner, (db) => db.query('select * from public.companion_my_trips()')));
  });
});

describe('family trip board', () => {
  test('shows companion names to family', async () => {
    const rows = await probeAsUser(ids.viewer, (db) =>
      db.query('select * from public.family_trip_board($1)', [ids.patient]));
    const scheduled = rows.find((r) => r.primary_companion_name !== null);
    assert.ok(scheduled, 'expected at least one trip generated from the schedule');
    assert.equal(scheduled.companion_name, 'Asha Companion (synthetic)');
    assert.equal(scheduled.primary_companion_name, 'Asha Companion (synthetic)');
    assert.equal(scheduled.backup_companion_name, 'Ravi Companion (synthetic)');
  });

  test('denies strangers and companions', async () => {
    for (const user of [stranger, ids.asha]) {
      await expectPgError(probeAsUser(user, (db) =>
        db.query('select * from public.family_trip_board($1)', [ids.patient])));
    }
  });
});

describe('assignment rules', () => {
  test('only ops can assign companions', async () => {
    await expectPgError(probeAsUser(ids.owner, (db) =>
      db.query('select public.ops_assign_schedule_companions($1, $2, $3)', [ids.schedule, ids.ravi, ids.asha])));
  });

  test('rejects a companion outside the cluster radius', async () => {
    await expectPgError(probeAsUser(ids.ops, (db) =>
      db.query('select public.ops_assign_schedule_companions($1, $2, $3)',
        [ids.schedule, ids.farCompanion, ids.asha])), 'P0001');
  });

  test('rejects an unverified companion', async () => {
    await expectPgError(probeAsUser(ids.ops, (db) =>
      db.query('select public.ops_assign_schedule_companions($1, $2, $3)',
        [ids.schedule, ids.pendingCompanion, ids.asha])), 'P0001');
  });

  test('rejects the same companion as primary and backup', async () => {
    await expectPgError(probeAsUser(ids.ops, (db) =>
      db.query('select public.ops_assign_schedule_companions($1, $2, $3)', [ids.schedule, ids.asha, ids.asha])),
    '22023');
  });

  test('swapping primary and backup moves future unstarted trips to the new primary', async () => {
    const moved = await probeAsUser(ids.ops, async (db) => {
      await db.query('select public.ops_assign_schedule_companions($1, $2, $3)', [ids.schedule, ids.ravi, ids.asha]);
      return db.query<{ companion_id: string }>(
        `select distinct companion_id from public.trips
         where schedule_id = $1 and status = 'scheduled' and scheduled_pickup_at > now()`, [ids.schedule]);
    });
    assert.deepEqual(moved.map((r) => r.companion_id), [ids.ravi]);
  });
});

describe('trip generation', () => {
  test('generates Mon/Wed/Fri at 07:00 IST and is idempotent', async () => {
    const rows = await asAdmin((db) => db.query<{ dow: number; local_time: string }>(
      `select extract(isodow from scheduled_pickup_at at time zone 'Asia/Kolkata')::int as dow,
              to_char(scheduled_pickup_at at time zone 'Asia/Kolkata', 'HH24:MI') as local_time
       from public.trips where schedule_id = $1`, [ids.schedule]));
    assert.ok(rows.length >= 6);
    assert.ok(rows.every((r) => [1, 3, 5].includes(r.dow) && r.local_time === '07:00'));
    const again = await probeAsUser(ids.ops, (db) =>
      db.query<{ n: number }>('select public.ops_generate_trips($1, current_date, 14) as n', [ids.schedule]));
    assert.equal(again[0].n, 0);
  });

  test('family cannot generate trips', async () => {
    await expectPgError(probeAsUser(ids.owner, (db) =>
      db.query('select public.ops_generate_trips($1)', [ids.schedule])));
  });
});
