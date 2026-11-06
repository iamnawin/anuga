# Production readiness completion dashboard

Updated: 5 November 2026. Source of truth: [31-row release matrix](PRODUCTION_READINESS.md).
This dashboard summarizes progress; only the matrix and linked evidence can close a gate.

| Gate | Status | Completed technical work | Evidence still required to close |
|---|---|---|---|
| P0 Consent withdrawal | Blocked | DB-enforced detail/action denial, OTP protection, serialization; PR #24 CI seven jobs pass | Apply/attest candidate schema in approved environment; execute active-visit safety workflow rehearsal |
| P0 Production isolation and parity | Blocked | Read-only catalogue attestation SQL and exact operator procedure | Name separate real-data project; Auth/Storage/Edge/Vercel dashboard receipts; schema/grant/policy comparison; seed-free proof |
| P1 Companion scheduling and pricing | Blocked | Founder occupancy contract verified at the DB boundary, including late visits and concurrent checks; PR #26 CI seven jobs pass | Active-visit handover rehearsal. Pricing, charging, no-show and subscriptions remain founder decisions |
| P1 Android, language and session recovery | Blocked | Ops/unified stale-session races fixed; PR #25 app/Android and real-Supabase CI pass | Physical Android Chrome/PWA execution; real expiry/network/account-switch evidence; signed Telugu/Hindi healthcare review |
| P1 Notifications, payments and recovery | Blocked | Truthful issue text, sensitive-error redaction, read-only attestation, operations/restore/rollback/incident runbooks | Named owners; provider/payment policy; alert receipt; retention approval; isolated DB+Storage+Auth recovery/rollback/incident drill |

## Current release decision

**NO-GO for real patient onboarding.** Technical code fixes do not replace hosted,
physical-device, human-language, recovery, legal/pilot or founder release approval.
No deployment, merge, hosted migration, cleanup, real SMS or payment is authorized.

## Remaining founder decisions

- Package prices and effective-date protection; monthly versus per-visit collection;
  payment timing, no-show treatment, refunds/disputes and support ownership.
- Travel/buffer policy after pilot evidence and the final Companion start window.
- Active-visit consent withdrawal/Companion unavailable safety and handover steps,
  named decision authority and completion criteria. Database emergency override is prohibited.
- Notification provider or explicitly staffed manual process, channel consent and response expectations.
- Retention/deletion schedule; RPO/RTO; named release, duty Ops, platform,
  incident, finance and privacy owners; final pilot/legal/release approval.

## Evidence sequence

1. Review stacked PRs #22 -> #23 -> #24 -> #25 -> #26 -> #27. Final technical source `618af1d` passed all seven CI jobs in run `42041948258`.
2. Release owner identifies the intended environment and completes the read-only
   [attestation](runbooks/environment-attestation.md); no migration is applied by this check.
3. Platform/Ops execute the isolated recovery and incident drill in
   [production operations](runbooks/production-operations.md).
4. QA executes [physical Android and language acceptance](ANDROID_TEST_PLAN.md)
   against the exact candidate SHA/environment and obtains human signatures.
5. Reconcile all 31 rows, pilot/legal evidence and obtain explicit founder release approval.
