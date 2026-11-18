"""v11: (A) two-week dialysis trial economics (DIALYSIS-SPECIFIC, scenario D1); (B) bottom-up COST FLOORS for other service categories.
Part B is NOT dialysis unit economics and not a forecast: it shows what each category must at least cover, from hours, wages and fixed costs, so that real prices
can be set only after measured data. All inputs [E] unless the report marks [V].
Run: python3 model_v11_trial_and_category_floors.py > model_v11_results.md
"""
import contextlib, io
with contextlib.redirect_stdout(io.StringIO()):
    import model_v2_sensitivity as m
    import model_v3_pricing_structure as m3
S1 = dict(m3.S1, vpf=12)

print("# v11: two-week trial economics (dialysis only) and category cost floors\n")
print("## A. Two-week Care Trial, dialysis scenario D1 only\n")
print("Offer: 6 round trips in 14 days (about 3 a week). Cab or auto fare is extra, prepaid at cost. Unused trips are refunded; the family can stop after any trip. "
      "No backup guarantee. The trial uses the same S1 cost structure as the pilot (companion ₹430 per trip, solo runs, 15 families of pilot scale). `[E]`\n")
ONBOARD = 400      # intake call, consent, ID card, messages
FIRST_TRIP_SUP = 430  # a second person supervises the first trip's handover
print("Per-family costs outside the trips: onboarding ₹400 and first-trip supervision ₹430 = ₹830. Acquisition cost per trial family is varied below.\n")
print("| Trial price (6 trips) | Per trip | Contribution per trip (15 families) | Expected trips delivered* | Contribution from trips ₹ | Less ₹830 set-up | **Net per trial family before CAC ₹** |")
print("|---|---|---|---|---|---|---|")
rows = []
for price in (3999, 4999, 5499, 5999):
    per = price / 6
    cm = m.unit(15, dict(S1, list=per, mixdisc=1.0))["cm"]
    exp_trips = 0.2 * 2 + 0.8 * 6
    net = exp_trips * cm - ONBOARD - FIRST_TRIP_SUP
    rows.append((price, per, cm, net))
    print(f"| ₹{price:,} | ₹{per:,.0f} | ₹{cm:,.0f} | {exp_trips:.1f} | {exp_trips * cm:,.0f} | 830 | **{net:,.0f}** |")
print("\n*Assumes 20% of families stop after trip 2 (refund of trips 3 to 6) and 80% finish. `[E]`\n")

print("### Value of converting a trial family to the plan (dialysis D1, S1 contribution about ₹4,000 per family-month at 12 trips)\n")
print("| Trial price | Conversion of completers | Months retained after plan | CAC ₹ | Expected value per trial family ₹ | Break-even conversion at CAC ₹3,000 |")
print("|---|---|---|---|---|---|")
for price, per, cm, net in rows:
    for conv in (0.3, 0.5, 0.7):
        for months in (6,):
            cac = 3000
            plan_cm = m.unit(40, S1)["cm_pre_acq"] * 12
            ev = net + 0.8 * conv * months * plan_cm - cac
            # break-even conversion
            be = max(0.0, (cac - net) / (0.8 * months * plan_cm))
            print(f"| ₹{price:,} | {int(conv * 100)}% | {months} | {cac:,} | {ev:,.0f} | {be * 100:.0f}% |")
print("\nBreak-even conversion is the share of trial completers who must move to the plan and stay 6 months for the trial to pay back its set-up cost and a ₹3,000 acquisition cost. Retention is `[E]` and unmeasured.\n")

print("### Trial terms that stay inside what you control\n")
print("- Six round trips within 14 days, booked on a fixed weekly pattern; trips start within a stated window after booking.\n"
      "- A named companion is confirmed 48 hours before each trip. If we cannot cover a trip we tell you at least 12 hours ahead where possible, refund it and add a ₹150 credit. "
      "**We do not promise a replacement companion** until measured replacement times exist.\n"
      "- Cancel up to 12 hours before a trip at no charge. Stop at any time; unused trips are refunded within 7 days.\n"
      "- The ₹500 deposit, if paid, is credited to the trial.\n")

