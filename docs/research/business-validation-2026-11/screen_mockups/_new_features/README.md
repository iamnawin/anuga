# New features you asked for: centre search, profile photos, map navigation

Status: proposals for founder review. Nothing is built. Each one needs an ADR because it changes the design contract or adds data.

## 1. Centre search with a photo (new screen F38)

**What you asked:** a search where a family types a hospital or dialysis centre name and sees matching centres, with a photo so a patient can recognise the place.

**Screen F38 "Find your centre"** (used in setup step 2, F2, and later when changing centre):
- Search box at the top. Typing filters as you go (name, area, locality).
- Result card: photo, centre name, area, distance from home, small chip "Already served by AnugaCare" if it is in our centres table.
- Tap a card: centre detail with address, a "Navigate" link, and a button "Choose this centre".
- If the centre is not found: "Tell us the name" form that sends a request to ops. Never invent a centre.

**Facts from the repo:** `public.centres` has name, address, location (a map point), phone and cluster. It has **no photo column and no search function** yet. Search would be a new read RPC (with an allowed and a denied test), plus a photo field.

**Rules to keep it honest:**
- Do **not** scrape Google or hospital websites for photos (copyright and terms). Use photos we take ourselves on a shadow run, or that the centre gives us in writing.
- A listing does **not** mean the centre has agreed to work with us. Do not show their logo as a partner or use words like "approved" or "endorsed" (partnership strategy, permission map S0 to S5). The chip says only that the centre is in our list.
- Photo of the building front only, no patients or staff.
- A fallback when there is no photo: a neutral building icon with the name.

## 2. Profile pictures for patients and companions

**What the design contract says now:** `docs/design/tokens.md` bans avatar photos. So this needs an ADR before building.

**Recommended approach:**
- **Interim (no ADR):** illustrated avatar or initials, as in the mockups.
- **With ADR:** optional real photo, and only for these uses:
  - A companion sees the patient's photo only for an assigned trip inside the existing time window, so they can recognise the patient at pickup.
  - A family sees the companion's photo only once that companion is assigned to their trip.
  - Never shown elsewhere, never in lists or notifications.
- Photo is personal data: needs the patient's or family's consent (a new consent purpose), stored in the private bucket with a server-generated path, deleted when consent is withdrawn (links to F29).
- Companion photo comes from onboarding (C20) and is checked by ops.
- Always allow "no photo" with initials.

**Open decision:** do you want the companion to see the patient's photo? It helps identification but it is the more sensitive of the two. Ask a lawyer.

## 3. Map and navigation

**Design contract today:** no fake map or ETA. A real map is allowed only with a decision.

**Three steps, cheapest first:**

| Step | What | Cost / risk | Needs |
|---|---|---|---|
| M0 (recommended now) | A "Navigate" button that opens the phone's own maps app with the centre or home address | No SDK, no data sent to us, no cost | Small screen change, no ADR |
| M1 | A static map pin in setup (F2) to confirm the home location, and a pin on centre detail | Map provider terms and cost; home location is sensitive | ADR, provider choice |
| M2 | Live position of the companion for the family | Consent, battery, cost, privacy, accuracy, and a promise we may not keep (the scheduling analysis shows delays are common) | ADR, founder decision, probably after the pilot |

Honest note: a live "where is my companion" map sets an expectation of exact arrival times. Our scheduling analysis says pickup windows should be 30 to 45 minutes. A live map without reliable timings may increase complaints. Start with M0.

## Screen list effect

If you approve all three, the screen list changes as follows (the master list is not edited until you decide):
- New F38 Find your centre (NEW, P1)
- F2 changes (centre picker becomes F38)
- C8 and C6 gain a Navigate button (M0)
- C20 and F1 gain optional photo capture (after the ADR)
- C23 live map stays deferred
