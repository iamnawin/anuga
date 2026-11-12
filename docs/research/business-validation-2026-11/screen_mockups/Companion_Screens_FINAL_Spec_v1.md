# Companion app: final screen spec v1 (for sign-off, then handover to the developer)

Date: 2026-11-12. Draft for founder approval. Not code. Built from the 20 mockups and the review in `Companion_Screens_Review_2026-11-12.md`.
How to use: (1) accept or change the 7 decisions, (2) generate the 5 boards in section 5 so the whole set matches, (3) give the developer this file plus the 5 boards. Images are direction only; this file is the specification.

## 1. Decisions (recommended default first; change any you disagree with)

| # | Decision | Recommended default | Why |
|---|---|---|---|
| D1 | How does the companion reach the family at the door? | **Pilot: "Call AnugaCare support" button; ops phones the family.** Add an "I have arrived" action later (needs a small backend event, ADR). No masked calling yet. | Cheapest, no new telephony. Without any option the companion is stuck. |
| D2 | Patient photo in the app | **None in the pilot.** Initials or the illustrated avatar. Photos come later with an ADR and consent. | Design contract bans it today. |
| D3 | Companion illustration | **Plain illustrated avatar, no "AnugaCare" t-shirt.** | A branded shirt implies employment. Ask the lawyer first. |
| D4 | Bottom navigation | **Today, Visits, Me.** Help lives inside Me and as a link on trip screens. No Records tab. | Companions never see records. |
| D5 | Maps | **"Navigate" button that opens the phone's maps app.** No in-app map, no ETA. | No SDK, no data sent to us. |
| D6 | Background check step | **Removed** until it really exists. Verification shows ID document and Training only. | Do not promise what we do not do. |
| D7 | Emergency numbers | **Show 112 and 108.** Keep "AnugaCare does not send emergency help." | Both are valid in India. |

## 2. Rules for every companion screen

- **Header:** back arrow plus screen title (flow screens). Logo header only on Today. No grey placeholder avatar. Bell icon only if notifications are built for companions; never show a count.
- **Trip run progress:** thin 8-step bar with the text "Step n of 8". Steps: Assigned, On the way, Picked up, At centre, Handed over, Session done, Returning, Home. (Maps to the existing trip states.)
- **Sample data (use everywhere):** companion Suresh Kumar; patient Ravi (first name only); family contact "Anita"; centre City Dialysis Centre, Kukatpally (sample address); home 12 Lake View Road, Kukatpally; today Thursday 12 November 2026.
- **Sample times:** pickup 7:00 am, at centre 7:25 am, handover 7:35 am, session expected to end about 11:45 am, return pickup 11:45 am to 12:15 pm, home about 12:30 pm.
- **Privacy:** companions see first name, pickup place, centre, mobility note and family first name only. No diagnosis, date of birth, billing, records or raw phone numbers.
- **Words:** "companion", never nurse. Status always with a word. Buttons at least 56 px, text 16 to 18 px, works at 200% text, light and dark, English, Telugu and Hindi.
- **Every screen needs:** loading, error with retry, and offline states (listed in section 4).

## 3. Final spec per screen

