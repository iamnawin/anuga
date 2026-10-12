# Weekly visits UI evidence

2026-10-12, `feat/weekly-visit-pattern`. Five captures from the real local Next app at loopback port 3112 after actual synthetic hosted Ops phone/OTP sign-in. Actual schedule/Trips reads, no auth or API mocks. Save was **not attempted** on hosted Supabase because its new RPC is not installed. Database behavior is covered separately by nine SQL tests, API/form tests and the new real-Supabase browser CI regression.

- `trips-mobile.png`: Show next, 1 day / 3 days / 1 week / 2 weeks, existing date/status behavior.
- `pattern-mobile-en.png`, `pattern-mobile-te.png`, `pattern-mobile-hi.png`: 390px mobile layout, select two visits and uncheck Wednesday, same-number validation, replacement notice, Save/Cancel. All weekday targets at least 48px in both dimensions, no page overflow or page errors.
- `pattern-desktop.png`: 1440px desktop layout, same actual form/state.
- `receipt.json`: measured control sizes and the explicit hosted-save limitation. No sessions or tokens retained in evidence.
- `ci-weekly-visits-mobile.png`, `ci-trips-range-mobile.png`: captures from the successful real local-Supabase CI browser suite, which saved, reloaded and restored the weekly pattern. Separate from the hosted read-only local UI captures above.
- `ci-summary.json`: all-six-job success at code 56bd5c6, real Supabase 159/159, Ops browser 8 and full connected journey/APKs.

## Intentional differences from the sketches

Schedules uses the existing Ops schedule cards and mint inline form rather than adding a booking wizard from recurring-setup panels 09-12. The founder's new request adds frequency/day editing only: no plan selector, payments step or clinical frequency advice. Primary/backup assignment remains a separate action. A saved count and weekday summary remain visible above the editor so pending selections do not pretend to be saved.

Trips keeps the sketch-derived table/sidebar/filter hierarchy; only the ambiguous Days label and numeric option display change. The underlying 1/3/7/14-day query range stays intact. Dev captures show Next's local development indicator; it is absent from a release build. User-provided design tokens, mint/teal/navy palette, mobile stacking and focus treatment are reused.

## Validation

Final scripts/check-all.sh passed, database 151 pass/8 real-only skips, Ops 55, shared Dart 27, companion 39/3 skips and family 35/6 skips. Separate app lint/typecheck/analyze/tests passed. Contract export unchanged. Independent review fixes for audit provenance and clock-time cutoff are regression tested. Code 56bd5c6 CI 38247279751 passed all six jobs: real Supabase 159/159 zero skips, Ops browser 8 including actual weekly save/reload/restore, both connected app journeys, full journey/test billing and both debug APKs. All three release web builds and combined loopback session-isolation smoke passed. Native te/hi review and physical mobile/Android testing remain unrun. No hosted mutation or feature deploy. This receipt changes documentation/evidence only; final whitespace checked without repeating app tests.
