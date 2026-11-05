# Operations hardening receipt

Prepared read-only environment/schema attestation, production operations,
backup/restore, compatible rollback and incident procedures. The catalogue SQL
runs in a read-only repeatable transaction; disposable verification executed it
and confirmed application row counts were unchanged.

Runtime hardening removes an unsupported acknowledgement from EN/TE/HI issue
notifications and replaces raw provider/database exception text in notification
failure records, dispatcher responses, vault logs/responses and payment logs/
responses with fixed error classes. Positive-marker regressions failed before and
pass after: 35/35 focused tests.

Official Supabase documentation confirms database backups exclude Storage bytes,
restore-to-new-project needs manual Storage/Edge/Auth reconfiguration, and S3
server keys bypass RLS. The runbook therefore treats DB, Auth, Storage bytes,
configuration and Edge code as separate recovery evidence.

Not performed: hosted inventory/attestation, provider activation, alert receipt,
backup restore, Storage recovery, rollback, incident drill, deletion, real SMS or
payment. Named owners, RPO/RTO, retention, provider/payment policy and final
release approval remain open.
