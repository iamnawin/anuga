# ADR 0005: Salesforce as a one-way ops copy of the app data

- Status: accepted (founder chose this option on 2026-10-20). Building it with synthetic data
  is allowed; sending real data waits for M10.
- Date: 2026-10-20

## Context

The founder wants to run the first ~10 real customers with a back office in Salesforce, where
the team already has developer and architect experience. The spec (section 5a) had turned
down Salesforce Health Cloud because of licence cost before revenue.

There were three options:

1. Salesforce as a one-way copy for ops.
2. Salesforce as the main database behind the apps.
3. Salesforce on its own, with no link to the apps.

Option 2 would mean rebuilding the M2–M9 RPCs, access rules and tests in Apex and sharing
rules. It would also move access checks out of the database, which breaks a non-negotiable
in `AGENTS.md` and ADR 0002. Option 3 throws away the apps that are already built.

## Decision

1. **Supabase stays the system of record.** The family, companion and ops apps keep using
   the RPCs, RLS and tests they use today. Nothing in the apps changes.
2. **Salesforce gets a one-way copy** for ops work, CRM follow-up and pilot reporting
   (renewals, on-time rate, missed visits). Changes made in Salesforce never flow back. Trip
   actions (assign, advance, OTP) stay in the ops console. Write-back would need its own ADR,
   and it would go through the existing ops RPCs as an integration user.
3. **Only minimum fields are sent.** Every synced field is listed in an allow-list in the
   migration:

   | Supabase | Salesforce object (proposed) | Fields sent |
   | --- | --- | --- |
   | `patients` | Account (Person Account) or `Patient__c` | id, full name, centre (and its cluster), package, schedule days and pickup time (from `schedules`) |
   | `profiles` + `patient_access` | Contact + relationship | name, phone, language, access level (owner/editor/viewer) |
   | `companions` | `Companion__c` | id, name, cluster, active |
   | `centres`, `clusters` | `Centre__c`, `Cluster__c` | id, name, status |
   | `trips` | `Trip__c` | id, patient, centre, companion, scheduled pickup/return, status, `picked_up_at`, `completed_at`, fare (paise) |
   | `invoices` | `Invoice__c` | id, patient, period, status, total (paise), paid at |

   **Never sent:**
   - date of birth, diagnoses, mobility notes, emergency contacts
   - home address, home location, post-visit notes (free text that may mention health)
   - vault documents, vitals, medicines
   - trip OTPs, `audit_log`

   Every Salesforce record carries the Supabase id in an External ID field (`Anuga_Id__c`), so
   upserts are idempotent and the copy can be rebuilt or moved to another system later.
4. **How it syncs:**
   - Triggers on the synced tables write the allow-listed fields to a `crm_outbox` table. It has
     no grants for app roles, the same pattern as the `notifications` outbox.
   - A new edge function, `crm-sync`, drains the outbox with the service role. It uses claim and
     mark RPCs and upserts through the Salesforce REST API on the External ID, with retries.
   - The adapter defaults to `test`, which records calls and sends nothing. The `salesforce`
     adapter authenticates as one integration user through OAuth 2.0 client credentials.
     Credentials live only in Supabase secrets.
5. **Access inside Salesforce:**
   - Ops users only, with a Private org-wide default.
   - No Experience Cloud and no family or companion logins.
   - Families and companions keep using the apps.
6. **Deletion:** when the consent-withdrawal deletion job (backlog) deletes a patient, it also
   queues a Salesforce delete. The sync audits each delete.

## Allowed now / gated

- **Allowed now:** the migration, the edge function with the `test` adapter, tests, and a free
  Salesforce Developer Edition org or sandbox loaded with the synthetic seed only.
- **Gated with M10:**
  - a paid Salesforce org on Hyperforce India
  - real patient data
  - a data processing agreement with Salesforce
  - naming Salesforce as a processor in the privacy notice
  - health-tech lawyer review

  Developer Edition terms don't allow real customer data.

## Consequences

- Each access rule gets tests in `supabase/tests/`:
  - Allowed: the service role can claim outbox rows, and a trip update enqueues only
    allow-listed fields.
  - Denied: app roles can't read or write `crm_outbox`, and changes to date of birth, vault or
    medicines enqueue nothing.
- Salesforce adds a second place where personal data lives. The breach runbook and the DPDP
  notice must cover it.
- Licence cost: a few ops seats plus the integration user. Get a current quote before M10.
- Moving off Salesforce later is cheap. The source of truth never left Postgres, and every
  record maps back by id.
- Open questions:
  - Person Accounts or a custom `Patient__c` object
  - which Salesforce edition to buy
  - whether WhatsApp messages get logged in Salesforce, which would need a paid connector
