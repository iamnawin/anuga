// DispatchStore over PostgREST with the service-role key (server side only:
// Edge Function secrets, never an app). Uses the global fetch (Deno and Node).
import type { ClaimedNotification, DispatchStore } from './dispatcher.ts';
import type { DeliveryRecorder } from './adapters.ts';

export function restStore(
  supabaseUrl: string,
  serviceRoleKey: string,
  fetchImpl: typeof fetch = fetch,
): DispatchStore & DeliveryRecorder {
  const headers = {
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
    'Content-Type': 'application/json',
  };

  async function post(path: string, body: unknown, prefer?: string): Promise<unknown> {
    const response = await fetchImpl(`${supabaseUrl.replace(/\/$/, '')}/rest/v1/${path}`, {
      method: 'POST',
      headers: prefer ? { ...headers, Prefer: prefer } : headers,
      body: JSON.stringify(body),
    });
    const text = await response.text();
    if (!response.ok) throw new Error(`${path}: HTTP ${response.status} ${text}`);
    return text ? JSON.parse(text) : null;
  }

  return {
    claim: async (limit) => (await post('rpc/dispatch_claim_notifications', { p_limit: limit })) as ClaimedNotification[],
    markSent: async (id, providerMessageId) => {
      await post('rpc/dispatch_mark_sent', { p_notification_id: id, p_provider_message_id: providerMessageId });
    },
    markFailed: async (id, error, permanent) =>
      (await post('rpc/dispatch_mark_failed', { p_notification_id: id, p_error: error, p_permanent: permanent })) as
        | 'pending'
        | 'failed',
    recordDelivery: async (row) => {
      await post('notification_deliveries', row, 'return=minimal');
    },
  };
}
