# ANUGA UI reference contract

Date: 2026-10-11. S2 baseline for S3, S4 and S5. Brand approval comes from the founder's current instruction; older product documents still call the brand undecided. Use ANUGA as the wordmark, Anuga in prose, and companion for the person's role. Keep package identifiers unchanged.

## Sources and corrected versions

All 15 supplied concept boards were opened visually. Their numbers below refer to filename suffixes; panel numbers are the numbers printed inside the board. Existing `docs/screenshots/m3/01-login.png` through `07-telugu.png` were also inspected: these are previous implementation evidence, not concept designs.

Prefer board 13 over 3 for panels 09-12 (2026 dates and corrected Basic handover). Prefer 14 over 6 for panels 21-24 (neutral prescription examples and corrected family navigation). Prefer 15 over 12 for panels 45-48 (ops role and corrected access history). Keep older boards as reference history.

Concept text, dates, names, prices, verification claims and permissions are examples. Never substitute them for RPC data. No new capabilities are authorized by an image.

## Colour tokens

Values are implementation approximations of visually observed colours, not an assertion that exact source hex values or font metadata were supplied.

| Role | Light value | Basis |
| --- | --- | --- |
| Background | `#F7FBFA` | Observed near-white mint canvas |
| Surface | `#FFFFFF` | Observed white forms and cards |
| Soft surface | `#EAF7F4` | Observed pale mint visit and privacy panels |
| Selected surface | `#D4F0E9` | Observed mint navigation selection |
| Primary / teal | `#00666B` | Darkened observed teal for accessible white labels |
| Primary hover | `#005357` | Accessibility / interactive adjustment |
| Primary foreground | `#FFFFFF` | Observed white button text |
| Ink | `#10243A` | Observed deep navy headings |
| Secondary ink | `#465D6B` | Darkened observed blue-grey supporting copy |
| Divider | `#D5E4E2` | Observed faint card separators |
| Control boundary | `#6A8588` | Darkened control outlines for distinguishable inputs |
| Success | `#166344` on `#DDF4E8` | Observed green completion / paid chips |
| Warning | `#754900` on `#FFF0CB` | Observed amber pending / assignment chips |
| Error | `#9E2929` on `#FDEAEA` | Accessible adjustment of concept red |
| Information | `#185E83` on `#E7F3FA` | Observed pale blue contextual notices |

Body and placeholder text must reach 4.5:1; large text and meaningful control boundaries 3:1. Status always includes text, not colour alone. Verify actual pairs after implementation. Preserve automatic dark mode with navy-green surfaces (`#102426`, `#183235`), white ink (`#EFF8F6`), secondary ink `#BED3D1`, mint primary `#8DDDD1` with dark primary foreground `#073B3E`. Dark mode is an accessibility extension, absent from the sketches.

## Typography, spacing and shapes

Observed: one familiar sans family, strong navy headings, regular supporting text, bold times and names. Exact font is unknown. Reuse system sans on the web and Flutter's existing platform font, including Telugu/Devanagari fallback. No external font dependency.

| Role | Implementation size | Weight / line height |
| --- | --- | --- |
| Page / mobile greeting | 28 | 700 / 1.25 |
| Section | 22 | 700 / 1.3 |
| Patient / time | 20 | 700 / 1.35 |
| Body / label | 18 | 400 or 600 / 1.5 |
| Supporting | 16 | 400 / 1.5 |
| Status | 14 minimum | 600 / 1.4 |

Sizes are CSS px or Flutter logical pixels before system scaling. Accessibility adjustment: preserve Flutter's minimum 1.15 text scale and honor larger user scaling without a maximum. Web text uses rem. Do not fix card height, clip translated labels, or shrink text to fit. Patient-facing primary facts can use 24-28 logical pixels.

Spacing scale: 4, 8, 12, 16, 24, 32, 48. Observed mobile gutter about 16; implement 20-24 where width permits, 16 on narrow screens. Section gaps 24, card padding 16-20, rows 12-16. Shapes: 12 radius cards / buttons, 8 radius inputs, full-pill status chips and circular icon backgrounds. Use thin complete borders and separators, minimal elevation. Use flat teal instead of the image tool's mottled gradients.

## Interaction and responsive rules

- Every interactive target at least 48 by 48; primary mobile buttons at least 56 high. These are accessibility adjustments to some smaller concept controls.
- Primary action teal with white label; secondary action outlined teal; destructive action red with explicit label. Busy states preserve disabled behavior and feedback.
- Web focus: 3px teal outline with 3px offset. On tinted or teal surfaces use a contrasting inner/outer ring. Flutter uses standard Material focus/hover states and visible outlines.
- Preserve loading, empty, denied, error, success and validation states. No fake countdown, ETA, maps, avatar photo, verification badge or notification count.
- Ops: mint sidebar on wide screens, top utility strip, white content, muted table headers; navigation wraps into an accessible header below 900px. Tables may scroll within their own labelled region. Forms and translated actions wrap.
- Mobile: scrollable content, safe areas, full-width primary actions where appropriate. Check 360 and 430 logical pixel widths, larger text and en/te/hi. Keep existing navigation and role-based visibility.
- Use built-in Material icons in Flutter. On web reuse existing text affordances; no icon dependency is required.

## Existing screen mapping

