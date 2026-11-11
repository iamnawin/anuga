"""v8: ideal-patient economics, 'Safe Return' tier for patients who travel alone, and expansion hypotheses beyond dialysis.
Reuses v2 engine and S1. All [E] unless the report marks [V]. Run: python3 model_v8_ideal_patient_and_expansion.py > model_v8_results.md
"""
import contextlib, io
with contextlib.redirect_stdout(io.StringIO()):
    import model_v2_sensitivity as m
    import model_v3_pricing_structure as m3
S1 = dict(m3.S1, vpf=12)
print("# v8: ideal patient, Safe Return tier, expansion hypotheses\n")

print("## 1. Is the service worth it for the family? Time value of the escort\n")
print("Family member's time freed per trip: 7 hours (about 3 travel/handover + 4 waiting) `[E]`; 12 trips = 84 hours. "
      "The cab or fuel cost is paid either way, so the **incremental** cost of AnugaCare is the service fee, not the fare. "
      "Value only counts if the time is real (unpaid leave, lost work, or a family member who would otherwise be free).\n")
print("| Family member's annual income | Value per hour ₹ (2,000 h/year) | Value of 84 hours ₹ | Plan fee ₹ | Value ÷ fee |")
print("|---|---|---|---|---|")
for inc in (3e5, 6e5, 12e5, 24e5):
    h = inc / 2000
    print(f"| ₹{inc / 1e5:.0f} L | {h:,.0f} | {84 * h:,.0f} | 10,999 | {84 * h / 10999:.1f}× |")
be_h = 10999 / 84
print(f"\nBreak-even: the plan pays for itself in time value if the family member's time is worth more than about ₹{be_h:,.0f} per hour, roughly ₹{be_h * 2000 / 1e5:.1f} L a year.\n")

print("## 2. Ideal patient scorecard (for screening interviews and the deposit test)\n")
print("| Signal | Fits | Does not fit |\n|---|---|---|")
for a, b, c in (
    ("Frequency", "Three times a week (12 to 13 trips)", "Twice a week or less"),
    ("Age and frailty", "60+, or weak and dizzy after sessions, or uses a stick or wheelchair", "Fit, independent, travels alone happily"),
    ("Who escorts today", "A working child or spouse who loses a day, or no one reliable", "A retired relative with free time"),
    ("Session fee", "₹3,500+ per session, private or corporate centre", "Free scheme (white card), or tight budget at ₹2,500"),
    ("Geography", "Within about 8 km of 2 to 3 target centres, in one micro-market", "Over 15 km or scattered"),
    ("Spending today", "Pays an attendant ₹1,000+ a day or books cabs for every trip", "Uses free bus or walks"),
    ("Care need", "Non-clinical help only", "Needs clinical monitoring in transit (ambulance case)")):
    print(f"| {a} | {b} | {c} |")
print()

print("## 3. Patients who come and go alone: a lighter tier\n")
print("Many patients settle in and manage; the risky part is the return home after the session (fatigue and low blood pressure, recovery median about 4 hours in one study `[V]`). "
      "A one-way **Safe Return** (meet at the centre, ride home, hand to family) costs less companion time than a round trip.\n")
print("| Tier | Price | Companion pay ₹ | Contribution per trip (40 families) | Per month at 12 trips |")
print("|---|---|---|---|---|")
sr_pay = 260
for nm, price, pay in (("Safe Return ₹549 per trip, 12 trips = ₹6,499", 6499 / 12, sr_pay), ("Safe Return ₹649 per trip, 12 trips = ₹7,799", 7799 / 12, sr_pay),
                       ("Door-to-Door plan ₹10,999 (S1)", 10999 / 12, 430)):
    u = m.unit(40, dict(S1, list=price, pay=pay))
    print(f"| {nm} | {price:,.0f} per trip | {pay} | {u['cm']:,.0f} | {u['cm'] * 12:,.0f} |")
print("\nSafe Return pay is `[E]`: about half of the round-trip effort. It is a feeder for families not yet ready for ₹10,999, and a way to serve solo travellers.\n")

print("## 4. Beyond dialysis: hypotheses to test (not validated)\n")
print("Same drop-and-return or wait-in-place design. Companion cost uses ₹110 per loaded hour for waiting designs, ₹430 for a dialysis-style drop-and-return. Other variable costs ₹130 per trip. `[E]` throughout; visit patterns are general knowledge, not sourced here.\n")
print("| Service | Visits per month | Visit pattern | Companion design | Price per trip ₹ | Cost per trip ₹ | Contribution per trip ₹ | Per family-month ₹ | Tenure | Fit |")
print("|---|---|---|---|---|---|---|---|---|---|")
rows = [("Dialysis (3 a week)", 12, "4 to 5 h session", "drop-and-return", 917, 430, "ongoing", "Core"),
        ("Chemotherapy day care", 2.5, "6 to 8 h infusion every 1 to 3 weeks", "drop-and-return", 917, 430, "months", "Good per trip, low frequency"),
        ("Radiotherapy course", 22, "short sessions, 1.5 to 2 h door to door waiting", "wait in place", 799, 3.3 * 110, "1 to 2 months", "High frequency, short tenure"),
        ("Physiotherapy / cardiac rehab", 10, "1 h session, 3 times a week", "wait in place", 699, 3.0 * 110, "1 to 3 months", "Moderate"),
        ("Elderly OPD and follow-ups", 1.5, "3 h hospital day", "wait in place", 1299, 5.0 * 110, "ongoing", "Low frequency, high effort")]
for nm, v, pat, des, price, pay, ten, fit in rows:
    cost = pay + 130 + 0.05 * price
    cm = price - cost
    print(f"| {nm} | {v} | {pat} | {des} | {price} | {cost:,.0f} | {cm:,.0f} | {cm * v:,.0f} | {ten} | {fit} |")
print()
print("Reading: dialysis has the best mix of frequency, tenure and predictable schedule. Chemo adds high-value, low-frequency use; radiotherapy and physiotherapy add volume but short tenure, "
      "which raises acquisition cost per rupee earned. Expansion should follow a working dialysis model in one micro-market, not run in parallel.\n")
