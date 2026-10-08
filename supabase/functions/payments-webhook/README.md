# payments and payments-webhook (Edge Functions)

Shared code: `supabase/functions/_shared/payments.ts` (runtime-neutral; Node tests import it).

| Function | Auth | Does |
| --- | --- | --- |
| `payments` | user JWT (platform-verified) | `start`: `payment_start` (owner, issued bill) -> adapter creates an order -> `payment_set_order`. `complete-test`: test adapter only; same owner check, then what a provider webhook would do |
| `payments-webhook` | `verify_jwt = false`; **HMAC-SHA256 body signature** (`X-Razorpay-Signature`) | verified `payment.captured` -> `payment_captured` (idempotent; amount must match) |

## Adapters

| Variable | Meaning |
| --- | --- |
| `PAYMENTS_ADAPTER` | `test` (default) or `razorpay` |
| `PAYMENTS_WEBHOOK_SECRET` | required; signs/verifies webhooks (local placeholder in `config.toml`) |
| `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET` | Razorpay keys; only `rzp_test_...` keys are accepted |
| `PAYMENTS_LIVE_AUTHORIZED` | `yes` allows live keys: founder authorization only |

Card/UPI data never reaches us: the provider collects it and sends ids and amounts.

**Not built (needs founder decisions / credentials):** Razorpay test-mode keys and a webhook URL
registered in the Razorpay dashboard; the Razorpay Checkout SDK in the family app (a third-party
SDK that receives payment data); UPI Autopay subscriptions for monthly plans.
