"""v4: vehicle/cab cost dynamics, shared-ride option, and 24-month projection at the ₹10,999 plan by dialysis-fee tier.
Reuses v2 engine and v1 ramps/overhead curve. All inputs [E] unless marked [V] in the report.
Run: python3 model_v4_mobility_and_segments.py > model_v4_results.md
"""
import contextlib
import io
import math
import numpy as np

with contextlib.redirect_stdout(io.StringIO()):
    import model_v2_sensitivity as m
    import model_v2_projection as pj
    import model_v3_pricing_structure as m3

S1 = m3.S1  # ₹10,999 plan, effective pay ₹430


def r(x, n=0):
    return f"{x:,.{n}f}"


print("# v4: mobility cost dynamics, shared ride, and segment-adjusted projection\n")
print("All figures `[E]` unless the report marks them `[V]`. Fare means the patient's vehicle cost. Companion solo legs are inside companion pay.\n")

# ---------- A. Vehicle options ----------
print("## A. Patient vehicle cost per round trip (two separate rides: drop, then pickup)\n")
print("Auto meter `[V]`: ₹30 for first 1.6 km then ₹14 per km. Cab: ₹50 base + ₹14 to ₹18 per km (my range; drivers are reportedly paid ₹12 to 13 per km `[V]`). "
      "Peak pricing up to 2× is permitted nationally `[V]`; dialysis morning slots fall in peak hours, so I show 1.5×. Ambulance ₹1,000 to ₹2,500 per trip `[V]` RED.Health.\n")
print("| One-way km | Auto round trip | Cab low | Cab mid | Cab at 1.5× peak | Ambulance round trip (₹1,000 to 2,500 each way) |")
print("|---|---|---|---|---|---|")
for km in (4, 8, 12, 16):
    auto = 2 * (30 + 14 * max(km - 1.6, 0))
    lo = 2 * (50 + 14 * km)
    mid = 2 * (50 + 18 * km)
    print(f"| {km} | {r(auto)} | {r(lo)} | {r(mid)} | {r(mid * 1.5)} | {r(2000)} to {r(5000)} |")
print()
print("Monthly fare for 12 round trips at 8 km one-way:\n")
print("| Vehicle | Per month ₹ |\n|---|---|")
for nm, v in (("Auto", 2 * (30 + 14 * 6.4) * 12), ("Cab low", 2 * (50 + 14 * 8) * 12), ("Cab mid (v1 assumption)", 2 * (50 + 18 * 8) * 12),
              ("Cab all trips at 1.5× peak", 2 * (50 + 18 * 8) * 1.5 * 12), ("Non-emergency ambulance", 24000)):
    print(f"| {nm} | {r(v)} |")
print()
print("**Who pays:** in the solo plan the fare is pass-through, so the family bears 100% of it. It is about 30% of the monthly bill at cab mid, and it is the part the family can compare to a ₹150 auto fare. "
      "Surge exposure: if 40% of trips are in peak at 1.5×, average fare rises about 20%.\n")

# ---------- B. Shared ride economics ----------
print("## B. Shared-ride (pooled) tier: one vehicle and one companion for 3 patients per run\n")
VEH_MONTH = 35000  # ₹ per month, car with driver, ~2,500 km, 26 days. [V] ₹15k to 25k Hyderabad monthly range (weak), ₹50k+ non-Hyderabad Ertiga/Innova; I use ₹35k for a 6-7 seater
RUN_PATIENTS = 3
SHIFTS = 2
DAYS = 26
CAP = RUN_PATIENTS * SHIFTS * DAYS  # patient round trips per vehicle-month at 100% fill
COMP_PER_COHORT = 480  # companion pay per cohort-shift (both legs), ₹, includes commute
print(f"Vehicle ₹{VEH_MONTH:,} per month (`[E]`, between the ₹15k to 25k Hyderabad range and ₹50k+ for Ertiga/Innova elsewhere `[V]` weak). "
      f"Capacity {CAP} patient round trips per month per vehicle at 100% fill ({RUN_PATIENTS} patients × {SHIFTS} shifts × {DAYS} days). "
      f"Companion ₹{COMP_PER_COHORT} per cohort-shift = ₹{COMP_PER_COHORT / RUN_PATIENTS:.0f} per patient trip.\n")
print("| Fill of vehicle | Vehicle cost per patient trip ₹ | Companion per patient trip ₹ | Delivered cost ₹ | Solo cab mid + companion ₹430 |")
print("|---|---|---|---|---|")
for fill in (0.4, 0.5, 0.6, 0.7, 0.85, 1.0):
    v = VEH_MONTH / (CAP * fill)
    print(f"| {int(fill * 100)}% | {r(v)} | {r(COMP_PER_COHORT / RUN_PATIENTS)} | {r(v + COMP_PER_COHORT / RUN_PATIENTS)} | {r(388 + 430)} |")
print()

PRICE_ALLIN = 750  # per round trip, fare included


def pooled_cm(f, price=PRICE_ALLIN):
    fill = min(0.85, 0.35 + 0.0065 * f)
    veh = VEH_MONTH / (CAP * fill)
    comp = COMP_PER_COHORT / RUN_PATIENTS * 1.10  # +10% idle
    other = 30 + 15 + 8 + 12
    fail = 30
    pg = 0.0236 * price
    acq = 0.06 * 3000 / 10
    return price - (veh + comp + other + fail + pg + acq), fill, veh


