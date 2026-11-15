# ADR 0009: Ops-planned outbound and return assignments

Status: Proposed implementation; not applied to hosted schema or published.
Date: 2026-11-15. Founder approved the service behavior and Ops-controlled dispatch.

## Context

Basic includes centre drop-off and later return pickup; Plus/Family Care includes
attendance during the session. The old pilot reserves one companion continuously
and prohibits every started-trip reassignment. Merely changing the handover screen
would not release occupancy or safely reserve the return. The scheduled return
timestamp is expected centre readiness, not home completion. No live-position or
travel-time service exists.

## Decision

Keep the booking/trip and original outbound identity. Add an opt-in visit plan
with two logical assignments: separate companion IDs and explicit travel-inclusive
outbound/return time blocks. Store these together in one restricted plan record;
do not duplicate the patient booking, invoice or entire state machine.

Snapshot the booked package's attendance flag at planning. Basic releases only
after staff receipt confirmation. Stay-assist retains continuous occupancy. Return
reservation remains through home delivery; unfinished work and missed returns
continue blocking conflicting starts until resolution. Ops approves all planned
jobs, readiness changes and unstarted Basic return replacements. Thirty-minute
preparation and fifteen-minute arrival are planning targets, never clinical facts.

Use a new restricted Companion board for planned assignments. Legacy projections
omit opted-in visits and direct trip/event reads remain denied to planned
companions. Guard legacy mutation paths; preserve their behavior for ordinary
visits. A released outbound companion may see a nonprivate summary, not another
assignee's patient essentials or return rights. Family board uses current return
identity after handover while history retains the outbound actor.

Centre readiness requires explicit Ops-recorded staff confirmation. Return assignee
confirms travel/arrival and verifies a separate, short-lived return code before
the booking becomes returning. The home pickup code cannot authorize this action.

Persist scheduled preparation/overdue reminders through the existing outbox and
reauthorize every app action. In-app timers and the Ops queue work without adding
a location/dispatch vendor. Existing provider/dispatcher delivery gates remain.

## Consequences

Existing trips retain current behavior unless Ops opts them in. Planned visits
require upgraded unified clients; native standalone clients are not silently
upgraded into the new contract. The schema must be applied and attested before
the new unified entry app is published. No automatic reassignment or ETA promise.
Ops must plan travel conservatively, monitor overruns and replan missed returns.
External reminders cannot be guaranteed without an operating dispatcher/provider.
