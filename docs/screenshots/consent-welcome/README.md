# Screens 04 Consent and 01 Welcome — delivery ledger

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
