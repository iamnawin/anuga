# Production operations and recovery

**Status: procedures prepared; operational execution and approvals BLOCKED.**
This runbook supports R17/R20/R21/R28/R29/R30/R31 in the existing
[release matrix](../PRODUCTION_READINESS.md). It does not enable a provider,
approve real patients, set prices, delete data, deploy, restore or merge anything.
Use [environment attestation](environment-attestation.md) before any exercise and
the existing [Android/language plan](../ANDROID_TEST_PLAN.md) for human acceptance.

## People, authority and service opening

The founder must replace each **Unassigned** entry with a person, a protected
contact and a backup before service opens. A role label is not an on-call rota.

| Responsibility | Named primary / backup | Evidence required |
|---|---|---|
| Release decision and pilot scope | Unassigned / Unassigned | Founder approval of exact candidate, environment and release matrix |
| Duty Ops and interrupted-visit safety | Unassigned / Unassigned | Shift coverage, contact acknowledgement and approved continuity/handover workflow |
| DB/Storage/Auth recovery | Unassigned / Unassigned | Access tested, recovery receipt, chosen RPO/RTO and escalation contact |
| Security incident commander | Unassigned / Unassigned | First-response drill and protected incident channel |
| Finance/payment support | Unassigned / Unassigned | Approved collection, reconciliation and dispute/refund process |
| Privacy/counsel and retention | Unassigned / Unassigned | Approved notices, retention/deletion schedule and incident notification decision owner |

At shift start, duty Ops checks the existing schedules/trip board for the service
date, confirms that all intended visits exist and have an eligible primary/backup,
and reviews the exception queue. Compare pickup/return and late unfinished visits
before confirming coverage; a schedule assignment is not proof every daily trip
was generated or staffed. Record the synthetic rehearsal's exact schedule/trip IDs
in a protected shift log. The assigned backup is an option, not an automatic
takeover commitment. Stop accepting new service commitments if coverage, contact
or required approvals are missing; do not represent a pending request as staffed.

Provisioning uses existing restricted account/profile/patient/access/consent and
Companion verification/training flows under a DB operator, with positive and
negative role tests. Do not reuse seed logins or a DB-owner account for service
users. No new onboarding UI or matching service is required by this runbook.

## Companion unavailable, issue or withdrawn consent

1. Duty Ops opens the current trip/exception queue and confirms persisted stage,
   assignee and latest event time. Read the private operational note only within
   authorized Ops access; never copy it into Family notes or notification payloads.
2. If **scheduled**, Ops can use existing `ops_assign_trip_companion` after
   eligibility and occupancy checks. Confirm the replacement and Family's persisted
   status. A conflict is a refusal to assign, not permission to bypass the DB.
3. If **underway or issue-reported**, do not routinely reassign or restart the
   trip. Existing guarded `ops_resolve_visit_issue` requires the observed incident
   version and its recorded prior stage; a stale/missing stage requires reload and
   review. Record the actual decision and its owner in authorized internal notes.
4. Withdrawal of trip consent blocks fresh Companion details and Companion actions
   under the approved hardening contract. Ops must coordinate patient safety using
   separately authorized operational access. Do not restore consent for the family,
   share previously cached details, issue an emergency-access token or invent a
   handover. Confirm with the authorized owner whether/when consent is restored.
5. **The contact, patient-safe continuity steps, authority to resume and completion
   criteria for this situation still require founder/Ops approval and a synthetic
   rehearsal.** Until that receipt exists, R12/R30 remain operationally blocked.
   Database permission to resume is not a safety decision. Do not resume a withdrawn
   service merely because an Ops RPC permits it.
6. Clinical emergencies use 108/ambulance; AnugaCare does not dispatch emergency
   or clinical care. The duty owner follows the separately approved safety process
   and records escalation, rather than improvising a product override.

Pilot occupancy is one visit per Companion across pickup to return, accounting for
late completion. Buffer time and exceptional underway handover remain unresolved.
Neither an empty exception queue nor successful assignment proves operational
availability; validate the next visit when a predecessor runs late.

## Notifications, login OTP and delivery

These are separate systems:

- Login phone OTP is Supabase Auth/provider configuration. Pickup OTP is the
  database's hashed, expiring visit verification. Neither is the notification outbox.
- `notify-dispatch` selects `test` adapters by default. They persist
  `notification_deliveries`; they do not deliver to a device. Live adapter selections
  fail even with the authorization flag because implementation/provider choice is
  unfinished (`notify-dispatch/adapters.ts`).
