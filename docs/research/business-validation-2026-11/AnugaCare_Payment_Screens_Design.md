# Payment screens for the plan purchase: design, mockup prompts and tooling review

Date: 2026-11-12. Draft for founder review. Design and research only: no application code, no changes to any development branch, nothing sent, installed, run or spent.
Scope: the family-facing purchase of the two-week Care Trial or a Care Plan. Prices are dialysis scenario D1 test values `[E]` from `AnugaCare_Final_Pricing_and_Decision_Memo.md` and `AnugaCare_Strategy_v2_Long_Term_Vision.md`. GST is unresolved `[I]`.
Labels: `[V]` found in a source, `[E]` my estimate or reasoning, `[I]` needs a developer, broker, CA or lawyer to settle.

---

## 1. The two repositories you proposed

### YouPI-PG (`youpi-pg/youpi-pg`): do not use for AnugaCare payments

What I read (shallow clone, README, ARCHITECTURE, SECURITY_AUDIT, package.json; I ran nothing):
- It is a **self-hosted UPI "gateway" that confirms payment by reading the receiving phone's bank SMS, push notifications and Gmail alerts** and matching the amount `[V]`. It needs an Android app with SMS and notification access, Gmail OAuth or a headless-Chrome scraper, and a WhatsApp OTP.
- **It says itself that it is not fit for real money.** The README calls it an "experimental research project", not certified, not NPCI or bank approved, "not for critical payments", with a conservative guide of 20 payment attempts a day per receiving account. Its own security file says "EXPERIMENTAL; NOT APPROVED FOR REAL-MONEY PRODUCTION" and "bank settlement is not proven by notification parsing" `[V]`.
- **Payment attribution is ambiguous** when two people pay the same amount to the same UPI ID; the design admits it `[V]`.
- **Licence is unclear.** `package.json` says "Commercial", the README points to a `LICENSE` file, and I found none in the clone `[V]`. Do not use it without written terms.
- **Privacy risk.** It reads bank SMS and email on a merchant phone. For a service handling health-adjacent family data, that is a data-protection problem under the DPDP rules `[I]`.
- **Architecture mismatch.** It is a Node 24 monorepo with SQLite and an Android observer. Your project uses Supabase, Postgres and edge functions with signed provider webhooks.
- **Regulatory note.** Taking customer payments to an ordinary account through a UPI QR is not the same as using a registered gateway; the repo itself warns that using it does not authorise you to run a payment service `[V]`. A CA or lawyer must confirm what applies to AnugaCare `[I]`.

**Verdict:** fine as something to read to learn how UPI flows work; wrong for real payments, and a poor fit for your stack.

### Awwwards-mcp (`INSANE0777/Awwwards-mcp`): not a payments tool, and I would not install it

- It is an MCP server that crawls Awwwards, captures screenshots and design details, analyses motion on any URL, and can "recreate the page section by section" into a Vite, Astro or Next.js project. MIT licence `[V]`.
- **Wrong fit:** Awwwards winners are motion-heavy marketing websites, not elderly-first mobile payment screens. Your product rules (large tap targets, high contrast, three languages) pull the other way.
- **Copying risk:** rebuilding a site section by section from another studio's award-winning work raises copyright and terms-of-use questions, and I did not verify Awwwards' scraping terms `[U]`.
- **Supply-chain risk:** installing an MCP server runs third-party code with browser automation and network access in your development environment.
- **If you want inspiration:** browse Material 3 guidance, Google Pay, PhonePe and Paytm checkout patterns, and your own `docs/design/tokens.md`. Use the prompts in section 5 for the mockups.

---

## 2. How payments already work in your project, and what the new model changes

From `docs/ARCHITECTURE.md` (section 6.6): Ops builds and issues a **monthly invoice**; the family owner taps **Pay**; the app calls the `payments` function, which starts a payment through a **provider adapter**; a signed provider webhook calls `payment_captured`. Today only the **test adapter** exists, and live keys are refused unless `PAYMENTS_LIVE_AUTHORIZED=yes`. Amounts are in paise.

