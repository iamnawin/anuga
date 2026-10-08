// The payments Edge Functions on Supabase local (edge runtime, test adapter).
// Skipped unless SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY and
// DATABASE_URL are set (CI job supabase-local). The webhook secret is the local
// placeholder from supabase/config.toml [edge_runtime.secrets].
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, asUser, ids } from './support/db.ts';
import { hmacSha256Hex } from '../functions/_shared/payments.ts';

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;
const webhookSecret = process.env.PAYMENTS_WEBHOOK_SECRET ?? 'local-test-webhook-signing-key-not-real';
const skip = !(url && anonKey && process.env.SUPABASE_SERVICE_ROLE_KEY && process.env.DATABASE_URL)
  && 'needs Supabase local with the edge runtime';

async function signIn(phone: string): Promise<string> {
  const headers = { apikey: anonKey!, 'Content-Type': 'application/json' };
  await fetch(`${url}/auth/v1/otp`, { method: 'POST', headers, body: JSON.stringify({ phone, create_user: false }) });
  const response = await fetch(`${url}/auth/v1/verify`, {
    method: 'POST', headers, body: JSON.stringify({ phone, token: '123456', type: 'sms' }),
  });
  return ((await response.json()) as { access_token: string }).access_token;
}

// An issued bill for a fixed past month, with one completed visit.
async function issuedBill(month: string): Promise<{ id: string; total: number }> {
  await asAdmin((db) => db.query(
    `insert into public.trips (patient_id, centre_id, companion_id, scheduled_pickup_at, scheduled_return_at, status)
     values ($1, $2, $3, $4::timestamptz, $4::timestamptz + interval '5 hours', 'completed')`,
    [ids.patient, ids.centre, ids.asha, `${month}-05T01:30:00Z`]));
  const [{ id }] = await asUser(ids.ops, (db) => db.query<{ id: string }>(
    'select public.ops_generate_invoice($1, $2::date) as id', [ids.patient, `${month}-01`]));
  await asUser(ids.ops, (db) => db.query('select public.ops_issue_invoice($1)', [id]));
  const [{ total_paise }] = await asAdmin((db) => db.query<{ total_paise: number }>('select total_paise from public.invoices where id = $1', [id]));
  return { id, total: total_paise };
}

const status = async (invoiceId: string) => (await asAdmin((db) => db.query<{ status: string }>(
  'select status from public.invoices where id = $1', [invoiceId])))[0].status;

const pay = (jwt: string, body: object) => fetch(`${url}/functions/v1/payments`, {
  method: 'POST', headers: { Authorization: `Bearer ${jwt}`, 'Content-Type': 'application/json' }, body: JSON.stringify(body),
});

const webhook = (body: string, signature: string) => fetch(`${url}/functions/v1/payments-webhook`, {
  method: 'POST', headers: { 'X-Razorpay-Signature': signature, 'Content-Type': 'application/json' }, body,
});

test('payments: owner starts, a signed webhook pays the bill once, everyone else is refused', { skip }, async () => {
  const [owner, viewer] = await Promise.all(['+919000000101', '+919000000102'].map(signIn));
  const bill = await issuedBill('2023-05');

  assert.equal((await pay(viewer, { action: 'start', invoice_id: bill.id })).status, 403);
  const start = await pay(owner, { action: 'start', invoice_id: bill.id });
  assert.equal(start.status, 200, await start.clone().text());
  const order = (await start.json()) as { order_id: string; amount_paise: number; provider: string };
  assert.equal(order.provider, 'test');
  assert.equal(order.amount_paise, bill.total);

  const body = JSON.stringify({ event: 'payment.captured', payload: { payment: { entity: {
    id: 'pay_synthetic_1', order_id: order.order_id, amount: bill.total, currency: 'INR' } } } });
  assert.equal((await webhook(body, 'forged')).status, 401);
  assert.equal(await status(bill.id), 'issued');

  const signature = await hmacSha256Hex(webhookSecret, body);
  const first = await webhook(body, signature);
  assert.deepEqual(await first.json(), { result: 'captured' });
  assert.equal(await status(bill.id), 'paid');
  assert.deepEqual(await (await webhook(body, signature)).json(), { result: 'already_captured' });
});

test('payments: test-mode completion goes through the same owner check', { skip }, async () => {
  const [owner, viewer] = await Promise.all(['+919000000101', '+919000000102'].map(signIn));
  const bill = await issuedBill('2023-06');
  assert.equal((await pay(viewer, { action: 'complete-test', invoice_id: bill.id })).status, 403);
  const done = await pay(owner, { action: 'complete-test', invoice_id: bill.id });
  assert.equal(done.status, 200, await done.clone().text());
  assert.equal(((await done.json()) as { result: string }).result, 'captured');
  assert.equal(await status(bill.id), 'paid');
  assert.equal((await pay(owner, { action: 'start', invoice_id: bill.id })).status, 400, 'a paid bill cannot be paid again');
});
