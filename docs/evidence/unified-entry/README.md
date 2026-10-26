# Unified AnugaCare entry: evidence

2026-10-26, `feat/anugacare-unified-entry`, stacked on PR #12 (`feat/anugacare-hardening` at
f9285b8). ADR 0007.

## Screenshots

Real `AnugaCareApp` widgets built for the web (`flutter build web`, dart2js) and opened in Chromium
through Playwright at phone sizes, with real fonts. Data comes from the synthetic in-memory fakes
the family and companion tests already use. There is no Supabase in this preview, so these are not
device screenshots and do not exercise real sign-in, RLS or RPCs.

| File | What it shows |
| --- | --- |
| `360-en-light-login*.png` | Sign-in, number typed, code step, wrong code |
| `360-en-light-checking.png` | Stored session waiting for the role lookup (spinner mid-animation) |
| `360-en-light-family-home.png`, `-companion-home.png` | Role homes, unchanged screens from the two apps |
| `360-en-light-error.png` | Role lookup failed: Try again (keeps session) or Sign out |
| `360-en-light-expired.png` | Session expired, cleared |
| `360-en-light-ops-account.png`, `-no-role.png` | Ops account pointed to the console; unknown role refused |
| `360-te-*`, `360-hi-*` | Telugu and Hindi sign-in, homes, expired, error, refused |
| `430-en-dark-*` | 430 px wide, dark mode |
| `360-*-200pct-*` | Browser text at 200% |

Width 360 x 780 and 430 x 932 CSS px.

## What the review found

- **Fixed:** the new screens showed the localized brand (అనుగాకేర్ / अनुगाकेयर) in the app bar, while
  the family and companion screens show a fixed "AnugaCare" wordmark, so the bar changed script
  after sign-in. The new screens now use the same wordmark; the localized name stays as the window
  title.
- **Not fixed, pre-existing:** at 200% text the family home clips the patient card ("Centre 1") and
  the bottom navigation labels (`360-en-light-200pct-family-home.png`). It is the unchanged family
  `HomeScreen`, identical in the standalone family app on main. Left for a separate family UI
  change so this branch does not alter existing screens.
- **Kept as is:** a wrong code shows the auth server message ("Token has expired or is invalid"),
  as the family and companion logins already do.

The flutter_test golden route was tried first. The test engine draws text without an explicit
font family in its built-in test font, so many labels came out as boxes; it was used only to check
that five configurations (360/412 px, en/te/hi, dark, 100-200% text) render without layout
exceptions, and those images are not committed.

## Reference research: what was and was not inspected

Patterns were adapted, not copied: no proprietary code, assets, branding or layouts.

| Source | Inspected | Not verified |
| --- | --- | --- |
| Uber, `uber.com/in/en/drive/` | Public page: separate "Sign in to ride" and "Sign in to drive & deliver" entries; separate Driver app | Actual in-app screens (no device, no account) |
| Uber help: SMS verification, account creation | Help text: phone number, SMS code, resend, name and language at sign-up | Exact screen layout |
| `auth.uber.com` | Returned 403 | Everything on it |
| Practo, `practo.com/login` | Returned only "OpenId transaction in progress" | The login screen itself |
| Practo Play listings | `com.practo.droid` is a separate "Practo Pro - For Doctors" app | Listing screenshots (content did not load) |
| Practo mobile OTP login | Described only by third parties (Tata AIA customer page, a Scribd help document) | Practo's own current screens |

Adapted: phone plus SMS code (already built, kept); the provider and customer split, inverted: one
app where the database role picks the screens, with no chooser that could imply a privilege; a
"wrong product" state for ops accounts; language choice before sign-in (already built).

Skills: the reverse-engineer-anything (REA) skill was read; it excludes ordinary source analysis,
so no REA tool was run on any target. The code audit of both apps, `shared_dart`, auth, roles,
navigation, RLS and grants was done with normal repository tools.

## Reproduce

The capture sources are gitignored (`artifacts/unified-entry/preview_main.dart.txt` and
`ui_test.dart.txt` locally). To repeat: copy `preview_main.dart.txt` to
`apps/anugacare_app/artifacts/preview_main.dart`, run
`flutter build web -t artifacts/preview_main.dart --output <absolute dir>`, serve that dir on
127.0.0.1, open `/?lang=en|te|hi&as=family|companion|ops|none|checking|error|expired` at 360 px.
Remove the `artifacts/` folder from the app afterwards: `flutter analyze` scans it.
