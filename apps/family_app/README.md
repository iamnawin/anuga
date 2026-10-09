# Family app (`apps/family_app`)

Flutter app (Android first) for the patient's family and the patient: bookings, live visit status,
the pickup code and an updates inbox. A thin client over `FamilyApi` in `packages/shared_dart`; the
database enforces every rule.

- **Sign in:** phone OTP (Supabase Auth, no sign-up from the app yet); non-family accounts are signed out.
- **Patients:** `family_my_patients()` with the user's access level. A picker appears when there
  is more than one patient.
- **Bookings:** `family_trip_board()`, from yesterday to two weeks ahead, with the companion and a
  "backup companion" label when the backup is covering.
- **Visit screen:**
  - status and timeline (`family_trip_timeline()`: who did what, with notes);
  - **Get pickup code** for owner, editor and patient, only while the visit awaits pickup;
  - **Cancel** for owner and editor, only while the visit is scheduled, with confirmation and an
    optional reason.
  - Viewers see neither button; the database refuses them anyway (`issue_pickup_otp`, `advance_trip`).
- **Updates:** `my_notifications()` (push-channel rows), newest first.
- **Records (M8):** reports listed via `vault_list_documents()` (audited). Owner/editor add a report
  photo (camera or gallery, `image_picker`), with the owner's records consent. Upload goes through
  the `vault-files` Edge Function (signed URL for a path the database chose); viewing uses a fresh
  60-second signed URL each time. PDFs can be stored but not viewed in the app yet.
- **Privacy and consent (M8):** one switch per purpose (visits, health records, ops may view
  records) for the owner; others see the status. Withdrawing asks for confirmation; giving does not.
- **Languages:** English, Telugu, Hindi (`lib/l10n/*.arb`; Telugu/Hindi need native review). Text
  is at least 15% larger than the platform default, with 56 dp buttons and a "call 108" notice.

## Run

```sh
flutter pub get
flutter run --dart-define=SUPABASE_URL=http://10.0.2.2:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=<from supabase status -o env>
```

On Supabase local the family owner signs in with `9000000101` and the viewer with `9000000102`, both
with code `123456`.

## Checks

```sh
dart format --output=none --set-exit-if-changed lib/main.dart lib/src test
flutter analyze --fatal-infos
flutter test          # access-level and status matrix, cancel, code, timeline, full app vs fake backend
SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_PUBLISHABLE_KEY=... flutter test test/supabase_local_test.dart
```

The last command runs against Supabase local after `supabase db reset` (it commits data).
