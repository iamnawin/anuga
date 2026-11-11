# AnugaCare business model validation, round 2

Date: 2026-11-11. Builds on `v1-original/AnugaCare_Business_Report_v1.md` and `v1-original/model_v1b_750_original.py` (both preserved unchanged, SHA-256 in `CHECKSUMS.txt`).
Calculations: `model_v2_sensitivity.py` → `model_v2_results.md` (re-run to reproduce).

Labels: `[V]` found in a source, `[E]` my estimate, `[U]` unverified or not found, `[I]` only a founder interview or a centre/CA/lawyer conversation can settle it.
No outreach, spend, code or repo change was made. Nothing here has been sent to anyone.

---

## 0. The short answer on ₹799

**₹799 is not a safe price for the model as written. It is a workable price only for a small, tightly run pilot, and it stops working as you grow.**

- v1 said contribution is **₹306 per visit (41%)** at pilot size. With the costs v1 left out, my v2 base is **₹189 (26%)**. The honest range is **₹30 to ₹324**, depending mostly on what you pay companions.
- Cause 1, **companion pay**: v1 paid ₹300 and assumed that covered the companion's own travel. A drop-and-return trip has two solo legs for the companion. I used ₹380 (₹300 plus about ₹80 commute). This one assumption moves contribution by ₹170.
- Cause 2, **package discount**: the ₹8,499 plan is ₹708 per trip, 11% below list. If most families buy it, ₹799 realises about **₹732**, not v1's ₹750.
- Cause 3, **late finishes, failed visits, replacement acquisition cost**: about ₹80 per visit in total.
- **Break-even moves from 268 visits (27 families) to about 423 visits (42 families)** with founders unpaid, and **578 visits (58 families)** if one founder takes ₹30k a month. Section 2 shows why.
- **To restore v1's margin you need roughly ₹899 to ₹999 list**, or ₹799 with companion pay held near ₹330 and no pack discount.
- **GST can erase the margin.** If 18% applies and ₹799 must be tax-inclusive, contribution falls to about ₹84. Restoring ₹200 needs about ₹949 inclusive.
- Whether families will pay ₹899 to ₹999 is `[I]`. No public data answers it. That is what the experiment in section 5 tests.

---

## 1. Price validation (₹799 round trip, ₹8,499 for 12 trips)

### 1.1 What the verified anchors say

| Anchor | Figure | Status |
|---|---|---|
| Private dialysis in Hyderabad | about ₹1,100 to ₹5,500 per session; one centre advertised ₹1,400 | `[V]` Bajaj Finserv Health, Telangana Today |
| Attendant, Hyderabad | from ₹1,000 per day (HCAH); ₹12k to ₹25k per month part-time (Samarth) | `[V]` vendor pages |
| Hospital pick-up and drop, one provider | "starts at ₹750"; it is vehicle service, not medical, and I could not confirm its city | `[V]` weak (drkmcims.com) |
| Hyderabad auto meter | ₹30 for first 1.6 km, ₹14 per km after | `[V]` Deccan Chronicle, date unclear |
| Cab aggregator pay | drivers say ₹12 to 13 per km paid, ask ₹17 to 20; peak pricing up to 2× allowed nationally | `[V]` Telangana Today |
| Payment gateway | Razorpay standard 2% plus 18% GST = 2.36%, even on UPI; UPI itself has zero MDR | `[V]` Razorpay. A claim of new UPI MDR from 15 Oct 2026 is unconfirmed |
| Telangana minimum wage Zone I | ₹16,000 per month from 1 Jun 2026, about ₹77 per hour | `[V]` (round 1) |
| Competitor prices (Buddy Mobility Care, CARESY) | none published | `[U]` |

v1 assumed fare of ₹50 plus ₹18 per km. That sits at the top of the verified range, so the fare estimate is cautious. The service fee, not the fare, is where the risk is.

### 1.2 Per-visit waterfall at ₹799 list, 15 families, no GST charged

