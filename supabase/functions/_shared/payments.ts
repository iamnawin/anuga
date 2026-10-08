// Payments: adapters, request handlers and webhook verification. Runtime-neutral
// (Deno entries: payments/index.ts, payments-webhook/index.ts; Node tests import this).
//
//   payments (user JWT):     start          -> payment_start (owner, issued bill) -> adapter order -> payment_set_order
//                            complete-test  -> test adapter only: simulates the provider capturing
//   payments-webhook:        provider-signed body only -> payment_captured (service role)
//
// Card/UPI data never reaches us: providers collect it and send ids and amounts.

export class ConfigError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ConfigError';
  }
}

export class RpcError extends Error {
  readonly status: number;
  readonly code: string;

  constructor(status: number, code: string, message: string) {
    super(message);
    this.name = 'RpcError';
    this.status = status;
    this.code = code;
  }
}

export interface PaymentAdapter {
  readonly name: 'test' | 'razorpay';
  createOrder(input: { paymentId: string; amountPaise: number }): Promise<{ orderId: string }>;
  /** Public details the app needs to open the provider's checkout (never a secret). */
  checkout(): Record<string, string>;
  /** Verifies a webhook body; returns the captured payment or null when the event is not a capture. */
  verifyWebhook(rawBody: string, signature: string | null): Promise<CapturedEvent | null>;
}

export interface CapturedEvent { orderId: string; providerPaymentId: string; amountPaise: number }

export class SignatureError extends Error {
  constructor() {
    super('invalid webhook signature');
    this.name = 'SignatureError';
  }
}

const encoder = new TextEncoder();

