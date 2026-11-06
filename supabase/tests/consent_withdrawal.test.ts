import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, asUser, createTrip, expectPgError, ids, probeAsUser } from './support/db.ts';
import { actorConnection, waitForLock } from './support/concurrent.ts';

const consent = (active: boolean) => asUser(ids.owner, (db) =>
  db.query("select public.set_consent($1,'trips',$2)", [ids.patient, active]));
const details = (trip: string) => probeAsUser(ids.asha, (db) =>
  db.query('select * from public.companion_my_trips() where trip_id=$1', [trip]));
const start = (trip: string) => asUser(ids.asha, (db) =>
  db.query("select * from public.advance_trip($1,'companion_en_route')", [trip]));

describe('trip consent withdrawal', () => {
  test('a concurrent start waits for withdrawal and observes its committed result', { skip: !process.env.DATABASE_URL }, async () => {
    const trip = await createTrip(25);
    const owner = await actorConnection(ids.owner);
    const companion = await actorConnection(ids.asha);
    let pending: Promise<unknown> | undefined;
    try {
      await owner.query("select public.set_consent($1,'trips',false)", [ids.patient]);
      const { rows: [{ pid }] } = await companion.query('select pg_backend_pid() as pid');
      // Attach the rejection assertion before releasing the owner transaction.
      pending = expectPgError(companion.query("select public.advance_trip($1,'companion_en_route')", [trip]));
      await waitForLock(owner, pid);
      await owner.query('commit');
      await pending;
      await companion.query('rollback');
    } finally {
      await owner.query('rollback');
      await companion.query('rollback');
      await owner.end();
      await companion.end();
      await consent(true);
    }
  });

  test('same identity loses projection fields, direct rows/events and start; restoration restores access', async () => {
    const trip = await createTrip(25);
    await consent(true);
    assert.equal((await details(trip))[0].details_visible, true);
    try {
      await consent(false);
      const [masked] = await details(trip);
      assert.equal(masked.details_visible, false);
      for (const field of ['patient_name', 'home_address', 'home_lat', 'home_lng', 'mobility_notes', 'emergency_contacts']) {
        assert.equal(masked[field], null, field);
      }
      for (const table of ['trips', 'trip_events']) {
        const key = table === 'trips' ? 'id' : 'trip_id';
        const rows = await probeAsUser(ids.asha, (db) => db.query(`select * from public.${table} where ${key}=$1`, [trip]));
        assert.equal(rows.length, 0, table);
      }
      await expectPgError(start(trip));
      for (const user of [ids.owner, ids.viewer, ids.ops]) {
        const rows = await probeAsUser(user, (db) => db.query('select id from public.trips where id=$1', [trip]));
        assert.equal(rows.length, 1, 'separately authorized history retained');
      }
      await consent(true);
      assert.equal((await details(trip))[0].details_visible, true);
      assert.equal((await start(trip))[0].status, 'companion_en_route');
    } finally { await consent(true); }
  });

  test('withdrawal blocks issued pickup code without consuming it; restoration permits pickup', async () => {
    const trip = await createTrip(25);
    await start(trip);
    const [{ code }] = await asUser(ids.owner, (db) => db.query<{ code: string }>('select public.issue_pickup_otp($1) as code', [trip]));
    try {
      await consent(false);
      await expectPgError(asUser(ids.asha, (db) => db.query('select public.verify_pickup_otp($1,$2)', [trip, 'incorrect-code'])));
      await expectPgError(asUser(ids.asha, (db) => db.query('select public.verify_pickup_otp($1,$2)', [trip, code])));
      const [otp] = await asAdmin((db) => db.query('select consumed_at,attempts from public.trip_otps where trip_id=$1', [trip]));
      assert.equal(otp.consumed_at, null);
      assert.equal(otp.attempts, 0);
      await consent(true);
      const [{ result }] = await asUser(ids.asha, (db) => db.query<{ result: { ok: boolean } }>(
        'select public.verify_pickup_otp($1,$2) as result', [trip, code]));
      assert.equal(result.ok, true);
    } finally { await consent(true); }
  });

  test('withdrawal blocks underway check-ins; Ops cancellation and Family history remain available', async () => {
    const trip = await createTrip(25);
    await start(trip);
    try {
      await consent(false);
      await expectPgError(asUser(ids.asha, (db) => db.query("select * from public.advance_trip($1,'issue_reported','synthetic')", [trip])));
      await probeAsUser(ids.viewer, async (db) => {
        await db.query("insert into public.consents(user_id,patient_id,purpose) values($1,$2,'trips')", [ids.viewer, ids.patient]);
        const [row] = await db.query('select * from public.family_consents($1) where purpose=\'trips\'', [ids.patient]);
        assert.equal(row.active, false, 'non-owner consent cannot restore service');
      });
      const [cancelled] = await asUser(ids.ops, (db) => db.query("select * from public.advance_trip($1,'cancelled','Consent withdrawn')", [trip]));
      assert.equal(cancelled.status, 'cancelled');
    } finally { await consent(true); }
  });
});
