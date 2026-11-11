# Mobility cost, the 4 to 5 hour wait, and segment-adjusted projection (v4)

Date: 2026-11-11. Follows `AnugaCare_Pricing_Structure_and_Bypass_Defence.md`. Calculations: `model_v4_mobility_and_segments.py` → `model_v4_results.md`.
Labels: `[V]` found in a source, `[E]` my estimate, `[U]` unverified, `[I]` needs interviews, quotes or a centre.
Nothing was sent or spent. Not legal or tax advice.

---

## 1. What the dialysis fee is, and is not

- The session fee (₹2,500 to ₹6,000, your input) is charged by the **hospital or centre**. It is not AnugaCare revenue and not AnugaCare cost. It matters because it decides **who can afford an escort on top**.
- **Free-scheme patients** (white ration card / Aarogyasri) pay no session fee. Earlier research found about 16,500 free-dialysis patients in Telangana, roughly 10,000 in government hospitals and 6,500 in private `[V]`. One 2024 guide says free dialysis is for BPL patients at government hospitals only, others say empanelled private hospitals too, and the income rule is unclear `[U]`. These families are unlikely to pay ₹10,999. Treat them as **outside the paying segment**. An NGO or CSR channel is a separate idea `[E]`.
- So the target is the person who **already pays the hospital ₹2,500 to ₹6,000 per session**.

## 2. What the customer is really buying: the 4 to 5 hour wait

Today someone, usually a working adult child or spouse, has to take the patient and stay. A session is about 4 to 5 hours plus travel, roughly 7 to 8 hours of someone's day, 12 times a month `[E]`.

| Offer | Price | Family hours freed per trip | Price per hour freed |
|---|---|---|---|
| Solo plan, drop-and-return | ₹917 per trip + fare | about 7 | about ₹130 |
| Stay tier, companion stays | ₹1,499 per session + fare | about 7.8 | about ₹190 |
| Informal attendant `[V]` HCAH | ₹1,000+ per day | about 8 to 12 | about ₹83 to 125 |

The informal attendant is the real comparator. AnugaCare's case is verified identity, backup, handover record and no one needing to stay.

**Hospital side `[I]`:** a drop-and-return model could free waiting-area space and reduce crowding, which a centre may value. I found no published statement from any centre on this. Ask in the centre visits. Do not pay centres for referrals.

## 3. Vehicle and cab cost dynamics

Verified points: Hyderabad auto meter ₹30 for 1.6 km then ₹14 per km `[V]` (date unclear); cab drivers reportedly paid about ₹12 to 13 per km, peak pricing up to 2× allowed nationally `[V]`; a normal ambulance is ₹1,000 to ₹2,500 per trip `[V]` RED.Health; one operator gives a Hyderabad monthly car-with-driver range of ₹15,000 to ₹25,000 for 26 days of 8 to 10 hours `[V]` weak. I found no Hyderabad dialysis-transport rate card.

Patient vehicle cost per round trip (two separate rides, no waiting cab):

| One-way km | Auto | Cab low | Cab mid | Cab at 1.5× peak |
|---|---|---|---|---|
| 4 | 127 | 212 | 244 | 366 |
| 8 | 239 | 324 | 388 | 582 |
| 12 | 351 | 436 | 532 | 798 |
| 16 | 463 | 548 | 676 | 1,014 |

At 8 km, 12 round trips a month cost about **₹2,900 by auto, ₹4,700 by cab, ₹7,000 if every trip is peak-priced, and ₹24,000+ by ambulance**.

**Who pays?** In the solo plan the fare is pass-through, so **the customer pays all of it, about 30% of the monthly bill**. That is a lot. Options to reduce the shock:
1. **Offer fixed distance-band fares** (for example one price for 0 to 8 km) so the family is never surprised by surge. AnugaCare carries the variance and needs a contracted cab partner and about a 10% buffer `[E]`, not modelled.
2. **Offer auto or family car as an option** for patients who can manage it. Autos save about ₹1,800 a month.
3. **Shared ride** (section 4).
4. Do not absorb fare into the service fee on the solo plan: fare swings 3 to 4× with distance.

