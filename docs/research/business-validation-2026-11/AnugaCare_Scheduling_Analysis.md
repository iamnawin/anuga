# Scheduling analysis: can a companion's day actually work?

Date: 2026-11-11. Model: `model_v10_scheduling.py` → `model_v10_results.md` (4,000 simulated days per case, three delay scenarios).
Labels: `[V]` found in a source, `[E]` my estimate, `[I]` needs a centre, interviews or a shadow run to settle.
Real inputs from you: a session is 4 to 5 hours; door to door is 6 to 7 hours. Everything else (centre shifts, delay sizes, travel times) is my assumption and must be replaced by shadow-run and centre data. Nothing was contacted or spent.

---

## 1. Verdict

**The pricing works only if the schedule works, and the schedule works only in a narrower form than I had assumed.**

1. **A companion can reliably do one solo round trip a day, not two or three.** My earlier ₹430 and "2 to 3 trips a day" scale-stage figure was too optimistic.
2. **Adjacent shifts collide.** The pickup of shift 1 and the drop for shift 2 are both due at about 11:15. One person cannot do both. In the simulation a solo companion serving adjacent shifts has a structural overlap, and 22% of days a patient waits more than 30 minutes (76% of days with no failure).
3. **Batching two patients in the same shift fails on reliability.** The companion must wait for the slower patient. Only 70% of days run clean in base delays (53% in high delay), and 28% of days have a patient waiting more than 30 minutes.
4. **The design that works is a "swap run".** One trip drops the next-shift patient at the centre and, in the same visit, collects the patient who has just finished. A morning crew doing one drop plus one swap serves **1.5 visits** in a 7.3-hour day with **95% of days clean** (93% in high delay), only about 13 minutes of idle wait per visit, and a margin better than solo.
5. **A third (evening) shift is impractical.** The last pickup ends after 21:00 in every simulated day, with a long day for the companion and a very late return for the patient. Treat shifts 1 and 2 as the service window for the pilot.
6. **So the maximum reliable load is about 1.0 solo, 1.5 on a swap crew, and up to 2.0 on a long split day (about 11.7 hours, 94% clean).** Not 3.

**Does the model work?** Yes, conditionally: with swap runs, clustered patients in the first two shifts, and part-time companions. It does not work with open-ended solo scheduling across shifts or with evening sessions.

---

## 2. What the simulation assumes `[E]`

- **Centre shifts:** S1 07:00, S2 11:30, S3 16:00, 4-hour sessions, 30-minute turnaround.
- **Legs:** a drop (travel to home 22 min, loading 10, ride 40 min with traffic ×1.2 at peak, handover 15) and a pickup (travel to centre 25, wait for the patient, discharge 10, ride 40, handover 10). A swap run chains a drop and a pickup in one trip.
- **Delays (base):** session start delay mean 8 min (sd 12); overrun mean 5 min (sd 18); 15% chance of an extra 30 to 60 minute overrun; 10 to 30 minutes of recovery before discharge; travel-time variation cv 0.35. Low and high scenarios scale these.
- **Cascade:** a leg cannot start until the previous leg ends.
- **Failure:** a drop later than 15 minutes after the planned session start, or a patient waiting more than 30 minutes at pickup.
- **Workable day:** no structural overlap, at least 90% of days with no failure, mean span of 11 hours or less, and under 15% of days ending after 21:00.

---

## 3. Results (base delays)

| Day plan | Visit-equivalents per day | Days with no failure | Patient waits >30 min | Span h | Companion pay per day | Workable |
|---|---|---|---|---|---|---|
| **Solo round trip, S1** | 1.0 | 98% | 0% | 7.2 | ₹430 | yes |
| Solo S1 + solo S3, one person | 2.0 | 95% | 0% | **16.2** | ₹860 | no (16-hour day, ends after 21:00) |
| Solo S1 + solo S2, one person | 2.0 | **76%** | 22% | 11.7 | ₹860 | no (structural overlap) |
| Batch of 2 in one shift | 2.0 | **70%** | 28% | 8.2 | ₹660 | no |
| Batch of 3 in one shift | 3.0 | 48% | 50% | 9.1 | ₹840 | no |
| **Morning swap crew: drop S1, swap S2-in / S1-out** | **1.5** | **95%** | 3% | 7.3 | ₹515 | **yes** |
| Afternoon swap crew (S3) | 1.5 | 97% | 2% | 7.3 | ₹515 | no (ends after 21:00) |
| One person, two-shift chain: drop S1, swap, pick S2 | 2.0 | 94% | 3% | 11.7 | ₹730 | borderline (long split day) |
| One person, three-shift chain | 3.0 | 91% | 5% | 16.2 | ₹1,030 | no |
| Two batches of 2 (S1 and S3) | 4.0 | 49% | 49% | 17.2 | ₹1,320 | no |

Across delay scenarios, solo S1 stays at 97% to 99% clean, the morning swap crew at 93% to 95%, and batch of 2 falls from 86% (low) to 53% (high).

**Why the numbers move:** the late drop is rare (2% to 6%). The binding failure is the **pickup**: a patient waiting for a companion who is stuck, or a companion waiting for a patient who overran. Batching multiplies that risk, because the whole group waits for the slowest patient.

---

## 4. Economics under real scheduling (S1 plan, 40 families, base delays)

Simulated idle wait and failure rate replace the flat assumptions (20 minutes of wait, 3% company failure). Pay per patient-leg: ₹215 solo, ₹165 in a batch of 2, a swap run ₹300 for two patient-legs `[E]`.