| ID | Screen | Final content | Buttons and what they do | Mockup action |
|---|---|---|---|---|
| C1 | Become a companion (invite) | Neutral avatar; "Invitation accepted"; Full name; Mobile (read-only); Neighbourhood; Language; Vehicle (None, Bike, Auto); Emergency contact; consent tick "I agree to the companion terms and the privacy notice"; line "You are an independent companion" (lawyer to confirm) | Continue: saves profile, goes to C20 | Regenerate |
| C2 | Verification | Rows: ID document (Received), Training (Pending), with dates. Info: "You can receive visits after verification." No background-check row | Back | Regenerate |
| C3 | Today | Greeting, today's visit card (time, patient first name, pickup area, centre), "Open visit"; Upcoming preview with Drop and Return labels; empty state "No visit assigned today" | Open visit goes to C5; View upcoming goes to C4 | Small fix (names) |
| C4 | Upcoming | Grouped by date; each leg labelled "Drop 7:00 am" or "Return 11:45 am"; status chip with word | Tap goes to C5 | Regenerate |
| C5 | Trip essentials | Patient initials avatar, Ravi, time, date; pickup address; centre name and address; mobility note; family contact first name | **Navigate** (opens maps), **Call AnugaCare support**, **Start journey** (state: on the way) | Regenerate |
| C6 | On the way | 8-step bar (2); status "On the way"; pickup address; mobility note; family contact | Navigate; Call support; Confirm pickup (goes to C7); Report an issue | Regenerate |
| C7 | Confirm pickup | Patient name; pickup place; hint "Ask Ravi or the family for the pickup code"; 6 empty code boxes and keypad | Verify and confirm pickup: checks the code, sets Picked up. Wrong code: "That code is not right. 3 tries left." After 5 wrong: "Locked. Call support." Patient not available (goes to C16) | Regenerate |
| C8 | At the centre | Bar (4); patient; centre name and address; times picked up and arrived; "Next: hand over to centre staff" | Continue to handover (C9); Navigate; Report an issue | Regenerate |
| C9 | Confirm handover | Patient first name; centre; checklist "Patient received by centre staff", "Belongings handed over"; optional note | Confirm handover: needs staff box ticked, sets Handed over (C10) | Regenerate |
| C10 | Session in progress | Bar (5 or 6); "Handover complete 7:35 am"; text "Sessions usually take 4 to 5 hours. You can wait nearby or take a break."; card "Return pickup expected 11:45 am"; note "Wait for the centre to say the session is finished" | Confirm session finished (C11); Report an issue; Call support | Small fix (labels) |
| C11 | Returning home | Bar (7); patient with you; destination address; tabs removed | Navigate; Confirm home arrival (C12); Report an issue | Regenerate |
| C12 | Home arrival | "Ravi is home. Dropped home 12:30 pm"; choice "Handed to: family member / patient at the door"; "The visit is complete once you submit your note" | Add visit note (C13) | Small fix (choice) |
| C13 | Visit note | Patient initials avatar; "Home arrival 12:30 pm"; empty text box with hint; line "Record visit details only. No medical notes."; optional quick tags (On time, Delay at centre) | Submit and complete visit (C14) | Small fix (avatar, empty box) |
| C14 | Visit completed | One title, one success card "Thank you, Suresh"; mini timeline (picked up, at centre, handed over, home); "Next visit" if any | Back to Today | Regenerate |
| C15 | Report an issue (sheet) | Chips: Patient not ready, Patient unwell, Cannot find family, Centre not ready, Other; text box; red line "In an emergency call 112 or 108" | Send report (sets Issue reported); Cancel | Regenerate |
| C16 | Patient not available (sheet) | "Confirm only if you could not pick up the patient. Please wait 15 minutes first." | Keep visit; Confirm patient not available (sets No-show) | Regenerate |
| C17 | Help and emergency | Emergency card: "Medical emergency? Call 112 or 108. AnugaCare does not send emergency help."; Call AnugaCare support; Report an issue; guides: Patient feels unwell, Cannot find family, Centre not ready; "You are a companion, not a medical professional. Do not give medicine." | Call 112 / 108; Call support; Report an issue | Regenerate |
| C18 | Me | Avatar, Suresh Kumar, Companion; rows Verification (status in words), Availability, Documents, Language, Help and emergency; Sign out | Each row opens its screen; Sign out asks to confirm | Small fix (nav, status line) |
| C19 | Availability | Grid Mon to Sun by Morning and Midday; Evening greyed "Not offered yet"; note "Ops will confirm your shifts" | Save availability | Regenerate |
| C20 | Upload document | Type (Identity document); Choose a file or Take a photo; selected file with Remove; line "Only the verification team can open this" | Submit for review | Small fix (privacy line, camera) |

## 4. States every screen must have
Loading; error with "Try again" (text typed by the user is kept); offline banner "No internet. Your changes will not be saved"; and, where it applies, empty (Today with no visit, Upcoming with none), and denied ("You cannot open this visit"). Pickup code screen also needs wrong-code, locked and expired. Document upload needs uploading, failed, too large.

## 5. Image prompts: 5 boards, 4 screens each (regenerate the full set so it matches)

