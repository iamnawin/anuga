# AnugaCare: image prompts for the 48 remaining screens (12 boards, 4 screens each)

Date: 2026-11-12. Paste one board prompt into your image tool at a time. Each is self-contained and repeats the shared style so the boards match.

**Update 2026-11-13:** the family prompts in boards 1 to 7 are replaced by section 6 of `screen_mockups/Family_Screens_FINAL_Spec_v1.md` (boards FAM-1 to FAM-9). Use those instead.

**Direction only, not specification.** Where a mockup shows a map, avatar or companion detail, the real app follows `docs/design/tokens.md`: no live map, ETA, countdown, notification count or verification badge, and no avatar photos until the design contract is changed. The map in F2 (home location) and the map preview in F15 are ideas to decide on. F37 (Medicines) is on hold: it is clinical, so ask before building. A2 (Sign in) is already built in PR #32 and is not in these boards.

Tips: if the tool garbles small text, generate each board twice and pick the cleaner one, or ask for 'two screens per image' and combine. Prices are test values from one dialysis scenario.


---

## Board 1: Family setup and plan (1)

Screens: F1, F2, F3, F4

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA) with a faint teal gradient, showing FOUR smartphone app screens side by side. Each screen is a 360x780 mobile UI in a thin neutral device frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare app: calm, trustworthy, easy for elderly users and families. Primary teal #00666B, ink navy #10243A, white cards with 16px rounded corners and soft shadows, amber #F2A33A only for attention, green for success, red for errors; every status colour is paired with a word and an icon. Friendly rounded sans-serif (Inter / Noto Sans), body text 16-18px, primary buttons 56px tall, tap targets 48px, generous spacing, high contrast. People appear as warm, flat, illustrated Indian avatars of mixed ages (no stock-photo faces). Simple line icons. Bottom navigation (Home, Visits, Records, Bills, More) on main-app screens; top app bar with back arrow and title; linear flows show a thin top progress bar with 'Step n of 5'. Companions are shown only as 'companion', never as nurse or doctor: no medical uniforms, stethoscopes or crosses. All names, prices and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four screens and their captions. Keep the same style on every board.

SCREENS (left to right):

1. F1 - Patient details. Top progress bar 'Step 1 of 5'. Title 'Who are we caring for?'. Illustrated avatar of an elderly Indian woman. Fields: First name (Lakshmi), Age band chips (Under 60 / 60-69 / 70-79 / 80+, '70-79' selected), Relationship to you chips (Mother selected / Father / Spouse / Other), Language chips (English / తెలుగు / हिन्दी), Mobility chips (Walks alone / Needs an arm / Walker / Wheelchair). Helper line 'We only ask what the companion needs.' Big teal 'Continue' button.

2. F2 - Visit pattern and place. Top progress bar 'Step 2 of 5'. Title 'Where and when?'. A clean stylised map card with a home pin and a dialysis-centre pin (sample, no real brand names). Address field, centre dropdown 'City Kidney Care (sample)'. Day chips Mon Tue Wed Thu Fri Sat Sun with Mon, Wed, Fri selected. Shift chips: Morning (selected), Midday, and a greyed 'Evening - not available yet'. Emergency contact name and phone fields. 'Continue' button.

3. F3 - Choose a plan. Top progress bar 'Step 3 of 5'. Title 'Choose a plan'. Three stacked cards: 'Trial - 6 trips - Rs 5,499'; 'Care Plan - 12 trips every 4 weeks - Rs 10,999' selected with teal border and a 'Most families' chip; 'Safe Return - 12 returns - Rs 7,799'. Small note 'Fares are extra and paid in advance.' Small grey tag 'Sample prices'. 'Continue' button.

4. F4 - Review and pay. Top progress bar 'Step 4 of 5'. Title 'Review and pay'. Summary card with patient avatar and name 'Lakshmi', plan row 'Care Plan - 12 trips'. Price lines: Plan Rs 10,999; Deposit credit minus Rs 500; GST 'to be confirmed'; Total in bold. Collapsible 'Refund terms' row. Checkbox 'I agree to the plan terms'. Primary button 'Continue to pay'. Small pill 'Test mode'.

