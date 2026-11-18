"""v7: what if the companion owns a vehicle. Reuses v2 engine and S1 (₹10,999 for 12 trips). All [E].
Run: python3 model_v7_companion_vehicle.py > model_v7_results.md
"""
import contextlib, io
with contextlib.redirect_stdout(io.StringIO()):
    import model_v2_sensitivity as m
    import model_v3_pricing_structure as m3
S1 = dict(m3.S1, vpf=12)
KM = 40  # total km per drop-and-return trip incl. companion's solo legs and deadhead (6+8+6 + 6+8+6) [E]
print("# v7: companion with an own vehicle\n")
print("Distance per round trip: 16 km with the patient plus about 24 km of companion solo legs (to the home, away, back to the centre, away) = about 40 km `[E]`. "
      "Operating cost per km (fuel, tyres, servicing, insurance, depreciation) `[E]`: two-wheeler ₹3, CNG auto ₹4.5, hatchback ₹11.\n")
print("## 1. Vehicle cost per trip and what it does to delivered cost\n")
print("| Vehicle | Operating cost per km ₹ | Cost for 40 km ₹ | Can carry the patient? | Companion time pay ₹ | Total delivered cost ₹ | Baseline: cab ₹388 + pay ₹430 = ₹818 |")
print("|---|---|---|---|---|---|---|")
for nm, c, carry, pay in (("Two-wheeler (companion's own legs only)", 3, "No (pillion unsafe post-dialysis); cab still needed", 330), 
                          ("CNG auto, commercial permit", 4.5, "Yes, but basic comfort", 330),
                          ("Hatchback, commercial permit", 11, "Yes", 330)):
    veh = c * KM
    if "Two" in nm:
        tot = 388 + 330 + 3 * 24  # cab for patient + time pay + bike for solo legs only
        print(f"| {nm} | {c} | {3 * 24:.0f} (solo legs only) | {carry} | {pay} | {tot:.0f} | saves about {818 - tot:.0f} |")
    else:
        tot = veh + pay
        print(f"| {nm} | {c} | {veh:.0f} | {carry} | {pay} | {tot:.0f} | {'saves' if tot < 818 else 'costs'} about {abs(818 - tot):.0f} |")
print()
print("Deadhead kilometres are the problem: only 16 of about 40 km are billable patient distance, so a car saves almost nothing against an aggregator cab plus a ₹60 commute allowance. Only a cheap-to-run vehicle (auto, bike for the solo legs) saves money.\n")
print("## 2. Contribution per trip, S1 plan (₹917), 40 families\n")
print("| Case | Companion effective pay ₹ | Customer fare per round trip ₹ | Contribution per trip ₹ | Customer saves per month ₹ |")
print("|---|---|---|---|---|")
for nm, pay, fare in (("Baseline: no vehicle, aggregator cab", 430, 388),
                      ("Companion owns a two-wheeler (commute allowance ₹60 → ₹20)", 390, 388),
                      ("Companion owns a CNG auto, patient pays meter fare", 330, 239)):
    u = m.unit(40, dict(S1, pay=pay))
    print(f"| {nm} | {pay} | {fare} | {u['cm']:.0f} | {(388 - fare) * 12:,.0f} |")
print()
print("In the auto case the companion also keeps the fare (₹239) against about ₹180 running cost, so their take is about ₹330 + ₹59 = ₹389 per trip, a little below the baseline ₹430 + commute, which is why the pay is a judgement and may need to be higher.\n")
