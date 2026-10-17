import assert from 'node:assert/strict';
import { test } from 'node:test';
import { readFile } from 'node:fs/promises';
import pg from 'pg';

test('real owner transactions serialize state/version and bound a blocked cutover without partial changes', {
  skip: !process.env.DATABASE_URL && 'requires isolated real Postgres connections',
}, async () => {
  const a = new pg.Client({ connectionString: process.env.DATABASE_URL });
  const b = new pg.Client({ connectionString: process.env.DATABASE_URL });
  await a.connect(); await b.connect();
  const id = '20000000-0000-0000-0000-00000000cc01';
  const change = `select private.configure_pilot_account($1,1,'active',null,'synthetic concurrency','synthetic:operator','synthetic:local-assumption')`;
  try {
    await a.query(`insert into auth.users(id,phone) values($1,'919000007771')`, [id]);
    await a.query('begin');
    await a.query(change, [id]);
    await b.query(`set lock_timeout='100ms'`);
    await assert.rejects(b.query(change, [id]), { code: '55P03' });
    await a.query('commit');
    await assert.rejects(b.query(change, [id]), { code: '40001' });
    const before = (await a.query('select account_state,account_state_version from public.profiles where id=$1', [id])).rows;
    await a.query('begin; lock table auth.users in access exclusive mode');
    const migration = await readFile(new URL('../migrations/20261016001000_pilot_account_access.sql', import.meta.url), 'utf8');
    await assert.rejects(b.query(migration), { code: '55P03' });
    await b.query('rollback'); await a.query('rollback');
    const after = (await a.query('select account_state,account_state_version from public.profiles where id=$1', [id])).rows;
    assert.deepEqual(after, before);
  } finally {
    await a.query('rollback'); await b.query('rollback');
    await a.end(); await b.end();
  }
});
