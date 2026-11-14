# Welcome hero: caring duo and theme blend

Task `WELCOME-HERO-20261113`, started 2026-11-13 and completed for review on
2026-11-14. Scope is the signed-out `/app/` illustration and immediate layout.
No merge or hosted deployment was performed.

## Result and files

- `apps/anugacare_app/lib/src/screens/welcome_screen.dart`: replace the rounded
  rectangle/cropped image with the asymmetric transparent hero, reserved4:3
  aspect and `BoxFit.contain`. Side/lower alpha masks reveal the active
  `scaffoldBackgroundColor`; foreground faces, clothing, hands and cane handle
  receive no colour filter. The lower fade starts below the hands and finishes
  before the separate headline, with an8px layout gap.
- `apps/anugacare_app/assets/welcome/walking-clinic-hero.png`: separate edited
  RGBA1448×1086 artwork. Clinic/trees are softer and muted. The original
  `walking-clinic.png` remains unchanged. Checksums/provenance: [asset.json](asset.json).
- `apps/anugacare_app/pubspec.yaml`: register the new asset, with no dependency change.
- `apps/anugacare_app/test/welcome_hero_test.dart`: rendered edge/background and
  headline separation regression in both themes; fails on the old rectangle.
- App product context and mandatory task/UX records document this scoped work.

The logo, headline/body/footer copy, all three localization files, language
selection, Get started and Companion sign-in callbacks/routes are unchanged.
The supplied [reference](reference.png) directs only the hero, not baked UI text.

## Screenshots

Each link opens a real release-web capture. Controls captures show the existing
scrollable content and both actions after scrolling. They are not image mocks.

| Width | Theme | English | Telugu | Hindi |
| --- | --- | --- | --- | --- |
| 360 | Light | [Top](360-light-en-top.png) / [Controls](360-light-en-controls.png) | [Top](360-light-te-top.png) / [Controls](360-light-te-controls.png) | [Top](360-light-hi-top.png) / [Controls](360-light-hi-controls.png) |
| 360 | Dark | [Top](360-dark-en-top.png) / [Controls](360-dark-en-controls.png) | [Top](360-dark-te-top.png) / [Controls](360-dark-te-controls.png) | [Top](360-dark-hi-top.png) / [Controls](360-dark-hi-controls.png) |
| 390 | Light | [Top](390-light-en-top.png) / [Controls](390-light-en-controls.png) | [Top](390-light-te-top.png) / [Controls](390-light-te-controls.png) | [Top](390-light-hi-top.png) / [Controls](390-light-hi-controls.png) |
| 390 | Dark | [Top](390-dark-en-top.png) / [Controls](390-dark-en-controls.png) | [Top](390-dark-te-top.png) / [Controls](390-dark-te-controls.png) | [Top](390-dark-hi-top.png) / [Controls](390-dark-hi-controls.png) |

## Executed verification

- Focused Welcome/render tests: **40 passed**. Render edge tests first failed2/2
  with the old rectangle and pass with the new treatment. Pixels at the arch
  exterior and lower tail equal the actual theme background; headline is below
  the image bounds.
- Full unified app: **93 passed**; analyzer clean; release web build passed.
- Browser: **12 configurations,24 screenshots**, actual desktop Chrome at
  360/390×844 in light/dark and EN/TE/HI. Both actions reach the existing phone
  form, explicit language survives reload, zero page errors and **zero hosted
  backend requests**. [Machine receipt](visual-results.json).
- Existing widget matrix also checks360/390 and all three languages/themes at
  normal and200% text, preserving accessible/reachable controls and routing.
- Visual inspection: no rectangular frame/seam, no clipped faces or cane handle,
  natural foreground colours, complete fade before readable headline. Independent
  read-only review found no blocker. Telugu/Hindi layout was checked; this does
  not replace native-speaker wording approval, and the wording was not edited.
- Required sequential `scripts/check-all.sh`: **ALL CHECKS PASSED**. Database209
  pass/11 environment skips, Ops70/build, shared29, Companion58/3skips,
  Family109/6skips, unified93. Format/analyze/lint/typecheck checks passed.
  Feature PR CI is separate and must not be inferred from these local results.

Local review URL: `http://127.0.0.1:3132/app/` while the local server is running.
No physical-device check, main merge, Vercel publication, provider activation or
backend/auth/consent change is claimed. Android and existing production gates remain.