| Line (₹ per completed visit) | v1 | v2 conservative | **v2 base** | v2 optimistic |
|---|---|---|---|---|
| Realised fee | 750 | 711 | **732** | 759 |
| Companion pay (incl. own commute) | 290 | 415 | **367** | 319 |
| Waiting for late finishes | 0 | 50 | **33** | 17 |
| Idle/guarantee buffer | 29 | 50 | **29** | 16 |
| Support, insurance, comms, training | 65 | 65 | **65** | 65 |
| Payment fee (2.36% of fee plus fare) | 23 | 27 | **27** | 12 |
| Failed visits (no-shows, company failures, reschedules) | 0 (flat 38 leakage in v1) | 58 | **31** | 19 |
| Replacement acquisition cost (churn × CAC ÷ visits) | 0 | 50 | **18** | 7 |
| Late-cancel fees kept | 0 | +34 | **+28** | +19 |
| **Contribution per visit** | **306** | **30** | **189** | **324** |

At 75 families (more batching): v1 ₹321, v2 conservative ₹54, **v2 base ₹208 (28%)**, optimistic ₹341.
The v2 engine reproduces v1 exactly when set to v1's inputs (₹306, ₹321, ₹337), so the gap is caused by the new cost lines, not a code difference.

How each requested item is handled:

| Item | Treatment in v2 | Basis |
|---|---|---|
| Companion compensation | ₹380 single, ₹293 batched, per visit | `[E]` 3.6 active hours ≈ ₹106 per hour, inside the verified ₹77 to ₹125 per hour band |
| Travel | Fare is prepaid pass-through; companion's own two solo legs are inside pay | `[E]` |
| Waiting between pickups | 20 min late-finish wait at ₹100 per hour plus 8% idle buffer | `[E]` |
| Failed visits | 5% patient late-cancel or no-show (70% of fee collected, ₹150 show-up pay), 3% company failure (free trip, ₹150 credit, replacement at 115% pay), 4% reschedules | `[E]` |
| Cancellations | Fee policy from v1 tiers | `[E]` |
| Payment fees | 2.36% of fee plus fare; direct UPI could be about 0 | `[V]` rate, `[E]` mix |
| Taxes | See 1.4 | mostly `[U]` |
| Support | ₹30 variable plus fixed ops in overhead | `[E]` |

Prudence note: a late cancel earns more than it costs, so in the tornado a higher cancellation rate looks "good". That is an artefact. Collecting no late-cancel fees gives ₹170 at 40 families (₹197 with 70% collected). Use ₹170 as the safe figure.

### 1.3 Price sweep (v2 base, contribution per completed visit)

| List ₹ | Realised ₹ | @15 fam | @40 fam | @75 fam | @40 fam, 18% GST absorbed |
|---|---|---|---|---|---|
| 649 | 595 | 50 | 58 | 69 | −34 |
| 749 | 686 | 142 | 151 | 162 | 44 |
| **799** | **732** | **189** | **197** | **208** | **84** |
| 849 | 778 | 235 | 243 | 255 | 123 |
| 899 | 824 | 282 | 290 | 301 | 163 |
| 949 | 870 | 328 | 336 | 348 | 202 |
| 999 | 916 | 375 | 383 | 394 | 241 |

- List price where contribution hits zero: about ₹590. Where it hits the ₹150 kill line: about ₹755. So **₹799 has only about ₹45 of headroom above the kill line**.
- Companion pay is the biggest lever (₹300 gives ₹282, ₹460 gives ₹112). Package discount is second (₹89 swing), late-finish waiting third (₹58).

### 1.4 Taxes (what is and is not settled)

- GST registration threshold for services is ₹20 lakh aggregate turnover, Telangana included `[V]` (ClearTax, Razorpay, others). Base-case revenue crosses ₹20 lakh inside year 1, so "no GST" is a pilot-only position.
- Whether 18% applies to a standalone companion service, and how the pass-through fare is treated, is `[U]`. **Needs a CA opinion before you publish any price.**
- Gig/aggregator social-security contribution under the Social Security Code: 1% to 2% of turnover, capped at 5% of payouts to gig workers `[V]`. The rate and start date were still awaited in an Oct 2026 source `[V]`; Telangana's state bill is unconfirmed `[U]`. At 2% of fee it is about ₹15 per visit. It only applies if companions are treated as platform workers, which a lawyer must decide.
- Income tax: none while loss-making.

