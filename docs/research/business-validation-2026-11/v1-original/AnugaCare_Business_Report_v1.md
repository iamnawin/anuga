# AnugaCare: Hyderabad Business Viability, Pricing, Operations and Scaling Report

Prepared 11 Nov 2026. Research and planning only: no code written, no repo changes, no outreach, no spending.

**How to read labels.** `[V]` = found in a cited source. `[E]` = my estimate or assumption, built to be edited. `[U]` = could not verify; treat as unknown. Almost everything in the pricing and cost sections is `[E]`, because no public Hyderabad price list exists for this exact service.

---

## 1. Executive recommendation

**Launch, but only as a gated, paid, 90-day pilot. Do not launch "the business" yet.**

- The idea is real and the need is real: dialysis is 2–3 trips a week, forever, and families are often out of the city or at work.
- The economics are **thin and fragile**. My base model clears break-even only if (a) the service fee is about ₹750 per round trip or higher, (b) companions are batched (one companion handles 2+ patients at the same centre and time slot), and (c) nobody sits idle for a 4-hour session.
- The two ways this fails fast: **companions waiting out dialysis sessions** (₹715 of cost per visit vs ₹750 of revenue), and **a price set to look attractive** (at ₹650 the model never breaks even at scale).
- The dialysis-only market may cap out at a few hundred families in Hyderabad. It is the best *entry* market (recurring, predictable, dense around centres) but probably not a big enough *end* market. Plan to extend to other recurring hospital visits.

| Question | Answer |
|---|---|
| Launch? | Yes, as a 90-day paid pilot with kill criteria (section 14). |
| Starting segment | Adult children (out-of-city, NRI, or working couples) of dialysis patients aged 60+, paying privately, attending 2–3 private dialysis centres in one or two adjacent Hyderabad areas. |
| First package | **Monthly Dialysis Companion Plan, 12 round trips**, drop-and-return with centre handover. Not open-ended waiting. |
| Price to test | Service fee **₹799 per round trip** ad hoc; **₹8,499 for 12 trips** (₹708/trip); fare prepaid separately at cost. All `[E]`, ex-GST. |
| Minimum capital | **About ₹6 lakh** for a 15-family, 6-month lean pilot. **About ₹15 lakh** to reach base-case break-even with buffer. |
| Break-even | About 270 visits/month (about 27 families at 10 visits) on the lean cost base; about 930 visits (93 families) on the local-launch base; about 3,270 visits (about 327 families) at city scale. Blended base-case projection breaks even around month 15. |
| Next 7 days | Section 16. |

---

## 2. Market opportunity and demand

### What the sources verify

