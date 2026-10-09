// Unit tests for the payments functions (supabase/functions/_shared/payments.ts):
// adapter selection, Razorpay order request, webhook signatures, request handling.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import {
  ConfigError, handlePaymentRequest, handleWebhook, hmacSha256Hex, razorpayAdapter, RpcError, selectPaymentAdapter,
  testAdapter, type PaymentDeps,
} from '../functions/_shared/payments.ts';

const SECRET = 'synthetic-webhook-secret';

function deps(over: Partial<PaymentDeps> = {}, existingOrder: string | null = null) {
  const calls: string[] = [];
  const d: PaymentDeps = {
    adapter: testAdapter(SECRET),
    userRpc: async (jwt, fn, args) => {
      calls.push(`user:${fn}:${JSON.stringify(args)}`);
      return [{ payment_id: 'aaaa-bbbb', amount_paise: 80000, provider_order_id: existingOrder }];
    },
    serviceRpc: async (fn, args) => { calls.push(`service:${fn}:${JSON.stringify(args)}`); return 'captured'; },
    ...over,
  };
  return { d, calls };
}

const post = (body: unknown, auth = 'Bearer user-jwt') => new Request('http://edge/payments', {
  method: 'POST', headers: { Authorization: auth, 'Content-Type': 'application/json' }, body: JSON.stringify(body),
});

const captured = (orderId: string, amount: number) => JSON.stringify({
  event: 'payment.captured',
  payload: { payment: { entity: { id: 'pay_synthetic', order_id: orderId, amount, currency: 'INR' } } },
});

describe('selectPaymentAdapter', () => {
  test('test adapter by default, with a webhook secret', () => {
    assert.equal(selectPaymentAdapter({ PAYMENTS_WEBHOOK_SECRET: 's' }).name, 'test');
    assert.throws(() => selectPaymentAdapter({}), ConfigError);
  });

  test('razorpay needs keys, and only test keys without founder authorization', () => {
    const base = { PAYMENTS_ADAPTER: 'razorpay', PAYMENTS_WEBHOOK_SECRET: 's', RAZORPAY_KEY_SECRET: 'x' };
    assert.throws(() => selectPaymentAdapter(base), /RAZORPAY_KEY_ID/);
    assert.equal(selectPaymentAdapter({ ...base, RAZORPAY_KEY_ID: 'rzp_test_abc' }).name, 'razorpay');
    assert.throws(() => selectPaymentAdapter({ ...base, RAZORPAY_KEY_ID: 'rzp_live_abc' }), /founder authorization/);
    assert.equal(selectPaymentAdapter({ ...base, RAZORPAY_KEY_ID: 'rzp_live_abc', PAYMENTS_LIVE_AUTHORIZED: 'yes' }).name, 'razorpay');
    assert.throws(() => selectPaymentAdapter({ PAYMENTS_ADAPTER: 'stripe', PAYMENTS_WEBHOOK_SECRET: 's' }), ConfigError);
  });
});

describe('razorpay adapter', () => {
  test('creates an order in paise with basic auth and exposes only the key id', async () => {
    let seen: { url: string; init: RequestInit } | null = null;
    const fakeFetch = (async (url: string, init: RequestInit) => {
      seen = { url, init };
      return Response.json({ id: 'order_synthetic' });
    }) as unknown as typeof fetch;
    const adapter = razorpayAdapter('rzp_test_key', 'secret_value', SECRET, fakeFetch);
    assert.deepEqual(await adapter.createOrder({ paymentId: 'p1', amountPaise: 80000 }), { orderId: 'order_synthetic' });
    assert.equal(seen!.url, 'https://api.razorpay.com/v1/orders');
    assert.equal((seen!.init.headers as Record<string, string>).Authorization, `Basic ${btoa('rzp_test_key:secret_value')}`);
    assert.deepEqual(JSON.parse(seen!.init.body as string), { amount: 80000, currency: 'INR', receipt: 'p1', notes: { payment_id: 'p1' } });
    assert.deepEqual(adapter.checkout(), { provider: 'razorpay', key_id: 'rzp_test_key' });
  });
});

