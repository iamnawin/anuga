# Request Care and visit issue review (2026-11-04)

Scope: registered-patient Request Care through Ops confirmation/assignment,
verified pickup, private issue reporting, explicit Ops resume/cancel and persisted
Family progress. PR #22 stays open; this review does not authorize merge or deploy.

## Reproduced defects and fixes

1. Resuming `issue_reported -> picked_up` overwrote the original verified
   `picked_up_at` with the resolution time. A new SQL regression failed against
   the previous source, showing different timestamps. Additive migration
   `20261104000100_preserve_issue_pickup_time.sql` preserves that timestamp on
   incident resume; normal pickup still records its own time. Its function body
   retains private note storage, event creation, notification redaction and grants.
   The original hosted migration is not edited. The real browser journey now
   asserts the original pickup timestamp against the resolution RPC response.
2. Family booking refreshes could finish out of order and restore an older issue
   status after a newer completed status. A failed/denied refresh retained old
   booking and request cards. Both new widget regressions failed before the fix.
   Bookings now uses the existing request-generation and clear-on-load pattern;
   late results are ignored, failed reads hide old cards, and Refresh recovers
   without resubmitting care. A mounted guard covers navigation return callbacks.

## Acceptance coverage

| Outcome | Observing check |
|---|---|
| Owner/editor only, owner consent required at request and confirmation | `care_requests.test.ts` allowed/denied contracts |
| Registered centre, active package, future whole-minute IST pickup | SQL contracts and Family form tests |
| Same-ID and same-slot retries do not create duplicate requests | SQL contracts and Family in-flight/retry tests |
| Ops confirmation/assignment persists and Family reads actual status | Real care-request and issue browser journeys |
| Required issue text and all Ops notes stay private | SQL direct-table/RPC/notification and browser marker checks |
| Exact incident, recorded stage, Ops-only explicit resolution | SQL stale/reissued/non-Ops/missing-stage and Ops confirmation tests |
| Pickup verification, original pickup fact and assignment survive resume | SQL regression and browser assertion |
| Same companion continues to completion; Family refresh/reload agrees | Real issue browser journey |
| Request cards cannot revert to stale status or survive a denied refresh | New Family deferred-response and failure/recovery regressions |
| EN/TE/HI forms and existing issue layouts remain usable | Family and Companion widget suites |

## Verification

`GATES.md` is the current completion ledger. The first full-check attempt stopped
at Dart formatting after the new Family tests were added. After formatting,
all three runnable gates passed: focused SQL contracts, sequential
`scripts/check-all.sh` (database, Ops lint/typecheck/unit/build, shared Dart and all
three Flutter format/analyze/test suites), and the nine-test Family care-request
suite. Automatic gate evidence records the output digests and execution context.
Fresh read-only review found no remaining blocker after the refresh fix.
Corrected source `335b58bdaf4eaa51210f9d124983cf61e409cc98` passed all seven jobs
in [CI 41840577234](https://github.com/iamnawin/anuga/actions/runs/41840577234).
Real Supabase SQL/Edge tests, seven Ops browser tests, the care-request browser
journey (24.2 s), the issue browser journey with pickup preservation (22.4 s),
the complete billing/notification journey (`JOURNEY PASSED`) and Android builds
passed. [CI summary](ci-summary.json) records the exact source and step results.
The final receipt changes documentation and gates only; its source-equality
oracle checks that product/test/workflow files still match the tested commit.

The pre-review PR head `63b3ed6` passed seven CI jobs in run `41644237755`;
that is historical evidence, not verification of this review's changes.

## Rollout and limits

Apply the new migration after `20261103000100` before publishing source that
expects the pickup-time fix. It is not applied to the hosted synthetic project
by this review, and the existing preview does not contain these changes.
Already overwritten pickup values are not backfilled: no original time is guessed.

No local Docker executable is available; CI supplied the real Supabase and browser
verification. This review does not repeat hosted data-mutating demos.
Physical-phone installation/keyboard/OS behavior and native-speaker wording approval
remain separate checks. Underway companion takeover still needs founder policy;
current scheduled-only reassignment remains enforced. Retained synthetic fixture
cleanup, pricing, the provisional start window and production launch stay outside
this review. No external provider, real data or paid service is enabled.
