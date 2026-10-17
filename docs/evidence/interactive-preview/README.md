# Interactive synthetic preview publication

17 October 2026. Sole coordinator, branch `feat/anu003-family-first-use`, base
`96bdc59527d6f2277f484d09eb057c925147b849`. Latest recorded founder authority
includes owned ANU-003/demo commits, a normal branch push and separate publication.
No main merge, hosted backend mutation or actual-user rollout.

**Open https://anuga-interactive-preview.vercel.app.** No Vercel login is needed.
[Guide, demo phones and build commands](../../../preview/README.md).

Actual app web builds run within an always-labelled simulation shell. The build
uses `synthetic-anuga.invalid` and a deliberately invalid public demo key. A
service worker and IndexedDB simulate sign-in, lifecycle states, role permissions,
trip transitions, assignments, notifications, records/consent and test payments.
Cross-role tabs see the same simulated state. Reload persists it; reset restores
fixtures. This is not real Auth/database/security/provider acceptance.

The supported ANU-003 Family UI and its prior local evidence are included;
patient creation, new schedules, owner-consent intake procedure, help destination
and simplified Patient routing remain blocked. Existing app Auth/RPC/SQL/shared
contracts were not changed by this continuation. No new dependency was added.

## Checks actually executed

| Check | Result |
| --- | --- |
| `node --test preview/demo-core.test.mjs`, fresh final run | 6 passed, zero failures/skips: known-account/code validation, role/lifecycle simulation, complete simulated visit/required note, assignments/billing, four Family levels/revocation, payment, local file/consent/reset |
| `node preview/verify-browser.mjs`, local compiled apps | 8 passed; [results](local-browser.json) |
| Same browser test against the public alias, final run | 8 passed; [results](hosted-browser.json), [6 captures](screenshots/) |
| `bash scripts/check-all.sh` | Exit 0: PGlite 157 pass/9 real-only skips, Ops 60, shared Dart 28, Companion 51/3 skips, Family 58/6 skips; format/analyze/lint/typecheck/build passed; [full receipt](check-all.txt) |
| Build/deploy inspection | Initial actual three-app prebuilt build passed; dedicated demo deployment READY, alias HTTP 200; [137 asset hashes/deployment IDs](deployment.json) |
| Existing site | `vercel inspect https://anuga.vercel.app` still resolves to the historical `dpl_FHuVVy4Th8XzxEqQAz3Ekc1ZFyN3`; HTTP 200, no simulator shell |
| Published static configuration scan | No configured `https://<project>.supabase.co` URL or private-key block. SDKs contain the literal `sb_secret_` rejection prefix, not a secret key |

Hosted browser assertions: invalid-phone rejection; Family owner sign-in and
two-patient home; Ops sign-in/trips; Companion sign-in; Family pickup-code issue;
Companion verifies the separate code and reaches picked-up; Ops refresh sees the
same update; Family reload retains role session/state and sees picked-up. No
page errors or observed hosted Supabase requests. The full completion/note,
records/consent/payment and other permission scenarios are simulator unit checks,
not claims that all those forms were browser-tested on the public deployment.

## Deployment and verification limitations

The first protected preview on the existing `anuga` project was not usable:
Vercel protection redirected its service-worker script request. Vercel CLI
generated a project automation-bypass token during diagnosis; it and its cookies
remain only in ignored local state. No existing-project protection setting or
production alias was changed. The protected draft was retained.

Created the separate `anuga-interactive-preview` project. Its public production
alias serves this synthetic preview only; it is not the Anuga M10 launch. The
existing site's deployment, Supabase and real data are unchanged.

Hosted Edge transfers initially stalled, and the harness's global `networkidle`
wait timed out despite the Family screen rendering and sign-in succeeding.
Final verification used `ANUGA_DEMO_HTTP1=1`, a three-minute first Flutter-load
ceiling and screenshot capture after actual screen assertions. No downloaded
asset, app response or backend call was replaced by the harness. These transport
settings apply only to automation; initial downloads may take time.

Browser result command, from repository root:

```powershell
$env:ANUGA_DEMO_SITE='https://anuga-interactive-preview.vercel.app'
$env:ANUGA_DEMO_EVIDENCE='artifacts/interactive-preview/public-browser-final'
$env:ANUGA_DEMO_HTTP1='1'
node preview/verify-browser.mjs
```

Native devices, screen readers, human te/hi review, full accessibility, hosted
real-backend lifecycle/security, actual roster/operator and rollout decisions
were not rerun or approved. Existing ANU-002-VERIFY and ANU-003 B1-B4 remain open.
No new PR or merge. Commit/push receipts are recorded in HANDOFF; historical
ANU-003 evidence remains a dated local receipt, not rewritten as hosted evidence.
