// Notification dispatch in the database (migration 0700) and the dispatcher end
// to end: a trip status change -> outbox rows -> test adapter -> delivered records.
// Other test files also create notifications, so assertions filter by this
// file's own rows; claiming other rows is harmless (a real dispatcher would too).
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, asServiceRole, asUser, createTrip, expectPgError, ids, probeAsAnon, probeAsUser } from './support/db.ts';
import { selectAdapters } from '../functions/notify-dispatch/adapters.ts';
import { drain, type ClaimedNotification, type DispatchStore } from '../functions/notify-dispatch/dispatcher.ts';
import type { DeliveryRecorder } from '../functions/notify-dispatch/adapters.ts';

// DispatchStore over SQL as the service role: the same RPCs the REST store calls.
const sqlStore: DispatchStore & DeliveryRecorder = {
  claim: (limit) => asServiceRole((db) =>
    db.query<ClaimedNotification & Record<string, unknown>>('select * from public.dispatch_claim_notifications($1)', [limit])),
  markSent: async (id, providerId) => {
    await asServiceRole((db) => db.query('select public.dispatch_mark_sent($1, $2)', [id, providerId]));
  },
  markFailed: async (id, error, permanent) => {
    const [r] = await asServiceRole((db) =>
      db.query<{ s: 'pending' | 'failed' }>('select public.dispatch_mark_failed($1, $2, $3) as s', [id, error, permanent]));
    return r.s;
  },
  recordDelivery: async (row) => {
    await asServiceRole((db) => db.query(
      `insert into public.notification_deliveries (notification_id, adapter, channel, recipient_id, language, title, body)
       values ($1, $2, $3, $4, $5, $6, $7)`,
      [row.notification_id, row.adapter, row.channel, row.recipient_id, row.language, row.title, row.body]));
  },
};

async function newNotification(): Promise<number> {
  const [row] = await asAdmin((db) => db.query<{ id: number }>(
    `insert into public.notifications (recipient_id, channel, template, payload)
     values ($1, 'push', 'trip_status_changed', '{"to_status": "completed"}') returning id`, [ids.owner]));
  return Number(row.id);
}

async function notification(id: number) {
  const [row] = await asAdmin((db) => db.query<{
    status: string; attempts: number; last_error: string | null; delay_s: number; leased: boolean;
  }>(`select status, attempts, last_error, extract(epoch from next_attempt_at - now())::int as delay_s,
             claimed_until > now() as leased
      from public.notifications where id = $1`, [id]));
  return row;
}

async function makeDue(id: number): Promise<void> {
  await asAdmin((db) => db.query('update public.notifications set next_attempt_at = now(), claimed_until = null where id = $1', [id]));
}

const claimAll = () => asServiceRole((db) =>
  db.query<{ notification_id: string }>('select notification_id from public.dispatch_claim_notifications(500)'));

describe('dispatch permissions', () => {
  test('app users and anon cannot drive the dispatcher or read deliveries', async () => {
    for (const user of [ids.owner, ids.asha, ids.ops]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.dispatch_claim_notifications(1)')));
      await expectPgError(probeAsUser(user, (db) => db.query('select public.dispatch_mark_sent(1)')));
      await expectPgError(probeAsUser(user, (db) => db.query(`select public.dispatch_mark_failed(1, 'x')`)));
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.notification_deliveries')));
    }
    await expectPgError(probeAsAnon((db) => db.query('select * from public.dispatch_claim_notifications(1)')));
  });

  test('the service role can claim', async () => {
    const id = await newNotification();
    const claimed = await claimAll();
    assert.ok(claimed.some((r) => Number(r.notification_id) === id));
  });
});

