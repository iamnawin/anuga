# AnugaCare: privacy notice, consent text and terms (draft for lawyer review)

Date: 2026-11-13. Prepared for: external legal review. Prepared by: ZeroOrigins (founder), drafted with AI assistance.

**Status: DRAFT. Not legal advice. Not published. Nothing in this file is shown to users until a lawyer has approved it in writing.**

Items in [SQUARE BRACKETS] are blanks we need to fill. Items marked **Q1, Q2...** are questions for you; the full list is in Part B.

---

## Part A. What we are asking you to do

1. Answer the questions in Part B.
2. Correct the three drafts: privacy notice (Part D), consent wording (Part E), terms of service (Part F).
3. Tell us what else we must have in place before we handle a real patient's data (Part G is our own list).
4. Confirm the final English text. We will then translate it into Telugu and Hindi and show it in the app.

We have not used any real patient data so far. Everything in the system today is invented test data.

---

## Part B. Questions for the lawyer

**Applicable law and timing**

- **Q1.** Our internal product document says the DPDP Rules were notified on 13 November 2025, that notice, consent, security safeguards and breach intimation apply from 13 November 2026, and that user rights and grievance redressal apply from 13 May 2027. Is this correct? Which obligations bind us on the day we onboard the first real patient?
- **Q2.** Until the DPDP Act fully applies, do the IT Act section 43A and the 2011 SPDI Rules apply to us (health information as sensitive personal data, written consent, published privacy policy, grievance officer)? If yes, does the draft satisfy both regimes?
- **Q3.** Are we at any risk of being classed as a Significant Data Fiduciary? We expect fewer than 100 patients in the pilot.
- **Q4.** Do any health-sector laws apply to a non-clinical escort service (for example the Clinical Establishments Act, telemedicine guidelines, or state rules in Telangana)? We give no medical care.

**Who can consent**

- **Q5.** The account is usually opened by an adult child (the "owner"). The data is about the patient, usually an elderly parent. Is the owner's consent enough? Do we need the patient's own consent, recorded separately, and in what form (tick in the app, signature on paper, recorded phone call)?
- **Q6.** What must we do when the patient cannot give consent (dementia, serious illness)? Does the "lawful guardian" route for a person with disability apply, and what proof must we keep?
- **Q7.** Some dialysis patients are under 18. What verifiable parental consent process do we need, or should we refuse minors in the pilot?
- **Q8.** The owner also gives us an emergency contact's name and phone number. That person has not agreed to anything. What notice or consent do we owe them?

**Consent design**

- **Q9.** The app has three separate consents, each with its own switch (Part E). Trip coordination is required to book a visit; the other two are optional. Is it lawful to refuse the service if trip consent is not given?
- **Q10.** Consent can be withdrawn with the same switch. When trip consent is withdrawn, the companion immediately loses access to the patient's details and cannot act on the trip, but past visit history stays visible to the family and to our operations team. Is keeping that history acceptable, and under what ground?
- **Q11.** Is in-app notice plus switches enough as proof of consent, or do we need a signed form for the pilot?

**Retention and deletion**

- **Q12.** When a family asks us to delete their data, what must we still keep, and for how long (invoices and tax records, payment records, audit logs, records of an incident or complaint)? Please give periods we can print in the notice.
- **Q13.** Are we required to keep access or processing logs for a minimum period?
- **Q14.** Within what time must we complete a deletion or correction request?
- **Q15.** Before we build an in-app "delete my data" screen, is it acceptable for the pilot to take deletion requests by phone or email and carry them out by hand, with a written record?

**Sharing and processors**

- **Q16.** We share limited patient details with the companion (Part C, section 3). Companions are [EMPLOYEES / CONTRACTORS: founder to state]. What must their agreement say about confidentiality and data use?
- **Q17.** The dialysis centre receives the patient at handover. We do not send the centre any data through the app. Do we need any agreement with centres?
- **Q18.** Our processors are listed in Part C, section 5. What data processing agreements do we need, and does any of them create a cross-border transfer issue?
- **Q19.** We plan to keep a minimum operations copy in Salesforce (India region). Is anything more than a data processing agreement and naming them in the notice required?

**Liability and the terms**

