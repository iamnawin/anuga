# G7 UI and synthetic staging design

Date: 2026-11-06

## Intent

Make the real AnugaCare staging application easier to understand and test on a
phone while preserving the existing Supabase-backed care journey, access rules,
translations, PWA path and Android builds. The target users are older dialysis
patients, family coordinators, non-clinical companions and Ops staff.

## Chosen approach

Use a targeted evolution of the current Flutter product UI. Reuse the approved
tokens, existing components, real role routing and real state-machine actions.
Improve hierarchy, grouped visit progress, primary-action clarity, responsive
behavior and loading/error/recovery states only where inspection proves a gap.

This is preferred over a ground-up redesign because the current UI was already
mapped to prior founder boards, translated, tested and connected to production-
shaped RPC contracts. It is preferred over concept-only mockups because every
visible enabled action must persist through the existing backend.

## Alternatives rejected

- Copy the three boards literally: rejected because they depict unsupported maps,
  calls, clinical/readiness checklists, recurring controls and simplified states.
- Replace Flutter with static web screens: rejected because it breaks Android,
  role routing, existing widget tests and one-app architecture.
- Add mapping/payment/navigation SDKs now: rejected until an existing provider,
  key, privacy boundary and operational need are verified.

## Visual direction

Product register, not marketing. Calm, warm and trustworthy with one familiar
sans family, restrained teal for primary actions/current state, orange for a
small number of meaningful secondary/highlight moments, white/mint surfaces,
minimal elevation and 48-pixel minimum targets. Motion is limited to immediate
state feedback and respects reduced-motion preferences.

## Functional design

- Family: request one supported visit, see pending/confirmed/assigned state,
  reveal OTP only when authorized, follow persisted milestones and completion.
- Patient: use only the view allowed by current Family/patient access. Emphasize
  today's visit, large OTP and chronological status without expanding permissions.
- Companion: group the real lifecycle as preparation, pickup, outbound, centre,
  return and completion. Keep OTP, required notes, issue waiting/resume and denial
  rules authoritative.
- Ops: preserve existing web workflows; change presentation only when required by
  the integrated journey or visual verification.

## Non-goals

No new clinical workflow, emergency dispatch, live GPS, fictional ETA, routine
underway reassignment, cancellation/rescheduling expansion, pricing policy,
production provider activation or independent Patient role.

## Verification

Run widget/unit/analyze/build checks for changed apps, the complete repository
suite, real-Supabase journeys, mobile-width browser screenshots, refresh/reopen
checks and final deployed synthetic smoke. Physical Android install and Telugu/
Hindi meaning approval remain human gates and cannot be inferred from automation.
