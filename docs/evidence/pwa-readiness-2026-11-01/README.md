# AnugaCare PWA readiness - 2026-11-01

Founder direction: prioritize PWA and feature iteration; preserve existing
Android/APK support. Branch `feat/anugacare-mobile-readiness` starts from current
main `09a74f87c5679cb1604f159fc70404ad8924206f` (merged PR #18).
[PR #19](https://github.com/iamnawin/anuga/pull/19) carries this pass; automated
CI status is on its checks tab. No deployment, production launch, real patient
data or paid-provider activation.

## Build and run

The tested release web build uses the existing synthetic Supabase project
`vsvkllfgrnlbhdydysny` with its public anon client key from deploy-staging.yml.
No elevated credential is compiled into the app.

- Build: `apps/anugacare_app/build/web/` (ignored).
- Ready-to-serve copy: `artifacts/pwa-readiness/site/app/` (ignored).
- Served `main.dart.js` SHA256:
  `DD1D428D447DCE69B6D160C8040E74CB35265D9BA9F56E598537DA2CAE06D57A`.
- From repository root, run:
  `uv run --no-project python -m http.server 3190 --bind 127.0.0.1 --directory artifacts/pwa-readiness/site`
  then open `http://127.0.0.1:3190/app/`. Loopback is local-only; this is not a
  phone-accessible deployment. Stop with Ctrl+C.
- Rebuild with Flutter 3.47.6 using `flutter build web --release
  --no-web-resources-cdn --base-href /app/` and both public client dart-defines
  documented in SETUP. Existing hosted `/app/` has not been replaced by this PR.
- Android remains intact. The existing unified CI APK now includes those same
  public staging defines and uploads `anugacare-android-staging/app-debug.apk`.
  This corrects the previous compile-only APK that threw for missing settings;
  no SDK was installed locally and native runtime verification is pending.

## Results and limits

Passes below identify their surface. Desktop Chromium phone emulation is not
an Android emulator, a physical phone or an installed-PWA OS-level test.
Browser details and identity projections: [browser-results.json](browser-results.json).
The driver launched a separate disposable Chrome profile, not the founder's
browser session. It entered authorized synthetic credentials without storing
codes/tokens in this receipt. Backend changes were limited to auth sessions;
no trip, schedule, invoice or vault mutation was performed.

| Check | Result | Actual evidence |
| --- | --- | --- |
| Local Chrome installability | Pass | Persistent-profile Chrome, 360x780 touch viewport: CDP manifest errors and installability errors both empty. AnugaCare standalone display, /app/ start/scope/ID, valid branded 192/512 icons |
| Phone home-screen installation and standalone launch | Blocked | No physical Android/iOS device available; no actual installation claimed |
| English/Telugu/Hindi layout | Pass | Real-font release web screenshots: sign-in and populated Family/Companion homes at 360x780; visually reviewed for wrapping, controls and glyph rendering |
| English/Telugu/Hindi wording | Blocked | Layout/glyph review is not native-speaker or product-copy approval; Telugu/Hindi phrasing still needs approval |
| 200% text and keyboard space | Pass - widget only | Each locale at 360x640, text 1x/2x and 280 px simulated keyboard inset; phone/code submit, validation and change-number controls scroll into view and accept taps without layout exceptions. Real mobile IME remains unverified |
| OTP navigation | Pass - widget only | A route-back event on idle OTP returns to phone entry. Original implementation failed this regression. Browser-history Back and installed-PWA system Back are not established by this test |
| Family login/role | Pass - local browser + hosted auth | Verification 200, ID 20000000-0000-0000-0000-000000000001 / phone 919000000101; synthetic patient and bookings rendered |
| Family navigation/back | Pass - local browser | Records/Bills/Updates/Bookings tabs; scheduled booking detail and visible Back returned to list |
| Session reload | Pass - local browser | Reload after Family sign-in restored the Family home |
| Logout/account switch | Pass - local browser | Family and Asha logout/reload returned blank shared sign-in; new verified Asha identity opened My trips without Family tabs |
| Asha login/role | Pass - local browser + hosted auth | Verification 200, ID 30000000-0000-0000-0000-000000000001 / phone 919000000201 |
| Companion error/Retry | Pass - injected-error test | Aborted only trip-list RPC requests, observed generic error and recovery control, restored requests and Refresh recovered |
| Ops direction | Pass - local browser | Verification 200, ID 10000000-0000-0000-0000-000000000001 / phone 919000000001; Use the ops console, unified session absent, Back to sign in works. No new signed-in /ops/ journey |
| Loading/account errors/expired sessions | Pass - widget only | Existing unified tests exercise pending role lookup, network-error Retry, session expiry and access routing; no real slow-mobile-network pass inferred |
| Pause/resume and logout | Pass - widget only | Valid inactive/hidden/paused/resumed lifecycle sequence preserves each role and cannot restore a logged-out home. Does not establish OS background termination/token renewal behavior |
| Browser JavaScript errors | Pass | No pageerror events in final smoke run; earlier automation attempts failed input/locator handling and were corrected, not counted as application failures |
| Android emulator / physical Android runtime | Blocked | flutter doctor: Android SDK absent; flutter emulators: none; no connected Android device. No emulator/physical screenshots claimed |
| Offline service/data | Blocked / not promised | No custom offline cache or offline patient-data store added. Auth/trip operations require connectivity; offline launch/recovery not established |

## Screenshots

These are local release Flutter web screenshots from desktop Chrome at a phone
viewport, using the hosted synthetic data. They are not Android screenshots.

| Screen | English | Telugu | Hindi |
| --- | --- | --- | --- |
| Sign-in | [EN](en-login.png) | [TE](te-login.png) | [HI](hi-login.png) |
| Family home | [EN](en-family-home.png) | [TE](te-family-home.png) | [HI](hi-family-home.png) |
| Companion home | [EN](en-companion-home.png) | [TE](te-companion-home.png) | [HI](hi-companion-home.png) |

Also: [empty OTP](en-otp-empty.png), [Family detail](en-family-detail.png),
[injected error](en-companion-injected-error.png), [Ops guidance](en-ops-guidance.png).
No entered OTP is present in screenshots.

## Validation

- Baseline unified tests: 22 passed.
- New matrix: 15 passed. First run reproduced OTP route-back failure;
  two lifecycle failures were invalid test transitions, corrected in harness.
- Release web build passed with local web resources. Existing upstream
  CupertinoIcons-family warning remains; no new icon dependency introduced.
- Sequential `scripts/check-all.sh`: exit 0, ALL CHECKS PASSED. PGlite170
  passed/8 skipped; ops54; shared Dart27; companion47/3 skipped; family35/6
  skipped; unified37. All formatting/analyze/lint/typecheck/build checks passed.
  After adding stale-code/error assertions only, the focused15-test matrix
  was rerun and passed. `git diff --check` passed.
- Read-only code review: no blocking issues; physical/browser-history Back
  remains separate from Flutter route-back coverage.
- Reproduction source/logs retained locally under ignored
  `artifacts/pwa-readiness/` (`smoke.mjs`, `check-all.log`).

## Carry-forward gates

No new signed-in /ops/ journey. Hosted fixture cleanup remains pending.
Oct 31 fixture deadline has passed: refresh the narrow fixture before future
Previous/Today/Upcoming checks; this pass does not re-verify those groups.
The 180-minute companion start window remains provisional. Production launch,
real data and paid providers remain gated. Next manual step: install the
synthetic /app/ from a phone browser, then check actual keyboard, system Back,
background/resume and EN/TE/HI at enlarged text; obtain wording approval.