print("## B. Cost floors for other service categories (illustrative, NOT dialysis economics)\n")
print("Method: floor = [companion hours × loaded rate × uplift + commute + per-visit costs] ÷ (1 − payment fee), plus a failure allowance. "
      "Loaded rate ₹110 per hour `[E]` (from ₹18,000 to ₹22,000 a month plus on-costs, against a Telangana ward-boy minimum wage of ₹15,960 `[V]`). "
      "Per-visit costs: insurance, support, messaging; categories with higher risk carry more. No overhead, founder pay, acquisition cost or margin is included, so a floor is the lowest price that avoids a direct loss, never a target price. "
      "Pass-through items (vehicle, tickets, meals) are excluded.\n")
cats = [
    # name, hours, companions, night uplift, commute, insurance, support, messaging, failure allowance, description
    ("Short visit (2 h, home or nearby)", 2.0, 1, 1.0, 60, 15, 30, 8, 0.05, "walk, conversation, errands, reading, tech help"),
    ("Long visit (4 h)", 4.0, 1, 1.0, 60, 25, 40, 8, 0.05, "longer company, meals, supervised activities at home"),
    ("Day outing (8 h door to door)", 8.0, 1, 1.0, 60, 60, 60, 15, 0.07, "temple, shopping, family function, cinema; vehicle and tickets pass-through"),
    ("Day outing, high support (wheelchair, 2 companions)", 8.0, 2, 1.0, 120, 90, 80, 15, 0.07, "mobility aids; two people"),
    ("Overnight (12 h, home or hospital bystander)", 12.0, 1, 1.25, 100, 80, 100, 15, 0.07, "night uplift 1.25 `[E]`; statutory overtime and night rules `[I]`"),
]
print("| Category | Hours | Companions | Night uplift | Companion cost ₹ | Commute ₹ | Insurance ₹ | Support ₹ | Messaging ₹ | Failure allowance | **Cost floor ₹** | Floor per companion-hour ₹ | What it covers |")
print("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
for nm, h, nc, up, comm, ins, sup, msg, fail, desc in cats:
    comp = h * nc * 110 * up
    subtotal = comp + comm + ins + sup + msg
    floor = subtotal * (1 + fail) / (1 - 0.0236)
    print(f"| {nm} | {h:g} | {nc} | {up:g} | {comp:,.0f} | {comm} | {ins} | {sup} | {msg} | {int(fail * 100)}% | **{floor:,.0f}** | {floor / (h * nc):,.0f} | {desc} |")
print("\nFloors are the outputs of the formula and nothing more. Commute, insurance and support figures for the longer categories are my guesses for higher risk and effort.\n")

print("### Published price anchors to compare with (all weak) `[V]`\n")
print("| Anchor | Price | Source quality |\n|---|---|---|")
for a, b, c in (("Gurugram companionship company", "₹450 per hour (10-hour pack), ₹400 per hour (25-hour pack)", "press, undated"),
                ("Third-party price list", "companionship ₹500 per hour; social outings ₹850 per hour; transport assistance ₹1,250 per hour", "unverified list"),
                ("Samarth (large elder-care platform)", "monthly plans from about ₹8,000 (Delhi page)", "provider marketing"),
                ("Synergia analysis, 2017", "from ₹150 for 1.5 hours up to ₹20,000 a month for weekly visits", "old"),
                ("Mumbai report", "₹2,500 to ₹4,000 per hour", "undated outlier"),
                ("HCAH attendant, Hyderabad", "₹1,000 or more per day", "vendor")):
    print(f"| {a} | {b} | {c} |")
print("\nUse of anchors: they show that someone has priced short companionship at about ₹400 to ₹500 an hour. They do not show demand in Hyderabad, cost to serve, or that AnugaCare can earn a margin there. "
      "Every category needs its own paid micro-pilot before any price is published.\n")
