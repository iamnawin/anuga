# Test the combined Anuga apps locally

Branch: `integration/local-anuga`. Synthetic data only. No deployment or main merge.
The real apps call the same existing synthetic Supabase project. No mocked login or RPCs.

## Start on Windows

From `D:\AI-Workspace\Repos\anuga-integration`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-local.ps1
```

The launcher uses the public anon settings already committed in PR #2, builds the
Next.js static export and both Flutter web apps, and serves only on loopback:

| App | URL | Synthetic phone (enter without +91) |
| --- | --- | --- |
| Ops | http://127.0.0.1:3100/login/ | `9000000001` |
| Family owner, Kiran | http://127.0.0.1:3101/ | `9000000101` |
| Companion backup, Ravi | http://127.0.0.1:3102/ | `9000000202` |
| Companion primary, Asha | same companion URL, sign out first | `9000000201` |
| Family viewer, Meena | same family URL, sign out first | `9000000102` |

Keep the terminal open. Ctrl+C stops the servers. After a successful build, restart
quickly with `-SkipBuild`. Rebuild after source or backend settings changes.
Use the exact `127.0.0.1` URLs consistently. Separate ports keep three different
role sessions independent. Sign-in persists in browser storage until sign-out.

## Hosted phone setup and dashboard steps

Phone sign-in and the synthetic test numbers are now enabled and verified on
2026-10-11. The real hosted allowed/denied smoke and all three browser sign-ins
pass. The setup below is retained for reference. The current synthetic sign-in
code is `123456`, as configured by the founder; the visit pickup code is separate.
Combined hosted URLs are `/ops/login/`, `/family/`, `/companion/` on
`https://anuga.vercel.app`; exact publication status is in the latest HANDOFF.

In Supabase project **anuga**, ref **vsvkllfgrnlbhdydysny**:

1. Authentication > Sign In / Providers > Phone: enable phone sign-in. Disable
   new-user signups for this seeded test project, as the app uses existing users only.
2. Select the **Twilio** SMS-provider configuration described in PR #2's staging
   setup, with synthetic placeholder values for mandatory fields. Add
   these test phone numbers: `919000000001`, `919000000101`, `919000000102`,
   `919000000201`, `919000000202`. Set one six-digit **synthetic sign-in code**
   in the dashboard's **Test phone numbers and OTPs** settings. Test-number requests must use the configured code and must
   not send paid SMS. Do not test any number outside this list.
3. Enter that dashboard-configured code in each app. Hosted sign-in does not
   automatically use the local Docker code `123456`. Do not paste the code,
   credentials, service keys or dashboard secrets into chat.

The existing staging handoff records migrations and seed already loaded. Do not
reload the seed or reset the hosted database. No Vercel token, GitHub deployment
secret, hosted frontend deployment or main merge is needed for local testing.
For optional test payments, Edge Functions > Secrets needs
`PAYMENTS_WEBHOOK_SECRET` stored in the dashboard only. It is not needed for the visit.

## Prepare one visit in the active time window

The seed visits were generated on an earlier date. Companion patient details are
deliberately hidden outside the database's time window. Do not weaken that rule.
In this synthetic project's SQL Editor, run the following once before a manual
test. It creates a fresh visit using only the known synthetic seed patient,
centre and primary companion. Copy the returned visit id for matching rows.
This is test data preparation, not a migration or access-rule change.

```sql
insert into public.trips
  (schedule_id, patient_id, centre_id, companion_id,
   scheduled_pickup_at, scheduled_return_at)
values
  ('80000000-0000-0000-0000-000000000001',
   '70000000-0000-0000-0000-000000000001',
   '50000000-0000-0000-0000-000000000001',
   '30000000-0000-0000-0000-000000000001',
   date_trunc('minute', now()) + interval '40 minutes',
   date_trunc('minute', now()) + interval '340 minutes')
returning id, scheduled_pickup_at, scheduled_return_at;
```

If you test near midnight IST, select the pickup date in ops and companion; family lists the next two weeks. This
adds a new synthetic visit; it never removes or resets earlier test results.

## Complete the visit in three tabs

1. **Ops:** sign in as `9000000001`. Open Trips, choose the pickup date and
   refresh. Find Lakshmi Rao (synthetic) at the returned pickup time. Use the
   assignment control to select **Ravi Companion (synthetic)**, the eligible
   backup, then save. Refresh and confirm it persists.
2. **Family:** sign in as `9000000101`. Select Lakshmi, open Visits and the
   matching booking. Confirm Ravi is shown. Tap **Get pickup code**. This code
   is freshly generated for this visit and differs from the sign-in code.
3. **Companion:** sign in as `9000000202`. Refresh today's visits and open the
   matching visit. Tap **I'm on my way**. Tap **Verify code and pick up**, enter
   the family-generated pickup code, and confirm. Do not repeatedly try wrong
   codes, because the existing database attempt limit locks pickup.
4. **Companion:** tap **Reached the centre**, then **Handed over at the centre**.
   An optional note can say `Synthetic centre handover test`.
5. **Family:** return to the booking list, reload the browser tab and reopen the visit. Its
   timeline should show pickup, centre arrival and handover. The app uses
   explicit refresh; do not expect live polling.
6. **Companion:** tap **Session finished**, **Starting the return journey**,
   **Dropped home safely**, then **Complete visit**. Supply the required note,
   for example `Synthetic visit completed; returned home safely`.
7. **Family:** reload the browser tab and reopen the visit. Confirm **Completed** and the note
   in its timeline. **Ops:** refresh Trips and confirm the completed status.

For permission verification, sign out of family and sign in as viewer
`9000000102`. The viewer can read the visit but cannot issue pickup codes or
cancel visits. Companions never have vault access. Existing allowed and denied
tests remain unchanged.

Family timeline and completion note read directly from the existing RPCs. The
Updates inbox reads queued notifications; delivery status depends on the existing
test notification dispatcher. No paid push/SMS/WhatsApp service is needed. Do not
put a service-role key into an app to run the dispatcher.

## Fully local backend alternative

Docker is unavailable on this machine. On a machine with Docker, follow
`docs/SETUP.md` to start a fresh Supabase local stack, then obtain only its API URL
and anon/publishable key from `supabase status -o env`. Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-local.ps1 -SupabaseUrl http://127.0.0.1:54321 -PublicKey '<local public anon or publishable key>'
```

Local Docker seed accounts use sign-in code `123456`. The connected automated
journey is `scripts/e2e-journey.sh`; it resets **Supabase local** first, creates a
visit, tests real auth/RLS, runs the ops browser and both Flutter API layers,
dispatches test notifications and completes billing. Never point that reset
script at the hosted project. The CI `supabase-local` job runs this journey on a
fresh Docker stack without founder dashboard credentials.