```


---

## Board 2: Payment (2)

Screens: F5, F6, F7, F8

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA) with a faint teal gradient, showing FOUR smartphone app screens side by side. Each screen is a 360x780 mobile UI in a thin neutral device frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare app: calm, trustworthy, easy for elderly users and families. Primary teal #00666B, ink navy #10243A, white cards with 16px rounded corners and soft shadows, amber #F2A33A only for attention, green for success, red for errors; every status colour is paired with a word and an icon. Friendly rounded sans-serif (Inter / Noto Sans), body text 16-18px, primary buttons 56px tall, tap targets 48px, generous spacing, high contrast. People appear as warm, flat, illustrated Indian avatars of mixed ages (no stock-photo faces). Simple line icons. Bottom navigation (Home, Visits, Records, Bills, More) on main-app screens; top app bar with back arrow and title; linear flows show a thin top progress bar with 'Step n of 5'. Companions are shown only as 'companion', never as nurse or doctor: no medical uniforms, stethoscopes or crosses. All names, prices and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four screens and their captions. Keep the same style on every board.

SCREENS (left to right):

1. F5 - Choose how to pay. Title 'How would you like to pay?'. Sticky amount bar 'Rs 10,999'. Options as cards: UPI apps (three generic round app icons labelled 'UPI app 1/2/3'), 'Enter UPI ID' field, 'Show QR code', 'Card'. Reassurance line 'Payments are secure'. Pill 'Test mode - no real money'. No real company logos.

2. F6 - Waiting for payment. Calm centred screen. Soft illustration of an hourglass or clock (no countdown numbers). Title 'Waiting for your payment'. Body 'Approve the request in your UPI app. We will update this screen when it arrives.' Amber chip with the word 'Pending'. Buttons: 'Check again' (primary), 'Pay another way' (secondary), text link 'Need help?'.

3. F7 - Payment successful. Green circle with a check mark, title 'Payment received'. Receipt card: Receipt no. AC-0001 (sample), plan 'Care Plan', amount Rs 10,999, date. 'What happens next' list of 3 numbered steps: Confirm first visit; Meet your companion; Plan starts. Buttons 'See my plan' (primary) and 'Download receipt' (secondary).

4. F8 - Payment failed or pending. Calm, non-alarming screen. Soft amber illustration, title 'The payment did not go through'. Body 'If money left your account, we will help you check.' Buttons: 'Try again' (primary), 'Pay another way' (secondary), 'Talk to us' (text button). Small status chip with the word 'Failed'.

```


---

## Board 3: Setup finish and family main (3)

Screens: F9, F12, F14, F15

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA) with a faint teal gradient, showing FOUR smartphone app screens side by side. Each screen is a 360x780 mobile UI in a thin neutral device frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare app: calm, trustworthy, easy for elderly users and families. Primary teal #00666B, ink navy #10243A, white cards with 16px rounded corners and soft shadows, amber #F2A33A only for attention, green for success, red for errors; every status colour is paired with a word and an icon. Friendly rounded sans-serif (Inter / Noto Sans), body text 16-18px, primary buttons 56px tall, tap targets 48px, generous spacing, high contrast. People appear as warm, flat, illustrated Indian avatars of mixed ages (no stock-photo faces). Simple line icons. Bottom navigation (Home, Visits, Records, Bills, More) on main-app screens; top app bar with back arrow and title; linear flows show a thin top progress bar with 'Step n of 5'. Companions are shown only as 'companion', never as nurse or doctor: no medical uniforms, stethoscopes or crosses. All names, prices and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four screens and their captions. Keep the same style on every board.

SCREENS (left to right):

1. F9 - All set. Top progress bar 'Step 5 of 5' full. Celebration illustration (soft, calm). Title 'You are all set'. First-visit card: 'First visit - Mon 16 Nov, morning' with pickup window text '7:00 to 7:30 am (sample)'. 'What happens next' list of 3 steps. Primary button 'Go to Home'.

