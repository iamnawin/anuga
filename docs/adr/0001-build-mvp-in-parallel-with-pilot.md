# ADR 0001: Build the MVP in parallel with the manual pilot

- Status: accepted
- Date: 2026-10-08
- Decided by: founder

## Context

`Pilot BRD.md` says to build an app only after the 8-week manual pilot passes its go/no-go
criteria. The original `CLAUDE.md` said the pilot runs in parallel with the build.

## Decision

Start building the MVP now, while the manual pilot runs. Production launch stays a separate,
gated milestone that uses the pilot go/no-go metrics.

## Consequences

- Pilot logs feed the backlog continuously instead of becoming the spec only at week 8.
- Building costs money before demand is proven; keep infra on free/local tiers and add no paid
  service without separate authorization.
- The BRD statement "build an app only if 80%+ renew" now applies to production launch, not to building.
