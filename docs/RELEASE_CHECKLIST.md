# AnugaCare synthetic staging release checklist

Last reconciled: 2026-11-07 11:02:46 IST (Asia/Kolkata)

This checklist tracks the current autonomous integration/UI/staging mission. It
does not replace `PRODUCTION_GATES.md`; real patient onboarding remains NO-GO.

11 November attestation update: live synthetic identity verified, but three Nov 4
hardening effects are missing and history diverges. Backup listing provides no
usable restore point; PITR false. Gate G remains BLOCKED by confirmed drift and
recovery gaps (not missing CLI access). Gate D's earlier PASS is candidate-CI
evidence only; hosted security parity FAILS. See the detailed
[receipt](evidence/g7-ui-staging-2026-11-07/STAGING_ATTESTATION.md).

| Gate | Measurable acceptance | Current evidence | State |
| --- | --- | --- | --- |
| A Integration | All in-scope stack/UI commits reconciled and merged to main; no local-only intended work omitted | #22-#27 merged through `ea6d142`; UI release work pending | INCOMPLETE |
| B UI | Approved branding/tokens and coherent supported Family, Patient-view, Companion and Ops interfaces are deployed | Branch screenshots reviewed; runtime changes tested in CI; hosted deployment pending | INCOMPLETE |
| C Functionality | Deployed synthetic Family -> Ops -> Companion -> Family journey persists through refresh and completion | CI journey passes at `d14e55c`; target is not deployed | INCOMPLETE |
| D Security | RLS, consent withdrawal, private issue notes, OTP, session isolation and occupancy allowed/denied tests pass on release candidate | PR #28 real-Supabase CI `42342439646` passes all allowed/denied and journey checks | PASS |
| E PWA | Deployed manifest/icons/scope/service worker/install/session/cache behavior pass desktop checks and physical install cases | Prior PWA implementation exists; target deployment and physical test pending | INCOMPLETE |
| F Testing | Required CI, real browser visual inspection, functional/negative journeys and Android build checks pass | Local check-all and PR #28 CI `42342439646` pass; 17 actual screenshots and APK inspected/hashed | PASS |
| G Deployment | Exact main commit plus migration versions are verified on existing synthetic staging, never production | Identity verified; missing Nov 4 hardening effects, divergent history and no usable recovery proof (ATTEST-001) | BLOCKED |
| H Handoff | URLs, safe accounts/roles, screenshots, CI/migration evidence, phone guide, limits and next actions are current | Durable recovery documents are being established | IN_PROGRESS |

## Human/external acceptance kept separate

- Physical Android Chrome and installed-PWA acceptance: NOT TESTED.
- Telugu native-language approval: NOT TESTED.
- Hindi native-language approval: NOT TESTED.
- Healthcare/service wording approval: NOT TESTED.
- Production isolation/recovery/safety rehearsal and founder release approval:
  BLOCKED/NOT TESTED under `PRODUCTION_GATES.md` G8.

## Required final decision language

Use exactly one of:

- `STAGING READY - VERIFIED`
- `STAGING PARTIALLY READY - BLOCKED`
- `STAGING NOT READY`

Never use staging readiness as production approval.