### 1.5 The ₹8,499 monthly package

| 12-trip price | Per trip | Contribution per visit | Margin |
|---|---|---|---|
| ₹7,999 | 667 | 130 | 20% |
| **₹8,499** | **708** | **173** | **24%** |
| ₹8,999 | 750 | 215 | 29% |
| ₹9,499 | 792 | 257 | 32% |
| ₹9,999 | 833 | 299 | 36% |

The plan gives away ₹91 of margin per trip for convenience the family may value anyway. **Do not discount the plan more than about 5%.** A plan near ₹9,499 (about ₹792 per trip) keeps the "named companion, prepaid, priority slot" story without the discount.

### 1.6 What a family actually pays

| List per trip | Fee × 12 | Plus fare ≈ ₹4,700 | Total per month |
|---|---|---|---|
| ₹799 | 9,588 | 4,700 | ≈ ₹14,300 |
| ₹899 | 10,788 | 4,700 | ≈ ₹15,500 |
| ₹999 | 11,988 | 4,700 | ≈ ₹16,700 |

Against a dialysis bill of ₹13k to ₹66k per month (12 × ₹1,100 to ₹5,500), the escort adds roughly 25% to over 100%. `[I]` families decide whether that is worth it.

---

## 2. The 270-visit lean break-even: audit

**Formula in v1:** `break-even visits per month = monthly fixed costs ÷ contribution per visit`, i.e. 82,000 ÷ 306 = 268 visits; 268 ÷ 10 visits per family = 27 families.

| Item | In v1's number? |
|---|---|
| Overhead | **Yes, ₹82,000**: ops/dispatch 25k, software 6k, insurance 10k, legal/accounting 8k, marketing 25k, rent/misc 8k |
| Founder compensation | **No. ₹0.** Founders unpaid |
| Setup costs (₹3.5 L) | No (payback, not monthly) |
| Taxes (GST, income tax) | **No** |
| Acquisition cost | **Partly.** ₹25k per month marketing is in overhead. No replacement cost for families who leave |
| Unused companion capacity | **Only a 10% buffer.** No capacity model |
| Failed visits | Flat 5% of fee |

Problems found:

1. **Internal inconsistency.** v1 divided the ₹82k overhead of 15 families by contribution at 27 families. v1's own cost curve rises to ₹299k at 75 families. Solving for where contribution truly covers that curve gives **about 146 families in v1's own model**, not 27. The lean 27 holds only if overhead stays at ₹82k, meaning founders run operations unpaid and no hire is made.
2. **Costs v1 left out** (section 1) lower contribution by about ₹117.
3. **Salaried capacity.** A salaried companion at ₹20k plus 17.5% on-cost costs ₹691 per visit at pilot density (about 34 visits per month), ₹452 at 2 trips a day and ₹301 at 3 trips a day. The model only works with **per-visit pay and part-time companions** at pilot scale.

### Corrected break-even (contribution at 30 families)

| Cost base | Overhead ₹/mo | Conservative | **Base** | Optimistic |
|---|---|---|---|---|
| F1 v1 lean, founders unpaid | 82,000 | 2,270 visits / 284 fam | **423 / 42** | 250 / 23 |
| F2 plus one founder at ₹30k | 112,000 | 3,101 / 388 | **578 / 58** | 341 / 31 |
| F3 plus two founders at ₹30k | 142,000 | 3,931 / 491 | **733 / 73** | 432 / 39 |
| F4 F2 plus setup repaid over 12 months | 141,167 | 3,908 / 489 | **729 / 73** | 430 / 39 |

### Self-consistent break-even with v1's overhead curve, by list price (v2 base)

