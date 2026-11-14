"""24-month projection with v2 unit economics. Reuses the v2 engine (model_v2_sensitivity.py) and v1's ramps and setup cost.
Run: python3 model_v2_projection.py > model_v2_projection_results.md
All inputs are [E]. v1 files are unchanged in v1-original/.
"""
import contextlib
import io
import numpy as np

with contextlib.redirect_stdout(io.StringIO()):  # the sensitivity module prints its tables on import
    import model_v2_sensitivity as m

RAMP = {  # v1 family ramps, unchanged
    "conservative": [(0, 0), (3, 10), (9, 25), (12, 45), (18, 70), (24, 90)],
    "base": [(0, 0), (3, 15), (9, 50), (12, 100), (18, 200), (24, 300)],
    "optimistic": [(0, 0), (3, 20), (9, 80), (12, 150), (18, 300), (24, 450)]}
SETUP = 350000
PARAMS = {"conservative": m.CON, "base": m.BASE, "optimistic": m.OPT}
LEAN_FX = [(0, 60000), (15, 100000), (75, 220000), (400, 800000)]  # alt: tighter overhead, my assumption


def fixed_alt(f):
    return float(np.interp(f, [a for a, _ in LEAN_FX], [b for _, b in LEAN_FX]))


def run(name, P, fx):
    xs = [a for a, _ in RAMP[name]]
    ys = [b for _, b in RAMP[name]]
    cum = -SETUP
    low = cum
    be = None
    rows = []
    for mo in range(1, 25):
        f = float(np.interp(mo, xs, ys))
        v = f * P["vpf"]
        u = m.unit(max(f, 1), P)
        rev = v * u["rev_per_completed"]
        contrib = v * u["cm"]
        fixed = fx(f)
        net = contrib - fixed
        cum += net
        low = min(low, cum)
        if net > 0 and be is None:
            be = mo
        rows.append((mo, f, v, rev, contrib, fixed, net, cum))
    y1 = [x for x in rows if x[0] <= 12]
    y2 = [x for x in rows if x[0] > 12]
    return dict(rows=rows, be=be, peak=-low, y1rev=sum(x[3] for x in y1), y1net=sum(x[6] for x in y1),
                y2rev=sum(x[3] for x in y2), y2net=sum(x[6] for x in y2), end=rows[-1][7])


def L(x):
    return f"{x / 1e5:,.1f}"


print("# 24-month projection with v2 costs\n")
print("Same family ramps and ₹3.5 L setup as v1. Unit economics from `model_v2_sensitivity.py`. "
      "Revenue is service fee only (fare is pass-through). ₹ lakh unless stated. All `[E]`.\n")
print("Overhead curves: **v1 curve** = (0, 60k), (15, 82k), (75, 299k), (400, 1.1 M) per month, founders at ₹0 until 75 families then ₹40k. "
      "**Alt lean curve** = (0, 60k), (15, 100k), (75, 220k), (400, 800k): an assumption that you keep overhead tighter but pay a stipend early. "
      "Neither is data.\n")


def summary(label, price_over=None, gst=None, curve=m.fixed_curve):
    print(f"### {label}\n")
    print("| Scenario | Break-even month | Peak cash need | Y1 revenue | Y1 net | Y2 revenue | Y2 net | Cash at month 24 |")
    print("|---|---|---|---|---|---|---|---|")
    for n in ("conservative", "base", "optimistic"):
        P = dict(PARAMS[n])
        if price_over:
            P["list"] = price_over
        if gst:
            P["gst"] = gst
        o = run(n, P, curve)
        print(f"| {n} | {o['be'] or 'never'} | {L(o['peak'])} | {L(o['y1rev'])} | {L(o['y1net'])} | {L(o['y2rev'])} | {L(o['y2net'])} | {L(o['end'])} |")
    print()


summary("A. ₹799 list, v2 costs, v1 overhead curve (like-for-like with v1)")
summary("B. ₹799 list, v2 costs, alt lean overhead curve", curve=fixed_alt)
summary("C. ₹899 list, v2 costs, v1 overhead curve", price_over=899)
summary("D. ₹999 list, v2 costs, v1 overhead curve", price_over=999)
summary("E. ₹799 list, 18% GST absorbed (tax-inclusive price), v1 overhead curve", gst="absorb")
summary("F. ₹899 list, 18% GST absorbed, v1 overhead curve", price_over=899, gst="absorb")

print("### v1 published results, for comparison (₹750 realised, v1 costs)\n")
print("| Scenario | Break-even month | Peak cash need | Y1 revenue | Y1 net | Y2 revenue | Y2 net |")
print("|---|---|---|---|---|---|---|")
print("| conservative | never | 33.0 | 13.7 | −9.2 | 46.8 | −20.3 |")
print("| base | 15 | 9.3 | 36.9 | −5.5 | 187.5 | +6.8 |")
print("| optimistic | 7 | 4.6 | 65.2 | +2.6 | 325.9 | +59.6 |")
print()

print("### Base case month by month, scenario A (₹799, v2 costs, v1 overhead curve)\n")
o = run("base", m.BASE, m.fixed_curve)
print("| Month | Families | Visits | Revenue ₹k | Contribution ₹k | Overhead ₹k | Net ₹k | Cumulative ₹k |")
print("|---|---|---|---|---|---|---|---|")
for r_ in o["rows"]:
    if r_[0] in (1, 3, 6, 9, 12, 15, 18, 21, 24):
        print(f"| {r_[0]} | {r_[1]:.0f} | {r_[2]:.0f} | " + " | ".join(f"{x / 1000:,.0f}" for x in r_[3:]) + " |")
print()

print("### Corrected pilot-stage cash (months 1 to 6, base ramp, ₹799, founders unpaid)\n")
o = run("base", m.BASE, m.fixed_curve)
c6 = o["rows"][5][7]
print(f"Cumulative cash after month 6 including ₹3.5 L setup: ₹{c6 / 1e5:,.1f} L.\n")
print("Reading: see the report addendum. Re-running the ramps does not make the business more certain; it shows which price and overhead choices keep it solvent.\n")