| Plan | Pay per visit | Idle wait min per visit | Visit failure rate | Contribution per visit | Companion monthly pay (26 days) |
|---|---|---|---|---|---|
| Solo round trip | ₹430 | 32 | 2% | **₹296** | ₹11,180 |
| Morning swap crew | ₹343 | 13 | 4% | **₹408** | ₹13,390 |
| Two-shift chain, one person | ₹365 | 26 | 3% | ₹368 | ₹18,980 |
| Batch of 2 | ₹330 | 21 | 15% | ₹333 | ₹17,160 (but only 70% reliable) |

- Solo scheduling is **₹38 below the ₹334 contribution used in the pricing model**, mostly from longer idle waits (32 vs 20 minutes).
- Swap runs **improve** contribution (₹408) because each trip serves two patients without an empty leg. That depends on my ₹300 swap pay, on swap pairs existing, and on two patients living in the same neighbourhood and adjacent shifts.
- **Companion income at the reliable load is low:** about ₹11,000 to ₹13,000 a month on 26 working days, ₹19,000 on a long split day. This is part-time money.

---

## 5. Companions needed (base delays, 1.3× cover for days off and sickness)

Each patient attends 3 days a week: about 0.46 visits per family per working day.

| Paying families | Visits per day | Companions at 1.5 per day (swap) | With cover | If only 1.0 per day (solo) |
|---|---|---|---|---|
| 15 | 6.9 | 4.6 | **7** | **9** |
| 30 | 13.8 | 9.2 | 13 | 18 |
| 60 | 27.7 | 18.5 | 25 | 36 |
| 100 | 46.2 | 30.8 | 40 | 60 |

**What changes:** a 15-family pilot needs **7 to 9 part-time companions**, not the 4 to 5 I budgeted. At 7 companions each does about 26 visits a month, so about **₹9,000** a month each at swap pay. Hiring cost for 7 to 9 is about **₹58,000 to ₹74,000** (₹8,250 each) versus the ₹45,000 to ₹56,000 earlier. Recruit people for whom this is a top-up (bike riders, students, women re-entering work), and say so openly.

---

## 6. Constraints the simulation cannot capture, and what to do

| Real-world issue | Why it matters | Mitigation to test |
|---|---|---|
| **Clustering** | Swap runs need an adjacent-shift pair from the same neighbourhood and centre. With 15 families spread across centres, shifts and areas, pairs are rare | Choose one micro-market, 2 to 3 centres; ask centres for shift times and patient counts; match families by (centre, shift, area) before launch |
| **Third shift** | The evening return pushes the day past 21:00 | Exclude shift 3 in the pilot. Ask what share of patients are in each shift `[I]` |
| **Discharge time** | The slowest patient sets the wait | Ask the centre for a heads-up about 30 minutes before discharge; allow 30 to 45 minute pickup windows rather than exact times |
| **Overruns** | A 30 to 60 minute extra overrun breaks the next leg | Keep a floating backup companion per centre per shift; do not schedule a hard leg within 45 minutes of a pickup |
| **Hours and fatigue** | Split days of 11 to 12 hours are hard to staff | Roster crews (morning and afternoon) rather than long chains |
| **Weekdays vs weekends, holidays** | Dialysis does not stop on Sundays; many centres run reduced shifts | Check the centre's calendar and treat Sunday and festival cover separately |
| **Distance** | The model uses 8 km each way | Charge the distance band; refuse over 15 km in the pilot |
| **Patient variation** | Some patients take longer to recover | Capture recovery type at onboarding; give such patients longer windows or solo runs |
| **Traffic** | Hyderabad peak is worse than ×1.2 on some corridors | Time real routes in the shadow runs |

---

## 7. What this changes in the decision

- **Pricing:** ₹10,999 for 12 trips still stands. The scheduling-adjusted contribution is ₹296 (solo) to ₹408 (swap) per visit versus ₹334 modelled, so the price is not the problem. Density is.
- **Operations gate (new):** before the paid pilot, a shadow run must show a real day on a real route fits inside the simulated windows (drop on time, pickup within 30 minutes), and the centre must confirm shift structure and a discharge heads-up.
- **Staffing and budget:** plan 7 to 9 part-time companions for 15 families and add about ₹15,000 to the recruitment budget.
- **Success conditions:** add "families clustered by centre, shift and area so that swap runs exist" and "the pilot runs in shifts 1 and 2 only".
- **Validation additions:** in centre visits ask shift times, patients per shift, any heads-up on discharge, Sunday schedule. In interviews ask which shift the patient attends. In shadow runs time every leg, including the commute gaps.
- **Product point:** this is also the case for a dispatch tool that groups patients by centre, shift and area. The repository already has clusters and companion controls according to `CLAUDE.md`; I have not checked whether they support swap runs, and I have not changed anything.

## 8. Limits

- Shift times, delay sizes, recovery times, traffic and the ₹300 swap pay are my assumptions. The only inputs from you are the 4 to 5 hour session and 6 to 7 hours door to door.
- The model assumes patients are within 8 km, all attend the same centre in the pilot, and a companion works a fixed crew pattern.
- A swap crew's reliability rests on the incoming patient being ready at home on time and the outgoing patient being ready to leave within about 30 minutes of the expected time.
- Treat the results as a stress test to design the pilot, not as a forecast.
