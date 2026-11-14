# Legal acceptance: evidence requirements and current gaps

Date: 2026-11-13. Status: engineering notes for founder and lawyer review. Not legal advice.
The legal texts are DRAFT (`lawyer-review-pack.md`); no lawyer sign-off is recorded in this repository.

## 1. Three separate things

| Thing | What it is | Where it lives today |
|---|---|---|
| Terms of service | A contract the account holder accepts once per version | Draft text only. No acceptance flow, no storage |
| Privacy notice | Information we must show. It is read, not "agreed to" | Draft text only, readable from the consent screen |
| Data consents | Per-patient, per-purpose choices the owner switches on or off | Built: `consents` table, `family_consents()`, `set_consent()`, Consent screen |

They must stay separate. Accepting terms must never switch on a consent, and a consent switch must never count as accepting terms.

## 2. What a valid acceptance record needs (proposed, for the lawyer to confirm)

For terms acceptance, one row per user per document version:

1. Who: the signed-in user id.
2. What: document kind and exact version identifier.
3. Exact text: a hash of the text shown, so the wording can be proved later.
4. Language shown.
5. When: server time, not device time.
6. How: an explicit action by the user (a button or an unticked box they tick). Never pre-ticked.
7. Where from: app surface and app version.
8. Append-only: rows are never updated or deleted by app roles; a new version creates a new row.

For data consents, the same items 1 to 8, plus:

9. Which patient and which purpose.
10. Which privacy notice version was on screen when the choice was made.
11. Withdrawal as its own dated event, as easy as the grant.
12. If the lawyer requires it (question Q5 in the pack): the patient's own consent, recorded separately from the owner's.

## 3. What is stored today

`public.consents`: `id`, `user_id`, `patient_id`, `purpose` (`trips`, `vault`, `ops_vault_access`), `granted_at`, `withdrawn_at`.
Each insert and update also writes an `audit_log` row through the `consents_audit` trigger.
Only the patient's owner can change a consent (`set_consent()` checks this in the database).

## 4. Gaps

| # | Gap | Why it matters | Needs |
|---|---|---|---|
| G1 | No record of terms acceptance at all | Nothing proves a user accepted any terms | New table and RPC (backend), then an acceptance screen |
| G2 | Consent rows do not record which notice version or text the user saw | Cannot prove the consent was informed | New columns or a linked table (backend) |
| G3 | Consent rows do not record the language shown | Same | Backend |
| G4 | `create_patient()` inserts a `trips` consent automatically when a patient is created | That consent is implied, not given by an explicit action. No app screen calls this function today, but it exists | Backend change before any self-service patient setup is built |
| G5 | No record of the patient's own consent, only the owner's | Depends on the lawyer's answer to Q5 and Q6 | Decision first, then backend |
| G6 | Withdrawal overwrites `withdrawn_at` on the row; the only event history is `audit_log` | Probably acceptable, lawyer to confirm | Decision |
| G7 | No terms or notice version is checked at sign-in, so a changed document cannot trigger a new acceptance | Needed once documents are approved and later revised | Backend plus app |
| G8 | No deletion or access-request process | Listed in the lawyer pack, Part G | Process, then feature F29 |
| G9 | Telugu and Hindi legal text does not exist | The notice must be readable in the user's language | Legally reviewed translations |

None of G1 to G9 is fixed in this change. Each backend item needs its own migration with allowed and denied tests.

## 5. How a draft is kept from becoming binding

- Documents are defined in `apps/family_app/lib/src/legal/`. A draft is created with `LegalDocument.draft`; it has no approval reference and no effective date.
- `LegalDocument.canRequestAcceptance` is true only when the document is marked approved, names the lawyer's written sign-off, has an effective date, and contains no `[To be confirmed: ...]` blank.
- `LegalDocumentScreen` is read-only. It has no accept button, checkbox or switch. It shows a pinned "Draft. Not approved. Not in force." banner whenever `canRequestAcceptance` is false, including when someone marks a document approved without recording the sign-off.
- Tests in `apps/family_app/test/legal_documents_test.dart` fail if the shipped documents stop being drafts without the above, or if the screen gains a control that could record agreement.
- No acceptance flow exists. When one is built it must refuse to render unless `canRequestAcceptance` is true.

## 6. Steps to go from draft to live (in order)

1. Founder fills the blanks in Part H of the lawyer pack.
2. Lawyer answers the questions and returns corrected text with written approval.
3. The signed approval is filed under `docs/legal/` and the English text in the app is replaced, using `LegalDocument.approved` with that file as the reference.
4. Telugu and Hindi translations are legally reviewed and added.
5. Backend work for G1 to G4 and G7 is designed, tested and merged.
6. Only then is a terms acceptance step added to sign-up.