## 4. Two more tiers worth designing

**Shared ride (scale-stage).** One vehicle with driver (₹35,000 a month `[E]`, 3 patients per run, 2 shifts, 26 days = 156 patient trips a month at full fill) and one companion per run (₹480 per cohort-shift, ₹160 per patient trip).

| Vehicle fill | Delivered cost per patient trip | Solo cab + companion |
|---|---|---|
| 50% | ₹609 | ₹818 |
| 70% | ₹481 | ₹818 |
| 85% | ₹424 | ₹818 |

At ₹750 all-in per trip (₹9,000 a month, fare included) the family pays about ₹6,700 a month less than solo plus cab, but contribution per trip is negative at 15 families (−₹58), about ₹75 at 40 and about ₹175 at 75 or more. It needs a dense micro-market on common centres and shifts, riders who accept a pickup window, and pricing that probably sits above ₹750. It also resists bypass: a companion cannot take the vehicle route with them. **This is the most plausible way to reach the ₹2,500-session segment**, but not a pilot offer.

**Stay tier.** A companion stays through the session for frail patients or centres that require an attendant. Cost about ₹858 per session; at ₹1,499 contribution is about ₹511 (34%), at ₹1,799 about ₹804 (45%). It is the easiest to sell and the easiest to bypass, because it looks like an ordinary attendant.

## 5. 24-month projection at ₹10,999, by dialysis-fee tier

Same v1 ramp, v1 overhead curve and ₹3.5 L setup, S1 unit economics. Ramp multipliers are my judgement, not data. ₹ lakh.

| Case | Families at month 24 | Break-even month | Peak cash need | Y1 net | Y2 net | Cash at month 24 |
|---|---|---|---|---|---|---|
| Solo ₹10,999, ₹4,000 to ₹6,000 sessions (ramp ×1.0) | 300 | 13 | 8.0 | −4.5 | +13.2 | +5.2 |
| 0.75 uptake | 225 | 16 | 8.8 | −4.9 | +5.8 | −2.6 |
| **Solo ₹10,999, ₹2,500 sessions (ramp ×0.5)** | **150** | **20** | **10.5** | −5.0 | −1.0 | **−9.4** |
| ₹2,500 sessions, weak (ramp ×0.3) | 90 | never | 13.4 | −5.2 | −4.6 | −13.4 |
| Shared ride ₹9,000 all-in, ₹2,500 sessions (ramp ×0.8) | 240 | never | 45.2 | −14.6 | −27.1 | −45.2 |

Sweep of ramp multiplier for the solo plan: ×0.2 never; ×0.4 month 24; ×0.5 month 20; ×0.6 month 18; ×0.75 month 16; ×1.0 month 13.

**Reading:**
- **₹10,999 for ₹2,500-session patients roughly halves the audience and pushes break-even from month 13 to about month 20.** Cash is still negative at month 24 (about −₹9 L) with v1 overhead.
- **The plan works best for ₹4,000+ families.** Choose centres by price tier.
- **A smaller segment needs a smaller organisation.** Break-even here is driven by overhead against family count. A leaner overhead than v1's curve helps every row.
- **The shared-ride row does not work at ₹750 on v1 overhead.** It would need a higher price, a leaner organisation, or both. I have not tuned it, because its inputs (vehicle cost, fill, acceptance) are weakly sourced.

## 6. Recommended structure now (test values)

| Tier | Who | Price `[E]` | Notes |
|---|---|---|---|
| **Solo Care Plan** | ₹4,000+ per session families | ₹10,999 for 12 trips + fare | Core offer. Backup guarantee, care team, OTP handover |
| **Stay** | Frail patients, centres needing an attendant | ₹1,499 to ₹1,799 per session + fare | High margin, easy to bypass, so keep AnugaCare's insurance and backup visible |
| **Shared Ride** | ₹2,500 to ₹4,000 families, in dense areas | ₹9,000+ per month all-in, later | Needs about 75 families in one corridor and a vehicle partner |
| **Fare** | All | Distance-band fixed price, auto option | Not folded into the service fee |

