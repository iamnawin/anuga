# AnugaCare Strategy v2.0: long-term vision, phased expansion and first service

Date: 2026-11-11. Status: **draft for founder review**. Version: strategy v2.0, new document. It does not replace the earlier research files; it frames them.
Companion document: `AnugaCare_Hospital_and_Centre_Partnership_Strategy.md`. Index of all files and their scope: `README_scope_and_index.md`.
Calculations for the trial offer and category cost floors: `model_v11_trial_and_category_floors.py` → `model_v11_results.md`.
Labels: `[V]` found in a source (many are weak: vendor pages, press), `[E]` my estimate, `[U]` not found or conflicting, `[I]` needs interviews, a centre, a broker, a CA, a lawyer or a measured pilot.
Nothing was sent, published, built or spent. No customers, centres or companions were contacted. No application code or development branch was touched.

---

## 0. The correction, and what it changes

AnugaCare is a **trusted companionship and assisted-mobility service**. Dialysis is the **market-entry wedge**, not the brand and not the limit.

What stays:
- **Every pricing, unit-economics, scheduling, bypass and projection file so far is scenario D1: recurring dialysis visits.** I keep them unchanged as D1 and have labelled them so (see the index). Numbers such as ₹10,999 for 12 trips, ₹334 contribution per trip, 1.0 to 1.5 visits per companion per day and the 7 to 9 companions for 15 families belong to D1 only.
- **I do not carry D1 economics into other categories.** Dialysis is frequent, schedule-fixed, short in the companion's active time (the patient is in a clinical setting for 4 to 5 hours) and handled by centre staff in the middle. A home visit, an outing or an overnight stay has none of those properties. For other categories this document gives **requirements, risk, cost floors from first principles, and the evidence each must produce**, never a margin.

What this document adds: one brand with several future service lines, a gated roadmap, requirement sets per service mode, acquisition and partnership strategy, a broader positioning, a two-week trial, and a narrow-versus-broad decision.

---

## 1. Vision, brand and positioning

### 1.1 Vision and mission (working text, for your edit)
- **Vision:** every older or vulnerable person in India has someone trustworthy beside them, to the hospital, around the neighbourhood and on the journeys that matter, so families can be at peace.
- **Mission:** provide verified, trained, accountable, non-clinical companions, and run the safeguarding, scheduling and records that make families and institutions trust them.
- **Principles:** trust before scale; dignity and independence for the older person; accountability (records, handover, escalation); non-clinical, always; families see what happens; fair pay and conditions for companions; honest claims; evidence before expansion.