- **Q20.** Companions are not nurses. They do not give medical care, medicines or first aid beyond calling for help. Is the wording in Part F, clauses 3 and 4, strong enough? What must we never say in marketing so that it stays true?
- **Q21.** In an emergency the companion calls 112 or 108 and then our support line and the family. What duty of care do we carry during the trip, and can we limit liability as drafted in clause 11?
- **Q22.** Travel is by cab or auto booked by [THE FAMILY / THE COMPANION / ANUGACARE: founder to state]. Who is liable for a road accident, and what insurance should we hold?
- **Q23.** Do the Consumer Protection Act and e-commerce rules apply, and do they require a specific refund, cancellation and grievance text?
- **Q24.** Is an arbitration clause seated in Hyderabad enforceable against a consumer, or should we use court jurisdiction only?

**People who work for us**

- **Q25.** We hold companions' own data (name, phone, home area, identity and background verification, training record). They need their own notice and consent. Can you provide or review one? It is not drafted here.

**Breach**

- **Q26.** Please confirm the breach steps and time limits (who we tell, in what form, by when) so that we can finish our internal breach runbook.

---

## Part C. Facts about the service and the data

This part is our description of what the system does. Please treat it as the factual basis for the drafts. If the notice says something the system does not do, the notice is wrong and we will fix it.

### 1. The service

AnugaCare sends a trained, non-medical companion to a patient's home on dialysis days. The companion travels with the patient to the dialysis centre, hands the patient to the centre's staff, and brings the patient home after the session. The family follows each step in a mobile and web app.

Operated by: [LEGAL ENTITY NAME], [REGISTERED ADDRESS], [CIN / GST]. Service area: Hyderabad, Telangana.

### 2. People who use the system

| Person | What they can do |
|---|---|
| Owner (family member who opened the account) | Everything for their patient: book and cancel visits, see visit progress, keep health documents, see and pay bills, change consent choices |
| Editor (family member) | Book and cancel visits, see visit progress |
| Viewer (family member) | See visit progress only |
| Patient | See their own visits and get the pickup code |
| Companion | See only the visits assigned to them, and only close to the visit time |
| AnugaCare operations staff | Plan visits, assign companions, handle problems, issue bills |

### 3. Data we collect

| Data | About whom | Why | Who can see it |
|---|---|---|---|
| Name, mobile number, preferred language | Each account holder | Login (one-time code by SMS), contact, language | The person, operations staff |
| Name, date of birth, home address and map location, dialysis centre, mobility notes (for example "needs a wheelchair") | Patient | To plan and carry out visits | Family with access, operations staff |
| Emergency contact name and phone number | A person named by the family | To call in an emergency | Owner, operations staff |
| Visit schedule, visit status, time of each step, companion's visit note | Patient | To run the visit and keep the family informed | Family with access, operations staff, the assigned companion |
| Pickup code | Patient's visit | To confirm the right companion at the door. Stored only in a scrambled (hashed) form | Family who request it; nobody can read the stored form |
| Health documents the family uploads (reports, prescriptions) | Patient | Family's own private record ("vault") | Owner and family the owner allows. Operations staff only if the owner turns on a separate permission; every view is logged. Never the companion |
| Bills, fares, payment status | Owner | Billing | Owner, operations staff |
| Record of consent choices and changes | Owner, patient | Proof of consent | Owner, operations staff |
| Audit log of sensitive actions | All users | Security | Operations staff |

What the companion sees: patient's first name, pickup address, centre, visit time and mobility notes, only inside a time window around the assigned visit. The companion never sees date of birth, diagnosis, health documents, bills, or any family phone number. Calls go through the AnugaCare support line.

What we do **not** collect today: diagnosis or treatment details as structured data, vital signs, medicine lists, live GPS tracking of the patient or companion, Aadhaar or other identity numbers of patients, card or bank details (these would be held by the payment provider), advertising or analytics identifiers.

**Q-note for the lawyer:** the database has empty tables for vital signs and medicines and a planned feature for the companion's live location during a visit. None is switched on. We will come back to you before enabling any of them.

### 4. Where the data is kept