print(f"Shared-ride plan, all-in price ₹{PRICE_ALLIN} per round trip (₹{PRICE_ALLIN * 12:,} for 12), fare included. Fill rises with family count in one micro-market (my assumption: 35% + 0.65% per family, capped at 85%).\n")
print("| Families | Fill | Vehicle ₹/trip | Contribution ₹/trip | Family pays per month (all-in) |")
print("|---|---|---|---|---|")
for f in (15, 30, 40, 75, 100, 200):
    cm, fill, veh = pooled_cm(f)
    print(f"| {f} | {int(fill * 100)}% | {r(veh)} | {r(cm)} | {r(PRICE_ALLIN * 12)} |")
print()
print("Reading: shared ride cuts the family's monthly all-in cost from about ₹15,700 (solo plan plus cab) to about ₹9,000, but it only earns a margin once a micro-market is dense (roughly 75+ families on common centres and shifts). "
      "It is a scale-stage tier, not a pilot offer. Riders must accept a pickup window and a longer ride.\n")

# ---------- C. Stay tier ----------
print("## C. 'Stay' tier: companion stays through the session (frail patients, or centres that require an attendant)\n")
stay_hours = 3.6 + 4.2
cost = stay_hours * 110
print(f"Active plus waiting time ≈ {stay_hours:.1f} h × ₹110 loaded = ₹{cost:,.0f} companion cost, matching v1's ₹715. A verified comparator is a ₹1,000+ per day attendant (HCAH).\n")
print("| Stay price per session ₹ | Other variable costs ₹ | Contribution ₹ | Margin |")
print("|---|---|---|---|")
for p in (1299, 1499, 1799, 1999):
    other = 65 + 0.0236 * p + 30
    print(f"| {p} | {r(other)} | {r(p - cost - other)} | {(p - cost - other) / p * 100:.0f}% |")
print()
print("A Stay tier at ₹1,499 to ₹1,799 is viable and sits near the verified attendant price, but it competes directly with informal attendants, so bypass is easiest here.\n")

# ---------- D. Segment-adjusted projection ----------
print("## D. 24-month projection at the ₹10,999 plan, by dialysis-fee tier (base ramp × multiplier, v1 overhead curve, ₹3.5 L setup)\n")
print("The session fee is the hospital's charge and is outside AnugaCare's revenue. It changes how many families can afford the escort. "
      "Multipliers are my judgement: ₹2,500 sessions make the escort about +52% of the dialysis bill (hard sell), ₹4,000 about +33%, ₹6,000 about +22%. "
      "Free-scheme (Aarogyasri/white card) patients pay no session fee and are assumed outside this segment.\n")


def run_ramp(unit_fn, mult, fx=m.fixed_curve):
    xs = [a for a, _ in pj.RAMP["base"]]
    ys = [b for _, b in pj.RAMP["base"]]
    cum = -pj.SETUP
    low = cum
    be = None
    y1 = y2 = rev1 = rev2 = 0
    for mo in range(1, 25):
        f = float(np.interp(mo, xs, ys)) * mult
        v = f * 10
        cm, rev_per = unit_fn(max(f, 1))
        net = v * cm - fx(f)
        cum += net
        low = min(low, cum)
        if net > 0 and be is None:
            be = mo
        if mo <= 12:
            y1 += net
            rev1 += v * rev_per
        else:
            y2 += net
            rev2 += v * rev_per
    return be, -low, y1, y2, cum, rev1, rev2


def solo_unit(f):
    u = m.unit(f, S1)
    return u["cm"], u["rev_per_completed"]


def pooled_unit(f):
    cm, _, _ = pooled_cm(f)
    return cm, PRICE_ALLIN


print("| Case | Ramp × | Peak families at month 24 | Break-even month | Peak cash need ₹ L | Y1 net | Y2 net | Cash at month 24 |")
print("|---|---|---|---|---|---|---|---|")
for nm, fn, mult in (("Solo plan ₹10,999, ₹6,000 sessions", solo_unit, 1.0),
                     ("Solo plan ₹10,999, ₹4,000 sessions", solo_unit, 1.0),
                     ("Solo plan ₹10,999, ₹2,500 sessions", solo_unit, 0.5),
                     ("Solo plan ₹10,999, ₹2,500 sessions, weak", solo_unit, 0.3),
                     ("Solo plan ₹10,999, 0.75 uptake", solo_unit, 0.75),
                     ("Shared ride ₹9,000 all-in, ₹2,500 sessions", pooled_unit, 0.8)):
    be, peak, y1, y2, end, r1, r2 = run_ramp(fn, mult)
    print(f"| {nm} | {mult} | {300 * mult:.0f} | {be or 'never'} | {peak / 1e5:,.1f} | {y1 / 1e5:,.1f} | {y2 / 1e5:,.1f} | {end / 1e5:,.1f} |")
print()
print("The ₹6,000 and ₹4,000 rows use the same ramp (×1.0) because I have no basis to separate them; the ramp itself is v1's assumption. "
      "Revenue ₹ L for the solo plan base case: Y1 and Y2 are in `model_v2_projection_results.md` pattern, scaled by the multiplier.\n")

print("### Solo plan at ₹10,999: ramp multiplier sweep\n")
print("| Ramp × | Families at month 24 | Break-even month | Peak cash need ₹ L | Cash at month 24 ₹ L |")
print("|---|---|---|---|---|")
for mult in (0.2, 0.3, 0.4, 0.5, 0.6, 0.75, 1.0, 1.25):
    be, peak, y1, y2, end, _, _ = run_ramp(solo_unit, mult)
    print(f"| {mult} | {300 * mult:.0f} | {be or 'never'} | {peak / 1e5:,.1f} | {end / 1e5:,.1f} |")
print()
print("Break-even depends mostly on overhead against family count, so a smaller segment needs a smaller organisation. The overhead curve here is v1's; a leaner one would move every row favourably.\n")
