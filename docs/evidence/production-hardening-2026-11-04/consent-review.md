# Independent consent security review

Reviewed the uncommitted `20261104000200_trip_consent_enforcement.sql`, effective
trip/OTP/RLS functions, consent helper and regression/concurrency tests on
4 November 2026. This is a source/disposable-DB review, not hosted parity or
production approval. No hosted writes, OTP messages or payments were performed.

## Findings found and corrected during review

1. **P1 — wrong pickup-code attempts remain mutable after withdrawal.** The
   trigger in the new migration runs on `trips.status` updates. The effective
   `verify_pickup_otp` in `20261022000100_trip_controls.sql:94` increments the
   attempt counter and returns before any status update for a wrong code. In a
   fresh disposable PGlite, after owner withdrawal the Companion call with
   `guaranteed_invalid` returned `wrong_code`, `attempts_left: 4`; its OTP row
   persisted `attempts: 1`. This violates the approved block on Companion actions
   and allows a withdrawn actor to exhaust the code's budget. **Corrected:**
   the new private `assert_trip_consent` helper locks the patient and checks
   current owner consent at the beginning of OTP verification, before code
   reads/writes. The regression now checks both incorrect and correct codes after
   withdrawal, SQLSTATE 42501 and unchanged attempts/consumption.

2. **P1 test reliability — the concurrent observer should inspect locks directly.**
   `support/concurrent.ts:20` queries `pg_stat_activity.wait_event_type` from an
   `authenticated` actor connection. Sensitive activity columns can be hidden
   for other sessions, and activity snapshots may remain cached in a transaction.
   **Corrected:** the test now uses
   `select pg_backend_pid() = any(pg_blocking_pids($1)) as blocking`
   on the owner connection, which directly proves that connection blocks the
   Companion backend. No app privileges were added. Real-Postgres CI must still
   verify the oracle and mutation race.
   [PostgreSQL statistics visibility](https://www.postgresql.org/docs/17/monitoring-stats.html).

## Reviewed protections

- The effective consent helper checks a current `patient_access` owner, rather
  than accepting a viewer's self-recorded consent or a JWT consent flag.
- Restricted patient fields become null and direct trip/event reads are denied
  by the updated RLS helpers after withdrawal. Existing separately authorized
  Family/Ops history remains readable; this is deliberate.
- The status trigger catches all valid Companion transitions, including issue
  reports and terminal transitions. Correct pickup-code consumption is rolled
  back when its subsequent transition raises. The corrected OTP function rejects
  all attempts before any OTP write when consent is withdrawn.
- Trigger functions are security definers with an empty search path and no app
  execution grants. Existing `apply_transition` is also unavailable to app roles.
- Fresh snapshots enforce current consent. An already delivered response,
  screenshot or read snapshot predating withdrawal cannot be retroactively erased.
- The restricted trip list intentionally retains schedule/status/centre metadata
  outside patient-detail visibility, matching its pre-existing masked-list shape.
  Patient name, address, location, mobility and contacts are masked.

## Evidence boundary and remaining checks

After correction, an independent execution of
`node --test --test-reporter=tap --test-isolation=none supabase/tests/consent_withdrawal.test.ts`
passed **3**, failed **0**, and skipped **1** (the real-Postgres concurrency case).
The independent wrong-code probe had failed the initial implementation, and the
corrected test now includes that negative case. Actual serialization remains
**Not Tested** until real Postgres executes it.
Add direct consent-write coverage and a withdrawn later-stage check-in if
expanding the regression cases. Hosted schema/grants, physical-session recovery,
and the Ops safety/handover process remain release gates.

**Review disposition: no remaining material source defect found in this scope.**
The review corrections are present and focused regressions pass. Real-Postgres
CI and hosted parity remain required; this receipt does not approve production.
