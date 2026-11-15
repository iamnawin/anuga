# Service-aware assignments: candidate rollout and acceptance

This feature changes occupancy/access contracts. Implementation approval does
not authorize an unattended hosted migration or public release.

## Before applying

1. Review ADR0009, design and exact candidate migration
   `20261115000100_visit_leg_plans.sql` together with its allowed/denied tests.
2. Verify candidate CI passes real PostgreSQL/Auth/Edge checks, new concurrent
   reservation test, planned care browser journey, legacy issue journey and APKs.
3. Attest the target is the existing synthetic Supabase project. Inspect actual
   hosted migration history and preceding schema; old notes about manual SQL
   application are not fresh evidence. Verify an approved recovery/export path.
4. Obtain founder approval for the exact additive migration and coupled synthetic
   app release. No real people, paid providers or production launch is authorized.
5. Confirm participants use upgraded unified `/app/` (or its unified Android build).
   Opted-in visits are intentionally omitted from old standalone Companion reads.

## Rollout order

1. Apply the reviewed migration transaction only after the above gate. It adds a
   restricted plan/return-code store, guards, RPCs and reminder templates; it does
   not rewrite existing bookings into plans. Attest grants/RLS/function signatures.
2. Ensure API schema cache exposes the new RPCs. Run allowed/denied role smoke and
   a read of both old and new boards before switching clients.
3. Build the exact source with existing synthetic public client settings. Deploy
   a preview and run one newly created synthetic planned visit, leaving historical
   founder visits alone. Verify hashed bundle identity and independent sessions.
4. Publish only the reviewed synthetic preview after acceptance. Record source,
   migration, PR/CI, deployment IDs and actual test results in HANDOFF/ledger.

If schema is applied but clients roll back, ordinary visits still work. Do not
enable new plans for old clients. Existing planned visits must be handled with a
compatible client and Ops; do not drop the schema or bypass the return guards to
force a rollback. Preserve records and use a reviewed forward fix if needed.

## Synthetic acceptance walkthrough

- Ops selects a scheduled packaged visit, explicit outbound departure/handover
  window and return departure/home-arrival window. Include travel and reserve
  return no later than30min before readiness; target arrival15min before.
- Home OTP remains Family-issued. Outbound companion completes pickup/centre
  arrival, confirms staff receipt. Basic shows drop-off complete/next assignment;
  Plus/FamilyCare says stay. Never infer clinical readiness from the timer.
- Assign/start a fitting job; deliberately overlapping return assignment/start
  must fail in SQL. Delayed actual work must continue to block a return start.
- Inspect durable future reminders without early inbox display. Reschedule or
  replace return and verify old pending reminders and former return rights go away.
- Ops records actual centre-staff confirmation. For early finish, replan return
  times conservatively before travel. An expired outbound plan requires Ops to
  cancel/rebook before starting; an expired return requires Ops rescheduling.
- Assigned return companion departs/arrives; Ops issues a separate return code
  after readiness+arrival. Wrong/expired/locked/replayed codes fail. Correct code
  starts returning; home delivery and required note complete the same booking.
- Family sees current return identity, service events and the final note, without
  internal Ops confirmation text. Revoke consent and test denied reads/actions.
- No actual dispatch/WhatsApp/push delivery promise until its existing operational
  infrastructure has been independently accepted. Outbox readiness is not delivery.