What this means for the new screen:
- **A real gateway fits this design,** because it has signed "payment captured" webhooks and refund APIs. Candidates to quote: Razorpay, Cashfree, PhonePe PG, PayU, Juspay `[I]`. Earlier research found Razorpay's standard fee at about 2% plus GST, even on UPI `[V]`, and UPI itself carries zero MDR (a possible change was unconfirmed). Get quotes and read the terms.
- **The new model is prepaid;** the current flow is post-paid monthly billing. Plan purchase, the ₹500 deposit credit, trial refunds and a fare wallet are **new payment products**. A developer should decide whether a purchase creates an issued invoice paid immediately (reusing the existing path). That changes `docs/PRODUCT_SPEC.md`, so **an ADR is required** under the repository rules `[I]`.
- **Live payments stay gated** until you authorise them, and a gateway business account needs an entity, a bank account in the business's name and a CA view on GST `[I]`.
- **A payment page receives patient-adjacent data** (names, phone numbers, plan). The repository rule is to ask before adding any third-party SDK that receives patient data. Prefer the gateway's hosted or intent checkout so card details never touch your servers.

---

## 3. Screen flow (family app, after onboarding and consent)

Six screens plus states. Copy is English first; Telugu and Hindi need native review.

### P1. Choose a plan
- Title: "Choose your plan".
- Card A (recommended first): **Two-week Care Trial**, ₹5,499, 6 round trips in 14 days. Line: "Stop any time. Unused trips are refunded."
- Card B: **Care Plan**, ₹10,999 for 4 weeks, 12 round trips (about ₹917 per trip).
- Card C: **Safe Return**, ₹7,799 for 12 trips home only.
- Under all cards: "Cab or auto fare is extra and paid separately." "Our companions are not nurses and do not give medical care."
- Each card lists only promises you can keep: "A named companion confirmed 48 hours before each trip", "A message at every step". **Do not show a backup guarantee.**
- Button: "Choose this plan".

### P2. Review and pay
- Plan line and price.
- If a deposit was paid: "Deposit credit −₹500".
- Optional line: "Fare wallet top-up" with a short explanation ("Fare is paid at cost; unused amount is refunded"). Keep it separate from the plan price.
- Tax line: "GST: [to be confirmed]" until a CA confirms; never show a tax figure that is not true.
- **Total to pay**, large.
- Collapsible "Refund terms": cancel up to 12 hours before a trip at no charge; unused trips refunded within 7 days; if we cannot cover a booked trip we refund it and add a ₹150 credit.
- A **separate** terms checkbox (not bundled with the data consents).
- Who pays: "Pay now" or "Send a payment link to a family member" (many payers are the adult child, not the person using the app).
- Button: "Continue to payment".

### P3. Choose how to pay
- Big amount at the top.
- UPI apps list (Google Pay, PhonePe, Paytm, others) using UPI intent where available.
- "Pay with a UPI ID".
- "Show a QR to scan with another phone".
- "Card or net banking".
- Small line: "Secure payment by [gateway name]". Do not show a gateway until chosen.

### P4. Waiting for confirmation
- "Waiting for your payment to confirm. Please don't close this screen."
- Progress indicator, a timer, and a "I've paid, check again" button.
- After a timeout: "Still waiting. If money left your account, it will be confirmed or refunded automatically. You can leave this screen."

### P5. Payment successful
- Large check icon, "Payment received", amount, plan, receipt number, date.
- Next steps: "Add your parent's visit details" and "We will confirm your named companion 48 hours before each trip".
- Buttons: "Download receipt", "Go to home".

### P6. Payment failed or pending
- Failed: "Your payment didn't go through. No money was taken, or any amount taken will be returned by your bank." (Only if the gateway confirms this.) Buttons: "Try again", "Choose another method".
- Pending: "We're confirming your payment." with the help line.
- Contact: "Need help? Call or message [support number]."

### Edge cases to design
Payer differs from the account holder; payment link expired; duplicate payment; partial refund after a trial stop; failed refund; amount mismatch; UPI app not installed; slow network; language switch mid-flow; 200% text size.

### Accessibility and trust rules
Text at least 16 to 18px; amounts at least 28px; buttons at least 56px high; high contrast; one primary action per screen; labels that do not rely on colour; no countdown pressure; plain language; the dev banner "Development build · synthetic data only" until production is authorised.

---

## 4. Data the payment flow needs (minimum)
Account holder name and phone; payer name and phone if different; plan and amount; deposit credit; fare wallet amount; terms acceptance with timestamp; gateway order and payment ids; status; refund records. No card data stored by AnugaCare. No health data on the payment screens. Keep retention and deletion rules per the privacy notice `[I]`.

---

## 5. Mockup prompts

