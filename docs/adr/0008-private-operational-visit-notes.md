# ADR 0008: Keep operational visit notes private

Status: Accepted for the founder-requested synthetic issue-handling slice, 2026-11-03.

Issue reports and Ops resolution context must not be exposed as Family visit
updates. Previously the same free text reached Family-readable events and
notification payloads, so UI-only redaction could not enforce this boundary.

Store issue notes and all Ops-authored transition notes in a private sidecar,
without app-role grants. Family-readable events/outbox retain status and time;
the existing guarded Ops exception projection retrieves the internal issue note.
Preserve companion handover/completion notes intended for Family. Move historical
operational text before clearing its public copies; preserve visit state,
assignment, OTP, consent, timestamps and notification bookkeeping. This cannot
recall a message already delivered externally.

The exception screen explicitly resumes only the recorded prior stage or
explicitly cancels using existing permitted transitions. A row-locked wrapper
checks the current incident timestamp before delegating to `advance_trip`.
Missing prior stage blocks resume; there is no invented restart fallback.

Underway companion takeover needs a separate decision about safe handover,
pickup verification and responsibility. Existing scheduled-only reassignment
remains unchanged. No acknowledgement/SLA, alert delivery or GPS behavior is added.
