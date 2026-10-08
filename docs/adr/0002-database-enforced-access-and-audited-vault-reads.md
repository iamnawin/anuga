# ADR 0002: Database-enforced access, restricted projections and audited vault reads

- Status: accepted
- Date: 2026-10-08

## Context

Patient permissions must hold even if an app has a bug. Companions need a few patient fields
for a trip and nothing else. Every vault read must be audited, but Postgres never fires
triggers on SELECT.

## Decision

1. Revoke Supabase's default table grants; grant per table and per column, and enable RLS on
   every table.
2. Companions get no access to `patients`. They read `companion_my_trips()`, a security-definer
   function returning only trip-essential fields, and only inside a time window set in `app_settings`.
3. Vault tables have no SELECT grant for app roles. The only read path is `vault_list_*()`
   functions that authorize, insert an `audit_log` row, and return rows in one transaction.
   Ops access requires an active `ops_vault_access` consent from the patient's owner.
4. Trip writes happen only through `advance_trip()` and `verify_pickup_otp()`, validated
   against the `trip_transitions` table.
5. Pickup OTPs are stored as salted SHA-256 hashes in `trip_otps`, which no app role can read.
   Wrong codes return a result instead of raising, so the attempt counter is committed.

## Consequences

- Clients must call RPCs for vault reads and trip changes; plain table SELECT on the vault fails.
- Vault inserts must use `Prefer: return=minimal` (no SELECT grant to return the row).
- Denied vault reads raise an error and are not in `audit_log` (the transaction rolls back);
  they remain visible in database/API logs.
- New public tables get no access until a migration grants it.
