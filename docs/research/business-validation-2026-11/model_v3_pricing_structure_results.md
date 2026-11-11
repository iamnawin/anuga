# v3: pricing structure and bypass resistance, calculations

All `[E]`. `pay` is effective companion cost per visit including commute allowance and the average retention bonus. Contribution includes failed visits, waiting, payment fees and replacement acquisition cost (v2 engine).

## 1. Contribution per completed visit by structure

| Structure | Fee per trip ₹ | Companion effective pay ₹ | Pay as % of fee | CM @15 | CM @40 | CM @75 | Margin @40 |
|---|---|---|---|---|---|---|---|
| S0 current: ₹799 per trip, packs 60% 12-pack | 732 | 380 | 52% | 189 | 197 | 208 | 27% |
| S1 Care Plan ₹10,999/12 trips, month 1-6 | 917 | 430 | 47% | 322 | 331 | 344 | 36% |
| S2 same family, month 13+ (price -8%, pay ladder) | 843 | 460 | 55% | 215 | 225 | 239 | 27% |
| S3 premium plan ₹11,999/12 trips | 1,000 | 460 | 46% | 374 | 384 | 398 | 38% |
| S4 ₹9,999/12 trips, pay 430 | 833 | 430 | 52% | 237 | 247 | 259 | 30% |

## 2. Companion pay design (illustrative, per round trip ≤8 km)

| Component | ₹ | Note |
|---|---|---|
| Base for time on the job | 330 | about 3.6 active hours |
| Commute allowance (two solo legs) | 60 | paid on every trip |
| Retention bonus ÷ trips | 40 | ₹1,500 per month if at least 30 trips, at least 95% on time, no direct-dealing breach. ₹50 per trip at 30 trips, ₹25 at 60 |
| **Effective pay used in S1** | **430** | Tenure ladder adds +₹10 per trip every 6 months up to +₹30 (S2 uses 460) |

Also paid by AnugaCare, not the companion: accident cover, training, ID kit, weekly payout, a minimum monthly guarantee once the companion is on 3+ regular families.

## 3. What each side gains by going direct (per family per month, 12 trips, fare identical either way)

A direct deal needs the companion to quote below the family's price but above what AnugaCare pays. ₹600 to ₹800 per round trip is my guess at what a freelance companion would ask `[E]`; a verified comparator is a ₹1,000 per day attendant (HCAH).

| Direct price per trip ₹ | Family saves per month vs ₹10,999 plan | Family saves % | Companion earns per month direct | Companion earns via AnugaCare (₹430) | Companion gain |
|---|---|---|---|---|---|
| 600 | 3,799 | 35% | 7,200 | 5,160 | 2,040 (+40%) |
| 700 | 2,599 | 24% | 8,400 | 5,160 | 3,240 (+63%) |
| 800 | 1,399 | 13% | 9,600 | 5,160 | 4,440 (+86%) |
| 900 | 199 | 2% | 10,800 | 5,160 | 5,640 (+109%) |

**Reading:** at a ₹700 direct deal the companion earns about 63% more and the family saves about 24%. Both sides win on paper. The incentive is real, so the defence must be (a) making AnugaCare's extras worth that gap and (b) keeping the gap small.

## 4. What the family and the companion lose by going direct

| Item | Family loses | Companion loses |
|---|---|---|
| Backup if the companion is ill or on leave | A missed dialysis session is clinically serious. One uncovered trip a month is the real cost | Sick-day cover and a replacement who takes their families |
| Insurance and incident handling | Cover for a fall or a missed handover | Accident cover |
| Verified identity and OTP/handover record | Proof of who collected the patient and when | Protection if a family disputes a trip |
| Centre acceptance | Centres may accept only registered, ID-checked providers (to be confirmed) | Same |
| Dense shifts | n/a | Batched, back-to-back runs; direct work is one family at a time with idle gaps |
| Pay certainty | One invoice, one prepaid wallet | Weekly payout even when a family delays |
| Price lock and loyalty step-downs | Forfeited | n/a |

## 5. Effect of bypass on the 24-month plan (base ramp, v1 overhead curve, ₹3.5 L setup)

Bypass modelled as a share of families permanently lost to direct deals, phased in linearly over 24 months. Overhead is sized to gross families (the organisation does not shrink when families leave). Companion re-training cost not included.

| Structure | Share of families lost to bypass by month 24 | Break-even month | Peak cash need ₹ L | Y1 net ₹ L | Y2 net ₹ L | Cash at month 24 ₹ L |
|---|---|---|---|---|---|---|
| S0 current: ₹799 per trip, packs 60% 12-pack | 0% | never | 35.6 | -11.1 | -21.0 | -35.6 |
| S0 current: ₹799 per trip, packs 60% 12-pack | 10% | never | 40.7 | -11.5 | -25.6 | -40.7 |
| S0 current: ₹799 per trip, packs 60% 12-pack | 25% | never | 48.2 | -12.1 | -32.6 | -48.2 |
| S0 current: ₹799 per trip, packs 60% 12-pack | 40% | never | 55.6 | -12.7 | -39.4 | -55.6 |
| S1 Care Plan ₹10,999/12 trips, month 1-6 | 0% | 13 | 8.0 | -4.5 | 13.2 | 5.2 |
| S1 Care Plan ₹10,999/12 trips, month 1-6 | 10% | 15 | 8.9 | -5.1 | 5.7 | -2.9 |
| S1 Care Plan ₹10,999/12 trips, month 1-6 | 25% | never | 15.0 | -6.1 | -5.4 | -15.0 |
| S1 Care Plan ₹10,999/12 trips, month 1-6 | 40% | never | 26.9 | -7.0 | -16.4 | -26.9 |
| S3 premium plan ₹11,999/12 trips | 0% | 11 | 5.9 | -1.9 | 26.8 | 21.4 |
| S3 premium plan ₹11,999/12 trips | 10% | 12 | 6.3 | -2.6 | 18.2 | 12.1 |
| S3 premium plan ₹11,999/12 trips | 25% | 13 | 7.2 | -3.7 | 5.4 | -1.8 |
| S3 premium plan ₹11,999/12 trips | 40% | never | 15.6 | -4.8 | -7.3 | -15.6 |

Note: S1 and S3 assume families accept ₹917 and ₹1,000 per trip, which is **untested**. S0 is the original ₹799 structure with v2 costs.

## 6. Introduction (conversion) fee for families who want to hire directly

Contribution per family-month on S1 ≈ ₹4,188. A one-time introduction fee of ₹12,000 equals about 2.9 months of that contribution, plus the recruitment, vetting and training already sunk in the companion (₹5k to ₹6k `[E]`). It is a pricing option, not a legal certainty; see the report.

