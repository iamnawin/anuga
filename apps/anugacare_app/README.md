# AnugaCare app (`apps/anugacare_app`)

The single AnugaCare mobile app (ADR 0007): one sign-in for families, patients and companions,
then the home for the role the database reports. It mounts the existing screens of
`apps/family_app` and `apps/companion_app` unchanged; both still build on their own during the
transition.

- **Sign in:** phone, then SMS code (Supabase Auth phone OTP, no sign-up from the app). No role
  picker.
- **Routing:** after every sign-in, and on launch with a stored session, `profiles.role` decides:
  `family` opens the family home, `companion` the companion trips. The database still checks every
  RPC, so this only decides which screens appear.
- **Accounts this app cannot open:** `ops_admin` is signed out and pointed to the ops console; no
  profile or any other role is signed out and refused.
- **States:** checking (spinner until the database answers), failed lookup (Try again keeps the
  session, or Sign out), expired session (cleared, Sign in again; also when it ends while a home is
  open).
- **Languages:** English, Telugu, Hindi (`lib/l10n/*.arb` for the new screens; the homes use their
  own app's strings). The choice on the sign-in screen carries into the home. New Telugu/Hindi
  strings need native review.

## Run

The family and companion apps generate their localizations on `pub get`, and path dependencies do
not, so run it there first:

```sh
(cd ../family_app && flutter pub get) && (cd ../companion_app && flutter pub get)
flutter pub get
flutter run --dart-define=SUPABASE_URL=http://10.0.2.2:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=<from supabase status -o env>
```

Only the publishable (anon) key belongs here, never a service-role key. On Supabase local, with
code `123456`: `9000000101` (family owner), `9000000102` (family viewer), `9000000201` (companion),
`9000000001` (ops, refused here). Android emulator reaches Supabase local at `10.0.2.2`.

## Checks

```sh
dart format --output=none --set-exit-if-changed lib/main.dart lib/src test
flutter analyze --fatal-infos
flutter test          # routing per role, refused accounts, checking/error/expired, en/te/hi, accessibility
```

`scripts/check-all.sh` and the `anugacare-app` CI job run the same steps.
