# AnugaCare product design system

## Source of truth

`docs/design/tokens.md` is the detailed cross-role visual contract. The unified
app reuses the Family and Companion Flutter packages, so their themes and screen
components remain authoritative rather than creating a third component system.

## Theme

Light and dark Material 3 themes use calm, flat surfaces. Light screens use a
near-white mint canvas with white/mint content surfaces. Dark screens use deep
navy-green surfaces. No decorative glass, fake map or heavy elevation.

## Color

- Primary teal: `#00666B`; dark-mode primary: `#8DDDD1`
- Canvas: `#F7FBFA`; surface: `#FFFFFF`; soft surface: `#EAF7F4`
- Ink: `#10243A`; supporting ink: `#465D6B`
- Semantic success, warning, error and information colors always include text

## Typography

Use the platform sans family with Telugu/Devanagari fallback. Page headings are
28/700, sections 22/700, facts 18-20 and supporting text at least 14. The app
enforces a minimum 1.15 text scale and never caps larger user scaling.

## Shape and spacing

Cards and buttons use a 12-pixel radius, inputs 8 pixels and status chips a full
pill. Spacing follows 4, 8, 12, 16, 24, 32 and 48. Cards use complete boundaries
with little or no shadow. Mobile gutters are 16-24 pixels.

## Components and states

Every enabled button maps to an existing backend action. Screens preserve
loading, empty, error, denied, disabled, busy, retry and success states. Primary
actions use filled teal; secondary actions use outlined teal; destructive actions
use explicit red copy. Progress visuals supplement, never replace, exact status
text and persisted event history.

## Motion and responsiveness

Motion is limited to Material state feedback and meaningful state changes, with
reduced-motion behavior inherited from Flutter. Content scrolls safely at 360
logical pixels and 200% text. Navigation labels may scroll horizontally rather
than clip. Desktop Ops uses its separate responsive web shell.
