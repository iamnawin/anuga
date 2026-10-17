# ANU-002 local verification — 2026-10-16

Branch docs/product-inventory-bootstrap, uncommitted over 69bbb36; fetched main
64c4603. No commit, push, merge, deployment or hosted mutation.
[Machine receipt/source hashes](verification.json), [full check-all output](check-all.txt),
[browser scenarios](browser-results.json), [task/blockers](../../delivery/tasks/ANU-002.md).

- scripts/check-all.sh: exit 0. Frozen pnpm install, root typecheck, PGlite
  142 pass/8 real-Supabase skips; Ops lint/typecheck/58 tests/build; shared Dart
  format/analyze/27 tests; Companion format/analyze/49 pass/3 environment skips;
  Family format/analyze/45 pass/6 environment skips.
- Both apps add 10 regression tests; Ops adds 6. Initial failing tests reproduced
  startup role bypass and missing/error/stale-profile conflation. Failures corrected
  before the final full run. No access policy/test skips were weakened.
- Shell syntax and whitespace checked. No SQL/contract changes, so no contract export.
- Browser: existing Playwright with installed Edge, loopback only. Four welcome
  locale/size/dark/text scenarios verify two hrefs, no overflow and screenshots.
  Five Ops phone/OTP/unconfirmed/error/denied scenarios have zero page errors.
  SDK endpoints use synthetic intercepted replies at anu002.invalid; no request
  reaches a hosted backend. Ops dev URL /login represents hosted /ops/login/;
  dedicated subpath remains existing build configuration, not a deployed check.
- Flutter: 20 local capture cases; 16 English screenshots curated below and
  inspected. Actual login widgets and copied app gate/theme source use test-only
  readable font substitutions and loaded Material icons, same layout/state logic;
  these are fixture renders, not device/real-auth acceptance. te/hi cases have no
  usable glyph fallback and are not visual acceptance. Native review remains open.
- Manual inspection: English phone, OTP, loading, missing profile, error, denial,
  dark and 200% text remain legible/scrollable. Welcome English/Telugu/Hindi
  renders correctly in the local browser. No full screen-reader review.

Skipped: real Supabase/Docker and app integration/journey tests (environment absent),
real provider OTP, same-origin independent-session smoke, combined staging builds,
Android/iOS device, native-language review. No release claim. Source hashes identify
the tested uncommitted code; a future commit/deployment must establish new receipts.
Pending/disabled lifecycle enforcement is blocked, not simulated as completed.

## Curated screenshots

- [family-phone.png](family-phone.png)
- [family-otp.png](family-otp.png)
- [family-loading.png](family-loading.png)
- [family-unconfirmed.png](family-unconfirmed.png)
- [family-error.png](family-error.png)
- [family-denied.png](family-denied.png)
- [family-en-dark.png](family-en-dark.png)
- [family-en-large.png](family-en-large.png)
- [companion-phone.png](companion-phone.png)
- [companion-otp.png](companion-otp.png)
- [companion-loading.png](companion-loading.png)
- [companion-unconfirmed.png](companion-unconfirmed.png)
- [companion-error.png](companion-error.png)
- [companion-denied.png](companion-denied.png)
- [companion-en-dark.png](companion-en-dark.png)
- [companion-en-large.png](companion-en-large.png)
- [welcome-en-360-light-1.png](welcome-en-360-light-1.png)
- [welcome-te-430-dark-1.png](welcome-te-430-dark-1.png)
- [welcome-hi-360-light-2.png](welcome-hi-360-light-2.png)
- [welcome-en-1440-dark-1.png](welcome-en-1440-dark-1.png)
- [ops-phone.png](ops-phone.png)
- [ops-otp.png](ops-otp.png)
- [ops-unconfirmed.png](ops-unconfirmed.png)
- [ops-error.png](ops-error.png)
- [ops-denied.png](ops-denied.png)

[Exact changed-file manifest](changed-files.txt): 69 files, including 25 curated
screenshots. Final scope/link/source-hash check passed: 299 existing local links,
19 tested source hashes unchanged, no staged changes, SQL/shared/home/ANU-003
paths unchanged. The manifest adds one receipt file; its link is also valid.
