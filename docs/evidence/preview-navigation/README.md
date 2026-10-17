# Preview switching and refresh repair

17 October 2026, sole coordinator on `feat/anu003-family-first-use`, task base
`22a9969`. Founder reported preview usability faults and confirmed the problem
was switching apps or refreshing. Existing publication authority covers updating
the same isolated synthetic demo and the owned normal commit/push.

Updated https://anuga-interactive-preview.vercel.app; [deployment/source hashes](deployment.json).
Only the deployed shell index changed. All 136 other assets were checked against
the previous deployment manifest and remain identical. No app/backend/Auth/SQL,
dependency, shared welcome source or live Anuga site change.

## Faults and correction

- Welcome sign-in links navigated the iframe but left Welcome selected. Shell
  navigation did not update its URL, so refresh returned to Welcome.
- Iframe and shell history competed during Back navigation. The shell now owns
  app-switch history and replaces the frame location rather than creating extra
  iframe history entries. Welcome links, top controls, active aria-current state,
  bookmarks, reload and Back agree on the selected app.
- Fixed-height header and shrinking buttons clipped phone controls and wrapped
  words inside buttons. Controls now wrap as whole buttons, meet 48px targets,
  and the frame fills available height below the natural header height.

The screenshot's rightward offset was not reproduced. Actual welcome content was
centred before and after at 360/1356/1920px; no invented root cause or welcome CSS
rewrite. Hosted [phone](screenshots/welcome-360.png),
[desktop](screenshots/welcome-1356.png), [wide](screenshots/welcome-1920.png) captures
were checked. Existing welcome styling, copy and en/te/hi selector are reused.

## Fresh verification

| Check | Result |
| --- | --- |
| Entry regressions before repair | 3 passed, 6 failed for mobile/control size, active app/URL, reload and Back; [red results](entry-red.json) |
| `node preview/verify-entry.mjs`, local compiled preview | 9/9; [results](entry-local.json) |
| Same entry suite against the public demo | 9/9; [results](entry-hosted.json) |
| `node preview/verify-browser.mjs`, local | 10/10; [results](journey-local.json) |
| Same journey suite against the public demo | 10/10, zero page errors/hosted Supabase requests; [results](journey-hosted.json) |
| `node --test preview/demo-core.test.mjs` | 6/6, zero failures/skips |
| `bash scripts/check-all.sh` | Exit 0: PGlite 157/9 real-only skips; Ops 60; shared Dart 28; Companion 51/3 skips; Family 58/6 skips; lint/typecheck/build/format/analyze pass; [log](check-all.txt) |

The 10-check journey includes all previous sign-in/pickup/cross-role update/reload
checks plus the founder's same-tab switch: Family to Companion restores the
Companion session; switching back restores the Family session and picked-up visit.
The 9 entry assertions cover centring/overflow/control visibility at three widths,
the actual Welcome sign-in link, reload and browser Back. An initial test-server
root-path guard and navigation-load wait were corrected before the recorded red
run; Back's frame assertion was made against the actual visible frame URL rather
than its stale src attribute. The first green attempt exposed the competing
iframe-history fault, which was fixed before the final passing run.

Published only the edited shell with the unchanged previously built app assets.
`node scripts/build-interactive-preview.mjs` reproduces the same output from
source; no repeated app compilation is needed for copying HTML. Hosted journey
uses the already-documented HTTP/1 browser setting, with no asset/response mocking.
All fixtures remain synthetic and browser-local. No native/human-language,
accessibility, real backend or rollout acceptance is implied. ANU-003 B1-B4 and
ANU-002-VERIFY remain open. No PR/merge. Current continuation is in HANDOFF.

Retry: reopen the same demo URL, sign in to Family, switch to Companion and back,
then refresh. The app choice stays in the address bar and its navigation stays
selected. Patient records/consents/session state are not reset by this repair.
