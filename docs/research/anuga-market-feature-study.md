# Market feature study: hospital-visit companions, patient transport and dialysis apps

Research date: **2026-10-12**. Researcher: Claude Code (REA 6.4.0 + public web).
Companion documents: [`anuga-feature-gap-matrix.md`](anuga-feature-gap-matrix.md) (what Anuga has today
versus these products) and [`anuga-next-release-proposal.md`](anuga-next-release-proposal.md) (what to build next).

> Naming: the user calls the product **Anuga**. `docs/PRODUCT_SPEC.md` says the brand is not final and
> the codename in code is `companion`. This study uses "Anuga" for the service.

## 1. Scope and method

Goal: learn workflow patterns from six products and turn them into original specifications for Anuga's
three roles (Family/Patient, Companion, Ops). No proprietary code, branding or assets are reused.
Screenshots in `screenshots/` are internal research references only; do not ship them.

### 1.1 Evidence labels used in every document

| Label | Meaning |
| --- | --- |
| **[Observed]** | Seen directly by this research: REA browser observation, page DOM/accessibility tree, or public JS bundle text served to every visitor |
| **[Vendor]** | Stated by the vendor on its own website, store listing or FAQ, not verified in a working product |
| **[Third-party]** | Reported by press or another organisation |
| **[Inferred]** | Our reading of how the product probably works; not confirmed |
| **[Proposal]** | Our recommendation for Anuga |

A marketing page is never treated as proof of how a private application works. Where only marketing
text exists, the finding is labelled [Vendor].

Cleanup review (2026-10-12): [Observed] establishes that a form or public statement
was visible, not that the advertised service works. FAQ/service/pricing statements
below are vendor claims even where their text was observed in a public bundle.
Absence means not found in the inspected public material, never proof of absence
from a competitor's service or private app. This review did not repeat browser/APK research.

### 1.2 Tooling log (REA)

| Step | Result |
| --- | --- |
| `binary_session` | REA server `rea-agents` **6.4.0**, MCP protocol 2025-11-25, client claude-code 2.1.296; no target open. Relevant capabilities **available**: `capture_browser_scenario`, `list_browser_targets`, `inspect_web_page`, `capture_web_screenshot`, `open_binary`. **Unavailable**: `inspect_android_package` (`provider_missing`: needs a caller-supplied jadx-headless-mcp JAR via `REA_JADX_MCP_JAR`). |
| `capture_browser_scenario` (launch mode, system Chrome 154) | **Failed twice** on this Windows host: `cleanup_incomplete` / `unreadable_output`. Not retried further. |
| Workaround | Started headless Chrome myself with a throwaway profile in the session scratchpad and `--remote-debugging-port=9333`, then used REA's passive tools over CDP. No clicks, no form input, no submissions. Browser closed after capture. |
| `inspect_web_page` (passive, accessibility text) | digniMuv booking `ev_4dbcca92cbdf…`, Hospy360 home `ev_7c5ccc202b46…`, HosFriend home `ev_965a94ff7969…`, NephroPlus app page `ev_5632e2a54e0b…`. DOM attribute values and scripts were policy-filtered by REA (expected). |
| `capture_web_screenshot` | digniMuv booking `ev_c5b7a9a6fcba…`, NephroPlus `ev_675ccd93adf3…`, HosFriend `ev_0373e18bd985…`, Ride Health `ev_c2de4e762baf…`, Hospy360 `ev_1f35147d2bc4…` (captured, but the image was returned inline only and was not saved to disk). |
| HosFriend FAQ answers | Collapsed accordions; answers read from the public Next.js chunk `/_next/static/chunks/16e326a35eb16b4a.js` that the site serves to every visitor (plain `curl`). Some bold spans inside answers were not recoverable and are marked "(value not captured)". |
| Android / NephroPlus APK | Not inspected. No authorised APK source was available without a device or Play account, and the REA Android provider is not installed. Not needed: the public store listings answered the questions that matter for Anuga. |

Screenshots saved (viewport only, 526 x 815, no personal data):
`screenshots/dignimuv-booking-form.png`, `screenshots/hosfriend-home.png`,
`screenshots/nephroplus-mobile-app-page.png`, `screenshots/ridehealth-platform.png`.

## 2. Product findings

### 2.1 HosFriend (Hyderabad): companion with or without transport
Sources: https://www.hosfriend.com/ , https://www.hosfriend.com/refund-and-cancellation-policy

