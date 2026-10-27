# AnugaCare logo

Founder-supplied artwork (2026-10-27), transparent PNG. No vector source in the repo yet.

| File | Use |
|---|---|
| `anugacare-symbol.png` | Arch symbol with orange dot: app icons, favicons, sign-in screens |
| `anugacare-lockup.png` | Symbol, wordmark and tagline "Someone beside you, every visit.": light backgrounds only (the tagline is dark grey) |

Colours in the artwork: teal about `#007375` (UI primary stays `#00666B`, see `docs/design/tokens.md`),
orange about `#E8A32D`.

Generated from these (rerun after a logo change):

```sh
uv run --with pillow python -I scripts/make-brand-icons.py <symbol.png> <lockup.png> .
```

It writes the Flutter web icons and favicons, Android launcher icons (legacy mipmaps), the
sign-in asset `assets/brand/anugacare-symbol.png` in each Flutter app, and the ops console
`icon.png` and sign-in symbol. The site root page uses `anugacare-lockup.png` (scripts/build-staging.sh).

Open: a vector (SVG) master and Android adaptive icons.