**Master style block (paste at the start of every prompt):**
```
Mobile app UI mockup, single phone screen, full screen visible and not cropped, 390x844 portrait, flat vector UI, Material 3 inspired,
calm and trustworthy, large tap targets (min 56px for primary buttons), high-contrast text, generous spacing, rounded corners (16px),
elder-friendly, no stock photos, no medical symbols, no hospital crosses.
Brand: "anugacare" lowercase wordmark with a teal arch-shaped symbol and a small marigold orange dot. Tagline: "Someone beside you, every visit."
Palette: deep teal-black background #10302E (dark) or soft white #F6FAF9 (light), primary teal #0E7C78, mint button #8FE3D0 with dark teal text #0B2B29, marigold accent #F5A623.
Font: Inter or Noto Sans, 16-18px body, amounts 28px bold.
Footer chip: "Development build · synthetic data only". No watermark. Crisp readable text, correctly spelled.
```

**P1 Choose a plan**
```
[Master style block]
Screen: "Choose your plan". Back arrow top left.
Three stacked cards. Card 1 with a small "Recommended to start" pill: "Two-week Care Trial", price "₹5,499", "6 round trips in 14 days", line "Stop any time. Unused trips are refunded."
Card 2: "Care Plan", "₹10,999 for 4 weeks", "12 round trips (about ₹917 per trip)".
Card 3: "Safe Return", "₹7,799 for 12 trips home only".
Each card has two checklist lines: "A named companion confirmed 48 hours before each trip" and "A message at every step".
Below the cards, small text: "Cab or auto fare is extra and paid separately. Our companions are not nurses and do not give medical care."
Primary mint button: "Choose this plan".
```

**P2 Review and pay**
```
[Master style block]
Screen: "Review and pay". Back arrow.
Summary card: "Two-week Care Trial  ₹5,499", "Deposit credit  −₹500", "GST  to be confirmed", a divider, then "Total to pay  ₹4,999" in large bold text.
Collapsed row with a chevron: "Refund terms".
Checkbox: "I agree to the refund terms".
Two options as segmented buttons: "Pay now" (selected) and "Send payment link".
Primary mint button: "Continue to payment".
```

**P3 Choose how to pay**
```
[Master style block]
Screen: "Pay ₹4,999" with the amount large at the top.
List of options with simple generic icons (no real brand logos): "UPI apps" with three placeholder app tiles, "Pay with a UPI ID" input row, "Show QR to scan with another phone", "Card or net banking".
Small lock line: "Secure payment".
Primary mint button: "Pay ₹4,999".
```

**P4 Waiting**
```
[Master style block]
Screen: Waiting for payment. Centered calm progress ring, text "Waiting for your payment to confirm", subtext "Please don't close this screen.", timer "00:42".
Secondary outline button: "I've paid, check again". Text link: "Need help?".
```

**P5 Success**
```
[Master style block]
Screen: Payment successful. Large teal circle with a white check, title "Payment received", amount "₹4,999", lines for plan, receipt number, date.
Info card: "Next: add your parent's visit details. We'll confirm your named companion 48 hours before each trip."
Buttons: primary mint "Add visit details", outline "Download receipt".
```

**P6 Failed**
```
[Master style block]
Screen: Payment failed. Calm amber icon (not alarming red), title "Your payment didn't go through", subtext "If any money was taken, your bank will return it.",
buttons: primary mint "Try again", outline "Choose another method". Footer: "Need help? Call or message us."
```

Negative prompt: `photorealistic faces, stock photos, real bank or app logos, hospital crosses, stethoscope, nurse uniform, text artifacts, misspelled words, tiny buttons, low contrast, clutter, watermark, neon colours.`

Tips: attach your built login and consent screens as style references; regenerate any screen with garbled text, then retype the copy in Figma or Canva; make a light variant by swapping the background line; make Telugu and Hindi variants only after native review.

---

## 6. Decisions for you
1. Confirm the three plan cards for the pilot (trial first, plan second, Safe Return later?).
2. Choose a gateway to get quotes from (Razorpay, Cashfree, PhonePe PG, PayU, Juspay). Contact is yours to authorise.
3. Confirm a prepaid purchase flow (needs an ADR) and who writes it.
4. CA answer on GST before any price is shown to customers.
5. Whether to offer "Send payment link" in the first version.

## 7. Limits
- I read the two repos' documentation and file layout, not every source file, and ran nothing.
- The gateway shortlist and fees are `[I]`; only Razorpay's 2% plus GST and zero UPI MDR came from earlier research.
- Screens are design only. No code was written and no branch was changed.
- Sources: [YouPI-PG](https://github.com/youpi-pg/YouPI-PG), [Awwwards-mcp](https://github.com/INSANE0777/Awwwards-mcp), `docs/ARCHITECTURE.md` section 6.6 in this repository, `CLAUDE.md` repository rules.