- **Service tiers** [Vendor, observed page text]: Full Day (round-trip transport + companion who stays up to
  8 hours), Half Day (transport + companion up to 4 hours), Companion (Attendant) only, "Does not
  include transportation service". Not emergency, ambulance or homecare.
- **Pricing** [Vendor, observed public FAQ 19 in bundle]: transport "on an average ... Rs. 40/- per kilometer each
  way"; companionship "Rs. 1250/- for 4 hours and Rs. 2500/- for up to 8 hours", inclusive of 18% GST.
- **Overruns** [Vendor, observed public FAQ 30]: if a Half Day visit runs long, "Your Companion will continue to stay
  with you, with extra time billed accordingly."
- **Appointment cancelled by the hospital on arrival** [Vendor, observed public FAQ 31]: a charge applies
  (value not captured).
- **Cancellation** [Vendor, observed public FAQ 9 + policy page]: cancel or reschedule "at any time"; paid amounts are
  refunded (within 7 working days); asks families to avoid last-minute changes because "we do not make
  any back-up bookings", so a late cancel leaves a slot unused.
- **Family updates** [Vendor, observed public FAQ 15]: companion and a Relationship Manager at a "Command Centre"
  update the family "via phone calls and messages at regular intervals". Each visit has a primary and a
  secondary Relationship Manager.
- **Mobility** [Vendor, observed public FAQ 18]: cars (Maruti WagonR) carry a wheelchair, but "we can support only
  those patients who can make the trip ... in a sitting position".
- **Booking and payment** [Vendor, observed public FAQ 8, 11, 22]: phone/WhatsApp 9 AM to 9 PM; UPI only, never cash;
  pay in advance or after.
- **Hours** [Vendor, observed public FAQ 17]: daytime only.
- **Safety** [Vendor]: GPS, dash cams streaming to the command centre, cabin recording retained 7 days
  (FAQ 20; the page body says 30 days, so the vendor is inconsistent).
- No app link, recurring plan or dialysis-specific offer was found in the inspected HosFriend material; availability beyond those pages is unknown.

### 2.2 Hospy360 (Hyderabad, Warangal): companion plans, transport at actuals
Sources: https://www.hospy360.in/ , https://www.hospy360.in/terms-and-conditions

- **Services** [Vendor]: doorstep pickup, OPD registration, consultation support, diagnostics,
  pharmacy support, "Safe Return" home, elderly care.
- **Female companions** [Observed]: "Female Companions are available for women".
- **Pricing** [Vendor]: Complete Hospital Visit ₹1,299, Night Companion Visit ₹1,499 (₹100 off first
  visit); Monthly Care Packages at custom prices; "Patient transportation charged at actuals".
- **Monthly plans** [Vendor]: cover dialysis support, physiotherapy, chemotherapy and regular follow-ups,
  with "dedicated companion, priority scheduling, flexible monthly plans, and family updates after every visit".
- **Booking form** [Observed, accessibility tree]: Patient Name, Mobile Number, Purpose, Preferred Date,
  Preferred Time, plan, and a mandatory checkbox "I agree to the Terms & Conditions and understand that
  Hospy360 provides non-medical assistance services only." Confirmation promised in under 5 minutes [Vendor].
- **Waiting / extra time** [Vendor, T&C]: "Additional time, if required, will be chargeable" (no rate).
- **Cancellation** [Vendor, T&C]: cancel or reschedule before service start; no refund once service begins.
- **Scope** [Vendor, T&C]: "No medical diagnosis or clinical treatment is provided."

### 2.3 NephroPlus app (dialysis provider, India)
Sources: https://nephroplus.com/mobile-app/ , https://apps.apple.com/in/app/nephroplus/id1604127204 ,
https://play.google.com/store/apps/details?id=com.nephroplus.nephroplus

- **Publisher verified** [Observed + Vendor]: the official site links to App Store id `1604127204` and
  Play package `com.nephroplus.nephroplus`; the App Store seller is "NEPHROCARE HEALTH SERVICES PRIVATE
  LIMITED", matching the site's footer company. Store version/rating values were captured in the original research, not rechecked during cleanup.
- **Features** [Observed page text + Vendor store text]: book dialysis sessions ("with just a few taps",
  including holiday sessions), pay for sessions, "View your entire transaction history and download
  your bills", view prescriptions and lab history, video consults with nephrologists and dietitians,
  renal recipes, quizzes.