## 7. Add to the validation plan

1. Ask every interviewee: **"What do you pay per session? Who stays with the patient now, and what does it cost them in time or pay?"** Tag price responses by session fee.
2. Ask about **auto vs cab vs own car** and the current monthly transport spend.
3. Get **written quotes** from 2 cab operators for a monthly drop-and-pickup package and a 6 to 7 seater with driver. Use them to replace the `[E]` vehicle figures.
4. Ask centres: *"Would you welcome fewer attendants in the waiting area? Would you accept handover? Do you run or recommend transport?"*
5. Ask who the free-scheme patients rely on for transport and whether an NGO or CSR channel exists `[I]`.

## 8. Limits

- Ramp multipliers, fill rates, vehicle cost and the shared-ride acceptance are estimates. The only Hyderabad vehicle figure is one weak operator range.
- Free-scheme eligibility and where free dialysis is delivered conflict across sources.
- The ambulance and attendant figures are vendor pages.
- The projection uses v1's overhead curve and ramp, which are assumptions, and the family count in the ₹2,500 row is a judgement, not a forecast.
- Sources: [RED.Health ambulance costs](https://red.health/blogs/cost-of-ambulance-services-in-hyderabad), [Trivenicabs monthly rental](https://www.trivenicabs.in/monthly-car-rental), [Deccan Chronicle auto fares](https://www.deccanchronicle.com/amp/southern-states/telangana/telangana-govt-increases-auto-rickshaw-fares-1992525), [Telangana Today cab fares](https://telanganatoday.com/cab-aggregators-can-charge-up-to-2-times-the-base-fare-during-peak-hours), [Telangana free bus pass](https://www.siasat.com/hyderabad-kidney-patients-get-free-rtc-bus-pass-1468155/), [HCAH](https://www.hcah.in/caregiver/hyderabad/).

---

## 9. Addendum: dialysis frequency (founder input: 12 is the base, mostly three times a week)

Calculations: `model_v5_visit_frequency.py` → `model_v5_results.md`. Frequency is founder input `[I]`, not independently verified. Earlier models assumed 10 escorted trips per family per month, which understates a 3-a-week patient (12 per 4 weeks, about 13 per calendar month).

| Trips per family per month | Break-even month, ₹4,000+ families (ramp ×1.0) | Cash at month 24 ₹ L | Break-even month, ₹2,500 families (ramp ×0.5) | Cash at month 24 ₹ L |
|---|---|---|---|---|
| 8 (twice a week) | never | −16.9 | never | −20.2 |
| 10 (earlier assumption) | 13 | +5.2 | 20 | −9.4 |
| **12** | **10** | **+27.3** | **14** | **+1.4** |
| **13** | **7** | **+38.3** | **11** | **+6.8** |

What it changes:
- **Trips per family is the second-biggest lever after price.** Contribution per trip barely moves (about ₹326 to ₹338). Each family simply brings more trips to cover the same overhead. Families needed to cover ₹112k overhead drop from 34 (at 10 trips) to 26 to 28 (at 12 to 13).
- **It rescues the ₹2,500-session case.** At 12 to 13 trips the ₹2,500 segment breaks even in months 11 to 14 instead of month 20. It also shows the risk: a twice-a-week patient (8 trips) never pays back, so **qualify patients by frequency**, not only by session fee.
- **Sell a 4-week plan, not a calendar-month plan.** Option A, 12 trips for ₹10,999 (₹917 per trip), renews every 28 days. A flat ₹10,999 for 13 trips would give away about ₹70 per trip (contribution ₹264 vs ₹335). If you bill monthly, price 13 trips at about ₹11,899.
- **The family's bill rises with frequency.** At 13 trips: about ₹11,900 fee plus about ₹5,000 cab fare, roughly ₹16,900. It stays about 33% of dialysis spend at ₹4,000 per session and about 52% at ₹2,500.
- **Interview question to add:** "How many sessions a week, and does that ever change (extra sessions, missed sessions, hospital stays)?" Missed or reduced sessions are a churn driver and are not in the model.
