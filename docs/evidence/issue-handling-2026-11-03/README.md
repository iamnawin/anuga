# Visit issue, Ops handling and Family status

## PR #21 publication

Reviewed diff and latest head `e5907ae`: no blockers; all seven jobs passed in
[CI41471118832](https://github.com/iamnawin/anuga/actions/runs/41471118832).
Merged as `21ae9bc2ad4ae4e5bb3befd8b4b27a8b3b1bd65c` and published to the existing
synthetic alias `https://anuga.vercel.app/app/`, READY
`dpl_AEj5XTiyqYPynhzgkQGzX7zvuzQN`. Live app bundle matches the merged build.
The focused read-only post-deployment smoke authenticated Family `9000000101`,
opened the existing completed visit, refreshed and checked its persisted milestone
time. [Deployment](pr21-deployment.json), [smoke receipt](pr21-post-deploy.json)
and screenshot are alongside this file. No visit data changed in that smoke.

## Reused behavior and narrow changes

Companion issue reporting already required a note; the queue, prior-stage field,
transition matrix, pickup OTP and scheduled-only reassignment already existed.
The new slice keeps issue/all Ops transition notes in private storage instead of
Family-readable event/outbox copies. Ordinary companion handover/completion notes
remain Family-facing. Ops sees the internal report, recorded stage, time and
assignment. Resume/cancel require explicit confirmation; a row-locked wrapper
checks the current issue and exact timestamp before using existing transitions.
Missing prior stage blocks resume; no default restart or stage selector is added.
Family service status/Updates and Companion waiting guidance use persisted state
with explicit Refresh/resume. No acknowledgement or delivered-alert claim is made.

## Database execution

Founder applied `20261103000100_private_visit_issue_notes.sql` in the synthetic
project's SQL Editor and reported success. [Hosted receipt](migration-hosted.json)
records its checksum. [Read-only preflight](migration-preflight.json) found zero
historical public note copies to move. The migration creates private note storage,
replaces the transition persistence/queue helpers and adds guarded issue resolution.
It does not change states, assignments, OTP, consent, visit dates or transition rules.
Historical redaction is tested locally, including reruns; it cannot recall already
delivered messages. Public app-table grants are unchanged. See ADR 0008.

## Verification ledger

The browser uses identical local prebuilt preview files and real hosted synthetic
Auth/Postgres/RPCs/RLS. It runs desktop Chrome at a phone viewport; it is not a
physical-device test. Exact trip/schedule IDs, authenticated identities and checks
are in `receipt.json`; retained synthetic records are in `created-records.json`.
Final hosted rerun: **1 passed, 34.5 seconds**. Schedule
`495bb4e9-be73-4991-8096-012b55aeb7d3`, trip
`eaf13b18-7f1c-48f8-8a59-e6b7fd2e4db6`; pickup 3 Nov 2026, 20:10 IST.
Two new synthetic schedules/trips were completed, including the earlier run;
existing active visits were not changed. Final status-label regression checks
passed24/24, and screenshots confirm the short badge and wrapped explanation.

[Family preview](https://anuga-8hftd37pw-iamnawins-projects.vercel.app/app/) ·
[Ops preview](https://anuga-8hftd37pw-iamnawins-projects.vercel.app/ops/), Vercel
team sign-in required. READY `dpl_Hx1U8Qmo66T8fKyPg3uvj5bLrPzd`, product source
`8f922ed`; later receipt changes are documentation only.

| Check | Result | Evidence |
| --- | --- | --- |
| Companion reports after real OTP pickup, required note | Pass | Exact requested/assigned trip; report persisted |
| Ops sees private report, prior stage and same assignment | Pass | Guarded queue read and screenshot |
| Underway reassignment rejected | Pass | Authenticated negative permission check; assignment unchanged |
| Explicit Ops resume to recorded picked-up stage | Pass | Guarded RPC and confirmation; no restart or stage skip |
| Family service status and note isolation | Pass | Four RPCs and three direct readable tables exclude both private markers |
| Refresh/reload consistency and completion | Pass | Family and Companion reload same resumed stage; all three roles complete |
| Missing stage, stale/reissued action, non-Ops resolution | Pass locally | Focused SQL/Ops tests; no hosted journey mutation for these cases |
| EN/TE/HI layout at 200% | Pass locally | Widget checks; visual status-chip clipping fixed and regression checked |
| Underway backup takeover | Blocked | Existing rules allow reassignment only while scheduled |
| Physical-phone and native-speaker wording approval | Blocked | No device available; layout verification does not approve wording |

Focused SQL/regressions32, Ops30, Family24 and Companion34 passed. Sequential
`check-all.sh` passed (DB190/8skip, Ops66, shared29, Companion57/3skip,
Family55/6skip, unified37), followed by targeted status-wrap regression checks.
CI also runs the issue browser journey on freshly seeded real Supabase local.
Final CI and preview links are recorded in the feature PR; preview deployment
identification is in `preview.json`. Protected Vercel preview sign-in is separate
from AnugaCare sign-in; no remote signed-in preview pass is inferred from readiness.

## Limits and next decision

The founder must define safe handover, pickup verification and responsibility
before supporting backup takeover during an underway visit. Until then, the
supported path explicitly resolves the recorded incident without reassignment.
Generic existing Ops transitions remain unchanged; this UI exposes only the
recorded prior stage or explicit cancellation.

Synthetic demo records are retained for scoped cleanup. No broad seed/reset,
demo_refresh, patient/consent edit, fare/invoice/payment, paid provider, notification
delivery or GPS behavior was introduced. Previous fixture cleanup remains pending;
refresh grouping fixtures before reuse. PWA remains first and Android preserved.
The 180-minute start window is provisional; production/real data/paid providers gated.
