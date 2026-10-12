# Tasks and milestones

## Founder testing: weekly visits (2026-10-12)

- [x] Visits per week 1-4 with matching weekday selection, separate from companion assignment; readable Show next date range; en/te/hi and 48px+ taps.
- [x] Founder chose replacement of future unstarted bookings: atomic Ops-only RPC, allowed/denied tests, cancellation/rebooking history, individual cancellations preserved, wall-clock past cutoff and stale-edit protection. No auth/RLS/state-machine change.
- [x] Final fast checks and separate app checks passed; contract export unchanged; five real-browser UI captures; independent review findings fixed.
- [ ] Feature PR and real-Supabase CI/full journey receipt.
- [!] Hosted Save: new migration must be applied to synthetic anuga through SQL Editor before feature publication. No hosted mutation, feature main merge or deploy yet.
- [ ] Founder tests frequency change, reload persistence and unchanged active/past visits on the updated combined site.

## Founder sketch UI streams (2026-10-11)

- [x] S2: inspect all 15 concept boards and seven previous ops screenshots; preserve source boards; define tokens and existing-screen mappings in `docs/design/tokens.md`.
- [x] S3: ops UI delivered as separate OPEN PR #5; full local checks pass; 23 browser captures. See that branch's docs/evidence/s3-ui/README.md.
- [x] S4: companion UI delivered as separate OPEN PR #6; full local checks pass; 38 curated widget captures. See that branch's docs/evidence/s4-ui/README.md.
- [x] S5: family/patient UI delivered as separate OPEN PR #7; full local checks pass; 25 curated widget captures. See that branch's docs/evidence/s5-ui/README.md.
- Runtime evidence, exact checks, differences and testing instructions must accompany each UI PR. No features are inferred from concept-only panels. Staging PR #2 is a separate dependency; PR #3 is obsolete.

Build one milestone at a time. A milestone is done only when its acceptance checks have run and
passed; record results (and checks that could not run) in `docs/HANDOFF.md`.

Goal of M1-M7, the **first working journey**: ops assigns a companion → family sees the booking →
companion completes pickup and hospital handover → family receives status → return journey completes.

Status: `[x]` done and verified · `[~]` in progress · `[ ]` not started · `[!]` blocked

## M0. Repo foundation `[x]`

- [x] Git repo, `.gitignore` (secrets, patient data, generated session state excluded), `.env.example`
- [x] `docs/PRODUCT_SPEC.md`, `docs/TASKS.md`, `docs/HANDOFF.md`, `docs/SETUP.md`, ADRs 0001-0003
- [x] `CLAUDE.md` and `AGENTS.md` point to the spec; BRD/CLAUDE.md conflict resolved (ADR 0001)
- [x] pnpm workspace root, Supabase CLI config (`supabase/config.toml`)

Acceptance: `pnpm install --frozen-lockfile` succeeds; `git status` shows no `.env`, `.remember/` or `node_modules/`.

## M1. Database core, permissions and the journey in SQL `[x]`

- [x] Schema: profiles, clusters, centres, patients, patient_access, consents, companions, packages,
      schedules (primary + backup), trips, trip_otps, trip_events, trip_transitions, notifications,
      audit_log, app_settings, vault_documents, vitals, medicines
- [x] Grants revoked by default; per-table/column grants; RLS on every table
- [x] RPCs: `create_patient`, `ops_assign_schedule_companions`, `ops_assign_trip_companion`,
      `ops_generate_trips`, `issue_pickup_otp`, `verify_pickup_otp`, `advance_trip`,
      `family_trip_board`, `companion_my_trips`, `vault_list_documents|vitals|medicines`
- [x] Synthetic seed with fixed ids
- [x] Tests: allowed + denied for each rule, full journey, exceptions, audited vault reads

Acceptance (all met 2026-10-08): `pnpm db:test` 55/55 pass on PGlite; `pnpm typecheck` clean;
mutation check (leak vault SELECT, disable companion window) makes tests fail.
Real Supabase run: passed, see M1a.

## M1a. Real Supabase verification `[x]`