| List ₹ | Families to break even | Overhead at that size |
|---|---|---|
| 799 | **483** (effectively beyond the local-launch plan) | ₹11 L |
| 899 | 186 | ₹5.7 L |
| 949 | 111 | ₹3.9 L |
| 999 | 78 | ₹3.1 L |

**Consequence:** v1's "break-even in month 15" in the base case does not survive v2 costs at ₹799 unless overhead is held well below v1's curve. The 24-month ramp is re-run in section 9.

### Pilot cash (rough, `[E]`)

15 families from month 3, six months, contribution ₹189: about ₹1.4 L earned against ₹4.9 L overhead plus ₹3.5 L setup, a need of about **₹7 L** with founders unpaid (v1 said ₹6 L), or about **₹8.8 L** with one ₹30k stipend.

### Where the model still stands up

LTV to CAC is healthy even in tough cases: at 6 months' tenure and ₹6,000 CAC it is 2.2×; at 12 months and ₹3,000 it is 8.6×. Tenure and CAC are both `[I]`.
A Monte Carlo of correlated-in-my-head ranges puts P(contribution > ₹150) at 92% to 99% at ₹799. **Treat that as overconfident**: independent draws average out. When wages, failures and discounts all go wrong together, the conservative corner is ₹30 to ₹54.

---

## 3. Do Hyderabad dialysis centres allow external companions to hand over, leave and return?

### 3.1 Published policy: what exists

**I found no published policy at any Hyderabad centre that permits or forbids an external, non-clinical companion handing a patient to centre staff and leaving.** That includes NephroPlus pages and listings, hospital pick-up pages and government programme news. This is an absence of evidence, not a "yes" or a "no".

| Finding | Status |
|---|---|
| National MoHFW guidance for dialysis during COVID says "dialysis personnel, attendants and caregivers" wear a three-layer mask inside the unit | `[V]` Implies attendants may be present. Era-specific; says nothing about handover or leaving |
| Centre-level visitor rules are set by each unit | `[V]` general statement; no Hyderabad text found |
| NHSRC Operational Guidelines for the PM National Dialysis Programme (July 2026) | **Not read.** The host did not resolve in this session. Check it for visitor, attendant and discharge rules. It likely governs government and PPP centres only `[U]` |
| NephroPlus "Dialysis on Call" and "Dialysis on Wheels" in Hyderabad bring dialysis to the patient | `[V]`. Not an escort policy, but shows centres already solve access problems themselves |
| Telangana free dialysis: 16,500 patients under Aarogyasri (about 10,000 in government hospitals, 6,500 in private); free bus pass for dialysis patients (2019; current terms unverified) | `[V]` Free-travel substitute for lower-income patients, not your target segment |
| Medulance–NephroPlus partnership (2021) | `[V]` ambulance aggregator link; current status unknown |

### 3.2 Needs direct centre confirmation (`[I]`, ask in person, get it in writing)

1. Will staff **release a patient to a named third-party escort** who holds a family-signed authorisation and an OTP or photo-ID match?
2. Who owns the patient between the cab and the chair, and between the chair and the cab? Does the **centre accept "handover at reception"** or require a family member to be inside?
3. May the companion **leave during the session** if a family member is reachable by phone? Must someone stay on premises?
4. **Post-dialysis observation:** how long is a patient observed after a session (blood pressure, access-site bleeding) before discharge, and who is told if something is wrong?
5. What does the centre want **after an incident** (who is called, what is documented)? Does it need your insurance certificate?
6. Is there a **waiting area** and any limit on outside staff?
7. Will it **refer** patients? (Never pay centres for referrals. It creates a conflict and legal risk.)
8. **Shift timings and volumes**, so batching can be planned.

### 3.3 Reasoned (not verified) expectation `[E]`

Dialysis is a clinical session, and patients can feel weak or dizzy afterward. A centre is unlikely to release a patient to a stranger without the family's authorisation and a clear handover. So the realistic design is "authorised escort picks up at a stated time, centre confirms by phone to the family", not "companion drops a patient and disappears". If centres insist on someone staying through the session, the economics change: waiting costs about ₹715 per visit and ₹799 loses money. That is the single biggest go/no-go fact, and it costs nothing to find out.

