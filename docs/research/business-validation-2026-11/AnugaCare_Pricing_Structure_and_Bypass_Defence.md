# AnugaCare pricing structure and bypass defence (v3)

Date: 2026-11-11. Follows `AnugaCare_Validation_Round2_Report.md`. Calculations: `model_v3_pricing_structure.py` → `model_v3_pricing_structure_results.md`.
Labels: `[V]` found in a source, `[E]` my estimate, `[U]` unverified, `[I]` needs interviews, a lawyer or a centre to settle.
Nothing here has been sent, signed or tested with anyone. Not legal advice.

---

## 1. The problem, said plainly

The companion rides with the patient and knows the family. Sooner or later someone says: *"Why do I pay AnugaCare? You know me, I'll pay you directly."*

- **You cannot block this technically.** An in-person service cannot hide who the person is. Any design that depends on "they will never get each other's number" will fail.
- **The incentive is real.** On the ₹10,999 plan, a ₹700 direct deal saves the family about ₹2,600 a month (24%) and raises the companion's earnings about 63% (₹8,400 vs ₹5,160). Both sides win on paper.
- **Why the gap is wide:** the companion keeps only about 47% to 55% of what the family pays. The rest covers insurance, support, failed visits, payment fees and overhead. Marketplaces that took a smaller cut still face bypass: Urban Company reportedly took 25% to 30% and still bans serving platform customers offline `[V]` press.
- **So the strategy is:** (1) make AnugaCare worth the gap, (2) keep the gap smaller, (3) make bypass worse for both people than it looks, (4) make bypass legal and priced instead of secret, (5) detect it early. Pure restriction is the weakest of the five.

---

## 2. Recommended pricing structure (test values, all `[E]`, fare extra and prepaid)

### 2.1 Customer side

