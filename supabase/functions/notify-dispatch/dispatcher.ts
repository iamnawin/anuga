// Drains the notifications outbox once: claim due rows, render, send through the
// channel's adapter, then mark each row sent or failed (the database decides
// between retry with backoff and final failure). Runtime-neutral: used by the
// Edge Function (Deno) and by the Node tests.
import { AdapterError, type Adapter, type Channel } from './adapters.ts';
import { languageOf, render } from './messages.ts';

export interface ClaimedNotification {
  notification_id: number | string;
  channel: Channel;
  template: string;
  payload: Record<string, unknown>;
  attempts: number;
  recipient_id: string;
  recipient_phone: string | null;
  recipient_language: string | null;
}

export interface DispatchStore {
  claim(limit: number): Promise<ClaimedNotification[]>;
  markSent(notificationId: number, providerMessageId: string | null): Promise<void>;
  // Returns the row's new status: 'pending' (will retry) or 'failed'.
  markFailed(notificationId: number, error: string, permanent: boolean): Promise<'pending' | 'failed'>;
}

export interface DispatchSummary { claimed: number; sent: number; retrying: number; failed: number }

export async function dispatchOnce(
  store: DispatchStore,
  adapters: Partial<Record<Channel, Adapter>>,
  limit = 50,
): Promise<DispatchSummary> {
  const rows = await store.claim(limit);
  const summary: DispatchSummary = { claimed: rows.length, sent: 0, retrying: 0, failed: 0 };

  for (const row of rows) {
    const id = Number(row.notification_id);
    const fail = async (message: string, permanent: boolean) => {
      const status = await store.markFailed(id, message, permanent);
      if (status === 'failed') summary.failed++;
      else summary.retrying++;
    };

    const adapter = adapters[row.channel];
    if (!adapter) {
      await fail(`no adapter for channel ${row.channel}`, true);
      continue;
    }
    let message;
    try {
      message = render(row.template, row.payload ?? {}, row.recipient_language);
    } catch (error) {
      await fail((error as Error).message, true);
      continue;
    }
    try {
      const { providerMessageId } = await adapter.send({
        ...message,
        notificationId: id,
        channel: row.channel,
        recipientId: row.recipient_id,
        recipientPhone: row.recipient_phone,
        language: languageOf(row.recipient_language),
      });
      await store.markSent(id, providerMessageId);
      summary.sent++;
    } catch (error) {
      const permanent = error instanceof AdapterError && error.permanent;
      await fail(error instanceof Error ? error.message : String(error), permanent);
    }
  }
  return summary;
}

// Runs dispatchOnce until a pass claims nothing (or maxPasses), for one cron tick.
export async function drain(
  store: DispatchStore,
  adapters: Partial<Record<Channel, Adapter>>,
  { limit = 50, maxPasses = 20 } = {},
): Promise<DispatchSummary> {
  const total: DispatchSummary = { claimed: 0, sent: 0, retrying: 0, failed: 0 };
  for (let pass = 0; pass < maxPasses; pass++) {
    const s = await dispatchOnce(store, adapters, limit);
    total.claimed += s.claimed; total.sent += s.sent; total.retrying += s.retrying; total.failed += s.failed;
    if (s.claimed < limit) break;
  }
  return total;
}
