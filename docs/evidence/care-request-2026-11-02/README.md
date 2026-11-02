# Family care request: first vertical slice - 2026-11-02

**Demonstrated against the existing hosted synthetic Supabase backend:**
Family submits -> ops sees -> ops confirms/assigns -> Family reloads assigned state.
Browser test: 1 passed in 20.2 seconds; real Auth/RPCs/Postgres/RLS, no mocked responses.
Screenshots are desktop Chrome at a phone viewport, not physical-device evidence.

| Stage | Observed result |
| --- | --- |
| [Request](01-family-request.png) and [review](02-family-review.png) | Lakshmi Rao (synthetic), registered Synthetic Dialysis Centre 1, existing Basic package; pickup Nov 5, 2026 at 18:05 IST |
| [Family reload](03-family-persisted-pending.png) | Pending ops confirmation; persisted schedule `11b3459b-ca11-4d28-b626-892c2fedd956` |
| [Ops sees it](04-ops-pending-request.png) | Existing Schedules board shows that request, date, package and pending state |
| [Ops confirms](05-family-confirmed.png) | New trip exists; Family says Confirmed / companion not assigned |
| [Ops assigns](06-ops-assigned.png) | Existing assignment chooses Asha(primary) and Ravi(backup) |
| [Family reloads](07-family-persisted-assigned.png) | Confirmed / companion assigned, Asha shown; trip `d185a2fb-fe5c-4618-8e70-5711f9c6bdce` |
| Concurrent retries | Two real parallel HTTP requests with distinct retry UUIDs returned the same schedule, not new requests |

[Sanitized journey receipt](receipt.json), [exact created records](created-records.json).
User reported applying the additive migration; successful real RPC calls verify
its hosted behavior. CLI migration-history bookkeeping was not verified here.

## Scope and contracts

Family booking reads, patient access, ops assignments/trip generation and the
companion journey already existed. The missing pieces were request creation and
pre-trip visibility. A request now reuses a single-date schedule; no request table,
new base-table grants or client-only permission boundary was introduced.

Owner/editor submission requires active owner trips consent. Viewers/patients may
read authorized requests but cannot submit; companions cannot read these records.
The new ops confirmation wrapper rechecks owner consent, then delegates existing
trip generation for exactly the requested date. Ordinary schedules keep their
existing generator. UUID retries plus patient-row locking and slot checks guard
against duplicate schedules, recurring-slot collisions and existing trips.

Pending means no trip; confirmed means a generated scheduled trip without a
companion; assigned means a scheduled trip with a companion. Other actual trip
statuses are preserved. No optimistic confirmed state is inserted by the client.

**Product decisions not invented:** only the patient's registered centre is
supported; per-visit centre changes need a destination contract. The selected
time is pickup time, not a dialysis appointment reservation. Existing schedule
planning default of 300 minutes is reused without presenting a clinical-duration
promise. Package names come from the active catalogue; no total, availability,
payment or cancellation rule was invented. Consent checks are not a promise
against a concurrently committing withdrawal transaction.

## Working preview and focused checks

Run `powershell -File scripts/build-care-preview.ps1`, then
`node scripts/serve-local.mjs --care-preview`. Open
`http://127.0.0.1:3104/app/` and `http://127.0.0.1:3104/ops/`.
Build output: `artifacts/care-preview/.vercel/output` (ignored). Published preview
URL/source/deployment identification are recorded in the PR receipt.

- 11 focused SQL tests passed (PGlite, actual migrations/RLS), including midnight,
  consent withdrawal, allowed/denied reads/writes and duplicate cases. Missing
  functions and missing duplicate/confirmation guards were reproduced first.
- 2 shared Dart API tests and 7 Family UI tests passed; Family/shared analyzers clean.
- 22 focused Ops tests passed; typecheck/lint passed. PWA+ops preview builds passed.
- Hosted browser journey: 1 passed; screenshots visually inspected. Earlier driver
  failures involved HTTP/2 pseudoheaders and Flutter text/menu semantics, not
  persisted application errors; debug requests are accounted for below.
- CI adds the same browser journey against freshly seeded real Supabase local,
  with screenshot/receipt artifacts. It is skipped in ordinary e2e runs unless
  CARE_REQUEST_JOURNEY is set. Existing historical checks were not rerun manually.
- Read-only access review found no blocking issue. Some logical slot conflicts
  use SQLSTATE 22023 and currently show the generic request error, rather than specific
  duplicate copy; successful same-intent retries remain idempotent.

## Synthetic effects and remaining gates

Five distinct synthetic one-date schedules and two trips were created across
browser-driver debugging and the successful demo. Three requests remain pending,
one confirmed/unassigned, one assigned. IDs/states are in created-records.json.
Existing audit/outbox behavior ran; no invoice/payment, patient/centre/consent
change, seed reset or demo_refresh was performed. No automatic cleanup executed.

Android support is preserved. Physical-phone checks and native-speaker wording
approval remain pending; the start window remains provisional at 180 minutes.
Old hosted fixture cleanup remains pending; refresh fixtures before new grouping
checks. Production launch, real patient data and paid providers remain gated.