---

## 4. Controlled market-validation plan (before committing ₹6 L)

Total cash before the pilot decision: **about ₹60k to ₹80k `[E]`**, less any prepaid revenue. Each stage has a gate. Everything below needs your approval before anyone is contacted.

| Stage | Days | What | Cost `[E]` | Gate to continue |
|---|---|---|---|---|
| 0. Interviews | 1 to 10 | 12 to 15 conversations with adult children of dialysis patients aged 60+ (your network, patient support groups, centre introductions you choose). Ask what they do today, what it costs, who escorts, and show three price cards (₹799, ₹899, ₹999 per round trip, fare extra) | ₹0 to 2k | At least 8 of 12 describe a real recurring escort problem; at least 5 would pay at ₹799; at least 3 at ₹899 or more |
| 1. Centre cooperation | 4 to 18 | Visit 4 to 6 centres in one micro-market. Ask the eight questions in 3.2. Request a short written "no objection" (WhatsApp or email) from at least 2 | ₹2k to 5k travel | At least 2 centres accept a named handover in writing. **If none, stop or redesign** |
| 2. Companions and operations | 8 to 28 | Speak to 10 candidates (ex-ward staff, home-care graduates). Offer ₹380 per round trip. Founders do **two shadow runs** (no patient, same route and hours) to time the real minutes against the 215 in the model and record real fares | ₹5k to 10k | At least 4 candidates commit to named shifts at ≤₹400 per trip; shadow-run time ≤ 4.2 h and cab fare within ±20% of ₹388 |
| 3. Paid concierge pilot | 21 to 60 | 3 to 5 families, 4 weeks, hand-run through WhatsApp and UPI with 2 vetted companions. Needs: lawyer-reviewed consent text, accident and liability quotes, written centre OK | ₹30k to 60k before revenue | At least 3 of 5 renew; contribution per visit ≥ ₹150 measured; on-time pickup ≥ 90%; zero safety incidents |

Things only direct conversations can settle `[I]`: willingness to pay at each price; how families currently solve escort; whether a handover is acceptable to the patient; companion pay needed and availability by shift; centre cooperation; how long families stay; whether GST makes the quoted price unworkable (CA); insurer appetite.

---

## 5. The smallest low-cost experiment: a refundable-deposit pre-sale

**Question:** will real families put real money down for a drop-and-return dialysis escort at ₹799 vs ₹899 vs ₹999, before you hire anyone or spend the pilot budget?

**Design (cost ₹0 to ₹2k):**
1. Write a one-page offer: who the service is, the drop-and-return flow, a clear line that companions are **non-clinical**, price per round trip (fare extra, prepaid), a 4-trip starter pack, and a start date at least three weeks out.
2. Show it to **about 30 families who fit the segment**, reached through people you already know or introduced by centres you have visited. Split them into three price cells, ₹799, ₹899 and ₹999 per trip. Use the same page otherwise.
3. Ask for a **refundable ₹500 UPI deposit** to hold a starter-pack slot. Refund in full if you do not launch in the area. Do not collect larger sums until a centre has confirmed handover and a companion is committed.
4. Measure paid deposits per cell, not likes or "interested".

| Result in 14 days | Reading | Next action |
|---|---|---|
| 5 or more deposits across cells, at least 2 at ₹899 or above | Willingness to pay holds above ₹799 | Go to Stage 1 to 3; plan the pilot at ₹899 |
| 5 or more deposits, all at ₹799 | Price ceiling near ₹799; margin is thin | Modify the model (cheaper companion pay, no pack discount) before launch |
| 2 to 4 deposits | Weak | Interview the "no"s; rework segment or offer |
| 0 to 1 | Demand not proven at these prices | Pause |

Caveats: 30 families is small; the same circle tends to say yes to a friend; deposits show intent, not retention. This is a screen, not proof.

---

## 6. Founder decision memo

