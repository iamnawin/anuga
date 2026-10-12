# Anuga Ops

Register: product. Ops staff assign companions and monitor scheduled dialysis visits using synthetic data during founder testing.

Requirements and access rules: [PRODUCT_SPEC](../../docs/PRODUCT_SPEC.md). Current state: [HANDOFF](../../docs/HANDOFF.md).

Keep the founder's mint, teal and navy design, system typography, 48px minimum controls, readable mobile forms and English/Telugu/Hindi labels. Visual source: [tokens and sketch mappings](../../docs/design/tokens.md), implemented in `src/app/globals.css`.

Scheduling choices describe the family's agreed weekly routine, not a clinical recommendation. Only Ops may replace future unstarted visits. Keep active visits, past visits, individual cancellations, notes and audited history intact. Database permissions remain the security boundary.