2. F12 - Home. Main app, bottom nav with Home active. Top bar: greeting 'Namaste, Ramesh' and a patient chip 'Lakshmi' with a down arrow. Next-visit card with a 9-step horizontal progress bar (step 2 highlighted, text 'Companion on the way'), status chip with a word. A pickup-code card showing '482 915' with caption 'Share only with the companion at the door'. Plan card 'Care Plan - 9 trips left - valid till 12 Dec'. Quick-action row: Visits, Records, Bills, Help. No live ETA numbers.

3. F14 - Visits list. Bottom nav with Visits active. Title 'Visits'. Tabs 'Upcoming | Past' with Upcoming selected. Visit cards: date, centre name (sample), small illustrated companion avatar with 'Suresh - companion', status chips with words: Scheduled, On the way, Completed, Cancelled, Issue reported (show a mix). A floating 'Request a change' button.

4. F15 - Visit detail. Top bar with back arrow 'Visit - Mon 16 Nov'. 9-step progress bar (steps: Scheduled, On the way, Picked up, At centre, Handed over, Session done, Returning, Home, Completed) with step 3 'Picked up' highlighted. Pickup-code card '482 915'. Companion card with avatar, 'Suresh - companion', button 'Call AnugaCare support'. Vertical timeline of events with sample times. A small stylised map card with the label 'Map preview (future idea)'. Visit-note card 'Note from companion'. No ETA numbers.

```


---

## Board 4: Family records, bills, privacy (4)

Screens: F19, F22, F24, F28

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA) with a faint teal gradient, showing FOUR smartphone app screens side by side. Each screen is a 360x780 mobile UI in a thin neutral device frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare app: calm, trustworthy, easy for elderly users and families. Primary teal #00666B, ink navy #10243A, white cards with 16px rounded corners and soft shadows, amber #F2A33A only for attention, green for success, red for errors; every status colour is paired with a word and an icon. Friendly rounded sans-serif (Inter / Noto Sans), body text 16-18px, primary buttons 56px tall, tap targets 48px, generous spacing, high contrast. People appear as warm, flat, illustrated Indian avatars of mixed ages (no stock-photo faces). Simple line icons. Bottom navigation (Home, Visits, Records, Bills, More) on main-app screens; top app bar with back arrow and title; linear flows show a thin top progress bar with 'Step n of 5'. Companions are shown only as 'companion', never as nurse or doctor: no medical uniforms, stethoscopes or crosses. All names, prices and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four screens and their captions. Keep the same style on every board.

SCREENS (left to right):

1. F19 - Records list. Bottom nav with Records active. Privacy banner 'Only you and people you allow can see these.' Filter chips: All, Reports, Prescriptions, Bills, Other. List of record rows with document icons, title, date, and a small lock icon. Floating button 'Add photo'.

2. F22 - Bills list. Bottom nav with Bills active. Segmented control 'Bills | Plan and receipts' with Bills selected. Summary card 'Due Rs 3,200' with button 'Pay now'. Invoice rows with month, amount and status chips with words: Due, Paid, Overdue.

3. F24 - Plan and receipts. Bottom nav with Bills active, segmented control with 'Plan and receipts' selected. Plan hero card 'Care Plan' with a horizontal progress bar '9 of 12 trips left' and 'Valid till 12 Dec'. Fare balance card 'Fare balance Rs 1,200'. Button 'Renew plan'. Receipts list with dates, numbers, amounts and a download icon.

4. F28 - Privacy choices. Top bar 'Privacy choices'. Toggles with one-line plain-language explanations: 'Trip details', 'Records vault', and under the vault a nested switch 'Let AnugaCare support view my records when I ask'. A language row. At the bottom a red-outlined text button 'Withdraw consent and delete data'.

```


---

## Board 5: Account status, delete data, companion session and help (5)

