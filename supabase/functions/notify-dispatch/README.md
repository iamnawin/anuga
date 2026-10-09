# notify-dispatch (Edge Function)

Drains the `public.notifications` outbox once per call: claim due rows (lease + `skip locked`),
render the message in the recipient's language, send it through the channel's adapter, then mark
each row `sent` or failed. The database decides between a retry with exponential backoff and a
final `failed` (`dispatch_mark_failed`, `app_settings.notification_*`).

| File | Role |
| --- | --- |
| `index.ts` | Deno entry (`Deno.serve`). POST only; refuses any caller whose JWT role is not `service_role` |
| `dispatcher.ts` | `dispatchOnce` / `drain`, runtime-neutral (also run by the Node tests) |
| `adapters.ts` | Adapter per channel from env; `test` records to `public.notification_deliveries` |
| `messages.ts` | Texts in en/te/hi (Telugu/Hindi need native review); no health data in messages |
| `rest_store.ts` | PostgREST calls with the service-role key |

## Adapters and environment

| Variable | Values | Default |
| --- | --- | --- |
| `NOTIFY_PUSH_ADAPTER` | `test`, `fcm` | `test` |
| `NOTIFY_WHATSAPP_ADAPTER` | `test`, `whatsapp` | `test` |
| `NOTIFY_SMS_ADAPTER` | `test`, `sms` | `test` |
| `NOTIFY_LIVE_PROVIDERS_AUTHORIZED` | `yes` only after founder authorization | unset |

Choosing a live adapter without `NOTIFY_LIVE_PROVIDERS_AUTHORIZED=yes` stops the function with a
configuration error. Live adapters are deliberately **not implemented**: they need a chosen
WhatsApp provider (open decision, `docs/PRODUCT_SPEC.md` section 10), a Firebase project, and
device-token storage. With authorization alone, the function still refuses to start.

## Run and test

```sh
pnpm dlx supabase@2.120.0 start -x studio,logflare,vector,imgproxy    # keeps the edge runtime
curl -X POST http://127.0.0.1:54321/functions/v1/notify-dispatch -H "Authorization: Bearer <SERVICE_ROLE_KEY>"
pnpm db:test     # dispatcher_unit.test.ts + dispatch.test.ts (SQL + dispatcher on PGlite)
SUPABASE_URL=... SUPABASE_ANON_KEY=... SUPABASE_SERVICE_ROLE_KEY=... DATABASE_URL=... pnpm db:test:supabase
```

Scheduling (not set up: no hosted project yet): call the function every minute, e.g. with
`pg_cron` + `pg_net` on the hosted project, or any scheduler holding the service-role key.
