import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, expectPgError, ids, probeAsAnon, probeAsUser, type Db } from './support/db.ts';

const change = (db: Db, schedule: string, days: number[], expected = [1, 3, 5]) =>
  db.query<{ result: { cancelled: number; generated: number } }>(
    'select public.ops_update_schedule_pattern($1, $2::smallint[], $3::smallint[]) as result',
    [schedule, `{${days.join(',')}}`, `{${expected.join(',')}}`],
  );

async function fixture() {
  return asAdmin(async (db) => {
    const [{ id }] = await db.query<{ id: string }>(
      `insert into public.schedules (patient_id, package_id, days_of_week, pickup_time, primary_companion_id,
       backup_companion_id, starts_on) values ($1, $2, '{1,3,5}', '07:00', $3, $4,
       (now() at time zone 'Asia/Kolkata')::date) returning id`,
      [ids.patient, ids.basicPackage, ids.asha, ids.ravi],
    );
    return id;
  });
}

describe('weekly visit pattern', () => {
  test('ops replaces removed weekdays, preserves matching IDs, and audits/notifies cancellations', async () => {
    const schedule = await fixture();
    await probeAsUser(ids.ops, async (db) => {
      await db.query('select public.ops_generate_trips($1, (now() at time zone \'Asia/Kolkata\')::date, 28)', [schedule]);
      const before = await db.query<{ id: string; dow: number }>(
        `select id, extract(isodow from scheduled_pickup_at at time zone 'Asia/Kolkata')::int as dow
         from public.trips where schedule_id = $1 and scheduled_pickup_at > now()`, [schedule]);
      const [{ result }] = await change(db, schedule, [2, 5]);
      assert.equal(result.cancelled, before.filter((t) => t.dow !== 5).length);
      assert.ok(result.generated > 0);
      const after = await db.query<{ id: string; dow: number; status: string }>(
        `select id, status, extract(isodow from scheduled_pickup_at at time zone 'Asia/Kolkata')::int as dow
         from public.trips where schedule_id = $1 and scheduled_pickup_at > now()`, [schedule]);
      assert.ok(after.filter((t) => t.status === 'scheduled').every((t) => [2, 5].includes(t.dow)));
      for (const trip of before) {
        assert.equal(after.find((t) => t.id === trip.id)?.status, trip.dow === 5 ? 'scheduled' : 'cancelled');
      }
      const events = await db.query(`select * from public.trip_events where trip_id = any($1::uuid[]) and to_status = 'cancelled'`,
        [`{${before.filter((t) => t.dow !== 5).map((t) => t.id).join(',')}}`]);
      assert.equal(events.length, result.cancelled);
      const notifications = await db.query(`select * from public.notifications where trip_id = any($1::uuid[])`,
        [`{${before.filter((t) => t.dow !== 5).map((t) => t.id).join(',')}}`]);
      assert.ok(notifications.length >= result.cancelled * 2);
      const audits = await db.query(`select * from public.audit_log where action = 'update_schedule_pattern' and record_id = $1`, [schedule]);
      assert.equal(audits.length, 1);
    });
  });

  test('family owner/viewer, both companions and anon cannot replace the routine', async () => {
    const schedule = await fixture();
    for (const user of [ids.owner, ids.viewer, ids.asha, ids.ravi, '20000000-0000-0000-0000-00000000ffff']) {
      await expectPgError(probeAsUser(user, (db) => change(db, schedule, [2, 4])));
    }
    await expectPgError(probeAsAnon((db) => change(db, schedule, [2, 4])));
    await expectPgError(probeAsUser('20000000-0000-0000-0000-00000000ffff', (db) =>
      db.query('select public.ops_generate_trips($1)', [schedule])));
  });

  test('rejects empty, duplicate, out-of-range and more than four weekdays', async () => {
    const schedule = await fixture();
    for (const days of [[], [1, 1], [0], [8], [1, 2, 3, 4, 5]]) {
      await expectPgError(probeAsUser(ids.ops, (db) => change(db, schedule, days)), '22023');
    }
  });

  test('rejects null weekdays, paused/expired schedules and stale edits without changing the pattern', async () => {
    const schedule = await fixture();
    await expectPgError(probeAsUser(ids.ops, (db) => db.query(
      "select public.ops_update_schedule_pattern($1, '{1,NULL}'::smallint[], '{1,3,5}'::smallint[])", [schedule])), '22023');
    await expectPgError(probeAsUser(ids.ops, (db) => change(db, schedule, [2], [1, 5])), '40001');
    await probeAsUser(ids.ops, async (db) => {
      await db.query('update public.schedules set active = false where id = $1', [schedule]);
      await expectPgError(change(db, schedule, [2]), '22023');
    });
    await asAdmin((db) => db.query(`update public.schedules set starts_on = current_date - 3, ends_on = current_date - 2 where id = $1`, [schedule]));
    await expectPgError(probeAsUser(ids.ops, (db) => change(db, schedule, [2])), '22023');
  });

  test('does not cancel any started state, terminal visit or overdue scheduled visit', async () => {
    const schedule = await fixture();
    const states = ['companion_en_route', 'picked_up', 'at_centre', 'handed_over', 'session_done',
      'returning', 'dropped_home', 'issue_reported', 'completed', 'no_show', 'cancelled', 'scheduled'];
    await asAdmin(async (db) => {
      for (let i = 0; i < states.length; i++) {
        await db.query(`insert into public.trips (schedule_id, patient_id, centre_id, companion_id,
          scheduled_pickup_at, scheduled_return_at, status, post_visit_note)
          values ($1, $2, $3, $4, now() + make_interval(mins => $5::int),
          now() + make_interval(mins => $5::int + 300), $6::public.trip_status, 'synthetic retained note')`,
          [schedule, ids.patient, ids.centre, ids.ravi, i === states.length - 1 ? -30 : 60 + i, states[i]]);
      }
    });
    await probeAsUser(ids.ops, async (db) => {
      const before = await db.query('select id, status, companion_id, post_visit_note from public.trips where schedule_id = $1 order by id', [schedule]);
      await change(db, schedule, [2]);
      const after = await db.query('select id, status, companion_id, post_visit_note from public.trips where id = any($1::uuid[]) order by id',
        [`{${before.map((t) => t.id).join(',')}}`]);
      assert.deepEqual(after, before);
    });
  });

  test('remove/re-add creates a new booking with intact cancellation history; retry creates nothing', async () => {
    const schedule = await fixture();
    await probeAsUser(ids.ops, async (db) => {
      await change(db, schedule, [1, 3, 5]);
      await change(db, schedule, [2, 4]);
      const [{ result }] = await change(db, schedule, [1, 3, 5], [2, 4]);
      assert.ok(result.generated > 0);
      const duplicates = await db.query(`select scheduled_pickup_at from public.trips
        where schedule_id = $1 and status <> 'cancelled' group by scheduled_pickup_at having count(*) > 1`, [schedule]);
      assert.equal(duplicates.length, 0);
      const again = await change(db, schedule, [1, 3, 5]);
      assert.deepEqual(again[0].result, { cancelled: 0, generated: 0 });
      const cancelled = await db.query(`select id from public.trips where schedule_id = $1 and status = 'cancelled'`, [schedule]);
      assert.ok(cancelled.length > 0);
    });
  });

  test('keeps individual cancellations and the existing generator never rebooks a cancelled visit', async () => {
    const schedule = await fixture();
    await probeAsUser(ids.ops, async (db) => {
      await change(db, schedule, [1, 3, 5]);
      const [trip] = await db.query<{ id: string; scheduled_pickup_at: string }>(
        `select id, scheduled_pickup_at from public.trips where schedule_id = $1 and status = 'scheduled'
         and scheduled_pickup_at > now() order by scheduled_pickup_at limit 1`, [schedule]);
      // Even an individual cancellation using the editor's exact display reason
      // must stay cancelled. Audit provenance, not free text, identifies routine changes.
      await db.query("select public.advance_trip($1, 'cancelled', 'Cancelled because weekly schedule changed.')", [trip.id]);
      await change(db, schedule, [2, 4]);
      await change(db, schedule, [1, 3, 5], [2, 4]);
      await db.query('select public.ops_generate_trips($1, (now() at time zone \'Asia/Kolkata\')::date, 28)', [schedule]);
      const sameSlot = await db.query('select id, status from public.trips where schedule_id = $1 and scheduled_pickup_at = $2', [schedule, trip.scheduled_pickup_at]);
      assert.deepEqual(sameSlot, [{ id: trip.id, status: 'cancelled' }]);
    });
  });

  test('an insertion failure rolls back the pattern, cancellations, events and notifications together', async () => {
    const schedule = await fixture();
    await asAdmin(async (db) => {
      await db.query(`insert into public.trips (schedule_id, patient_id, centre_id, scheduled_pickup_at, scheduled_return_at)
        values ($1, $2, $3, (date_trunc('week', now() at time zone 'Asia/Kolkata') + interval '7 days 7 hours') at time zone 'Asia/Kolkata',
        (date_trunc('week', now() at time zone 'Asia/Kolkata') + interval '7 days 12 hours') at time zone 'Asia/Kolkata')`,
        [schedule, ids.patient, ids.centre]);
      await db.exec(`create function public.weekly_pattern_test_reject_insert() returns trigger language plpgsql as $$
        begin raise exception 'synthetic insertion failure' using errcode = 'P0001'; end; $$;
        create trigger weekly_pattern_test_reject_insert before insert on public.trips
        for each row when (new.schedule_id = '${schedule}'::uuid) execute function public.weekly_pattern_test_reject_insert();`);
    });
    try {
      await probeAsUser(ids.ops, async (db) => {
        const before = await db.query('select id, status from public.trips where schedule_id = $1', [schedule]);
        await db.exec('savepoint before_pattern');
        await expectPgError(change(db, schedule, [2]), 'P0001');
        await db.exec('rollback to savepoint before_pattern');
        assert.deepEqual(await db.query('select id, status from public.trips where schedule_id = $1', [schedule]), before);
        assert.deepEqual(await db.query('select days_of_week from public.schedules where id = $1', [schedule]), [{ days_of_week: [1, 3, 5] }]);
        assert.deepEqual(await db.query('select id from public.trip_events where trip_id = $1', [before[0].id]), []);
        assert.deepEqual(await db.query('select id from public.notifications where trip_id = $1', [before[0].id]), []);
      });
    } finally {
      await asAdmin((db) => db.exec('drop trigger weekly_pattern_test_reject_insert on public.trips; drop function public.weekly_pattern_test_reject_insert();'));
    }
  });

  test('a booking that becomes past during the transaction is preserved', async () => {
    const schedule = await fixture();
    const [trip] = await asAdmin((db) => db.query<{ id: string; dow: number }>(
      `insert into public.trips (schedule_id, patient_id, centre_id, scheduled_pickup_at, scheduled_return_at)
       values ($1, $2, $3, clock_timestamp() + interval '1 second', clock_timestamp() + interval '301 seconds')
       returning id, extract(isodow from scheduled_pickup_at at time zone 'Asia/Kolkata')::int as dow`,
      [schedule, ids.patient, ids.centre]));
    await probeAsUser(ids.ops, async (db) => {
      const [{ future }] = await db.query<{ future: boolean }>('select scheduled_pickup_at > now() as future from public.trips where id = $1', [trip.id]);
      assert.equal(future, true);
      await db.query('select pg_sleep(1.1)');
      await change(db, schedule, [trip.dow % 7 + 1]);
      assert.deepEqual(await db.query('select status from public.trips where id = $1', [trip.id]), [{ status: 'scheduled' }]);
    });
  });
});
