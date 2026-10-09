// Ops console read models (migration 0500). Each RPC: ops allowed, every other
// role denied. Tests create their own trips and filter by id, so they also run
// on a shared real Supabase database where other tests commit data.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, asUser, createTrip, createUser, expectPgError, ids, probeAsAnon, probeAsUser } from './support/db.ts';

const stranger = '20000000-0000-0000-0000-0000000000fe';
const nonOps = [ids.owner, ids.viewer, ids.asha];

// A trip that belongs to the seed schedule (so it has a primary and backup).
async function createScheduledTrip(pickupInMinutes: number, companionId: string | null = ids.asha): Promise<string> {
  return asAdmin(async (db) => {
    const [row] = await db.query<{ id: string }>(
      `insert into public.trips (schedule_id, patient_id, centre_id, companion_id, scheduled_pickup_at, scheduled_return_at)
       values ($1, $2, $3, $4, date_trunc('second', now()) + make_interval(mins => $5::int),
               date_trunc('second', now()) + make_interval(mins => $5::int + 300))
       returning id`,
      [ids.schedule, ids.patient, ids.centre, companionId, pickupInMinutes],
    );
    return row.id;
  });
}

async function advance(userId: string, tripId: string, to: string, note: string | null = null): Promise<void> {
  await asUser(userId, (db) => db.query('select public.advance_trip($1, $2::public.trip_status, $3)', [tripId, to, note]));
}

const board = (db: { query: (sql: string, params?: unknown[]) => Promise<Record<string, unknown>[]> }, statuses: string[] | null = null) =>
  db.query(`select * from public.ops_trip_board(now() - interval '2 days', now() + interval '14 days', $1::public.trip_status[])`,
    [statuses && `{${statuses.join(',')}}`]);

describe('ops schedule board', () => {
  test('ops sees the weekly pattern with primary and backup names', async () => {
    const rows = await probeAsUser(ids.ops, (db) => db.query('select * from public.ops_schedule_board()'));
    const row = rows.find((r) => r.schedule_id === ids.schedule);
    assert.ok(row);
    assert.equal(row.patient_name, 'Lakshmi Rao (synthetic)');
    assert.equal(row.primary_companion_name, 'Asha Companion (synthetic)');
    assert.equal(row.backup_companion_name, 'Ravi Companion (synthetic)');
    assert.deepEqual(row.days_of_week, [1, 3, 5]);
    assert.ok((row.upcoming_trips as number) > 0);
    assert.ok(!('date_of_birth' in row));
  });

  test('family, companions and strangers are denied', async () => {
    await createUser(stranger);
    for (const user of [...nonOps, stranger]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.ops_schedule_board()')));
    }
  });
});

describe('ops trip board', () => {
  test('lists trips in range with companion, primary and backup', async () => {
    const tripId = await createScheduledTrip(120);
    const rows = await probeAsUser(ids.ops, (db) => board(db));
    const row = rows.find((r) => r.trip_id === tripId);
    assert.ok(row);
    assert.equal(row.status, 'scheduled');
    assert.equal(row.companion_name, 'Asha Companion (synthetic)');
    assert.equal(row.backup_companion_id, ids.ravi);
    assert.equal(row.is_late, false);
  });

  test('filters by status', async () => {
    const cancelled = await createTrip(180);
    await advance(ids.ops, cancelled, 'cancelled', 'synthetic cancel');
    const rows = await probeAsUser(ids.ops, (db) => board(db, ['cancelled']));
    assert.ok(rows.some((r) => r.trip_id === cancelled));
    assert.ok(rows.every((r) => r.status === 'cancelled'));
  });

  test('flags a scheduled trip whose pickup time has passed as late', async () => {
    const late = await createTrip(-30);
    const rows = await probeAsUser(ids.ops, (db) => board(db));
    assert.equal(rows.find((r) => r.trip_id === late)?.is_late, true);
  });

  test('rejects an inverted or too-wide date range', async () => {
    await expectPgError(probeAsUser(ids.ops, (db) =>
      db.query(`select * from public.ops_trip_board(now(), now() - interval '1 day')`)), '22023');
    await expectPgError(probeAsUser(ids.ops, (db) =>
      db.query(`select * from public.ops_trip_board(now(), now() + interval '365 days')`)), '22023');
  });

  test('family and companions are denied', async () => {
    for (const user of nonOps) {
      await expectPgError(probeAsUser(user, (db) => board(db)));
    }
  });
});