Screens: A5, F29, C10, C17

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA) with a faint teal gradient, showing FOUR smartphone app screens side by side. Each screen is a 360x780 mobile UI in a thin neutral device frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare app: calm, trustworthy, easy for elderly users and families. Primary teal #00666B, ink navy #10243A, white cards with 16px rounded corners and soft shadows, amber #F2A33A only for attention, green for success, red for errors; every status colour is paired with a word and an icon. Friendly rounded sans-serif (Inter / Noto Sans), body text 16-18px, primary buttons 56px tall, tap targets 48px, generous spacing, high contrast. People appear as warm, flat, illustrated Indian avatars of mixed ages (no stock-photo faces). Simple line icons. Bottom navigation (Home, Visits, Records, Bills, More) on main-app screens; top app bar with back arrow and title; linear flows show a thin top progress bar with 'Step n of 5'. Companions are shown only as 'companion', never as nurse or doctor: no medical uniforms, stethoscopes or crosses. All names, prices and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four screens and their captions. Keep the same style on every board.

SCREENS (left to right):

1. A5 - Account status (companion). Companion app. Title 'Your application'. Vertical step list in plain text with icons: Applied (done), ID check (in progress), Training (not started), Ready to take visits (waiting). Amber chip with the word 'Waiting'. Message 'We will message you when the next step opens.' Button 'Talk to support'. No badges.

2. F29 - Withdraw consent and delete data. Top bar 'Delete my data'. Soft amber warning panel. Two lists: 'What will be deleted' (records, photos, notes) and 'What we may have to keep' (billing records, wording 'to be confirmed'). A checkbox 'I understand'. Buttons: 'Keep my account' (primary teal) and 'Request deletion' (red outline). Line 'We will tell you when it is done.'

3. C10 - Session in progress (companion). Companion app, bottom nav (Today, Upcoming, Help, Me) with Today active. Title 'Visit with Lakshmi'. Chip 'Session in progress'. 8-step progress bar with step 5 highlighted. Card 'Handed over to centre staff at 7:20 am'. Guidance card: 'Sessions usually take 4 to 5 hours. You can wait nearby or take a break.' Buttons: 'Session finished - start return' (primary) and 'Report an issue' (secondary).

4. C17 - Help and emergency (companion). Companion app, Help tab active. Red-tinted card 'In an emergency, call 112' with a big call button. Button 'Call AnugaCare support'. Accordion list: 'Patient feels unwell', 'I cannot find the family', 'The centre is not ready'. A calm reminder card 'You are a companion, not a medical professional. Do not give medicine or treatment.'

```


---

## Board 6: Pay-by-others, receipt, refund (6)

Screens: F10, F11, F25, F26

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA) with a faint teal gradient, showing FOUR smartphone app screens side by side. Each screen is a 360x780 mobile UI in a thin neutral device frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare app: calm, trustworthy, easy for elderly users and families. Primary teal #00666B, ink navy #10243A, white cards with 16px rounded corners and soft shadows, amber #F2A33A only for attention, green for success, red for errors; every status colour is paired with a word and an icon. Friendly rounded sans-serif (Inter / Noto Sans), body text 16-18px, primary buttons 56px tall, tap targets 48px, generous spacing, high contrast. People appear as warm, flat, illustrated Indian avatars of mixed ages (no stock-photo faces). Simple line icons. Bottom navigation (Home, Visits, Records, Bills, More) on main-app screens; top app bar with back arrow and title; linear flows show a thin top progress bar with 'Step n of 5'. Companions are shown only as 'companion', never as nurse or doctor: no medical uniforms, stethoscopes or crosses. All names, prices and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four screens and their captions. Keep the same style on every board.

SCREENS (left to right):

1. F10 - Send payment link. Top bar 'Ask someone else to pay'. Plan summary card (Care Plan, Rs 10,999). Payer name and phone fields. Share buttons with generic icons: 'WhatsApp', 'SMS', 'Copy link'. Note 'They only see the plan and amount, never health details.' Primary button 'Send link'.

2. F11 - Payment link page (payer). A phone showing a mobile WEB page inside a browser frame with a simple address bar (sample domain). AnugaCare logo wordmark, title 'Lakshmi's Care Plan', 'Requested by Ramesh', amount Rs 10,999, three generic UPI buttons, 'Pay with card', line 'Secure payment - test mode'. No login required.

3. F25 - Receipt detail. Top bar 'Receipt'. Receipt card with number AC-0001 (sample), date, line items, payment method 'UPI', total. A 'Paid' chip. Buttons 'Download PDF' and 'Share'.

4. F26 - Refund request and status. Top bar 'Request a refund'. Card: 'Trial - 4 of 6 trips unused'. 'Refund estimate - to be confirmed'. Reason chips. Status timeline: Requested, Reviewed, Refunded (first step done, second in progress). Button 'Submit request'.

```


