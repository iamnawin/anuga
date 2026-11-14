# v4: mobility cost dynamics, shared ride, and segment-adjusted projection

All figures `[E]` unless the report marks them `[V]`. Fare means the patient's vehicle cost. Companion solo legs are inside companion pay.

## A. Patient vehicle cost per round trip (two separate rides: drop, then pickup)

Auto meter `[V]`: ₹30 for first 1.6 km then ₹14 per km. Cab: ₹50 base + ₹14 to ₹18 per km (my range; drivers are reportedly paid ₹12 to 13 per km `[V]`). Peak pricing up to 2× is permitted nationally `[V]`; dialysis morning slots fall in peak hours, so I show 1.5×. Ambulance ₹1,000 to ₹2,500 per trip `[V]` RED.Health.

| One-way km | Auto round trip | Cab low | Cab mid | Cab at 1.5× peak | Ambulance round trip (₹1,000 to 2,500 each way) |
|---|---|---|---|---|---|
| 4 | 127 | 212 | 244 | 366 | 2,000 to 5,000 |
| 8 | 239 | 324 | 388 | 582 | 2,000 to 5,000 |
| 12 | 351 | 436 | 532 | 798 | 2,000 to 5,000 |
| 16 | 463 | 548 | 676 | 1,014 | 2,000 to 5,000 |

Monthly fare for 12 round trips at 8 km one-way:

| Vehicle | Per month ₹ |
|---|---|
| Auto | 2,870 |
| Cab low | 3,888 |
| Cab mid (v1 assumption) | 4,656 |
| Cab all trips at 1.5× peak | 6,984 |
| Non-emergency ambulance | 24,000 |

**Who pays:** in the solo plan the fare is pass-through, so the family bears 100% of it. It is about 30% of the monthly bill at cab mid, and it is the part the family can compare to a ₹150 auto fare. Surge exposure: if 40% of trips are in peak at 1.5×, average fare rises about 20%.

## B. Shared-ride (pooled) tier: one vehicle and one companion for 3 patients per run

Vehicle ₹35,000 per month (`[E]`, between the ₹15k to 25k Hyderabad range and ₹50k+ for Ertiga/Innova elsewhere `[V]` weak). Capacity 156 patient round trips per month per vehicle at 100% fill (3 patients × 2 shifts × 26 days). Companion ₹480 per cohort-shift = ₹160 per patient trip.

| Fill of vehicle | Vehicle cost per patient trip ₹ | Companion per patient trip ₹ | Delivered cost ₹ | Solo cab mid + companion ₹430 |
|---|---|---|---|---|
| 40% | 561 | 160 | 721 | 818 |
| 50% | 449 | 160 | 609 | 818 |
| 60% | 374 | 160 | 534 | 818 |
| 70% | 321 | 160 | 481 | 818 |
| 85% | 264 | 160 | 424 | 818 |
| 100% | 224 | 160 | 384 | 818 |

Shared-ride plan, all-in price ₹750 per round trip (₹9,000 for 12), fare included. Fill rises with family count in one micro-market (my assumption: 35% + 0.65% per family, capped at 85%).

| Families | Fill | Vehicle ₹/trip | Contribution ₹/trip | Family pays per month (all-in) |
|---|---|---|---|---|
| 15 | 44% | 501 | -58 | 9,000 |
| 30 | 54% | 412 | 32 | 9,000 |
| 40 | 61% | 368 | 75 | 9,000 |
| 75 | 83% | 268 | 175 | 9,000 |
| 100 | 85% | 264 | 179 | 9,000 |
| 200 | 85% | 264 | 179 | 9,000 |

Reading: shared ride cuts the family's monthly all-in cost from about ₹15,700 (solo plan plus cab) to about ₹9,000, but it only earns a margin once a micro-market is dense (roughly 75+ families on common centres and shifts). It is a scale-stage tier, not a pilot offer. Riders must accept a pickup window and a longer ride.

## C. 'Stay' tier: companion stays through the session (frail patients, or centres that require an attendant)

Active plus waiting time ≈ 7.8 h × ₹110 loaded = ₹858 companion cost, matching v1's ₹715. A verified comparator is a ₹1,000+ per day attendant (HCAH).

| Stay price per session ₹ | Other variable costs ₹ | Contribution ₹ | Margin |
|---|---|---|---|
| 1299 | 126 | 315 | 24% |
| 1499 | 130 | 511 | 34% |
| 1799 | 137 | 804 | 45% |
| 1999 | 142 | 999 | 50% |

A Stay tier at ₹1,499 to ₹1,799 is viable and sits near the verified attendant price, but it competes directly with informal attendants, so bypass is easiest here.

## D. 24-month projection at the ₹10,999 plan, by dialysis-fee tier (base ramp × multiplier, v1 overhead curve, ₹3.5 L setup)

The session fee is the hospital's charge and is outside AnugaCare's revenue. It changes how many families can afford the escort. Multipliers are my judgement: ₹2,500 sessions make the escort about +52% of the dialysis bill (hard sell), ₹4,000 about +33%, ₹6,000 about +22%. Free-scheme (Aarogyasri/white card) patients pay no session fee and are assumed outside this segment.

| Case | Ramp × | Peak families at month 24 | Break-even month | Peak cash need ₹ L | Y1 net | Y2 net | Cash at month 24 |
|---|---|---|---|---|---|---|---|
| Solo plan ₹10,999, ₹6,000 sessions | 1.0 | 300 | 13 | 8.0 | -4.5 | 13.2 | 5.2 |
| Solo plan ₹10,999, ₹4,000 sessions | 1.0 | 300 | 13 | 8.0 | -4.5 | 13.2 | 5.2 |
| Solo plan ₹10,999, ₹2,500 sessions | 0.5 | 150 | 20 | 10.5 | -5.0 | -1.0 | -9.4 |
| Solo plan ₹10,999, ₹2,500 sessions, weak | 0.3 | 90 | never | 13.4 | -5.2 | -4.6 | -13.4 |
| Solo plan ₹10,999, 0.75 uptake | 0.75 | 225 | 16 | 8.8 | -4.9 | 5.8 | -2.6 |
| Shared ride ₹9,000 all-in, ₹2,500 sessions | 0.8 | 240 | never | 45.2 | -14.6 | -27.1 | -45.2 |

The ₹6,000 and ₹4,000 rows use the same ramp (×1.0) because I have no basis to separate them; the ramp itself is v1's assumption. Revenue ₹ L for the solo plan base case: Y1 and Y2 are in `model_v2_projection_results.md` pattern, scaled by the multiplier.

### Solo plan at ₹10,999: ramp multiplier sweep

| Ramp × | Families at month 24 | Break-even month | Peak cash need ₹ L | Cash at month 24 ₹ L |
|---|---|---|---|---|
| 0.2 | 60 | never | 13.9 | -13.9 |
| 0.3 | 90 | never | 13.4 | -13.4 |
| 0.4 | 120 | 24 | 11.7 | -11.7 |
| 0.5 | 150 | 20 | 10.5 | -9.4 |
| 0.6 | 180 | 18 | 9.6 | -6.8 |
| 0.75 | 225 | 16 | 8.8 | -2.6 |
| 1.0 | 300 | 13 | 8.0 | 5.2 |
| 1.25 | 375 | 12 | 7.6 | 13.7 |

Break-even depends mostly on overhead against family count, so a smaller segment needs a smaller organisation. The overhead curve here is v1's; a leaner one would move every row favourably.

