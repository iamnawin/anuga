"""v10: scheduling simulation for one companion's day. Drop-and-return design.
Real-world constraints: delayed session starts, overrunning sessions, recovery wait before discharge, traffic, commute gaps between legs,
overlapping pickup/return windows, batching patients on one run, delay cascade from leg to leg.
All inputs [E]; the founder confirmed only that a session is 4 to 5 hours and door-to-door 6 to 7 hours.
Run: python3 model_v10_scheduling.py > model_v10_results.md
"""
import contextlib
import io
import math
import numpy as np

with contextlib.redirect_stdout(io.StringIO()):
    import model_v2_sensitivity as m
    import model_v3_pricing_structure as m3

S1 = dict(m3.S1, vpf=12)
N = 4000
SHIFT_START = {1: 7 * 60, 2: 11 * 60 + 30, 3: 16 * 60}  # planned session starts (minutes after midnight) [E]: three shifts, 30 min turnaround


def LN(rng, mean, cv):
    s2 = math.log(1 + cv * cv)
    return float(rng.lognormal(math.log(mean) - s2 / 2, math.sqrt(s2)))


def traffic(t):
    return 1.2 if (6.5 * 60 <= t < 10 * 60 or 17 * 60 <= t < 20.5 * 60) else 1.0


SCEN = {
    "low delay": dict(start_mu=4, start_sd=8, over_mu=2, over_sd=10, p_extra=0.08, cv_t=0.25),
    "base": dict(start_mu=8, start_sd=12, over_mu=5, over_sd=18, p_extra=0.15, cv_t=0.35),
    "high delay": dict(start_mu=15, start_sd=18, over_mu=10, over_sd=25, p_extra=0.25, cv_t=0.45)}

# Day plans are lists of legs: ("drop", shift, n_patients), ("pick", shift, n_patients), ("swap", shift_in, shift_out).
# A swap run delivers the next-shift patient to the centre and, in the same trip, collects the patient who has just finished.
def solo(sh):
    return [("drop", sh, 1), ("pick", sh, 1)]


CONFIGS = {
    "K1  solo round trip, S1 only": solo(1),
    "K2a solo S1 + solo S3 (non-adjacent, one person)": solo(1) + solo(3),
    "K2b solo S1 + solo S2 (adjacent shifts, one person)": solo(1) + solo(2),
    "K3  batch of 2 in S1": [("drop", 1, 2), ("pick", 1, 2)],
    "K4  batch of 3 in S1": [("drop", 1, 3), ("pick", 1, 3)],
    "K5  morning crew: drop S1, then swap S2-in / S1-out": [("drop", 1, 1), ("swap", 2, 1)],
    "K6  afternoon crew: swap S3-in / S2-out, then pick S3": [("swap", 3, 2), ("pick", 3, 1)],
    "K7  two-shift centre, one person: drop S1, swap S2/S1, pick S2": [("drop", 1, 1), ("swap", 2, 1), ("pick", 2, 1)],
    "K8  three-shift chain, one person: drop S1, swap, swap, pick S3": [("drop", 1, 1), ("swap", 2, 1), ("swap", 3, 2), ("pick", 3, 1)],
    "K9  batch of 2 in S1 + batch of 2 in S3 (one person)": [("drop", 1, 2), ("pick", 1, 2), ("drop", 3, 2), ("pick", 3, 2)]}
# pay per patient-leg (₹): solo 215 (half of ₹430); batch of 2 about 165; batch of 3 about 140; swap run 300 for two patient-legs [E]
LEG_PAY = {("solo"): 215, ("b2"): 165, ("b3"): 140}
SWAP_PAY = 300
DROP_WORK = lambda n: 22 + 10 * n + 10 * (n - 1) + 40 + 8 * (n - 1)


def leg_pay(lg):
    if lg[0] == "swap":
        return SWAP_PAY
    n = lg[2]
    return n * (LEG_PAY["solo"] if n == 1 else LEG_PAY["b2"] if n == 2 else LEG_PAY["b3"])


def patient_legs(lg):
    return 2 if lg[0] == "swap" else lg[2]


def plan(config):
    legs = []
    for lg in config:
        kind = lg[0]
        if kind == "drop":
            sh, n = lg[1], lg[2]
            ss = SHIFT_START[sh]
            legs.append(dict(kind="drop", sh=sh, n=n, planned=ss - 15 - DROP_WORK(n), ss=ss, raw=lg))
        elif kind == "pick":
            sh, n = lg[1], lg[2]
            ss = SHIFT_START[sh]
            legs.append(dict(kind="pick", sh=sh, n=n, planned=ss + 240 + 15 - 25, ss=ss, raw=lg))
        else:
            sin, sout = lg[1], lg[2]
            ss = SHIFT_START[sin]
            legs.append(dict(kind="swap", sh=sin, out=sout, n=1, planned=ss - 15 - DROP_WORK(1), ss=ss, raw=lg))
    legs.sort(key=lambda x: x["planned"])
    return legs