- The outbox has a 120-second claim lease, five-attempt default and exponential
  retry based on `app_settings`; verify effective settings in the candidate. The
  Edge entry drains up to 20 passes of 50 records per call and requires a verified
  service-role JWT. There is no proven hosted scheduler/alert receipt in this audit.

Before enabling a channel, the messaging owner must supply the approved provider,
recipient-language mapping and consent basis; the backend owner must implement and
sandbox-verify delivery, scheduler authentication, retries, duplicate behavior and
failure alerting. Obtain separate authorization before a real SMS/paid send. Keep
`NOTIFY_PUSH_ADAPTER`, `NOTIFY_WHATSAPP_ADAPTER`, `NOTIFY_SMS_ADAPTER` set to `test`
and `NOTIFY_LIVE_PROVIDERS_AUTHORIZED` unset until approved. Never embed service
credentials in cron URLs, client apps, screenshots or logs.

**Manual pilot alternative, PROPOSAL ONLY:** a named duty operator may check the
persisted trip board/inbox and contact the authorized family using an approved
service channel, record acknowledgement and escalate missed contact. Founder must
approve staffing, channel, response interval and privacy before this can substitute
for automated delivery. This document does not authorize sending a message. Test
receipts and status-only wording do not establish human acknowledgement or an SLA.

For a separately authorized synthetic dispatch rehearsal, use the existing local
Supabase CI journey/tests; do not call a hosted drain endpoint just to inspect it,
because draining changes rows and can send messages. Verify one controlled retry,
an expired lease and a permanent failure; attach counts and alert receipt without
recipient phone, message body or token. Monitoring queries below are read-only.

## Payments and billing

Existing invoices and test billing stay intact. Family currently rejects non-test
checkout (`bills_tab.dart`); backend checks signatures, amount, authorization and
idempotency. These tests do not establish a live payment/UPI subscription service.
No new package price, charge timing, no-show charge, subscription or collection
policy has been approved. Do not issue/collect a real bill using hypothesis prices.

Finance must approve the price effective date and protection against later package
changes repricing history, taxes/receipts as applicable, collection method, refunds,
disputes and support responsibilities. An external/manual collection process is
also a proposal requiring explicit approval; it is not authorized by preserving
the test backend. Keep `PAYMENTS_ADAPTER=test`, live authorization unset and real
keys absent from test environments.

Before any separately authorized launch, reconcile a **sandbox** issued invoice,
payment attempt, provider order/payment and captured amount/currency using the
existing flows. Exercise a duplicate webhook, wrong signature, wrong amount and
unconfirmed callback. A browser success screen is not financial confirmation.
Record only protected reference IDs/counts and exception disposition; never PAN,
UPI credentials, webhook secret or raw provider payload. For a missing capture,
finance investigates provider status under its approved process; do not edit a DB
invoice to paid or repeat a charge speculatively. Real funds remain unauthorized.

## Monitoring, redaction and retention

Platform/Ops must select and prove an alert destination before opening service.
The code contains audit records but no verified Sentry/hosted alert integration.
Alert thresholds, service response times and log retention need named owner
approval; do not silently turn sample thresholds into an operational promise.

Minimum monitored conditions are failed Auth/provider requests, repeated login/
pickup denial or rate-limit events, Edge/API failure rate, notification due backlog/
final failure/expired leases, payment capture mismatch, overdue unfinished visits,
missing coverage, failed backups and excessive database/Storage capacity. Check
the hosted platform dashboards and exercise a synthetic failure for each selected
alert path. A dashboard chart without an acknowledged alert is incomplete evidence.

The following queries are read-only, aggregate-only inspection by the authorized
DB operator. They are not a scheduler and do not claim or retry notifications:

```sql
begin read only;
set local statement_timeout = '10s';
select status, channel, count(*) from public.notifications group by status, channel;
select count(*) as due,
       max(now() - next_attempt_at) as oldest_due_age
from public.notifications
where status = 'pending' and next_attempt_at <= now();
select count(*) as expired_leases from public.notifications
where status = 'pending' and claimed_until < now();
select status, count(*) from public.payments group by status;
select count(*) as late_unfinished from public.trips
where status not in ('scheduled','completed','cancelled','no_show')
  and scheduled_return_at < now();
rollback;
```

