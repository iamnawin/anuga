// Trip controls (migration 20261022000100): F02 training and suspension, F04
// companion reads limited to the detail window, F05 start window, F06 required
// notes. Each rule has an allowed and a denied case. Companion flags changed here
// are restored in `finally` because every file shares one database.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, asUser, createTrip, expectPgError, ids, probeAsUser } from './support/db.ts';

async function setCompanion(id: string, fields: { training?: boolean; active?: boolean; status?: string }): Promise<void> {
  await asAdmin((db) => db.query(
    `update public.companions set
       training_completed = coalesce($2, training_completed),
       active = coalesce($3, active),
       verification_status = coalesce($4::public.verification_status, verification_status)
     where id = $1`,
    [id, fields.training ?? null, fields.active ?? null, fields.status ?? null],
  ));
}

const restoreRavi = () => setCompanion(ids.ravi, { training: true, active: true, status: 'verified' });

async function advance(userId: string, tripId: string, to: string, note: string | null = null) {
  return asUser(userId, (db) => db.query('select public.advance_trip($1, $2::public.trip_status, $3)', [tripId, to, note]));
}

async function setStatus(tripId: string, status: string): Promise<void> {
  await asAdmin((db) => db.query('update public.trips set status = $2::public.trip_status where id = $1', [tripId, status]));
}

describe('F02 companion training and suspension', () => {
  test('a trained companion can be assigned; an untrained one is refused and shown as not_trained', async () => {
    const trip = await createTrip(60, null);
    await asUser(ids.ops, (db) => db.query('select public.ops_assign_trip_companion($1, $2)', [trip, ids.ravi]));

    const other = await createTrip(60, null);
    try {
      await setCompanion(ids.ravi, { training: false });
      await expectPgError(
        asUser(ids.ops, (db) => db.query('select public.ops_assign_trip_companion($1, $2)', [other, ids.ravi])),
        'P0001',
      );
      const rows = await probeAsUser(ids.ops, (db) => db.query('select * from public.ops_companion_options($1)', [ids.patient]));
      const ravi = rows.find((r) => r.companion_id === ids.ravi);
      assert.equal(ravi?.eligible, false);
      assert.equal(ravi?.reason, 'not_trained');
    } finally {
      await restoreRavi();
    }
  });

  test('an active companion can start an assigned trip; a suspended or inactive one cannot', async () => {
    const trip = await createTrip(30, ids.ravi);
    try {
      await setCompanion(ids.ravi, { status: 'suspended' });
      await expectPgError(advance(ids.ravi, trip, 'companion_en_route'));
      await setCompanion(ids.ravi, { status: 'verified', active: false });
      await expectPgError(advance(ids.ravi, trip, 'companion_en_route'));
    } finally {
      await restoreRavi();
    }
    await advance(ids.ravi, trip, 'companion_en_route');
  });

  test('a suspended companion cannot verify a pickup code; ops can still cancel the trip', async () => {
    const trip = await createTrip(30, ids.ravi);
    await advance(ids.ravi, trip, 'companion_en_route');
    const [{ code }] = await asUser(ids.owner, (db) => db.query('select public.issue_pickup_otp($1) as code', [trip]));
    try {
      await setCompanion(ids.ravi, { status: 'suspended' });
      await expectPgError(asUser(ids.ravi, (db) => db.query('select public.verify_pickup_otp($1, $2)', [trip, code])));
      await advance(ids.ops, trip, 'cancelled');
    } finally {
      await restoreRavi();
    }
  });
});

