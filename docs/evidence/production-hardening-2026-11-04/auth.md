# Session lifecycle hardening

Four controlled Ops regressions failed before the fix: a delayed profile restored
Ops after logout; stored-session bootstrap superseded logout; old account lookup
overwrote a newer Family account; network rejection left loading with an unhandled
rejection. All four pass after request-generation invalidation and fail-closed
resolution. Invalidation/identity clearing occurs synchronously on auth events;
only the profile request is deferred out of the auth callback.

Unified Flutter regression reproduced a delayed stored role reopening Companion
after the expiry event. Generation checks now invalidate both successful and
failed old lookups after expiry/signout/new login; a second regression verifies a
late failure cannot replace a newer Family home. Routing suite: 24 pass, including
existing EN/TE/HI accessibility checks. App identity still comes from DB profiles;
database permissions remain authoritative.

Scope: deterministic fake-session races, not proof of physical Android expiry,
refresh-token revocation, live OTP delivery or native-language approval. Keep D04
and all pending physical/human rows open in the existing Android plan. No token
TTL or global session settings changed.
