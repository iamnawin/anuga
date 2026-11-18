# v10: scheduling analysis (one companion's day)

Simulation of a drop-and-return day, 4,000 simulated days per case. All inputs `[E]` except the founder's 4 to 5 hour session and 6 to 7 hour door-to-door figure.

**Assumed centre shifts (planned session starts):** S1 07:00, S2 11:30, S3 16:00 (4-hour sessions, 30-minute turnaround). **Legs:** a *drop* (travel to home 22 min, loading 10, ride 40 with traffic ×1.2 at peak, handover 15), a *pick* (travel to centre 25, wait for the patient, discharge 10, ride 40, handover 10), and a *swap run* (drop the next-shift patient, then collect the patient who just finished, in one trip). **Delays:** session start delay and overrun by scenario, a chance of a 30 to 60 minute extra overrun, 10 to 30 minutes of recovery before discharge, travel variation. **Failure:** a drop later than 15 minutes after the planned session start, or a patient waiting more than 30 minutes at pickup. A leg cannot start until the previous one ends, so delays cascade. **Workable day** = no structural conflict, at least 90% of days with no failure, mean span of 11 hours or less, under 15% of days ending after 21:00.

Scenarios (start delay mean/sd, overrun mean/sd, chance of long overrun, travel variation): **low delay** 4/8, 2/10, 8%, cv 0.25; **base** 8/12, 5/18, 15%, cv 0.35; **high delay** 15/18, 10/25, 25%, cv 0.45.

Pay per patient-leg `[E]`: ₹215 solo (half of ₹430), ₹165 in a batch of 2, ₹140 in a batch of 3; a swap run ₹300 for two patient-legs.

## Low Delay

| Day plan | Visit-equivalents | Structural conflict | Day with no failure | Late drop (any) | Patient waits >30 min (any) | Active h | Idle wait min | Span h (mean / p90) | Ends after 21:00 | Pay per day ₹ | Workable |
|---|---|---|---|---|---|---|---|---|---|---|---|
| K1  solo round trip, S1 only | 1.0 | no | 99% | 1% | 0% | 2.8 | 20 | 7.0 / 7.5 | 0% | 430 | yes |
| K2a solo S1 + solo S3 (non-adjacent, one person) | 2.0 | no | 97% | 3% | 0% | 5.7 | 39 | 16.0 / 16.4 | 100% | 860 | no |
| K2b solo S1 + solo S2 (adjacent shifts, one person) | 2.0 | YES | 66% | 3% | 34% | 5.7 | 21 | 11.5 / 11.9 | 0% | 860 | no |
| K3  batch of 2 in S1 | 2.0 | no | 86% | 2% | 13% | 3.7 | 27 | 7.9 / 8.5 | 0% | 660 | no |
| K4  batch of 3 in S1 | 3.0 | no | 74% | 2% | 24% | 4.6 | 32 | 8.8 / 9.4 | 0% | 840 | no |
| K5  morning crew: drop S1, then swap S2-in / S1-out | 1.5 | no | 95% | 3% | 4% | 3.9 | 11 | 7.1 / 7.5 | 0% | 515 | yes |
| K6  afternoon crew: swap S3-in / S2-out, then pick S3 | 1.5 | no | 97% | 1% | 3% | 3.9 | 31 | 7.1 / 7.5 | 100% | 515 | no |
| K7  two-shift centre, one person: drop S1, swap S2/S1, pick S2 | 2.0 | no | 94% | 3% | 4% | 5.3 | 30 | 11.5 / 11.9 | 0% | 730 | no |
| K8  three-shift chain, one person: drop S1, swap, swap, pick S3 | 3.0 | no | 91% | 4% | 7% | 7.8 | 40 | 16.1 / 16.5 | 100% | 1,030 | no |
| K9  batch of 2 in S1 + batch of 2 in S3 (one person) | 4.0 | no | 71% | 4% | 26% | 7.5 | 54 | 16.9 / 17.4 | 100% | 1,320 | no |

