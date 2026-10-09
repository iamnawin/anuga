// Unit tests for the notification dispatcher (supabase/functions/notify-dispatch):
// message rendering, adapter selection, retry decisions, and the REST store.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { AdapterError, ConfigError, selectAdapters, testAdapter, type Adapter, type Channel } from '../functions/notify-dispatch/adapters.ts';
import { dispatchOnce, drain, type ClaimedNotification, type DispatchStore } from '../functions/notify-dispatch/dispatcher.ts';
import { render, STATUSES, TEMPLATES, UnknownTemplateError } from '../functions/notify-dispatch/messages.ts';
import { restStore } from '../functions/notify-dispatch/rest_store.ts';

const row = (id: number, over: Partial<ClaimedNotification> = {}): ClaimedNotification => ({
  notification_id: id, channel: 'push', template: 'trip_status_changed',
  payload: { to_status: 'picked_up', note: null }, attempts: 1,
  recipient_id: 'u1', recipient_phone: '919000000101', recipient_language: 'en', ...over,
});

function fakeStore(rows: ClaimedNotification[], failStatus: 'pending' | 'failed' = 'pending') {
  const sent: number[] = [];
  const failed: { id: number; error: string; permanent: boolean }[] = [];
  const deliveries: unknown[] = [];
  let queue = [...rows];
  const store: DispatchStore & { recordDelivery(r: unknown): Promise<void> } = {
    claim: async (limit) => { const out = queue.slice(0, limit); queue = queue.slice(limit); return out; },
    markSent: async (id) => { sent.push(id); },
    markFailed: async (id, error, permanent) => { failed.push({ id, error, permanent }); return permanent ? 'failed' : failStatus; },
    recordDelivery: async (r) => { deliveries.push(r); },
  };
  return { store, sent, failed, deliveries };
}

describe('render', () => {
  test('every template and status has text in en, te and hi', () => {
    for (const lang of ['en', 'te', 'hi']) {
      for (const template of TEMPLATES) {
        const payload = template === 'trip_status_changed' ? { to_status: 'completed' }
          : template === 'invoice_issued' ? { total_paise: 480000, period_start: '2026-10-01' } : {};
        const m = render(template, payload, lang);
        assert.ok(m.title.trim() && m.body.trim(), `${lang} ${template}`);
      }
      for (const status of STATUSES) {
        assert.ok(render('trip_status_changed', { to_status: status }, lang).body.trim(), `${lang} ${status}`);
      }
    }
  });

  test('uses the recipient language and falls back to English', () => {
    assert.equal(render('trip_status_changed', { to_status: 'picked_up' }, 'te').body, 'ఇంటి నుండి పికప్ అయింది');
    assert.equal(render('trip_status_changed', { to_status: 'picked_up' }, 'fr').body, 'Picked up from home');
  });

  test('never copies the companion note into an outbound message, only says there is one', () => {
    const note = 'BP looked high, centre staff informed';
    for (const lang of ['en', 'te', 'hi']) {
      const m = render('trip_status_changed', { to_status: 'completed', note }, lang);
      assert.ok(!m.body.includes('BP') && !m.title.includes('BP'), lang);
    }
    assert.equal(render('trip_status_changed', { to_status: 'issue_reported', note: 'Auto broke down' }, 'en').body,
      "Issue reported; our team is on it Open the app to read the companion's note.");
    // The system's own pickup note is not a companion note.
    assert.equal(render('trip_status_changed', { to_status: 'picked_up', note: 'pickup OTP verified' }, 'en').body,
      'Picked up from home');
  });

  test('bills show the month and the amount in rupees with Indian grouping', () => {
    assert.equal(render('invoice_issued', { total_paise: 12345600, period_start: '2026-10-01' }, 'en').body,
      'Bill for October 2026: ₹1,23,456.00. Open the app to see it.');
    assert.throws(() => render('invoice_issued', { total_paise: 'x' }, 'en'), UnknownTemplateError);
  });

  test('unknown templates are an error, not a blank message', () => {
    assert.throws(() => render('nope', {}, 'en'), UnknownTemplateError);
  });
});

describe('selectAdapters', () => {
  const recorder = { recordDelivery: async () => {} };

  test('defaults to the test adapter for every channel', () => {
    const adapters = selectAdapters({}, recorder);
    assert.deepEqual(Object.values(adapters).map((a) => a.name), ['test', 'test', 'test']);
    assert.deepEqual(Object.values(selectAdapters({ NOTIFY_PUSH_ADAPTER: 'test', NOTIFY_WHATSAPP_ADAPTER: '' }, recorder))
      .map((a) => a.name), ['test', 'test', 'test']);
  });

  test('a live provider needs founder authorization', () => {
    assert.throws(() => selectAdapters({ NOTIFY_WHATSAPP_ADAPTER: 'whatsapp' }, recorder), (e: unknown) =>
      e instanceof ConfigError && /founder authorization/.test(e.message));
    assert.throws(() => selectAdapters({ NOTIFY_PUSH_ADAPTER: 'fcm' }, recorder), ConfigError);
  });

  test('even when authorized, live adapters do not exist yet, so nothing is sent', () => {
    assert.throws(() => selectAdapters({ NOTIFY_PUSH_ADAPTER: 'fcm', NOTIFY_LIVE_PROVIDERS_AUTHORIZED: 'yes' }, recorder),
      (e: unknown) => e instanceof ConfigError && /not implemented/.test(e.message));
  });

  test('rejects unknown values', () => {
    assert.throws(() => selectAdapters({ NOTIFY_SMS_ADAPTER: 'twilio' }, recorder), ConfigError);
  });
});