Record correlation/reference IDs, event class, function, timestamp and outcome.
Exclude OTPs, bearer/refresh tokens, signed URLs, phone/address, health/vault text,
private notes, provider secrets and request/response bodies. Restrict log access
and export storage. Raw provider exception messages can contain sensitive data;
test redaction with a positive synthetic marker in each relevant error path and
prove it absent in client responses, logs and stored `last_error`. Source review
found raw error paths. The operations hardening replaces unknown vault/payment
exception logs and database failures with fixed event/error classes; dispatcher
failures persist fixed classes and its HTTP catch returns a generic class.
Synthetic-marker regressions cover core response/log/outbox paths. Historical
hosted logs/failed records, deployed parity and actual alert receipt remain
unverified; this runbook does not certify them.

Privacy/counsel must approve retention by table/object/log/backup/provider and the
handling of withdrawal, legal holds and expired signed links. Record who requests,
approves, executes and verifies deletion, including provider copies and restored
backups. No generic purge job or hosted cleanup is authorized. Use the existing
[exact-manifest cleanup proposal](../PRODUCTION_READINESS.md#synthetic-inventory-and-safe-cleanup-proposal);
preserve automated fixtures and financial/audit evidence. The unfinished
retention/deletion policy remains a release blocker.

## Backup and isolated recovery drill

**Not executed.** RPO/RTO, backup schedule/retention, off-site access controls,
Storage-byte coverage and recovery ownership are pending founder/platform approval.
Do not copy real patient information into development or a test recovery project.
Use a specifically approved synthetic-only source and isolated disposable target.
No restore, new paid resource or production replacement is authorized by this text.

1. Record source/target project refs, region, PostgreSQL/platform versions, named
   operator/reviewer, backup point, chosen RPO/RTO and a protected artifact location.
   Confirm targets differ and neither is the live/synthetic source. Inventory
   outbound cron, DB webhooks, extensions, notification/payment provider settings
   and Auth test mappings. The target must have outbound delivery/charging disabled
   **before** restoring any runnable job/trigger. Stop if that cannot be guaranteed.
2. In Supabase **Database > Backups**, inspect actual backup history, failures and
   restore availability for the plan. Record timestamps and coverage, not credentials.
   Establish an approved export/off-site procedure if the plan lacks adequate
   history. Database backups do **not** contain Storage file bytes. [Supabase backup documentation](https://supabase.com/docs/guides/platform/backups).
3. Record a complete backup manifest: DB schema/data/grants/roles and migration
   history; Auth user records and required configuration; Storage bucket/object
   metadata **plus bytes**; custom Auth/Storage policies/triggers; Edge code/config;
   secret *references* and recovery custody, not plaintext keys in the manifest.
   A bare CLI schema dump excludes managed schemas and contains neither data nor
   custom roles by default. Follow the reviewed version-specific logical backup
   procedure if selected. [Supabase CLI backup/restore procedure](https://supabase.com/docs/guides/platform/migrating-within-supabase/backup-restore).
4. For a metadata-only supplemental snapshot, an operator with existing compatible
   PostgreSQL tools and protected libpq service may run the following. It does not
   back up Auth/data/Storage and cannot be used as the sole recovery artifact:

   ```powershell
   pg_dump --version
   pg_dump --dbname=service=anuga_backup --schema-only --schema=public --schema=private `
     --file="$ReceiptDir/app-schema.sql"
   if ($LASTEXITCODE) { throw 'Supplemental schema export failed' }
   Get-FileHash "$ReceiptDir/app-schema.sql" -Algorithm SHA256
   ```

   `ReceiptDir` must already be an approved protected absolute path outside Git;
   source connection details/password live in protected libpq service/password
   files. Schema-only output preserves definitions/ACLs, not patient rows.
   [PostgreSQL pg_dump reference](https://www.postgresql.org/docs/17/app-pgdump.html).
5. Inventory and back up Storage bytes using an approved server-side S3-compatible
   client or individual synthetic downloads in **Storage > Files**. Record each
   protected object manifest entry's bucket/key, bytes and SHA256, preserving
   metadata/ownership separately. Supabase S3 access keys bypass RLS: keep them on
   the controlled operator machine and never in app/build artifacts. Do not enable
   S3 or generate a key without the operator's separate authorization. [Storage downloads](https://supabase.com/docs/guides/storage/management/download-objects),
   [S3 credential scope](https://supabase.com/docs/guides/storage/s3/authentication).
6. After a separately approved synthetic drill plan, the platform operator chooses
   a supported restore-to-new-project or reviewed logical-restore procedure. A
   restored database alone omits Storage bytes and manual platform configuration;
   Auth settings/API keys and Edge functions also need reconfiguration. Inspect
   restored outbound jobs before allowing execution. Never use the source project's
   Restore button for a drill. The platform clone path may carry runnable cron or
   hooks immediately; choose an isolated logical process if that cannot be prevented.
   [Restore-to-new-project coverage](https://supabase.com/docs/guides/platform/clone-project).
7. Reconcile before/after protected counts, migration history, function/grant/RLS
   fingerprints and Storage byte checksums. On the isolated synthetic target,
   validate login and all roles' allowed/denied access, consent denial/restoration,
   private-note isolation, pickup OTP, request/assignment/issue/resume/completion,
   vault authorization/download and sandbox billing. Verify test adapters and no
   outbound production endpoint. Run the existing CI journey against that isolated
   target only under explicit drill authorization; it mutates synthetic fixtures.
8. Measure elapsed restore and validation time and the recovered data point. Compare
   to approved RPO/RTO, capture discrepancy/owner/action and reviewer signature.
   An archive hash or successful restore command is insufficient. Leave the target
   quarantined; its eventual deletion requires separate approval. Do not restore
   a backup in production or change endpoints without an approved release action.

## Compatible rollback and incident response

Before any separately approved rollout, release/DB owners record the current and
candidate application, Edge and database versions, migration order, compatible
previous app artifact and backup receipt. Additive migrations generally stay in
place during an app rollback. Check RPC signatures/status payloads against the
prior app; rehearse the selected combination on the isolated synthetic candidate.
**Do not roll back consent/RLS/private-note enforcement or restore a vulnerable
database definition to regain availability.** If the old app cannot safely use the
new DB contract, stop the affected capability and apply a reviewed forward fix.
No automatic schema down migration, database reset or destructive restore is part
of rollback. Actual Vercel alias/artifact or Edge rollback requires release owner
authorization and candidate-specific commands; do not click Promote/Redeploy here.

For a suspected breach, credentials leak, incorrect billing or service-safety event:

1. Duty Ops alerts the named incident commander through the protected contact.
   Record UTC/IST start, environment, affected capability and correlation IDs.
   Do not paste patient data or secrets into public issues/chat. Safety owner
   coordinates any underway patient support under the approved process.
2. Commander classifies impact and obtains authorized platform containment: stop
   new commitments/affected provider processing where needed, protect evidence,
   and restrict compromised access. Do not delete logs or mass-sign-out users
   without considering underway visits and authorization. A refresh-token revoke
   does not immediately invalidate an already issued access JWT.
3. Security/platform owner identifies actual affected credentials and data paths,
   records access/export scope, and rotates/restricts only under approved incident
   authority. Preserve immutable sanitized evidence, audit trail and chain of
   custody. Never publish the credential to demonstrate the leak.
4. Privacy/counsel owns legal assessment and required regulator/user/provider
   notifications and timing. The product spec's dates/deadlines are not an
   independently verified legal opinion. No automated external message is authorized.
5. Recover using the verified compatible artifact or isolated-tested forward fix;
   reconcile billing/outbox state to avoid duplicate delivery/charges. Re-run the
   relevant role, consent and journey checks. Founder/release owner explicitly
   approves return to service after safety, security and recovery owners sign off.
6. Record cause, scope, timeline, decisions, validation and assigned follow-ups.
   Rehearse a synthetic incident before launch, including contact acknowledgement
   and failed first escalation. A written runbook alone does not close R28/R29.

## Evidence receipt and remaining approvals

```text
Exercise / environment / source SHA / project ref / operator / reviewer:
Authorization and explicit allowed actions:
Primary and backup contacts acknowledged at:
Synthetic fixture IDs / no real data confirmed:
Notification/payment modes and outbound isolation verified by:
Backup point / DB+Auth+Storage+config manifest / protected artifact hashes:
Chosen RPO / RTO / measured recovery point / elapsed recovery+validation:
Role-denial / consent / privacy / journey / billing test results:
Alert class / destination / delivery and human acknowledgement evidence:
Rollback app+DB compatibility and safety-continuity rehearsal results:
Failures, missing access, approvals and precise next owner action:
Operational approval and separate founder release decision:
```

Still required: named shift/security/platform/finance/privacy owners; approved
active-visit consent safety and handover process; provider/manual-message process;
pricing/collection/no-show/subscription decisions; start-window and travel-buffer
validation; retention/deletion policy; monitoring destination/thresholds; real
backup coverage and RPO/RTO; isolated restore/rollback/incident evidence; legal,
pilot and final release approval. No item becomes PASS because this runbook exists.