## Base

| Day plan | Visit-equivalents | Structural conflict | Day with no failure | Late drop (any) | Patient waits >30 min (any) | Active h | Idle wait min | Span h (mean / p90) | Ends after 21:00 | Pay per day ₹ | Workable |
|---|---|---|---|---|---|---|---|---|---|---|---|
| K1  solo round trip, S1 only | 1.0 | no | 98% | 2% | 0% | 2.8 | 32 | 7.2 / 7.8 | 0% | 430 | yes |
| K2a solo S1 + solo S3 (non-adjacent, one person) | 2.0 | no | 95% | 4% | 0% | 5.7 | 64 | 16.2 / 16.8 | 100% | 860 | no |
| K2b solo S1 + solo S2 (adjacent shifts, one person) | 2.0 | YES | 76% | 4% | 22% | 5.7 | 40 | 11.7 / 12.4 | 0% | 860 | no |
| K3  batch of 2 in S1 | 2.0 | no | 70% | 2% | 28% | 3.7 | 43 | 8.2 / 8.8 | 0% | 660 | no |
| K4  batch of 3 in S1 | 3.0 | no | 48% | 3% | 50% | 4.6 | 50 | 9.1 / 9.8 | 0% | 840 | no |
| K5  morning crew: drop S1, then swap S2-in / S1-out | 1.5 | no | 95% | 4% | 3% | 3.9 | 20 | 7.3 / 7.8 | 0% | 515 | yes |
| K6  afternoon crew: swap S3-in / S2-out, then pick S3 | 1.5 | no | 97% | 1% | 2% | 3.9 | 54 | 7.3 / 7.8 | 100% | 515 | no |
| K7  two-shift centre, one person: drop S1, swap S2/S1, pick S2 | 2.0 | no | 94% | 4% | 3% | 5.3 | 52 | 11.7 / 12.4 | 0% | 730 | no |
| K8  three-shift chain, one person: drop S1, swap, swap, pick S3 | 3.0 | no | 91% | 6% | 5% | 7.7 | 73 | 16.2 / 16.8 | 100% | 1,030 | no |
| K9  batch of 2 in S1 + batch of 2 in S3 (one person) | 4.0 | no | 49% | 6% | 49% | 7.5 | 85 | 17.2 / 17.8 | 100% | 1,320 | no |

## High Delay

| Day plan | Visit-equivalents | Structural conflict | Day with no failure | Late drop (any) | Patient waits >30 min (any) | Active h | Idle wait min | Span h (mean / p90) | Ends after 21:00 | Pay per day ₹ | Workable |
|---|---|---|---|---|---|---|---|---|---|---|---|
| K1  solo round trip, S1 only | 1.0 | no | 97% | 3% | 0% | 2.8 | 49 | 7.5 / 8.3 | 0% | 430 | yes |
| K2a solo S1 + solo S3 (non-adjacent, one person) | 2.0 | no | 93% | 6% | 0% | 5.7 | 100 | 16.5 / 17.3 | 100% | 860 | no |
| K2b solo S1 + solo S2 (adjacent shifts, one person) | 2.0 | YES | 82% | 6% | 15% | 5.7 | 69 | 12.1 / 12.9 | 0% | 860 | no |
| K3  batch of 2 in S1 | 2.0 | no | 53% | 3% | 45% | 3.7 | 65 | 8.6 / 9.3 | 0% | 660 | no |
| K4  batch of 3 in S1 | 3.0 | no | 28% | 4% | 71% | 4.6 | 73 | 9.5 / 10.2 | 0% | 840 | no |
| K5  morning crew: drop S1, then swap S2-in / S1-out | 1.5 | no | 93% | 6% | 2% | 3.9 | 36 | 7.5 / 8.3 | 0% | 515 | yes |
| K6  afternoon crew: swap S3-in / S2-out, then pick S3 | 1.5 | no | 97% | 2% | 1% | 3.9 | 87 | 7.5 / 8.3 | 100% | 515 | no |
| K7  two-shift centre, one person: drop S1, swap S2/S1, pick S2 | 2.0 | no | 93% | 6% | 2% | 5.3 | 87 | 12.1 / 12.9 | 0% | 730 | no |
| K8  three-shift chain, one person: drop S1, swap, swap, pick S3 | 3.0 | no | 89% | 9% | 4% | 7.8 | 122 | 16.5 / 17.3 | 100% | 1,030 | no |
| K9  batch of 2 in S1 + batch of 2 in S3 (one person) | 4.0 | no | 30% | 12% | 68% | 7.5 | 129 | 17.6 / 18.3 | 100% | 1,320 | no |

