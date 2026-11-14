# Error handling: feature specification v1

Date: 2026-11-13. Task id: ERR-1. Author: Claude Code. Status: groups 1 to 3 are built locally on `feat/error-handling` (draft pull request, not merged); groups 4 to 6 are not started. Section 12 records what was built and what remains.
Code facts were read from `main` at e8e0063 (through the `feat/legal-documents` worktree, which has that commit merged).
Scope: the unified app `apps/anugacare_app` and its two packages `apps/family_app` and `apps/companion_app`. Ops console is covered only in section 9.

## 1. Why this feature

A patient's family or a companion may be on a weak mobile network, on an old phone, or half way through a trip step when something fails.
Today the app does catch most failures, but it answers almost all of them with one sentence, "Something went wrong. Try again."
The user cannot tell whether to wait, move to better signal, sign in again or call someone. A companion in the middle of a pickup needs to know that quickly.

The goal: every failure, on every screen, ends in a plain message that says what happened, what to do next, and a short code that support can ask for.
Technical detail is never shown to families or companions.

## 2. What exists today

| Item | Where | Notes |
|---|---|---|
| Database errors converted to `RpcException(code, message)` | `supabase_rpc.dart` in family and companion apps | Only `PostgrestException` is converted. Network errors pass through as raw SDK errors |
| Two known codes | `packages/shared_dart/lib/src/errors.dart` | `42501` not allowed, `22023` step not possible |
| Message mapping | `describeError()` in `family_app/lib/src/labels.dart`; a private copy in companion `trip_screen.dart` | Anything that is not `42501` or `22023` becomes the generic message |
| Three error strings (en, te, hi) | `errorGeneric`, `errorNotAllowed`, `errorStepNotPossible` | Same three in both apps |
| Family notice with a Try again button | `FamilyStateNotice` in `family_ui.dart` | Text and button only. No icon, no title, no code |
| Family offline banner | `FamilyOfflineBanner`, fed by `familyOnline` (web only; the non-web stub exists) | Used on the Family home only |
| Session expired and "could not check your account" screens | `AccountStage.expired` and `AccountStage.error` in `anugacare_app/lib/src/app.dart` | Good pattern: icon, title, body, primary action. Used only at sign-in and role lookup |
| Duplicate request message | `care_request_screen.dart` (`23505`) | Screen-specific |
| Ops console classifier | `apps/ops_console/src/lib/errors.ts` | Shows the raw database detail to ops on purpose |
| One line in each screen spec | Companion and Family FINAL specs | "Every screen needs: loading, error with retry, offline." No detail beyond that line |

Per-screen check (counted from the source, not from running the app):

| Screen file | Catches failure | Has retry or refresh | Knows about offline |
|---|---|---|---|
| Family: home, home tab | Yes | Yes | Yes |
| Family: bookings, bills, inbox, records tabs, trip, consent, care request | Yes | Yes | No |
| Family: record (single document), login | Yes | No | No |
| Companion: trips list, trip | Yes | Yes | No |
| Companion: login | Yes | No | No |
| Unified: login | Yes | No | No |
| Unified: welcome, account status; Family: legal document | Not needed (no backend call) | n/a | n/a |

## 3. What is missing

| # | Gap | Effect on the user |
|---|---|---|
| E1 | Network failure, timeout, server fault and app bug are not told apart | Same generic sentence for all; user does not know what to do |
| E2 | No time limit on any backend call (no `.timeout` found in the apps) | A stalled request can show a spinner with no end |
| E3 | No global catch-all: no `FlutterError.onError`, `PlatformDispatcher.onError` or `ErrorWidget.builder` in any app | An unexpected fault in a screen shows Flutter's blank grey area with no way out |
| E4 | Start-up can fail silently: `main()` throws if settings are missing and `Supabase.initialize` is not guarded | A white page on launch |
| E5 | Companion has no shared notice widget and no offline banner | Each companion screen draws its own red text |
| E6 | Offline is shown on the Family home only | Other screens let the user type and press Save while offline |
| E7 | No reference code on any message | Support cannot tell which failure a caller means |
| E8 | Nothing is recorded anywhere | Ops learns about failures only when someone calls |
| E9 | "Not found" (`P0002`) and "already exists" (`23505`) have no general message in the apps | They fall to the generic sentence, except on the care request screen |
| E10 | No stated rule for a write that times out (trip step, consent, payment) | Pressing Try again may repeat an action that already succeeded |
| E11 | Sign-in errors pass the provider's own message text into `PhoneAuthException` | To check: whether that raw text reaches the screen |
| E12 | No detailed design for error states in the screen specs or image boards | Builders invent a different look per screen |

