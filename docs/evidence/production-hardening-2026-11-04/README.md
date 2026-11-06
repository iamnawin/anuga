# Production hardening execution

Working source starts at audit `9a49ffe`, after issue feature `fd6c8dc` (PR22).
PR23 remains based on PR22. Hardening branches are stacked after PR23; none is a
deployment or merge authorization. The existing [release matrix](../../PRODUCTION_READINESS.md)
remains authoritative; this receipt records implementation evidence, not launch approval.

## Founder decisions received in this session

- Withdrawn trip consent blocks fresh Companion detail reads and Companion
  actions, including underway actions; Ops coordinates continuity using existing
  permissions. No emergency access override. The safety workflow still requires
  operational verification before release.
- Pilot occupancy is one visit per Companion across pickup to return, extended
  for late completion. Enforce conflicting/concurrent assignments in the DB.
- No arbitrary travel buffer; routine underway reassignment remains forbidden.
- Pricing, collection timing, no-show charges, subscriptions and per-visit
  collection remain unapproved. Preserve billing; no real charge authorized.

## Consent fix

Added `20261104000200_trip_consent_enforcement.sql`. Reuses
`owner_consent_active`, existing Companion window and role helpers. Masks six
patient-detail fields in the restricted projection, removes direct trip/event
reads through RLS, and guards Companion status mutations at the database trigger
boundary. Failed pickup rolls back consumption and events. Consent writes and
Companion transitions serialize on the patient row, including direct consent
writes permitted by existing RLS. Family and Ops permissions/history are unchanged.

Before migration: three regression cases failed (details remained visible,
pickup accepted, underway action accepted). After migration: three pass in
disposable PGlite. A fourth, two-connection withdrawal/start lock test is reserved
for real Postgres CI; a local skip is not a concurrency pass.

Independent security review additionally reproduced wrong-code attempt consumption
after withdrawal. `verify_pickup_otp` now checks serialized consent before any OTP
read/write; the regression checks wrong and correct codes and unchanged attempts.

The fix cannot erase already downloaded data, screenshots or an in-flight read
whose database snapshot preceded withdrawal. Fresh requests use current consent;
the JWT does not carry consent authority. No historical records are deleted.

Final consent source: Unlazy focused gate passes (3 executed, 1 real-PG skip); full `scripts/check-all.sh` passes. The initial oracle reporter mismatch was corrected by explicitly requesting TAP, then both gates were re-executed. Final-source real-Supabase CI is pending PR creation.
Hosted schema parity and physical device behavior remain unverified.
