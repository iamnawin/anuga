# LOGIN-001 — unified phone and SMS verification review

Codex session started 2026-11-12 16:11:55 IST. Isolated worktree
`D:\AI-Workspace\Repos\anuga-login-review`, branch `feat/unified-login-review`,
starting at PR #29 head `d75cf071ef5e54d5b47415aac612a11b8b08545f`.
PR #28 `6b8e63c` and PR #29 remain untouched.

## Approval and baseline

`docs/design/tokens.md` maps historical login to board 1 panels 02–03:
`Companion onboarding_ Start with trust-1.png`. Founder supplied
`AnugaCare mobile sign-in screen.png` in this task and explicitly approved mist,
white, mint, teal, navy and small marigold accents, plus a smaller OTP logo and
white card. That newer instruction controls phone layout. No newer OTP image
was supplied: OTP follows panel 03's code/change-number intent and the founder's
written compact-card direction. Do not claim a pixel-exact approved OTP mockup.

Approved original PNGs are `docs/logo/anugacare-lockup.png` and
`docs/logo/anugacare-symbol.png` (see logo README). They are reused unmodified.

Compared origin/main `ea6d142` with #29: #29 added a mint circle behind the symbol,
CarePanel around the fields, and an error container; it did not change Auth or
role routing. This branch is stacked on #29, not merged into #28/#29.

## Captures and comparison

Before screenshots show the running #29 Flutter release web app, 426×923 CSS px,
DPR 2 (852×1846 physical pixels, same as founder reference). The OTP send response
was stubbed by Playwright. UI is the real application, not HTML
reconstruction. Hosted authentication evidence will be labelled separately.

- `before-phone.png`, `before-otp.png`: captured before implementation.
- `reference-phone.png`: unedited founder attachment, 852×1846.
- `after-phone.png`, `after-otp.png`: final release app at the same viewport/DPR.
- `phone-comparison.png`: reference / before / after, scaled equally for viewing.
- `phone-overlay.png`: 50% pixel-aligned reference/after blend. No geometric warp,
  crop, screenshot reconstruction or score implying pixel identity.
- `otp-comparison.png`: before/after only; no supplied new OTP reference exists.
- `360-{en,te,hi}-{phone,otp}.png`: actual Chromium 360×780, real fallback fonts.
- `360-{en,te,hi}-200pct-{phone,otp}.png`: root font 32px before Flutter bootstrap
  (Flutter web derives 2× text scaling from root font); scrollable content can
  extend below the screenshot. Phone submits to the actual OTP screen in all three.
- `browser-results.json`: sanitized observations; no token or entered code.
- New acceptance tests first failed 0/2 against the old UI (missing lockup and
  new action label). Later layout/compile/selector failures are retained in ignored
  local logs; final results must be recorded before delivery.

Scope: unified app login only, locale persistence, focused tests and screenshots.
No role/RPC/RLS/provider changes, migrations, merge or deployment.

## Final implementation and intentional differences

Phone uses the approved original full lockup on mist, a labelled language menu,
white card, +91 prefix/divider, full-width teal action and the supplied copy.
OTP uses the original smaller symbol, existing six-digit field/autofill, same
card/palette, Verify code, and change-number. Keyboard opening moves the single
Verify action above the IME; step changes reset scroll so OTP opens at the top.
Busy buttons stay disabled across keyboard changes; errors remain live regions.

English is the default even with a Telugu browser locale. Explicit en/te/hi choice
is saved with SharedPreferencesAsync under the exact web key `anuga-language`
(JSON string value), validated at launch, and passed to the existing role homes.
No global SharedPreferences prefix or auth-session storage change. The already
locked shared_preferences 2.5.6 is now a direct dependency, without version upgrade.

The original logo PNG has different proportions from the newly generated mockup;
its wordmark/tagline are preserved rather than redrawn. Lockup SHA-256 in both
docs/logo and the app is `E458F9B8BCFC70558E9E3637CE7648B44F981139B324412EFBA5C08CE0614968`.
Platform sans, Flutter's minimum 1.15 scale, accessible outlined controls, flat
teal, 16px card radius, and synthetic-build notice differ deliberately. Large
translations wrap and scroll; single-line phone hints can ellipsize at 360px,
while the external field label and validation remain readable. Dark mode keeps
the existing theme with a mist backing for the light-only logo. At 2× Telugu,
long words wrap across lines; human review is still needed.