Run the M1 suite on real Supabase (Postgres 17, real `auth` schema and roles, `storage` schema).
Path: CI job `supabase-local` (`supabase start`, `supabase db reset`, `pnpm db:test:supabase`);
manual path in `docs/SETUP.md`. `supabase/tests/platform.test.ts` adds storage-privacy, real
`auth.uid()` and anon-denial checks (skipped on PGlite).

Acceptance (met 2026-10-08, GitHub Actions run 37748137710 on `iamnawin/anuga` @ `487d409`):
all 4 migrations and the seed applied; `pnpm db:test:supabase` 60/60 pass, 0 skipped.
Real phone-OTP sign-in through Supabase Auth: covered since M3 (Playwright). Still not covered
(arrives with M8): private bucket policies and signed URLs.

## M2. Shared Dart package `[x]`

- [x] `packages/shared_dart` (pure Dart, no SDK dependency): `TripStatus`, `TransitionActor`,
      `TripStateMachine`, models for every M1 RPC result, `CompanionApi` / `FamilyApi` / `OpsApi`
      over an injected `RpcCaller`
- [x] Contract: `pnpm contract:export` writes `test/fixtures/trip_contract.json` from SQL;
      `supabase/tests/contract.test.ts` fails on SQL drift; Dart test fails on Dart drift
- [x] Flutter SDK configured (user PATH, `PUB_CACHE` on D:), commands documented in `docs/SETUP.md`
- [x] CI: `shared-dart` job (format, analyze --fatal-infos, test); actions bumped to v5

Acceptance (met 2026-10-08): `dart test` 16/16; `dart analyze --fatal-infos` clean; format check
clean; mutation (remove one Dart rule) fails the agreement test; `pnpm db:test` 57 pass, 3 skipped
(real-Supabase-only), `pnpm typecheck` clean.

## M3. Ops console: assign and monitor `[x]`

`apps/ops_console` (Next.js 16, TypeScript, pnpm workspace). Phone-OTP login against Supabase local
(`[auth.sms.test_otp]` in `supabase/config.toml` with synthetic numbers; no SMS provider).

- [x] Migration `0500_ops_console.sql`: `ops_schedule_board`, `ops_trip_board` (date/status filter,
      late flag), `ops_exception_queue`, `ops_companion_options` (eligibility + reason). Ops only;
      late threshold, lookback and board range in `app_settings`. Allowed + denied tests for each.
- [x] Phone OTP on Supabase local: seed `auth.users` rows in GoTrue's shape; test OTP `123456`.
- [x] Schedules list with primary/backup assignment (`ops_assign_schedule_companions`), showing
      eligibility errors from the database.
- [x] Trips board filtered by date/status; one-tap backup and reassign (`ops_assign_trip_companion`).
- [x] Exception queue: `issue_reported`, `no_show`, late; resolve actions derived from `trip_transitions`.
- [x] English, Telugu, Hindi strings (Telugu/Hindi drafted by the dev team; need native review).

