# 24-month projection with v2 costs

Same family ramps and ₹3.5 L setup as v1. Unit economics from `model_v2_sensitivity.py`. Revenue is service fee only (fare is pass-through). ₹ lakh unless stated. All `[E]`.

Overhead curves: **v1 curve** = (0, 60k), (15, 82k), (75, 299k), (400, 1.1 M) per month, founders at ₹0 until 75 families then ₹40k. **Alt lean curve** = (0, 60k), (15, 100k), (75, 220k), (400, 800k): an assumption that you keep overhead tighter but pay a stipend early. Neither is data.

### A. ₹799 list, v2 costs, v1 overhead curve (like-for-like with v1)

| Scenario | Break-even month | Peak cash need | Y1 revenue | Y1 net | Y2 revenue | Y2 net | Cash at month 24 |
|---|---|---|---|---|---|---|---|
| conservative | never | 45.7 | 14.8 | -12.2 | 50.5 | -30.0 | -45.7 |
| base | never | 35.6 | 37.4 | -11.1 | 190.0 | -21.0 | -35.6 |
| optimistic | 10 | 5.9 | 64.2 | -0.8 | 321.0 | 41.5 | 37.1 |

### B. ₹799 list, v2 costs, alt lean overhead curve

| Scenario | Break-even month | Peak cash need | Y1 revenue | Y1 net | Y2 revenue | Y2 net | Cash at month 24 |
|---|---|---|---|---|---|---|---|
| conservative | never | 37.7 | 14.8 | -12.5 | 50.5 | -21.8 | -37.7 |
| base | 20 | 13.5 | 37.4 | -8.1 | 190.0 | -0.6 | -12.2 |
| optimistic | 6 | 5.2 | 64.2 | 5.0 | 321.0 | 69.8 | 71.3 |

### C. ₹899 list, v2 costs, v1 overhead curve

| Scenario | Break-even month | Peak cash need | Y1 revenue | Y1 net | Y2 revenue | Y2 net | Cash at month 24 |
|---|---|---|---|---|---|---|---|
| conservative | never | 37.7 | 16.6 | -10.4 | 56.8 | -23.8 | -37.7 |
| base | 18 | 11.3 | 42.1 | -6.6 | 213.8 | 2.3 | -7.8 |
| optimistic | 4 | 4.1 | 72.2 | 7.1 | 361.2 | 81.2 | 84.8 |

### D. ₹999 list, v2 costs, v1 overhead curve

| Scenario | Break-even month | Peak cash need | Y1 revenue | Y1 net | Y2 revenue | Y2 net | Cash at month 24 |
|---|---|---|---|---|---|---|---|
| conservative | never | 29.7 | 18.4 | -8.6 | 63.2 | -17.7 | -29.7 |
| base | 11 | 5.9 | 46.8 | -2.0 | 237.6 | 25.5 | 20.0 |
| optimistic | 3 | 3.9 | 80.3 | 15.1 | 401.4 | 121.0 | 132.6 |

### E. ₹799 list, 18% GST absorbed (tax-inclusive price), v1 overhead curve

| Scenario | Break-even month | Peak cash need | Y1 revenue | Y1 net | Y2 revenue | Y2 net | Cash at month 24 |
|---|---|---|---|---|---|---|---|
| conservative | never | 55.4 | 12.5 | -14.4 | 42.8 | -37.5 | -55.4 |
| base | never | 69.5 | 31.7 | -16.7 | 161.0 | -49.3 | -69.5 |
| optimistic | 23 | 22.1 | 54.4 | -10.5 | 272.0 | -7.0 | -21.1 |

### F. ₹899 list, 18% GST absorbed, v1 overhead curve

| Scenario | Break-even month | Peak cash need | Y1 revenue | Y1 net | Y2 revenue | Y2 net | Cash at month 24 |
|---|---|---|---|---|---|---|---|
| conservative | never | 48.6 | 14.1 | -12.8 | 48.2 | -32.3 | -48.6 |
| base | never | 45.9 | 35.7 | -12.8 | 181.2 | -29.6 | -45.9 |
| optimistic | 11 | 7.6 | 61.2 | -3.8 | 306.1 | 26.7 | 19.4 |

### v1 published results, for comparison (₹750 realised, v1 costs)

| Scenario | Break-even month | Peak cash need | Y1 revenue | Y1 net | Y2 revenue | Y2 net |
|---|---|---|---|---|---|---|
| conservative | never | 33.0 | 13.7 | −9.2 | 46.8 | −20.3 |
| base | 15 | 9.3 | 36.9 | −5.5 | 187.5 | +6.8 |
| optimistic | 7 | 4.6 | 65.2 | +2.6 | 325.9 | +59.6 |

### Base case month by month, scenario A (₹799, v2 costs, v1 overhead curve)

| Month | Families | Visits | Revenue ₹k | Contribution ₹k | Overhead ₹k | Net ₹k | Cumulative ₹k |
|---|---|---|---|---|---|---|---|
| 1 | 5 | 50 | 38 | 9 | 67 | -58 | -408 |
| 3 | 15 | 150 | 114 | 28 | 82 | -54 | -518 |
| 6 | 32 | 325 | 247 | 63 | 145 | -82 | -736 |
| 9 | 50 | 500 | 380 | 100 | 209 | -108 | -1,035 |
| 12 | 100 | 1000 | 760 | 210 | 361 | -151 | -1,463 |
| 15 | 150 | 1500 | 1,140 | 319 | 484 | -164 | -1,944 |
| 18 | 200 | 2000 | 1,520 | 432 | 607 | -175 | -2,459 |
| 21 | 250 | 2500 | 1,900 | 547 | 730 | -183 | -3,001 |
| 24 | 300 | 3000 | 2,280 | 666 | 854 | -188 | -3,560 |

### Corrected pilot-stage cash (months 1 to 6, base ramp, ₹799, founders unpaid)

Cumulative cash after month 6 including ₹3.5 L setup: ₹-7.4 L.

Reading: see the report addendum. Re-running the ramps does not make the business more certain; it shows which price and overhead choices keep it solvent.