### 1.2 One brand, several service lines
The master brand is **AnugaCare**. Each line has a working name (not trademark-checked `[I]`; the brand name itself is not final per the repository's product documents, so treat all names as placeholders).

| Line (working name) | What it is | Typical duration | Status |
|---|---|---|---|
| **Visits** | Scheduled medical visits: dialysis first, then chemotherapy day care, radiotherapy, physiotherapy, OPD follow-ups | 2 to 8 hours door to door | **Launch line (dialysis)** |
| **Company** | Everyday companionship at home or nearby: conversation, walks, errands, shared meals, tech help | 2 to 6 hours | Future |
| **Outings** | Planned day outings: temple, family function, shopping, cinema, park | 6 to 10 hours | Future |
| **Journeys** | Assisted longer journeys, airport and station assistance, multi-day trips; overnight cover | Overnight or multi-day | Last; likely via partners |

### 1.3 Positioning
**Master positioning:** *AnugaCare is the trusted companion for the people you love: someone dependable beside them wherever they need to go.*

Three pillars, in this order:
1. **Trust:** verified, trained, accountable people; a record of every handover.
2. **Time:** families get their hours back and their peace of mind.
3. **Dignity:** older people stay independent, connected and treated as adults.

**What it is not:** nursing or medical care, an ambulance, a taxi marketplace, residential care, or a replacement for family. The broader frame also protects against being priced and judged as transport.

### 1.4 The dialysis campaign stays, as one acquisition message
Master brand speaks about companionship and trust. Campaigns speak to one pain at a time. The first campaign is:

> **"Get your 6 to 7 hours back on dialysis days."** A trained, ID-checked companion takes your parent to the dialysis centre, hands them to the centre team, and brings them home.

It sits under *Visits*, aimed at adult children and shown to dialysis centres as a reliability service. Later campaigns follow the same pattern: *"A familiar face for the afternoon"* (Company), *"Be at the wedding, with someone beside Amma"* (Outings). These are illustrative lines, not approved copy.

### 1.5 Claims discipline
- Say **companion**, never nurse or medical professional.
- Do not claim a feature or protection that is not live and proven. Examples: "ID-verified" only once a vetting vendor is used; "OTP handover" only when it works in production (the repository's trip workflow is in test mode per `CLAUDE.md`, production is gated); "backup within an hour" only after measured replacement times; "centre-approved" only with written permission.
- Never use a hospital's name or logo without written permission.

---

## 2. Service categories and what each one requires

Short visits, long visits, day outings and overnight activities are different businesses. The table lists requirements, not prices. Cost floors come from `model_v11` and are the lowest price that avoids a direct loss before overhead, founder pay, acquisition cost or margin; they are not targets and not D1 numbers.

| Requirement | **Short visit** (up to 3 h; includes scheduled medical visits) | **Long visit** (3 to 6 h, at home) | **Day outing** (6 to 10 h) | **Overnight** (10+ h, home or hospital bystander) |
|---|---|---|---|---|
| **Typical use** | Dialysis, chemo, physio, OPD; errands; a walk | Company at home, meals, supervised activity | Temple, wedding, shopping, cinema | Night cover; recovery at home; hospital stay bystander |
| **Where risk sits** | Handover and transit | Alone at home with a vulnerable adult | Vehicle, crowds, heat, toilets, mobility, meals | Sleep, night falls, toileting, wandering, fatigue of the companion |
| **Companion** | Part-time, trained, ID-verified | Same plus home-access vetting and matched pairing | Experienced; first-aid; may need two for wheelchair users | Night-trained; limited hours; rest rules; supervisor on call |
| **Safeguarding** | ID, police and address check, references, training, trip records, family notices | Adds home-entry rules, spot check-in calls, supervisor review, no private money or keys, incident log | Adds trip plan and risk assessment per outing, emergency contacts, consent from family | Adds enhanced vetting, two-person or on-call escalation, daily review, written consent to the arrangement |
| **Insurance (get quotes, `[U]`)** | Companion personal accident; public liability; passenger liability through a licensed vehicle partner | Adds professional indemnity; check home-visit exclusions | Adds event and travel cover; operator permits and passenger cover | Highest underwriting; clinical-boundary exclusions; employer's liability if employees |
| **Vehicles** | Licensed cab or auto on contract | Usually none | Licensed vehicle, accessibility for wheelchairs `[I]` | Rare |
| **Consent and records** | Family authorisation; handover record | Care plan; daily log | Outing plan and consent | Care plan, night log, escalation protocol |
| **Pricing model** | Per visit or monthly plan (D1 for dialysis) | Per hour in blocks with a minimum | Day rate plus pass-through costs | Per night, with night uplift |
| **Cost floor, illustrative** `[E]` | ₹358 (2 h) | ₹616 (4 h) | ₹1,178 (8 h, one companion); ₹2,263 with two | ₹2,131 (12 h, night uplift 1.25) |
| **Evidence available** | Dialysis modelled and researched; other medical visits are hypotheses | Anchors only: about ₹400 to ₹500 an hour in press and a third-party list `[V]` weak | One unverified anchor of ₹850 an hour `[V]` weak | None found |
| **Risk level** | Moderate | Higher | Higher | Highest |

Additional points:
- **Safeguarding standard is self-imposed.** I found no statutory registry or licensing for elder-care companions. The Maintenance and Welfare of Parents and Senior Citizens Act 2007 is about family obligations, not paid-worker vetting `[V]` secondary. A claim that caregivers can be fined for abandonment could not be confirmed `[U]`. AnugaCare's own policy has to carry the load: a named safeguarding lead, vetting, a reporting channel, an incident log, supervisor spot checks, retention rules and a DPDP-compliant data approach.
- **Labour rules change with long and night work.** Telangana's Shops and Establishments Act sets an 8-hour day, 48-hour week and overtime at double the ordinary rate, and women's night work requires consent and transport `[V]` secondary summaries. Whether these apply to a companion service, and how, is `[I]`. This is why overnight comes last.
- **Insurance premiums for care providers were not found.** Cover types exist (public liability, professional indemnity, group personal accident) but pricing is `[U]`. A broker quote per category is a gate.
- **Clinical boundary.** Long and overnight work drifts into personal care and clinical tasks. Define it in writing, train to it, and refer to licensed nursing agencies for anything clinical.
- **Companion workforce differs by line.** Short scheduled visits suit part-timers (bike riders, students, women re-entering work). Long visits and outings favour mature, stable, experienced people. Overnight needs a separate, supervised pool.

---

## 3. Phased roadmap with gates

Phases advance on **evidence**, not on dates. Dates in the last column are the earliest plausible, not forecasts.

| Phase | What | Gate to leave it (all must hold) | Earliest |
|---|---|---|---|
| **0. Validate (dialysis)** | Interviews, centre protocol, companion pay test, shadow runs, deposit pre-sale (about ₹60k to ₹80k) | At least 2 centres confirm a handover protocol in writing; at least 5 refundable deposits with 2 at ₹10,999 or above; at least 4 companions committed to named shifts; real-route shadow run fits the windows; CA and lawyer answers on GST and engagement | Weeks 0 to 8 |
| **1. Dialysis pilot** (*Visits*, one micro-market) | 15 to 30 paying families, shifts 1 and 2, swap runs, part-time companions | **8 straight weeks of:** on-time pickup at least 95%; zero serious safeguarding incidents, every incident closed in the stated time; plan retention at least 70% after 3 months `[E]`; measured contribution per visit at least ₹150 (kill line) and ideally ₹250 or more (D1 only); companion monthly turnover 10% or less; overhead 112k a month or less; at least 30 paying families; insurance and safeguarding policy approved | Months 3 to 9 |
| **2. Adjacent medical visits** (*Visits*) | Chemotherapy day care, radiotherapy, physiotherapy, OPD follow-ups for the **same families, centres and hospitals** | Each service: at least 20 completed paid visits **with its own measured unit economics**, no dialysis margin assumed; no safeguarding incident; families ask unprompted (at least 10 requests or 30% of customer families `[E]`) | After Phase 1 gate |
| **3. Everyday companionship** (*Company*, short home visits up to 3 h) | For **existing, trusting customers**, then their networks | 10 to 20 paid visits; enhanced home-visit safeguarding in place; repeat rate at least 50%; no incident; measured margin above the cost floor with a buffer | After Phase 2 evidence |
| **4. Long visits and day outings** (*Company*, *Outings*) | 3 to 6 hour visits; planned outings in small groups with licensed vehicle partners | At least 3 months of clean Phase 3 visits; broker-confirmed insurance for outings; per-outing risk assessment in use; at least 10 outings completed without incident; measured unit economics per outing type | After Phase 3 |
| **5. Assisted journeys and overnight** (*Journeys*) | Airport and station assistance, longer journeys; overnight via partners or tightly supervised | Labour-law and night-work review complete; two-person or on-call model proven; insurance bound; partner agreements for anything clinical; a separate risk sign-off by you | After Phase 4, possibly never in-house |

**Moving geography:** add a second micro-market in Hyderabad (density matters because of the scheduling constraint) before any new city. Move to a new city only when unit economics repeat in two micro-markets.

**Pause rules at any phase:** any serious safeguarding incident without a documented root cause and fix; on-time pickup below 90% for 4 weeks; companion turnover above 20%; insurer declines cover for the next category; cash below 3 months of overhead.

---

## 4. Customer acquisition by segment

Pilot CAC and conversion figures remain `[E]`. I found no Indian benchmark. The first-100 plan from the v1 report still applies for dialysis.

| Segment | Their pain | First offer | Message | Channel | Proof they need | Risks and ethics |
|---|---|---|---|---|---|---|
| **Adult children** (working, or abroad) | Time lost, guilt, worry, no dependable person | Two-week trial (section 7) | *"Get your 6 to 7 hours back"*, later *"Someone you trust beside your parent"* | Referrals from other families, dialysis support groups, centre introductions you choose, WhatsApp communities, employer parent-care benefits | ID, record of each trip, family messages, named companions, references from other families | Do not exaggerate; do not pressure; keep prices clear |
| **Elderly customers** (direct) | Independence, fear of burdening family, loneliness (living alone raises loneliness risk sharply in Indian ageing data `[V]`, 37% to 41% versus about 13% to 20% overall, definitions differ) | Always involve the family; offer a first short visit that the older person chooses | *"Someone to go with you, so you can stay independent"* | Through family, senior-living managers, community groups | Warm, known companion; their own say in choosing | They often will not pay themselves; never push a vulnerable person to buy; consent and dignity first |
| **Hospitals and centres** | Missed and late sessions, waiting-area load, discharge handover | A reliability pilot with 3 to 5 patients (see partnership document) | *"A verified handover and on-time arrival, at no cost to you"* | Direct visits to centre managers and medical leads | Written protocol, metrics, insurance, incident log | No endorsement assumed, no referral fees, no logo use without permission |
| **Dialysis centres** | Same, plus chair turnover | Same | Same | Same | Same | Same |
| **Senior living communities** | Resident needs outside their care model, visits and outings, event attendance | A small pilot for residents who need hospital visits; later companionship hours as a resident add-on | *"Support for residents' hospital visits and outings, without adding to your staff"* | Community managers, resident associations | Insurance, vetting, referrals, clear scope | Hyderabad has a wave of new premium communities (press reports of ₹400 crore and ₹600 crore programmes `[V]` weak) and a Hans India note that official records list only 19 registered senior homes in Telangana `[V]`; markets are small and still forming. Keep scope clear to avoid overlap with community staff |
| **Relevant partners** | Complementary needs | Referral relationships without fees where possible | Specific to partner | Nephrologists and nurses (introductions only), physiotherapists, geriatricians, home-nursing agencies (they do clinical care, we do companionship), diagnostic labs, pharmacies, RWAs, NGOs, employers' HR teams | Reliability data | No payments to doctors or hospital staff for referrals `[I]` check ethics and law; no conflicts of interest |

**Sequencing:** adult children in one micro-market through families and one or two centres first. Senior living and employers once the pilot has measured reliability. Elderly-direct only through families or trusted community channels.

---

## 5. Hospital and centre partnership, summary

The full strategy is a separate file. Core points:
- **No assumed permission or endorsement.** I found no published Hyderabad centre policy on external companions. Every centre is "unknown" until it says otherwise in writing.
- **Ask for a verified handover protocol, not a blessing.** Registered companions, ID, family authorisation, named staff handover, timestamped record, escalation.
- **Offer reliability, not promises:** on-time arrival, a monthly report, an incident log, insurance proof, a stop button.
- **No fees, no referral payments, no exclusivity, no logo use without written permission.**

---

## 6. Brand positioning by audience and category

| Audience | Master message | Campaign message (acquisition) | Do not say |
|---|---|---|---|
| Adult children | Someone you trust beside your parent | Dialysis: *Get your 6 to 7 hours back* | "Nurse", "guaranteed backup", "approved by [hospital]" |
| Older customers | Stay independent; someone dependable with you | *Go where you need to go, with company* | "Babysitter", "care for the elderly" in a diminishing tone |
| Centres and hospitals | A verified, accountable handover | *On-time arrival and a documented handover* | "Endorsed", "replaces your staff", clinical claims |
| Senior living | Support for residents' visits and outings | *No extra staff, same standards* | Claims of residential care |
| Partners | Complementary, non-clinical companionship | Case-specific | Fee-for-referral language |

Voice: warm, plain, respectful, no jargon, English, Telugu and Hindi (the product direction in `CLAUDE.md` already requires all three).

---

## 7. Two-week Care Trial (dialysis, scenario D1)

**Goal:** let a family test the service before a plan, at a price that is honest, financially viable, operationally realistic and free of unverified promises.

### 7.1 The offer
- **6 round trips in 14 days** (about three a week), fixed weekly pattern.
- **₹5,499** (₹916 per trip, the same per-trip price as the plan, no discount). Alternative test cell ₹4,999. Fare extra, prepaid at cost.
- **₹500 refundable deposit**, if paid earlier, is credited to the trial.
- Eligible only if: within about 8 km of a centre that has confirmed the handover protocol in writing; the patient attends shift 1 or 2; the family signs the authorisation.

### 7.2 What we promise (and what we do not)
**Promise:**
1. A named companion confirmed 48 hours before each trip.
2. A message at each step of the trip.
3. Free cancellation up to 12 hours before a trip.
4. Stop at any time; **unused trips refunded within 7 days**.
5. If we cannot cover a booked trip we tell you as early as we can, at least 12 hours ahead where possible, **refund the trip and add a ₹150 credit**.

**Do not promise:** a replacement companion, a response time, or any backup coverage until real replacement times exist from at least 4 weeks of operation.

### 7.3 Is it viable? (D1 only, 15-family pilot scale, `model_v11`)

| Trial price | Contribution per trip | Net per trial family before acquisition cost | Break-even conversion at ₹3,000 CAC* |
|---|---|---|---|
| ₹3,999 | ₹71 | **−₹459** | 17% |
| ₹4,999 | ₹240 | ₹419 | 13% |
| **₹5,499** | **₹325** | **₹858** | **11%** |
| ₹5,999 | ₹409 | ₹1,298 | 8% |

*Share of trial completers who must join the plan and stay 6 months. Assumes 20% of families stop after trip 2, onboarding ₹400 and first-trip supervision ₹430 per family, plan contribution about ₹4,000 per family-month `[E]`, retention unmeasured.

**Reading:** do not discount the trial below about ₹4,999; ₹3,999 loses money before acquisition cost. At ₹5,499 the trial itself pays for set-up, and 11% of completers staying six months pays back a ₹3,000 acquisition cost. The risk is not the trial price; it is whether anyone converts.

### 7.4 Operationally realistic
- Capacity: 6 trial families at once means about 18 trips a week. At 1.0 to 1.5 visits per companion-day (scheduling analysis), a team of 4 to 5 companions covers it, with a second person on each family's first trip.
- Do not start any trial until the centre protocol is confirmed and the shadow run has passed.
- Trial families are on the same safeguarding, consent and record rules as paying plans.

### 7.5 Trials for other categories (later)
Not priced now. For each new line, the first offer will be a **small cost-recovery pilot for existing customers**, priced at a measured cost floor plus a buffer, limited to 10 to 20 visits, with the same refund and honesty rules. Prices are set only after the first measured visits.

---

## 8. Start narrow, or launch several services at once?

### 8.1 Comparison

| Criterion | **Narrow: recurring dialysis first** | **Broad: several categories at once** |
|---|---|---|
| Evidence on unit economics | Modelled, with scheduling and pay tests planned | None for other categories; only weak price anchors |
| Demand predictability | Fixed schedule, 12 to 13 trips a month per family | Irregular, episodic demand; no Hyderabad evidence |
| Scheduling density | One micro-market, two centres, shifts 1 and 2 can reach density | Spread across hours and places; density fails |
| Workforce | One trained pool, part-time | Different pools and training per line; 7 to 9 for 15 dialysis families already |
| Safeguarding load | Handover plus transit | Adds home access, outings and overnight at once |
| Insurance | One category to underwrite | Several, each with unknown cover and price |
| Brand clarity | Clear campaign, clear promise | Risk of being nothing in particular |
| Capital need | About ₹60k to 80k to validate; ₹6 to 7 lakh to pilot | Larger and spread across more unknowns |
| Learning speed | Fast: repeated, comparable trips | Slow: small samples in every line |
| Blast radius of a failure | One line; limited | A single safeguarding incident can end the whole brand |
| Option value | Dialysis customers become the first buyers of other lines | Wider early reach, but little trust yet |
| Partner relationships | Centres judge reliability on one clear service | Mixed messages |

### 8.2 Recommendation
**Start narrow in operations and broad in brand.** Launch only dialysis visits as the delivered service. Keep the master brand and a visible "coming next" roadmap. Meanwhile, **sense demand** for other lines cheaply, without delivering them: ask existing families unprompted what else they need, keep a waitlist, and run interviews with senior-living managers.

Evidence behind the choice: the scheduling simulation shows one companion reliably does only 1.0 to 1.5 visits a day even in a regular service; unit economics, density and pay exist only for dialysis; the safeguarding and insurance requirements of long, outing and overnight work are higher and unquoted; and a single serious incident hurts a young brand more than a narrow scope does.

**When broadening earlier could be justified:** a funded team with separate operations leads per line; inbound demand evidence for a second line from at least 10 paying families; a licensed partner who carries the clinical and vehicle risk; or an insurer who has quoted all lines. None exists now.

---

## 9. Conclusion

### 9.1 Long-term vision
AnugaCare becomes the trusted companion for older and vulnerable people in India: first on the hospital journey, then in everyday company, outings and assisted travel, built on verified people, honest claims, records families can see, and partnerships with hospitals and communities that earn their trust one reliable handover at a time.

### 9.2 Recommended first service
**Visits: recurring dialysis trips, drop-and-return, in one Hyderabad micro-market** (shifts 1 and 2, swap runs, part-time companions).
- **D1 test pricing:** ₹10,999 per 4 weeks for 12 trips (₹917 per trip), fare extra; Safe Return ₹7,799 for 12 returns; Stay ₹1,499 to ₹1,799 per session. All `[E]`, GST unresolved.
- **Entry offer:** two-week Care Trial, ₹5,499 for 6 trips.
- **Gate before any money from families:** a written handover protocol from at least two centres, a passed shadow run, and CA and lawyer answers.

### 9.3 Future service roadmap

| Order | Service | Trigger |
|---|---|---|
| 1 | Dialysis visits | Now (Phase 0 then 1) |
| 2 | Other medical visits: chemotherapy day care, radiotherapy, physiotherapy, OPD | Phase 1 gate met, each service with measured economics |
| 3 | Everyday companionship, short home visits | Phase 2 evidence, safeguarding policy for home visits |
| 4 | Long visits and day outings | Three clean months, outing insurance, risk-assessment process |
| 5 | Assisted journeys and overnight | Partners or a proven supervised model, labour review, your sign-off |

### 9.4 Practical pitch

**To an adult child (30 seconds):**
> "AnugaCare is a trusted companion service for older parents. We start with dialysis. A trained, ID-checked companion takes your parent to the centre, hands them to the centre team, and brings them home, so you get your six to seven hours back on dialysis days. They are not nurses and do not give medical care. Try us for two weeks: six trips, you can stop any time and unused trips are refunded. Over time the same team will be there for other hospital visits, and for company at home."

**To an older customer:**
> "We are people you can rely on to go with you, so you can stay independent and your family can stop worrying. You choose, and we always speak to your family too."

**To a hospital or dialysis centre (30 seconds):**
> "We are not asking for endorsement. We would like a written handover protocol that works for your staff: registered companions with ID and the family's written authorisation, on-time arrival, a named staff handover with a timestamp, and an incident log. They do no clinical tasks. It costs you nothing, we pay no referral fees, and you can stop at any time. We would like to pilot with three to five of your patients for four weeks and share reliability numbers monthly."

**One-line master pitch:**
> "AnugaCare: someone you trust, beside the people you love."

### 9.5 Decisions I need from you
1. Approve the "narrow operations, broad brand" approach and the five-phase gates.
2. Choose the trial price test: ₹5,499 or ₹4,999.
3. Brand and line names: placeholders for now; trademark check and naming are yours.
4. Whether to ask centres for the written protocol first (recommended) or run interviews first.
5. Whether to approach a broker for insurance quotes per category in parallel.

## 10. Limits

- Everything outside dialysis is hypothesis. Cost floors are lower bounds, not prices. I found no Hyderabad demand or price data for companionship, outings or overnight care; anchors are press or vendor pages.
- Insurance premiums, labour-law application to these services, and the Telangana gig-workers Act's reach are `[I]`.
- The dialysis scenario inputs (shift times, delay sizes, conversion and retention) are `[E]`.
- Loneliness figures from Indian ageing data show risk, not willingness to pay, and definitions differ between studies.
- Sources: [LASI loneliness studies](https://www.ijcmph.com/index.php/ijcmph/article/download/15298/9129/76521), [Hyderabad senior living, Hans India](https://assets.thehansindia.com/business/hyds-senior-living-sector-tests-intl-standards-claims-and-affordability-1025339), [Vera Vita Living](https://telanganatoday.com/vera-vita-living-enters-indias-premium-senior-living-sector-with-hyderabad-project), [Serene Communities](https://www.constructionworld.in/latest-construction-news/real-estate-news/serene-communities--prathima-group-invest-rs-4-billion-in-hyderabad-/80735), [Synergia on paid companions](https://www.synergiafoundation.org/insights/analyses-assessments/companions-seniors), [Samarth](https://care.samarth.community/?p=85132), [Maintenance and Welfare Act 2007](https://cleartax.in/s/maintenance-and-welfare-of-parents-and-senior-citizens-act-2007), [Telangana S&E Act overtime summary](https://employmentlaw.lkslaw.com/working-hours), plus the sources in earlier files.
- Nothing here is legal, tax, insurance or clinical advice.
