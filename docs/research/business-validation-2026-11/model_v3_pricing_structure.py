"""v3: pricing structure designed to resist companion/customer disintermediation (bypass).
Reuses the v2 unit engine and v1 ramps/overhead curve. All inputs [E].
Run: python3 model_v3_pricing_structure.py > model_v3_pricing_structure_results.md
"""
import contextlib
import io
import numpy as np

with contextlib.redirect_stdout(io.StringIO()):
    import model_v2_sensitivity as m
    import model_v2_projection as pj

BASE = m.BASE
PLAN12 = 10999          # proposed monthly plan, 12 round trips, fare extra
PER_TRIP_PLAN = PLAN12 / 12

S0 = dict(BASE, name="S0 current: ₹799 per trip, packs 60% 12-pack", pay=380)
S1 = dict(BASE, name="S1 Care Plan ₹10,999/12 trips, month 1-6", list=PER_TRIP_PLAN, mixdisc=1.0, pay=430)
S2 = dict(BASE, name="S2 same family, month 13+ (price -8%, pay ladder)", list=PER_TRIP_PLAN * 0.92, mixdisc=1.0, pay=460)
S3 = dict(BASE, name="S3 premium plan ₹11,999/12 trips", list=11999 / 12, mixdisc=1.0, pay=460)
S4 = dict(BASE, name="S4 ₹9,999/12 trips, pay 430", list=9999 / 12, mixdisc=1.0, pay=430)


def r(x, n=0):
    return f"{x:,.{n}f}"


print("# v3: pricing structure and bypass resistance, calculations\n")
print("All `[E]`. `pay` is effective companion cost per visit including commute allowance and the average retention bonus. "
      "Contribution includes failed visits, waiting, payment fees and replacement acquisition cost (v2 engine).\n")

print("## 1. Contribution per completed visit by structure\n")
print("| Structure | Fee per trip ₹ | Companion effective pay ₹ | Pay as % of fee | CM @15 | CM @40 | CM @75 | Margin @40 |")
print("|---|---|---|---|---|---|---|---|")
for S in (S0, S1, S2, S3, S4):
    u15, u40, u75 = (m.unit(f, S) for f in (15, 40, 75))
    print(f"| {S['name']} | {r(u40['real'])} | {r(S['pay'])} | {S['pay'] / u40['real'] * 100:.0f}% | {r(u15['cm'])} | {r(u40['cm'])} | {r(u75['cm'])} | {u40['cm'] / u40['real'] * 100:.0f}% |")
print()

print("## 2. Companion pay design (illustrative, per round trip ≤8 km)\n")
print("| Component | ₹ | Note |\n|---|---|---|")
rows = [("Base for time on the job", 330, "about 3.6 active hours"), ("Commute allowance (two solo legs)", 60, "paid on every trip"),
        ("Retention bonus ÷ trips", 40, "₹1,500 per month if at least 30 trips, at least 95% on time, no direct-dealing breach. ₹50 per trip at 30 trips, ₹25 at 60")]
for a, b, c in rows:
    print(f"| {a} | {b} | {c} |")
print("| **Effective pay used in S1** | **430** | Tenure ladder adds +₹10 per trip every 6 months up to +₹30 (S2 uses 460) |\n")
print("Also paid by AnugaCare, not the companion: accident cover, training, ID kit, weekly payout, a minimum monthly guarantee once the companion is on 3+ regular families.\n")

print("## 3. What each side gains by going direct (per family per month, 12 trips, fare identical either way)\n")
print("A direct deal needs the companion to quote below the family's price but above what AnugaCare pays. ₹600 to ₹800 per round trip is my guess at what a freelance companion would ask `[E]`; "
      "a verified comparator is a ₹1,000 per day attendant (HCAH).\n")
