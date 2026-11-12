# Screen master list: every screen, what to change, what is missing

Date: 2026-11-12. Draft for founder review. Design and planning only: no code, no changes to any development branch.
Companion to `AnugaCare_App_Navigation_and_Screen_Map.md`. Status sources: `docs/design/tokens.md` (2026-10-11), the migrations, PR #32, and the mockups you shared. "Built" and "KEEP" must be verified against the current app by a developer.

**Status words:** KEEP = exists, no change. CHANGE = exists, or a mockup exists, but it needs the changes listed. NEW = not built, I propose it. SPEC = in `PRODUCT_SPEC.md` but not built. DEFER = in a mockup but not for the pilot.
**Priority:** P0 = needed for the pilot. P1 = soon after. P2 = later.
**Mockup:** Provided = an image you shared. Generated = image made from my prompt. Prompt = prompt written, no image yet. Built = already in the app. None = nothing yet.

## 1. Totals

**81 screens in total.** (Dialogs and small states are counted as screens when the app needs a design for them.)

| By status | Count |
|---|---|
| KEEP | 15 |
| CHANGE | 23 |
| NEW | 34 |
| SPEC | 6 |
| DEFER | 3 |
| **Total** | **81** |

| By area | Screens | KEEP | CHANGE | NEW | SPEC | DEFER |
|---|---|---|---|---|---|---|
| Sign-in and consent (shared) | 5 | 0 | 4 | 1 | 0 | 0 |
| Family: setup, plan and payment | 11 | 0 | 0 | 11 | 0 | 0 |
| Family: main app | 26 | 6 | 8 | 7 | 5 | 0 |
| Companion app | 23 | 4 | 11 | 5 | 0 | 3 |
| Ops console (web) | 10 | 5 | 0 | 4 | 1 | 0 |
| Manager console (web, new role) | 6 | 0 | 0 | 6 | 0 | 0 |

| By priority | Screens | Of which already fine (KEEP) | Work to do |
|---|---|---|---|
| P0 | 46 | 15 | 31 |
| P1 | 21 | 0 | 21 |
| P2 | 14 | 0 | 14 |

**For the pilot (P0): 46 screens, 15 already fine, so 31 to change or build** (19 to change, 11 new, 1 in the spec but not built: withdraw consent and delete data).

**Mockups:** 17 of the 66 screens that need work already have an image (16 you provided, counting 3 deferred screens, plus 1 generated for consent). One more provided image, the pickup code screen, is for a screen that is already fine. **48 still need a mockup image:** P0 19, P1 18, P2 11. Prompts are already written for 16 of them (F3 to F8, F12, F14, F15, F19, F22, F24, F27, F34, C17, C18).

## 2. The list

### Sign-in and consent (shared)

