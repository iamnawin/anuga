# Review of the 20 companion screens (PDF "Campanion_screens", 22 pages)

Date: 2026-11-12. Direction only, not specification. I did not build or change anything.
**Limit of this review:** the PDF pages are cropped at the bottom, so buttons and lower sections of about half the screens are cut off (marked "cut"). Please export full-length screens to check them. Pages 5 and 22 are blank.

## 1. Verdict

The set is good and covers every companion screen in my list (C1 to C20). The flow reads clearly, the wording is calm, the pickup code is 6 digits, and no phone number is shown. **Eight things must be fixed before it goes to a developer** (section 2). Then the per-screen notes (section 3).

## 2. Fix these first (across screens)

| # | Problem | Where | Fix |
|---|---|---|---|
| 1 | **A "Records" tab is shown to the companion.** Companions must never see the vault or records (design contract, spec). | Returning home (C11) top tabs: Today, Visits, Records, Profile | Remove Records. Use Today, Visits, Me. |
| 2 | **Sample data does not match.** Patient is Ravi, Ravi Mehta, Aarav Mehta and Maya Desai. Centre is City Dialysis Centre, Riverdale Care Centre, Riverside Community Centre. Dates are 12 and 19 January 2026 while Today says 12 November. | Report an issue (C15), Patient not available (C16), Confirm handover (C9) look like older drafts | Regenerate those three with Ravi, City Dialysis Centre, Kukatpally, Nov 2026. C15 and C16 also say "Activity Centre" and "community activity", which is not dialysis. |
| 3 | **Three header styles.** (a) back arrow plus teal "Companion", (b) logo, "Companion", bell and grey avatar, (c) plain title. | whole set | Pick one. Suggest: back arrow plus screen title for flow screens; logo header only on Today. Drop the grey placeholder avatar. |
| 4 | **Patient photo is photographic on one screen and illustrated on others.** Trip essentials has a realistic photo; visit note and completed use a cartoon avatar. Photos are banned by the contract until an ADR and consent exist. | C5, C13, C14 | Use one style. For now use the illustrated avatar or initials. |
| 5 | **No way to reach the family at the door.** "Family contact: Anita" has no call button, and there is no "I have arrived" action. | C5, C6 | Needs a decision: masked call (an ADR) or an "arrived for pickup" event. Without one, the companion has no tool when nobody answers. |
| 6 | **Two Ravi visits on the same day (7:00 am and 12:00 pm) look like two separate visits.** Probably drop and return legs. Today also lists "8:00 am Anita" while Anita is the family contact. | C4, C3 | Label the legs: "Drop 7:00" and "Return 12:00". Use a different name for the family contact. |
| 7 | **Availability still has the old design** (bundles Mon-Wed-Fri, no Sunday, Evening selectable, hours do not match shifts). | C19 | Per-day grid; Evening greyed "not offered yet". See `C19_availability`. |
| 8 | **"Background check" appears as a step.** We have not set up any background check, so this promises a process that may not exist. | C2 | Show only steps that really exist (ID, training). Add the background step only when it is real, after the lawyer and vendor are decided. |

## 3. Screen by screen

