# shared_dart

Models, trip state machine and RPC client shared by `apps/companion_app` and `apps/family_app`.

- `TripStatus`, `TransitionActor`: mirror the Postgres enums.
- `TripStateMachine`: client copy of `public.trip_transitions`, used to decide which actions to show.
  The database stays authoritative.
- `CompanionApi`, `FamilyApi`, `OpsApi`: typed wrappers over the M1 RPCs. They take an `RpcCaller`,
  so apps pass `supabase.rpc` and tests pass a fake. No Supabase SDK dependency here.
  `FamilyApi` also wraps the M5 read models (`myPatients`, `timeline`, `notifications`).
- `AccessLevel`: a user's level for a patient, with `canIssuePickupOtp` / `canChangeTrips`
  mirroring the SQL checks (used to hide buttons; the database still decides).
- `RpcException`, `PhoneAuth`: SDK-free error and sign-in interfaces the apps implement once.
- India helpers: `normalizeIndianMobile`, `isOtpCode`, `toIst`, `istDay`.

## Contract with SQL

`test/fixtures/trip_contract.json` is generated from the migrations with `pnpm contract:export`
(repo root). `pnpm db:test` fails if the database drifts from it; `dart test` fails if this package does.
After changing statuses or transitions in SQL: run the export, update `lib/src/trip_state_machine.dart`,
run both test suites.

## Commands (from this folder)

```sh
dart pub get
dart format --output=none --set-exit-if-changed lib test
dart analyze --fatal-infos
dart test
```