| Element | Proposal | Why |
|---|---|---|
| **Monthly Dialysis Care Plan** | **₹10,999 for 12 round trips** (about ₹917 per trip). Test cells ₹9,999 / ₹10,999 / ₹11,999 | Buy the service, not the person. A monthly price hides the per-trip split that makes bypass maths easy |
| Pay-as-you-go | ₹999 per trip | Plan is clearly better value, so families commit |
| No package discount stacking | No 11% discount like the old ₹8,499 plan | Discount was costing about ₹90 per trip |
| Extra trips inside the month | ₹899 | Keeps use on-platform |
| Fare | Prepaid wallet topped up to AnugaCare, drawn per trip | Cash never flows companion to family or back |
| Loyalty | Price lock for 6 months; **−8% from month 13** (S2) | Staying is rewarded; direct deal saves less over time |
| Included, in writing | Backup companion guarantee (target within 60 minutes), care team of two, accident cover for the trip, OTP handover record, weekly family report | This is what the premium buys. It must be real before it is advertised |
| Direct-hire path | Allowed after 6 months with a **one-time introduction fee** (₹12,000 test value, about 3 months of the family's contribution), see 5 | Turns a secret bypass into revenue and removes the adversarial feel |

### 2.2 Companion side (illustrative per round trip ≤8 km)

| Component | ₹ | Note |
|---|---|---|
| Base for about 3.6 active hours | 330 | |
| Commute allowance (two solo legs) | 60 | Paid every trip |
| Retention bonus | about 40 | ₹1,500 a month if ≥30 trips, ≥95% on time and no direct-dealing breach |
| **Effective pay** | **430** | Tenure ladder +₹10 per trip every 6 months up to +₹30 (460 at tenure) |

Also from AnugaCare: accident cover, training, ID kit, weekly payout, a minimum monthly guarantee once on 3+ regular families, paid replacement shifts when a colleague is sick. Companions see the family's address and first name only. They do **not** see the family's price.

### 2.3 What the numbers say (v2 engine, 40 families, contribution per completed visit)

| Structure | Fee per trip | Companion pay | Companion share | Contribution | Margin |
|---|---|---|---|---|---|
| S0 original: ₹799, packs | 732 | 380 | 52% | 197 | 27% |
| **S1 Care Plan ₹10,999 (months 1 to 6)** | 917 | 430 | 47% | **331** | 36% |
| S2 same family, month 13+ | 843 | 460 | 55% | 225 | 27% |
| S3 premium ₹11,999 | 1,000 | 460 | 46% | 384 | 38% |
| S4 ₹9,999 | 833 | 430 | 52% | 247 | 30% |

Higher pay for companions does not break the model if the price moves with it. It breaks if the price stays at ₹799.

### 2.4 24-month effect, base ramp, v1 overhead curve (₹ lakh)

| Structure | Families lost to bypass by month 24 | Break-even month | Peak cash need | Cash at month 24 |
|---|---|---|---|---|
| S0 ₹799 | 0% | never | 35.6 | −35.6 |
| S0 ₹799 | 25% | never | 48.2 | −48.2 |
| **S1 ₹10,999** | 0% | 13 | 8.0 | +5.2 |
| S1 ₹10,999 | 10% | 15 | 8.9 | −2.9 |
| S1 ₹10,999 | 25% | never | 15.0 | −15.0 |
| S3 ₹11,999 | 10% | 12 | 6.3 | +12.1 |
| S3 ₹11,999 | 25% | 13 | 7.2 | −1.8 |

**Reading:** the structure survives about 10% bypass at ₹10,999 and about 25% at ₹11,999. It does not survive 25% leakage at ₹10,999. S1 and S3 assume families accept ₹917 to ₹1,000 per trip, which is `[I]` and untested. If they accept only ₹799 equivalents, none of this works, bypass or not.

---

## 3. Strict operating controls

Rules a coordinator can follow from day one. Write them into the companion agreement and the family terms.

1. **All money through AnugaCare.** No cash to companions. Fare wallet and plan paid to AnugaCare. Tips only through the app, capped, and logged.
2. **Masked communication.** Families call the AnugaCare number or a WhatsApp Business line, not the companion's personal phone. Companions do not give out personal numbers. Emergency contact is the coordinator plus a family emergency number.
3. **Care team, not a single person.** Each family has a primary and a secondary companion, rotated about one trip in four. The relationship is with the team and the coordinator. (v1 recommended a named primary companion; keep the name, but add the secondary.)
4. **Branded identity.** AnugaCare ID and uniform. Handover to the centre is made in AnugaCare's name.
5. **The backup guarantee is the product.** If it is not delivered every time, no contract will hold families. Measure it weekly.
6. **No solo dependence.** No companion serves more than about 40% of one family's trips, and no family more than about 40% of one companion's income. Reduces single-pair lock-in.
7. **Centre registration.** Ask each centre to accept handover only from registered AnugaCare companions with ID. This turns centre cooperation into a moat. Never pay centres for referrals.
8. **Companion agreement (lawyer to draft):** exclusivity for AnugaCare-introduced families while engaged; confidentiality and data protection (the family's health and contact data belong to the process, not the companion); a duty to report direct approaches; suspension for breach.
9. **Early-warning signals:** a family's bookings drop with no medical reason; a family cancels but the same companion's weekend availability appears unexplained; the same two people appear in family chats outside the app; repeat late cancellations on one pair; a companion's completed trips fall while their availability stays open. Review weekly.
10. **Graduated response:** conversation first (why), then written warning, then suspension. Never leave a patient without service as a penalty. Safety comes before enforcement.

---

## 4. What the law can and cannot do `[V]` commentary, `[I]` lawyer

- **Post-termination restraints on individuals are generally void under Section 27 of the Indian Contract Act.** Commentary says the Supreme Court held a two-year post-service non-compete void; Delhi High Court decisions reportedly void clauses stopping an ex-employee from dealing with clients unless protecting trade secrets, though courts treat non-solicits between businesses differently ([Nishith Desai](https://www.nishithdesai.com/default.aspx?id=15383), [Bar & Bench](https://www.barandbench.com/view-point/non-solicitation-in-employment-agreements-understanding-enforcement-issues-and-pitfalls), [Mondaq on Varun Tyagi v Daffodil](https://www.mondaq.com/india/employee-rights-labour-relations/1667768/what-courts-are-cracking-the-code-on-post-employment-clauses-in-light-of-varun-tyagi-v-daffodil-software-pvt-ltd)). Sources are law-firm commentary, not the judgments.
- **During the engagement**, restrictions are usually accepted. So rely on in-term exclusivity, confidentiality and suspension, not on "you may never work for our families after you leave".
- **Practical enforcement elsewhere:** Urban Company reportedly treats off-platform service to platform customers as a breach and blocks IDs, with warnings and re-training before blocking `[V]` press ([News Minute](https://www.thenewsminute.com/news/pay-to-join-pay-to-work-inside-the-gruelling-life-of-an-urban-company-beautician), [Newslaundry](https://www.newslaundry.com/2025/07/07/long-hours-low-earnings-paying-to-work-the-brutal-life-of-an-urban-company-beautician)). The same reporting shows worker anger over commissions and penalties, so heavy-handed control has its own cost in trust and recruitment.
- **Whether a customer introduction fee is enforceable** is unsettled to me. It is a fee for the placement service, not a restraint on a person's profession, but a lawyer must confirm and draft it. Do not promise it to anyone until then `[I]`.
- **Employment form interacts:** the more control you impose (schedules, exclusivity, uniform), the closer you are to an employment relationship, with statutory costs. Decide the engagement form with the lawyer before the agreement.

---

## 5. Scripts (drafts for your review; nothing sent)

**Family asks: "Why AnugaCare? I know her, I'll pay her directly."**
> "You can absolutely choose that, and she is good at her work. Here is what changes. If she is ill or on leave, we send a verified replacement within about an hour, and your father's session is not missed. Every trip has an accident cover, an OTP handover record, and a message to you when he is home. One monthly bill and a prepaid wallet cover the fare. If you ever want to hire a companion directly, we have an introduction option after six months, so you are never stuck. Would you like me to walk you through the backup first?"

**Companion proposes: "Pay me directly, I'll charge less."**
> "I understand. Today you earn ₹X a trip plus a monthly bonus, weekly pay, accident cover and steady runs. Going direct means no cover, no replacement if you are ill, gaps between jobs, and a family that may cancel at the last minute. You are also asked to report such offers; doing the work off the platform ends your engagement. If you feel your pay is too low, tell us, because that is what we want to fix."

Hold both to plain facts. Do not threaten. Do not promise legal outcomes.

---

## 6. What to put into the validation experiment

1. Replace the per-trip price cells with **monthly plan cells: ₹9,999, ₹10,999, ₹11,999** (12 trips, fare extra) and compare deposits.
2. In the offer, state the backup guarantee, care team and "all payments through AnugaCare". Count how many families object to those terms.
3. In interviews, ask: *"If the companion offered to work directly for less, what would you do, and why?"* and *"What would make you stay with the service?"* Record the answers verbatim. They are the evidence for this whole section.
4. Ask 6 to 8 candidate companions the mirror question: *"What would stop you taking a family direct?"* and *"What pay would feel fair?"*
5. Ask each centre whether it will accept handover only from registered providers.

Stop criteria for this design: if fewer than 3 of 12 families accept ₹917 per trip or more, S1 fails and the plan needs a different segment or price logic. If companions say they would go direct at any pay under about ₹550, the model is exposed and needs the employment route (higher cost, more control) evaluated.

---

## 7. Limits

- Every number is an estimate. Bypass rates, direct-deal prices and the willingness to pay ₹917 or more are guesses until interviews and the deposit test.
- The bypass model removes families but does not model the loss of trained companions (₹5k to ₹6k each, plus disruption).
- Legal points rest on commentary. A lawyer must review the agreement, the introduction fee, the exclusivity wording and the engagement form.
- Search covered Section 27 commentary and press reports on Urban Company. I did not find any dialysis or hospital-companion platform that publishes its anti-bypass policy.
- Nobody was contacted and nothing was spent.
