# Developer handoff: prompt to give your colleague

Date: 2026-11-12. Draft for founder review. This is a prompt and a checklist, not code. Nothing was sent to anyone.
Use it with any AI coding assistant or as a written brief. Replace the `[BRACKETS]` before sending.

## What you hand over with the prompt

1. Access to the repository `iamnawin/anuga` (and, if you want the research, PR #31 on branch `ccr-d6e3aaf3-jvijtn`, which contains docs only).
2. These files from PR #31: `AnugaCare_App_Navigation_and_Screen_Map.md`, `AnugaCare_Payment_Screens_Design.md`, `README_scope_and_index.md`.
3. Your mockup images (login, consent, and the new screens), with a note that they are **direction, not specification**.
4. Answers to the open decisions in section "Decisions the founder must make first" below.
5. A named person who answers questions (you) and a place to report back.

## Split the work into three prompts, not one

Three streams touch different parts of the code. Give them one at a time so work does not collide.

| Stream | Scope | Touches | Starts when |
|---|---|---|---|
| **A: Screens** | Family and companion screens per the navigation doc, using existing data and RPCs | `apps/anugacare_app/lib/**` (and ARB files); no database changes | Now |
| **B: Plans and payment** | Prepaid plan purchase, deposit credit, refunds, test-mode payment | New ADR, then `supabase/migrations`, `supabase/functions`, `packages/shared_dart`, UI | After you approve the ADR |
| **C: Ops and Manager** | New "manager" role and new ops screens | ADR and design first; then migrations and `apps/ops_console` | After you approve the design |

## Decisions the founder must make first (answer these before sending)

1. **Base branch.** PRs #28, #29, #30 and #32 are open, and #32 is stacked on `feat/anugacare-ui-modernization`. Say which branch the colleague branches from (recommended: the latest `main`, or the stack's tip if #32 has merged), and tell them not to push to anyone else's PR branch.
2. **Which app.** `CLAUDE.md` says the delivery direction is the unified `apps/anugacare_app` (web/PWA first, Android preserved). Confirm Stream A targets that app, not the older `family_app` and `companion_app`.
3. **What "Manager" means.** My assumption: a senior AnugaCare role above Ops who approves refunds, approves companion verification, reviews incidents, sees reliability metrics and centre-partnership status, and changes business settings (prices, windows). Confirm or correct.
4. **Payment gateway choice** (needed only for Stream B's live step; test mode needs none).
5. **Whether "likes" means preferences** (see the navigation doc).

---

## The prompt (copy from here)

```
You are a senior full-stack engineer (Flutter, Supabase/Postgres, Next.js) joining the AnugaCare project. Work independently, in small steps, and stop for review at the end of each stream.

PROJECT
AnugaCare is a trusted companionship and assisted-mobility service in India. The first service is dialysis visits: a companion takes a patient from home to the dialysis centre, hands them to centre staff, and returns later to bring them home. Roles in the database: family (access levels owner, editor, viewer, patient), companion, ops_admin. Everything runs on SYNTHETIC data only.

READ FIRST, IN THIS ORDER
1. CLAUDE.md  2. docs/HANDOFF.md  3. docs/PRODUCT_SPEC.md  4. docs/TASKS.md  5. docs/ARCHITECTURE.md  6. docs/design/tokens.md
7. docs/research/business-validation-2026-11/AnugaCare_App_Navigation_and_Screen_Map.md (screen map, progress bars, EXISTS / SPEC / NEW labels)
8. docs/research/business-validation-2026-11/AnugaCare_Payment_Screens_Design.md (plan purchase and payment screens)
9. docs/research/business-validation-2026-11/README_scope_and_index.md
The research documents are on branch ccr-d6e3aaf3-jvijtn (PR #31, docs only). Prices and plans in them are TEST VALUES from one dialysis scenario, never constants. Mockup images are direction, not specification: "no new capabilities are authorized by an image".

BASE BRANCH AND GIT
- Branch from [BASE BRANCH]. Create your own feature branches, one per stream. Small commits.
- Do NOT push to or edit anyone else's branches or PRs (#28, #29, #30, #32 are open and stacked). Do not force-push shared branches.
- Open DRAFT pull requests only. Never merge. Never deploy. No migrations against any hosted project.

HARD RULES (from CLAUDE.md and the design contract)
- Synthetic data only. No production, no real payments, no real SMS, no paid providers. Payment and notification adapters stay in test mode. PAYMENTS_LIVE_AUTHORIZED stays off.
- Ask before adding any third-party SDK or service, especially one that receives patient data. Do not adopt YouPI-PG or Awwwards-mcp.
- The database is the security boundary. Grants are revoked by default. Any new table needs explicit grants, RLS policies, and allowed AND denied tests. Security definer functions use `set search_path = ''` and fully qualified names.
- Any decision that changes docs/PRODUCT_SPEC.md needs an ADR in docs/adr/ first. Write the ADR, then wait for approval before building.
- Companions never see the vault, diagnoses, date of birth or billing. No separate patient mode. No clinical features. Never call a companion a nurse or medical professional.
- UI rules: no fake ETA, map, countdown, notification count or verification badge. Status uses words, not colour alone. Tap targets at least 48px, primary buttons at least 56px, text at least 16 to 18px, works at 200% text scale, light and dark, English + Telugu + Hindi through the ARB files (no hard-coded strings).
- Business values (prices, windows, limits) live in packages, clusters and app_settings, never in code.
- Never commit secrets or .env files.
- If a screen needs data or an RPC that does not exist, STOP and write a short proposal. Do not invent backend behaviour.

STREAM A: SCREENS (start here)
Build in apps/anugacare_app (confirm with me that this is the right app before starting).
Priority P0, in this order:
 1. Family Home with next-visit card and trip progress bar.
 2. Visit detail with the 9-step trip progress bar, built on the existing trip states (scheduled, companion_en_route, picked_up, at_centre, handed_over, session_done, returning, dropped_home, completed, plus cancelled, no_show, issue_reported).
 3. Visits list, Records, Bills (existing data).
 4. Bottom navigation (Home, Visits, Records, Bills, More) and top bar pattern; top progress bar only for linear flows.
 5. Companion Today, Upcoming, trip essentials, and trip run with the 8-step progress bar using the existing state actions, pickup code entry and required visit note.
Respect the family access levels (owner, editor, viewer, patient) exactly as in the navigation document, and verify with allowed and denied tests where the database is involved.
Do not change RPCs, auth, payment adapters or upload adapters in this stream. Screens only.

STREAM B: PLANS AND PAYMENT (only after I approve the ADR)
First deliverable is an ADR and a short data-model proposal for prepaid purchases: plans, trial, deposit credit, refunds, fare wallet, receipts, and how a purchase maps to the existing invoice and payment flow. STOP and wait for approval. After approval, implement in test mode: new RPCs with tests, an edge function using the existing adapter pattern, signed webhook handling, and the six payment screens. No live gateway.

STREAM C: OPS AND MANAGER (design only for now)
Write an ADR and permission matrix for a new "manager" role, [MY ASSUMPTION OF WHAT MANAGER MEANS]. Include: enum and RLS changes, which RPCs managers can call, audit requirements, new Ops screens, and tests you would write. Keep role checks centralised. Do not implement until I approve.

DONE MEANS (for each stream)
- scripts/check-all.sh passes. pnpm db:test passes if the database was touched. flutter analyze --fatal-infos and flutter test pass in the app you changed.
- Screenshots at 360 and 430 widths, English/Telugu/Hindi, light and dark, and 200% text.
- docs/TASKS.md and docs/HANDOFF.md updated, including checks you could not run.
- PR description maps each screen to the navigation document, lists deviations, and states exactly which checks ran and which did not.

REPORT BACK
After each stream: what you built, files changed, tests run and results, anything unverified, open questions. Then stop.

QUESTIONS TO ASK ME BEFORE YOU START
Which base branch; confirm the target app; whether #32 has merged; my definition of manager; ADR numbering; anything in the docs that seems to conflict.
```

## Notes for you

- Send Stream A first; hold B and C until their ADRs are approved.
- Ask the colleague to keep each PR small so you can review quickly.
- If your colleague uses an AI assistant, tell them to give it `CLAUDE.md` and this prompt in the same session.
- File ownership rule that avoids conflicts: Stream A owns `apps/anugacare_app/lib/**`; Stream B owns new migrations, functions and the payment RPCs; Stream C owns `apps/ops_console` and role changes. If two streams need the same file, they coordinate through you.

## Addendum (2026-11-12): companion mockups

The companion boards (screens 29 to 40) are direction only. Stream A includes Today, Upcoming, trip essentials, trip run, pickup code (6 digits), handover checklist and the completion note. It excludes live maps and ETA, earnings, fare and receipt entry, a public "Become a companion" sign-up, masked calling, and leg-level assignment. See section 11 of `AnugaCare_App_Navigation_and_Screen_Map.md`.

Update (2026-11-12, founder approved): the companion screens C1 to C20 are specified in `screen_mockups/Companion_Screens_FINAL_Spec_v1.md` (decisions D1 to D7, per-screen content, states). That file is the specification; the regenerated boards are direction. Allowed by those decisions: flat illustrated avatars (never photos), a drawn route card (home icon, line, centre icon, addresses) and a Navigate button that opens the phone's own maps app with the address. Not allowed without a new ADR: an in-app or static map, live position, ETA, raw phone numbers, masked calling.
