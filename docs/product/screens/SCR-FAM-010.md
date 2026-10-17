# SCR-FAM-010 — consent (design screen 04)

Spec ready for review, not Approved. FEAT-006; CMP-010/011. ANU-002 owns the
entry/consent specification review; owner Unassigned. Existing implementation:
apps/family_app/lib/src/screens/consent_screen.dart, FamilyApi.consents/setConsent,
migration 0800. This specification does not add an onboarding gate.

Scenario: a linked Family owner reviews the patient's consent purposes. Current
entry is Home privacy or Records, with Back to that destination. Concept 04 puts
consent immediately after login; that placement depends on D2 patient creation,
owner identity and consent capture. A login without a patient cannot supply an
invented patient ID to set_consent. Other role logins do not create owner consent.

Layout: patient context and consent heading → purpose descriptions/switches →
save/withdraw feedback. Reuse actual purpose switches and tokens, not independent
per-invite vault toggles. Board 1:04 shows trips and optional private vault;
current purposes also include ops_vault_access. Describe those distinctly and
truthfully. No unsupported claim about legal sufficiency or retention/deletion.

| Action/state | Existing data/control flow | Result/failure |
| --- | --- | --- |
| Open | FamilyApi.consents(patientId) → family_consents | Loading, purposes/canChange or error; no consent assumed active |
| Enable purpose | Owner → setConsent → set_consent | Reload actual state; show error if rejected; no synthetic success |
| Disable purpose | Existing confirmation → set_consent(false) | Keep/turn off; reload; withdrawal does not prove stored files deleted |
| Back | Existing Navigator | Return without additional writes or onboarding progress claim |

Permissions: linked owner/editor/patient/viewer can read returned consent status;
only owner can change it. Companions have no consent-management path. Ops cannot
grant owner consent to itself; audited Ops vault reads require active owner
ops_vault_access. Anonymous/unrelated users are denied. Linked Family viewer vault
read remains current SQL behavior; concept image text does not revoke that access.

States to verify: loading, no linked patient (route must not open with invented
context), non-owner read-only, revoked access, request failure/retry, confirmation
dismissal, save/withdraw failure and successful refresh. Existing initial errors
are text; a new retry/save-progress design needs explicit implementation scope.
No trip notification or external delivery is promised by a consent toggle.

Use 48px targets, readable purpose labels, existing light/dark tokens, uncapped
text scaling, scrollable confirmation and en/te/hi. At 360/430/wide and 2x/3x
text, switches and consequences remain associated and keyboard/screen-reader usable.

Acceptance: owner toggles each real purpose; editor/patient/viewer cannot write;
unrelated/Companion/Ops/anonymous attempts fail in the DB. Confirm and dismiss
withdrawal separately; preserve state on errors, never show deletion completed.
Resolve D2 before routing new users from Auth OTP through mandatory consent.
Historical records/widget and vault SQL tests exist; no runtime checks in this audit.

ANU-002 boundary (2026-10-16): entry gate changes do not call create_patient,
set_consent or grant patient access. Account lifecycle and patient ownership/consent
remain separate; see [pilot access contract](../PILOT_ACCESS_CONTRACT.md).
