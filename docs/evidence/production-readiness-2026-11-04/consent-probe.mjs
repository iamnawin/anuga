// Disposable PGlite only: refuses any configured real database connection.
if (process.env.DATABASE_URL) throw new Error('Refusing real database; unset DATABASE_URL for this audit.');
const { asUser, createTrip, ids } = await import('../../../supabase/tests/support/db.ts');
const trip = await createTrip(25);
await asUser(ids.owner, (db) => db.query("select public.set_consent($1,'trips',false)", [ids.patient]));
const details = await asUser(ids.asha, (db) => db.query('select details_visible from public.companion_my_trips() where trip_id=$1', [trip]));
const advanced = await asUser(ids.asha, (db) => db.query("select status from public.advance_trip($1,'companion_en_route')", [trip]));
console.log(JSON.stringify({ environment: 'disposable PGlite synthetic only', consentWithdrawn: true,
  detailsVisible: details[0]?.details_visible, resultStatus: advanced[0]?.status }));