describe('F05 companion start window', () => {
  test('a companion can start within the window but not 30 days early', async () => {
    const soon = await createTrip(60, ids.asha);
    await advance(ids.asha, soon, 'companion_en_route');

    const later = await createTrip(60 * 24 * 30, ids.asha);
    await expectPgError(advance(ids.asha, later, 'companion_en_route'), '22023');
  });

  test('the window comes from app_settings', async () => {
    const trip = await createTrip(240, ids.asha);
    await expectPgError(advance(ids.asha, trip, 'companion_en_route'), '22023');
    try {
      await asAdmin((db) => db.query(`update public.app_settings set value = '300' where key = 'companion_start_minutes_before'`));
      await advance(ids.asha, trip, 'companion_en_route');
    } finally {
      await asAdmin((db) => db.query(`update public.app_settings set value = '180' where key = 'companion_start_minutes_before'`));
    }
  });

  test('companion_my_trips says when Start opens, matching advance_trip', async () => {
    const early = await createTrip(240, ids.asha);
    const open = await createTrip(60, ids.asha);
    const rows = await probeAsUser(ids.asha, (db) => db.query<{ trip_id: string; start_allowed_at: Date; scheduled_pickup_at: Date }>(
      'select trip_id, start_allowed_at, scheduled_pickup_at from public.companion_my_trips() where trip_id = any($1)', [[early, open]]));
    assert.equal(rows.length, 2);
    for (const r of rows) {
      assert.equal(r.scheduled_pickup_at.getTime() - r.start_allowed_at.getTime(), 180 * 60_000);
    }
    const byId = new Map(rows.map((r) => [r.trip_id, r.start_allowed_at.getTime()]));
    assert.ok(byId.get(early)! > Date.now());
    await expectPgError(advance(ids.asha, early, 'companion_en_route'), '22023');
    assert.ok(byId.get(open)! <= Date.now());
    await advance(ids.asha, open, 'companion_en_route');
  });
});

describe('F06 required notes', () => {
  test('a companion completes with a note; null, empty and blank notes are refused', async () => {
    const trip = await createTrip(0, ids.asha);
    await setStatus(trip, 'dropped_home');
    for (const note of [null, '', '   ']) {
      await expectPgError(advance(ids.asha, trip, 'completed', note), '22023');
    }
    const [row] = await advance(ids.asha, trip, 'completed', 'Home safely, BP noted by centre');
    assert.ok(row);
    const [done] = await probeAsUser(ids.ops, (db) => db.query('select post_visit_note from public.trips where id = $1', [trip]));
    assert.equal(done.post_visit_note, 'Home safely, BP noted by centre');
  });

  test('reporting an issue needs a note', async () => {
    const trip = await createTrip(0, ids.asha);
    await advance(ids.asha, trip, 'companion_en_route');
    await expectPgError(advance(ids.asha, trip, 'issue_reported', ' '), '22023');
    await advance(ids.asha, trip, 'issue_reported', 'Patient not at home, calling family');
  });
});

describe('F04 companion reads limited to the detail window', () => {
  test('inside the window the companion reads trip and events; far ahead they read neither', async () => {
    const near = await createTrip(30, ids.asha);
    await advance(ids.asha, near, 'companion_en_route');
    const nearTrips = await probeAsUser(ids.asha, (db) => db.query('select id from public.trips where id = $1', [near]));
    const nearEvents = await probeAsUser(ids.asha, (db) => db.query('select note from public.trip_events where trip_id = $1', [near]));
    assert.equal(nearTrips.length, 1);
    assert.equal(nearEvents.length, 1);

    const far = await createTrip(60 * 24 * 30, ids.asha);
    await asAdmin((db) => db.query(
      `insert into public.trip_events (trip_id, from_status, to_status, actor_kind, note)
       values ($1, 'scheduled', 'scheduled', 'ops', 'Synthetic sensitive event note')`, [far]));
    const farTrips = await probeAsUser(ids.asha, (db) => db.query('select id from public.trips where id = $1', [far]));
    const farEvents = await probeAsUser(ids.asha, (db) => db.query('select note from public.trip_events where trip_id = $1', [far]));
    assert.equal(farTrips.length, 0);
    assert.equal(farEvents.length, 0);

    // companion_my_trips still lists the far trip, with details hidden.
    const mine = await probeAsUser(ids.asha, (db) => db.query(
      `select details_visible, patient_name from public.companion_my_trips(now(), now() + interval '40 days') where trip_id = $1`, [far]));
    assert.equal(mine[0]?.details_visible, false);
    assert.equal(mine[0]?.patient_name, null);
  });

  test('family viewers and ops still read the far trip and its events', async () => {
    const far = await createTrip(60 * 24 * 30, ids.asha);
    await asAdmin((db) => db.query(
      `insert into public.trip_events (trip_id, from_status, to_status, actor_kind, note)
       values ($1, 'scheduled', 'scheduled', 'ops', 'Visible to family and ops')`, [far]));
    for (const user of [ids.owner, ids.viewer, ids.ops]) {
      const events = await probeAsUser(user, (db) => db.query('select note from public.trip_events where trip_id = $1', [far]));
      assert.ok(events.some((e) => e.note === 'Visible to family and ops'), user);
    }
  });
});
