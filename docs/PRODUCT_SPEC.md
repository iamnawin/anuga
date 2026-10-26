# Product spec: Dialysis Companion (codename `companion`)

Shared product requirements for every contributor and agent. `CLAUDE.md` and `AGENTS.md`
point here. Business case and pilot plan: `Pilot BRD.md`. Delivery plan: `docs/TASKS.md`.

Brand: **AnugaCare** (ADR 0006; domains `anugacare.com`, `anugacare.in`; trademark search pending).
Families and companions use mobile apps; the ops console is an internal web tool.
The codename `companion` stays in code, packages and folders.

## 1. What we are building

A **scheduled hospital-visit companion service for hemodialysis patients**, starting in one area of
Hyderabad, India. Owned by **ZeroOrigins AI Pvt Ltd** (incorporated July 2026).

- A dialysis patient needs 2-3 hospital visits every week, for life.
- Families (often a son or daughter working full-time, in another city, or abroad) cannot attend
  every visit. Travel and lost wages make up more than half of monthly dialysis-related spending.
- We provide a **verified, trained companion** who picks the patient up, takes them to the dialysis
  centre, handles check-in and paperwork, brings them home, and sends the family live updates.
- The patient also gets a **private health vault**: reports, weight, BP, dialysis notes and medicines,
  visible only to people the family owner allows.

**Core principle:** this is not "Uber for companions". Demand is **recurring and scheduled**
(e.g. Mon/Wed/Fri 7 AM). Consistency beats proximity: each patient gets the **same primary companion
plus a backup**. On-demand matching only fills gaps.

**Hard scope limits (never build features that break these):**

- **No emergencies.** Emergencies go to 108 / ambulance. The app shows emergency numbers; it does not dispatch.
- **No clinical tasks.** Companions are non-medical: no nursing, cannulation, medication administration or vitals interpretation.
- **We do not sell medicines.** The app only reminds and raises refill requests. Ordering goes through a licensed partner pharmacy (later phase).

## 2. Users and roles

| Role | Who | App | Can see |
| --- | --- | --- | --- |
| Owner (family) | Family member who creates the patient profile and pays | Family app | Everything for their patient(s); controls who else sees what |
| Patient | Adult on maintenance hemodialysis, often 50+ | Family app (simplified view) | Own schedule and vault |
| Shared family member | Sibling/relative invited by owner | Family app | What the owner grants (view-only by default) |
| Companion | Verified part-timer living within 2-3 km of the patient | Companion app | Only what the trip needs: name, address, pickup time, emergency contact, mobility notes. **Never** vault files, reports or diagnoses |
| Partner centre | Dialysis centre staff | Later (web) | Only visit schedules they are part of |
| Ops admin | ZeroOrigins operations team | Ops console (web) | Trips, assignments, payments. Vault only with the owner's recorded consent; every view logged |

Profile-based access ("docking") is **enforced in the database** (grants + row-level security +
restricted functions), not only in app code.

## 3. MVP features

### 3.1 Booking and schedules

- Owner creates patient profile: home location (map pin), dialysis centre, recurring pattern
  (days + time), mobility needs, emergency contacts.
- Recurring trip generation from the pattern (rolling window, default 28 days, configurable).
- Primary + backup companion assignment per patient pattern.
- Reschedule / cancel a single trip or the whole pattern.

### 3.2 Live trip

- Trip states: `scheduled → companion_en_route → picked_up → at_centre → handed_over → session_done →
  returning → dropped_home → completed` (+ `cancelled`, `no_show`, `issue_reported`).
  Allowed transitions per actor live in the `trip_transitions` table.
- Companion taps check-ins; each change notifies the family (push + WhatsApp).
- **OTP at pickup**: family/patient issues a code in their app and shares it with the companion.
- Live location of companion during active trip only.
- Post-visit note from companion (text + optional photo of a report/receipt).

### 3.3 Health vault (private)

- Upload reports / prescriptions (photo or PDF) to encrypted, private storage.
- Log weight (pre/post dialysis), BP, dialysis session notes.
- Medicine list: name, dose, timings, stock / refill date.
- Every vault read and write is written to the audit log.

### 3.4 Medicines

- Refill reminders based on stock/refill date.
- "Needs refill" request sent to owner (and, later, a partner pharmacy).

### 3.5 Patient requests

- Simple "I need..." request (collect report, buy an item, extra visit).
- Owner approves/declines; ops assigns.

### 3.6 Family view

- Trip status timeline, post-visit notes, vault, monthly bill, invite family members with roles.

### 3.7 Companion app

