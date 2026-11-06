import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { asAdmin } from './support/db.ts';

test('operator catalogue attestation executes read-only and leaves application rows unchanged', async () => {
  await asAdmin(async (db) => {
    if (!process.env.DATABASE_URL) {
      // PGlite does not have Supabase migration bookkeeping. No hosted change.
      await db.exec('create schema if not exists supabase_migrations; create table if not exists supabase_migrations.schema_migrations(version text)');
    }
    const before = await db.query('select (select count(*) from public.patients) as patients, (select count(*) from public.trips) as trips');
    const sql = await readFile(new URL('../../scripts/production-attestation.sql', import.meta.url), 'utf8');
    assert.match(sql, /begin transaction isolation level repeatable read read only;/);
    await db.exec(sql);
    assert.deepEqual(await db.query('select (select count(*) from public.patients) as patients, (select count(*) from public.trips) as trips'), before);
  });
});
