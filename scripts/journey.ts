// Helpers for scripts/e2e-journey.sh (M7). Talks to Supabase local directly:
//   setup     create today's synthetic visit for the seed patient (primary: Asha)
//   dispatch  call the notify-dispatch Edge Function, then check the family received the updates
//   report    print the trip, its timeline and the deliveries (evidence)
// Env: DATABASE_URL, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, JOURNEY_STATE.
import { readFile, writeFile } from 'node:fs/promises';
import pg from 'pg';

const statePath = must('JOURNEY_STATE');
const ids = {
  owner: '20000000-0000-0000-0000-000000000001',
  viewer: '20000000-0000-0000-0000-000000000002',
  asha: '30000000-0000-0000-0000-000000000001',
  patient: '70000000-0000-0000-0000-000000000001',
  centre: '50000000-0000-0000-0000-000000000001',
  schedule: '80000000-0000-0000-0000-000000000001',
};

function must(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is not set`);
  return value;
}

async function withDb<T>(fn: (db: pg.Client) => Promise<T>): Promise<T> {
  const db = new pg.Client({ connectionString: must('DATABASE_URL') });
  await db.connect();
  try {
    return await fn(db);
  } finally {
    await db.end();
  }
}

async function readState(): Promise<Record<string, string>> {
  return JSON.parse(await readFile(statePath, 'utf8')) as Record<string, string>;
}

async function setup(): Promise<void> {
  const tripId = await withDb(async (db) => {
    const { rows } = await db.query<{ id: string }>(
      `insert into public.trips (schedule_id, patient_id, centre_id, companion_id, scheduled_pickup_at, scheduled_return_at)
       values ($1, $2, $3, $4, date_trunc('minute', now()) + interval '40 minutes',
               date_trunc('minute', now()) + interval '340 minutes')
       returning id`,
      [ids.schedule, ids.patient, ids.centre, ids.asha]);
    return rows[0].id;
  });
  // Month of the visit in India time (the invoice period), as YYYY-MM.
  const month = await withDb(async (db) => (await db.query<{ m: string }>(
    `select to_char(scheduled_pickup_at at time zone 'Asia/Kolkata', 'YYYY-MM') as m from public.trips where id = $1`,
    [tripId])).rows[0].m);
  await writeFile(statePath, JSON.stringify({ tripId, month }, null, 2));
  console.log(`today's visit: trip ${tripId}, pickup in 40 minutes, companion Asha (primary), backup Ravi`);
}