Shared style (already inside each prompt): phone screens 360x780, teal #00666B, navy #10243A, white cards 16 px corners, amber only for attention, status with a word, friendly sans-serif, 56 px buttons, flat illustrated avatars (no photos, no uniforms, no shirts with logos), 8-step thin progress bar on trip screens, back arrow plus title headers.

```text
BOARD A  (C1, C2, C3, C4)
Create ONE presentation board, 16:9 landscape, soft off-white background (#F7FBFA), FOUR smartphone screens side by side (360x780 each, thin neutral device frame), caption under each 'ID - Name'. Style: AnugaCare companion app, calm, trustworthy, easy for everyone. Teal #00666B, navy #10243A, white cards with 16px rounded corners and soft shadows, amber #F2A33A only for attention, green for success, status chips always with a word. Friendly rounded sans-serif (Inter / Noto Sans), body 16-18px, buttons 56px tall. Flat illustrated Indian avatars, no photos, no logos on clothing, no medical uniforms or crosses. Headers: back arrow plus screen title. Sample data only. Crisp, correctly spelled text. No watermark.
1. C1 - Become a companion. Neutral illustrated avatar of a middle-aged man. Chip 'Invitation accepted'. Fields: Full name (Suresh Kumar), Mobile (98765 43210, locked, grey, small lock icon), Neighbourhood (Kukatpally dropdown), Language chips (English, Telugu, Hindi), Vehicle chips (None, Bike, Auto). Checkbox 'I agree to the companion terms and the privacy notice'. Small line 'You are an independent companion.' Button 'Continue'.
2. C2 - Your verification. Two rows: ID document (green chip 'Received', date), Training (amber chip 'Pending'). Info box 'You can receive visits after verification.' Button 'Back to Today'.
3. C3 - Today. Header 'Companion' with logo and bell (no count). Card 'Good morning, Suresh - Thursday, 12 November'. Section Today: card '7:00 am - Ravi', Pickup Kukatpally, Drop City Dialysis Centre, button 'Open visit'. Section Upcoming with two small rows 'Fri 13 Nov - Drop 7:00 am - Meena' and 'Fri 13 Nov - Return 11:45 am - Meena'. Bottom nav: Today (active), Visits, Me.
4. C4 - Upcoming visits. Grouped by date: 'Fri, 13 Nov' with cards 'Drop 7:00 am - Ravi - City Dialysis Centre - Scheduled' and 'Return 11:45 am - Ravi - City Dialysis Centre - Scheduled'; 'Mon, 16 Nov' with the same two. Bottom nav: Visits (active).

BOARD B  (C5, C6, C7, C8)
[same style paragraph as Board A, with: trip screens show a thin 8-step progress bar and the text 'Step n of 8']
1. C5 - Trip essentials. Card with a round initials avatar 'R', 'Ravi - 7:00 am', 'Thursday, 12 November'. Route card: 'Pickup from home - 12 Lake View Road, Kukatpally' to 'City Dialysis Centre - Kukatpally (sample address)'. Row 'Mobility support - Uses a walking stick'. Row 'Family contact - Anita'. Buttons: 'Navigate' (secondary, with a maps-pin icon), 'Call AnugaCare support' (secondary), 'Start journey' (primary).
2. C6 - On the way to Ravi. Progress bar 'Step 2 of 8'. Chip 'On the way'. 'Scheduled pickup 7:00 am'. Address card, mobility note, family contact 'Anita'. Buttons: 'Navigate', 'Confirm pickup' (primary), 'Report an issue'.
3. C7 - Confirm pickup. Bar 'Step 2 of 8'. 'Ask Ravi or the family for the pickup code.' SIX EMPTY code boxes, first box active, and a large numeric keypad. Button 'Verify and confirm pickup'. Text link 'Patient not available'. Show a small red helper under the boxes in a second faded state 'That code is not right. 3 tries left.'
4. C8 - At the centre. Bar 'Step 4 of 8'. 'You have reached the centre with Ravi.' Cards: patient Ravi, 'City Dialysis Centre', timeline 'Picked up 7:10 am', 'At the centre 7:25 am'. 'Next: hand over to centre staff.' Buttons: 'Continue to handover' (primary), 'Navigate', 'Report an issue'.

BOARD C  (C9, C10, C11, C12)
[same style paragraph, with 8-step bar]
1. C9 - Confirm handover. Bar 'Step 4 of 8'. Patient 'Ravi', centre 'City Dialysis Centre'. Checklist: 'Patient received by centre staff', 'Belongings handed over' (unchecked). Optional 'Handover note'. Button 'Confirm handover' (disabled until staff box ticked).
2. C10 - Session in progress. Bar 'Step 5 of 8'. 'Handover complete 7:35 am'. Info text 'Sessions usually take 4 to 5 hours. You can wait nearby or take a break.' Card 'Return pickup expected 11:45 am'. Note 'Wait for the centre to say the session is finished.' Buttons: 'Confirm session finished' (primary), 'Call AnugaCare support', 'Report an issue'.
3. C11 - Returning home. Bar 'Step 7 of 8'. 'Ravi is with you.' Destination card '12 Lake View Road, Kukatpally'. Buttons: 'Navigate', 'Confirm home arrival' (primary), 'Report an issue'. NO Records tab; bottom nav Today (active), Visits, Me.
4. C12 - Home arrival. Bar 'Step 8 of 8'. 'Ravi is home. Dropped home 12:30 pm.' Radio 'Handed to: Family member / Patient at the door'. Text 'The visit is complete once you submit your note.' Button 'Add visit note'.

BOARD D  (C13, C14, C15, C16)
[same style paragraph]
1. C13 - Add visit note. Round initials avatar 'R'. 'Ravi - Home arrival 12:30 pm'. EMPTY text box with hint 'For example: Ravi was comfortable. Small delay at the centre.' Quick tags 'On time', 'Delay at centre'. Info 'Record visit details only. No medical notes.' Button 'Submit and complete visit'.
2. C14 - Visit completed. ONE title only. Green card 'Visit completed - Thank you, Suresh'. Mini timeline 'Picked up 7:10 am, At the centre 7:25 am, Handed over 7:35 am, Home 12:30 pm'. 'Next visit: Fri 13 Nov, 7:00 am - Meena' if any. Button 'Back to Today'. No grey avatar.
3. C15 - Report an issue (bottom sheet over the C6 screen with Ravi, 12 Lake View Road, Kukatpally and no phone numbers). Chips: 'Patient not ready', 'Patient unwell', 'Cannot find family', 'Centre not ready', 'Other'. Text box. Red line 'In an emergency call 112 or 108.' Buttons 'Send report' and 'Cancel'.
4. C16 - Patient not available (bottom sheet over the C7 screen). Icon of a person with a slash. 'Confirm only if you could not pick up the patient. Please wait 15 minutes first.' Buttons 'Keep visit' (primary) and 'Confirm patient not available' (red outline).

BOARD E  (C17, C18, C19, C20)
[same style paragraph]
1. C17 - Help and emergency. Card 'Medical emergency? Call 112 or 108. AnugaCare does not send emergency help.' with two call buttons. Button 'Call AnugaCare support'. Button 'Report an issue'. Accordion guides 'Patient feels unwell', 'I cannot find the family', 'The centre is not ready'. Reminder 'You are a companion, not a medical professional. Do not give medicine.'
2. C18 - Me. Illustrated avatar, 'Suresh Kumar - Companion'. Rows: 'Verification - ID received, training pending', 'Availability', 'Documents', 'Language', 'Help and emergency'. Button 'Sign out'. Bottom nav Today, Visits, Me (active).
3. C19 - Availability. Grid with days Mon-Sun as rows and Morning and Midday as columns with toggles (Mon, Wed, Fri on for Morning). Evening row greyed 'Not offered yet'. Note 'Ops will confirm your shifts.' Button 'Save availability'.
4. C20 - Upload document. 'Upload only the requested document.' Document type dropdown 'Identity document'. Buttons 'Choose a file' and 'Take a photo'. Selected file 'identity-document.pdf' with 'Remove'. Line 'Only the verification team can open this.' Button 'Submit for review'.
```

## 6. Open items outside the images
- ADR for "I have arrived" and masked calling (later).
- ADR for availability storage; verification fields; companion terms wording (lawyer).
- Native Telugu and Hindi copy; dark mode and 200% text checks on the final set.
- Check the state machine allows the companion to mark "Session done"; check what companion name fields `companion_my_trips()` returns.