Acceptance (met 2026-10-08, Claude Code cloud session with Docker): `pnpm lint`, `pnpm typecheck`,
`pnpm test` (Vitest 36/36), `pnpm build` pass; Playwright 6/6 against Supabase local, including
"ops signs in with phone OTP and assigns the backup companion to a trip"; screenshots in
`docs/screenshots/m3/`. `pnpm db:test` 72 pass / 3 skipped; `pnpm db:test:supabase` 75/75.
CI: job `ops-console`; Playwright added to `supabase-local`. GitHub Actions run 37769970593
(PR iamnawin/anuga#1): all jobs green, Playwright 6/6 on real Supabase in CI.

## M4. Companion app: run a trip `[x]`

`apps/companion_app` (Flutter 3.47.6, Android first) over `packages/shared_dart`.

- [x] Phone-OTP sign-in (no sign-up), companion-role gate.
- [x] Today/upcoming from `companion_my_trips` (restricted fields; hidden outside the window).
- [x] Check-in buttons from the shared state machine (`lib/src/trip_actions.dart`); pickup only via
      `verify_pickup_otp` with attempts left; optional handover note; return legs; required
      post-visit note; issue report with description; confirmed no-show; "call 108" notice.
- [x] English, Telugu, Hindi (ARB); text >= 1.15x, 56 dp buttons, light/dark high-contrast theme.
- [x] Android: INTERNET permission; debug-only cleartext to Supabase local (10.0.2.2).

Acceptance (met 2026-10-08, cloud session): `flutter analyze --fatal-infos` clean; format clean;
`flutter test` 41 pass + 1 skipped (widget tests for all 12 trip states, OTP errors, reassignment
and conflict errors, notes; full trip through the app widgets against a fake backend that enforces
the shared state machine). Mutation (offer pickup without OTP) fails 6 tests.
Extra: `test/supabase_local_test.dart` ran the companion journey on Supabase local (ops assigns,
viewer denied OTP, owner issues it, wrong then right code, return legs, completion, 8 family
notifications): pass. CI: job `companion-app` (+ `flutter build apk --debug`); the Supabase journey
runs in `supabase-local`.

## M5. Family app: booking and live status `[x]`

`apps/family_app` (Flutter 3.47.6, Android first) over `FamilyApi`.

- [x] Migration `0600_family_app.sql`: `family_my_patients` (with access level),
      `family_trip_timeline` (no locations or actor ids), `my_notifications` (push inbox).
      Allowed + denied tests (`supabase/tests/family_app.test.ts`).
- [x] `shared_dart`: `AccessLevel` (rules mirror SQL), `FamilyPatient`, `TripEvent`,
      `InboxNotification`; shared `RpcException`, `PhoneAuth` and India helpers (the companion app
      now uses them too).
- [x] Booking board (`family_trip_board`) with backup-covering label; visit timeline; pickup code
      (owner/editor/patient, only while awaiting pickup); cancel a scheduled visit (owner/editor,
      confirm + reason); updates inbox; patient picker; en/te/hi.

Acceptance (met 2026-10-08, cloud session): `flutter analyze --fatal-infos` clean; format clean;
`flutter test` 17 pass + 1 skipped, including "a viewer never sees the pickup code button, in any
status" and the access-level x status matrix; full app flow against a fake backend.
`test/supabase_local_test.dart` on Supabase local: viewer refused code and cancel by the database,
companion picks up with the owner's code, family cannot cancel once started, timeline and inbox
correct, companions refused the family read models: pass. `pnpm db:test` 81 pass / 3 skipped;
`pnpm db:test:supabase` 84/84; `dart test` (shared_dart) 24/24. CI: job `family-app`; the family
journey runs in `supabase-local`.

## M6. Notifications dispatch `[x]`

Edge Function `supabase/functions/notify-dispatch` (Deno entry; runtime-neutral core tested in Node).

- [x] Migration `0700_notification_dispatch.sql`: `dispatch_claim_notifications` (lease +
      `skip locked`, counts the attempt), `dispatch_mark_sent`, `dispatch_mark_failed`
      (exponential backoff, final `failed` after `notification_max_attempts`, or at once when
      permanent); service role only. `notification_deliveries` records what the `test` adapter "sent".
- [x] Adapters from env: `test` by default for push, WhatsApp and SMS; `fcm`/`whatsapp`/`sms`
      need `NOTIFY_LIVE_PROVIDERS_AUTHORIZED=yes` and are not implemented, so the function refuses
      to start with them. No live provider calls.
- [x] Messages in en/te/hi by the recipient's `preferred_language`. Status words only: a
      companion note (free text, may mention health) never leaves the database; the message says
      "open the app to read the companion's note" (found and fixed during M7).

Acceptance (met 2026-10-08, cloud session): `dispatcher_unit.test.ts` (13: rendering, adapter
selection, retry decisions, REST store); `dispatch.test.ts` (8: permissions, lease, expired lease,
backoff 60/120/240/480 s then failed, permanent failure, and a trip status change delivered to
owner and viewer in their languages via the test adapter, nothing sent twice).
`dispatch_function.test.ts` on Supabase local with the edge runtime: anon refused (403); service
role call delivers a status change. `pnpm db:test` 102 pass / 5 skipped; `pnpm db:test:supabase`
107/107. Scheduling the function needs a hosted project (M10).

## M7. End-to-end journey across apps `[x]`

`scripts/e2e-journey.sh` runs the first working journey in order against Supabase local, with the
real clients: the ops console in a browser (Playwright `e2e/journey.spec.ts`), the companion and
family Dart API layers (`test/journey_test.dart` in each app, same adapters as the apps) and the
`notify-dispatch` Edge Function. Helper: `scripts/journey.ts` (setup, dispatch checks, report).

Steps: today's visit (40 min ahead) -> ops assigns the backup in the console -> family sees the
booking covered by the backup; viewer refused the code, owner issues it -> companion sets off,
wrong code refused, family code accepted, centre, handover note -> dispatcher delivers; check that
no companion note leaves the database -> family timeline + inbox show the handover -> return
journey, completion note -> dispatch -> family sees completed -> ops board shows completed,
exception queue clear.

Acceptance (met 2026-10-08, cloud session): journey passed on Supabase local in ~60 s; evidence in
`docs/evidence/m7/` (log + 2 screenshots). The run first caught a real defect: notes were copied
into outbound messages; fixed in `messages.ts`, and the journey now fails if a note leaks (proved
against the stale function). CI: the journey runs at the end of `supabase-local` and uploads the
`journey` artifact. Flutter UIs on a device/emulator are not part of the run (no Android SDK in the
cloud session); their widgets are covered by the M4/M5 widget tests.

## M8. Vault UI and storage `[x]`

- [x] Migration `0800_vault_storage.sql`: private bucket `vault` (10 MB; JPEG/PNG/WebP/PDF; no
      object policies for app roles); `vault_create_document` (owner/editor + owner's vault
      consent; server-generated path; direct inserts revoked), `vault_upload_target`,
      `vault_mark_uploaded` (service role), `vault_document_download` (audited vault read, URL
      lifetime from `app_settings`); vault writes need the owner's vault consent;
      `family_consents`, `set_consent` (owner only, audited).
- [x] Edge Function `vault-files`: authorizes as the caller, then signs upload/download URLs.
- [x] Family app: Records tab (list, add report photo, view image via signed URL, pending state),
      Privacy and consent screen (per-purpose switches, confirm on withdraw), en/te/hi.
- [ ] PDF upload/view in the app: needs a file picker / viewer package (founder decision, see HANDOFF).
- [ ] Deleting existing vault data on withdrawal: the backlog deletion job (retention decision).

Acceptance (met 2026-10-08): SQL `vault_storage.test.ts` 11 (allowed/denied for every rule);
`vault_files_unit.test.ts` 6; `vault_files_function.test.ts` on Supabase local (upload -> confirm
-> viewer download, bytes match, read audited, companion/ops/anon refused, no direct or public
storage access, no overwrite); family app widget tests (access level x consent, upload sequence,
viewer, consent switches) and its Supabase-local vault test. `pnpm db:test` 120 pass / 6 skipped;
`pnpm db:test:supabase` 126/126; M7 journey still passes.

## M9. Payments (test mode) `[x]`

- [x] Migration `0900_payments.sql`: `invoices`, `invoice_lines`, `payments` (paise; no direct
      grants; audited). Fares: `ops_record_trip_fare` (pass-through at cost; frozen once billed).
      Invoices per patient and India-time month: completed visits at the package price + fares +
      the package's monthly fee (`ops_generate_invoice`, `ops_issue_invoice` notifies the owner,
      `ops_invoices`). Family: `family_invoices` / `family_invoice_lines` (owner and editors,
      issued bills only). Payments: `payment_start` (owner), `payment_set_order`,
      `payment_captured` (service role; idempotent; amount must match).
