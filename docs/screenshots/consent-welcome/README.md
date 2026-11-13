# Screens 04 Consent and 01 Welcome — delivery ledger

## Welcome verified — 2026-11-13 13:44:37 IST

Welcome is implemented on separate `feat/welcome-review`, based on Consent
`b5e9142838ccf04b58474cdf6257e5f05a9dea23` / [PR #33](https://github.com/iamnawin/anuga/pull/33).
Consent was committed and verified **before** Welcome code began. PR #33 CI
[43234936451](https://github.com/iamnawin/anuga/actions/runs/43234936451) completed
SUCCESS, all seven jobs; no merge or successful-job rerun. #32 remains unchanged.

Welcome implementation:

- Signed-out root is Welcome. Valid stored sessions still go directly through
  existing checking/database-role routing. Both Get started and Companion sign in
  push the **same existing LoginScreen**; no role hint, signup or separate account.
- Existing OTP handlers/validation, session storage, expiry/account restrictions
  and language persistence remain unchanged. System Back moves OTP→phone→Welcome;
  successful verification clears pushed routes. A guard prevents duplicate login
  routes from rapid taps. Own logout now returns Welcome; explicit expired/Ops/
  unassigned-account recovery keeps its existing phone sign-in path.
- Supplied clean illustration is a Flutter asset, unmodified, with the teal
  crew-neck shirt/chest logo. SHA-256 in docs and runtime asset:
  `BFB92B056BAAFA56C7FD976F1B46B2B807BE2E32C7EB2C704074291CB9582FFB`.
  Heading/body, choice chips, dropdown, both actions and footer are Flutter widgets,
  not a screenshot. Existing transparent branding/dark wordmark treatment reused.
- English remains default even with Telugu browser locale. Chip/menu selection
  uses the existing callback and exact `anuga-language` storage. Real browser
  Telugu/Hindi selection→reload→both phone actions passed. Synthetic footer kept.

Actual validation:

| Check | Result and evidence boundary |
|---|---|
| Welcome TDD | Initial 2 passed/29 failed (existing stored-session cases already passed); final new38 cases PASS |
| Unified suite | **87 PASS**, including old49 phone/OTP/session/role checks, new24 layout combinations, six light/dark accessibility-guideline checks, locale callback/back, both actions and double-tap guard |
| Family suite | **94 PASS, 6 documented skips**; unchanged from Consent |
| Analyzer/format | PASS; final analyzer reports no issues |
| Release web build | PASS on Nov13; same release/dart2js build with optional Wasm dry-run disabled, no workflow/app setting change |
| Broad fast checks | DB209/11 skip, Ops70 + build, shared29, Companion58/3 skip and all analyzers PASS. That script invocation then hit Windows Dart OOM at Family; Family94 and unified87 both passed on complete sequential reruns with identical assertions, no timeout increase or new skips. Do not label the interrupted script invocation itself successful |
| Browser matrix | **9 configurations**, 27 viewport captures +2 comparison sheets; four 360/390 English light/dark cases, English2×, Telugu/Hindi1×/2×. All actual release Flutter, not HTML reconstruction |
| Auth/network boundary | Welcome checks aborted every hosted request; observed hosted calls **0**. Both actions reached phone without submitting OTP. Consent captures used intercepted fixtures. No SMS, real login/session or hosted data change |
| Independent review | No material auth/navigation issue; suggested locale callback/AA tests and accurate logout names added and passed. Physical Pixel/native wording approval still pending |

[Dark comparison](welcome/comparison-dark.png) · [light comparison](welcome/comparison-light.png)
· [final browser results](welcome/results.json). Final capture completed
2026-11-13 13:39:50 IST. Original mockups under docs/design/screens-01-04 are
unchanged; screenshots preserve proportions and label separate top/middle/bottom
viewports. No invented light mockup or stitched fake full-screen evidence.

Visual improvement pass changed unselected language chips from inherited fills
to outlines, matching the supplied mockup; final release was rebuilt/recaptured.
Intentional differences: existing flat themes/platform font/minimum1.15 scale,
original logo proportions, and full clean illustration instead of reusing its
cropped mockup. Longer translations/200% text scroll rather than shrink or clip.
Small brand tagline stays in the approved lockup; ordinary copy remains localized.

Recovery/evidence history: Nov12 tool-session reset interrupted build checks;
later full-script Family run exhausted host memory, recovered sequentially. A
final recapture build failed starting DartWorker when Windows had ~480MiB free;
Nov13 retry succeeded without changing product code or reinstalling tools. Capture
helper bootstrap/choice-chip ARIA locators were corrected after actual UI was
visible but semantic locators were not; no test timeout was increased. Existing
Wasm/font asset advisory warnings were not treated as passing or failing tests.

## Pixel review and release boundary

Current server PID **14468**, `http://192.168.31.252:3114/app/` (same Wi-Fi),
loopback/LAN HTTP200 checked Nov13. Old PID37772 belonged to Nov12 and is historical.
**Sign out to review Welcome**; a valid existing session intentionally bypasses it.
For Consent, sign into an authorized synthetic Family account, keep/select the
patient in Home and open Privacy and consent. Explicit Save calls real staging
from a person's browser; capture fixtures do not intercept the phone's browser.

Review both themes, language selection/reload, both Welcome actions, OTP/back and
keyboard, patient-specific state, withdrawal confirmation, parent-vault/support
behavior and non-owner read-only access. Physical behavior and native-language
meaning require human review. Outstanding contract gaps remain: approved Privacy
Policy destination and any request-scoped support permission (currently standing).
No release gate promoted; production NO-GO, no merge/deploy/migrations. Next:
commit/push Welcome separately, record its PR, then STOP for founder Pixel review.


## Phase transition — 2026-11-12 19:43:23 IST

Consent committed/pushed as `b5e9142838ccf04b58474cdf6257e5f05a9dea23`,
[PR #33](https://github.com/iamnawin/anuga/pull/33) OPEN, base #32. Gate 5 met.
Welcome begins only after that verified checkpoint, on separate `feat/welcome-review`
branch from b5e9142. Same owned worktree/preview; no source PR edited or merged.


Codex session started 2026-11-12 19:08:40 IST. Worktree
`D:\AI-Workspace\Repos\anuga-consent-welcome`, Consent branch `feat/consent-review`,
starting at PR #32 `ca22a5d463d23eabffe8662b1de5b730959b7bc1`.
PR #32 OPEN; CI 43211837626 all seven jobs SUCCESS, observed at start. No merge.

## Acceptance gates written before implementation

1. Consent uses server values/per-row permissions and selected patient ID; no
   preselected mockup grants or writes before explicit Save. Allowed/denied tests.
2. Only edited differences call existing set_consent; confirmed withdrawal,
   dependent support grant, partial failure/reconciliation/retry verified.
3. Consent matches supplied hierarchy with explicit On/Off, trip requirement,
   separate optional vault, indented support option and truthful standing grant.
4. Consent loading/retry/denied/non-owner and en/te/hi/large-text are tested;
   release app captures 360/390 light/dark beside its mockup.
5. Consent committed/reviewable before Welcome implementation starts.
6. Welcome uses supplied clean illustration; Flutter renders controls/copy;
   signed-out entry only, existing valid sessions retain role routing.
7. Both Welcome actions open the same phone login, language defaults/persistence
   unchanged, stored sessions/OTP/account restrictions/Back regressions verified.
8. Welcome en/te/hi/large text and 360/390 light/dark captures compared to mockup.
9. Separate commits/PRs, truthful evidence and mandatory handoff updated; same-Wi-Fi
   preview delivered, no merge/deploy/hosted mutation. Physical review left open.

Checks will run directly using the task-authorized Flutter/analyzer/database
commands. Evidence/status is recorded below; no inherited gate commands or hooks
are installed. Runtime screenshots with fakes are labelled separately from real
Supabase verification. Do not claim physical/device/language approval from them.

## Contract inspection before Consent

- Existing Home patient selector remains unchanged; it opens Consent for selected
  patient. Consent itself has no independent selector. Show selected patient name.
- family_consents supplies actual active/can_change rows; set_consent returns bool
  and is owner-only. Multiple saves are separate non-atomic calls.
- Support access is a standing patient grant, **not per support request**. Vault
  Off blocks new writes but does not revoke existing support access to old records.
  Disable new support grants while vault off, allow existing grant withdrawal,
  and explain that support permission remains until separately withdrawn.
- No approved Privacy Policy destination found. Do not invent or activate a link.
- Backend evidence: 20261008000800_vault_storage.sql:183–221; audited vault reads
  20261008000400_vault_audited_access.sql:65–90; trip requirement
  20261102000100_family_care_requests.sql. Hosted Nov 4 hardening gaps remain
  separate and unverified by this UI task; PR #28 owns those gates.

## Consent verification checkpoint — 2026-11-12 19:40:46 IST

Consent implemented and verified; Welcome not started. Separate Consent commit
and review PR will precede Welcome implementation. Gates 1–4 met; gate 5 is the
commit/push checkpoint. Screens 01/04 mockups and clean illustration are retained
unaltered in `docs/design/screens-01-04/`; the clean illustration is not yet added
to runtime assets in this Consent-only change.

Actual checks:

- `scripts/check-all.sh`: PASS. DB 209 pass/11 skip; Ops 70 tests + lint/typecheck/
  build; shared Dart 29; Companion 58 pass/3 skip; Family **94 pass/6 skip**;
  unified **49 pass**. All analyzers pass. Full successful baseline CI not rerun.
- Focused PostgreSQL/PGlite consent/vault allowed/denied tests: **6 PASS**.
- New Consent save tests started RED 0/7, then passed. Additional tests verify
  no implicit support revocation, pending grant removal, RPC bool mismatch,
  busy controls and switch semantics. Full Family suite includes 24 layout
  combinations (360/390, light/dark, en/te/hi, 1×/2×).
- Release unified Flutter web build PASS. No Android config/workflow change.
- Running release web: **9 capture configurations**, **27 viewport captures +
  2 comparison sheets**. Four English width/theme cases; 360 dark 200% English;
  Telugu/Hindi 1× and 2×. [Dark comparison](consent/comparison-dark.png),
  [light comparison](consent/comparison-light.png), [results](consent/results.json).
- Captures use actual Flutter UI and Supabase adapters with all Auth/RPC replies
  intercepted as explicit synthetic fixtures; zero consent writes on load and
  patient ID checked. No hosted traffic, SMS, real authentication, migration or
  patient-data change. These are not hosted persistence/RLS or physical tests.
- Independent contract/code review completed. Its two findings were corrected:
  purpose labels on switches and truthful confirmation that withdrawal takes
  effect on Save. Final purpose semantics regression passes.

Intentional differences: existing flat themes/platform text/minimum 1.15 scaling
and 48px targets replace mockup gradients. Patient identity and existing grant
timestamps remain visible when returned. Content scrolls rather than shrinking
long translations. Support text describes a standing grant and existing-document
access truthfully. Save is disabled until explicit changes; the mockup's enabled
button/default On is not permission to grant consent. No fake Privacy Policy link
is rendered without an approved destination. No per-request support promise.

The first capture showed a tooltip/route-transition overlay; it was recaptured
after a real touch navigation and transition completion. Final top/middle/bottom
images were visually inspected. Physical Pixel/native-language approval pending.

New preview server PID **37772**, `http://192.168.31.252:3114/app/` (same Wi-Fi),
loopback HTTP 200 checked. PR #32 login preview on 3113 remains unchanged. Use
authorized synthetic accounts; select the patient in existing Family Home, then
Privacy and consent. Human Save clicks on the real preview call staging normally.
No merge/deploy. Next authorized phase: Welcome, after Consent commit/PR creation.
