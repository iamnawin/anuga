// The deployed shape of M6: the notify-dispatch Edge Function served by Supabase
// local (`supabase start` with the edge runtime). Skipped unless SUPABASE_URL,
// SUPABASE_ANON_KEY and SUPABASE_SERVICE_ROLE_KEY are set (CI job supabase-local).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, asUser, createTrip, ids } from './support/db.ts';

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const skip = !(url && anonKey && serviceKey && process.env.DATABASE_URL) && 'needs Supabase local with the edge runtime';

const invoke = (key: string) =>
  fetch(`${url}/functions/v1/notify-dispatch`, { method: 'POST', headers: { Authorization: `Bearer ${key}` } });

test('the Edge Function refuses non-service callers', { skip }, async () => {
  const response = await invoke(anonKey!);
  assert.equal(response.status, 403);
});

test('the Edge Function delivers a status change through the test adapter', { skip }, async () => {
  const tripId = await createTrip(25);
  await asUser(ids.asha, (db) => db.query(`select public.advance_trip($1, 'companion_en_route')`, [tripId]));

  const response = await invoke(serviceKey!);
  assert.equal(response.status, 200, await response.clone().text());
  const summary = (await response.json()) as { sent: number; failed: number };
  assert.ok(summary.sent >= 4, JSON.stringify(summary));

  const rows = await asAdmin((db) => db.query<{ status: string; adapter: string | null; body: string | null }>(
    `select n.status, d.adapter, d.body from public.notifications n
     left join public.notification_deliveries d on d.notification_id = n.id
     where n.trip_id = $1`, [tripId]));
  assert.equal(rows.length, 4);
  assert.ok(rows.every((r) => r.status === 'sent' && r.adapter === 'test' && r.body === 'Companion is on the way'));
});
