# Combined local browser verification

2026-10-11, `integration/local-anuga`, Windows, installed Edge through repository
Playwright 1.56.1. Real production web builds, real Supabase clients, existing
synthetic project. No browser interceptions, mocked auth or data responses.

| App | URL | Result |
| --- | --- | --- |
| Ops | http://127.0.0.1:3100/login/ | HTTP 200, phone input confirmed |
| Family | http://127.0.0.1:3101/ | HTTP 200, Flutter renders, phone input confirmed |
| Companion | http://127.0.0.1:3102/ | HTTP 200, Flutter renders, phone input confirmed |

Zero page errors and zero failed browser requests on each app. Flutter semantics
enabled for automation, then real keyboard input entered. See
[browser-smoke.json](browser-smoke.json), [ops](ops-login.png),
[family](family-login.png), [companion](companion-login.png).

Backend probe in [backend-probe.json](backend-probe.json): phone provider is
disabled, so authenticated browser journey was not attempted. Both browser Edge
Function preflights pass (204, CORS). No hosted data changed and no OTP requested.
Local server traversal refused with 403, POST refused with 405. Loopback binding
only. Three separate origins preserve role sessions.

`scripts/check-all.sh` native exit 0: PGlite 142 pass / 8 real-Supabase skips,
ops 52, shared Dart 27, companion 39 / 3 skips, family 35 / 6 skips; all
install/format/lint/analyze/typecheck/build steps pass. Separate ops lint,
typecheck and test pass; separate companion and family analyze/test pass.
Launcher builds Next export and both Flutter release web apps. Flutter emits
non-failing upstream wasm/font warnings; the screenshots confirm rendered
Material icons. No tests weakened, dependencies added or access rules changed.

Latest source CI runs #2 38131473596, #4 38135461326, #5 38135464723,
#6 38135468540, #7 38135471172 all passed six jobs, including real Supabase.
The #7 log contains `JOURNEY PASSED` through test billing. Integration-head
CI results are recorded in HANDOFF after its PR run completes.

Local Docker real-Supabase suites/journey and Android device runs unavailable.
Native-language review not performed. Browser plugin could not bootstrap due to
the existing global Node module configuration; repository Playwright/Edge was
used instead. Logs and capture harness: ignored `artifacts/integration/`.

Founder steps and complete manual visit: [LOCAL_TESTING.md](../../LOCAL_TESTING.md).
