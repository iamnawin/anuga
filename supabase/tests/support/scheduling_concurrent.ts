import assert from 'node:assert/strict';
import pg from 'pg';

// Two real connections are required to prove serialization; PGlite has one.
export async function connectActor(user: string) {
  if (!process.env.DATABASE_URL) throw new Error('Disposable real Postgres is required');
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
  assert.fail('conflicting assignment never waited for a database lock');
}