## 4. Failure kinds and what the user sees

One list, used by every screen. Wording is a draft; Telugu and Hindi need a native-speaker review before real use.

| Kind | How it is recognised | Title | Body | Main action | Code prefix |
|---|---|---|---|---|---|
| Offline | Device reports no connection | No internet | Your changes will not be saved until you are back online. | Try again (enabled when back online) | OFF |
| Network | Request failed before a reply came | We could not reach AnugaCare | Check your signal and try again. | Try again | NET |
| Timeout | No reply within the time limit | This is taking too long | Your network may be slow. | Reads: Try again. Writes: Check status (see 5.4) | TIM |
| Session expired | Auth error or `PGRST301` / `PGRST303` | Please sign in again | You were signed out to keep your information safe. | Sign in again (existing screen) | SES |
| Not allowed | `42501` | You do not have permission for this | Existing wording per app | Go back | DEN |
| Out of date | `22023` | This is no longer possible | The visit has changed. Refresh to see the latest. | Refresh | OLD |
| Not found | `P0002` | We could not find this | It may have been removed or changed. | Go back | NFD |
| Already done | `23505` | This was already saved | Nothing more is needed. | Go back | DUP |
| Server | Any other database or function error | Something went wrong on our side | Try again in a minute. | Try again | SRV |
| App fault | Caught by the global handler | Something broke on this screen | Your saved information is safe. | Go to Home | APP |

Rules for every kind:

1. Never show the database message, a stack trace, an id or a table name to a family member or companion.
2. One main action only. A second action, "Call support", appears only after a support number exists. `[To be confirmed: support number]`
3. Calm colours: amber for things the user can fix (offline, network, timeout), the theme error colour only for app fault and server.
4. Text typed by the user is kept when an error appears (already promised in both screen specs).
5. Large text (200%) and screen readers: the title is a heading, the code is read as letters and digits.

Reference code format (as built): the prefix alone, or `PREFIX-CODE` when the database or an Edge Function gave a code, for example `NET`, `TIM`, `DEN-42501`, `SRV-P0001`. It contains no time, no message and no personal data.
Until gap E8 is closed the code only tells support the kind of failure; it is not a lookup key.

## 5. What needs to be built

### 5.1 Classifier (shared, pure Dart)
`packages/shared_dart/lib/src/failures.dart`: `enum FailureKind` and `FailureKind classifyFailure(Object error)`, plus typed `NetworkException` and `RequestTimeoutException`.
`shared_dart` has no SDK dependency today and must stay that way, so SDK and platform errors are converted in the adapters (5.2), the same way `PostgrestException` is converted now.

### 5.2 Adapters
The two `supabase_rpc.dart` files, plus `payments.dart`, `vault_files.dart` and the `auth.dart` files: convert network failures to `NetworkException`, add a time limit and convert it to `RequestTimeoutException`.
These are backend client files. They change how errors are named, not what is sent or who may call it. No RPC, RLS or auth rule changes.

### 5.3 Screen parts
- Family: extend `FamilyStateNotice` (icon, title, body, action, code) and `describeError`. Do not create a second notice widget.
- Companion: add the matching notice and an offline banner in the companion package, using the same keys and layout. Move the private mapping out of `trip_screen.dart`.
- Offline: show the banner on every screen that can save, and disable Save while offline.
- Strings: about 20 new keys per app in en, te and hi.

There is no shared Flutter package between the two apps. Recommended: one small notice per app sharing the classifier, not a new package (see decision ED3).

### 5.4 Rule for writes that time out
A trip step, a consent change or a payment may have reached the server even though no reply came back.
On timeout or network failure after a write: do not retry automatically. Reload the current state first, show it, and let the user act again only if the change is not there.
Payments follow `AnugaCare_Payment_Screens_Design.md` (waiting and failed screens) and are not redesigned here.

