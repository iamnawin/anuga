"""v9: companion pay maths, recruitment funnel cost, gig-fee effect. Reuses v2 engine and S1 (₹917 per trip, 12 trips). All [E] unless marked.
Run: python3 model_v9_companion_pay_and_funnel.py > model_v9_results.md
"""
import contextlib, io
with contextlib.redirect_stdout(io.StringIO()):
    import model_v2_sensitivity as m
    import model_v3_pricing_structure as m3
S1 = dict(m3.S1, vpf=12)
print("# v9: companion pay, funnel and gig-fee maths\n")

print("## 1. What does ₹430 per trip mean as an hourly rate?\n")
active, elapsed = 3.6, 6.5
print("| Basis | Hours | ₹ per hour at ₹430 | ₹ per hour at ₹390 (own two-wheeler) |\n|---|---|---|---|")
print(f"| Active time (travel, rides, handovers) | {active} | {430 / active:,.0f} | {390 / active:,.0f} |")
print(f"| Elapsed time (first pickup to second drop; includes the 3 h gap between legs) | {elapsed} | {430 / elapsed:,.0f} | {390 / elapsed:,.0f} |")
print("\nBenchmarks `[V]` unless noted: Telangana ward-boy minimum wage ₹15,960 a month from 1 Apr 2026 (about ₹77 an hour on 26 days × 8 h); Hyderabad ward-boy and patient-care job listings ₹16,000 to ₹24,000 (some ₹18,000 to ₹30,000), about ₹77 to ₹144 an hour; "
      "HCAH attendant ₹1,000+ a day; Rapido's own target of ₹70 to ₹80 an hour net after fuel for two-wheeler riders (company statement). "
      "Rapido and Uber earnings claims (₹65,000 to ₹100,000 a month per Rapido; older cab study ₹45,000 to ₹50,000 gross, about ₹10,000 net after EMI) are unverified and conflict.\n")
print("The gap between legs is only useful if the companion can fill it. A pickup due at 10:30 means no new ride after about 9:45. Two staggered patients a day make the gap productive.\n")

print("## 2. Companion monthly income by trips (₹430 per trip, ₹390 with own two-wheeler)\n")
print("| Trips per month | Per week | ₹430 | ₹390 | Comparable to |\n|---|---|---|---|---|")
for t, c in ((20, "part-time top-up"), (30, "part-time"), (37, "pilot density: 150 visits ÷ 4 companions"), (45, "matches ward-boy entry wage"), (52, "2 trips a day"), (78, "3 trips a day, scale-stage")):
    print(f"| {t} | {t / 4.33:.0f} | {t * 430:,} | {t * 390:,} | {c} |")
print()

print("## 3. Minimum guarantee exposure during the pilot\n")
print("| Companions | Guarantee per month | Maximum monthly exposure if no trips | Likely exposure at 37 trips each (₹430) |\n|---|---|---|---|")
for n, g in ((4, 6000), (4, 8000), (5, 8000)):
    print(f"| {n} | ₹{g:,} | ₹{n * g:,} | ₹{max(0, n * (g - 37 * 430)):,} |")
print("\nAt 37 trips (₹15,910) a guarantee of ₹8,000 never binds. It only matters in weak months, early weeks, and for companions on fewer than about 19 trips. Offer it after 20 completed trips.\n")

print("## 4. Cost to hire one companion (vetting, training, kit) `[E]`\n")
rows = [("Application screening and interviews (founder time)", 0), ("Identity and e-KYC", 150), ("Police or court check, address check (vendor blogs report ₹250 to ₹2,000 court, ₹250 to ₹1,000 address)", 1500),
        ("Basic medical fitness check", 500), ("Training 2 to 3 days (trainer fee share, materials, first-aid)", 3500), ("Paid training and shadow days (3 days × ₹600)", 1800), ("ID card, uniform, kit", 800)]
tot = sum(c for _, c in rows)
print("| Item | ₹ |\n|---|---|")
for a, b in rows:
    print(f"| {a} | {b:,} |")
print(f"| **Total per hired companion** | **{tot:,}** |")
print("\n| Pass rate from applicants | Applicants needed for 5 companions | Screening cost at ₹150 per applicant | Total hiring cost for 5 |\n|---|---|---|---|")
for p in (0.05, 0.10, 0.20):
    need = 5 / p
    print(f"| {int(p * 100)}% | {need:.0f} | ₹{need * 150:,.0f} | ₹{5 * tot + need * 150:,.0f} |")
print("\nIncludes a ₹150 per-applicant screening cost (phone ID check). Pass rates are my judgement. The setup budget in earlier files allowed ₹40,000 for recruitment, vetting and training of 5 companions; this is about ₹45,000 to ₹56,000 plus attrition.\n")

print("## 5. Gig-worker levy effect `[U]` whether it applies\n")
print("Telangana's 2026 platform gig-workers Act reportedly sets an aggregator fee of 1% to 2% of transaction value, not deductible from worker pay `[V]` secondary reports; applicability to AnugaCare is `[I]`.\n")
print("| Levy | Per trip at ₹917 | CM per trip (S1, 40 families) |\n|---|---|---|")
base = m.unit(40, S1)["cm"]
for l in (0, 0.01, 0.02):
    print(f"| {int(l * 100)}% | ₹{917 * l:,.0f} | ₹{base - 917 * l:,.0f} |")
print()