| Stream / implemented screen | Reference / panel | Intentional difference |
| --- | --- | --- |
| S3 login | board 1, 02-03 | Ops role sign-in retained; no signup or welcome route |
| S3 shell and trips board | board 11, 41 | Existing filters and actual trip states; no fabricated overview counts or unsupported nav |
| S3 trip reassignment | board 11, 42 | Existing inline form; DB eligibility errors and selectable ineligible options preserved |
| S3 schedules and assignment | board 11, 43 + 42 | Existing schedules and primary/backup actions; no calendar editing or new schedule creation |
| S3 exceptions | board 11, 41 visual vocabulary | Unmatched concept screen; preserve exception actions derived from transitions |
| S3 billing / fare entry | board 15, 46 | Existing invoice generation/issue and fare entry; no exports, payouts or sample prices |
| S4 login | board 1, 02-03 | Existing companion role gate; no onboarding / verification workflow |
| S4 today / upcoming trips | board 9, 31 | Existing lists and time-window restrictions; no earnings/profile navigation |
| S4 trip essentials | board 9, 32 | Actual restricted projection; no map/directions or invented phone action |
| S4 outbound / OTP / handover | board 8, 33-36 | Existing state-machine actions, OTP field and notes; no arrival state or extra handover checklist |
| S4 return / home / note / completed | board 10, 37-40 | Existing states and required completion note; no earnings, receipt upload or fare entry |
| S4 issue / no-show dialogs | board 10, 37 help row; board 8, 35 issue action | Unmatched dialog; retain reasons, confirmations and emergency notice |
| S5 login | board 1, 02-03 | Existing auth flow; no signup or new onboarding |
| S5 home / patient picker / bookings | board 4, 13-14; board 7, 25 | Existing patient-role experience and navigation retained; no new simplified mode, greeting identity or routine editor |
| S5 visit / OTP / timeline / completion | board 4, 15-16; board 5, 17; board 7, 26 | No location/ETA, clinical data or fake events; code shown only under current access/state rules |
| S5 updates inbox | board 4, 16 timeline vocabulary | Unmatched standalone screen; actual notifications retained |
| S5 records / photo upload / image viewer | board 5, 18-20 | Existing list and photo picker; no folders, PDF support, access history or new metadata |
| S5 consent screen | board 1, 04; board 14, 23-24 | Current purpose switches / owner-only behavior; no invite/access editor |
| S5 bills / detail / test payment | board 13, 11; board 14, 24; board 15, 46 | Current monthly invoices and owner-only test payment; no plan selection, UPI/card checkout or booking payment |

Unmatched and intentionally not built: board 2 panels 05-08 patient setup; board 13 panels 09-12 recurring setup and checkout; board 14 panels 21-23 medicines, requests, invites; board 7 panels 27-28 request/help capabilities; board 9 panels 29-30 onboarding; board 11 panel 44 roster; board 15 panels 45,47,48 requests, coverage and ops vault UI. Borrow their visual vocabulary only where mapped above. Never expose vault data to companions.

## Current audit note (2026-10-16)

The [screen inventory](../product/SCREEN_INVENTORY.md) now maps all 60 panel instances
and separates main, open PRs and release receipts. This token contract stays unchanged.
Combined synthetic publication already occurred via PR #8/#9; the older stream
instructions below record their 2026-10-11 delivery plan, not current PR status or
new cherry-pick/deploy authority. [Working agreement](../delivery/WORKING_AGREEMENT.md)
and current work-board reservations govern new contributions.

## Historical verification and delivery (2026-10-11)

Each UI PR cites the panel mappings above, adds per-screen deviations and actual implementation screenshots, and reports exact checks. Run `scripts/check-all.sh` plus the app's analyze/tests or lint/typecheck/tests. Record runtime failures explicitly. Supabase-local journeys require Docker; staging remains PR #2 plus founder dashboard steps and is not included in these main-based UI branches. No deploy or main merge.

## Implementation plan and ownership

1. S2: preserve supplied reference PNGs alongside this contract, review mappings, run the full baseline script, commit documentation and open the token PR. Source PNGs are the founder's supplied design input, not generated implementation output.
2. S3: modify `apps/ops_console/src/app/**` and presentation components in `src/components/**`. Reuse messages and handlers. Add the responsive mint sidebar, teal brand, form/table hierarchy and states. Never edit `src/lib/**` or auth/API providers. Keep existing translated labels and brand wordmark separately so no translation key needs a library edit.
3. S4: modify `apps/companion_app/lib/src/app.dart`, screen widgets and ARB files only. Reuse state-machine actions, API calls and keys. Style sign-in, trip lists, essentials, state panels and dialogs. Never edit RPC/auth/format/action logic.
4. S5: modify `apps/family_app/lib/src/app.dart`, screen widgets and ARB files only. Reuse patient picker, role-based actions, bookings, records, consent, bills and inbox. Never edit RPC/auth/payment/upload adapters or add a separate patient mode.
5. Each stream runs the full fast script and app checks, reviews its own diff for unchanged control flow, and captures local synthetic UI evidence at narrow/wide sizes. Any temporary visual harness stays under ignored `artifacts/`; no demo login or fake backend enters product code. Existing tests are preserved.
6. The root coordinator owns `docs/HANDOFF.md`, `docs/TASKS.md`, AGENTS status, curated screenshot evidence and PR text. Workers return receipts; they do not edit shared documents. Each stream receives documentation before its task commit, then pushes and opens a separate PR. Incorporate S2 by cherry-picking its commit, never staging changes or merging main.
