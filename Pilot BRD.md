# Dialysis Companion Pilot BRD (ZeroOrigins, name TBD)

Oct 8, 2026 · @Navn

## Summary

Run an 8-week, manual-first pilot of a scheduled companion service for hemodialysis patients in one Hyderabad cluster, and build an app only if 80%+ of paying families renew.

- **The problem:** dialysis means 2–3 hospital trips a week for life. Travel and lost wages cost families more than half of monthly dialysis-related spending, and caregivers carry a heavy burden.
- **The bet:** families will pay a monthly plan for a verified, consistent companion who handles the trip, the paperwork and the updates, so a working son or daughter doesn't have to.
- **The ask:** about 8 weeks, 8–10 companions, 2–3 partner dialysis centres, and a target of 15+ paying patients.
- **Not in scope:** emergencies, medical tasks, and any build beyond WhatsApp plus a spreadsheet.

## Problem

The hardest part of dialysis for many families is not the treatment but getting to it, again and again.

| Pain point | Evidence |
| --- | --- |
| Relentless frequency | A patient needs about 3 sessions a week, roughly 156 a year, until a transplant ([Asian Hospital & Healthcare Mgmt](https://www.asianhhm.com/articles/is-dialysis-the-next-big-opportunity-in-indian-healthcare)) |
| Travel and lost wages cost more than the treatment overhead | In a Kerala study of 835 patients, indirect costs such as travel and lost employment were over half of monthly dialysis-related spending ([Research Matters](https://researchmatters.in/news/spite-subsidies-haemodialysis-costs-push-families-financial-distress-finds-study)) |
| Distance cuts treatment, and survival | Across 16,252 Apex Kidney Care patients, those dialysing 2.5 times a week or less lived a median 20 km away vs 13 km for 2.5+ ([ISN abstract](https://events.theisn.org/event/session/view/29306)). Five-year survival was 74% at 3–3.5 sessions/week vs 58% below 2 ([ISN abstract](https://events.theisn.org/event/session/view/29007)) |
| Caregivers are stretched | 69% of caregivers in a Sikkim study had mild to severe burden ([PubMed](https://pubmed.ncbi.nlm.nih.gov/35496347/)); a Bengaluru study found moderate burden in 54% ([IJCM](https://doaj.org/article/ecb8b6f4a0b74412be81efb49804a723)) |
| Government already sees the travel gap | Telangana gives ₹2,016/month to 4,021 dialysis patients, citing their frequent hospital visits ([UNI](https://test.uniindia.com/news/south/administration-telangana-pensions/3495661.html)), and aims to put every patient within 20–25 minutes of a centre ([Siasat](https://www.siasat.com/govt-to-set-up-79-new-dialysis-centers-in-telangana-health-minister-3456438/)) |

What this adds up to: a working family member loses a day's work several times a week, or the patient goes alone, skips sessions, or travels unsafely after treatment.

## Who it's for

The patient uses the service, but the family member who pays is the real customer.

| Role | Who | What they need | What they get |
| --- | --- | --- | --- |
| Patient | Adult on maintenance hemodialysis, often 50+, living with spouse or alone | A safe ride there and back, help with steps and paperwork, someone familiar | The same trained companion each visit, plus a backup |
| Paying family member | Son or daughter working full time, in another city, or abroad | Peace of mind without losing workdays | Live trip status, a post-visit WhatsApp note, and one monthly bill |
| Companion | Nursing or allied-health students, retired people, part-timers near the centre | Flexible, predictable earnings | Fixed recurring slots near home, training and a verified badge |
| Dialysis centre | Partner centres in the pilot cluster | Fewer missed or late sessions, less front-desk load | A reliable referral partner for patients who struggle to come |

First target: private-pay families in Hyderabad whose patient dialyses at a private or partner centre 2–3 times a week.

## Market

India has the volume and the pain but no paid transport benefit; the US proves people pay for this; the Gulf is small but premium.

| Country | Dialysis population | Who pays for the trip today | What it means for us |
| --- | --- | --- | --- |
| India | About 1.75 lakh on chronic dialysis in 2018 ([MedBound Times](https://www.medboundtimes.com/amp/story/medicine/world-kidney-day-2026-dialysis-access-cost-kidney-care-india)), growing 10–15% a year ([Sakshi Post](https://www.sakshipost.com/kidney-disease-sufferers-double-in-india-over-15-years)). NephroPlus alone has 38,262 active patients ([Indian Pharma Post](https://www.indianpharmapost.com/healthcare/nephrocare-posts-rs-282-crore-revenue-at-237-growth-in-q1-fy27-21449)) | The family, out of pocket. The free government programme runs 1,704 centres ([Medical Dialogues](https://health.medicaldialogues.in/health/bihars-sheikhpura-sadar-hospital-offers-free-dialysis-thousands-benefited-154526)) but covers treatment, not travel | Biggest volume, private-pay model, price must stay low |
| Telangana | About 16,500 patients get free dialysis under Aarogyasri across 102 government centres ([Siasat](https://www.siasat.com/govt-to-set-up-79-new-dialysis-centers-in-telangana-health-minister-3456438/)), plus private-pay patients | The family; a ₹2,016/month pension reaches only 4,021 patients | Dense, reachable pilot market at home |
| United States | About 800,000 people with kidney failure in 2020, nearly 500,000 on hemodialysis ([Endovascular Today](https://assets.bmctoday.net/evtoday/pdfs/et0623_medpage.pdf)) | Insurers. Dialysis is about 29% of non-emergency medical transport demand, and Medicaid funds about 52% of that market ([Mordor Intelligence](https://www.mordorintelligence.com/industry-reports/non-emergency-medical-transportation-market)) | Proof that payers fund trips and companions; not our first market |
| UAE | Over 2,000 on dialysis, growing 10–15% a year (older industry estimate) ([Gulf News](https://gulfnews.com/amp/story/uae%2Fhealth%2Fchronic-kidney-ailments-on-the-rise-1.1658368)); 4,000+ kidney-failure patients await a transplant ([Zavis](https://www.zavis.ai/intelligence/doh-2150-abu-dhabi-transplants-hayat-expansion)) | Families and employers; high willingness to pay | Small but premium; a later expansion, not the pilot |
| Qatar | Forecast 1,245 dialysis patients in 2025 ([Gulf Times](https://www.gulf-times.com/article/658164/qatar/study-forecasts-567-annual-increase-in-dialysis-patients)) | Mostly state hospitals | Too small to lead with |

**Bottom-up India estimate (our projection, not a published figure):** 1.75 lakh patients in 2018 growing 10–15% a year gives roughly 3.8–5.4 lakh in 2026. If 10% of them buy a ₹4,800/month plan, that is about 38,000–54,000 subscribers and **₹215–310 crore a year** in revenue. Treat this as an order-of-magnitude check; the pilot will replace the 10% and ₹4,800 assumptions with real numbers.

## Competition

Hospital-companion startups exist in India, but none we found is built around recurring dialysis schedules; that focus is our wedge.

| Player | Where | Model | Gap we exploit |
| --- | --- | --- | --- |
| [CARESY](https://ascendants.in/the-ascendants/caresy-hospital-companion-service-india/) | India | Hospital companion for paperwork, queues and coordination during visits | One-off hospital visits, not a recurring dialysis plan |
| [AayaCare](https://datainnovation.org/?p=19691) | Indian metros | Matches patients with companions for healthcare visits | General visits; no centre partnerships or dialysis focus found |
| [Eldy Care](https://www.startinup.up.gov.in/crm/Welcome/startup_user_details/NDMzMzE=) | Uttar Pradesh | On-demand hourly elder companions, commission per booking | On-demand marketplace; we sell scheduled consistency |
| [GoodFellows](https://homegrown.co.in/homegrown-explore/goodfellows-a-companionship-startup-to-reduce-loneliness-in-senior-citizens) | India | Monthly companionship subscription for seniors, including doctor visits | Loneliness first, medical logistics second |
| [Papa](https://www.papa.com) | United States | Companions paid by about 70 health plans, including rides to doctor visits | Shows the insurer-paid path we could pursue later in India or the Gulf |
| [Kuantan van service](https://www.nst.com.my/amp/news/regional/2026/07/1493413/van-service-helps-disabled-elderly-patients-get-appointments) | Malaysia | RM25 trips to hospitals and dialysis centres, companions at RM11/hour | Low-cost community model; confirms demand from dialysis families |
| Emoha (Age Care Labs) | India | Funded eldercare platform; hospital accompaniment is one of many home services (raised ₹85 crore, July 2026) | Broad eldercare bundle; we win on dialysis focus, fixed recurring companions and price |

**Our difference:** dialysis-only at launch, the same companion every session, partner dialysis centres as the referral channel, and live updates built for the paying family member.

## Pilot scope

The pilot covers non-medical trip support for hemodialysis patients around 2–3 centres in one Hyderabad area.

**In scope**

- Pickup from home, travel with the patient, check-in at the centre
- Handover to centre staff, then pickup after the session and drop-home
- Carrying files, collecting reports, a pharmacy stop on the way back
- Live status and a post-visit WhatsApp note to the family
- A primary and a backup companion per patient

**Out of scope**

- Emergencies: those go to 108 or an ambulance
- Any clinical task: no nursing, cannulation, medication or vitals
- Peritoneal or home dialysis, and other conditions (heart, cancer) until dialysis is proven
- A custom app: WhatsApp Business, Google Forms and a sheet only
- Cities other than Hyderabad

## Business model

A monthly plan of 12 visits at about ₹400 each (₹4,800/month) leaves roughly ₹150 margin per visit; the pilot exists to test these numbers.

For comparison, a private session costs ₹2,500–4,000 ([MedBound Times](https://www.medboundtimes.com/amp/story/medicine/world-kidney-day-2026-dialysis-access-cost-kidney-care-india)), so the plan adds roughly 10–16% to a family's monthly session spend of ₹30,000–48,000. All figures below are pilot assumptions, not market data.

| Item | Per visit | Per patient per month (12 visits) | 15 patients per month |
| --- | --- | --- | --- |
| Price to family | ₹400 | ₹4,800 | ₹72,000 |
| Companion pay (drop-off + pickup legs) | ₹250 | ₹3,000 | ₹45,000 |
| Gross margin | ₹150 | ₹1,800 | ₹27,000 |
| Cab or auto fare | Passed through at cost | — | — |

- **Pricing to test:** monthly plan vs pay-per-visit, and a premium tier where the companion stays through the session
- **Companion earnings:** a companion with 4 patients earns about ₹12,000/month for fixed morning or evening slots
- **One-time pilot costs to budget:** background checks, a half-day training, accident insurance, branded ID cards and WhatsApp Business setup
- **Later revenue paths:** centre partnerships (per-referral or bulk plans), corporate caregiver benefits, and insurers, as Papa does in the US

## Plan and timeline

Eight weeks: two to set up, six to run, then a go/no-go call.

1. **Week 0: lock the basics**
   - Pick the name and check trademark and domain
   - Choose a 5 km cluster with 2–3 dialysis centres
2. **Weeks 1–2: set up**
   - Meet centre managers and offer the first 5 patients free for two weeks
   - Recruit 8–10 companions; run background checks and a half-day training
   - Set up WhatsApp Business, a booking form and the tracking sheet
   - Arrange accident insurance and a short service agreement with families
3. **Weeks 3–8: run**
   - Serve booked patients on recurring slots with a primary and backup companion
   - Send a status update and post-visit note for every trip
   - Log no-shows, wait times, complaints, payment delays and companion hours
   - Convert free trials to the paid plan at the end of week 4
4. **Week 8: decide**
   - Review metrics against the go/no-go criteria
   - If go, write the app spec from the log; if no-go, record why

## Success metrics

Go to an app build only if families pay, stay, and companions turn up reliably.

| Metric | Go if | Stop or rethink if |
| --- | --- | --- |
| Paying patients by week 8 | 15 or more | Fewer than 8 |
| Renewal into month 2 | 80% or more | Under 50% |
| On-time pickups | 95% or more | Under 85% |
| Visits missed because of us | Under 2% | Over 5% |
| Family satisfaction (1–5) | 4.5 or higher | Under 4 |
| Companion retention over the pilot | 75% or more | Under 50% |
| Referrals from partner centres | At least 1 centre referring weekly | No centre referrals |

Anything between the two columns means extend the pilot 4 weeks with one change (price, cluster or channel), not build.

## Risks

Trust and safety are the biggest risks; each has a cheap mitigation in the pilot.

| Risk | Mitigation |
| --- | --- |
| Patient feels unwell during a trip | Companion training on warning signs; 108 and centre numbers on every ID card; family called first |
| Companion misconduct or theft | Background checks, ID verification, live location sharing, two references |
| Liability if something goes wrong | Accident insurance plus a signed agreement stating the service is non-medical |
| Companion no-shows | Backup companion assigned per patient; small reliability bonus |
| Families won't pay enough | Test two price points; offer a per-visit option |
| Centres see us as a competitor | Position as a referral partner that improves their attendance; no clinical role |
| Name clash (Anuga) | Choose a new name and run a trademark check before any branding spend |

## Open questions

- [ ] Final brand name, trademark and domain
- [ ] Which Hyderabad cluster and which 2–3 centres?
- [ ] How many patients in that cluster pay privately vs under Aarogyasri?
- [ ] Will families pay ₹400 a visit, or does a per-month plan sell better?
- [ ] Do centres prefer patients to stay with a companion through the session?
- [ ] Which insurer will cover companion accident and liability risk?
- [ ] Is the business set up as a ZeroOrigins brand or a separate entity?

## Sources

- [World Kidney Day 2026: dialysis access, cost and care in India — MedBound Times](https://www.medboundtimes.com/amp/story/medicine/world-kidney-day-2026-dialysis-access-cost-kidney-care-india)
- [Kidney disease sufferers double in India — Sakshi Post](https://www.sakshipost.com/kidney-disease-sufferers-double-in-india-over-15-years)
- [Is dialysis the next big opportunity in Indian healthcare — Asian Hospital & Healthcare Management](https://www.asianhhm.com/articles/is-dialysis-the-next-big-opportunity-in-indian-healthcare)
- [Haemodialysis costs push families into financial distress — Research Matters](https://researchmatters.in/news/spite-subsidies-haemodialysis-costs-push-families-financial-distress-finds-study)
- [Burden of travelling distance to the dialysis centre in India — ISN](https://events.theisn.org/event/session/view/29306)
- [Survival of patients on long-term maintenance hemodialysis in India — ISN](https://events.theisn.org/event/session/view/29007)
- [Caregiver burden in haemodialysis, Sikkim — PubMed](https://pubmed.ncbi.nlm.nih.gov/35496347/)
- [Social impact of ESRD on patients and caregivers, Bengaluru — IJCM](https://doaj.org/article/ecb8b6f4a0b74412be81efb49804a723)
- [79 new dialysis centres in Telangana — Siasat](https://www.siasat.com/govt-to-set-up-79-new-dialysis-centers-in-telangana-health-minister-3456438/)
- [Telangana support for 4,021 dialysis patients — UNI](https://test.uniindia.com/news/south/administration-telangana-pensions/3495661.html)
- [PMNDP: 1,704 operational centres — Medical Dialogues](https://health.medicaldialogues.in/health/bihars-sheikhpura-sadar-hospital-offers-free-dialysis-thousands-benefited-154526)
- [NephroPlus Q1 FY27 results — Indian Pharma Post](https://www.indianpharmapost.com/healthcare/nephrocare-posts-rs-282-crore-revenue-at-237-growth-in-q1-fy27-21449)
- [USRDS figures on US kidney failure — Endovascular Today](https://assets.bmctoday.net/evtoday/pdfs/et0623_medpage.pdf)
- [Non-emergency medical transportation market — Mordor Intelligence](https://www.mordorintelligence.com/industry-reports/non-emergency-medical-transportation-market)
- [Dialysis patients in the UAE — Gulf News](https://gulfnews.com/amp/story/uae%2Fhealth%2Fchronic-kidney-ailments-on-the-rise-1.1658368)
- [Abu Dhabi transplants — Zavis](https://www.zavis.ai/intelligence/doh-2150-abu-dhabi-transplants-hayat-expansion)
- [Qatar dialysis forecast — Gulf Times](https://www.gulf-times.com/article/658164/qatar/study-forecasts-567-annual-increase-in-dialysis-patients)
- [CARESY hospital companion — The Ascendants](https://ascendants.in/the-ascendants/caresy-hospital-companion-service-india/)
- [AayaCare interview — Center for Data Innovation](https://datainnovation.org/?p=19691)
- [Eldy Care — Startup in UP](https://www.startinup.up.gov.in/crm/Welcome/startup_user_details/NDMzMzE=)
- [GoodFellows — Homegrown](https://homegrown.co.in/homegrown-explore/goodfellows-a-companionship-startup-to-reduce-loneliness-in-senior-citizens)
- [Papa](https://www.papa.com)
- [Kuantan hospital van service — New Straits Times](https://www.nst.com.my/amp/news/regional/2026/07/1493413/van-service-helps-disabled-elderly-patients-get-appointments)