### 5.5 Global fallback and start-up
In `apps/anugacare_app/lib/main.dart`: set `FlutterError.onError`, `PlatformDispatcher.instance.onError` and `ErrorWidget.builder` to show the "App fault" screen with Go to Home.
Guard start-up so missing settings or a failed `Supabase.initialize` show a plain "AnugaCare could not start" page with Reload, in English (translations are not loaded yet at that point).

### 5.6 Recording failures (later, gated)
Option A: a `client_errors` table and one insert-only RPC storing kind, code, screen name, app version and time. No patient data, no free text. Needs a migration with allowed and denied tests.
Option B: an outside crash-reporting service. This is a third-party SDK and needs separate founder approval under the repository rules.
Recommended: neither in the first release; decide after the screens are done (decision ED4).

## 6. How to deliver it (one feature, small groups)

| Group | Content | Files | Conflict risk with open PRs |
|---|---|---|---|
| 1 | Classifier and its tests | New files in `packages/shared_dart` | None |
| 2 | Adapters: network and timeout conversion | `supabase_rpc.dart` x2, `payments.dart`, `vault_files.dart`, `auth.dart` x3 | Low |
| 3 | Family notice, mapping, strings, offline on saving screens | `family_ui.dart`, `labels.dart`, Family screens, ARB files | Low now that PR #37 is merged |
| 4 | Companion notice, offline banner, strings | Companion screens, ARB files | High with PR #36. Start after #36 merges |
| 5 | Global fallback and start-up page | `anugacare_app/lib/main.dart`, one new screen | Medium with PR #28. Start after #28 merges |
| 6 | Recording failures | Migration, RPC, tests | Separate approval |

Own worktree and branch (`feat/error-handling`), one draft PR per group or one PR with one commit per group. Groups 1 and 2 can start now without touching any other agent's files.

## 7. Tests

- Classifier: one unit test per kind, plus unknown input.
- Adapters: injected network failure and injected stall give the typed exceptions.
- Notice widgets: every kind in en, te, hi; light and dark; 100% and 200% text; no overflow.
- A test that fails if any raw database message text appears on a Family or Companion screen.
- Each saving screen: offline disables Save and keeps typed text.
- Write timeout: the action is called once, then a reload, never an automatic second call.
- Global fallback: a widget that throws shows the App fault screen and Go to Home works.
- Existing suites stay green: `flutter analyze --fatal-infos` and `flutter test` in all three apps, `dart test` in `shared_dart`. `pnpm db:test` only if group 6 is built.

## 8. Done means

1. No screen can show a spinner for longer than the time limit.
2. No path ends in a blank or grey screen.
3. Every failure shows one of the ten kinds in section 4 with one clear action and a code.
4. No database text reaches a family member or companion.
5. Family and Companion look and behave the same for the same failure.
6. Evidence: screenshots of each kind, and a physical-phone check in airplane mode on a trip step.

## 9. Not in this feature

- Ops console: it already classifies errors and shows the raw detail to ops on purpose. It has no global error page (`error.tsx` not found); that is a small separate task.
- Payment failure screens (own design document).
- Upload-specific states such as "file too large" (already listed per screen in the Family spec).
- Offline queueing of actions. The app stays online-only, as recorded in ARCHITECTURE.
- Any change to RPCs, RLS, consent or authorization.

## 10. Decisions needed from the founder

| # | Question | Recommendation |
|---|---|---|
| ED1 | Show a reference code to users? | Yes, small, under the message |
| ED2 | Time limit for a request | 20 seconds for reads and writes; 60 for file upload. Technical value, kept in one constant |
| ED3 | One notice per app, or a new shared Flutter package? | One per app, shared classifier |
| ED4 | Record failures: own table, outside service, or not yet | Not yet; revisit after group 5 |
| ED5 | "Call support" button | Add when the support number is confirmed |
| ED6 | Start group 4 and 5 before PR #36 and #28 merge? | No, wait |
| ED7 | Who reviews the Telugu and Hindi wording | A native speaker before any real use |

## 11. Image prompt for the design board (optional)

