# Companion model: who, how selected, how paid (deep research)

> **Scope: dialysis scenario D1 only.** Prices, margins, scheduling limits and companion numbers in this file are for recurring dialysis visits and must not be applied to other service categories. Business-wide strategy is in `AnugaCare_Strategy_v2_Long_Term_Vision.md`; see `README_scope_and_index.md`.

Date: 2026-11-11. Calculations: `model_v9_companion_pay_and_funnel.py` → `model_v9_results.md`. Interview scripts for companions are in `AnugaCare_Interview_Script_and_Deposit_Offer.md`.
Labels: `[V]` found in a source, `[E]` my estimate, `[U]` not found or conflicting, `[I]` needs interviews, a vendor quote, an insurer, a CA or a lawyer.
Nobody was contacted and nothing was spent. Not legal advice.

---

## 1. Short answer

1. **Do not open the platform to anyone on day one.** The customer is an unwell, often elderly person and the product is trust. For the pilot, run a **curated, invite-and-verify intake of 4 to 6 companions**. Open sign-up comes later, after the pilot proves the funnel and the controls.
2. **Taxi, auto and bike-taxi drivers are a good recruiting pool, but only for the escort role.** A driver who is also the escort cannot watch a weak patient, and a private vehicle cannot carry paying passengers without a permit. Patient legs go in a licensed cab or auto; the companion rides alongside or travels on their own two-wheeler.
3. **Set pay from evidence, then test it on candidates before you have a team.** Start at **₹330 base + ₹60 commute + about ₹40 retention bonus = ₹430 effective per round trip** (₹390 if the companion brings a two-wheeler). That is about ₹119 an hour on active time but only about ₹66 on elapsed time, so the offer works only if the 3-hour gap between legs is usable.
4. **The hiring cost is about ₹8,250 per companion, and about ₹45,000 to ₹56,000 for the first five.** It is the main reason early gigs need a clear plan for retention.

---

## 2. Open platform vs curated pilot

| | Open sign-up (anyone with a bike or taxi) | Curated pilot (recommended now) |
|---|---|---|
| Speed to supply | Fast | Slower (about 3 to 5 weeks) |
| Safety for a vulnerable patient | Weak: vetting at volume is expensive and error-prone | Strong: every companion verified, trained, shadowed |
| Bypass control | Weak: lots of freelancers who know a family | Moderate: care teams, guarantees, retention bonus |
| Brand and trust | Risky: one incident ends the brand | Protected |
| Cost per companion | Lower on paper | About ₹8,250 |
| Legal exposure | Higher (platform, vehicles, insurance) | Lower, easier to document |
| When it fits | After proof: on-time ≥95%, zero safety incidents, stable retention | Now |

**Proposed gates to open the platform:** at least 30 paying families; on-time pickup ≥95% for 8 weeks; zero serious incidents; verification vendor and insurance in place; a lawyer-approved engagement form; and an application funnel that passes 1 in 5 or better. The existing system in this repository already has companion training and suspension controls and ops approval of companions according to `CLAUDE.md`, so intake rules can be enforced there later; I have not verified details.

---

## 3. Candidate pools

| Pool | Strengths | Risks | Pay expectation `[E]` | Best use |
|---|---|---|---|---|
| **Bike-taxi, auto and cab drivers** (Rapido, Uber, Ola) | Know the city, punctual habit, own a vehicle, used to gig pay | Driver mindset not escort mindset; will compare against app earnings; direct-hire risk is highest | Compare to Rapido's target of ₹70 to ₹80 an hour net after fuel for riders `[V]` company statement | Two-wheeler riders as companions for the solo legs and for shuttle runs; auto drivers as the patient-leg vehicle partner, not as the escort |
| **Ex-hospital ward staff, GDA and HHA graduates** | Handling skills, patient manner, certificates exist | Wage expectations ₹16,000 to ₹24,000 a month `[V]` listings; may want salaried work | ₹77 to ₹144 an hour equivalent | Core escort pool |
| **Nursing students and graduates** | Clinical awareness, trainable | Overqualified, short tenure, can drift to clinical tasks you must forbid | Higher | Careful: keep non-clinical scope; good as supervisors |
| **Women re-entering work (NGO and community referrals)** | Care mindset, stable tenure, trusted by families | Need flexible hours; travel safety; mobility to reach homes | ₹10,000 to ₹16,000 part-time | Strong pool for part-time shifts and female patients |
| **Retired or semi-retired (ex-army, ex-nursing, community)** | Reliable, calm | Physical limits, tech comfort | Lower | Selected morning shifts |
| **Staffing agencies** | Fast bench | Margin 15% to 25% `[E]`; you do not own the relationship | Higher | Backup supply only |