| Fact | Source |
|---|---|
| India has no national renal registry; estimates conflict. About 220,000 new ESRD cases a year (EY-NATHEALTH, cited), 94% of dialysis patients on haemodialysis. | [NATHEALTH dialysis whitepaper](https://nathealthindia.org/wp-content/uploads/2023/01/Dialysis-Whitepaper_241122.pdf) `[V]` |
| Guideline is 3 sessions/week; a 2023 study of 35 private-network centres found 55% prescribed 3/week, 43% twice, 2% once. A NephroPlus study reports 72% opt for lower frequency than prescribed. | [ISN 2023 abstract](https://events.theisn.org/event/session/view/28385); [Financial Express via GlobalDialysis](https://mail.globaldialysis.net/dialysis-world-news/100-dialysis-industry-news/261533798-more-than-72-per-cent-of-dialysis-patients-do-not-undergo-prescribed-treatment-financial-express.html) `[V]` |
| Telangana runs about 102 government dialysis centres for about 7,550 patients, plus about 5,060 Aarogyasri patients in private hospitals. A later report says about 16,500 free-dialysis patients (10,000 government, 6,500 private). | [Telangana Today](https://telanganatoday.com/dialysis-centres-in-telangana-up-102-says-harish-rao); [Deccan Chronicle](https://www.deccanchronicle.com/southern-states/telangana/telangana-expands-free-dialysis-services-1945644) `[V]`, figures from different years |
| 79 more government centres planned, aim of a centre within 20–25 minutes of patients. | [Siasat](https://www.siasat.com/?p=3456438) `[V]` |
| Private dialysis in Hyderabad is quoted at roughly ₹1,600–₹4,000 per session. A 2022 Banjara Hills hospital cut its price to ₹1,400, saying corporate hospitals usually charge ₹3,000+. | [NephroPlus cost guide](https://nephroplus.com/blogs/understanding-the-cost-of-kidney-dialysis-in-india); [Telangana Today](https://telanganatoday.com/hyderabads-century-hospitals-slashes-single-dialysis-session-to-rs-1400); [Pace Hospital](https://pacehospital.com/dialysis-package-offers) `[V]`, marketing pages |
| Telangana's 60+ share is about 9–11% today, projected 12.5% (2026) to 17.1% (2036). | [The South First](https://thesouthfirst.com/news/telangana-projected-to-see-25-percent-decline-in-newborns-82-percent-surge-in-80-population-by-2036); [Siasat/UNFPA](https://www.siasat.com/is-hyderabad-population-aging-heres-what-unfpa-report-says-2731616) `[V]`, sources disagree |
| **Watch item:** a 9 Nov 2026 report says private hospitals across Telangana have stopped accepting Aarogyasri/EHS cards over about ₹1,500 crore in pending dues. Effect on dialysis not confirmed. | [Telangana Today tag page](https://telanganatoday.com/tag/Aarogyasri) `[U]` for dialysis impact |

### What I could not find

- A **Hyderabad-only** dialysis patient count. `[U]`
- Any data on how many dialysis patients travel with a paid companion, or how many hospitals/centres restrict outside attendants. `[U]`
- Willingness-to-pay data for escort services. `[U]` This is the single biggest gap; the pilot must produce it.

### Sizing (all `[E]`, built to be edited)

| Step | Estimate | Reasoning |
|---|---|---|
| Hyderabad dialysis patients | 6,000–9,000 | Statewide figures above imply about 12–17k Aarogyasri-funded patients plus unknown cash/insurance patients; I assume Hyderabad holds about half. |
| Who pays privately and uses a private centre | 25–35% | Many are in free government/Aarogyasri slots. |
| Of those, family cannot reliably escort | 30–40% | Out-of-city children, working couples, frail spouses. |
| Of those, willing to pay a stranger-service | 25–35% | Trust barrier is the main limiter. |
| **Realistic serviceable families** | **about 150–500** | Roughly 7,500 × 30% × 35% × 30%. |

**Implication.** Dialysis alone supports a small-to-mid business: a few hundred families. A "city-scale 300–500 families" plan would need a large share of that segment. This is why the recommended path is dialysis first, then other recurring hospital visits (chemotherapy/radiation, physiotherapy, cardiac/diabetic follow-ups) using the same companions.

### Dialysis vs broader elderly hospital companion

| | Dialysis-first | Broad elderly appointments |
|---|---|---|
| Visits per family/month | 8–13 | 1–3 |
| Revenue per family/month | about ₹6,000–₹9,000 | about ₹800–₹2,400 |
| Demand predictability | High, fixed schedule | Low, ad hoc |
| Batching potential | High (same centre, same shift) | Low (scattered hospitals) |
| Addressable base | Hundreds of families | Tens of thousands |
| Acquisition | Referral through centres | Expensive, diffuse |
| **Verdict** | Best entry market | Better end market, worse unit economics |

**Recommendation:** enter through dialysis, because recurring schedules are the only thing that makes batching and retention work. Add a "single appointment" product only when companions have spare capacity.

---

## 3. Competitor and substitute comparison

| Player | What they do | Hyderabad price evidence | Gap AnugaCare can use |
|---|---|---|---|
| [CARESY](https://ascendants.in/the-ascendants/caresy-hospital-companion-service-india/) | "Hospital companion platform": queue, department guidance, reports, on-ground support. App launched Sept (year per source). | `[U]` | Hospital-visit generalist; no evidence of recurring dialysis or home-to-home handover. City coverage `[U]`. |
| [Buddy Mobility Care](https://yourstory.com/2025/07/buddy-mobility-assisted-care-transport) | Transport plus caregiving for elderly/disabled, listed in Hyderabad, Bengaluru, Delhi NCR, Chandigarh. | `[U]` | **Closest direct competitor.** Study their pricing first. |
| [Aayacare](https://www.deccanherald.com/india/karnataka/bengaluru/new-service-taking-patients-to-hospital-1193643.html) | Hospital visit assistance plus transport (Bengaluru). | `[U]` | Not Hyderabad; status unclear. |
| [Samarth](https://care.samarth.community/long-distance-care-giving/elder-care-cost-hyderabad/) | Elder care for families abroad, attendants, companion for local transport. | Part-time attendant ₹12,000–₹25,000/month, 24/7 rotating ₹55,000–₹75,000 (national figures) | Overlaps the NRI-child segment. They sell hours, not dialysis reliability. |
| [Portea](https://portea.com/elder-care/hyderabad), [HCAH](https://www.hcah.in/caregiver/hyderabad/), [MedifyHome](https://medifyhome.com/?p=594612) | Home attendants and nursing. | HCAH from ₹1,000/day; MedifyHome listing ₹1,150 (unit unclear), ₹3,500/day for 24h critical nursing | Home-bound care; not trip-based. |
| Anvayaa, Life Circle (Hyderabad) | Elder care; named in a startup list. | `[U]` | Not verified as escort providers. |
| Hospital ward-boy/attender listings | Informal labour. | ₹10,000–₹21,000/month (not Hyderabad-specific) via [IndiaMART](https://m.indiamart.com/impcat/ward-boy-service.html) | The price anchor families will compare you to. |

**Substitutes that matter most (and are free or near-free):** a family member taking leave; a household driver; an existing domestic helper; the dialysis centre's own staff; a neighbour; the patient travelling alone by auto. Your real competitor is "we manage".

**Fare context** `[V]`: Telangana auto meter is ₹30 for the first 1.6 km, then ₹14/km, 1.5× from 11pm–5am ([Deccan Chronicle](https://www.deccanchronicle.com/southern-states/telangana/state-revises-autorickshaw-fares-1992627)). App cabs may surge up to 2× in peak hours ([Telangana Today](https://telanganatoday.com/cab-aggregators-can-charge-up-to-2-times-the-base-fare-during-peak-hours)). Cab per-km rates `[U]`; I assume about ₹18/km plus ₹50 base.

---

## 4. Business model comparison

Ratings are my judgement. Margins are gross margin on service fee before fixed costs, `[E]`.

| Model | Buyer / payer | Revenue | Gross margin | Retention | Ops complexity | Main risk | Verdict |
|---|---|---|---|---|---|---|---|
| A. Pay-per-visit | Adult child pays | ₹799/trip | 40–45% | Low | Medium (unpredictable) | Idle companions, no commitment | Use as entry offer only |
| **B. Monthly dialysis plan** | Adult child pays | ₹8,499/month | 35–40% | **High** | Medium (predictable) | Trust, price | **Start here** |
| C. Prepaid 4/8/12 | Family pays upfront | ₹3,199 / ₹5,899 / ₹8,499 | 33–40% | Medium–High | Medium; refund liabilities | Unused-balance disputes, consumer law | Offer as formats of B |
| D. Elderly appointments | Family | ₹799–₹1,500/visit | 30–40% | Low | High (scattered) | Low frequency | Phase 2 |
| E. Dialysis centre/hospital partnerships | Centre refers; family pays (centre may co-promote) | Same fee, lower CAC | Same | High | Medium | Centre policy on outside attendants `[U]` | **Primary channel, not a revenue model** |
| F. Corporate elder-care benefit | Employer pays | Per-employee annual fee | 50%+ if low utilisation | Medium | Medium | Long sales cycle, tiny utilisation | Phase 3 |
| G. Residential/senior-living | Community or residents | Per-trip or retainer | 35–40% | Medium | Low (dense) | Few dialysis patients per site | Phase 2 channel |

**Best initial model for Hyderabad:** B delivered as a prepaid C pack, sourced through E and family referrals. Everything else waits for evidence.

---

## 5. Proposed pricing (INR)

**Rule used:** price off real cost, then check against what families already pay. All figures `[E]`, ex-GST. **GST is unresolved** (section 12). If 18% applies and you must quote tax-inclusive, ₹799 becomes about ₹677 net, which breaks the model.

**Fare is billed separately, prepaid, at cost.** Reason: fare swings 3–4× with distance, and baking it in forces you to either overcharge short trips or lose money on long ones.

### Service fee (excludes fare)

| Service | Fee | Includes |
|---|---|---|
| One-way accompaniment (≤8 km zone) | ₹449 | Pickup or return, verified handover, family updates |
| **Round trip, drop-and-return (≤8 km zone)** | **₹799** | Home → centre handover, then centre → home. Companion not waiting. Up to 15 min handover buffer each end. |
| Waiting/extended support | ₹180/hour after 30 free minutes | Cost basis is about ₹110/hour loaded. Billed in 30-min blocks. |
| Distance band 8–15 km | +₹120 per round trip | Extra companion time |
| Distance band >15 km | Case by case | Likely out of pilot scope |
| 4-trip pack | ₹3,199 (₹800/trip) | Valid 30 days |
| 8-trip pack | ₹5,899 (₹737/trip) | Valid 45 days |
| **12-trip monthly plan** | **₹8,499 (₹708/trip)** | Valid 35 days, named primary companion where possible |
| Cancellation, more than 12 h before | Free; reschedule free | |
| Cancellation, 2–12 h before | 50% of fee | Companion is committed |
| Cancellation, under 2 h or no-show | 100% of fee | |
| Companion no-show | Trip free, ₹150 credit | Service guarantee |

### Fare estimate (prepaid, pass-through) `[E]`

| Distance (one-way) | Round-trip cab estimate (₹50 base + ₹18/km) |
|---|---|
| 4 km | about ₹244 |
| 8 km | about ₹388 |
| 12 km | about ₹532 |
| 18 km | about ₹748 |

### What a family pays and whether that is plausible

12 round trips of 8 km: ₹8,499 + about ₹4,700 fare = **about ₹13,200/month**. Against private dialysis at ₹1,600–₹4,000/session × 12 = ₹19,000–₹48,000/month, the escort adds 28–70%. That is affordable for upper-middle-income families and a real stretch for others. Pilot evidence will tell; do not assume it.

**Verified market anchors:** attendant ₹1,000+/day (HCAH), ₹12,000–₹25,000/month part-time (Samarth, national). At ₹708/trip you sit between a bare ward-boy and an agency; you must justify it with verified pickup, structured handover and family visibility.

---

## 6. Companion workforce economics

### Inputs

- **Verified:** Telangana unskilled minimum wage for Zone I (municipal corporations, which should include Hyderabad, my inference) rose from ₹12,750 to **₹16,000/month (about ₹615/day) from 1 June 2026** ([The South First](https://thesouthfirst.com/telangana/telangana-revises-minimum-wages-for-unskilled-workers-from-₹12750-to-₹16000); [WageIndicator](https://wageindicator.org/ai/work/minimum-wage/countries/india/21802-telangana/55564-zonei-municipal-corporations-notified-scheduled-employments/)). Over 26 days × 8 hours that is about ₹77/hour floor.
- **Estimate:** a trustworthy, trained companion will need ₹18,000–₹22,000/month. Loaded with statutory on-costs, about ₹110/hour.

### Staffing models

| | Employee | Independent contractor / per-task | Staffing agency partner |
|---|---|---|---|
| Control over quality | High | Low–medium | Low |
| Cost when idle | You pay | Companion bears it (but quits) | Agency margin 15–25% `[E]` |
| Legal exposure | Statutory obligations (PF/ESI/gratuity thresholds apply) | **Misclassification risk** if you set schedules and uniform | Principal-employer liability can remain |
| Reliability | Best | Weakest, no-shows | Medium |
| Gig-law exposure | None | Telangana's gig-worker bill proposes a 1–2% welfare fee on payouts; **status unconfirmed** ([PRS draft](https://prsindia.org/bills/states/the-draft-telangana-gig-and-platform-workers-registration-social-security-and-welfare-bill-2025)) | None |

**Recommendation for the first 20 families:** 3–5 part-time companions on **fixed-term engagement with a per-visit rate and a minimum monthly guarantee**, drafted by an employment lawyer. Treat the legal form as `needs professional review` (section 12). Do not call this a gig platform until a lawyer confirms it.

### Per-visit pay used in the model `[E]`

- Single-patient trip: ₹300 (about 2.5 hours incl. companion's own transport and slack).
- Batched trip (2+ patients on one run): ₹230.
- Plus 10% idle/guarantee buffer.

### Why waiting-in-place is fatal

| Option | Companion cost per visit | Margin at ₹799 |
|---|---|---|
| Wait through a 4-hour session | 4 h wait + 2.5 h travel × ₹110 = **₹715** | Negative after other costs |
| Drop-and-return, single patient | about ₹330 | Healthy |
| Drop-and-return, batched | about ₹255 | Best |

So the product design is: **hand over to the dialysis centre's staff at the door, leave, return for pickup.** This depends on the centre accepting the handover (`[U]`, pilot test) and on the family accepting that you are not sitting in the unit.

### Recruitment, vetting, training `[E]`

- Channels: nursing and paramedic institutes' lower-tier graduates, ex-hospital ward staff, women re-entering the workforce via local NGO networks, senior-care agency referrals. Referral from existing good companions is the best channel.
- Vetting: identity and address verification, police verification (via an accredited background-check vendor), two references, a character interview. About ₹1,500–₹2,500 per companion.
- Training: 2–3 days: patient handling and safe transfers, basic first aid/CPR, dialysis-patient do's and don'ts (non-clinical: no medication handling, no fistula-arm pressure), OTP/handover protocol, family communication, escalation. About ₹3,000–₹4,000 per companion including a course fee.
- Insurance: personal accident cover for companions and liability cover for the company (premiums `[U]`, get quotes).

---

## 7. Per-visit unit economics (base case, ₹799 list, ₹750 realised after packs)

| Line | Lean (15 fam) | Local (75 fam) | City (400 fam) |
|---|---|---|---|
| Customer service fee, realised | 750 | 750 | 750 |
| Companion pay | 290 | 276 | 262 |
| Idle/guarantee buffer | 29 | 28 | 26 |
| Payment processing (2% of fee + fare) | 23 | 23 | 23 |
| Support/dispatch, variable | 30 | 30 | 30 |
| Insurance per visit | 15 | 15 | 15 |
| SMS/WhatsApp/maps | 8 | 8 | 8 |
| Vetting + training amortised | 12 | 12 | 12 |
| Cancellation/no-show leakage (5%) | 38 | 38 | 38 |
| **Total variable cost** | **444** | **429** | **413** |
| **Contribution per visit** | **₹306 (41%)** | **₹321 (43%)** | **₹337 (45%)** |
| Batching share of visits | 15% | 35% | 60% |

Fare is excluded from revenue and cost because it is prepaid pass-through. The 2% processing on fare is included.

### Sensitivity (contribution per visit at 75 families, base ₹321)

| Change | New contribution | Change |
|---|---|---|
| Companion pay +20% | ₹261 | −₹60 |
| Price ₹650 instead of ₹750 | ₹228 | −₹93 |
| Price ₹850 | ₹414 | +₹93 |
| Cancellation leakage 10% | ₹284 | −₹37 |
| No batching at all | ₹295 | −₹26 |

**Price is the strongest lever; batching is smaller than expected at this scale; wages matter next.** The failure scenario is price pressure plus wage pressure together.

---

## 8. Initial capital and monthly operating budget

### One-time setup (lean pilot) `[E]`

| Item | ₹ |
|---|---|
| Incorporation, consent/terms templates, contractor agreements | 60,000 |
| Brand, simple website, WhatsApp Business setup | 40,000 |
| Recruitment, vetting, training for 5 companions | 40,000 |
| Insurance first premiums | 30,000 |
| Phones, ID kit, safety kit | 40,000 |
| First-aid/CPR and senior-care course for team | 40,000 |
| Pilot materials, partner meetings | 30,000 |
| Contingency 15% | 48,000 |
| **Total** | **about ₹3.3 lakh (model uses ₹3.5 lakh)** |

Local-launch setup about ₹8–10 lakh and city-scale about ₹30–40 lakh are rougher `[E]` (more vetting, a second location, tech hardening).

### Monthly fixed costs `[E]` (companion pay is variable, see section 7)

| Item | Lean (15 fam) | Local (75 fam) | City (400 fam) |
|---|---|---|---|
| Operations/dispatch and supervision | 25,000 | 130,000 | 355,000 |
| Customer support | in ops | 22,000 | 120,000 |
| Founders' pay | 0 (unpaid) | 40,000 | 120,000 |
| Product/tech | in software | in software | 100,000 |
| Software, hosting, SMS | 6,000 | 12,000 | 50,000 |
| Insurance | 10,000 | 25,000 | 90,000 |
| Legal and accounting | 8,000 | 15,000 | 40,000 |
| Marketing/acquisition | 25,000 | 30,000 | 140,000 |
| Rent, misc | 8,000 | 25,000 | 85,000 |
| **Total** | **about ₹82,000** | **about ₹299,000** | **about ₹1,100,000** |

### Scenario summary (base case)

| | Lean pilot | Local launch | City-scale |
|---|---|---|---|
| Paying families | 15 | 75 | 400 |
| Visits/month (10 per family) | 150 | 750 | 4,000 |
| Revenue (service fee) | ₹1.13 L | ₹5.63 L | ₹30.0 L |
| Contribution | ₹0.46 L | ₹2.41 L | ₹13.5 L |
| Fixed costs | ₹0.82 L | ₹2.99 L | ₹11.0 L |
| **Monthly result** | **−₹0.36 L** | **−₹0.58 L** | **+₹2.5 L** |
| Break-even visits/month | 268 (27 families) | 930 (93 families) | 3,266 (327 families) |
| Cash runway on ₹6 L (lean) | about 6 months after setup | n/a | n/a |

Honest reading: **a 15-family pilot does not make money**; it buys evidence. The first profitable point is around 90–100 families if overhead stays at local-launch levels.

---

## 9. First 100 customers: acquisition plan

CAC and conversion figures are **experimental assumptions `[E]`**. I found no Indian benchmark for this service.

| Channel | Est. CAC (₹) | Lead→paid | Lead quality | Effort | Trust-building | Scale |
|---|---|---|---|---|---|---|
| **Dialysis centre partnerships** | 500–1,500 | 20–35% | High | High, slow start | Staff endorsement is the trust | Medium |
| **Nephrologist/hospital referrals** | 300–1,000 | 25–40% | Highest | High | Doctor's word | Medium |
| **Family referrals** | 0–500 (credit) | 40–50% | High | Low | Built-in | Grows over time |
| Senior communities/RWAs | 800–2,000 | 5–10% | Medium | Medium | Talks, camps | Low–medium |
| Apartment associations | 1,000–2,500 | 3–8% | Medium | Medium | Low | Low |
| Google Search/Maps, local SEO | 1,500–3,500 | 8–15% | Medium–High (intent) | Low | Reviews needed | Medium |
| WhatsApp Business | 200–800 (follow-up) | 15–25% | Depends on source | Low | Fast replies matter | Supports others |
| Facebook/Instagram ads | 3,000–6,000 | 2–5% | Low–medium | Medium | Hard for health trust | High, poor fit |
| Corporate benefits | 5,000+ | slow | Medium | Very high | Procurement | Phase 3 |

**Test first (the three):**
1. **Dialysis centre and nephrologist partnerships**, because a doctor's or centre's recommendation is the only thing that converts a trust-driven purchase. Start with 2–3 private centres in one micro-market.
2. **Family referrals** with a credit (e.g., one free trip after the referred family's first month). Cheap, high conversion.
3. **Google Business Profile plus WhatsApp**, to capture families already searching, once you have 5–10 happy customers for reviews.

**Path to 100 families:** 3 centres × 6 families = 18 (months 1–3); referrals and Google add about 25 (months 3–6); 2 more clusters add about 40 (months 6–10); referrals add the rest. If you are not at 15 paying families by day 90, do not scale (section 14).

### Draft messages (for your review; nothing has been sent)

**Partnership pitch to a dialysis centre manager**
> Namaste. We are AnugaCare, a non-clinical companion service for dialysis patients: we collect the patient from home, hand them to your front desk, and bring them back after the session, with the family updated at each step. We do not touch treatment, medication or records. We would like to run a 6-week trial with 5–6 of your patients whose families cannot escort them. We will follow your arrival and handover rules, share every incident with you, and stop at your word. May we meet for 20 minutes?

**Message to a family (WhatsApp)**
> Hello, this is [Name] from AnugaCare. We help families who cannot be with a parent on dialysis days. A trained, verified companion collects your parent, hands them to the centre staff, and brings them home safely. You get a message at pickup, handover and arrival, and the pickup is confirmed with a one-time code that only you and the companion see. First two trips are at a trial rate. Would a 10-minute call this week be useful?

**Doctor/centre one-liner**
> If a patient's family cannot accompany them, you can give them our number. We do not provide medical care; we get them to and from your centre on time.

Do not send any of these until you approve and have fixed your consent and data-handling text.

---

## 10. Operations and safety framework (first 20 families)

Principle: **humans do judgement; the app records and nudges.** Per the repo notes, AnugaCare already has Family, Companion and Ops roles, a trip state machine, OTP-verified pickup, a family timeline, and notification and payment flows in test mode; production, real data and paid providers are still gated. Treat anything beyond that as manual until built. I have not verified individual app screens beyond the project notes.

| Process | Who | Rule | App support |
|---|---|---|---|
| Onboarding and consent | Ops (human) | Written family consent plus patient consent where able; emergency contact; named doctor/centre; consent to share status with family | Consent capture exists in the data model per project notes; wording needs legal review |
| Eligibility | Ops, with a checklist | Accept: stable, ambulatory or wheelchair-transferable, cognitively able to follow simple instructions. Decline: oxygen-dependent, unstable, needing lifting or medical care in transit | Not an app feature; manual screening |
| Companion selection | Ops lead | Vetting plus trial trips with a supervisor before solo duty | Manual |
| Scheduling | Ops | Fix recurring slots per centre; batch by centre and shift; name a primary and a backup companion | Ops console and trip creation exist per notes; batching logic is **not** assumed |
| Pickup | Companion | Arrive in window; OTP confirms pickup | Supported (OTP-verified pickup) |
| Centre check-in/handover | Companion and centre staff | Hand patient to named staff member; photo of handover only if centre allows `[U]` | Status step in timeline |
| Waiting/delays | Ops | Family alert if more than 15 minutes late; extended-support fee only with consent | Manual alerts unless built |
| Return | Companion | Collect on staff release; check patient's condition at pickup | Timeline updates |
| Emergency | Companion then Ops | Call the centre/ambulance (108), then the family; companion does not treat; incident log within 24 hours | Manual protocol; run a drill |
| Companion late/absent | Ops | Backup companion within 20 minutes; otherwise refund the trip and credit | Manual |
| Complaints/refunds/disputes | Ops lead | Acknowledge in 4 hours, resolve in 3 days, founder reviews every incident | Manual |
| Family communication | App and Ops | Updates at pickup, handover, return; weekly summary | Notifications exist in test mode; WhatsApp is not assumed |
| Quality monitoring | Ops | Weekly review of on-time %, complaints, repeat rate; monthly family call | Manual dashboards |

**Hard rules for the pilot:** no medication handling, no vehicle driven by AnugaCare staff, no patient ever left unattended at a door, and a written stop-rule list.

---

## 11. Differentiation

What a competitor cannot copy quickly: **local density** (companions clustered at specific centres and shifts), **centre trust relationships**, a **named recurring companion**, and **reliability data** on on-time pickup and handover. What they can copy in a month: price, a booking app, "verified companions" marketing, OTP pickup, family updates.

**Defensible value proposition:** "For the same 3 trips a week, the same trusted person gets your parent to the centre and home, and you can see it happen." Its moat is operational discipline and centre relationships, not software.

---

## 12. Legal, insurance and compliance (research flags, not legal advice)

| Topic | Status |
|---|---|
| **Business registration** | Likely a private limited company or LLP; also shops-and-establishment registration, PAN/TAN `needs professional review` |
| **DPDP** | Rules notified 14 Nov 2025; sources point to full consent/notice/breach duties from about **14 May 2027** after an 18-month phase-in ([Tribune](https://www.tribuneindia.com/news/business/govt-notifies-digital-personal-data-protection-rules-rollout-in-phases-specified-obligations-for-data-fiduciaries); [YourStory](https://yourstory.com/2025/11/digital-personal-data-protection-dpdp-rules-2025-rollout-over-18-months)). I found nothing on health-data treatment. **Design to comply now** and treat patient data as highly sensitive. |
| **GST** | `[U]`. Healthcare services by clinical establishments are exempt, but I found no ruling on a standalone companion service. Staff-supply style services are taxable at 18% in some commentary. Get a CA opinion or an advance ruling before pricing publicly. Registration threshold is likely crossed in year 1 under the base case. |
| **Employment/contractor** | Misclassification risk; Telangana's gig bill reached cabinet but final enactment `[U]` ([PRS](https://prsindia.org/bills/states/the-draft-telangana-gig-and-platform-workers-registration-social-security-and-welfare-bill-2025)). `needs professional review` |
| **Background verification** | Use an accredited vendor; keep records per DPDP |
| **Healthcare-adjacent liability** | Do not describe companions as nurses or clinical staff; contract language and consent forms must say non-clinical. `needs professional review` |
| **Insurance** | Seek quotes for general/third-party liability, professional indemnity, personal accident for companions, cyber. Premiums `[U]`. |
| **Consumer protection** | Clear cancellation and refund terms; prepaid pack refund policy |
| **Transport** | Use licensed commercial vehicles or aggregator rides only; companions should not carry patients on private bikes. Vehicle liability sits with the operator; confirm indemnities in writing. `needs professional review` |
| **Hospital/centre policy** | Whether centres allow outside escorts, handover, and photos is `[U]` and decides the model |

Budget about ₹60,000 up front and ₹8,000/month for a lawyer and CA relationship, as in section 8.

---

## 13. Projections (24 months, editable assumptions)

Assumptions: 10 visits per family per month (8 conservative, 11 optimistic); realised fee ₹690 / ₹750 / ₹790; companion pay 15% above/at/below base; leakage 8% / 5% / 4%; fixed costs follow the section 8 curve; setup ₹3.5 L; fare is prepaid pass-through. All `[E]`.

| Month | Cons. families | Cons. net (₹k) | Base families | Base net (₹k) | Base cum. cash (₹k) | Opt. families | Opt. net (₹k) |
|---|---|---|---|---|---|---|---|
| 3 | 10 | −60 | 15 | −36 | −482 | 20 | −20 |
| 6 | 18 | −65 | 32 | −44 | −608 | 50 | −2 |
| 9 | 25 | −81 | 50 | −51 | −754 | 80 | +26 |
| 12 | 45 | −122 | 100 | −38 | −900 | 150 | +155 |
| 15 | 58 | −147 | 150 | +4 | −931 | 225 | +300 |
| 18 | 70 | −172 | 200 | +48 | −832 | 300 | +452 |
| 24 | 90 | −195 | 300 | +143 | −218 | 450 | +887 |

| | Conservative | Base | Optimistic |
|---|---|---|---|
| Year-1 revenue (service fee) | ₹13.7 L | ₹36.9 L | ₹65.2 L |
| Year-1 net | −₹9.2 L | −₹5.5 L | +₹2.6 L |
| Year-2 revenue | ₹46.8 L | ₹187.5 L | ₹325.9 L |
| Year-2 net | −₹20.3 L | +₹6.8 L | +₹59.6 L |
| Break-even month | **never** | **15** | 7 |
| Peak cash need (incl. setup) | **₹33 L** | **₹9.3 L** | ₹4.6 L |

**Read this honestly:** the conservative case is the signal to stop, not to fund. The base case pays back slowly (still −₹2.2 L cumulative at month 24). The optimistic case needs 450 families, which is likely above the dialysis-only market (section 2).

Rebuild the model in a spreadsheet using the section 7 and 8 tables; every number above is an input.

---

## 14. Risks, validation experiments, and kill criteria

| Risk | Why it matters | Experiment | Pass / fail (starting hypotheses `[E]`) |
|---|---|---|---|
| Families will not trust a stranger | Primary demand risk | 10 interviews plus 15-family paid trial | 15 paying families in 90 days; 60%+ repeat after trial |
| Centres refuse outside escorts or handover | Breaks drop-and-return | Visit 5 centres, ask in writing | At least 2 centres agree to a named handover |
| Waiting-time cost | ₹715/visit if waiting | Time-and-motion on 30 trips | Average companion time under 2.5 h/visit |
| Low margin | Price and wage | Test ₹699 vs ₹799 vs ₹899 | Realised price ≥ ₹750 with 50%+ acceptance |
| Price sensitivity | Dialysis already costs a lot | Ask for a deposit on the plan | 40%+ of interviewed qualified families take a paid trial |
| Recruitment reliability | Ruins trust | Recruit 8 for 4 slots | No-show under 2%, replacement under 20 minutes |
| Scheduling inefficiency | Kills batching | Map patients by centre/shift | At least 30% of trips batchable |
| Medical emergency | Liability | Run a drill; check insurance | Incident protocol signed off; cover quoted |
| Low volume | Dialysis-only cap | Count qualified families per centre | At least 40 qualified families across 3 centres |
| Regulatory (GST, labour) | Margin shock | CA and lawyer opinions | Written opinion before launch |

**Stop or pivot if by day 90:** fewer than 10 paying families; or on-time pickup below 90%; or contribution per visit below ₹150; or centres block handover. In that case test the broader elderly-appointment or senior-community models instead.

---

## 15. Scaling roadmap

| Phase | Move when (metric gate) |
|---|---|
| 1. Hyderabad pilot (one micro-market, 15–30 families) | n/a |
| 2. More Hyderabad zones | Contribution per visit ≥ ₹250 for 3 months; on-time pickup ≥ 95%; 60%+ repeat; companion utilisation ≥ 55%; complaint rate under 2 per 100 visits; CAC payback under 3 months |
| 3. Other Telangana cities (e.g., Warangal, Karimnagar) | Hyderabad profitable at the local-launch level; a repeatable playbook; a local centre partner before launch |
| 4. Bengaluru, Chennai, Pune | Positive unit economics for 6 months; local operations lead; a funded plan; competitors there checked first (Buddy Mobility Care and others) |

**Starting-hypothesis thresholds `[E]`:** utilisation 55–65%; 9–11 visits/family/month; repeat booking 70%+; on-time 95%; cancellation under 8%; CAC under ₹3,000; contribution ₹250+/visit; payback under 4 months; referral rate 20%+ of new families; incident rate under 1 per 500 visits; LTV about ₹25,000+ (contribution ₹300 × 10 visits × 8+ months).

---

## 16. Funding strategy and the 30/60/90 plan

**Funding.** Do not raise venture money now. The pilot needs about ₹6 lakh; the base case needs about ₹15 lakh with buffer. Best default is **bootstrapping plus customer prepayment**, because prepaid packs fund working capital. Then:

| Option | Fit |
|---|---|
| Bootstrap/prepaid revenue | Best now |
| DPIIT recognition (free; tax and compliance benefits; [Startup India playbook](https://www.startupindia.gov.in/content/dam/invest-india/HomePage/Startup-Playbook-Exclusive-Benefits-for-DPIIT-Recognised-Startups-in-India-April-2026.pdf)) | Do now; check eligibility |
| T-Hub, Telangana programmes (e.g., [TISC 2026](https://www.startupgrantsindia.com/tisc-telangana-innovation-startup-challenge-2026), applications reported to close **20 Nov 2026**, eligibility `[U]`) | Worth a look this week |
| Angels | After evidence: 50+ paying families, 70% repeat, contribution ≥ ₹250/visit |
| Dialysis/hospital partnership funding | Possible later, but beware dependence |

Verify all programme terms on official sites; most of what I found is from aggregators.

### 30 / 60 / 90 days

| Days | Actions |
|---|---|
| **1–30** | 20 family and 5 centre interviews. Lawyer, CA and insurer meetings. Decide staffing form. Draft consent, terms, protocols. Recruit and vet 5 companions. Price test conversation (₹699/799/899). |
| **31–60** | Sign 2–3 centre partners. Train and run 10–15 trial trips with supervisors. Onboard 8–10 paying families. Time-and-motion study. |
| **61–90** | Reach 15 paying families. Test the 12-trip plan. Collect referrals. Hold the day-90 review against the section 14 gates. |

---

## 17. Conclusion

- **Should we launch?** Yes, as a gated paid pilot. Not as a full launch.
- **Segment:** adult children of privately treated dialysis patients, 60+, near 2–3 centres in one micro-market.
- **Package:** 12-trip monthly dialysis plan, drop-and-return.
- **Price to test:** ₹799/trip, ₹8,499/12 trips, fare prepaid at cost. Test ₹699 and ₹899 in interviews.
- **Capital:** about ₹6 lakh to prove it; about ₹15 lakh to reach break-even in the base case.
- **Break-even bookings:** about 270 visits/month at lean costs; about 930 at local-launch costs; about 3,270 at city-scale costs.

### Your next seven days

1. Call or message 10 families you can reach through existing contacts, and ask about escorts, cost and trust. Do not pitch yet.
2. Visit 3–5 private dialysis centres in one area and ask in person what they allow.
3. Ask Buddy Mobility Care and CARESY for a customer-style quote to price against.
4. Book 30 minutes each with a CA (GST) and a lawyer (contractor vs employee, consent).
5. Get 2 insurance quotes.
6. Check DPIIT recognition and the TISC deadline of 20 Nov 2026.
7. Open the spreadsheet model and replace my estimates with whatever you learned. Review before any outreach.

---

### Source list and caveats

Sources: [NATHEALTH](https://nathealthindia.org/wp-content/uploads/2023/01/Dialysis-Whitepaper_241122.pdf), [ISN 2023](https://events.theisn.org/event/session/view/28385), [Telangana Today (dialysis)](https://telanganatoday.com/dialysis-centres-in-telangana-up-102-says-harish-rao), [Deccan Chronicle](https://www.deccanchronicle.com/southern-states/telangana/telangana-expands-free-dialysis-services-1945644), [NephroPlus](https://nephroplus.com/blogs/understanding-the-cost-of-kidney-dialysis-in-india), [The South First](https://thesouthfirst.com/news/telangana-projected-to-see-25-percent-decline-in-newborns-82-percent-surge-in-80-population-by-2036), [Samarth](https://care.samarth.community/long-distance-care-giving/elder-care-cost-hyderabad/), [HCAH](https://www.hcah.in/caregiver/hyderabad/), [CARESY](https://ascendants.in/the-ascendants/caresy-hospital-companion-service-india/), [Buddy Mobility](https://yourstory.com/2025/07/buddy-mobility-assisted-care-transport), [Telangana minimum wage](https://thesouthfirst.com/telangana/telangana-revises-minimum-wages-for-unskilled-workers-from-₹12750-to-₹16000), [DPDP Rules](https://www.tribuneindia.com/news/business/govt-notifies-digital-personal-data-protection-rules-rollout-in-phases-specified-obligations-for-data-fiduciaries), [Telangana gig bill](https://prsindia.org/bills/states/the-draft-telangana-gig-and-platform-workers-registration-social-security-and-welfare-bill-2025), [Startup India](https://www.startupindia.gov.in/content/dam/invest-india/HomePage/Startup-Playbook-Exclusive-Benefits-for-DPIIT-Recognised-Startups-in-India-April-2026.pdf).

**Limits of this research.** I ran about 13 targeted searches, not a full primary-source review. I did not read full text of PDFs, and several figures come from vendor marketing pages and news summaries. I did not verify competitor prices, hospital escort policies, cab per-km rates, GST treatment, DPDP health-data treatment, insurance premiums, or enactment of the Telangana gig law. I did not use specialist subagents; all analysis was done inline. The financial model script is at `/tmp/claude-0/-home-user-anuga/16af7077-7bd0-5d63-8bd6-60700473ec07/scratchpad/model2.py` and all its inputs are editable.
