# ADR 0006: Brand AnugaCare, mobile-first product

- Status: accepted (founder decision in chat, 2026-10-22)
- Date: 2026-10-22

## Context

The spec left the brand open ("Anuga" was dropped because it clashes with the Anuga food trade
fair). A later session approved "ANUGA" for the synthetic test site but kept identifiers
unchanged. The founder has now chosen **AnugaCare** and holds `anugacare.com` and `anugacare.in`.
The founder also stated that the customer product is a mobile app.

## Decision

1. **Brand:** AnugaCare. Telugu `అనుగాకేర్`, Hindi `अनुगाकेयर` (to be checked by a native reviewer).
2. **Product surfaces:** families and companions use native mobile apps (Android first). The ops
   console stays an internal web tool. The domains host a marketing/landing page only; no customer
   web app is planned. The hosted Flutter web builds stay as synthetic test links.
3. **Scope of this change:** user-facing names only (app titles, Android labels, web titles,
   ops wordmark, test-site chooser). Not changed: Android application ids
   (`com.zeroorigins.family_app`, `com.zeroorigins.companion_app`), package and folder names,
   the codename `companion` in code, the Supabase project, `anuga.vercel.app` and env var names.
4. **Final application id** is decided together with app consolidation (X1, see
   `docs/research/anugacare-mobile-analysis.md`). Nothing is published to a store yet, so the id
   can change once, before the first store upload, at no user cost.

## Consequences

- Trademark search for "AnugaCare" (class 44 health services, class 9 software) is still open and
  is a launch blocker under M10. The food-fair clash that dropped "Anuga" should be reviewed.
- Store listings, privacy policy URL and support email will use the `anugacare.in`/`.com` domains.