def run_day(config, sc, rng, det=False):
    legs = plan(config)
    shifts = set()
    for lg in legs:
        shifts.add(lg["sh"])
        if lg["kind"] == "swap":
            shifts.add(lg["out"])
    shift_delay = {sh: (0 if det else max(0.0, rng.normal(sc["start_mu"], sc["start_sd"]))) for sh in shifts}
    over = {}
    for sh in shifts:
        o = []
        for _ in range(3):
            ov = 0 if det else max(0.0, rng.normal(sc["over_mu"], sc["over_sd"]))
            if not det and rng.random() < sc["p_extra"]:
                ov += rng.uniform(30, 60)
            o.append(ov)
        over[sh] = o
    draw = (lambda mean, cv: mean) if det else (lambda mean, cv: LN(rng, mean, cv))
    cvt = sc["cv_t"]
    free = 0.0
    first = True
    drop_fail = pick_fail = 0
    active = wait_c = 0.0
    delays = []
    first_start = None
    end_t = 0.0
    for lg in legs:
        n = lg["n"]
        start = max(lg["planned"], free)
        delays.append(start - lg["planned"])
        if first_start is None:
            first_start = start
        t = start + draw(20 if first else 22, cvt) if lg["kind"] in ("drop", "swap") else start + draw(25, cvt)
        if lg["kind"] in ("drop", "swap"):
            t += sum(draw(10, 0.4) for _ in range(n)) + sum(draw(10, 0.4) for _ in range(n - 1))
            arrival = t + (draw(40, 0.25) + 8 * (n - 1)) * traffic(t)
            if arrival - lg["ss"] > 15:
                drop_fail += 1
            hand_end = arrival + draw(15, 0.4) + 5 * (n - 1)
            if lg["kind"] == "drop":
                end = hand_end
                active += end - start
            else:
                ready = SHIFT_START[lg["out"]] + shift_delay[lg["out"]] + 240 + over[lg["out"]][0] + (20 if det else rng.uniform(10, 30))
                leave_start = max(hand_end, ready)
                wait_c += max(0.0, ready - hand_end)
                if leave_start - ready > 30:
                    pick_fail += 1
                leave = leave_start + draw(10, 0.4)
                end = leave + draw(40, 0.25) * traffic(leave) + draw(10, 0.4)
                active += (hand_end - start) + (leave - leave_start) + (end - leave)
        else:
            arrival = t
            readies = []
            for i in range(n):
                readies.append(lg["ss"] + shift_delay[lg["sh"]] + 240 + over[lg["sh"]][i] + (20 if det else rng.uniform(10, 30)))
            leave_start = max(arrival, max(readies))
            wait_c += max(0.0, max(readies) - arrival)
            if max(leave_start - x for x in readies) > 30:
                pick_fail += 1
            leave = leave_start + draw(10, 0.4)
            end = leave + (draw(40, 0.25) + 10 * (n - 1)) * traffic(leave) + sum(draw(10, 0.4) for _ in range(n))
            active += (arrival - start) + (leave - leave_start) + (end - leave)
        free = end
        end_t = end
        first = False
    return dict(drop_fail=drop_fail, pick_fail=pick_fail, active=active, wait_c=wait_c, delay=float(np.mean(delays)),
                max_delay=max(delays), elapsed=end_t - first_start, end_t=end_t, first=first_start)


def simulate(config, sc):
    rng = np.random.default_rng(11)
    det = run_day(config, sc, rng, det=True)
    structural = det["max_delay"] > 5
    rows = [run_day(config, sc, rng) for _ in range(N)]
    a = lambda k: np.array([r_[k] for r_ in rows])
    pl = sum(patient_legs(lg) for lg in config)
    nv = pl / 2
    anyfail = (a("drop_fail") + a("pick_fail")) > 0
    leg_fail_rate = (a("drop_fail").sum() + a("pick_fail").sum()) / (N * pl)
    return dict(structural=structural, ok=1 - anyfail.mean(), dropfail=(a("drop_fail") > 0).mean(), pickfail=(a("pick_fail") > 0).mean(),
                active_h=a("active").mean() / 60, wait_c=a("wait_c").mean(), elapsed_h=a("elapsed").mean() / 60,
                elapsed_p90=np.percentile(a("elapsed"), 90) / 60, late_end=(a("end_t") > 21 * 60).mean(),
                nv=nv, pay=sum(leg_pay(lg) for lg in config), visit_fail=1 - (1 - leg_fail_rate) ** 2,
                first_h=a("first").mean() / 60, end_h=a("end_t").mean() / 60)


def r(x, n=0):
    return f"{x:,.{n}f}"


def workable(s):
    return (not s["structural"]) and s["ok"] >= 0.90 and s["elapsed_h"] <= 11 and s["late_end"] < 0.15