print("| Direct price per trip ₹ | Family saves per month vs ₹10,999 plan | Family saves % | Companion earns per month direct | Companion earns via AnugaCare (₹430) | Companion gain |")
print("|---|---|---|---|---|---|")
for p in (600, 700, 800, 900):
    fam = PLAN12 - 12 * p
    print(f"| {p} | {r(fam)} | {fam / PLAN12 * 100:.0f}% | {r(12 * p)} | {r(12 * 430)} | {r(12 * p - 12 * 430)} (+{(p / 430 - 1) * 100:.0f}%) |")
print()
print("**Reading:** at a ₹700 direct deal the companion earns about 63% more and the family saves about 24%. Both sides win on paper. The incentive is real, so the defence must be (a) making AnugaCare's extras worth that gap and (b) keeping the gap small.\n")

print("## 4. What the family and the companion lose by going direct\n")
print("| Item | Family loses | Companion loses |")
print("|---|---|---|")
print("| Backup if the companion is ill or on leave | A missed dialysis session is clinically serious. One uncovered trip a month is the real cost | Sick-day cover and a replacement who takes their families |")
print("| Insurance and incident handling | Cover for a fall or a missed handover | Accident cover |")
print("| Verified identity and OTP/handover record | Proof of who collected the patient and when | Protection if a family disputes a trip |")
print("| Centre acceptance | Centres may accept only registered, ID-checked providers (to be confirmed) | Same |")
print("| Dense shifts | n/a | Batched, back-to-back runs; direct work is one family at a time with idle gaps |")
print("| Pay certainty | One invoice, one prepaid wallet | Weekly payout even when a family delays |")
print("| Price lock and loyalty step-downs | Forfeited | n/a |\n")

print("## 5. Effect of bypass on the 24-month plan (base ramp, v1 overhead curve, ₹3.5 L setup)\n")
print("Bypass modelled as a share of families permanently lost to direct deals, phased in linearly over 24 months. "
      "Overhead is sized to gross families (the organisation does not shrink when families leave). Companion re-training cost not included.\n")


def run_bypass(S, share):
    xs = [a for a, _ in pj.RAMP["base"]]
    ys = [b for _, b in pj.RAMP["base"]]
    cum = -pj.SETUP
    low = cum
    be = None
    y1 = y2 = 0
    for mo in range(1, 25):
        f = float(np.interp(mo, xs, ys))
        fe = f * (1 - share * min(1, mo / 24))
        v = fe * S["vpf"]
        u = m.unit(max(fe, 1), S)
        net = v * u["cm"] - m.fixed_curve(f)
        cum += net
        low = min(low, cum)
        if net > 0 and be is None:
            be = mo
        if mo <= 12:
            y1 += net
        else:
            y2 += net
    return be, -low, y1, y2, cum


print("| Structure | Share of families lost to bypass by month 24 | Break-even month | Peak cash need ₹ L | Y1 net ₹ L | Y2 net ₹ L | Cash at month 24 ₹ L |")
print("|---|---|---|---|---|---|---|")
for S in (S0, S1, S3):
    for sh in (0.0, 0.10, 0.25, 0.40):
        be, peak, y1, y2, end = run_bypass(S, sh)
        print(f"| {S['name']} | {int(sh * 100)}% | {be or 'never'} | {peak / 1e5:,.1f} | {y1 / 1e5:,.1f} | {y2 / 1e5:,.1f} | {end / 1e5:,.1f} |")
print()
print("Note: S1 and S3 assume families accept ₹917 and ₹1,000 per trip, which is **untested**. S0 is the original ₹799 structure with v2 costs.\n")

print("## 6. Introduction (conversion) fee for families who want to hire directly\n")
fam_cm = m.unit(40, S1)["cm_pre_acq"] * 12
print(f"Contribution per family-month on S1 ≈ ₹{fam_cm:,.0f}. A one-time introduction fee of ₹12,000 equals about {12000 / fam_cm:.1f} months of that contribution, "
      "plus the recruitment, vetting and training already sunk in the companion (₹5k to ₹6k `[E]`). It is a pricing option, not a legal certainty; see the report.\n")