async function dispatch(expected: string[]): Promise<void> {
  const { tripId } = await readState();
  const response = await fetch(`${must('SUPABASE_URL')}/functions/v1/notify-dispatch`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${must('SUPABASE_SERVICE_ROLE_KEY')}` },
  });
  const summary = await response.text();
  console.log(`notify-dispatch -> HTTP ${response.status} ${summary}`);
  if (!response.ok) throw new Error('dispatch failed');

  const rows = await withDb(async (db) => (await db.query<{ recipient: string; channel: string; status: string; body: string; event: string }>(
    `select case n.recipient_id when $2 then 'owner' when $3 then 'viewer' else n.recipient_id::text end as recipient,
            n.channel, n.status, coalesce(n.payload ->> 'to_status', n.template) as event, d.body
     from public.notifications n
     left join public.notification_deliveries d on d.notification_id = n.id
     where n.trip_id = $1 and n.recipient_id in ($2, $3)
     order by n.id`, [tripId, ids.owner, ids.viewer])).rows);
  const pending = rows.filter((r) => r.status !== 'sent');
  if (pending.length) throw new Error(`undelivered family notifications: ${JSON.stringify(pending)}`);
  // Companion notes stay in the app: no delivered message may contain one.
  const notes = await withDb(async (db) => (await db.query<{ note: string }>(
    `select note from public.trip_events where trip_id = $1 and note is not null and actor_kind = 'companion'
       and to_status <> 'picked_up'`, [tripId])).rows.map((r) => r.note));
  const leaked = rows.filter((r) => r.body && notes.some((n) => r.body.includes(n)));
  if (leaked.length) throw new Error(`companion notes leaked into outbound messages: ${JSON.stringify(leaked)}`);
  const ownerPush = rows.filter((r) => r.recipient === 'owner' && r.channel === 'push').map((r) => r.event);
  for (const event of expected) {
    if (!ownerPush.includes(event)) throw new Error(`owner did not receive ${event}; got ${ownerPush.join(', ')}`);
  }
  console.log(`family deliveries for the trip (test adapter): ${rows.length} rows, all sent`);
  for (const r of rows.filter((x) => x.channel === 'push' && x.recipient === 'owner')) {
    console.log(`  owner push: ${r.event.padEnd(20)} "${r.body}"`);
  }
}

// The owner's bill notification was delivered with the amount in rupees.
async function dispatchBill(expectedRupees: string): Promise<void> {
  const response = await fetch(`${must('SUPABASE_URL')}/functions/v1/notify-dispatch`, {
    method: 'POST', headers: { Authorization: `Bearer ${must('SUPABASE_SERVICE_ROLE_KEY')}` },
  });
  console.log(`notify-dispatch -> HTTP ${response.status} ${await response.text()}`);
  const rows = await withDb(async (db) => (await db.query<{ status: string; body: string | null }>(
    `select n.status, d.body from public.notifications n
     left join public.notification_deliveries d on d.notification_id = n.id
     where n.template = 'invoice_issued' and n.recipient_id = $1 order by n.id desc limit 1`, [ids.owner])).rows);
  if (rows[0]?.status !== 'sent' || !rows[0].body?.includes(expectedRupees)) {
    throw new Error(`owner bill notification not delivered with ${expectedRupees}: ${JSON.stringify(rows)}`);
  }
  console.log(`  owner push: invoice_issued       "${rows[0].body}"`);
}

async function report(): Promise<void> {
  const { tripId } = await readState();
  await withDb(async (db) => {
    const trip = (await db.query(
      `select t.status, p.full_name as companion, t.picked_up_at is not null as picked_up, t.post_visit_note
       from public.trips t join public.profiles p on p.id = t.companion_id where t.id = $1`, [tripId])).rows[0];
    console.log('trip:', JSON.stringify(trip));
    const events = (await db.query<{ to_status: string; actor_kind: string; note: string | null }>(
      'select to_status, actor_kind, note from public.trip_events where trip_id = $1 order by id', [tripId])).rows;
    for (const e of events) console.log(`  event: ${e.to_status.padEnd(20)} by ${e.actor_kind}${e.note ? ` — ${e.note}` : ''}`);
    const counts = (await db.query(
      `select n.channel, count(*)::int as sent from public.notifications n
       join public.notification_deliveries d on d.notification_id = n.id where n.trip_id = $1 group by 1 order by 1`, [tripId])).rows;
    console.log('deliveries by channel:', JSON.stringify(counts));
    const bill = (await db.query(
      `select i.status, i.total_paise, (select count(*)::int from public.invoice_lines l where l.invoice_id = i.id) as lines,
              (select p.status from public.payments p where p.invoice_id = i.id order by p.created_at desc limit 1) as payment
       from public.invoices i where i.patient_id = $1 order by i.created_at desc limit 1`, [ids.patient])).rows[0];
    console.log('bill:', JSON.stringify(bill));
  });
}

const [command, arg] = process.argv.slice(2);
if (command === 'setup') await setup();
else if (command === 'dispatch') await dispatch(arg ? arg.split(',') : []);
else if (command === 'dispatch-bill') await dispatchBill(arg);
else if (command === 'report') await report();
else throw new Error('usage: journey.ts setup | dispatch <events> | dispatch-bill <rupees> | report');