---

## Board 7: Change visits, More, Help, Privacy notice (7)

Screens: F17, F27, F31, F32

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA) with a faint teal gradient, showing FOUR smartphone app screens side by side. Each screen is a 360x780 mobile UI in a thin neutral device frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare app: calm, trustworthy, easy for elderly users and families. Primary teal #00666B, ink navy #10243A, white cards with 16px rounded corners and soft shadows, amber #F2A33A only for attention, green for success, red for errors; every status colour is paired with a word and an icon. Friendly rounded sans-serif (Inter / Noto Sans), body text 16-18px, primary buttons 56px tall, tap targets 48px, generous spacing, high contrast. People appear as warm, flat, illustrated Indian avatars of mixed ages (no stock-photo faces). Simple line icons. Bottom navigation (Home, Visits, Records, Bills, More) on main-app screens; top app bar with back arrow and title; linear flows show a thin top progress bar with 'Step n of 5'. Companions are shown only as 'companion', never as nurse or doctor: no medical uniforms, stethoscopes or crosses. All names, prices and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four screens and their captions. Keep the same style on every board.

SCREENS (left to right):

1. F17 - Reschedule or edit pattern. Top bar 'Change my visits'. Current pattern card 'Mon, Wed, Fri - Morning'. Day chips and shift chips to edit. Info line 'Changes apply from next week.' Buttons 'Save change' and text 'Ask us instead'.

2. F27 - More menu. Bottom nav with More active. Header with illustrated avatar and name 'Ramesh - Owner'. List rows with icons: Patients and access, Family members, Privacy choices, Language, Preferences, Help and support, Privacy notice, About, Sign out.

3. F31 - Help and support. Top bar 'Help'. Big button 'Call AnugaCare support'. 'Report a problem' with category chips (Visit, Payment, Records, Other) and a text box. FAQ accordion with 4 questions.

4. F32 - Privacy notice and About. Top bar 'Privacy notice'. Language switcher chips. Readable long-form page with clear headings and short paragraphs (placeholder text, last updated sample date). Footer rows: 'About AnugaCare', 'App version 0.1 (sample)'.

```


---

## Board 8: Access roles and companion profile (8)

Screens: F33, F34, F35, C18

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA) with a faint teal gradient, showing FOUR smartphone app screens side by side. Each screen is a 360x780 mobile UI in a thin neutral device frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare app: calm, trustworthy, easy for elderly users and families. Primary teal #00666B, ink navy #10243A, white cards with 16px rounded corners and soft shadows, amber #F2A33A only for attention, green for success, red for errors; every status colour is paired with a word and an icon. Friendly rounded sans-serif (Inter / Noto Sans), body text 16-18px, primary buttons 56px tall, tap targets 48px, generous spacing, high contrast. People appear as warm, flat, illustrated Indian avatars of mixed ages (no stock-photo faces). Simple line icons. Bottom navigation (Home, Visits, Records, Bills, More) on main-app screens; top app bar with back arrow and title; linear flows show a thin top progress bar with 'Step n of 5'. Companions are shown only as 'companion', never as nurse or doctor: no medical uniforms, stethoscopes or crosses. All names, prices and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four screens and their captions. Keep the same style on every board.

SCREENS (left to right):

1. F33 - Family members and access. Top bar 'Family and access'. List of members with illustrated avatars and role chips with words: Owner, Editor, Viewer, Patient. Button 'Invite someone' opening a bottom sheet with phone field and role radio options, each with a one-line explanation.

2. F34 - Viewer variant of Home. Same layout as Home but a banner 'You can view this, not change it.' No cancel button, bottom nav shows Home, Visits, Records, More (no Bills). Next-visit card with 9-step bar and status chip with a word.

3. F35 - Patient-access variant of Home. Simplified, extra-large text version of Home for the patient. Title 'Your next visit'. Very large pickup code '482 915'. Large status text 'Companion on the way'. Large 'Updates' list. Plenty of white space, 18-20px text.

4. C18 - Me (companion). Companion app, Me tab active. Illustrated avatar, first name 'Suresh'. Rows: 'Verification - complete (checked 3 Nov)', 'Training - complete', Language, 'Availability'. Button 'Sign out'. No badges or stars.

```