**Recommendation: choose B. Modify first, then reconsider A.** The numbers say ₹799 can carry a small pilot but not growth, and the single largest unknown (centre handover) is free to test.

| | **A. Launch a limited paid pilot now** | **B. Modify, then pilot** (recommended) | **C. Pause** |
|---|---|---|---|
| Expected cost | About ₹7 L, founders unpaid (₹8.8 L with a ₹30k stipend). v1 said ₹6 L | ₹60k to 80k over 6 to 8 weeks, then A's cost if gates pass | About ₹0 plus founder time and any staging hosting |
| What changes | Nothing | Test ₹899 to ₹999 vs ₹799; plan discount ≤5%; piece-rate part-time companions; centre handover in writing; GST opinion before quoting; overhead capped near ₹112k | Stop active work; keep research and the unused staging build |
| Evidence required before spending | At least 2 centres confirm handover in writing; at least 5 paid deposits; 4 committed companions; CA opinion on GST; lawyer on engagement form; insurance quotes | Same, but obtained in the cheap stages (section 4) | None |
| Financial risk | Lose up to the full ₹7 L. At ₹799 the pilot loses about ₹54k per month at 15 families (v1 estimated ₹36k) and needs 58 families to cover a ₹112k overhead | Capped near ₹80k. Risk of delay and of founder time | Zero cash. Cost is time and lost momentum |
| Stop criteria | By day 60: fewer than 8 paying families; contribution under ₹150; on-time pickup under 90%; any serious safety incident; a centre blocks handover; companion pay above ₹430 per trip | Stage gates in section 4. Stop if no centre agrees to handover, or fewer than 3 of 12 interviewees would pay ₹899 and none pay ₹799 | Revisit when: a centre partner appears; a pilot funder exists; a CA says GST is exempt; or a price test shows ₹999 holds |
| Next action | Do not start yet | Approve the stage 0 interviews and the deposit pre-sale; book a CA and lawyer consult | Archive the research; set a 90-day review date |

Time-sensitive: the v1 report noted a startup challenge (TISC 2026) with a reported 20 Nov 2026 close and Aarogyasri payment disruption in private hospitals. Both are `[U]` and worth a 10-minute check, regardless of choice.

---

## 7. Changes to v1 conclusions

| v1 said | Round 2 says |
|---|---|
| Contribution ₹306 (41%) | ₹189 (26%) base; range ₹30 to ₹324 |
| Realised price ₹750 | ₹732 at ₹799 list with a 60% 12-pack mix |
| Break-even 268 visits (27 families) | 423 (42), 578 (58) with one stipend; 146 families on v1's own overhead curve; 483 at ₹799 with v2 costs |
| ₹6 L lean pilot | about ₹7 L (₹8.8 L with a stipend) |
| ₹8,499 monthly plan | Discount too deep; keep ≤5% |
| Buddy Mobility Care "closest competitor" | Operates in Hyderabad (GMR airport partnership, later articles list the city) but looks airport and wheelchair focused; dialysis escort overlap unproven. Soften the claim |
| Base case break-even month 15 | Re-run (section 9): **never** at ₹799 on v1's overhead curve; month 20 with leaner overhead; month 18 at ₹899; month 11 at ₹999 |

## 8. Sources and limits