Rule of thumb: build the core of **escort-minded people** (ward staff, women re-entering, ex-hospital) and add **two-wheeler riders** as the mobile layer.

---

## 4. Pay benchmarks (what I could verify)

| Benchmark | Figure | Status |
|---|---|---|
| Telangana minimum wage, ward boy in hospitals and clinics | ₹15,960 a month from 1 Apr 2026 (to 30 Sep 2026) | `[V]` WageIndicator |
| Telangana minimum wage, unskilled, Zone I | ₹16,000 from 1 Jun 2026 | `[V]` (round 1) |
| Hyderabad ward-boy and patient-care listings | ₹16,000 to ₹24,000; some ₹18,000 to ₹30,000; low end ₹15,000 | `[V]` job portals |
| Home-care agency listing | ₹15,000 to ₹60,000 (mixes nurse and attendant roles) | `[U]` too broad |
| HCAH attendant | ₹1,000+ a day | `[V]` vendor |
| Rapido riders | Target ₹70 to ₹80 an hour net after fuel; "₹65,000 to ₹100,000 a month" and half of Hyderabad captains on it as primary income | `[V]` company statements only |
| Uber and Ola drivers | Older study: ₹45,000 to ₹50,000 gross after commission, net about ₹10,000 after EMI; fuel about 40% of earnings | `[V]` undated study, `[U]` current |
| Driver share of fare under the 2025 aggregator guidelines | At least 80% when using own vehicle, 60% for aggregator-owned vehicle | `[V]` news |
| Telangana gig-workers Act 2026 | Aggregator welfare fee 1% to 2% of transaction value, not deductible from worker pay | `[V]` secondary reports, see section 9 |

---

## 5. Companion pay maths

### 5.1 What ₹430 per trip means

| Basis | Hours | ₹ per hour |
|---|---|---|
| Active time (travel, rides, handovers) | 3.6 | 119 |
| Elapsed time, first pickup to second drop | 6.5 | 66 |

At ₹66 an hour on elapsed time the offer is below a ward boy's wage unless the gap is used. Three ways to use it:
1. **Stagger two patients a day** (a morning and an afternoon shift) so each companion does two paid round trips per day.
2. **Fill the gap with their own work** (for example, Rapido rides), keeping a protected buffer of about 45 minutes before pickup.
3. **Batch two or three patients** on a shared run later.

### 5.2 Monthly income

| Trips per month | ₹ at ₹430 | ₹ at ₹390 (own two-wheeler) | Comparable to |
|---|---|---|---|
| 20 | 8,600 | 7,800 | Part-time top-up |
| 30 | 12,900 | 11,700 | Part-time |
| 37 | 15,910 | 14,430 | Pilot density (150 visits ÷ 4 companions) |
| 45 | 19,350 | 17,550 | Ward-boy entry wage |
| 52 | 22,360 | 20,280 | 2 trips a day |
| 78 | 33,540 | 30,420 | 3 trips a day, scale-stage |

**Meaning:** in a 15-family pilot a companion earns about ₹15,000 a month. That works as a **part-time or top-up job** (students, women re-entering, bike riders), not as a living wage. Plan for part-time companions, say so openly, and expect full-time hires only at scale.

### 5.3 Pay structure (illustrative, `[E]`)

| Element | ₹ per round trip (≤8 km) | Note |
|---|---|---|
| Base | 330 | About 3.6 active hours |
| Commute allowance | 60 (20 with own two-wheeler) | Covers two solo legs |
| Retention bonus | about 40 | ₹1,500 a month if ≥30 trips, ≥95% on time, no direct-dealing breach |
| Tenure ladder | +10 every 6 months up to +30 | Keeps good people |
| Distance band 8 to 15 km | +120 customer-side; companion +60 `[E]` | |
| **Effective** | **430 (390 with a bike)** | |

Also: weekly payout; accident cover paid by AnugaCare; paid training and shadow days; **minimum monthly guarantee of ₹6,000 to ₹8,000 after 20 completed trips** (maximum exposure ₹24,000 to ₹40,000 a month for 4 to 5 companions, almost never binding at 37 trips each).

### 5.4 Setting pay before you have a team

You have no companions yet, so test pay **on candidates**, not on guesses.