---

## Board 9: Companion availability, documents, preferences, requests (9)

Screens: C19, C20, F30, F36

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA) with a faint teal gradient, showing FOUR smartphone app screens side by side. Each screen is a 360x780 mobile UI in a thin neutral device frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare app: calm, trustworthy, easy for elderly users and families. Primary teal #00666B, ink navy #10243A, white cards with 16px rounded corners and soft shadows, amber #F2A33A only for attention, green for success, red for errors; every status colour is paired with a word and an icon. Friendly rounded sans-serif (Inter / Noto Sans), body text 16-18px, primary buttons 56px tall, tap targets 48px, generous spacing, high contrast. People appear as warm, flat, illustrated Indian avatars of mixed ages (no stock-photo faces). Simple line icons. Bottom navigation (Home, Visits, Records, Bills, More) on main-app screens; top app bar with back arrow and title; linear flows show a thin top progress bar with 'Step n of 5'. Companions are shown only as 'companion', never as nurse or doctor: no medical uniforms, stethoscopes or crosses. All names, prices and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four screens and their captions. Keep the same style on every board.

SCREENS (left to right):

1. C19 - Availability (companion). Companion app. Title 'When can you work?'. Week grid Mon-Sun by Morning and Midday with toggles (some on). Greyed row 'Evening - not offered yet'. Note 'Choose only what you can keep.' Button 'Save'.

2. C20 - Document upload (companion). Companion app. Title 'Verify your ID'. Steps 'ID proof' and 'Photo'. A camera-capture frame with corner guides. Tick states. Line 'Only the verification team can open this.' Button 'Take photo'.

3. F30 - Preferences. Top bar 'Preferences'. Language radio list (English, తెలుగు, हिन्दी). Notification toggles: Visit updates, Reminders. A section 'Care preferences (to confirm)' with chips like 'Telugu-speaking companion', 'Female companion', 'Quiet ride'.

4. F36 - Requests. Top bar 'I need...'. Request cards: Reschedule, Extra trip, Change address, Something else, plus a text box. Below, 'Your requests' history with status chips with words: Open, Done.

```


---

## Board 10: Ops console (10)

Screens: O6, O7, O8, O9

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA), showing FOUR desktop browser windows in a 2x2 grid. Each window is a 1440x900 web console in a clean browser frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare ops and manager console: calm, clear, data-dense but airy. Primary teal #00666B, ink navy #10243A, white cards with 12px rounded corners, thin borders, soft shadows; amber #F2A33A for attention, green for success, red for errors; every status colour is paired with a word. Inter / Noto Sans, readable 14-16px table text, left sidebar navigation, top bar with search and a small avatar, filter chips, tables with status chips, KPI tiles, simple clean charts. All people, names, centres and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four windows and their captions. Keep the same style on every board.

SCREENS (top-left, top-right, bottom-left, bottom-right):

1. O6 - Plan sales and refunds. Ops console. Sidebar highlighting 'Plans'. KPI strip (Plans sold, Active, Refunds open). Table of purchases with plan, family, amount, status chips (Paid, Pending, Refunded). Tab 'Refund queue'.

2. O7 - Companion onboarding queue. Ops console. Board with columns Applied, ID check, Training, Shadow run, Ready. Candidate cards with illustrated avatars and chips. Right-side drawer with an ID-check checklist.

3. O8 - Centre permission map. Ops console. Table of centres with permission level chips S0 to S5, last contact date, protocol checklist ticks (heads-up on discharge, handover sign-off). Filter chips.

4. O9 - Reliability report. Ops console. KPI tiles: On-time drop %, Avg pickup wait, Incidents, Failed visits. A clean line chart over weeks. Per-centre table. Caption 'Sample data'.

```


