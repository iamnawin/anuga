// Checks that only mean something on a real Supabase database (storage schema,
// real auth schema). They skip on the PGlite harness, which has neither.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, expectPgError, ids, probeAsAnon, probeAsUser } from './support/db.ts';

async function hasSchema(name: string): Promise<boolean> {
  const rows = await asAdmin((db) => db.query('select 1 from pg_namespace where nspname = $1', [name]));
  return rows.length === 1;
}

const realSupabase = Boolean(process.env.DATABASE_URL);

test('no storage bucket is public', { skip: !realSupabase && 'needs real Supabase (storage schema)' }, async () => {
  assert.ok(await hasSchema('storage'), 'storage schema missing');
  const publicBuckets = await asAdmin((db) => db.query('select id from storage.buckets where public'));
  assert.deepEqual(publicBuckets, []);
});

test('API roles cannot list storage objects without a policy', { skip: !realSupabase && 'needs real Supabase' }, async () => {
  const objects = await probeAsUser(ids.owner, (db) => db.query('select id from storage.objects'));
  assert.deepEqual(objects, []);
});

test('real auth.uid() resolves the request JWT', { skip: !realSupabase && 'needs real Supabase auth schema' }, async () => {
  const [row] = await probeAsUser(ids.owner, (db) => db.query<{ uid: string }>('select auth.uid()::text as uid'));
  assert.equal(row.uid, ids.owner);
});

test('anon cannot call any app function', async () => {
  for (const sql of [
    `select * from public.companion_my_trips()`,
    `select * from public.family_trip_board('${ids.patient}')`,
    `select * from public.vault_list_documents('${ids.patient}')`,
  ]) {
    await expectPgError(probeAsAnon((db) => db.query(sql)));
  }
});