print("# v10: scheduling analysis (one companion's day)\n")
print("Simulation of a drop-and-return day, 4,000 simulated days per case. All inputs `[E]` except the founder's 4 to 5 hour session and 6 to 7 hour door-to-door figure.\n")
print("**Assumed centre shifts (planned session starts):** S1 07:00, S2 11:30, S3 16:00 (4-hour sessions, 30-minute turnaround). "
      "**Legs:** a *drop* (travel to home 22 min, loading 10, ride 40 with traffic ×1.2 at peak, handover 15), a *pick* (travel to centre 25, wait for the patient, discharge 10, ride 40, handover 10), "
      "and a *swap run* (drop the next-shift patient, then collect the patient who just finished, in one trip). "
      "**Delays:** session start delay and overrun by scenario, a chance of a 30 to 60 minute extra overrun, 10 to 30 minutes of recovery before discharge, travel variation. "
      "**Failure:** a drop later than 15 minutes after the planned session start, or a patient waiting more than 30 minutes at pickup. "
      "A leg cannot start until the previous one ends, so delays cascade. **Workable day** = no structural conflict, at least 90% of days with no failure, mean span of 11 hours or less, under 15% of days ending after 21:00.\n")
print("Scenarios (start delay mean/sd, overrun mean/sd, chance of long overrun, travel variation): "
      + "; ".join(f"**{k}** {v['start_mu']}/{v['start_sd']}, {v['over_mu']}/{v['over_sd']}, {int(v['p_extra'] * 100)}%, cv {v['cv_t']}" for k, v in SCEN.items()) + ".\n")
print("Pay per patient-leg `[E]`: ₹215 solo (half of ₹430), ₹165 in a batch of 2, ₹140 in a batch of 3; a swap run ₹300 for two patient-legs.\n")

results = {}
for sc_name, sc in SCEN.items():
    print(f"## {sc_name.title()}\n")
    print("| Day plan | Visit-equivalents | Structural conflict | Day with no failure | Late drop (any) | Patient waits >30 min (any) | Active h | Idle wait min | Span h (mean / p90) | Ends after 21:00 | Pay per day ₹ | Workable |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for name, cfg in CONFIGS.items():
        s = simulate(cfg, sc)
        results[(sc_name, name)] = s
        print(f"| {name} | {s['nv']:.1f} | {'YES' if s['structural'] else 'no'} | {s['ok'] * 100:.0f}% | {s['dropfail'] * 100:.0f}% | {s['pickfail'] * 100:.0f}% | {s['active_h']:.1f} | {s['wait_c']:.0f} | {s['elapsed_h']:.1f} / {s['elapsed_p90']:.1f} | {s['late_end'] * 100:.0f}% | {r(s['pay'])} | {'yes' if workable(s) else 'no'} |")
    print()

print("## Maximum reliable visits per companion per day\n")
print("| Scenario | Best workable plan | Visit-equivalents | Day with no failure | Span h |\n|---|---|---|---|---|")
best_by = {}
for sc_name in SCEN:
    best = None
    for name in CONFIGS:
        s = results[(sc_name, name)]
        if workable(s) and (best is None or s["nv"] > results[(sc_name, best)]["nv"]):
            best = name
    best_by[sc_name] = best
    if best:
        s = results[(sc_name, best)]
        print(f"| {sc_name} | {best} | {s['nv']:.1f} | {s['ok'] * 100:.0f}% | {s['elapsed_h']:.1f} |")
    else:
        print(f"| {sc_name} | none | - | - | - |")
print()

print("## Economics by plan (S1 plan ₹10,999 for 12 trips, 40 families, base delays)\n")
print("Idle wait and visit-failure rate from the simulation replace the flat assumptions (20 min wait, 3% company failure). Pay per visit = pay for the two patient-legs of one visit. `[E]`\n")
print("| Plan | Visit-equivalents per day | Pay per visit ₹ | Idle wait min per visit | Visit failure rate | Contribution per visit ₹ | Companion monthly pay ₹ (26 days) | Workable |")
print("|---|---|---|---|---|---|---|---|")
for name in CONFIGS:
    s = results[("base", name)]
    payv = s["pay"] / s["nv"]
    wmin = s["wait_c"] / s["nv"]
    u = m.unit(40, dict(S1, pay=payv, bratio=1.0, bf=0.0001, wait_min=wmin, fc=min(0.3, s["visit_fail"])))
    print(f"| {name} | {s['nv']:.1f} | {payv:,.0f} | {wmin:,.0f} | {s['visit_fail'] * 100:.0f}% | {u['cm']:,.0f} | {s['pay'] * 26:,.0f} | {'yes' if workable(s) else 'no'} |")
print()

print("## Companions needed\n")
print("Each patient attends 3 days a week: about 12 ÷ 26 = 0.46 visits per family per working day. Allow 1.3× for days off, sickness and backup. "
      "Rosters assume the best workable plan per scenario (base) and a looser 1.0 visit-equivalent per companion per day (solo S1-style).\n")
bb = best_by["base"]
per = results[("base", bb)]["nv"] if bb else 1.0
print(f"Best workable base plan: **{bb}** at **{per:.1f}** visit-equivalents per companion-day.\n")
print("| Paying families | Visits per day | Companions on duty at best plan | With 1.3× cover | If only 1.0 per day |")
print("|---|---|---|---|---|")
for fam in (15, 30, 60, 100, 200):
    v = fam * 12 / 26
    print(f"| {fam} | {v:.1f} | {v / per:.1f} | {math.ceil(v / per * 1.3)} | {math.ceil(v * 1.3)} |")
print()