1. In each candidate interview (script in the companion interview file), ask the reservation pay first (the lowest they would take for this trip) before showing your number.
2. Show **three offers** to the first 10 candidates: ₹330, ₹380, ₹430 per trip, each with the same duties. Record the acceptance.
3. Pick the **lowest rate at which 4 candidates commit to named shifts**. If it is above about ₹550, or candidates say they would only do it as direct work, the model fails at this price and needs the employment route or a higher price.
4. Run **two paid shadow runs** with the first candidates to check real minutes against the 215 modelled.
5. Review pay at day 30 and 60 against retention and on-time rate.

---

## 6. Selection funnel

| Step | What | Pass test | Cost `[E]` |
|---|---|---|---|
| 1. Apply | Short form: name, phone, area, availability, vehicle, language, prior work | Complete and in the micro-market | ₹0 |
| 2. Phone screen (10 min) | Motivation, availability, fit with part-time pay, direct-hire attitude | Clear and calm; availability matches shifts | ₹0 |
| 3. ID and e-KYC | Aadhaar-based ID, address | Match | about ₹150 |
| 4. Structured interview (45 min) | Script plus scenario role-play | Score ≥ threshold | founder time |
| 5. References | 2 references, one from a recent employer or community | Positive, no flags | ₹0 |
| 6. Background check | Police or court record and address check via an accredited vendor | Clear | ₹1,000 to ₹2,000 (vendor blogs report ₹250 to ₹2,000 court, ₹250 to ₹1,000 address) `[V]` conflicting |
| 7. Medical fitness | Basic: can lift, no communicable disease | Fit | about ₹500 |
| 8. Training (2 to 3 days) | Section 7 | Written and practical check | about ₹3,500 |
| 9. Shadow runs (2, paid) | With an experienced person, or two founder dry runs | Pass checklist | about ₹1,800 |
| 10. Probation (20 trips) | Monitored, family feedback after each, daily review | On-time ≥95%, zero concerns | included |

Pass rate from applications to hire: my judgement is 5% to 20%. Total hiring cost for the first five companions is about **₹45,000 to ₹56,000** including screening of 25 to 100 applicants.

**Red flags (stop):** refusal of verification; asks to be paid outside the platform in the first call; vague about previous work; unusual interest in patient cash or valuables; cannot handle a scenario calmly; pushes for medication or clinical tasks; poor boundary with elderly patients.

**Scenarios to test (role-play):** patient dizzy at the centre door; family member asks the companion to hold money; patient refuses to leave; centre staff are late; family offers cash tip and a direct deal; the cab arrives with a different driver; patient falls near the vehicle.

---

## 7. Training and certification