export async function hmacSha256Hex(secret: string, body: string): Promise<string> {
  const key = await crypto.subtle.importKey('raw', encoder.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const mac = new Uint8Array(await crypto.subtle.sign('HMAC', key, encoder.encode(body)));
  return Array.from(mac, (b) => b.toString(16).padStart(2, '0')).join('');
}

function constantTimeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/** Razorpay webhook body (payment.captured). */
function capturedFromRazorpay(body: string): CapturedEvent | null {
  const event = JSON.parse(body) as { event?: string; payload?: { payment?: { entity?: Record<string, unknown> } } };
  if (event.event !== 'payment.captured') return null;
  const entity = event.payload?.payment?.entity ?? {};
  if (typeof entity.order_id !== 'string' || typeof entity.id !== 'string' || typeof entity.amount !== 'number') {
    throw new SignatureError();
  }
  return { orderId: entity.order_id, providerPaymentId: entity.id, amountPaise: entity.amount };
}

/** Signs and checks bodies the same way as Razorpay (HMAC-SHA256 hex of the raw body). */
async function verifySigned(secret: string, rawBody: string, signature: string | null): Promise<CapturedEvent | null> {
  if (!signature || !constantTimeEqual(await hmacSha256Hex(secret, rawBody), signature)) throw new SignatureError();
  return capturedFromRazorpay(rawBody);
}

/** No provider: order ids are generated here; captures are simulated by `complete-test`. */
export function testAdapter(webhookSecret: string): PaymentAdapter {
  return {
    name: 'test',
    createOrder: async ({ paymentId }) => ({ orderId: `test_order_${paymentId.replaceAll('-', '')}` }),
    checkout: () => ({ provider: 'test' }),
    verifyWebhook: (body, signature) => verifySigned(webhookSecret, body, signature),
  };
}

/** Razorpay Orders API. Test keys only unless live payments are authorized. */
export function razorpayAdapter(
  keyId: string, keySecret: string, webhookSecret: string, fetchImpl: typeof fetch = fetch,
): PaymentAdapter {
  return {
    name: 'razorpay',
    async createOrder({ paymentId, amountPaise }) {
      const response = await fetchImpl('https://api.razorpay.com/v1/orders', {
        method: 'POST',
        headers: { Authorization: `Basic ${btoa(`${keyId}:${keySecret}`)}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount: amountPaise, currency: 'INR', receipt: paymentId, notes: { payment_id: paymentId } }),
      });
      if (!response.ok) throw new Error(`razorpay orders: HTTP ${response.status}`);
      return { orderId: ((await response.json()) as { id: string }).id };
    },
    checkout: () => ({ provider: 'razorpay', key_id: keyId }),
    verifyWebhook: (body, signature) => verifySigned(webhookSecret, body, signature),
  };
}

/** Picks the adapter from env. Default `test`; Razorpay needs keys, and live keys need authorization. */
export function selectPaymentAdapter(env: Record<string, string | undefined>, fetchImpl: typeof fetch = fetch): PaymentAdapter {
  const choice = (env.PAYMENTS_ADAPTER ?? 'test').trim() || 'test';
  const webhookSecret = env.PAYMENTS_WEBHOOK_SECRET ?? '';
  if (choice === 'test') {
    if (!webhookSecret) throw new ConfigError('PAYMENTS_WEBHOOK_SECRET is required (any random value for the test adapter)');
    return testAdapter(webhookSecret);
  }
  if (choice !== 'razorpay') throw new ConfigError(`PAYMENTS_ADAPTER must be "test" or "razorpay", got "${choice}"`);
  const keyId = env.RAZORPAY_KEY_ID ?? '';
  const keySecret = env.RAZORPAY_KEY_SECRET ?? '';
  if (!keyId || !keySecret || !webhookSecret) {
    throw new ConfigError('razorpay needs RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET and PAYMENTS_WEBHOOK_SECRET');
  }
  if (!keyId.startsWith('rzp_test_') && env.PAYMENTS_LIVE_AUTHORIZED !== 'yes') {
    throw new ConfigError('only Razorpay test keys (rzp_test_...) are allowed without founder authorization');
  }
  return razorpayAdapter(keyId, keySecret, webhookSecret, fetchImpl);
}

export interface PaymentDeps {
  adapter: PaymentAdapter;
  userRpc(jwt: string, fn: string, args: Record<string, unknown>): Promise<unknown>;
  serviceRpc(fn: string, args: Record<string, unknown>): Promise<unknown>;
}

const json = (body: unknown, status = 200) => Response.json(body, { status });

function errorResponse(error: unknown): Response {
  if (error instanceof RpcError) {
    if (error.code === '42501') return json({ error: 'not_allowed', message: error.message }, 403);
    if (error.code === '22023' || error.code === 'P0002') return json({ error: 'invalid', message: error.message }, 400);
    return json({ error: 'database', message: error.message }, 502);
  }
  console.error('payments:', error instanceof Error ? error.message : String(error));
  return json({ error: 'internal', message: 'unexpected error' }, 500);
}

async function startPayment(deps: PaymentDeps, jwt: string, invoiceId: unknown) {
  const [row] = (await deps.userRpc(jwt, 'payment_start', { p_invoice_id: invoiceId, p_provider: deps.adapter.name })) as {
    payment_id: string; amount_paise: number; provider_order_id: string | null;
  }[];
  let orderId = row.provider_order_id;
  if (!orderId) {
    orderId = (await deps.adapter.createOrder({ paymentId: row.payment_id, amountPaise: row.amount_paise })).orderId;
    await deps.serviceRpc('payment_set_order', { p_payment_id: row.payment_id, p_provider_order_id: orderId });
  }
  return { payment_id: row.payment_id, order_id: orderId, amount_paise: row.amount_paise, currency: 'INR', ...deps.adapter.checkout() };
}

/** payments: called by the family app with the user's JWT (verified by the platform). */
export async function handlePaymentRequest(request: Request, deps: PaymentDeps): Promise<Response> {
  if (request.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);
  const jwt = /^Bearer\s+(\S+)$/i.exec(request.headers.get('Authorization') ?? '')?.[1];
  if (!jwt) return json({ error: 'sign_in_required' }, 401);
  let body: Record<string, unknown>;
  try {
    body = (await request.json()) as Record<string, unknown>;
  } catch {
    return json({ error: 'invalid', message: 'JSON body required' }, 400);
  }
  try {
    switch (body.action) {
      case 'start':
        return json(await startPayment(deps, jwt, body.invoice_id));
      case 'complete-test': {
        if (deps.adapter.name !== 'test') return json({ error: 'invalid', message: 'only in test mode' }, 400);
        // Same authorization as start (owner, issued bill), then what a provider webhook would do.
        const order = await startPayment(deps, jwt, body.invoice_id);
        const result = await deps.serviceRpc('payment_captured', {
          p_provider_order_id: order.order_id,
          p_provider_payment_id: `test_pay_${order.payment_id.replaceAll('-', '')}`,
          p_amount_paise: order.amount_paise,
        });
        return json({ payment_id: order.payment_id, result });
      }
      default:
        return json({ error: 'invalid', message: 'action must be start or complete-test' }, 400);
    }
  } catch (error) {
    return errorResponse(error);
  }
}

/** payments-webhook: provider-signed, no user JWT. Answers 200 for duplicates so the provider stops retrying. */
export async function handleWebhook(request: Request, deps: PaymentDeps): Promise<Response> {
  if (request.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);
  const raw = await request.text();
  let event: CapturedEvent | null;
  try {
    event = await deps.adapter.verifyWebhook(raw, request.headers.get('X-Razorpay-Signature'));
  } catch {
    return json({ error: 'invalid_signature' }, 401);
  }
  if (!event) return json({ ignored: true });
  try {
    const result = await deps.serviceRpc('payment_captured', {
      p_provider_order_id: event.orderId,
      p_provider_payment_id: event.providerPaymentId,
      p_amount_paise: event.amountPaise,
    });
    return json({ result });
  } catch (error) {
    return errorResponse(error);
  }
}

/** userRpc / serviceRpc over PostgREST. */
export function postgrest(supabaseUrl: string, anonKey: string, serviceRoleKey: string, fetchImpl: typeof fetch = fetch) {
  const base = supabaseUrl.replace(/\/$/, '');
  async function rpc(token: string, apikey: string, fn: string, args: Record<string, unknown>): Promise<unknown> {
    const response = await fetchImpl(`${base}/rest/v1/rpc/${fn}`, {
      method: 'POST',
      headers: { apikey, Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(args),
    });
    const text = await response.text();
    const data = text ? JSON.parse(text) : null;
    if (!response.ok) throw new RpcError(response.status, data?.code ?? String(response.status), data?.message ?? text);
    return data;
  }
  return {
    userRpc: (jwt: string, fn: string, args: Record<string, unknown>) => rpc(jwt, anonKey, fn, args),
    serviceRpc: (fn: string, args: Record<string, unknown>) => rpc(serviceRoleKey, serviceRoleKey, fn, args),
  };
}
