# Interactive synthetic preview

This wraps the actual Family, Companion and Ops web builds in a labelled demo
shell. A service worker answers requests to `https://synthetic-anuga.invalid`;
IndexedDB holds synthetic state in this browser. There is no hosted Supabase
connection, real account, SMS, clinical record or payment. Never enter real data.

Preview: https://anuga-interactive-preview.vercel.app

The dedicated `anuga-interactive-preview` Vercel project serves only this demo.
No Vercel sign-in is required. The existing `anuga.vercel.app` site is separate.
The Demo guide lists all accounts, limitations and reset/error/loading scenarios.

| App | Demo phone | Sign-in code |
| --- | --- | --- |
| Family owner | 9000000101 | 123456 |
| Companion Asha | 9000000201 | 123456 |
| Ops | 9000000001 | 123456 |

Open this URL in three tabs, choose one app per tab, and sign in. In Family,
open the visit and get its pickup code. In Companion, start the outward journey,
enter that separate pickup code, and advance the visit. Refresh Family and Ops
to see the same browser-local visit. Reload retains state; Demo guide > Reset
restores all synthetic fixtures and signs out the demo apps.

The simulator supports existing screens for assignment, visit transitions,
records, owner purpose-consent and test billing. Its permissions and timing are
simulations, not database security evidence. Patient intake/schedule creation,
invites, real tracking, an approved help destination and simplified Patient mode
remain unavailable. Native/human-language/accessibility and rollout gates stay open.

## Build and verify

From the repository root, using installed Flutter and pnpm dependencies:

```sh
node scripts/build-interactive-preview.mjs
node --test preview/demo-core.test.mjs
node preview/verify-browser.mjs
```

The build writes only ignored `artifacts/interactive-preview/.vercel/output` plus
the apps' normal ignored build directories. It does not deploy. Browser checks
use the installed Playwright/Edge and bind the local server to `127.0.0.1:3210`.
For an authorized hosted check, set `ANUGA_DEMO_SITE` to the exact preview URL,
`ANUGA_DEMO_EVIDENCE` to an ignored results directory, and optionally
`ANUGA_DEMO_STORAGE_STATE` to an ignored Playwright storage-state file containing
the authenticated Vercel preview cookie. Never commit cookies or bypass tokens.
If the automated browser stalls on hosted HTTP/2 transfers, set
`ANUGA_DEMO_HTTP1=1`; this changes the test browser transport only. Flutter's first
load has a three-minute ceiling for its renderer download.

Publication uses the already-linked ignored artifact directory and Vercel CLI:

```sh
pnpm dlx vercel@59.26.0 deploy --prebuilt --prod --yes
```

Run that command inside `artifacts/interactive-preview` only with publication
authority and after checking `.vercel/project.json` names `anuga-interactive-preview`
(project ID `prj_31olZNOfP2UD4kW24PBp9hB1HVVx`). This project's production target
is the public synthetic demo, not the Anuga product release. Never run it linked
to `anuga`, and do not promote this simulation to the existing production domain.
