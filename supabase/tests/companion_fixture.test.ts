// Always a throwaway PGlite database: never runs fixture writes on DATABASE_URL.
import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';
import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';

const root = join(import.meta.dirname, '..');
const fixture = await readFile(join(root, 'seed/companion_trip_groups.sql'), 'utf8');
const cleanupPath = join(root, 'seed/companion_trip_groups_cleanup.sql');
const asha = '30000000-0000-0000-0000-000000000001';
const fixtureIds = [1, 2, 3].map((n) => `92000000-0000-0000-0000-00000000000${n}`);
let pg: PGlite;

before(async () => {
  pg = await PGlite.create({ extensions: { postgis } });
  await pg.exec(await readFile(join(root, 'tests/support/supabase_shim.sql'), 'utf8'));
  for (const file of (await readdir(join(root, 'migrations'))).filter((f) => f.endsWith('.sql')).sort()) {
    await pg.exec(await readFile(join(root, 'migrations', file), 'utf8'));
  }
  await pg.exec(await readFile(join(root, 'seed/seed.sql'), 'utf8'));
});
after(async () => { await pg?.close(); });

async function rollback(fn: () => Promise<void>) {
  await pg.exec('begin');
  try { await fn(); } finally { await pg.exec('rollback'); }
}

// Freeze only the fixture clock; the RPC itself remains the migrated implementation.
const at = (timestamp: string) => fixture.replaceAll(/\bnow\(\)/g, `'${timestamp}'::timestamptz`);

describe('synthetic companion grouping fixture (PGlite only)', () => {
  for (const clock of ['00:00:00', '21:59:59', '22:00:00', '23:59:00', '23:59:59.999999']) {
    test(`three IST groups remain in the RPC list window at ${clock}`, async () => rollback(async () => {
      const timestamp = `2026-10-31 ${clock}+05:30`;
      await pg.exec(at(timestamp));
      await pg.query("select set_config('request.jwt.claims', $1, true)", [JSON.stringify({ sub: asha, role: 'authenticated' })]);
      await pg.exec('set local role authenticated');
      const { rows } = await pg.query<{ trip_id: string; day: string }>(
        `select trip_id, to_char(scheduled_pickup_at at time zone 'Asia/Kolkata', 'YYYY-MM-DD') as day
         from public.companion_my_trips($1::timestamptz - interval '1 day', $1::timestamptz + interval '14 days')
         where trip_id::text like '92000000-%' order by scheduled_pickup_at`, [timestamp]);
      assert.deepEqual(rows, fixtureIds.map((trip_id, i) => ({ trip_id, day: ['2026-10-30', '2026-10-31', '2026-11-01'][i] })));
      const expired = await pg.query(
        `select trip_id from public.companion_my_trips('2026-11-01 00:00:00+05:30'::timestamptz - interval '1 day',
          '2026-11-15 00:00:00+05:30') where trip_id = $1`, [fixtureIds[0]]);
      assert.equal(expired.rows.length, 0, 'Previous expires at the next IST midnight');
    }));
  }

  test('reruns affect exactly three rows, preserve identities and appear through default RPC bounds', async () => rollback(async () => {
    await pg.exec(fixture);
    const before = await pg.query('select id, created_at from public.trips order by id');
    await pg.exec(fixture);
    assert.deepEqual((await pg.query('select id, created_at from public.trips order by id')).rows, before.rows);
    await pg.query("select set_config('request.jwt.claims', $1, true)", [JSON.stringify({ sub: asha, role: 'authenticated' })]);
    await pg.exec('set local role authenticated');
    const { rows } = await pg.query('select trip_id from public.companion_my_trips() where trip_id::text like \'92000000-%\'');
    assert.equal(rows.length, 3);
  }));

  for (const change of [
    "update public.patients set full_name = 'Real person'",
    "update auth.users set phone = '919111111111' where id = '20000000-0000-0000-0000-000000000001'",
    `update public.profiles set role = 'family' where id = '${asha}'`,
    `update auth.users set phone = '919000000299' where id = '${asha}'`,
  ]) {
    test(`refuses unsafe seed: ${change.split(' set ')[0]}`, async () => rollback(async () => {
      await pg.exec(change);
      await assert.rejects(pg.exec(fixture), /non-synthetic|synthetic companion Asha/);
    }));
  }

  test('refuses a fixed-ID collision assigned to another companion', async () => rollback(async () => {
    await pg.exec(fixture);
    await pg.query('update public.trips set companion_id = $1 where id = $2', ['30000000-0000-0000-0000-000000000002', fixtureIds[1]]);
    await assert.rejects(pg.exec(fixture), /fixture-owned/);
  }));

  test('a missing Previous ownership marker is refused', async () => rollback(async () => {
    await pg.exec(fixture);
    await pg.query('update public.trips set post_visit_note = null where id = $1', [fixtureIds[0]]);
    await assert.rejects(pg.exec(fixture), /fixture-owned/);
  }));

  test('cleanup refuses another companion at a reserved ID', async () => rollback(async () => {
    await pg.exec(fixture);
    await pg.query('update public.trips set companion_id = $1 where id = $2', ['30000000-0000-0000-0000-000000000002', fixtureIds[1]]);
    await assert.rejects(pg.exec(await readFile(cleanupPath, 'utf8')), /fixture-owned/);
  }));

  test('cleanup is repeatable and preserves an unrelated row with the same ID prefix', async () => rollback(async () => {
    await pg.exec(fixture);
    const other = '92000000-0000-0000-0000-000000000099';
    await pg.query(`insert into public.trips (id, patient_id, centre_id, companion_id, scheduled_pickup_at, scheduled_return_at)
      select $1, patient_id, centre_id, companion_id, scheduled_pickup_at, scheduled_return_at from public.trips where id = $2`, [other, fixtureIds[1]]);
    const cleanup = await readFile(cleanupPath, 'utf8');
    await pg.exec(cleanup);
    await pg.exec(cleanup);
    assert.equal((await pg.query('select id from public.trips where id = any($1::uuid[])', [fixtureIds])).rows.length, 0);
    assert.equal((await pg.query('select id from public.trips where id = $1', [other])).rows.length, 1);
  }));

  test('reruns refuse dependent workflow data instead of deleting it', async () => rollback(async () => {
    await pg.exec(fixture);
    await pg.query("insert into public.trip_events (trip_id, to_status) values ($1, 'scheduled')", [fixtureIds[1]]);
    await assert.rejects(pg.exec(fixture), /dependent/);
  }));

  test('cleanup refuses dependent workflow data', async () => rollback(async () => {
    await pg.exec(fixture);
    await pg.query("insert into public.trip_events (trip_id, to_status) values ($1, 'scheduled')", [fixtureIds[1]]);
    await assert.rejects(pg.exec(await readFile(cleanupPath, 'utf8')), /dependent/);
  }));
});