- **Not found in inspected public material**: transport, family access, notifications; private-app capabilities remain unknown.
- **Relevance** [Inferred]: session booking, payment and downloadable bills are useful provider-app
  patterns; this study did not measure family expectations. Clinical features are outside Anuga's
  hard scope and are listed only so they are not copied.
- **Android inspection**: not performed (see 1.2). Public screenshots and store text were sufficient.

### 2.4 Ride Health (US): care-transport orchestration platform
Sources: https://www.ridehealth.com/platform , https://www.ridehealth.com/health-systems

- **Ride types** [Vendor]: one-way, round-trip, multi-part (pharmacy stop) and "recurring subscriptions
  (day center)".
- **Passenger profile** [Vendor]: "mobility constraints", "service level needs", "communication
  preferences"; "Every detail about a passenger: mobility, communication, behavioral needs: shapes how
  rides are planned and executed."
- **Permissions** [Vendor]: "Ride creation and viewing permissions configurable" across staff, Ride
  Health and passengers or caregivers.
- **Proactive operations** [Vendor]: "Proactive ride scheduling triggered by appointment data";
  "real-time ride monitoring that catches problems before they become missed visits"; a "24/7/365 Ride
  Success team" responds to "automated ride alerts".
- **Family visibility** [Vendor]: "Real-time ETA updates so patients and caregivers always know when
  their ride is arriving."
- **Dispatch** [Vendor]: in-house fleet first, overflow to third parties ("smart offer logic").
- **Reporting** [Vendor]: "CSV exports, customizable dashboards", dashboards for "no-show reduction".
- **Outcome claims**: the earlier 35% no-show reduction figure was removed because no exact supporting source was recorded. No measured outcome is established here.
- **Will-call returns**: an earlier SoonerRide comparison lacked an exact supporting source and was removed. Flexible return pickup remains an Anuga proposal, not a verified Ride Health capability or a one-hour service promise.

### 2.5 Fresenius Kidney Care PatientHub (US, clinical portal)
Sources: https://www.freseniuskidneycare.com/thriving-on-dialysis/patienthub

- [Vendor] Lab results and goal ranges, daily treatment flow sheets sent to the care team, supply orders
  with email/text delivery alerts, secure care-team messaging, fingerprint login. Registration starts with
  the care team; account required.
- App Store rating/review counts removed: the original search-result claim was not source-verified.
- **Not found in inspected public material**: transport, family/care-partner access, treatment schedule; private capabilities remain unknown.
- **Relevance**: mostly clinical, so out of scope. Two transferable patterns only: **status
  notifications for logistics events** (delivery alerts) and **registration initiated by the provider**
  (similar to ops-created accounts).

### 2.6 digniMuv (Hyderabad): wheelchair-accessible patient transport
Sources: https://www.dignimuv.com/ , https://www.dignimuv.com/how-it-works , https://www.dignimuv.com/booking

- **Booking form** [Observed, accessibility tree + screenshot]: Full Name, Phone Number, Pickup Address,
  Drop-off Address, Pickup Date & Time, **Return Date & Time (Optional) "For round trips only"**,
  Additional Notes. "Our team will contact you within 15 minutes to confirm your booking". The page also
  showed "Google Maps is not fully configured" at capture time. Nothing was submitted.
- **Booking modes** [Vendor]: Urgent (5-15 min response), Same Day, Advance "Up to 30 days ahead";
  confirmation by SMS/email with a "Real-time tracking number".
- **Recurring** [Vendor]: "Scheduled Appointments": "Flexible scheduling", "Regular bookings",
  "Reminder service". Dialysis listed among supported trips.
- **Cancellation** [Vendor]: cancel or reschedule "at least 6 hours prior to pick-up" to avoid a fee,
  "through the mobile app or contacting our phone" (no app link found).
- **Pricing** [Vendor]: distance slabs ₹3,500 (0-10 km) to ₹5,000 (20-25 km), then ₹100/km.
- **Vehicles** [Vendor]: hydraulic lifts, wheelchair tie-downs, GPS, CCTV, "Real-time video call monitoring".

## 3. Cross-product patterns relevant to Anuga