describe('claim, lease and retry', () => {
  test('a claimed row is leased: a second claim does not return it', async () => {
    const id = await newNotification();
    assert.ok((await claimAll()).some((r) => Number(r.notification_id) === id));
    assert.ok(!(await claimAll()).some((r) => Number(r.notification_id) === id));
    const row = await notification(id);
    assert.equal(row.attempts, 1);
    assert.equal(row.leased, true);
  });

  test('an expired lease is claimed again (a crashed worker does not lose the row)', async () => {
    const id = await newNotification();
    await claimAll();
    await asAdmin((db) => db.query(`update public.notifications set claimed_until = now() - interval '1 second' where id = $1`, [id]));
    assert.ok((await claimAll()).some((r) => Number(r.notification_id) === id));
    assert.equal((await notification(id)).attempts, 2);
  });

  test('transient failures back off exponentially, then fail after the attempt limit', async () => {
    const id = await newNotification();
    const delays: number[] = [];
    for (let attempt = 1; attempt <= 5; attempt++) {
      await makeDue(id);
      assert.ok((await claimAll()).some((r) => Number(r.notification_id) === id), `attempt ${attempt} claimed`);
      const status = await sqlStore.markFailed(id, `timeout ${attempt}`, false);
      const row = await notification(id);
      assert.equal(row.attempts, attempt);
      if (attempt < 5) {
        assert.equal(status, 'pending');
        delays.push(row.delay_s);
      } else {
        assert.equal(status, 'failed');
        assert.equal(row.status, 'failed');
        assert.equal(row.last_error, 'timeout 5');
      }
    }
    // 60 s, 120 s, 240 s, 480 s (app_settings notification_retry_base_seconds = 60).
    for (const [i, expected] of [60, 120, 240, 480].entries()) {
      assert.ok(Math.abs(delays[i] - expected) <= 2, `retry ${i + 1}: ${delays[i]}s, expected ~${expected}s`);
    }
  });

  test('a backed-off row is not claimed before its time', async () => {
    const id = await newNotification();
    await claimAll();
    await sqlStore.markFailed(id, 'timeout', false);
    assert.ok(!(await claimAll()).some((r) => Number(r.notification_id) === id));
  });

  test('permanent failures fail at once; finished rows cannot be marked again', async () => {
    const id = await newNotification();
    await claimAll();
    assert.equal(await sqlStore.markFailed(id, 'no phone', true), 'failed');
    await expectPgError(sqlStore.markSent(id, null), '22023');
    await expectPgError(sqlStore.markFailed(id, 'again', false), '22023');
  });
});

describe('dispatcher end to end (test adapter)', () => {
  test('a trip status change reaches every family member, in their language', async () => {
    await asAdmin((db) => db.query(`update public.profiles set preferred_language = 'te' where id = $1`, [ids.viewer]));
    try {
      const tripId = await createTrip(20);
      await asUser(ids.asha, (db) => db.query(`select public.advance_trip($1, 'companion_en_route', 'leaving now')`, [tripId]));
      const outbox = await asAdmin((db) => db.query<{ id: string }>(
        `select id from public.notifications where trip_id = $1 order by id`, [tripId]));
      assert.equal(outbox.length, 4, 'owner and viewer x push and whatsapp');

      const summary = await drain(sqlStore, selectAdapters({}, sqlStore), { limit: 500 });
      assert.ok(summary.sent >= 4);

      const rows = await asAdmin((db) => db.query<{
        status: string; channel: string; recipient_id: string; language: string; title: string; body: string;
      }>(`select n.status, n.channel, n.recipient_id, d.language, d.title, d.body
          from public.notifications n join public.notification_deliveries d on d.notification_id = n.id
          where n.trip_id = $1 order by n.recipient_id, n.channel`, [tripId]));
      assert.equal(rows.length, 4);
      assert.ok(rows.every((r) => r.status === 'sent'));
      const owner = rows.filter((r) => r.recipient_id === ids.owner);
      const viewer = rows.filter((r) => r.recipient_id === ids.viewer);
      assert.deepEqual(owner.map((r) => [r.channel, r.language, r.body]), [
        ['push', 'en', 'Companion is on the way — leaving now'],
        ['whatsapp', 'en', 'Companion is on the way — leaving now'],
      ]);
      assert.deepEqual(viewer.map((r) => r.body), ['సహచరులు దారిలో ఉన్నారు — leaving now', 'సహచరులు దారిలో ఉన్నారు — leaving now']);
      assert.ok(rows.every((r) => !/1958|dob|lab/i.test(r.body)), 'no health data in messages');

      // Nothing is sent twice.
      await drain(sqlStore, selectAdapters({}, sqlStore), { limit: 500 });
      const [{ n }] = await asAdmin((db) => db.query<{ n: number }>(
        `select count(*)::int as n from public.notification_deliveries d
         join public.notifications x on x.id = d.notification_id where x.trip_id = $1`, [tripId]));
      assert.equal(n, 4);
    } finally {
      await asAdmin((db) => db.query(`update public.profiles set preferred_language = 'en' where id = $1`, [ids.viewer]));
    }
  });
});
