# Companion occupancy hardening

Founder-approved pilot contract: one occupied visit per Companion from scheduled
pickup through scheduled return; actual late completion extends occupancy. There
is no invented travel buffer. Routine reassignment remains limited to scheduled
visits; an underway exception still requires the approved Ops safety/handover
process. Pricing and payment policy are unchanged.

The additive trigger serializes authenticated and service-role assignments/starts
on the Companion row and checks conflicts after the lock. It covers one-off
assignment, recurring generation, bulk schedule assignment, scheduled interval
changes and starts of preassigned visits. An unfinished overrun remains occupied
until completion; completion itself is never blocked. Adjacent intervals are
allowed. Database-owner seed/maintenance writes remain privileged and are not an
application/service bypass.

Before the migration, five focused cases reproduced accepted overlap/conflicts.
Final focused result: 10 pass, 2 real-Postgres concurrency cases skipped locally,
0 fail. Full disposable DB suite: 211 tests, 201 pass, 10 environment skips,
0 fail. Existing shared fixtures are explicitly detached/restored around
independent tests; the product trigger is never bypassed.

Two-connection assignment and start tests are reserved for real Supabase CI.
Hosted migration parity, physical-device behavior and the underway safety process
remain unverified. No migration was applied to a hosted environment.