Sources used this round: [Razorpay pricing](https://razorpay.com/blog/razorpay-shopify-payment-gateway-pricing-explained/), [ClearTax GST thresholds](https://cleartax.in/s/gst-registration-limits-increased), [Mondaq on gig-worker levy](https://www.mondaq.com/india/constitutional-administrative-law/1759312/social-security-for-gig-workers-in-india-do-central-and-state-laws-signal-higher-costs-for-online-platforms), [Telangana Today cab rules](https://telanganatoday.com/cab-aggregators-can-charge-up-to-2-times-the-base-fare-during-peak-hours), [Deccan Chronicle auto fares](https://www.deccanchronicle.com/amp/southern-states/telangana/telangana-govt-increases-auto-rickshaw-fares-1992525), [HCAH Hyderabad](https://www.hcah.in/caregiver/hyderabad/), [Bajaj Finserv dialysis cost](https://bajajfinservhealth.in/surgeries/dialysis/cost/dialysis-cost-in-hyderabad), [NephroPlus Dialysis on Call](https://www.biospectrumindia.com/news/60/19262/nephroplus-unveils-dialysis-on-call-service-in-hyderabad.html), [Medulance–NephroPlus](https://biospectrumindia.com/news/98/19571/medulance-healthcare-with-nephroplus-to-aid-in-dialysis-care-in-23-states.html), [MoHFW dialysis guidance](https://covid19dashboard.mohfw.gov.in/pdf/RevisedGuidelinesforDialysisofCOVID19Patients.pdf), [Telangana free bus pass](https://www.siasat.com/hyderabad-kidney-patients-get-free-rtc-bus-pass-1468155/), [Buddy Mobility, YourStory](https://yourstory.com/2025/07/buddy-mobility-assisted-care-transport), [GMR–Buddy](https://telanganatoday.com/gmr-hyderabad-airport-partners-with-buddy-mobility-care-for-inclusive-travel).

Limits:
- About 15 searches; many results are vendor or news summaries, some with unreliable dates.
- The NHSRC PMNDP guideline was not readable; the network host did not resolve. Treat it as unread.
- All v2 inputs are `[E]`. The Monte Carlo ranges are my judgement.
- The 24-month projection is re-run in section 9 using v1's ramps, which are themselves assumptions.
- Not legal, tax, medical or insurance advice. GST, employment form, insurance and DPDP need professionals.
- No customer, centre or companion was contacted.

## 9. 24-month projection re-run with v2 costs

Script `model_v2_projection.py`, full tables in `model_v2_projection_results.md`. Same family ramps and ₹3.5 L setup as v1; ₹ lakh; all `[E]`.

| Case (base scenario) | Break-even month | Peak cash need | Y1 net | Y2 net | Cash at month 24 |
|---|---|---|---|---|---|
| v1 published (₹750, v1 costs) | 15 | 9.3 | −5.5 | +6.8 | about +1 |
| **₹799, v2 costs, v1 overhead curve** | **never** | **35.6** | −11.1 | −21.0 | −35.6 |
| ₹799, v2 costs, leaner overhead curve (assumption) | 20 | 13.5 | −8.1 | −0.6 | −12.2 |
| ₹899, v2 costs, v1 overhead curve | 18 | 11.3 | −6.6 | +2.3 | −7.8 |
| **₹999, v2 costs, v1 overhead curve** | **11** | **5.9** | −2.0 | +25.5 | +20.0 |
| ₹799, 18% GST absorbed | never | 69.5 | −16.7 | −49.3 | −69.5 |
| ₹899, 18% GST absorbed | never | 45.9 | −12.8 | −29.6 | −45.9 |

Other scenarios at ₹799 on v1's overhead curve: conservative never breaks even (peak need ₹45.7 L); optimistic breaks even in month 10 (peak need ₹5.9 L).

What this means:
- **At ₹799 the v1 growth plan loses money every month** because contribution (about ₹210 per visit) cannot carry overhead that grows to ₹8.5 L a month by month 24. Volume does not fix it.
- **Overhead discipline is worth about as much as ₹100 of price.** Holding overhead to the leaner curve rescues the base case to a month-20 break-even at ₹799, but still leaves about ₹12 L of cumulative cash gap.
- **₹999 is the only tested price where the base case pays back inside 24 months** (cash +₹20 L at month 24). ₹899 gets close to break-even but not to payback.
- **GST is the largest single risk.** If 18% applies and the quoted price is tax-inclusive, even ₹899 never breaks even in the base case.
- **Pilot cash through month 6, base ramp, founders unpaid, ₹799:** about ₹7.4 L including setup, consistent with the ₹7 L estimate in section 2.
- These results make the price test in section 5 more important, not less: the case for the business depends on families accepting about ₹900 to ₹1,000 per trip, which only the deposit pre-sale can show.
