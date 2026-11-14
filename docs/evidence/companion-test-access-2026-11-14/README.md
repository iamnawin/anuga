# Companion test visit and navigation - 2026-11-14

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
