import { after, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { asAdmin, asServiceRole, asUser, createTrip, createUser, expectPgError, ids, probeAsAnon, probeAsUser, type Db } from './support/db.ts';
import { render } from '../functions/notify-dispatch/messages.ts';

const editor = '20000000-0000-0000-0000-000000000081';
const patient = '20000000-0000-0000-0000-000000000082';
const stranger = '20000000-0000-0000-0000-000000000083';
const note = 'Private cancellation reason: synthetic diagnosis';
const cancel = (db: Db, trip: string) => db.query(
  "select public.advance_trip($1, 'cancelled', $2)", [trip, note]);
const notices = (db: Db, trip: string) => db.query<{
  id: number; recipient_id: string; channel: string; payload: Record<string, unknown>;
}>("select id, recipient_id, channel, payload from public.notifications where trip_id = $1 and template = 'trip_status_changed' and payload->>'to_status' = 'cancelled' order by id", [trip]);

async function accessUsers() {
  for (const [user, level] of [[editor, 'editor'], [patient, 'patient']] as const) {
    await createUser(user);
    await asAdmin((db) => db.query(`insert into public.patient_access (patient_id, user_id, access_level)
      values ($1, $2, $3::public.access_level) on conflict do nothing`, [ids.patient, user, level]));
  }
  await createUser(stranger);
}

describe('assigned companion cancellation notification', () => {
  after(async () => {
    await asAdmin((db) => db.query('delete from public.patient_access where patient_id = $1 and user_id in ($2, $3)', [ids.patient, editor, patient]));
  });

  test('owner/editor and Ops cancellations notify only the assigned companion with safe content', async () => {
    await accessUsers();
    const states = ['scheduled', 'companion_en_route', 'picked_up', 'at_centre', 'handed_over',
      'session_done', 'returning', 'dropped_home', 'issue_reported'];
    for (const [user, status] of [[ids.owner, 'scheduled'], [editor, 'scheduled'],
      ...states.map((s) => [ids.ops, s])] as [string, string][]) {
      const trip = await createTrip(60, ids.ravi);
      await asAdmin((db) => db.query('update public.trips set status = $2::public.trip_status where id = $1', [trip, status]));
      await asUser(user, (db) => cancel(db, trip));
      const rows = await asAdmin((db) => notices(db, trip));
      const companion = rows.filter((r) => r.recipient_id === ids.ravi);
      assert.equal(companion.length, 1, `${user}: ${status}`);
      assert.equal(companion[0].channel, 'push');
      assert.deepEqual(companion[0].payload, { trip_id: trip, to_status: 'cancelled' });
      assert.equal(rows.filter((r) => r.recipient_id === ids.asha).length, 0);
      for (const family of [ids.owner, ids.viewer, editor, patient]) {
        assert.deepEqual(rows.filter((r) => r.recipient_id === family).map((r) => r.channel).sort(), ['push', 'whatsapp']);
      }
      const events = await asAdmin((db) => db.query('select note from public.trip_events where trip_id = $1', [trip]));
      assert.deepEqual(events, [{ note }]);
      for (const [lang, body] of [['en', 'Visit cancelled'], ['te', 'సందర్శన రద్దు అయింది'], ['hi', 'विज़िट रद्द']]) {
        assert.equal(render('trip_status_changed', companion[0].payload, lang).body, body);
      }
    }
  });

  test('denied callers/states produce no cancellation, event or outbox row', async () => {
    await accessUsers();
    for (const user of [patient, ids.viewer, stranger, ids.asha, ids.ravi]) {
      const trip = await createTrip(60, ids.ravi);
      await expectPgError(probeAsUser(user, (db) => cancel(db, trip)), user === ids.ravi ? '22023' : '42501');
      assert.deepEqual(await asAdmin((db) => notices(db, trip)), []);
      assert.deepEqual(await asAdmin((db) => db.query('select status from public.trips where id = $1', [trip])), [{ status: 'scheduled' }]);
      assert.deepEqual(await asAdmin((db) => db.query('select id from public.trip_events where trip_id = $1', [trip])), []);
    }
    const trip = await createTrip(60);
    await expectPgError(probeAsAnon((db) => cancel(db, trip)));
    for (const status of ['completed', 'cancelled', 'no_show']) {
      await asAdmin((db) => db.query('update public.trips set status = $2::public.trip_status where id = $1', [trip, status]));
      await expectPgError(probeAsUser(ids.ops, (db) => cancel(db, trip)), '22023');
    }
    await asAdmin((db) => db.query("update public.trips set status = 'handed_over' where id = $1", [trip]));
    for (const user of [ids.owner, editor]) await expectPgError(probeAsUser(user, (db) => cancel(db, trip)), '22023');
    for (const user of [ids.owner, editor, ids.ops, patient, ids.viewer, stranger, ids.asha, ids.ravi]) {
      await expectPgError(probeAsUser(user, (db) => db.query(
        "select private.notify_user($1, $2, 'trip_status_changed', '{\"to_status\":\"cancelled\"}'::jsonb)", [trip, ids.ravi])));
      await expectPgError(probeAsUser(user, (db) => db.query(`insert into public.notifications (trip_id, recipient_id, channel, template, payload)
        values ($1, $2, 'push', 'trip_status_changed', '{"to_status":"cancelled"}')`, [trip, ids.ravi])));
    }
    assert.deepEqual(await asAdmin((db) => notices(db, trip)), []);
  });

  test('unassigned cancellation works, rollback is atomic, and retries retain the transition error', async () => {
    const unassigned = await createTrip(60, null);
    await asUser(ids.owner, (db) => cancel(db, unassigned));
    assert.ok((await asAdmin((db) => notices(db, unassigned))).every((r) => r.recipient_id !== ids.asha && r.recipient_id !== ids.ravi));
    const trip = await createTrip(60);
    await assert.rejects(asUser(ids.owner, async (db) => {
      await cancel(db, trip);
      throw new Error('abort request');
    }), /abort request/);
    assert.deepEqual(await asAdmin((db) => notices(db, trip)), []);
    assert.deepEqual(await asAdmin((db) => db.query('select status from public.trips where id = $1', [trip])), [{ status: 'scheduled' }]);
    assert.deepEqual(await asAdmin((db) => db.query('select id from public.trip_events where trip_id = $1', [trip])), []);
    await asUser(ids.owner, (db) => cancel(db, trip));
    await expectPgError(probeAsUser(ids.ops, (db) => cancel(db, trip)), '22023');
    assert.equal((await asAdmin((db) => notices(db, trip))).filter((r) => r.recipient_id === ids.asha).length, 1);
  });

  test('reassignment targets current worker, and delivery retries reuse the same outbox row', async () => {
    const trip = await createTrip(60);
    await asUser(ids.ops, (db) => db.query('select public.ops_assign_trip_companion($1, $2)', [trip, ids.ravi]));
    await asUser(ids.owner, (db) => cancel(db, trip));
    const rows = await asAdmin((db) => notices(db, trip));
    assert.equal(rows.filter((r) => r.recipient_id === ids.asha).length, 0);
    const companionRows = rows.filter((r) => r.recipient_id === ids.ravi);
    assert.equal(companionRows.length, 1);
    const [{ id }] = companionRows;
    await asServiceRole(async (db) => {
      const claimed = await db.query<{ notification_id: number }>('select * from public.dispatch_claim_notifications(10000)');
      assert.ok(claimed.some((r) => Number(r.notification_id) === Number(id)));
      await db.query("select public.dispatch_mark_failed($1, 'temporary transport failure', false)", [id]);
    });
    await asAdmin((db) => db.query('update public.notifications set next_attempt_at = now() where id = $1', [id]));
    await asServiceRole(async (db) => {
      const claimed = await db.query<{ notification_id: number; attempts: number }>('select * from public.dispatch_claim_notifications(10000)');
      assert.equal(claimed.find((r) => Number(r.notification_id) === Number(id))?.attempts, 2);
      await db.query("select public.dispatch_mark_sent($1, 'synthetic-cancel-delivery')", [id]);
    });
    assert.equal((await asAdmin((db) => notices(db, trip))).filter((r) => r.recipient_id === ids.ravi).length, 1);
  });

  test('unchanged PR #10 SQL coexists without duplicate notices or resurrecting individual cancellations', async () => {
    // Exact test-only snapshot from PR #10 c561a9d; no branch merge or production installation.
    const sql = await readFile(new URL('./fixtures/weekly_visit_pattern_pr10.sql', import.meta.url), 'utf8');
    await asAdmin(async (db) => {
      await db.exec('begin');
      try {
        await db.exec(sql);
        const [{ id: schedule }] = await db.query<{ id: string }>(`insert into public.schedules
          (patient_id, package_id, days_of_week, pickup_time, primary_companion_id, backup_companion_id, starts_on)
          values ($1, $2, '{1,3,5}', '07:00', $3, $4, current_date + 1) returning id`,
        [ids.patient, ids.basicPackage, ids.asha, ids.ravi]);
        await db.exec('set local role authenticated');
        await db.query("select set_config('request.jwt.claims', $1, true)", [JSON.stringify({ sub: ids.ops, role: 'authenticated' })]);
        await db.query('select public.ops_generate_trips($1, current_date + 1, 28)', [schedule]);
        const [{ id: individual }] = await db.query<{ id: string }>(
          'select id from public.trips where schedule_id = $1 order by scheduled_pickup_at limit 1', [schedule]);
        await cancel(db, individual);
        const change = (days: string, expected: string) => db.query(
          'select public.ops_update_schedule_pattern($1, $2::smallint[], $3::smallint[])', [schedule, days, expected]);
        await change('{2,4}', '{1,3,5}');
        const removed = await db.query<{ id: string }>("select id from public.trips where schedule_id = $1 and status = 'cancelled'", [schedule]);
        await change('{1,3,5}', '{2,4}');
        await change('{1,3,5}', '{1,3,5}');
        await db.exec('reset role');
        for (const { id } of removed) {
          assert.equal((await notices(db, id)).filter((r) => r.recipient_id === ids.asha).length, 1);
          const [{ status }] = await db.query('select status from public.trips where id = $1', [id]);
          assert.equal(status, 'cancelled');
        }
        const sameSlot = await db.query<{ id: string }>(`select id from public.trips where schedule_id = $1
          and scheduled_pickup_at = (select scheduled_pickup_at from public.trips where id = $2)`, [schedule, individual]);
        assert.deepEqual(sameSlot, [{ id: individual }]);
        assert.ok(removed.length > 1);
        const restored = await db.query(`select 1 from public.trips where schedule_id = $1 and status = 'scheduled'
          and extract(isodow from scheduled_pickup_at at time zone 'Asia/Kolkata') in (1,3,5)`, [schedule]);
        assert.ok(restored.length > 0);
      } finally {
        await db.exec('rollback');
      }
    });
  });

  test('only cancellation pushes deduplicate, including after the row is sent', async () => {
    const trip = await createTrip(60);
    await asUser(ids.owner, (db) => cancel(db, trip));
    await asAdmin(async (db) => {
      await db.query("update public.notifications set status = 'sent' where trip_id = $1 and recipient_id = $2", [trip, ids.asha]);
      await db.query("select private.notify_user($1, $2, 'trip_status_changed', jsonb_build_object('trip_id', $1::uuid, 'to_status', 'cancelled'))", [trip, ids.asha]);
      assert.equal((await notices(db, trip)).filter((r) => r.recipient_id === ids.asha).length, 1);
      for (let i = 0; i < 2; i++) {
        await db.query("select private.notify_user($1, $2, 'trip_assigned', '{}'::jsonb)", [trip, ids.asha]);
        await db.query("select private.notify_user($1, $2, 'trip_status_changed', '{\"to_status\":\"issue_reported\"}'::jsonb)", [trip, ids.asha]);
      }
      const [{ count }] = await db.query<{ count: number }>(`select count(*)::int as count from public.notifications
        where trip_id = $1 and recipient_id = $2 and not (template = 'trip_status_changed' and payload->>'to_status' = 'cancelled')`, [trip, ids.asha]);
      assert.equal(count, 4);
    });
  });

  test('concurrent committed cancellations produce one companion notice', { skip: !process.env.DATABASE_URL }, async () => {
    const trip = await createTrip(60);
    const { default: pg } = await import('pg');
    const clients = [new pg.Client({ connectionString: process.env.DATABASE_URL }), new pg.Client({ connectionString: process.env.DATABASE_URL })];
    try {
      await Promise.all(clients.map((c) => c.connect()));
      const results = await Promise.allSettled(clients.map(async (c) => {
        await c.query('begin');
        await c.query('set local role authenticated');
        await c.query("select set_config('request.jwt.claims', $1, true)", [JSON.stringify({ sub: ids.owner, role: 'authenticated' })]);
        await c.query("select public.advance_trip($1, 'cancelled')", [trip]);
        await c.query('commit');
      }));
      assert.equal(results.filter((r) => r.status === 'fulfilled').length, 1);
      const rejected = results.find((r) => r.status === 'rejected');
      assert.equal(rejected?.status === 'rejected' ? rejected.reason.code : null, '22023');
      assert.equal((await asAdmin((db) => notices(db, trip))).filter((r) => r.recipient_id === ids.asha).length, 1);
    } finally {
      await Promise.all(clients.map((c) => c.end()));
    }
  });
});
