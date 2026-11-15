# Service-aware visit assignments evidence

Agent: Codex. Task `VISIT-LEGS-20261115`; worktree
`D:/AI-Workspace/Repos/anuga-visit-legs`, branch `feat/visit-leg-assignments`,
starting main `981e567`. First observed clock13:17:18 IST on2026-11-15.

## Delivered source scope

- Opt-in Basic drop-and-return versus continuous stay-assist from the booked
  package's real attendance flag, not its name.
- Explicit Ops-planned, travel-inclusive blocks; independent outbound/return
  identities under one booking. Same-companion initial selection is the UI default.
- Confirmed staff receipt releases Basic; fitting Ops-assigned work is allowed,
  while a reserved return, unfinished job or overdue return blocks conflicts.
- Current-version Ops return replacement/rescheduling; no started return transfer.
- Explicit centre confirmation, return travel/arrival and separate hashed one-use
  return code. No timer auto-finishes treatment; no original OTP reuse.
- Restricted new Companion board, old RPC/RLS bypass prevention and consent checks.
  Released outbound can retain a nonprivate work summary without return rights.
- Family current return identity/readiness; Companion released/stay/return states;
  Ops planning, return queue, overdue notices and code issuance.
- Durable due/overdue outbox templates, stale pending reminder replacement and
  in-app timers. Existing test adapters/provider gates remain; no paid push enabled.
- EN/TE/HI copy and narrow200% tests. No new dependency, price or payment changes.

## Executed checks (checkpoint)

- Full database: **221 passed,12 skipped**, no failures. Eleven skips are existing;
  one new test requires two real PostgreSQL connections to prove serialization.
- Focused planned-visit SQL tests cover both allowed/denied roles, legacy/direct
  read bypasses, replacement revocation, consent, conflicts, version guards, service
  role writes, return OTP issuer/expiry/attempts/replay, reminder timing/recipient/
  cancellation and missed-return occupancy.
- Ops: **72 tests passed**, lint/typecheck/build passed.
- Shared Dart: **42 passed**, formatter/analyzer clean.
- Legacy Companion: **58 passed,3 existing skips**; Family **181 passed,6 existing
  skips**, their analyzers/formatters passed.
- Unified analyzer clean; final unified tests/captures running at this checkpoint.
- Planned real-browser care journey updated; discovery finds both journeys. Actual
  browser/Supabase/concurrency CI execution is pending. Docker unavailable locally.

Full check script ran through the earlier modules and stopped on new Companion
formatting; formatter corrected it and the final unified stage is rerunning. Do
not infer final all-green from this intermediate receipt. Logs remain ignored in
`artifacts/`.

## Retained failures and fixes

Missing plan RPC initially RED. Broader tests caught an overstrict legacy-start
check; restored old behavior for two legacy visits while always checking new
planned commitments. A test fixture initially used a blank generated profile name,
then received an explicit synthetic name. A return-time test accidentally overlapped
its own job; fixed the test interval without relaxing enforcement. PGlite lacks
pgcrypto random bytes, so code/salt generation reuses the existing UUID CSPRNG
pattern. New row/frame formatting and lint failures were corrected. A theme-cache
experiment was not needed in this task. No existing assertion/skip was weakened.

## Release boundaries

**No hosted migration, main merge, preview or live publication has occurred for
this feature.** Publishing the new unified client before this schema would make
its new read RPC unavailable. See the release runbook for the coupled rollout.
Physical-phone/native-speaker approval and provider delivery are not claimed.
Specialist final review was unavailable after model/config and quota failures;
the coordinator performed source/security checks and has not claimed an independent
final audit. Previous source and live test visit remain untouched.
