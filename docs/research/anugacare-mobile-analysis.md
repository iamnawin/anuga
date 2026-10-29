# AnugaCare mobile analysis and framework decision

Date: 2026-10-22. Branch `feat/anugacare-hardening` (main `de28006` merged in).
Scope: the family and companion apps as a mobile product, the ops console as an internal web
tool. No framework migration was done. Database findings are in
`anugacare-db-findings-2026-10-22.md` (external review, retained as received).

## 1. Method

- The reverse-engineering skill (REA) only applies to shipped artifacts. For a full source
  repository its own rules say to use normal source analysis, so the source was audited with
  a code-audit workflow (entry points, trust boundaries, dependencies, permissions, journeys).
- **No APK exists.** CI builds debug APKs but doesn't upload them, and this machine has no
  Android SDK. Every APK check below is marked "needs a build".
- The shipped artifact that does exist is the hosted Flutter web build at
  `anuga.vercel.app/family/` and `/companion/` (3.4 MB and 3.1 MB `main.dart.js`). It was
  downloaded and scanned. REA `analyze_javascript_application` ran on the family bundle
  (Evidence `ev_cadbca1a...`) but ran out of memory on the dart2js output: coverage partial,
  no relationships recovered. The conclusions below use a direct scan of the artifact's strings.

Labels: **[V]** verified in source or artifact, **[B]** needs an APK or device build,
**[A]** assumption or judgement.

## 2. What exists today

| Item | Family app | Companion app |
|---|---|---|
| Screens | login, home (bookings, records, bills, inbox tabs), trip, record, consent | login, trips list, trip |
| Dart lines (excl. generated) | about 3,100 for both apps together [V] | |
| Shared package | `packages/shared_dart` 765 lines: models, API wrappers, `TripStateMachine` tested against the SQL contract [V] | |
| Widget tests | 35 pass, 6 skipped [V] | 39 pass, 3 skipped [V] |
| Dependencies | `supabase_flutter`, `image_picker`, `http`, `intl` [V] | `supabase_flutter`, `intl` [V] |
| Languages | en, te, hi ARB files [V] | en, te, hi [V] |
| Role check | `PhoneAuth.currentRole()` reads `profiles.role` [V] | same [V] |
| Duplicate code | `supabase_rpc.dart` identical; `auth.dart`, `format.dart`, `labels.dart` differ by 2 to 34 lines [V] | |

## 3. Mobile readiness findings

| # | Finding | Evidence | Severity |
|---|---|---|---|
| M1 | **No iOS project.** Neither app has an `ios/` folder. | [V] `ls apps/*/` | High if iOS is in scope |
| M2 | **Release builds use the debug signing key** in both apps. | [V] `android/app/build.gradle.kts:36` | High before any store upload |
| M3 | Two application ids `com.zeroorigins.family_app` / `companion_app`, version `0.1.0+1`. Final id not chosen. | [V] gradle, pubspec | Decide with X1 |
| M4 | **No push notifications client.** No FCM, no device-token table; notifications reach users only via the in-app inbox. | [V] pubspec, migrations | High for the product promise |
| M5 | **No location.** Only `INTERNET` permission; live companion location is backlog. | [V] AndroidManifest | Medium (spec says live location during active trips) |
| M6 | **No offline handling.** Every action is a direct RPC; no queue, no connectivity check, no retry. Companions in hospital basements will hit this. | [V] grep of `lib/` | High for companions |
| M7 | No crash reporting or analytics. | [V] pubspec | Medium |
| M8 | No deep links / app links (needed for invites, payment return, `anugacare.in` links). | [V] manifest has no intent filters beyond launcher | Medium |
| M9 | Family screen does not refresh live (DB review F08). | [V] `trip_screen.dart` | Medium |
| M10 | Accessibility: large tap targets (56 to 64 dp), high contrast, a `largeText` builder [V]. TalkBack labels and Indic text at 200% scale not verified. | [V] / [B] | Verify on device |
| M11 | Shipped web bundles carry only the Supabase URL and an **anon-role** JWT; no service-role key, no `sb_secret_`, no third-party SDKs, no source maps (map URL 404). HSTS set; no CSP or X-Frame-Options. | [V] artifact scan | Low (synthetic test site) |
| M12 | The staging anon key is committed in two workflows. Anon keys are public by design; rotate before production. | [V] `.github/workflows/deploy-*.yml` | Low |
| M13 | Release APK size, merged-manifest permissions from plugins, R8 output, cold start on a low-end phone, background kill behaviour. | [B] | Unknown until built |