- Today's / upcoming trips, patient essentials (restricted fields only), check-in buttons, OTP entry,
  issue report, earnings summary.

### 3.8 Ops console (web)

- All trips (filter by date/cluster/status), assign/reassign companions, exception queue
  (late, no-show, issue reported), companion onboarding status, payments overview.

### 3.9 Payments

- Monthly plan billing via **Razorpay UPI Autopay**; per-visit option.
- Cab/auto fare passed through at actual cost (recorded per trip).

### Later (do not build in MVP, keep the data model open)

Partner-centre portal, pharmacy ordering via licensed partner, ABHA (ABDM) health-record linking,
OCR of lab values + trend charts, other conditions (cardiac rehab, chemo), village/long-distance
pooled van runs, auto-assignment and demand heat maps, masked calling, companion ratings/training modules.

## 4. Matching and geography

- Each **partner dialysis centre** anchors a **cluster** of patient homes.
- **Companion eligibility radius: 2-3 km from the patient's home**, stored per cluster
  (`clusters.companion_radius_m`, default 3000).
- **Density gate:** a cluster opens only with ~10 patients and ~4 companions (`clusters.min_*`
  values, enforced in the ops console, not hard-coded).
- Assignment: fixed primary + backup per weekly pattern. If both are unavailable, ops offers the trip
  to the nearest free eligible companion in the cluster (ops confirms in MVP).
- Patients more than 20 km away (villages) are out of MVP scope.
- Points are PostGIS `geography(Point, 4326)`; radius checks use `ST_DWithin`. H3 hex indexes are
  planned for density views (not in the first milestone). No hand-drawn polygons.
- Cluster sizing differs between documents: the BRD pilot uses a ~5 km area around 2-3 centres, this
  spec allows larger clusters. The radius and gate values are data, so the pilot sets them.

## 5. Packages (pilot hypotheses; prices live in the `packages` table, never in code)

| Package | Includes | Hypothesis price |
| --- | --- | --- |
| Basic | Drop-off + pickup each session, live status, post-visit note, vault | ₹400/visit (~₹4,800 for 12 visits/month) |
| Plus | Basic + companion stays through session, report collection, pharmacy run | ₹700-800/visit |
| Family Care | Plus + monthly vault summary, refill management, named care coordinator | Plus + ₹999/month |

Companion pay hypothesis: ~₹250/visit. Fares passed through at cost. Amounts are stored in paise.

## 5a. Tech stack (decided defaults)

| Layer | Choice |
| --- | --- |
| Mobile apps (family/patient + companion) | **Flutter**, Android first (iOS later from same codebase), one AnugaCare app whose family or companion views are chosen by `profiles.role` (`docs/adr/0007-one-mobile-app-role-routing.md`) |
| Backend | **Supabase**: Postgres + **PostGIS**, Auth (phone OTP), Storage (private buckets), Edge Functions |
| Region | **Supabase Mumbai (ap-south-1)**: health data stays in India |
| Ops console | **Next.js** (TypeScript) on Vercel, using Supabase |
| Maps | Google Maps Platform (geocoding, ETA) behind a provider interface so Ola Maps/Mapbox can be swapped |
| Messaging | WhatsApp Business API via a provider + FCM push; SMS fallback |
| Payments | Razorpay (UPI Autopay subscriptions + one-off) |
| Errors/monitoring | Sentry |
| CI/CD | GitHub + GitHub Actions; Codemagic for Flutter builds; staged Play Store rollout (10% → 50% → 100%) |

Salesforce Health Cloud was considered and rejected as the main platform (licence cost pre-revenue).
Ops CRM and reporting: a one-way, minimum-field copy to Salesforce; Supabase stays the system of
record (`docs/adr/0005-salesforce-ops-copy.md`). Real data in Salesforce is gated with M10.

Repo layout: `apps/anugacare_app` (Flutter entry app, ADR 0007) mounting the screens of
`apps/family_app` and `apps/companion_app`, `apps/ops_console` (Next.js),
`packages/shared_dart` (models, API client, trip state machine), `supabase/migrations`,
`supabase/functions`, `supabase/seed` (synthetic only), `supabase/tests`, `docs/` (ADRs, runbooks).

## 6. Data model and access rules

As built (first milestone) in `supabase/migrations/`. Tables marked *later* are still to come.

- `profiles` (auth user, role: family | companion | ops_admin, name, phone, language)
- `patients` (name, dob, home address + location, centre, mobility notes, emergency contacts).
  Ownership is a `patient_access` row with level `owner`; there is no `owner_id` column.