| Screen | File | Looks right | Change |
|---|---|---|---|
| C1 Become a companion (invite) | Invited companion account setup-4 (cut) | Invite-only, "Invitation accepted" | Mobile number should be read-only (it is the login). Add contractor wording and consent tick. The "AnugaCare" t-shirt implies a uniform or employment; check with the lawyer before using it. Add vehicle type (none, bike, auto), language. |
| C2 Verification | Your verification | Plain words, amber chips with words, "assigned visits after verification" | Fix #8. Add dates. |
| C3 Today | Companion daily visit-7 | Clear next visit and "Open visit" | Fix #6 for the Upcoming row. Add a banner when no visit is assigned. |
| C4 Upcoming | Upcoming visits-2 (cut) | Grouped by date, status chips | Fix #6. Add Navigate nothing here; keep as a list. |
| C5 Trip essentials | Trip essentials-1 (cut) | Address, walking stick, family first name only | Fix #4 and #5. Add centre address and Navigate (opens the phone's maps app). Button "Start journey" is cut. |
| C6 On the way | En route to Ravi-6 | Status word "En route", scheduled time | Add Navigate; fix #5. Show the 8-step progress bar. |
| C7 Confirm pickup | Confirm pickup, six-digit code-5 | Asks for the code; 6 boxes | The sample shows the code filled in. Draw it empty with the keypad. Add states: wrong code (attempts left), locked after 5 tries, expired. |
| C8 At the centre | At the centre-19 | Clear next step | See `C8_at_the_centre`. |
| C9 Confirm handover | Confirm handover-3 (cut) | Checklist: received by staff, belongings | Fix #2. Name of the staff member who received? Optional field. |
| C10 Session in progress | Session in progress-9 (cut) | Fills the gap I flagged. "Wait for the centre to confirm" is good | Rename the "Scheduled 12:00 pm" card "Return pickup (expected)". Add "Sessions usually take 4 to 5 hours" and what to do if the centre is late. Check the state machine allows the companion to mark the session finished. |
| C11 Returning home | Returning home-8 (cut) | Short timeline | Fix #1. The progress shows only 3 steps; use the full 8-step bar. |
| C12 Home arrival | Home arrival-10 | Simple, one action | Add "Handed to: family / patient at door" choice. |
| C13 Visit note | Add visit note-11 | "Record visit details only" keeps it non-clinical | Fix #4. Pre-filled text is fine as a hint, not as the saved note. Add quick tags (on time, delay at centre) later. |
| C14 Visit completed | Visit completed | Warm and short | Duplicate title and a lower-case "v". See `C14_visit_completed`. |
| C15 Report an issue | Report an issue-18 (cut) | Bottom sheet | See `C15_report_issue`. Fix #2. A raw phone number, +91 98765 43210, is shown behind it. |
| C16 Patient not available | Patient pickup confirmation-14 (cut) | "Confirm only if you could not pick up", Keep visit | Fix #2. Add how long to wait first (for example 15 minutes) and the effect (no-show fee?) in words. Pricing decision is yours. |
| C17 Help and emergency | Help and emergency-15 (cut) | Honest: "AnugaCare does not send emergency help" | Show 112 as well as 108. Add "Call AnugaCare support" (cut, check). |
| C18 Me | Companion Profile and Settings-20 | | See `C18_me`. |
| C19 Availability | Choose your weekly work shifts-17 | | Fix #7. |
| C20 Upload document | Identity document upload-12 | "Upload only the requested document" | Add a short line on who can see it and how long it is kept. Add camera capture. Decide which IDs are accepted (take care with Aadhaar). |

## 4. What this changes in the lists

- All companion screens C1 to C20 now have a mockup (C21 to C23 stay deferred).
- Of the 48 screens without an image, **5 are now done**: C10, C17, C18, C19, C20. **43 remain.** Of the 19 pilot screens, 18 remain (C10 done). I have not edited the master list yet.
- Boards 5, 8 and 9 in the image-prompt file shrink: drop C10, C17 (board 5), C18 (board 8), C19 and C20 (board 9). I can regenerate those prompts.
- New platform gaps from this review: an "arrived for pickup" action or masked calling (#5), a background-check decision (#8), and contractor wording (C1).

## 5. What I need from you

1. A full-length export of the cut screens (C1, C4, C5, C7 to C11, C15 to C17) so I can check the buttons and lower sections.
2. A choice on #5: masked calling, or an "I have arrived" action, or neither in the pilot.
3. Whether the "AnugaCare" t-shirt on the companion illustration is intended.

## 6. Addendum: full-length checks (5 screens, same day)

Images are in the folders `C5_trip_essentials`, `C1_become_a_companion`, `C7_confirm_pickup`, `C17_help_and_emergency`, and `C19_availability/mockup_v2_unchanged.webp`.

| Screen | What the full length shows | Still to change |
|---|---|---|
| **C5 Trip essentials** | "Start journey" button is present. Photo is a realistic face. | No Navigate button and no centre address. The realistic photo breaks the no-photo rule and looks like a real person: use the illustrated avatar or initials. No way to reach the family (finding #5). |
| **C1 Become a companion** | Name, mobile, neighbourhood, Continue. Nothing below. | Mobile should be read-only. Missing: consent tick, contractor wording, language, vehicle type (none, bike, auto), emergency contact. T-shirt question stands. |
| **C7 Confirm pickup** | Button reads "Verify and confirm pickup". Code boxes filled. | Draw the empty state with a number keypad. Add wrong-code, attempts-left, locked and expired states. |
| **C17 Help and emergency** | Only two cards: Call 108, and Report an issue. The lower half is empty. | **Add "Call AnugaCare support"** and 112. Add three short guides (patient feels unwell, cannot find family, centre not ready) and the line "You are a companion, not a medical professional." Keep "AnugaCare does not send emergency help": it is honest. |
| **C19 Availability** | Same as before. | Redesign still needed (finding #7). |

Cut screens still to check: C4, C8 to C11, C15, C16.