## 4. Framework comparison

The requirements that matter for AnugaCare: one app for families and companions with role-based
screens; push plus WhatsApp; companion location during an active trip; elderly users in
English, Telugu and Hindi; companions working on poor networks; a small team; the database stays
the security boundary (so most business logic is in SQL whatever the client is).

| Criterion | Keep Flutter (improve) | Expo / React Native | Native (Kotlin + Swift) |
|---|---|---|---|
| Reuse of existing work | All of it: 3.1k lines of app code, 74 widget tests, shared Dart contract tests, ARB files, CI APK jobs [V] | Rewrite apps, tests and the TripStateMachine contract in TS; SQL and Edge Functions kept | Rewrite twice |
| One app with role-based navigation | `currentRole()` already exists; merge screens behind a role switch (X1, medium) | Same pattern (Expo Router groups) | Two codebases each do it |
| Push | `firebase_messaging` mature | `expo-notifications` / FCM mature | Best control |
| Location in an active trip | `geolocator` + foreground service; background needs care | `expo-location` + TaskManager; similar care | Best control |
| Accessibility for elderly users | Good: Semantics, text scaling; own text engine shapes Indic scripts | Native widgets give the best TalkBack fidelity | Best |
| Offline queue | `drift`/sqlite + retry; server must be idempotent anyway | `expo-sqlite` + retry; same server need | Same |
| Testing | Fast in-process widget tests already in place | Jest + RTL; Maestro/Detox for e2e | Espresso + XCTest, twice |
| Over-the-air fixes | Shorebird (paid tiers) | EAS Update, strong advantage | None |
| Code sharing with ops console | None (Dart vs TS) | Types and API wrappers could be shared with Next.js | None |
| iOS later | Add a target, needs a Mac to build | Same, EAS can build iOS in the cloud | Separate app |
| Cost to reach today's parity | 0 | About 3 to 5 weeks plus regression risk [A] | About 2x RN [A] |

## 5. Recommendation

**Keep Flutter, merge the two apps into one AnugaCare app, keep the ops console as Next.js web.**

- Switching gains OTA updates and TS sharing with the ops console. Neither fixes any open
  finding (M1 to M10 and the DB findings), and it costs a rewrite of working, tested code
  right before the pilot.
- Every high-priority gap (signing, push, offline, location, iOS) is a missing feature, not a
  limitation of Flutter.
- Revisit if: the team becomes TypeScript-only, or weekly hotfixes without store review become
  necessary (evaluate Shorebird first), or a key SDK has no Flutter support.

## 6. Proposed next steps (after the DB fixes)

1. **X1 one app:** new `apps/anugacare_app` (or rename `family_app`), route on `profiles.role`,
   move companion screens in, merge ARB files and tests, one CI APK job. Choose the final id
   (suggest `in.anugacare.app`). Companion-only permissions requested only in the companion view.
2. **Release signing:** upload key in CI secrets, Play App Signing; remove debug signing from
   release.
3. **Push:** FCM device-token table with grants and RLS, `push` adapter in `notify-dispatch`.
   Payloads carry no patient data (Firebase is a third-party SDK; founder approval required).
4. **Offline for companions:** queue trip actions locally with an idempotency key; make
   `advance_trip` accept a client action id so retries cannot double-apply.
5. **Live refresh (F08):** Supabase Realtime on the family trip screen plus refresh on resume.
6. **Device checks [B]:** install the Android SDK or upload CI APKs as artifacts, then measure
   size, permissions and TalkBack, and test on a low-end phone.
7. **iOS:** add the target when there is a Mac or a cloud build service; not needed for an
   Android-first Hyderabad pilot [A].