## Executed checks

| Check | Actual result / boundary |
|---|---|
| `scripts/check-all.sh` via Git Bash | PASS: root typecheck, DB 209 pass/11 skip; Ops lint/typecheck/70 unit tests/build; shared Dart 29; Companion analyze/58 pass/3 skip; Family analyze/58 pass/6 skip; unified analyze/43 tests at that point |
| Final `flutter test` in unified app | PASS 45, after adding pending-verify and scroll-reset regressions |
| Final `flutter analyze --fatal-infos` | PASS, no issues |
| Scoped format and `git diff --check` | PASS |
| Ops after E2E selector update | lint/typecheck PASS; Playwright `--list` discovers both journeys. Those two business journeys not executed locally in this task; CI status must be reported separately |
| Regression evidence | Original two layout tests RED 0/2; keyboard visibility RED→GREEN; scrolled phone→OTP RED→GREEN; final 45 pass |
| Busy/error/navigation coverage | Invalid phone/code, wrong/expired-code error, change number, system Back, pending-send/pending-verify, IME changes, expiry recovery, allowed Family/Companion and denied Ops/unassigned-account routes are exercised by widget tests |
| Hosted synthetic Auth | Final 2026-11-12 16:48:28 IST: real `/verify` 200 for existing Family, Companion and Ops test accounts; role lookup and reload pass; Family/Companion sign out to login; Ops directed to console and signed out. No business-record mutations |
| Visual locale persistence | Explicit Telugu/Hindi selection→reload PASS; English default PASS with te-IN browser. en/te/hi 1.15× and 2× captures visually inspected after fallback font loading |
| Independent review | Keyboard finding resolved; final reviewer reports no remaining material issue. First configured reviewer model unavailable; fallback native reviewer completed read-only review |

Auth send was stubbed for the **final** captures and hosted verification run;
verification/role reads were real. Earlier capture attempts missed query-bearing
OTP URLs after reload and reached staging Auth for synthetic test numbers, returning
a rate-limit error. Final driver matches those query URLs and asserts its stub
response header. No real SMS delivery is verified. Original premature font/OTP
captures were recaptured; no boxes/loading phone form is labelled as final OTP.
No trace/video or code/token-containing screenshots were retained in Git.

## Founder phone review — stop here

Local review server: `http://192.168.31.252:3113/app/` on the same Wi-Fi;
desktop `http://127.0.0.1:3113/app/`. Both returned HTTP 200 on this computer.
Hidden local server PID 35976; no firewall rule or public deployment created.
The phone's reachability and actual IME are NOT TESTED. If Windows blocks it,
do not disable the firewall; review access separately. Private IP may change.
This server is the real configured app: a person submitting a number will call
staging Auth normally. Use only the existing authorized synthetic test accounts;
automated capture stubbing does not affect the phone's browser.

1. Open on Android Chrome, English default; inspect original logo, palette, card,
   type, spacing and primary action against the comparison.
2. Choose Telugu, reload, then Hindi, reload, then English. Confirm persistence
   and ask a native reviewer to approve the changed intro/Verify copy.
3. Invalid number, authorized synthetic Family code, wrong/expired code, change
   number, and back. Confirm no role chooser and no new signup behavior.
4. Open the real keyboard on OTP at normal and larger Android font settings;
   verify the action stays above it and busy actions cannot be repeated.
5. Complete authorized synthetic Family and Companion login; refresh/sign out.
   Existing Ops guidance/unassigned-account refusal must remain. Do not create
   hosted users merely to execute the unassigned-account case.

Status: implemented and locally tested; awaiting founder login review, native
language approval and physical-device evidence. Not merged/deployed or production
approved. Next single task is founder login acceptance, not another feature or
BACKUP-002. The unresolved hosted hardening/recovery gates remain owned by PR #28.