| # | Pattern | Seen in | Evidence |
| --- | --- | --- | --- |
| P1 | Phone/WhatsApp or form-based intake; Hospy360/digniMuv advertise short confirmation/call-back times | HosFriend, Hospy360, digniMuv | Observed forms and Vendor promises; completion not tested |
| P2 | Service level is a product choice: companion only, transport + companion, or transport only, priced per block of hours | HosFriend, Hospy360, digniMuv | Observed FAQ / Vendor |
| P3 | Optional return-date/time field | digniMuv | Observed form; does not establish open-ended pickup |
| P4 | Overruns and waiting are **billable extra time**, rarely with a published rate | HosFriend, Hospy360 | Observed FAQ 30, Vendor T&C |
| P5 | Cancellation rules differ: digniMuv advertises a cutoff, Hospy360 a service-start refund boundary; HosFriend permits cancellation and separately discusses hospital cancellation after arrival | digniMuv, Hospy360, HosFriend | Vendor statements; no common late-cancel fee established |
| P6 | Dedicated companion and priority scheduling sold as a **monthly plan** | Hospy360 | Vendor |
| P7 | Female companions advertised for women | Hospy360 | Vendor; matching implementation unknown |
| P8 | Mobility limits declared up front (sitting position only; wheelchair vehicles) | HosFriend, digniMuv | Observed FAQ 18, Vendor |
| P9 | Structured passenger needs (mobility, communication preferences) drive planning | Ride Health | Vendor |
| P10 | Proactive monitoring and alerts before a visit is missed; ops team responds | Ride Health, HosFriend command centre | Vendor |
| P11 | Reminder service advertised | digniMuv | Vendor; Ride Health reminder claim lacks a recorded supporting passage |
| P12 | Family gets ETA / status updates; companion or manager also calls | Ride Health, HosFriend | Vendor, Observed FAQ 15 |
| P13 | Downloadable bills and transaction history | NephroPlus | Observed page text |
| P14 | Explicit "non-medical only" consent at booking | Hospy360 | Observed checkbox |
| P15 | Reporting/CSV for operational outcomes (no-shows) | Ride Health | Vendor |

Patterns deliberately **not** adopted: clinical consults, lab values, treatment logging, medication or
dialysis calculations (NephroPlus, PatientHub), live video monitoring in vehicles and owned fleets
(HosFriend, digniMuv: capital-heavy and outside the companion model), emergency dispatch.

## 4. What this means for Anuga (summary)

Current-code reconciliation (2026-10-12): matrix section 5 compares main `64c4603`
and OPEN PR #10 head `c561a9d`. PR #10 covers existing weekly-pattern edits and
pattern-cancellation companion notifications, not intake or all cancellation paths.
Return-progress transitions already exist for assigned companions and Ops; an
independent ready request, active reassignment and real waiting capture do not.
The smallest recommended slice is general companion cancellation notification
(proposal section 0), preserving existing permissions and pending business policies.
Consolidation remains a separate packaging recommendation. No competitor research
was repeated for this source-code comparison.

1. Anuga's **recurring series with a fixed primary + backup companion** is a concrete product strength,
   not proven market uniqueness. [Hospy360](https://www.hospy360.in/) advertises monthly dialysis
   support and pre-planned visits; digniMuv advertises regular bookings and dialysis transport.
   Their private scheduling, backup assignment and app workflows were not inspected.
2. Anuga's biggest gaps are operational, not visual: **no booking intake screen**, **no flexible return
   pickup or waiting-time capture**, **no proactive exceptions** (unassigned or at-risk visits) and **no
   cancellation cutoff** in the audited snapshot. The reviewed services advertise relevant patterns;
   these do not establish which policies Anuga should adopt.
3. Patient needs are free text today. Competitors gate on mobility (sitting only, wheelchair) and
   gender; Ride Health structures needs. Anuga should store a few structured fields and warn ops on
   mismatches, without collecting clinical data.
4. [Proposal] Consider downloadable bills (NephroPlus) and reminders (digniMuv); user demand was not measured.
5. Details, status per feature and the proposed release are in the two companion documents.

## 5. Limitations

- All competitor behaviour behind logins (apps, ops tools) is unknown; nothing was booked, paid or submitted.
- REA launch-mode capture failed on this host; passive CDP observation was used instead.
- Hospy360's booking-form option lists were redacted by REA's policy filter; the field names come from
  the accessibility tree and WebFetch text.
- HosFriend FAQ 31 amounts were bold spans not present in the extracted text.
- Ride Health facts are vendor marketing; no dialysis-specific or will-call evidence was found for it.
- No Android analysis was done (no authorised APK, Android provider not installed).
- Targeted cleanup source check: Hospy360's official page confirms monthly dialysis support;
  Ride Health's platform page confirms recurring rides/alerts but did not establish the reminder claim.
  digniMuv how-it-works timed out and HosFriend's policy page was inaccessible to the web tool;
  their original findings remain attributed vendor observations, not freshly verified policies.