| ID | Screen | Status | Priority | Mockup | What to change or add |
|---|---|---|---|---|---|
| A1 | Welcome with language chips | NEW | P1 | Provided (01) | Not in the design contract. Add English/Telugu/Hindi chips, AnugaCare brand, copy in language files |
| A2 | Sign in (mobile number) | CHANGE | P0 | Built (PR #32) | Keep +91. Add privacy line only if true. Decide on international numbers |
| A3 | Verify code (6 boxes) | CHANGE | P0 | Provided (03) | Resend timer, change number, wrong-code state, 5-attempt message |
| A4 | Consent choices | CHANGE | P0 | Generated | Remove 'each time' label; say what happens if trips is off; support-vault switch only when vault is on |
| A5 | Account status (waiting / suspended) | CHANGE | P0 | None | Exists. Show companion funnel steps as plain text |

### Family: setup, plan and payment

| ID | Screen | Status | Priority | Mockup | What to change or add |
|---|---|---|---|---|---|
| F1 | Setup step 1: Patient details | NEW | P0 | None | First name, age band, relationship, language, mobility needs |
| F2 | Setup step 2: Visit pattern and place | NEW | P0 | None | Home pin, centre, days and shift, emergency contact |
| F3 | Setup step 3: Choose a plan | NEW | P0 | Prompt | Trial, Care Plan, Safe Return cards; top progress bar |
| F4 | Setup step 4: Review and pay | NEW | P0 | Prompt | Summary, deposit credit, GST line 'to be confirmed', refund terms |
| F5 | Choose how to pay | NEW | P0 | Prompt | UPI apps, UPI ID, QR, card; test mode only |
| F6 | Waiting for payment | NEW | P0 | Prompt | Pending state, timeout text, 'check again' |
| F7 | Payment successful | NEW | P0 | Prompt | Receipt number, next steps |
| F8 | Payment failed or pending | NEW | P0 | Prompt | Calm wording, try again, help |
| F9 | Setup step 5: All set | NEW | P0 | None | First visit date, what happens next |
| F10 | Send payment link | NEW | P1 | None | For a payer who is not the account holder |
| F11 | Payment link page (for the payer) | NEW | P1 | None | Mobile web page, plan summary and pay |

### Family: main app

| ID | Screen | Status | Priority | Mockup | What to change or add |
|---|---|---|---|---|---|
| F12 | Home | CHANGE | P0 | Prompt | Next-visit card, progress bar, plan card, quick actions |
| F13 | Patient picker | KEEP | P0 | None | Exists |
| F14 | Visits list (Upcoming / Past) | CHANGE | P0 | Prompt | Tabs, status chips with words |
| F15 | Visit detail with 9-step progress bar | CHANGE | P0 | Prompt | Pickup code (6 digits) card, timeline, note; no map or ETA |
| F16 | Cancel visit dialog | KEEP | P0 | None | Exists, only before the companion sets off |
| F17 | Reschedule or edit pattern | SPEC | P1 | None | In spec, not built |
| F18 | Updates inbox | KEEP | P0 | None | Exists |
| F19 | Records list | CHANGE | P0 | Prompt | Privacy banner; vault-off card |
| F20 | Add photo to records | KEEP | P0 | None | Exists |
| F21 | Record viewer | KEEP | P0 | None | Exists |
| F22 | Bills list | CHANGE | P0 | Prompt | Segmented: Bills | Plan and receipts |
| F23 | Bill detail and test payment | KEEP | P0 | None | Exists |
| F24 | Plan and receipts | NEW | P0 | Prompt | Trips left, expiry, receipts |
| F25 | Receipt detail | NEW | P1 | None | Downloadable |
| F26 | Refund request and status | NEW | P1 | None | Trial unused-trip refunds |
| F27 | More menu | NEW | P1 | Prompt | Patients and access, privacy, language, help, sign out |
| F28 | Privacy choices (settings) | CHANGE | P0 | None | Exists; add conditional support-vault switch |
| F29 | Withdraw consent and delete data | SPEC | P0 | None | Required by the product spec (DPDP); not built |
| F30 | Preferences | NEW | P2 | None | Language, notifications; 'likes' meaning to confirm |
| F31 | Help and support | NEW | P1 | None | Support number, report a problem |
| F32 | Privacy notice and About | NEW | P1 | None | Static pages |
| F33 | Family members and access (invite with roles) | SPEC | P1 | None | In spec, not built |
| F34 | Viewer variant of Home | CHANGE | P1 | Prompt | No cancel, no billing |
| F35 | Patient-access variant of Home | CHANGE | P1 | None | Own next visit, pickup code, updates |
| F36 | Requests ('I need...') | SPEC | P2 | None | In spec, not built |
| F37 | Medicines | SPEC | P2 | None | Clinical: ask before building (repo rule) |

### Companion app

Final spec for C1 to C20 (approved 2026-11-12): `screen_mockups/Companion_Screens_FINAL_Spec_v1.md`. Where this table and the spec differ, the spec wins.

| ID | Screen | Status | Priority | Mockup | What to change or add |
|---|---|---|---|---|---|
| C1 | Become a companion / invite application | CHANGE | P1 | Provided (29) | Make invite-only; availability by shift, not Morning/Evening |
| C2 | Verification status | CHANGE | P1 | Provided (30) | ID document and Training only; no background-check row until it exists (D6) |
| C3 | Today | CHANGE | P0 | Provided (31) | No notification count; tabs Today, Visits, Me (D4) |
| C4 | Upcoming / Visits | KEEP | P0 | None | Exists |
| C5 | Trip essentials | CHANGE | P0 | Provided (32) | Illustrated avatars; drawn route card; Navigate opens phone maps; Call AnugaCare support; start button follows the start window |
| C6 | On the way (en route) | CHANGE | P0 | Provided (33) | Remove live map and ETA; drawn route card + Navigate; 'I have arrived' later (ADR) |
| C7 | Pickup code | KEEP | P0 | Provided (34) | 6 digits; add attempts message |
| C8 | At the centre | CHANGE | P0 | Provided (35) | Remove live map and ETA; route card, timeline with real times, Navigate |
| C9 | Handover checklist | CHANGE | P0 | Provided (36) | Auto time stamp; staff name optional |
| C10 | Session in progress (waiting) | NEW | P0 | None | Missing from the mockups: between handover and 'session finished' |
| C11 | Return journey | CHANGE | P0 | Provided (37) | Remove live map and ETA; timeline, route card, Navigate |
| C12 | Home arrival | CHANGE | P0 | Provided (38) | 'Handed to' choice; no phone numbers (D1) |
| C13 | Visit note | CHANGE | P0 | Provided (39) | Note required; fare and receipt deferred |
| C14 | Visit completed | CHANGE | P0 | Provided (40) | Without earnings |
| C15 | Report an issue | KEEP | P0 | None | Exists |
| C16 | Patient not available | KEEP | P0 | None | Exists |
| C17 | Help and emergency guidance | NEW | P1 | Prompt | Support number, 'In an emergency call 112' |
| C18 | Me (profile, status, language) | NEW | P1 | Prompt | Verification, training status, sign out |
| C19 | Availability (shifts and days) | NEW | P1 | None | Needed for crew scheduling |
| C20 | Document upload for onboarding | NEW | P2 | None | ID capture |
| C21 | Earnings | DEFER | P2 | Provided (40) | Needs a payout model |
| C22 | Fare and receipt entry | DEFER | P2 | Provided (39) | Needs a controlled fare source |
| C23 | Live map, ETA and directions | DEFER | P2 | Provided (33,35,37) | Needs consent, cost, ADR. Static two-pin map (M1) also needs an ADR |

### Ops console (web)

| ID | Screen | Status | Priority | Mockup | What to change or add |
|---|---|---|---|---|---|
| O1 | Trips board | KEEP | P0 | Built | Exists |
| O2 | Trip reassignment | KEEP | P0 | Built | Exists |
| O3 | Schedules and assignment | KEEP | P0 | Built | Exists |
| O4 | Exceptions queue | KEEP | P0 | Built | Exists |
| O5 | Billing and fare entry | KEEP | P0 | Built | Exists |
| O6 | Plan sales and refunds | NEW | P1 | None | Follows the payment ADR |
| O7 | Companion onboarding queue | SPEC | P1 | None | In spec, not built |
| O8 | Centre permission map and protocol tracker | NEW | P1 | None | From the partnership strategy |
| O9 | Reliability report for centres | NEW | P1 | None | On-time drop, pickup wait, incidents |
| O10 | Leg-level assignment (swap runs) | NEW | P2 | None | Needs an ADR |

### Manager console (web, new role)

| ID | Screen | Status | Priority | Mockup | What to change or add |
|---|---|---|---|---|---|
| M1 | Manager dashboard | NEW | P2 | None | Metrics, gates |
| M2 | Approvals (refunds, companion verification) | NEW | P2 | None | New role needs an ADR |
| M3 | Incident review | NEW | P2 | None |  |
| M4 | Business settings (prices, windows) | NEW | P2 | None | Values live in settings, not code |
| M5 | Centres and partnerships | NEW | P2 | None |  |
| M6 | Users and roles | NEW | P2 | None |  |

## 3. What we missed (not in any mockup or not yet in the plan)

| Gap | Why it matters |
|---|---|
| Companion: session-in-progress screen (C10) | Nothing shows the companion what to do between handover and 'session finished'. The state machine has `handed_over` then `session_done`. |
| Family: patient details and visit-pattern screens (F1, F2) | Not in any mockup you shared. Without them a family cannot create a patient or schedule. They are in the design contract as intentionally not built. |
| Family: withdraw consent and delete data (F29) | The product spec requires it (DPDP). It is not designed and not built. |
| Consent screen rules (A4) | Remove 'needs your permission each time'; say what happens if trips is off; show the support-vault switch only when the vault is on. |
| Payment screens and the prepaid model (F3 to F11, F24 to F26) | Prompts exist for F3 to F8; no images yet; the plan model needs an ADR. |
| Reschedule, receipt, refund screens (F17, F25, F26) | Needed once plans and trials exist. |
| Help and support in both apps (F31, C17) | Only a design idea so far. |
| Companion: availability by shift (C19) and onboarding documents (C20) | Needed for the intake funnel and crew scheduling. |
| Static pages: privacy notice, terms, About (F32) | Legal text must come from your lawyer. |
| Error, empty, offline and slow-network states | Not designed for any list or flow. Every screen needs them. |
| Dark-mode versions of every screen | Only the login and consent are shown dark. |
| Telugu and Hindi versions | None of the mockups show them; text length changes layouts. |
| 200% text-size check | Needed for every screen. |
| Ops and Manager screens (O6 to O10, M1 to M6) | New role and new web screens. Design after the ADR. |
| Masked calling (companion to family) | Replaces raw phone numbers; needs a provider decision and an ADR. |
| Arrival-at-pickup event and leg-level assignment (platform) | Needed to measure pickup wait for centres and to run swap routes. Needs ADRs. |
| Centre-facing view | A partner view for centres is in the spec as 'later'; not planned here. |

## 4. Order of work for the pilot (P0, 31 screens to change or build: 5 + 9 + 7 + 10)

- **Batch 1: sign-in and consent (5):** A2, A3, A4, A5 plus F29 (withdraw and delete). Needed before any real data.
- **Batch 2: family set-up (9):** F1, F2, F3, F4, F5, F6, F7, F8, F9 (P0 wizard and payment in test mode); F10 and F11 come later.
- **Batch 3: family main (7):** F12, F14, F15, F19, F22, F24, F28. The pickup code card is part of F15.
- **Batch 4: companion trip (10):** C3, C5, C6, C8, C9, C10, C11, C12, C13, C14. C7 (pickup code) is already fine.
- **Batch 5: P1 follow-ups:** Help, More, receipts, refunds, invite family, reschedule, companion onboarding, availability, Ops plan sales and reports.

## 5. Decisions that change the count

1. **Wizard before or after payment:** I recommend patient and visit setup first (F1, F2 before F3 to F8).
2. **Solo or swap scheduling for the pilot:** swap needs leg-level assignment (O10) and a run view.
3. **Maps, earnings, fare entry (C21 to C23):** left out of the pilot; adding any one adds work and an ADR.
4. **Manager role:** M1 to M6 stay P2 until you confirm the definition.
5. **'Likes' (F30):** confirm what you meant.

## 6. Limits
- Counts are my design inventory, not a developer estimate. Dialogs and variants are counted as screens, which may differ from how a developer counts routes.
- KEEP and Built statuses come from `docs/design/tokens.md` (2026-10-11), the migrations and PR #32; the app has changed since and each must be verified.
- Telugu, Hindi and dark mode multiply the visual deliverables but not the screen count.
