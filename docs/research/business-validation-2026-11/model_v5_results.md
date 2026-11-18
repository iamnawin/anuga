# v5: dialysis frequency (visits per family per month)

Founder input: 12 per 4-week cycle is the base, most patients dialyse three times a week (about 13 per calendar month), some twice a week. Earlier models assumed 10 escorted trips per family per month. All else as S1 (₹10,999 plan, effective companion pay ₹430). `[E]`

## 1. Sessions per month by weekly frequency

| Pattern | Sessions per 4 weeks | Sessions per calendar month (4.33 weeks) |
|---|---|---|
| Twice a week | 8 | 8.7 |
| Three times a week | 12 | 13.0 |
| Four times a week (less common) | 16 | 17.3 |

## 2. Family economics by trips per month (S1 unit economics, 40 families)

| Trips per month | Contribution per trip ₹ | Contribution per family-month ₹ | Service revenue per family ₹ (at ₹917/trip) | Fare per month (cab mid, 8 km) | Total family bill ₹ | As % of dialysis at ₹2,500 | At ₹4,000 |
|---|---|---|---|---|---|---|---|
| 8 | 326 | 2,612 | 7,333 | 3,104 | 10,437 | 52% | 33% |
| 9 | 329 | 2,961 | 8,249 | 3,492 | 11,741 | 52% | 33% |
| 10 | 331 | 3,310 | 9,166 | 3,880 | 13,046 | 52% | 33% |
| 12 | 334 | 4,008 | 10,999 | 4,656 | 15,655 | 52% | 33% |
| 13 | 335 | 4,357 | 11,916 | 5,044 | 16,960 | 52% | 33% |
| 17 | 338 | 5,753 | 15,582 | 6,596 | 22,178 | 52% | 33% |

Per-trip economics barely move (only replacement acquisition cost is spread over more trips). What changes is **how many trips each family brings**, which spreads overhead, and **the monthly bill**.

## 3. Break-even visits and families, S1, overhead bases (contribution at 30 families)

| Trips per family per month | CM per trip ₹ | Families to cover ₹82k | ₹112k | ₹142k |
|---|---|---|---|---|
| 8 | 323 | 32 | 43 | 55 |
| 10 | 327 | 25 | 34 | 43 |
| 12 | 330 | 21 | 28 | 36 |
| 13 | 331 | 19 | 26 | 33 |

## 4. 24-month projection, S1 at ₹10,999 for 12 trips (₹917 per trip), v1 overhead curve, by trips per family and ramp (₹ lakh)

Ramp × is a judgement for segment size: ×1.0 for ₹4,000+ session families, ×0.5 for ₹2,500 session families (see v4).

| Trips per family | Ramp × | Break-even month | Peak cash need | Y1 net | Y2 net | Cash at month 24 |
|---|---|---|---|---|---|---|
| 8 | 1.0 | never | 16.9 | -8.0 | -5.4 | -16.9 |
| 10 | 1.0 | 13 | 8.0 | -4.5 | 13.2 | 5.2 |
| 12 | 1.0 | 10 | 5.4 | -1.0 | 31.8 | 27.3 |
| 13 | 1.0 | 7 | 4.8 | 0.7 | 41.1 | 38.3 |
| 8 | 0.5 | never | 20.2 | -6.7 | -10.1 | -20.2 |
| 10 | 0.5 | 20 | 10.5 | -5.0 | -1.0 | -9.4 |
| 12 | 0.5 | 14 | 6.8 | -3.3 | 8.1 | 1.4 |
| 13 | 0.5 | 11 | 6.1 | -2.4 | 12.7 | 6.8 |

## 5. Plan sizing options for a 3-a-week patient

| Option | Trips | Price | Per trip | Note |
|---|---|---|---|---|
| A. 4-week plan | 12 | ₹10,999 | ₹917 | Matches the 4-week cycle; renews every 28 days (13 cycles a year, not 12) |
| B. Calendar-month plan | 13 | ₹11,899 | ₹915 | Same per-trip price as A, billed monthly |
| C. Calendar-month plan, 13 trips, flat | 13 | ₹10,999 | ₹846 | Looks simpler, but gives away about ₹70 per trip. Contribution falls below ₹300 |
| D. Twice a week | 8 to 9 | ₹7,999 | about ₹890 | Lower frequency, same per-trip rate |

Option C contribution per trip at 40 families: ₹264 (vs ₹335 for A/B).

Monthly family bill at 13 trips, cab mid: ₹11,899 + ₹5,044 fare = about ₹16,900. At ₹2,500 per session (₹32,500 dialysis) that is about 52%; at ₹4,000 (₹52,000) about 33%.

