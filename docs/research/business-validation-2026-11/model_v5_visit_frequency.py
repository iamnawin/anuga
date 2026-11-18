"""v5: effect of visits per family per month (dialysis frequency) on the ₹10,999 plan.
Reuses v2 engine, v1 ramp/overhead curve, S1 structure. All [E] (frequency itself is founder input: mostly 3 sessions a week).
Run: python3 model_v5_visit_frequency.py > model_v5_results.md
"""
import contextlib
import io
import numpy as np

with contextlib.redirect_stdout(io.StringIO()):
    import model_v2_sensitivity as m
    import model_v2_projection as pj
    import model_v3_pricing_structure as m3

S1 = m3.S1


def r(x, n=0):
    return f"{x:,.{n}f}"


def run(vpf, mult, price_trip=None, fx=m.fixed_curve):
    S = dict(S1, vpf=vpf)
    if price_trip:
        S["list"] = price_trip
    xs = [a for a, _ in pj.RAMP["base"]]
    ys = [b for _, b in pj.RAMP["base"]]
    cum = -pj.SETUP
    low = cum
    be = None
    y1 = y2 = 0
    for mo in range(1, 25):
        f = float(np.interp(mo, xs, ys)) * mult
        u = m.unit(max(f, 1), S)
        net = f * vpf * u["cm"] - fx(f)
        cum += net
        low = min(low, cum)
        if net > 0 and be is None:
            be = mo
        if mo <= 12:
            y1 += net
        else:
            y2 += net
    return be, -low, y1, y2, cum


print("# v5: dialysis frequency (visits per family per month)\n")
print("Founder input: 12 per 4-week cycle is the base, most patients dialyse three times a week (about 13 per calendar month), some twice a week. "
      "Earlier models assumed 10 escorted trips per family per month. All else as S1 (₹10,999 plan, effective companion pay ₹430). `[E]`\n")

print("## 1. Sessions per month by weekly frequency\n")
print("| Pattern | Sessions per 4 weeks | Sessions per calendar month (4.33 weeks) |\n|---|---|---|")
for n, lab in ((2, "Twice a week"), (3, "Three times a week"), (4, "Four times a week (less common)")):
    print(f"| {lab} | {n * 4} | {n * 4.33:.1f} |")
print()

print("## 2. Family economics by trips per month (S1 unit economics, 40 families)\n")
print("| Trips per month | Contribution per trip ₹ | Contribution per family-month ₹ | Service revenue per family ₹ (at ₹917/trip) | Fare per month (cab mid, 8 km) | Total family bill ₹ | As % of dialysis at ₹2,500 | At ₹4,000 |")
print("|---|---|---|---|---|---|---|---|")
for v in (8, 9, 10, 12, 13, 17):
    S = dict(S1, vpf=v)
    u = m.unit(40, S)
    rev = v * u["real"]
    fare = v * 388
    tot = rev + fare
    print(f"| {v} | {r(u['cm'])} | {r(u['cm'] * v)} | {r(rev)} | {r(fare)} | {r(tot)} | {tot / (v * 2500) * 100:.0f}% | {tot / (v * 4000) * 100:.0f}% |")
print()
print("Per-trip economics barely move (only replacement acquisition cost is spread over more trips). What changes is **how many trips each family brings**, which spreads overhead, and **the monthly bill**.\n")

print("## 3. Break-even visits and families, S1, overhead bases (contribution at 30 families)\n")
print("| Trips per family per month | CM per trip ₹ | Families to cover ₹82k | ₹112k | ₹142k |")
print("|---|---|---|---|---|")
for v in (8, 10, 12, 13):
    S = dict(S1, vpf=v)
    cm = m.unit(30, S)["cm"]
    print(f"| {v} | {r(cm)} | {r(82000 / cm / v)} | {r(112000 / cm / v)} | {r(142000 / cm / v)} |")
print()

print("## 4. 24-month projection, S1 at ₹10,999 for 12 trips (₹917 per trip), v1 overhead curve, by trips per family and ramp (₹ lakh)\n")
print("Ramp × is a judgement for segment size: ×1.0 for ₹4,000+ session families, ×0.5 for ₹2,500 session families (see v4).\n")
print("| Trips per family | Ramp × | Break-even month | Peak cash need | Y1 net | Y2 net | Cash at month 24 |")
print("|---|---|---|---|---|---|---|")
for mult in (1.0, 0.5):
    for v in (8, 10, 12, 13):
        be, peak, y1, y2, end = run(v, mult)
        print(f"| {v} | {mult} | {be or 'never'} | {peak / 1e5:,.1f} | {y1 / 1e5:,.1f} | {y2 / 1e5:,.1f} | {end / 1e5:,.1f} |")
print()

print("## 5. Plan sizing options for a 3-a-week patient\n")
print("| Option | Trips | Price | Per trip | Note |\n|---|---|---|---|---|")
print("| A. 4-week plan | 12 | ₹10,999 | ₹917 | Matches the 4-week cycle; renews every 28 days (13 cycles a year, not 12) |")
print("| B. Calendar-month plan | 13 | ₹11,899 | ₹915 | Same per-trip price as A, billed monthly |")
print("| C. Calendar-month plan, 13 trips, flat | 13 | ₹10,999 | ₹846 | Looks simpler, but gives away about ₹70 per trip. Contribution falls below ₹300 |")
print("| D. Twice a week | 8 to 9 | ₹7,999 | about ₹890 | Lower frequency, same per-trip rate |")
u_c = m.unit(40, dict(S1, vpf=13, list=10999 / 13))
print(f"\nOption C contribution per trip at 40 families: ₹{u_c['cm']:.0f} (vs ₹{m.unit(40, dict(S1, vpf=13))['cm']:.0f} for A/B).\n")
print("Monthly family bill at 13 trips, cab mid: ₹11,899 + ₹5,044 fare = about ₹16,900. At ₹2,500 per session (₹32,500 dialysis) that is about 52%; at ₹4,000 (₹52,000) about 33%.\n")
