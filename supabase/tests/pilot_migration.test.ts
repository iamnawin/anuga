import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';
import { test } from 'node:test';

test('populated cutover aborts atomically on unknowns/mismatches/audit failure; explicit synthetic roster preserves access', async () => {
  const { PGlite } = await import('@electric-sql/pglite');
  const { postgis } = await import('@electric-sql/pglite-postgis');
  const pg = await PGlite.create({ extensions: { postgis } });
  const root = join(import.meta.dirname, '..');
  const name = '20261016001000_pilot_account_access.sql';
  try {
    await pg.exec(await readFile(join(import.meta.dirname, 'support/supabase_shim.sql'), 'utf8'));
    for (const f of (await readdir(join(root, 'migrations'))).filter(f => f.endsWith('.sql') && f < name).sort()) {
      await pg.exec(await readFile(join(root, 'migrations', f), 'utf8'));
    }
    const migration = await readFile(join(root, 'migrations', name), 'utf8');
    const id = '20000000-0000-0000-0000-00000000bb01';
    await pg.query(`insert into auth.users(id,phone) values($1,'919000009881')`, [id]);
    const entry = { id, role: 'family', state: 'active', authority_ref: 'synthetic:local-assumption' };
    for (const manifest of [[], [entry, entry], [{ ...entry, role: 'ops_admin' }], [{ ...entry, authority_ref: '' }],
      [{ ...entry, id: '20000000-0000-0000-0000-00000000bb02' }]]) {
      await pg.query(`select set_config('anuga.pilot_backfill_manifest',$1,false)`, [JSON.stringify(manifest)]);
      await assert.rejects(pg.exec(migration));
      await pg.exec('rollback');
      assert.equal((await pg.query(`select 1 from information_schema.columns where table_schema='public' and table_name='profiles' and column_name='account_state'`)).rows.length, 0);
      assert.equal((await pg.query<{role: string}>(`select role from public.profiles where id=$1`, [id])).rows[0].role, 'family');
    }
    await pg.query('delete from public.profiles where id=$1', [id]);
    await assert.rejects(pg.exec(migration));
    await pg.exec('rollback');
    await pg.query('insert into public.profiles(id) values($1)', [id]);
    await pg.query(`select set_config('anuga.pilot_backfill_manifest',$1,false)`, [JSON.stringify([entry])]);
    await pg.exec(`create function private.fail_backfill_test() returns trigger language plpgsql as $$ begin
      if new.action='account_backfilled' then raise exception 'synthetic audit failure'; end if; return new; end $$;
      create trigger fail_backfill_test before insert on public.audit_log for each row execute function private.fail_backfill_test();`);
    await assert.rejects(pg.exec(migration));
    await pg.exec('rollback; drop trigger fail_backfill_test on public.audit_log; drop function private.fail_backfill_test()');
    await pg.exec(migration);
    const { rows } = await pg.query(`select account_state,role from public.profiles where id=$1`, [id]);
    assert.deepEqual(rows, [{ account_state: 'active', role: 'family' }]);
    assert.equal((await pg.query(`select 1 from public.audit_log where action='account_backfilled'`)).rows.length, 1);
  } finally { await pg.close(); }
});