describe('dispatchOnce', () => {
  test('sends through the test adapter and records the rendered message', async () => {
    const f = fakeStore([row(1), row(2, { channel: 'whatsapp', recipient_language: 'hi' })]);
    const summary = await dispatchOnce(f.store, selectAdapters({}, f.store));
    assert.deepEqual(summary, { claimed: 2, sent: 2, retrying: 0, failed: 0 });
    assert.deepEqual(f.sent, [1, 2]);
    assert.deepEqual((f.deliveries[1] as { body: string; language: string }), {
      notification_id: 2, adapter: 'test', channel: 'whatsapp', recipient_id: 'u1', language: 'hi',
      title: 'विज़िट अपडेट', body: 'घर से पिकअप हो गया',
    });
  });

  test('transient errors retry; permanent errors and missing adapters fail', async () => {
    const flaky: Adapter = { name: 'flaky', send: async () => { throw new Error('timeout'); } };
    const f = fakeStore([
      row(1),
      row(2, { channel: 'sms', recipient_phone: null }),
      row(3, { channel: 'whatsapp' }),
      row(4, { template: 'mystery' }),
    ]);
    const recorderAdapter = testAdapter(f.store);
    const summary = await dispatchOnce(f.store, { push: flaky, sms: recorderAdapter } as Partial<Record<Channel, Adapter>>);
    assert.deepEqual(summary, { claimed: 4, sent: 0, retrying: 1, failed: 3 });
    assert.deepEqual(f.failed.map((x) => [x.id, x.permanent]), [[1, false], [2, true], [3, true], [4, true]]);
    assert.match(f.failed[1].error, /no phone/);
    assert.match(f.failed[2].error, /no adapter for channel whatsapp/);
    assert.match(f.failed[3].error, /unknown notification template/);
  });

  test('a retry the database turns into a final failure is counted as failed', async () => {
    const down: Adapter = { name: 'down', send: async () => { throw new AdapterError('provider down'); } };
    const f = fakeStore([row(1)], 'failed');
    assert.deepEqual(await dispatchOnce(f.store, { push: down }), { claimed: 1, sent: 0, retrying: 0, failed: 1 });
  });

  test('drain keeps claiming full pages until a short one', async () => {
    const f = fakeStore(Array.from({ length: 5 }, (_, i) => row(i + 1)));
    const total = await drain(f.store, selectAdapters({}, f.store), { limit: 2 });
    assert.deepEqual(total, { claimed: 5, sent: 5, retrying: 0, failed: 0 });
  });
});

describe('restStore', () => {
  test('calls the dispatch RPCs with the service-role key', async () => {
    const calls: { url: string; init: RequestInit }[] = [];
    const fakeFetch = (async (url: string, init: RequestInit) => {
      calls.push({ url, init });
      const body = url.endsWith('dispatch_mark_failed') ? '"pending"' : url.endsWith('claim_notifications') ? '[]' : '';
      return new Response(body, { status: 200 });
    }) as unknown as typeof fetch;
    const store = restStore('http://127.0.0.1:54321/', 'service-key', fakeFetch);
    assert.deepEqual(await store.claim(10), []);
    await store.markSent(5, null);
    assert.equal(await store.markFailed(6, 'boom', false), 'pending');
    await store.recordDelivery({ notification_id: 7, adapter: 'test', channel: 'push', recipient_id: 'u', language: 'en', title: 't', body: 'b' });
    assert.deepEqual(calls.map((c) => c.url.replace('http://127.0.0.1:54321/rest/v1/', '')),
      ['rpc/dispatch_claim_notifications', 'rpc/dispatch_mark_sent', 'rpc/dispatch_mark_failed', 'notification_deliveries']);
    const headers = calls[0].init.headers as Record<string, string>;
    assert.equal(headers.Authorization, 'Bearer service-key');
    assert.equal(headers.apikey, 'service-key');
    assert.deepEqual(JSON.parse(calls[2].init.body as string), { p_notification_id: 6, p_error: 'boom', p_permanent: false });
  });

  test('surfaces HTTP errors', async () => {
    const fakeFetch = (async () => new Response('{"code":"42501"}', { status: 401 })) as unknown as typeof fetch;
    await assert.rejects(restStore('http://x', 'k', fakeFetch).claim(1), /HTTP 401/);
  });
});
