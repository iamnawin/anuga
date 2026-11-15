# Service-aware visit assignments implementation plan

**Goal:** Let Ops plan outbound and return work for Basic while preserving
continuous attendance for stay-and-assist, with database-enforced reservations.

**Architecture:** Opt-in per-visit service plan and independent return assignment
under the existing booking. Guarded RPCs own planning, readiness, leg actions and
verification; thin apps display permitted actions. Preserve legacy bookings.

**Stack:** Existing Postgres/PostGIS, PGlite tests, shared Dart, Flutter, Next.js.
**Spec:** docs/design/visit-leg-assignments.md.

## Tasks

- [ ] Backend RED allowed/denied tests for plan service snapshots, release,
      conflicts, alternate return assignee, legacy/RLS bypasses, consent and OTP.
- [ ] Add migration with plan/reservation guards, restricted projections, Ops
      planning/readiness/replacement RPCs and distinct return verification.
- [ ] Test shared model/API parsing and opt-in calls without changing legacy RPCs.
- [ ] Add Ops planning/return queue controls, explicit times and stale-safe actions.
- [ ] Add Companion release/next-assignment/return states and Family return identity.
- [ ] Add in-app prep/arrival reminders and durable Ops due/overdue visibility;
      preserve provider gates and never auto-finish a session.
- [ ] Full local checks, real SQL/browser journeys, release build, source review,
      screenshots, CI, feature PR and migration/release instructions.

Review concurrency, direct-service-role writes, old client bypasses, issue resumption,
midnight/early/late readiness, identity revocation and stale modal drafts explicitly.
Coordinator owns shared handoff docs. No silent patient/schema/publication changes.
