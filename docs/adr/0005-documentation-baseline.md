# ADR 0005: Reconcile documentation against the existing Anuga baseline

- Status: documentation reconciliation of existing decisions, 2026-10-16.
- Scope: record already-approved brand and implemented model/storage state;
  no new business, access, architecture, provider or launch decision.

## Evidence and correction

The 2026-10-11 design contract records founder approval of ANUGA as the wordmark,
Anuga in prose, and unchanged package identifiers. Main's combined UI/site uses it.
PRODUCT_SPEC and CLAUDE still called the brand undecided. Reconcile those headers
to the existing approval, not a new naming proposal. Final store identifiers and
whether to consolidate mobile apps remain separate pending decisions.

PRODUCT_SPEC's first-milestone model and private-storage “later” wording lag M8/M9.
Main migrations 0800/0900 and historical milestone/release receipts establish
private signed-file access and test-mode invoices/payments. Update those current
claims, while preserving original milestone history. PDF/requests/onboarding/live
location UI and production payments are not thereby complete.

## Consequences

Inventories report source, design, verification and release independently.
M0–M10 history remains intact; PR #10/#11 remain open and are not counted as main
or deployed features. The current handoff links an intact historical main handoff
archive. One contribution agreement governs agent entries; old stream/publication
receipts are historical, not new authority.

No database permission changes: linked Family viewers retain audited vault reads;
the conceptual independent viewer-vault switch remains unsupported. Any future
policy change needs its own decision and allowed/denied database tests.

Evidence: [design contract](../design/tokens.md), [audit baseline](../product/AUDIT_BASELINE.md),
[milestones](../TASKS.md), [historical handoff](../HANDOFF_HISTORY_2026-10-16.md).
