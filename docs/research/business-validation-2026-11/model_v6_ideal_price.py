"""v6: ideal plan price at 12 trips per 4-week cycle. Reuses v2 engine, S1 pay structure, v1 ramp/overhead. All [E].
Run: python3 model_v6_ideal_price.py > model_v6_results.md
"""
import contextlib, io
import numpy as np
with contextlib.redirect_stdout(io.StringIO()):
    import model_v2_sensitivity as m
    import model_v2_projection as pj
    import model_v3_pricing_structure as m3
S1 = m3.S1
def run(price12, mult, bypass=0.0, vpf=12):
    S = dict(S1, list=price12 / 12, vpf=vpf)
    xs=[a for a,_ in pj.RAMP["base"]]; ys=[b for _,b in pj.RAMP["base"]]
    cum=-pj.SETUP; low=cum; be=None
    for mo in range(1,25):
        f=float(np.interp(mo,xs,ys))*mult
        fe=f*(1-bypass*min(1,mo/24))
        u=m.unit(max(fe,1),S)
        net=fe*vpf*u["cm"]-m.fixed_curve(f)
        cum+=net; low=min(low,cum)
        if net>0 and be is None: be=mo
    return be,-low,cum
print("# v6: ideal price, 12 trips per 4-week plan\n")
print("S1 pay structure (effective ₹430 per trip), 12 trips per family per month, v1 ramp and overhead, ₹3.5 L setup, fare extra. `[E]`\n")
print("| Plan price (12 trips) | Per trip | CM/trip @40 fam | Margin | ₹4,000+ families: break-even / cash m24 ₹L | ₹2,500 families (ramp ×0.5): break-even / cash m24 ₹L | ₹4,000+ with 10% bypass: break-even / cash m24 ₹L | 18% GST absorbed, ₹4,000+: break-even / cash m24 ₹L |")
print("|---|---|---|---|---|---|---|---|")
for p in (7999,8999,9999,10999,11999,12999):
    S=dict(S1,list=p/12,vpf=12); u=m.unit(40,S)
    a=run(p,1.0); b=run(p,0.5); c=run(p,1.0,0.10)
    # GST absorbed
    S2=dict(S1,list=p/12,vpf=12,gst="absorb")
    xs=[x for x,_ in pj.RAMP["base"]]; ys=[y for _,y in pj.RAMP["base"]]
    cum=-pj.SETUP; be=None
    for mo in range(1,25):
        f=float(np.interp(mo,xs,ys)); uu=m.unit(max(f,1),S2); net=f*12*uu["cm"]-m.fixed_curve(f); cum+=net
        if net>0 and be is None: be=mo
    fmt=lambda t:f"{t[0] or 'never'} / {t[-1]/1e5:,.1f}"
    print(f"| ₹{p:,} | ₹{p/12:,.0f} | {u['cm']:,.0f} | {u['cm']/u['real']*100:.0f}% | {fmt(a)} | {fmt(b)} | {fmt(c)} | {be or 'never'} / {cum/1e5:,.1f} |")
