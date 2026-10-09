# ADR 0004: Hosted staging with synthetic data

- Status: accepted (founder approved a staging deploy on 2026-10-09)
- Date: 2026-10-09

## Context

Testing the apps needed Docker, Flutter and an Android emulator on the founder's machine.
The founder asked for hosted links that open on any browser or phone. CLAUDE.md requires
separate founder authorization for public deploys; this ADR records that authorization and
its limits. It does not authorize production (M10).

## Decision

1. **Backend:** a free-tier Supabase project `anuga` (ref `vsvkllfgrnlbhdydysny`, Mumbai
   `ap-south-1`) with the same migrations and `supabase/seed/seed.sql`. Synthetic data only.
2. **Logins:** Supabase test phone numbers for the seed accounts with one fixed code chosen by
   the founder (not `123456`), stored only in the Supabase dashboard and the GitHub secret
   `STAGING_TEST_OTP`. The SMS provider has placeholder values; no SMS is sent or paid for.
3. **Functions:** `vault-files` and `payments` (test adapter; `PAYMENTS_WEBHOOK_SECRET` set in
   the dashboard). `payments-webhook` and `notify-dispatch` are not deployed: test mode does not
   use the webhook, and no live notification provider exists.
4. **Web apps:** one static site on the Vercel project `anuga`: ops console at `/ops/`, family
   app at `/family/`, companion app at `/companion/` (Flutter web builds). Vercel Authentication
   stays on, so only members of the founder's Vercel team can open it. `noindex` everywhere.
5. **Deploys:** manual GitHub workflow `deploy staging` (`scripts/build-staging.sh`, then
   `vercel deploy --prebuilt`), followed by `scripts/staging-smoke.ts` against the backend.
6. The browser-called functions answer CORS (`_shared/cors.ts`); authorization is still the
   bearer token and the database.

## Consequences

- Anyone who knows a seed phone number and the staging code can sign in to the backend
  directly. Acceptable only because every record is invented; never load real data here.
- Schema changes must also be applied to staging. The Supabase connector cannot run
  statements that drop or delete (it waits for a confirmation it cannot show), so those run
  in the dashboard SQL editor.
- Free-tier projects pause after a week without traffic; restore from the dashboard.
- Production (M10) still needs its own decision: real SMS, a paid tier, backups, domains and
  removal of test numbers.