- [x] Edge Functions `payments` and `payments-webhook` (HMAC-signed bodies only). Adapter `test`
      by default; Razorpay adapter accepts only `rzp_test_` keys without founder authorization.
- [x] Ops console: fare entry for completed trips; Billing page (generate/rebuild draft, issue).
- [x] Family app: Bills tab (owner and editors), bill lines, test-mode payment for the owner.
- [x] Dispatcher: `invoice_issued` message with the amount in rupees (en/te/hi).
- [x] M7 journey extended: fare -> invoice -> bill notification -> owner pays -> ops sees paid.
- [!] Razorpay test-mode run: needs Razorpay test API keys and a webhook registration
      (not available). Razorpay Checkout in the app and UPI Autopay: founder decisions.

Acceptance (met 2026-10-08): SQL `payments.test.ts` 9; `payments_unit.test.ts` 10 (adapter
selection, order request, webhook signatures, handler); `payments_function.test.ts` on Supabase
local (forged webhook refused, signed webhook pays once, owner-only, test completion);
ops console Vitest 52, Playwright 7 + journey; family app 35 tests; journey passes with billing.
`pnpm db:test` 140 pass / 8 skipped; `pnpm db:test:supabase` 148/148.
Assumption to confirm: only `completed` visits are billed (`app_settings.billable_trip_statuses`).