- `patient_access` (patient, user, level: owner | editor | viewer | patient)
- `consents` (user, patient, purpose: trips | vault | ops_vault_access, granted/withdrawn)
- `clusters`, `centres`, `companions` (cluster, home location, verification, training, active)
- `packages`, `schedules` (days, pickup time, session minutes, timezone, primary + backup companion)
- `trips` (schedule, patient, centre, companion, pickup/return times, status, note, fare)
- `trip_otps` (salted hash only; unreadable by every app role)
- `trip_events` (append-only timeline), `trip_transitions` (state machine as data)
- `notifications` (outbox: one row per recipient per channel)
- `vault_documents`, `vitals`, `medicines`
- `audit_log` (append-only)
- `app_settings` (business values: visibility window, OTP limits, generation window)
- *Later:* `requests`, `subscriptions`, `payments`, live location, H3 density.

**Access rules (each has allowed and denied tests in `supabase/tests/`):**

- Family users reach a patient only through `patient_access`.
- Companions cannot read `patients` at all. They get a restricted projection
  (`companion_my_trips()`) with trip-essential fields only, populated only inside a configurable
  window around each assigned trip. Never vault data, diagnoses or date of birth.
- Vault tables have **no SELECT grant** for any app role. Reads go only through `vault_list_*()`
  functions that authorize and write an `audit_log` row in the same transaction (Postgres does not
  fire triggers on SELECT, so trigger-based read auditing is impossible). Writes are audited by triggers.
- Ops vault access requires an active `ops_vault_access` consent given by the patient's owner.
- Trip state changes happen only through `advance_trip()` / `verify_pickup_otp()`, which check the
  caller's relationship to the trip against `trip_transitions` and notify the family.
- Storage buckets are private; files are served via short-lived signed URLs after an access check (later milestone).

## 7. Privacy and compliance (India), designed in from day one

- **DPDP Act 2023 + DPDP Rules (notified 13 Nov 2025).** Notice, consent, security safeguards and breach
  intimation apply from **13 Nov 2026**; user rights, grievance redressal and fuller rules from **13 May 2027**.
- Consent must be **specific, separate per purpose, plain language**, not bundled with terms, and as easy
  to withdraw as to give: per-purpose consent screens + "withdraw and delete" in settings,
  with a deletion job and audit trail.
- Breach: notify the Data Protection Board without delay, detailed report within 72 hours, inform users.
  Keep `docs/runbooks/breach.md`, monitoring and a named owner.
- Salesforce (ADR 0005) is a processor holding a minimum-field ops copy: Hyperforce India, a DPA,
  named in the privacy notice, and included in deletion and the breach runbook. No vault, vitals,
  medicines, date of birth, diagnoses, addresses or notes are sent.
- Encrypt at rest and in transit; India-region hosting (Supabase Mumbai, ap-south-1); least-privilege
  access; audit every vault read.
- **Never use real patient data in dev/test.** Synthetic seed data only.
- Not legal advice: a health-tech lawyer reviews before launch.

## 8. Pilot and build sequencing

**Founder decision (2026-10-08):** build the MVP now, while the 8-week manual pilot runs in parallel.
This supersedes the BRD line "build an app only if 80%+ of paying families renew"
(see `docs/adr/0001-build-mvp-in-parallel-with-pilot.md`). Production launch is a separate milestone
and still uses the pilot go/no-go results.

- Manual pilot: 2-3 dialysis centres in one Hyderabad area, 8-10 companions,
  WhatsApp Business + Google Sheet. Pilot logs (no-shows, waits, complaints, requests) feed the app backlog.
- **Go/no-go for production launch:** 15+ paying patients, ≥80% renew into month 2, ≥95% on-time pickups,
  <2% visits missed due to us, satisfaction ≥4.5/5, ≥75% companion retention, ≥1 centre referring weekly.
- The app must support exporting trip data so these metrics can be computed.

## 9. Budget context

- MVP + pilot budget ≈ ₹6-12 lakh, founder-funded. Keep infra lean (free/low tiers where possible).
- Funding path: DPIIT recognition, then Startup India Seed Fund (via incubator, eligible until July 2028),
  then angels with pilot data, then seed VCs (e.g. Endiya Partners, W Health Ventures) once clusters repeat.
- No paid service, production credential or public deployment without separate founder authorization.

## 10. Open decisions (ask the founder, don't assume)

- Trademark clearance for AnugaCare; final Android application id (with X1 consolidation).
- Exact Hyderabad cluster and partner centres.
- WhatsApp Business API provider.
- Monthly plan vs per-visit as the default pricing.
- Whether companions may stay through the session by default.
- Insurer for companion accident/liability cover.