Create ONE presentation board, 16:9 landscape, soft off-white background (#F7FBFA), FOUR smartphone screens side by side (360x780 each, thin neutral device frame), captioned below each. Brand: AnugaCare, teal primary, warm amber for cautions, large text, high contrast, generous tap targets, for elderly users in India. All data is synthetic.
1. No internet: slim amber banner under the app bar "No internet. Your changes will not be saved", the Bookings list still visible below, Save button greyed out.
2. Could not reach AnugaCare: centred amber cloud-off icon, title "We could not reach AnugaCare", body "Check your signal and try again.", one large teal button "Try again", small grey text "Code NET-0000-2014".
3. This is taking too long (after a trip step): title "This is taking too long", body "Your network may be slow. We will check whether your last step was saved.", one button "Check status", code "TIM-0000-2015".
4. Something broke on this screen: calm red-outline icon, title "Something broke on this screen", body "Your saved information is safe.", one button "Go to Home", code "APP-0000-2016".
No stack traces, no technical words, no phone numbers, no real names.

## 12. Build status (2026-11-13 20:58 IST)

Worktree `D:\AI-Workspace\Repos\anuga-error-handling`, branch `feat/error-handling` from `main` e8e0063, fast-forwarded to 29a8356. Draft pull request. Not merged, not deployed. No migration.

### Built

| Group | What | Where |
|---|---|---|
| 1 | `FailureKind` (8 kinds), `classifyFailure`, `failureCode`, `guardRequest`, `NetworkException`, `RequestTimeoutException`, time limits 20 s and 60 s | `packages/shared_dart/lib/src/failures.dart` |
| 2 | Transport failures and stalled requests converted for database calls, payments, vault calls and file upload | Family `supabase_rpc.dart`, `payments.dart`, `vault_files.dart` |
| 3 | One sentence per kind; `FamilyFailureNotice` with icon, sentence, code and optional Try again; `FamilyOfflineHint` | Family `labels.dart`, `family_ui.dart`, nine screen files, three ARB files |

Screens now using the notice: Home (both places), Visits, Bills, Updates, Records, single Record, Consent.
Screens now showing the offline hint: Home (already had it), Consent, Care request, Visit.

### Checks run locally

| Package | Analyze | Tests |
|---|---|---|
| `packages/shared_dart` | clean | 39 passed |
| `apps/family_app` | clean | 128 passed, 6 existing skips |
| `apps/companion_app` | clean | 58 passed, 3 existing skips |
| `apps/anugacare_app` | clean | 91 passed |

Not run: `pnpm db:test`, `scripts/check-all.sh`, ops console checks, supabase-local journeys, CI, any browser or phone check. No screenshots were made.

### Differences from sections 4 to 6

- One sentence per kind, not a separate title and body. This kept every existing call site and avoided doubling the translated strings.
- No amber colour: the theme has no caution colour token, and adding one is a design-system change.
- The offline hint does not disable Save. The browser's connection flag is only a hint and can be wrong; the server stays authoritative.
- The support code has no time in it (see section 4).
- The standalone Companion app's adapter is unchanged and moves to group 4. In the unified app, Companion calls already go through the Family adapter, so they get the time limit and typed failures.
- `Offline` and `App fault` are not classifier kinds: offline comes from the device, and app fault belongs to the global handler in group 5.

### Still to build

| # | Item | Waits for |
|---|---|---|
| R1 | Group 4: Companion notice, offline banner, standalone adapter, its strings | PR #36 merged |
| R2 | Group 5: global fallback screen and start-up failure page (gaps E3, E4) | PR #28 merged |
| R3 | Sign-in messages (gap E11, now confirmed): the three login screens show the auth provider's own English text, and a network failure at sign-in is not caught by kind | Decision on wording; touches auth files |
| R4 | After a write times out, reload the state automatically (section 5.4). Today the timeout sentence asks the user to check | Per-screen work on Visit, Consent, Bills |
| R5 | Family places that still show a sentence without icon or code: Visit screen, pay-bill dialog. Care request uses the generic sentence for everything except permission and duplicate | Small follow-up |
| R6 | Offline detection on Android: the non-web helper always reports online. A connectivity plugin would be a new dependency | Founder approval for the dependency |
| R7 | Group 6: recording failures (gap E8) | Separate approval |
| R8 | Ops console global error page | Separate small task |
| R9 | Native-speaker review of six new Telugu and Hindi strings | Reviewer |
| R10 | Evidence: screenshots of each kind, airplane-mode check on a phone | After commit |
