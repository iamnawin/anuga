# Service-aware visit assignments

Founder direction, 2026-11-15: one family booking, outbound drop-off and reserved
return assignments; same companion preferred. Basic releases at confirmed centre
handover; stay-and-assist remains occupied. Founder chose Ops approval of every
additional job and return replacement. Thirty-minute preparation and fifteen-minute
target arrival precede expected readiness; neither timer declares treatment finished.

## V1 execution contract

Ops explicitly enables a plan before starting a visit, supplying outbound start/
end and return occupied-through time. Expected readiness initially comes from the
booking's scheduled return time. These blocks include operator-assessed travel;
there is no location/ETA/automatic proximity service. Same companion is reserved
for both legs initially. Service behavior is snapshotted from the booked package's
`companion_stays_through_session` flag, never from its display name.

After the outbound companion confirms centre-staff receipt, Basic displays
"Drop-off complete", expected return, prep time and target arrival, plus Back to
Today. Stay-assist displays "Stay with the patient". The database releases Basic
only after handover and rejects work whose entire reserved interval overlaps the
return block. Unfinished/overrunning work continues to block another start.

Ops can replace only an unstarted Basic return assignment, following current
eligibility and conflict checks. Completed outbound identity/history stays intact.
Replacement revokes former return access immediately. No started return transfer.
Ops records the centre's actual ready confirmation; an elapsed timer is insufficient.
Return assignee confirms departure and centre arrival, then uses a separately
issued return code. Return code is salted/hashed, expires, rate-limited and one-use;
the original home code is never reused. No clinical readiness assessment is made.

Family sees one visit timeline and the current return companion. Companions see
only current assigned-leg essentials inside its access window, never diagnoses,
DOB, vault data or the other patient's details. Legacy trip/OTP endpoints must not
bypass plan controls. RLS/direct trip/event reads must match the new boundaries.

## Operational safety

Plan edits/replacement require a version guard and serialize companion reservations.
Plans are opt-in; existing trips retain their current full-visit occupancy. Release/
completion never fails merely because a downstream reservation now conflicts.
Return due/overdue views alert Ops when the assignee hasn't departed/arrived.
In-app time-derived reminders are visible after reload; provider delivery uses the
existing outbox/test adapters and cannot be claimed as a paid/live push service.
Ops must update expected readiness for early/late finishes and handle conflicts;
the app never fabricates a replacement, ETA or patient readiness.

## Acceptance

1. Basic handover frees a companion for a fitting job; overlap/overrun rejected.
2. Plus/Family Care handover does not release occupancy.
3. Return remains reserved, with preparation30min/target15min before readiness.
4. Ops-only return replacement, eligibility, stale-version and conflict checks.
5. Released/replaced companions denied private reads and return actions, including
   direct table/event access and legacy RPC attempts.
6. Explicit centre ready + arrival + distinct valid return code precede returning.
7. Wrong/replayed/expired/locked codes denied; revoked consent denies all actions.
8. Family identity/status updates, EN/TE/HI,48px targets and200% text tested.
9. Existing journey, billing, notification and legacy app tests remain green.

No new dependency, dispatch provider, pricing or payment change. No hosted schema
application, main merge or publication without a concrete reviewed release approval.