describe('ops exception queue', () => {
  test('contains late, no_show and issue_reported trips with the latest note', async () => {
    const late = await createScheduledTrip(-20);
    const noShow = await createTrip(-10);
    await advance(ids.asha, noShow, 'no_show', 'nobody answered the door (synthetic)');
    const issue = await createTrip(15);
    await advance(ids.asha, issue, 'companion_en_route');
    await advance(ids.asha, issue, 'issue_reported', 'auto broke down (synthetic)');
    const upcoming = await createTrip(240);

    const rows = await probeAsUser(ids.ops, (db) => db.query('select * from public.ops_exception_queue()'));
    const byId = new Map(rows.map((r) => [r.trip_id, r]));
    assert.equal(byId.get(late)?.kind, 'late');
    assert.equal(byId.get(late)?.backup_companion_name, 'Ravi Companion (synthetic)');
    assert.equal(byId.get(noShow)?.kind, 'no_show');
    assert.equal(byId.get(noShow)?.last_note, 'nobody answered the door (synthetic)');
    assert.equal(byId.get(issue)?.kind, 'issue_reported');
    assert.equal(byId.get(issue)?.status_before_issue, 'companion_en_route');
    assert.equal(byId.get(issue)?.last_note, 'auto broke down (synthetic)');
    assert.ok(!byId.has(upcoming), 'an upcoming scheduled trip is not an exception');
  });

  test('the late threshold is a business setting, not code', async () => {
    const trip = await createTrip(-5);
    const inQueue = async () => (await probeAsUser(ids.ops, (db) =>
      db.query('select trip_id from public.ops_exception_queue()'))).some((r) => r.trip_id === trip);
    assert.equal(await inQueue(), true);
    await asAdmin((db) => db.query(`update public.app_settings set value = '15' where key = 'ops_late_after_minutes'`));
    try {
      assert.equal(await inQueue(), false);
    } finally {
      await asAdmin((db) => db.query(`update public.app_settings set value = '0' where key = 'ops_late_after_minutes'`));
    }
  });

  test('resolving an issue removes it from the queue', async () => {
    const issue = await createTrip(25);
    await advance(ids.asha, issue, 'companion_en_route');
    await advance(ids.asha, issue, 'issue_reported', 'synthetic issue');
    await advance(ids.ops, issue, 'companion_en_route', 'resolved by ops (synthetic)');
    const rows = await probeAsUser(ids.ops, (db) => db.query('select trip_id from public.ops_exception_queue()'));
    assert.ok(!rows.some((r) => r.trip_id === issue));
  });

  test('family and companions are denied', async () => {
    for (const user of nonOps) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.ops_exception_queue()')));
    }
  });
});

describe('ops companion options', () => {
  test('explains why each companion in the cluster is or is not eligible', async () => {
    const rows = await probeAsUser(ids.ops, (db) =>
      db.query('select * from public.ops_companion_options($1)', [ids.patient]));
    const byId = new Map(rows.map((r) => [r.companion_id, r]));
    assert.equal(byId.get(ids.asha)?.eligible, true);
    assert.equal(byId.get(ids.ravi)?.eligible, true);
    assert.equal(byId.get(ids.farCompanion)?.reason, 'outside_radius');
    assert.equal(byId.get(ids.pendingCompanion)?.reason, 'not_verified');
    assert.ok((byId.get(ids.farCompanion)?.distance_m as number) > (byId.get(ids.farCompanion)?.radius_m as number));
  });

  test('agrees with the assignment RPC for every companion', async () => {
    const tripId = await createTrip(300, null);
    const options = await probeAsUser(ids.ops, (db) =>
      db.query<{ companion_id: string; eligible: boolean }>('select * from public.ops_companion_options($1)', [ids.patient]));
    assert.ok(options.length >= 4);
    for (const option of options) {
      let assigned = true;
      try {
        await probeAsUser(ids.ops, (db) => db.query('select public.ops_assign_trip_companion($1, $2)', [tripId, option.companion_id]));
      } catch (error) {
        assert.equal((error as { code?: string }).code, 'P0001');
        assigned = false;
      }
      assert.equal(assigned, option.eligible, `companion ${option.companion_id}`);
    }
  });

  test('family and companions are denied', async () => {
    for (const user of nonOps) {
      await expectPgError(probeAsUser(user, (db) =>
        db.query('select * from public.ops_companion_options($1)', [ids.patient])));
    }
  });
});

test('anon cannot call any ops console function', async () => {
  for (const sql of [
    'select * from public.ops_schedule_board()',
    `select * from public.ops_trip_board(now(), now() + interval '1 day')`,
    'select * from public.ops_exception_queue()',
    `select * from public.ops_companion_options('${ids.patient}')`,
  ]) {
    await expectPgError(probeAsAnon((db) => db.query(sql)));
  }
});
