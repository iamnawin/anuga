# Combined synthetic publication verification

Founder authorized PR #8 main merge and all-three-app publication on 2026-10-11.
PR #8 is merged at 3c6f2ac; final head CI 38146021839 and merged-main CI
38148157637 passed all six jobs, including real Supabase/full journey and APKs.

Same-origin regression: the Flutter SDK broadcasts auth on a fixed project-wide
channel. Different persisted keys alone failed: family restored the companion's
identity after companion sign-in. Web-only app-specific storage keys plus scoped
auth channels fix this. Native defaults and all OTP/RPC/RLS rules remain unchanged.

`scripts/web-session-smoke.mjs` runs the real apps with real synthetic Phone OTP
auth, one shared browser context and separate tabs. Each role signs in, reloads
with its own identity, and companion sign-out preserves ops/family sessions.
Final local combined-build smoke passed with zero page errors. No auth/RPC mocks
or interceptions. [Local receipt](local-session-receipt.json).

Final `scripts/check-all.sh` exit 0: PGlite 142 pass/8 environment skips, ops 52,
shared Dart 27, companion 39/3 skips, family 35/6 skips, all format/analyze/lint/
typecheck/build steps pass. Separate ops lint/typecheck/test and both Flutter
analyze/test pass. Three final release web builds pass. JS/shell syntax and diff
whitespace pass. Existing non-failing upstream Flutter wasm/font warnings retained.

Hosted `scripts/staging-smoke.ts` passed: allowed synthetic role reads, forbidden
ops reads by family, forbidden patient/vault access by companion, anon denial and
function CORS. No hosted seed reset or clinical data. No new paid provider/project.
Android/device and local Docker journey unavailable; native te/hi review not run.

Vercel CLI authenticated as founder; existing anuga project configured for root/
Other and combined prebuilt publishing. All-three-app manual workflow added;
Git auto-deploy disabled to prevent ops-only replacement. Site is LIVE at
[anuga.vercel.app](https://anuga.vercel.app), published source de8f72a, deployment
dpl_FHuVVy4Th8XzxEqQAz3Ekc1ZFyN3. Root and all three apps HTTP 200. The same
real-browser session regression passed on the published domain, zero page errors.
See [deployment.json](deployment.json), [published session receipt](published-session-receipt.json).
PR #9 merged at 37bdae2c. [Code CI 38150546061](https://github.com/iamnawin/anuga/actions/runs/38150546061)
at de8f72a passed all six jobs, real Supabase 150/150 zero skips, ops browser 7,
both apps' real-Supabase tests, full journey/test billing and both APKs.
[CI receipt](ci-summary.json). Main app/build/security code matches verified
published source; later receipts are documentation-only, with new CI possibly
running. Founder manual active-window visit remains the next check.
