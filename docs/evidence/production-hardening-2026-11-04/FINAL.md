# Production hardening execution receipt

Decision: **NO-GO for real patient onboarding**.

## Completed technical scope

- PR #24: database-enforced consent-withdrawal masking and Companion action denial.
- PR #25: Ops and unified-app stale authentication response invalidation.
- PR #26: database-enforced Companion occupancy, concurrency, late completion and
  started-visit reassignment protection.
- PR #27: truthful issue text, sensitive-error redaction, read-only environment
  attestation and production operations/recovery runbooks.

Final technical source `618af1d85e62b91e19fee0507c0ac4aa6ac5b720`
passed all seven CI jobs in run `42041948258`: database tests, real Supabase and
browser journeys, Ops, shared Dart, Family, Companion and unified Android builds.
PR #26 run `42041948190` also passed all seven jobs after retrying an external
Maven download failure. Local database regression: 204 passed, 11 environment
skips, 0 failed. Focused operations checks: 36 passed, 0 failed.

## Acceptance result

`PRODUCTION_GATES.md`: 6 met, 3 open while corrected PR #27 CI is pending.

- G6 is reopened: the corrected care-request fixture must pass the complete
  real-Supabase/browser/Android CI workflow.
- G7 remains open: physical Android Chrome/installed-PWA execution and signed
  Telugu/Hindi healthcare-language approval need people and real hardware.
- G8 remains open: production isolation/schema parity, backup/restore/rollback/
  incident drills, active-visit safety rehearsal and final release approval need
  authorized hosted access and named owners.

## Explicitly not performed

No merge, deployment, hosted migration, synthetic-data deletion, real SMS,
payment transaction or provider activation was performed. Pricing, collection,
no-show, subscription, retention, RPO/RTO and release decisions remain with the
named human owners in the 31-row production-readiness matrix.

## Later PR #27 CI regression

Receipt-head run `42167845149` failed `care_request.spec.ts:167`. Its Friday
11:45-16:45 request selected Asha while the fresh seed already occupied Asha
07:00-12:00. The occupancy trigger correctly refused the overlap with SQLSTATE
`22023` and the transaction rolled back; the UI stayed in the assignment form.
The test now uses unoccupied Ravi, signs in as that assigned Companion, and
asserts the assignment HTTP response before rendered state. Until the corrected
head passes all seven jobs, G6 is reopened and the gate count is 6 met / 3 open.
This technical regression is separate from G7 and G8 human/external evidence.