- Database and file storage: Supabase, Mumbai region (AWS ap-south-1), encrypted in transit and at rest.
- Health documents: a private storage area; files are opened only through short-lived links after an access check.
- Web app hosting: Vercel (serves the app's code; patient data is not stored there).

### 5. Processors and other recipients

| Recipient | What they receive | Status |
|---|---|---|
| Supabase (hosting, database, login) | All data in section 3 | In use |
| Vercel (web hosting) | No stored patient data | In use |
| SMS / WhatsApp provider [NAME] | Mobile number, message text (login codes, visit updates) | Not yet chosen; test mode only |
| Payment provider [NAME] | Payer name, mobile number, amount | Not yet chosen; test mode only |
| Salesforce, India region | Minimum operations copy: names, visit times, status. No health documents, date of birth, addresses or notes | Planned |

We do not sell data and do not use it for advertising.

### 6. What is not built yet

- An in-app "delete my data" screen (deletion would be done by hand on request; see Q15).
- A screen to invite family members and change their access (operations staff do this on request).
- A configured support phone number and a named grievance officer.
- Real SMS, WhatsApp and payment providers.

---

## Part D. Draft privacy notice (shown in the app and on the website)

> **AnugaCare privacy notice**
>
> Last updated: [DATE]
>
> **Who we are.** AnugaCare is run by [LEGAL ENTITY NAME], [ADDRESS]. We arrange a companion to travel with a patient to dialysis and back home.
>
> **What we collect and why.**
>
> - *Your name, mobile number and language*: to log you in and contact you.
> - *The patient's name, date of birth, home address, dialysis centre and mobility needs*: to plan the visit and send the right help.
> - *An emergency contact's name and number*: to call them if something goes wrong.
> - *Visit times, visit status and the companion's note*: to carry out the visit and keep you informed at every step.
> - *Health documents you choose to upload*: to keep them in your private vault. This is optional.
> - *Bills and payment status*: to charge for the service and keep the records the law requires.
>
> We collect only what we need for these purposes.
>
> **Who sees it.**
>
> - *Your companion* sees the patient's first name, pickup address, centre, visit time and mobility needs, only around the time of the visit. Your companion never sees health documents, date of birth, bills or your phone number.
> - *Family members you allow* see what their access level permits.
> - *AnugaCare staff* see what they need to plan visits, solve problems and bill you. They can open your health documents only if you turn that permission on, and every view is recorded.
> - *Companies that work for us*: [LIST: hosting, messaging, payments, operations software]. They may use the data only to provide their service to us.
>
> We do not sell your data. We do not use it for advertising.
>
> **Where it is kept.** On servers in India. [CONFIRM AFTER Q18.]
>
> **How long we keep it.** While you use AnugaCare. After you leave or ask us to delete your data, we delete it within [PERIOD], except records the law requires us to keep, such as [BILLING AND TAX RECORDS FOR N YEARS]. [COMPLETE AFTER Q12 TO Q14.]
>
> **Your choices and rights.** You can:
>
> - see the data we hold about you and the patient;
> - ask us to correct or update it;
> - withdraw any consent at any time in the app under "Privacy and consent". It is as easy as giving it. If you withdraw consent for trip coordination, we cannot provide visits;
> - ask us to delete your data;
> - name another person to use these rights for you if you die or become unable to;
> - complain to us, and if you are not satisfied, to the Data Protection Board of India.
>
> **How to reach us.** Grievance officer: [NAME], [EMAIL], [PHONE]. We reply within [N DAYS].
>
> **Children and people who cannot decide for themselves.** [TEXT AFTER Q6 AND Q7.]
>
> **Emergencies.** AnugaCare is not an emergency or medical service. In a medical emergency call 112 or 108.
>
> **Changes.** If we change this notice in a way that matters, we will tell you in the app before the change applies, and ask for consent again where the law requires it.

---

## Part E. Draft consent wording

The app already shows three separate choices on one screen, each with its own switch. Nothing is switched on in advance. Only the owner can change them. The current wording is below with proposed additions in *italics*. **Q9 to Q11 apply.**

**Screen title:** Choose what you share

**Introduction:** You're in control. You can change or withdraw these choices here at any time. *Read our privacy notice [LINK].*

**1. Trip coordination (needed to book visits)**

> Share visit schedule, pickup and drop-off locations, and trip details with your assigned companion. Your health documents are not shared.
>
> *We use the patient's name, address, dialysis centre, mobility needs and emergency contact to plan and carry out visits. AnugaCare staff can see these details.*
>
> If you turn this off, you can't book visits.

**2. Private health vault (optional)**

> Store health documents in your family vault. Private; never visible to your companion.

**3. Let AnugaCare support see my vault (optional)**

> This permission applies to this patient until you withdraw it. Support views are logged.

**Proposed new line for the owner, shown once before the first choice is saved (wording depends on Q5 and Q6):**

> I confirm that I am 18 or older and that [THE PATIENT HAS AGREED TO / I AM LEGALLY ALLOWED TO DECIDE] the sharing of their details with AnugaCare for these purposes.

**Proposed line on the patient's own first login (if Q5 requires it):**

> [NAME OF OWNER] has arranged AnugaCare visits for you. We use your name, address, dialysis centre and mobility needs to send a companion with you. [I AGREE / I DO NOT AGREE]

---

## Part F. Draft terms of service (family and patient)

> **AnugaCare terms of service**
>
> Last updated: [DATE]
>
> **1. Who we are.** "AnugaCare", "we" and "us" mean [LEGAL ENTITY NAME]. "You" means the person who opens the account and anyone who uses it with your permission.
>
> **2. What we provide.** A trained companion goes to the patient's home, travels with the patient to the dialysis centre, hands the patient to the centre's staff, and brings the patient home after the session.
>
> **3. What we do not provide.** Companions are not doctors, nurses or paramedics. They do not give medical advice, medicines, injections or treatment, and they do not operate medical equipment. AnugaCare is not an ambulance or emergency service.
>
> **4. Emergencies.** In a medical emergency, call 112 or 108. If an emergency happens during a visit, the companion will call emergency services and then tell AnugaCare and your emergency contact. AnugaCare does not send emergency help.
>
> **5. Your responsibilities.** You agree to: give us correct details about the patient, including mobility needs and anything a companion must know to travel safely; tell us before the visit if the patient is unwell or not fit to travel; make sure someone is reachable on the emergency contact number during the visit; keep the pickup code private and give it only to the companion at the door.
>
> **6. When a companion may refuse or stop a visit.** A companion may decline to start, or may stop and call for help, if the patient appears too unwell to travel safely, or if the companion faces abuse or unsafe conditions. [CHARGES IN THIS CASE.]
>
> **7. The pickup code.** We confirm the companion at your door with a one-time code. Do not hand over the patient to anyone who cannot enter the code successfully.
>
> **8. Booking, changes and cancellation.** You can request a visit in the app; a visit is confirmed only when we confirm it. You can cancel in the app before the companion sets out. [CANCELLATION AND LATE-CANCELLATION CHARGES.] If we cannot provide a confirmed visit, we will tell you as early as we can and [REMEDY: REFUND / CREDIT].
>
> **9. Prices and payment.** Prices are shown before you book. Cab or auto fare is [EXTRA / INCLUDED] and is shown separately on your bill. Bills are due [TERMS]. [GST.] [REFUND TERMS.]
>
> **10. Travel.** Travel is by [CAB / AUTO] booked by [WHO]. [RESPONSIBILITY FOR THE VEHICLE AND DRIVER, AFTER Q22.]
>
> **11. Our responsibility to you.** We will provide the service with reasonable care and skill. We are not responsible for the patient's medical condition or treatment, for the dialysis centre's services, or for delays caused by traffic, weather or events outside our control. [LIMIT OF LIABILITY, AFTER Q21. Nothing here limits liability that the law does not allow us to limit.]
>
> **12. Your data.** Our privacy notice explains what we collect and your choices. Consent for data use is asked separately in the app and is not part of accepting these terms.
>
> **13. Family access.** The account owner decides who else in the family can see or manage visits. You are responsible for the people you ask us to add.
>
> **14. Ending the service.** You can stop at any time. We may suspend or end the service if these terms are broken, if bills stay unpaid, or if we can no longer serve your area, with [NOTICE PERIOD] notice where possible.
>
> **15. Complaints.** Contact [GRIEVANCE OFFICER, EMAIL, PHONE]. We acknowledge within [N] hours and aim to resolve within [N] days.
>
> **16. Changes to these terms.** We will tell you in the app at least [N] days before a change applies.
>
> **17. Law and disputes.** These terms are governed by the laws of India. [COURTS AT HYDERABAD / ARBITRATION, AFTER Q24.]

---

## Part G. What we believe must exist before the first real patient

Please correct or add to this list.

1. Lawyer-approved privacy notice, consent wording and terms, in English, Telugu and Hindi.
2. A named grievance officer with a working phone number and email.
3. A written process for access, correction, withdrawal and deletion requests, even if done by hand.
4. Retention periods decided and written down.
5. Signed data processing agreements with each processor in Part C, section 5.
6. Confidentiality and data-use terms signed by every companion and staff member, and a companion privacy notice.
7. A breach runbook with a named owner.
8. A production system separate from the test system, with real login codes, and no test accounts.
9. Insurance as advised under Q22.
10. A record of the patient's own consent in the form advised under Q5.

## Part H. Blanks the founder must fill before sending

- Legal entity name, registered address, CIN, GST number.
- Companions: employees or contractors.
- Who books and pays for the cab or auto.
- Grievance officer name, email and phone; support line number.
- Prices, cancellation charges, refund terms, billing terms.
- Chosen SMS / WhatsApp and payment providers, if decided.
