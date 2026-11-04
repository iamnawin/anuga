// Real Postgres only. The PGlite harness has one connection and cannot prove locks.
import assert from 'node:assert/strict';
import pg from 'pg';

export async function actorConnection(user: string) {
  if (!process.env.DATABASE_URL) throw new Error('Concurrent checks require disposable real Postgres');
  const client = new pg.Client({ connectionString: process.env.DATABASE_URL });
  await client.connect();
  await client.query('begin');
  await client.query('set local role authenticated');
  await client.query("select set_config('request.jwt.claims',$1,true)", [JSON.stringify({ sub: user, role: 'authenticated' })]);
  return client;
}

export async function waitForLock(observer: pg.Client, pid: number) {
  for (let attempt = 0; attempt < 200; attempt++) {
    const { rows } = await observer.query('select pg_backend_pid() = any(pg_blocking_pids($1)) as blocking', [pid]);
    if (rows[0]?.blocking === true) return;
    await new Promise((resolve) => setTimeout(resolve, 10));
  }
  assert.fail('second transaction never waited for a database lock');
}