- **Certificates exist:** Healthcare Sector Skill Council General Duty Assistant (NSQF level 4, model curriculum listed at 240 hours; an older Ministry of Health handbook sets 710 hours; sources conflict) and Home Health Aide (NSQF level 3) `[V]`. Advanced GDA course listings show 500 to 1,200 hours and a fee of ₹24,500 in one Kerala programme `[V]` conflicting. I did not find a verified current fee for Home Health Aide.
- **Do not require certification for the pilot,** but prefer candidates who hold GDA or HHA, and keep the 2 to 3 day AnugaCare module for everyone.
- **Module content (non-clinical only):** safe transfers and fall prevention; getting in and out of a vehicle; post-dialysis care as taught by the centre (follow the centre's instructions; do not apply pressure to the access arm unless trained by the centre); recognising when to call the family or the centre; first-aid and CPR basics; OTP and handover protocol; dignity, privacy and boundaries; no medicines, no money handling, no gifts; communication in English, Telugu and Hindi; data privacy.
- **Ask a nephrology nurse or the centre** to review the module and sign off the "when to escalate" rules `[I]`.
- **Never position a companion as a nurse or medical professional.** Badges and scripts say "companion".

---

## 8. Safety, trust and bypass controls on the companion side

See `AnugaCare_Pricing_Structure_and_Bypass_Defence.md`. Companion-specific:
- Agreement: exclusivity for AnugaCare-introduced families while engaged; confidentiality and data protection; duty to report direct approaches; suspension for breach. Post-exit restraints on individuals are generally void under Section 27 `[V]` commentary, so rely on incentives.
- Rotation, masked contact, ID, trip tracking and a family report each trip.
- **Insurance:** personal accident cover for companions and passenger liability for patient legs, through the cab partner. Quotes `[U]`.
- **Female patient preference** and a no-single-companion dependence rule.
- Complaints process and a written incident log.

---

## 9. Legal form: where this can go wrong

- **Telangana now appears to have a gig-workers law.** PRS lists *The Telangana Platform Based Gig Workers (Registration, Social Security and Welfare) Act, 2026* as Act 21 of 2026 in the gazette, and Bar and Bench describes it as enacted `[V]` secondary reports. It reportedly sets an aggregator fee of **1% to 2% of transaction value**, not deductible from worker pay, with registration and a 7-day termination notice. **I could not open the Act itself** (the site did not resolve in this session), so scope, definitions, commencement and exemptions are `[U]`. Whether AnugaCare is an "aggregator" and companions are "platform based workers" is `[I]`: a lawyer must read the Act.
- **Central Code on Social Security 2020** (in force from 21 Nov 2025 per one source): aggregator contribution of 1% to 2% of turnover, capped at 5% of payments to gig workers, rate not yet notified in an Oct 2026 source `[V]`/`[U]`.
- **Effect if either levy applies:** about ₹9 to ₹18 per trip at ₹917, lowering contribution from ₹334 to about ₹316 to ₹325. Absorbable.
- **Employment vs contractor:** more control (schedules, exclusivity, uniform, guaranteed minimum) pushes toward employment, with statutory costs. Choose the form with an employment lawyer before the first agreement.
- **Vehicle rules:** see `AnugaCare_Mobility_Waiting_and_Segment_Analysis.md` section 10.

---

## 10. What to do next (all need your approval)

1. Ask 2 verification vendors for a rate card for 5 to 10 candidates and the turnaround.
2. Ask 2 insurers for companion accident and passenger liability quotes.
3. Ask a training provider (HSSC-aligned) or a nephrology nurse to deliver or review the module and give a price.
4. Draft the companion agreement with an employment lawyer, including the Telangana gig Act question.
5. Use the pay test (5.4) with 10 candidates before committing any pay figure to a family.
6. Do not publish "join as a companion" until the gates in section 2 are met.

## 11. Limits

- No Hyderabad home-health-aide wage was found. Rapido and Uber figures are company statements or an old study. Vetting prices are vendor-blog ranges that conflict. The gig-workers Act was not read directly.
- Pass rates, pay acceptance and the 8,250 hiring cost are my estimates.
- Sources: [Telangana ward-boy minimum wage](https://wageindicator.org/salary/minimum-wage/india/21802-telangana/36946-hospitals-nursing-homes-clinics-and-dispensaries), [Hyderabad ward-boy listing](https://www.jobhai.com/ward-boy-ward-boy-job-in-healthcare-at-home-india-private-limited-somajiguda-hyderabad-1-to-6-plus-years-1775542322-7480791-jid), [Rapido Hyderabad captains](https://newsmeter.in/data-stories/50-of-rapido-drivers-in-hyderabad-rely-on-platform-for-primary-income-rapido-763214), [Hyderabad cab driver study](https://www.thehansindia.com/news/cities/hyderabad/cab-drivers-in-hydbad-earn-low-bereft-of-social-benefits-study-809853), [BGV pricing, MploycheK](https://mploychek.com/blog-cost-background-verification-india.html), [HSSC GDA qualification](https://www.nqr.gov.in/qualification/file/Qualification%20File%20-%20STT_General%20Duty%20Assistant%20Trainee_v2.0.pdf), [Home Health Aide qualification](https://www.nqr.gov.in/qualification/file/Qualification%20File%20-%20STT_Home%20Health%20Aide.pdf), [Telangana gig Act (PRS)](https://prsindia.org/files/bills_acts/acts_states/telangana/2026/Act21of2026TG.pdf) (not read), [Bar and Bench on the Act](https://www.barandbench.com/columns/beyond-the-app-why-telanganas-new-law-is-a-major-step-for-gig-worker-dignity), [MVAG 2025 summary](https://www.angelone.in/news/ola-uber-rapido-can-charge-double-during-peak-hours-bike-taxis-legalised), [Samarth vetting claims](https://care.samarth.community/home-health/).

---

## 12. Addendum: scheduling changes the headcount

The scheduling simulation (`AnugaCare_Scheduling_Analysis.md`) shows a companion can reliably do about 1.0 solo round trip or 1.5 visits on a swap crew per day. A 15-family pilot therefore needs **7 to 9 part-time companions** (not 4 to 5), each earning about ₹9,000 to ₹13,000 a month at the pay modelled. Hiring cost for 7 to 9 is about ₹58,000 to ₹74,000. Favour candidates for whom this is a top-up (two-wheeler riders, students, women re-entering work), and be open about the income in interviews. The "2 to 3 trips a day, ₹33,540 a month" scale-stage figure in section 5 is not supported; use about ₹13,000 to ₹19,000 as the reliable range.
