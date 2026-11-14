# Unified AnugaCare product context

## Register
Product UI. The specification remains `docs/PRODUCT_SPEC.md`; this is a design summary.

## Users and purpose
Families arrange recurring scheduled visits. Companions use assigned trip essentials,
pickup-code verification and recorded check-ins to accompany a patient safely.
Database permissions remain authoritative. This is a non-clinical service.

## Design direction
Use the existing teal, mint, navy and light/dark themes from `docs/design/tokens.md`.
The founder-approved Companion final spec on research PR #31 controls C1–C20;
October and November images supply visual direction only. Illustrated faces,
simple route cards and clear action hierarchy convey a calm, familiar service.

## Accessibility and boundaries
EN/TE/HI, 200% text, scrolling layouts, 48px targets and 56px primary buttons.
Never use colour as the only status indicator. No patient photos, clinical data,
raw contact numbers, Records tab, fake map/ETA, badges or notification counts.
Missing contracts are documented rather than replaced with demonstration data.

# AnugaCare app context

## Register

Product: a Flutter app for families, patients and non-clinical visit companions.
The existing `/app/` uses database role routing after phone sign-in.

## Audience and visual direction

Families and older patients need a calm, legible and trustworthy interface.
Use the existing Material theme, AnugaCare branding and EN/TE/HI controls.
Light and dark follow the existing app themes; do not introduce a new palette.

## Welcome hero task

The founder's 2026-11-13 caring-duo mockup directs only the illustration and its
immediate layout: wide asymmetric arch, naturally colored foreground figures,
soft clinic/trees, transparent side/lower edges, and a fade completed before the
existing headline. Preserve faces, both hands and the cane handle.

Keep the original illustration. Any edited hero is a separate asset. Logo,
copy, language selection, buttons and existing sign-in behavior remain real UI.
No auth, backend, token, consent or navigation changes are in scope.
