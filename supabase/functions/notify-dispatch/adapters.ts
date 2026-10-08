// Delivery adapters per channel. `test` records the rendered message in
// public.notification_deliveries instead of sending it. Live providers (FCM,
// WhatsApp) are gated: selecting one needs NOTIFY_LIVE_PROVIDERS_AUTHORIZED=yes
// (founder authorization) and an implementation, which does not exist yet.
import type { Rendered } from './messages.ts';

export type Channel = 'push' | 'whatsapp' | 'sms';

export interface OutgoingMessage extends Rendered {
  notificationId: number;
  channel: Channel;
  recipientId: string;
  recipientPhone: string | null;
  language: string;
}

export interface Adapter {
  readonly name: string;
  send(message: OutgoingMessage): Promise<{ providerMessageId: string | null }>;
}

// A delivery failure. Permanent failures are not retried (e.g. no phone number).
export class AdapterError extends Error {
  readonly permanent: boolean;

  constructor(message: string, permanent = false) {
    super(message);
    this.name = 'AdapterError';
    this.permanent = permanent;
  }
}

// Misconfiguration found at start-up; the dispatcher refuses to run.
export class ConfigError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ConfigError';
  }
}

export interface DeliveryRecorder {
  recordDelivery(row: {
    notification_id: number; adapter: string; channel: Channel; recipient_id: string;
    language: string; title: string; body: string;
  }): Promise<void>;
}

export function testAdapter(recorder: DeliveryRecorder): Adapter {
  return {
    name: 'test',
    async send(m) {
      // WhatsApp and SMS need a phone number; push goes to the user's devices.
      if (m.channel !== 'push' && !m.recipientPhone) throw new AdapterError('recipient has no phone number', true);
      await recorder.recordDelivery({
        notification_id: m.notificationId, adapter: 'test', channel: m.channel, recipient_id: m.recipientId,
        language: m.language, title: m.title, body: m.body,
      });
      return { providerMessageId: null };
    },
  };
}

const ENV_KEYS: Record<Channel, string> = {
  push: 'NOTIFY_PUSH_ADAPTER',
  whatsapp: 'NOTIFY_WHATSAPP_ADAPTER',
  sms: 'NOTIFY_SMS_ADAPTER',
};

const LIVE: Record<Channel, string> = { push: 'fcm', whatsapp: 'whatsapp', sms: 'sms' };

// Chooses one adapter per channel from the environment. Default: `test` everywhere.
export function selectAdapters(env: Record<string, string | undefined>, recorder: DeliveryRecorder): Record<Channel, Adapter> {
  const test = testAdapter(recorder);
  const result = {} as Record<Channel, Adapter>;
  for (const channel of Object.keys(ENV_KEYS) as Channel[]) {
    const choice = (env[ENV_KEYS[channel]] ?? 'test').trim() || 'test';
    if (choice === 'test') {
      result[channel] = test;
    } else if (choice === LIVE[channel]) {
      if (env.NOTIFY_LIVE_PROVIDERS_AUTHORIZED !== 'yes') {
        throw new ConfigError(`${ENV_KEYS[channel]}=${choice} needs founder authorization (NOTIFY_LIVE_PROVIDERS_AUTHORIZED=yes)`);
      }
      throw new ConfigError(`the ${choice} adapter is not implemented yet: choose a provider first (docs/PRODUCT_SPEC.md section 10)`);
    } else {
      throw new ConfigError(`${ENV_KEYS[channel]} must be "test" or "${LIVE[channel]}", got "${choice}"`);
    }
  }
  return result;
}
