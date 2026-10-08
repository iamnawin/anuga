// Family app read models (migration 0600): allowed and denied for each.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { asUser, createTrip, createUser, expectPgError, ids, probeAsAnon, probeAsUser } from './support/db.ts';

const stranger = '20000000-0000-0000-0000-0000000000fd';

async function advance(userId: string, tripId: string, to: string, note: string | null = null): Promise<void> {
  await asUser(userId, (db) => db.query('select public.advance_trip($1, $2::public.trip_status, $3)', [tripId, to, note]));
}

describe('family_my_patients', () => {
  test('returns each patient with the caller\'s own access level', async () => {
    const owner = await probeAsUser(ids.owner, (db) => db.query('select * from public.family_my_patients()'));
    assert.deepEqual(owner.map((r) => [r.patient_id, r.access_level]), [[ids.patient, 'owner']]);
    assert.equal(owner[0].full_name, 'Lakshmi Rao (synthetic)');
    assert.ok(!('date_of_birth' in owner[0]));
    const viewer = await probeAsUser(ids.viewer, (db) => db.query('select * from public.family_my_patients()'));
    assert.deepEqual(viewer.map((r) => r.access_level), ['viewer']);
  });

  test('a family account without access gets an empty list', async () => {
    await createUser(stranger);
    assert.deepEqual(await probeAsUser(stranger, (db) => db.query('select * from public.family_my_patients()')), []);
  });

  test('companions, ops and anon are denied', async () => {
    for (const user of [ids.asha, ids.ops]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.family_my_patients()')));
    }
    await expectPgError(probeAsAnon((db) => db.query('select * from public.family_my_patients()')));
  });
});

describe('family_trip_timeline', () => {
  test('family sees the status events oldest first, with notes but no locations', async () => {
    const tripId = await createTrip(30);
    await advance(ids.asha, tripId, 'companion_en_route', 'leaving now (synthetic)');
    await advance(ids.asha, tripId, 'issue_reported', 'traffic block (synthetic)');
    for (const user of [ids.owner, ids.viewer, ids.ops]) {
      const rows = await probeAsUser(user, (db) => db.query('select * from public.family_trip_timeline($1)', [tripId]));
      assert.deepEqual(rows.map((r) => [r.from_status, r.to_status, r.actor_kind, r.note]), [
        ['scheduled', 'companion_en_route', 'companion', 'leaving now (synthetic)'],
        ['companion_en_route', 'issue_reported', 'companion', 'traffic block (synthetic)'],
      ]);
      for (const hidden of ['location', 'actor_id']) assert.ok(!(hidden in rows[0]), hidden);
    }
  });

  test('strangers and companions are denied; unknown trips look the same as forbidden ones', async () => {
    const tripId = await createTrip(35);
    for (const user of [stranger, ids.asha]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.family_trip_timeline($1)', [tripId])));
    }
    await expectPgError(probeAsUser(ids.owner, (db) =>
      db.query('select * from public.family_trip_timeline($1)', ['00000000-0000-0000-0000-00000000dead'])));
  });
});

describe('my_notifications', () => {
  test('family inbox has one push row per status change, newest first', async () => {
    const tripId = await createTrip(40);
    await advance(ids.asha, tripId, 'companion_en_route');
    const rows = await probeAsUser(ids.viewer, (db) => db.query<{ notification_id: string; trip_id: string; template: string; payload: { to_status: string } }>(
      'select * from public.my_notifications()'));
    const mine = rows.filter((r) => r.trip_id === tripId);
    assert.equal(mine.length, 1, 'push only; the WhatsApp copy is not in the inbox');
    assert.equal(mine[0].template, 'trip_status_changed');
    assert.equal(mine[0].payload.to_status, 'companion_en_route');
    const order = rows.map((r) => Number(r.notification_id));
    assert.deepEqual(order, [...order].sort((a, b) => b - a));
  });

  test('each user sees only their own notifications', async () => {
    const tripId = await createTrip(45, null);
    await asUser(ids.ops, (db) => db.query('select public.ops_assign_trip_companion($1, $2)', [tripId, ids.ravi]));
    const ravi = await probeAsUser(ids.ravi, (db) => db.query('select * from public.my_notifications()'));
    assert.ok(ravi.some((r) => r.trip_id === tripId && r.template === 'trip_assigned'));
    const asha = await probeAsUser(ids.asha, (db) => db.query('select * from public.my_notifications()'));
    assert.ok(!asha.some((r) => r.trip_id === tripId));
    assert.deepEqual(await probeAsUser(stranger, (db) => db.query('select * from public.my_notifications()')), []);
  });

  test('the page size is clamped', async () => {
    const rows = await probeAsUser(ids.owner, (db) => db.query('select * from public.my_notifications(1)'));
    assert.equal(rows.length, 1);
    const capped = await probeAsUser(ids.owner, (db) => db.query('select * from public.my_notifications(100000)'));
    assert.ok(capped.length <= 200);
  });

  test('anon is denied', async () => {
    await expectPgError(probeAsAnon((db) => db.query('select * from public.my_notifications()')));
  });
});