## M10. Production launch `[!]` gated

Blocked by: pilot go/no-go metrics, health-tech legal review, brand name, Supabase Mumbai project,
paid services authorization, breach runbook with a named owner, real-Supabase test run.
Not started without explicit founder approval.

## Backlog (from spec, unscheduled)

Requests ("I need..."), medicine refill reminders, live companion location during active trips,
H3 density views and cluster density gate in ops console, monthly bill view, family invites with
roles, trip data export for pilot metrics, deletion job for consent withdrawal.

## Combined local testing (2026-10-11)

- [x] Combine tokens, all three UI streams and PR #2 browser support on integration/local-anuga from current main. Source PRs #2/#4-#7 preserved.
- [x] Full fast checks and separate app lint/analyze/tests; three release web builds; loopback HTTP and server boundary smoke passed.
- [x] Inspect latest source CI: all jobs passed on PR #2 and #4-#7, including real-Supabase journeys.
- [x] Local launcher and independent browser origins, synthetic accounts, active-window visit fixture and walkthrough in docs/LOCAL_TESTING.md.
- [!] Authenticated manual visit: synthetic hosted project Phone provider is disabled. Founder dashboard steps in LOCAL_TESTING; local Docker unavailable. No secrets in chat.
- [x] Integration PR #8 opened: https://github.com/iamnawin/anuga/pull/8. No main merge/deploy command; existing PRs intact. Existing Vercel Git automation created previews, recorded in HANDOFF.
- [x] Integration CI 38145315706 at 719361c: all six jobs pass, real Supabase 150/150 with zero skips, ops browser 7 pass, full cross-app journey and test billing pass, both debug APKs pass. Final receipt only docs and restored staging-script executable bit; no product changes after tested SHA.
- [ ] Founder manual browser journey after Phone-provider/test-number dashboard setup.

## Founder-authorized combined publication (2026-10-11)

- [x] Founder authorized PR #8 main merge and existing anuga.vercel.app synthetic publication; PR #8 merged, main CI passed all six jobs.
- [x] Hosted Phone enabled; real synthetic allowed/denied/CORS smoke passes.
- [x] Same-origin storage and BroadcastChannel regression reproduced/fixed; real browser sign-ins, independent reloads and isolated sign-out pass.
- [x] Final fast checks, separate app checks and all three web release builds pass; guarded Windows build output cleanup/sub-path support.
- [x] Authenticated Vercel CLI; existing project configured for prebuilt combined site, no new project or paid service.
- [x] Publish combined prebuilt to anuga.vercel.app: dpl_FHuVVy4Th8XzxEqQAz3Ekc1ZFyN3 at de8f72a. Four routes HTTP 200; three real role sign-ins/reloads and isolated companion sign-out pass.
- [x] Hosting fix PR #9 opened; source CI 38150546061 running. Documentation-only live receipt checked with git diff --check.
- [x] Publish fix PR #9 merged at 37bdae2c. Code CI 38150546061/de8f72a: six jobs pass, real Supabase 150/150 zero skips, ops browser 7 pass, full journey/test billing and APKs. Main product source matches deployed/tested code. Final doc-only receipt checked, no app rerun; receipt/main CI may be running.
- [ ] Founder manual active-window visit. Additive synthetic fixture and walkthrough remain in LOCAL_TESTING.
