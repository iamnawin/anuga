# Companion test visit and navigation - 2026-11-14

### Agent Session - 2026-11-14 20:18:30 IST - Companion navigation verified preview; font LIVE

**Agent:** Codex; Companion navigation repair and synthetic readiness.
**Task ID / Name:** COMPANION-TEST-ACCESS-20261114, plus approved TEXT-SIZE publication follow-up.
**Session start:** First captured19:48:30 IST; checkpoint 2026-11-14 20:18:30 IST.
**Repository / Worktree:** D:/AI-Workspace/Repos/anuga-companion-test-access.
**Branch:** fix/companion-test-visit-access.
**Starting commit:** 67cca2e; current-main font merge d5e3f39 reconciled locally.
**Current commit:** Tested source8c2208be8391ca5933d6a3665200fe7ad9fdf7dd; later receipt Git metadata identifies its commit.
**PR:** #48 OPEN/MERGEABLE https://github.com/iamnawin/anuga/pull/48 . Font #47 MERGED by explicit founder approval as d5e3f39efae8c2cb8b31becf055694bc5b4a65b2.
**Scope:** Fix web map handoff and unclear start date; prepare one eligible synthetic visit without disabling guards.
**Completed work:** Web HTTPS directions, native map schemes retained, authorized home coordinates preferred, hidden stale coordinates remain blocked. Future Start shows localized date/time. Existing owner request/Ops confirm/assign created scheduled visitf85106fd-1408-4192-9702-67dd06d9f9e0 forAsha9000000201 pickupNov14 20:23IST. Manual browser left visit unstarted for founder. Font setting promoted separately with founder approval.
**Files changed:** Companion UI/trip screen, regression tests, six tracking docs and curated fixture/browser/CI evidence; main font source retained without alteration.
**Tests and actual results:** Initial date/coordinate RED, Companion65 PASS/analyzer clean. Full local check-all before main reconciliation PASS DB209/11 old skips, Ops70/build, shared39, legacy Companion58/3 old skips, Family181/6 old skips, unified162. Final combined-source CI ALL7 SUCCESS including Android and both real browser journeys. Four-app releasebuild PASS. Actual Chrome sign-in shows new Today card, enabled Navigate/Start; clicking Navigate opens Google Maps HTTPS directions at synthetic home17.495,78.405 and renders route. No Start/pickup/completion action performed by manual smoke. Preview bundle matches local SHA4A6D223E35B01AFC8B0FE14134A03F6051703B8608F11E88BD858924B0245A23.
**CI evidence:** https://github.com/iamnawin/anuga/actions/runs/43605963396 on8c2208b ALL7 SUCCESS. Font headbf5a531 CI43604067348 SUCCESS before authorized merge; source5509d4d CI43603097816 also7SUCCESS. Receipt-only CI separate.
**Merge status:** Navigation #48 not merged; pending explicit founder reply to merge/publish question. Font #47 merged d5e3f39.
**Deployment and migration status:** Navigation preview READY dpl_3pVCRkTDbxUcxRjQsYoFdvdQ8b5z https://anuga-fq2p48yqe-iamnawins-projects.vercel.app/app/ . Initial CLI ended fetch-failed after upload; independent Vercel inspection READY, HTTP200 and exact bundle hash verified. Existing LIVE alias points to font deployment dpl_6WYYtt1AWoJ2PLYykCUteu8LiLGb https://anuga-7i15w99uc-iamnawins-projects.vercel.app/app/, created20:04:43IST. Promoted font bundle exactC7BD6B3D5DF8E13052F132E6783D6B30C65E5F56279138354D09048105E6F834; real browser confirms Text size Standard. Direct main-domain fetch timed out locally, authenticated Vercel alias mapping/artifact and generated public production URL confirmed. No migrations/auth/RLS/provider changes. One synthetic scheduled fixture created with ordinary app RPCs only.
**Decisions and assumptions:** Initial first-screen block was future-window fixtures; no timing/visibility guard bypass. Map fix is separate from font approval. Maps screenshot containing external browser account/location context discarded; evidence contains only synthetic app screenshot and URI/result receipt. No physical/native launcher acceptance claimed.
**Blockers:** Navigation live publication approval pending; no technical blocker. App allows Start for prepared visit; founder completes workflow (Family generates pickup code when needed).
**Uncommitted changes:** Own receipt/evidence before commit; application unchanged after8c2208b.
**Exact next action:** Founder opens/refreshes Today as9000000201 and tests20:23 visit, or reviews preview. Answer pending question to merge/publish #48; upon approval verify head/unchanged product source and greenCI, merge normally, promote exact verified preview, verify alias/hash and record receipt. Do not create another overlapping fixture or start founder's trip. Main font setting already live; More/Me/Help -> Text size.
**Next responsible agent:** Founder for navigation publication/visit walkthrough; Codex for authorized publication follow-up.

Agent Codex; task COMPANION-TEST-ACCESS-20261114. Worktree
`D:/AI-Workspace/Repos/anuga-companion-test-access`, branch
`fix/companion-test-visit-access`, starting67cca2e. First captured clock19:48:30 IST.

## Diagnosis

Read-only authenticated inspection found Asha201 had five future scheduled visits,
first November16 at07:00 IST, start allowed04:00 that day. All home details were
correctly hidden. Ravi202 had no assigned visits. The apparent first-screen block
was a stale/ineligible fixture, not a missing state transition. The UI showed only
the opening clock time, obscuring the date.

The map action also used geo: on web and ignored existing home coordinates,
instead sending a synthetic sample address that cannot reliably be geocoded.

## Correction

- Web sends an HTTPS Google Maps directions URL with encoded destination. Native
  Android geo: and iOS maps: remain. Launcher uses platformDefault on web.
- Home coordinates are preferred only while detailsVisible is true. Hidden stale
  coordinates never enable navigation; centre address still supplies centre leg.
- Future Start message includes localized date and time, retaining server timing.
- Existing Family request/Ops confirmation/assignment RPCs prepared one synthetic
  visit for Asha9000000201, pickup2026-11-14 20:23 IST. It was verified scheduled,
  detailsVisible and inside Start window; left unstarted for founder. Receipt JSON
  contains exact IDs. No existing visit was advanced/deleted, no timing/access
  guard weakened, no DB migration or provider change.

Map URL reference: https://developers.google.com/maps/documentation/urls/get-started
uses api=1/destination and requires no API key. No paid Maps API enabled.

## Verification

New date and coordinate tests failed before changes. Unified analyzer clean;
focused Companion suite65 PASS, including native/web URI generation, address
encoding, hidden coordinates, all persisted journey states and EN/TE/HI200%.
Full repository check running; build/browser/CI follow. Physical phone navigation
and native app launch acceptance not claimed. Synthetic addresses/coordinates are
test fixtures, not real patient destinations.

Font feature47 has separate explicit founder approval to merge/publish. Keep its
release state distinct from this navigation change.