## Maximum reliable visits per companion per day

| Scenario | Best workable plan | Visit-equivalents | Day with no failure | Span h |
|---|---|---|---|---|
| low delay | K5  morning crew: drop S1, then swap S2-in / S1-out | 1.5 | 95% | 7.1 |
| base | K5  morning crew: drop S1, then swap S2-in / S1-out | 1.5 | 95% | 7.3 |
| high delay | K5  morning crew: drop S1, then swap S2-in / S1-out | 1.5 | 93% | 7.5 |

## Economics by plan (S1 plan ₹10,999 for 12 trips, 40 families, base delays)

Idle wait and visit-failure rate from the simulation replace the flat assumptions (20 min wait, 3% company failure). Pay per visit = pay for the two patient-legs of one visit. `[E]`

| Plan | Visit-equivalents per day | Pay per visit ₹ | Idle wait min per visit | Visit failure rate | Contribution per visit ₹ | Companion monthly pay ₹ (26 days) | Workable |
|---|---|---|---|---|---|---|---|
| K1  solo round trip, S1 only | 1.0 | 430 | 32 | 2% | 296 | 11,180 | yes |
| K2a solo S1 + solo S3 (non-adjacent, one person) | 2.0 | 430 | 32 | 2% | 293 | 22,360 | no |
| K2b solo S1 + solo S2 (adjacent shifts, one person) | 2.0 | 430 | 20 | 13% | 227 | 22,360 | no |
| K3  batch of 2 in S1 | 2.0 | 330 | 21 | 15% | 333 | 17,160 | no |
| K4  batch of 3 in S1 | 3.0 | 280 | 17 | 17% | 388 | 21,840 | no |
| K5  morning crew: drop S1, then swap S2-in / S1-out | 1.5 | 343 | 13 | 4% | 408 | 13,390 | yes |
| K6  afternoon crew: swap S3-in / S2-out, then pick S3 | 1.5 | 343 | 36 | 2% | 383 | 13,390 | no |
| K7  two-shift centre, one person: drop S1, swap S2/S1, pick S2 | 2.0 | 365 | 26 | 3% | 368 | 18,980 | no |
| K8  three-shift chain, one person: drop S1, swap, swap, pick S3 | 3.0 | 343 | 24 | 4% | 393 | 26,780 | no |
| K9  batch of 2 in S1 + batch of 2 in S3 (one person) | 4.0 | 330 | 21 | 15% | 330 | 34,320 | no |

## Companions needed

Each patient attends 3 days a week: about 12 ÷ 26 = 0.46 visits per family per working day. Allow 1.3× for days off, sickness and backup. Rosters assume the best workable plan per scenario (base) and a looser 1.0 visit-equivalent per companion per day (solo S1-style).

Best workable base plan: **K5  morning crew: drop S1, then swap S2-in / S1-out** at **1.5** visit-equivalents per companion-day.

| Paying families | Visits per day | Companions on duty at best plan | With 1.3× cover | If only 1.0 per day |
|---|---|---|---|---|
| 15 | 6.9 | 4.6 | 7 | 9 |
| 30 | 13.8 | 9.2 | 13 | 18 |
| 60 | 27.7 | 18.5 | 25 | 36 |
| 100 | 46.2 | 30.8 | 40 | 60 |
| 200 | 92.3 | 61.5 | 80 | 120 |

