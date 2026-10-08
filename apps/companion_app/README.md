# Companion app (`apps/companion_app`)

Flutter app (Android first) for verified companions to run a dialysis visit trip. A thin client over
`packages/shared_dart` (`CompanionApi`, `TripStateMachine`); the database enforces every rule.

- **Sign in:** phone OTP (Supabase Auth, `shouldCreateUser: false`); non-companion accounts are signed out.
- **My trips:** today and upcoming trips from `companion_my_trips()`. Patient essentials only, and only
  inside the configured window; never date of birth, diagnoses or vault data.
- **Trip screen:** one button per step allowed from the current status, derived from the shared state
  machine (`lib/src/trip_actions.dart`).
  - Pickup only through the family's OTP (`verify_pickup_otp`), with attempts left on a wrong code.
  - Optional handover note; required post-visit note at completion.
  - "Patient not available" asks for confirmation; "report an issue" requires a description.
  - Shows "call 108" for medical emergencies. The app does not dispatch help.
- **Languages:** English, Telugu, Hindi (`lib/l10n/*.arb`; Telugu/Hindi need native review). Text is
  at least 15% larger than the platform default, with 56 dp buttons.

## Run

```sh
flutter pub get
flutter run --dart-define=SUPABASE_URL=http://10.0.2.2:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=<from supabase status -o env>
```

On Supabase local, companion Asha signs in with `9000000201` and code `123456`.

## Checks

```sh
dart format --output=none --set-exit-if-changed lib/main.dart lib/src test
flutter analyze --fatal-infos
flutter test                                  # widget tests per state + full trip vs a fake backend
SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_PUBLISHABLE_KEY=... flutter test test/supabase_local_test.dart
```

The last command runs the companion journey against Supabase local: ops assigns the backup, the
family issues the OTP, and the companion completes the trip. It commits data, so run
`supabase db reset` first. It is skipped when the variables are not set.