describe('payments handler', () => {
  test('start: the database authorizes first, then an order is created and stored', async () => {
    const { d, calls } = deps();
    const response = await handlePaymentRequest(post({ action: 'start', invoice_id: 'inv1' }), d);
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), {
      payment_id: 'aaaa-bbbb', order_id: 'test_order_aaaabbbb', amount_paise: 80000, currency: 'INR', provider: 'test',
    });
    assert.deepEqual(calls, [
      'user:payment_start:{"p_invoice_id":"inv1","p_provider":"test"}',
      'service:payment_set_order:{"p_payment_id":"aaaa-bbbb","p_provider_order_id":"test_order_aaaabbbb"}',
    ]);
  });

  test('an existing order is reused; a refusal creates nothing', async () => {
    const reuse = deps({}, 'test_order_existing');
    await handlePaymentRequest(post({ action: 'start', invoice_id: 'inv1' }), reuse.d);
    assert.equal(reuse.calls.length, 1);
    const refused = deps({ userRpc: async () => { throw new RpcError(403, '42501', 'not allowed'); } });
    const response = await handlePaymentRequest(post({ action: 'start', invoice_id: 'inv1' }), refused.d);
    assert.equal(response.status, 403);
    assert.deepEqual(refused.calls, []);
  });

  test('complete-test works only with the test adapter', async () => {
    const t = deps();
    const ok = await handlePaymentRequest(post({ action: 'complete-test', invoice_id: 'inv1' }), t.d);
    assert.deepEqual(await ok.json(), { payment_id: 'aaaa-bbbb', result: 'captured' });
    assert.ok(t.calls.at(-1)!.startsWith('service:payment_captured:{"p_provider_order_id":"test_order_aaaabbbb"'));
    const live = deps({ adapter: razorpayAdapter('rzp_test_k', 's', SECRET) });
    assert.equal((await handlePaymentRequest(post({ action: 'complete-test', invoice_id: 'inv1' }), live.d)).status, 400);
    assert.deepEqual(live.calls, []);
  });

  test('needs a bearer token, POST and a known action', async () => {
    const { d } = deps();
    assert.equal((await handlePaymentRequest(post({ action: 'start' }, ''), d)).status, 401);
    assert.equal((await handlePaymentRequest(new Request('http://edge/payments'), d)).status, 405);
    assert.equal((await handlePaymentRequest(post({ action: 'refund' }), d)).status, 400);
  });
});

describe('webhooks', () => {
  const hook = async (body: string, signature: string | null) => new Request('http://edge/payments-webhook', {
    method: 'POST', headers: signature ? { 'X-Razorpay-Signature': signature } : {}, body,
  });

  test('a correctly signed capture is recorded', async () => {
    const { d, calls } = deps();
    const body = captured('order_1', 80000);
    const response = await handleWebhook(await hook(body, await hmacSha256Hex(SECRET, body)), d);
    assert.deepEqual(await response.json(), { result: 'captured' });
    assert.deepEqual(calls, ['service:payment_captured:{"p_provider_order_id":"order_1","p_provider_payment_id":"pay_synthetic","p_amount_paise":80000}']);
  });

  test('missing, wrong or stale signatures are rejected and change nothing', async () => {
    const { d, calls } = deps();
    const body = captured('order_1', 80000);
    const tampered = captured('order_1', 1);
    for (const req of [
      await hook(body, null),
      await hook(body, 'deadbeef'),
      await hook(tampered, await hmacSha256Hex(SECRET, body)),
      await hook(body, await hmacSha256Hex('another-secret', body)),
    ]) {
      assert.equal((await handleWebhook(req, d)).status, 401);
    }
    assert.deepEqual(calls, []);
  });

  test('other events are acknowledged and ignored', async () => {
    const { d, calls } = deps();
    const body = JSON.stringify({ event: 'payment.authorized', payload: {} });
    assert.deepEqual(await (await handleWebhook(await hook(body, await hmacSha256Hex(SECRET, body)), d)).json(), { ignored: true });
    assert.deepEqual(calls, []);
  });
});