---

## Board 11: Ops and Manager console (11)

Screens: O10, M1, M2, M3

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA), showing FOUR desktop browser windows in a 2x2 grid. Each window is a 1440x900 web console in a clean browser frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare ops and manager console: calm, clear, data-dense but airy. Primary teal #00666B, ink navy #10243A, white cards with 12px rounded corners, thin borders, soft shadows; amber #F2A33A for attention, green for success, red for errors; every status colour is paired with a word. Inter / Noto Sans, readable 14-16px table text, left sidebar navigation, top bar with search and a small avatar, filter chips, tables with status chips, KPI tiles, simple clean charts. All people, names, centres and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four windows and their captions. Keep the same style on every board.

SCREENS (top-left, top-right, bottom-left, bottom-right):

1. O10 - Leg-level assignment. Ops console. Horizontal day timeline (6:00 to 22:00) with one lane per companion, coloured blocks labelled Drop, Pickup, Swap, a conflict marker in amber, unassigned legs panel on the right.

2. M1 - Manager dashboard. Manager console. Sidebar. KPI tiles (Families, Visits this week, On-time %, Refunds). Gates panel: 'Pilot gate' with checklist and progress bar. Line chart.

3. M2 - Approvals. Manager console. Tabs 'Refunds | Companion verification'. Queue table with requester, amount or candidate, age, and Approve / Decline buttons. Detail drawer.

4. M3 - Incident review. Manager console. List of incidents with severity chips (with words), visit ID, date, status. Detail pane with timeline and notes, 'Close incident' button.

```


---

## Board 12: Manager console and one held screen (12)

Screens: M4, M5, M6, F37

```text
Create ONE presentation board image, 16:9 landscape, soft off-white background (#F7FBFA), showing FOUR desktop browser windows in a 2x2 grid. Each window is a 1440x900 web console in a clean browser frame, with a small caption under it in the form 'ID - Name'. Design language for the AnugaCare ops and manager console: calm, clear, data-dense but airy. Primary teal #00666B, ink navy #10243A, white cards with 12px rounded corners, thin borders, soft shadows; amber #F2A33A for attention, green for success, red for errors; every status colour is paired with a word. Inter / Noto Sans, readable 14-16px table text, left sidebar navigation, top bar with search and a small avatar, filter chips, tables with status chips, KPI tiles, simple clean charts. All people, names, centres and numbers are sample values. All text must be crisp, spelled correctly and legible. No watermark, no extra text outside the four windows and their captions. Keep the same style on every board.

SCREENS (top-left, top-right, bottom-left, bottom-right):

1. M4 - Business settings. Manager console. Settings form: plan prices, pickup windows, distance limit as editable fields with units, version history side panel with 'Changed by' and date, 'Save as new version' button. Tag 'Sample values'.

2. M5 - Centres and partnerships. Manager console. Pipeline board: Not contacted, In talks, Protocol agreed, Active. Centre cards with notes and last contact. No logos.

3. M6 - Users and roles. Manager console. Table of users with role chips (Family, Companion, Ops, Manager), status, last active. Right drawer with a role permission matrix and 'Change role' button.

4. F37 - Medicines (HOLD - clinical). HOLD: show a placeholder screen only. Top bar 'Medicines'. A soft banner 'Not available yet' and a simple illustration. No dosage, no advice.

```
