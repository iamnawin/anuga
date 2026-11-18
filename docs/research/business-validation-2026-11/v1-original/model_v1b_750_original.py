import numpy as np
# fixed-cost curve points (families, monthly fixed INR incl marketing)
FX=[(0,60000),(15,82000),(75,299000),(400,1100000)]
def fixed(f): return float(np.interp(f,[a for a,_ in FX],[b for _,b in FX]))
def batch(f,k): return k*float(np.interp(f,[0,15,75,400],[0.10,0.15,0.35,0.55]))
S={ # price(avg realised svc fee), pay_single, pay_batched, leakage, batchfactor, visits/fam
 'conservative':dict(price=690,ps=340,pb=270,leak=.08,bf=.8,vpf=8),
 'base':dict(price=750,ps=300,pb=230,leak=.05,bf=1.0,vpf=10),
 'optimistic':dict(price=790,ps=290,pb=220,leak=.04,bf=1.2,vpf=11)}
FARE=400 # pass-through avg round trip, prepaid
def unit(f,s):
    p=S[s]; b=min(batch(f,p['bf']),.75)
    pay=p['ps']*(1-b)+p['pb']*b
    idle=0.10*pay
    pg=0.02*(p['price']+FARE)
    sup=30; ins=15; comm=8; train=12
    leak=p['leak']*p['price']
    var=pay+idle+pg+sup+ins+comm+train+leak
    return dict(price=p['price'],pay=pay,idle=idle,pg=pg,sup=sup,ins=ins,comm=comm,train=train,leak=leak,var=var,cm=p['price']-var,b=b)
for s in S:
  for f in (15,75,400):
    u=unit(f,s); print(s,f,{k:round(v,1) for k,v in u.items()}, 'BE visits',round(fixed(f)/u['cm']), 'BE fam',round(fixed(f)/u['cm']/S[s]['vpf']))
ramp={'conservative':[(0,0),(3,10),(9,25),(12,45),(18,70),(24,90)],
 'base':[(0,0),(3,15),(9,50),(12,100),(18,200),(24,300)],
 'optimistic':[(0,0),(3,20),(9,80),(12,150),(18,300),(24,450)]}
setup={'conservative':350000,'base':350000,'optimistic':350000}
for s in S:
  xs=[a for a,_ in ramp[s]];ys=[b for _,b in ramp[s]]
  cum=-setup[s];low=cum;be=None;rows=[]
  for m in range(1,25):
    f=float(np.interp(m,xs,ys));v=f*S[s]['vpf'];u=unit(f,s)
    rev=v*S[s]['price'];dc=v*u['var'];gp=rev-dc;fx=fixed(f);net=gp-fx
    cum+=net;low=min(low,cum)
    if net>0 and be is None: be=m
    rows.append((m,round(f),round(v),rev,dc,gp,fx,net,cum))
  print('\n',s,'peak cash need',round(-low),'break-even month',be)
  for r in rows:
    if r[0] in (1,3,6,9,12,15,18,21,24): print(r[0],r[1],r[2],*(round(x/1000) for x in r[3:]))
  y1=[r for r in rows if r[0]<=12];y2=[r for r in rows if r[0]>12]
  print('Y1 rev',round(sum(r[3] for r in y1)/1e5,1),'L net',round(sum(r[7] for r in y1)/1e5,1),'Y2 rev',round(sum(r[3] for r in y2)/1e5,1),'net',round(sum(r[7] for r in y2)/1e5,1))
# sensitivity on base @75 families
base=S['base'];import copy
def cm_with(**kw):
    global S
    old=copy.deepcopy(S['base']);S['base'].update(kw);u=unit(75,'base');S['base']=old;return round(u['cm'])
print('\nsens base@75: cm',cm_with(), 'wage+20%',cm_with(ps=360,pb=276),'price 650',cm_with(price=650),'price 850',cm_with(price=850),'leak 10%',cm_with(leak=.10),'no batching',cm_with(bf=0.0001))
# wait-in-place scenario: companion waits 4h at 110/h
print('wait 4h cost',4*110+2.5*110)
# travel distance model: cab cost per km 18, base 50
for km in (4,8,12,18): print(km,'km cab one-way est',50+18*km,'rt',2*(50+18*km))
