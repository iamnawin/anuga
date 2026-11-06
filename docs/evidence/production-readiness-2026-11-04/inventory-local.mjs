// Disposable in-memory synthetic inventory, not a hosted cleanup script.
if (process.env.DATABASE_URL) throw new Error('Refusing a real database connection.');
const { asAdmin, asUser, createTrip, ids } = await import('../../../supabase/tests/support/db.ts');
const tables = ['auth.users', ...['profiles', 'patients', 'patient_access', 'consents', 'companions',
  'centres', 'clusters', 'packages', 'schedules', 'trips', 'trip_events', 'trip_otps', 'notifications',
  'notification_deliveries', 'vault_documents', 'vitals', 'medicines', 'invoices', 'invoice_lines',
  'payments', 'audit_log'].map((table) => `public.${table}`)];
const counts = {};
for (const table of tables) {
  const [row] = await asAdmin((db) => db.query(`select count(*)::integer as count from ${table}`));
  counts[table] = row.count;
}
const [storage] = await asAdmin((db) => db.query("select to_regclass('storage.objects')::text as objects"));
const first = await createTrip(25, null);
const second = await createTrip(26, null);
await asUser(ids.ops, (db) => db.query('select public.ops_assign_trip_companion($1,$2)', [first, ids.ravi]));
await asUser(ids.ops, (db) => db.query('select public.ops_assign_trip_companion($1,$2)', [second, ids.ravi]));
console.log(JSON.stringify({ environment: 'disposable PGlite, migrations plus unchanged seed', counts,
  storageObjectsTable: storage.objects, storageLimit: 'No Storage schema in PGlite; no claim about hosted objects.',
  overlappingAssignmentProbe: { pickupsMinutesFromNow: [25, 26], returnMinutesFromNow: [325, 326],
    sameCompanionAssignedToBoth: true, affectsHostedData: false } }, null, 2));
