// Database harness for the SQL tests.
//
// Default: an in-process PGlite (Postgres 18 in WASM) with PostGIS, loaded with
// supabase_shim.sql + every migration + the synthetic seed. Needs no Docker.
//
// With DATABASE_URL set: connects to a real Postgres that already has the
// migrations and seed applied (e.g. `supabase db reset` on Supabase local).
import { readdir, readFile } from 'node:fs/promises';
import { join } from 'node:path';

type Row = Record<string, unknown>;

export interface Db {
  query<T extends Row = Row>(sql: string, params?: unknown[]): Promise<T[]>;
  exec(sql: string): Promise<void>;
}

const supabaseDir = join(import.meta.dirname, '..', '..');
let shared: Promise<Db> | undefined;

export function getDb(): Promise<Db> {
  shared ??= process.env.DATABASE_URL ? connectPostgres(process.env.DATABASE_URL) : startPglite();
  return shared;
}

async function startPglite(): Promise<Db> {
  const { PGlite } = await import('@electric-sql/pglite');
  const { postgis } = await import('@electric-sql/pglite-postgis');
  const pg = await PGlite.create({ extensions: { postgis } });

  await pg.exec(await readFile(join(import.meta.dirname, 'supabase_shim.sql'), 'utf8'));
  const migrationsDir = join(supabaseDir, 'migrations');
  for (const file of (await readdir(migrationsDir)).filter((f) => f.endsWith('.sql')).sort()) {
    await pg.exec(await readFile(join(migrationsDir, file), 'utf8'));
  }
  await pg.exec(await readFile(join(supabaseDir, 'seed', 'seed.sql'), 'utf8'));

  return {
    query: async <T extends Row>(sql: string, params?: unknown[]) => (await pg.query<T>(sql, params)).rows,
    exec: async (sql) => { await pg.exec(sql); },
  };
}

async function connectPostgres(url: string): Promise<Db> {
  const { default: pg } = await import('pg');
  const client = new pg.Client({ connectionString: url });
  await client.connect();
  return {
    query: async <T extends Row>(sql: string, params?: unknown[]) => (await client.query<T>(sql, params)).rows,
    exec: async (sql) => { await client.query(sql); },
  };
}

// Runs fn as an API user (role `authenticated`, JWT sub = userId) inside one
// transaction, like a single PostgREST request. Commits on success.
export async function asUser<T>(userId: string, fn: (db: Db) => Promise<T>): Promise<T> {
  return inTransaction('authenticated', { sub: userId, role: 'authenticated' }, fn, 'commit');
}

// Same as asUser, but always rolls back. Use for probes that must not persist.
export async function probeAsUser<T>(userId: string, fn: (db: Db) => Promise<T>): Promise<T> {
  return inTransaction('authenticated', { sub: userId, role: 'authenticated' }, fn, 'rollback');
}

export async function probeAsAnon<T>(fn: (db: Db) => Promise<T>): Promise<T> {
  return inTransaction('anon', { role: 'anon' }, fn, 'rollback');
}

// Runs fn as the service role (trusted backend, e.g. the notification dispatcher). Commits.
export async function asServiceRole<T>(fn: (db: Db) => Promise<T>): Promise<T> {
  return inTransaction('service_role', { role: 'service_role' }, fn, 'commit');
}

async function inTransaction<T>(
  role: string, claims: Row, fn: (db: Db) => Promise<T>, end: 'commit' | 'rollback',
): Promise<T> {
  const db = await getDb();
  await db.exec('begin');
  try {
    await db.exec(`set local role ${role}`);
    await db.query(`select set_config('request.jwt.claims', $1, true)`, [JSON.stringify(claims)]);
    const result = await fn(db);
    await db.exec(end);
    return result;
  } catch (error) {
    await db.exec('rollback');
    throw error;
  }
}

// Runs as the database owner (seed/migration privileges) and commits.
export async function asAdmin<T>(fn: (db: Db) => Promise<T>): Promise<T> {
  const db = await getDb();
  return fn(db);
}

export const ids = {
  ops: '10000000-0000-0000-0000-000000000001',
  owner: '20000000-0000-0000-0000-000000000001',
  viewer: '20000000-0000-0000-0000-000000000002',
  asha: '30000000-0000-0000-0000-000000000001',
  ravi: '30000000-0000-0000-0000-000000000002',
  farCompanion: '30000000-0000-0000-0000-000000000003',
  pendingCompanion: '30000000-0000-0000-0000-000000000004',
  cluster: '40000000-0000-0000-0000-000000000001',
  centre: '50000000-0000-0000-0000-000000000001',
  basicPackage: '60000000-0000-0000-0000-000000000001',
  patient: '70000000-0000-0000-0000-000000000001',
  schedule: '80000000-0000-0000-0000-000000000001',
} as const;

// Creates a stranger: a family account with no access to the seed patient.
export async function createUser(id: string, role: 'family' | 'companion' | 'ops_admin' = 'family'): Promise<string> {
  await asAdmin(async (db) => {
    await db.query(`insert into auth.users (id, phone) values ($1, $2) on conflict do nothing`,
      [id, `91999${id.replaceAll('-', '').slice(-7)}`]);
    // This helper creates ACTIVE synthetic fixtures; actual Auth creation stays pending.
    await db.query(`select private.configure_pilot_account(id,account_state_version,'active',$2,
      'active test fixture','synthetic:test-helper','synthetic:provisional-defaults')
      from public.profiles where id=$1`, [id, role]);
  });
  return id;
}

// Creates a trip for the seed patient at a pickup time relative to now.
export async function createTrip(pickupInMinutes: number, companionId: string | null = ids.asha): Promise<string> {
  return asAdmin(async (db) => {
    const [row] = await db.query<{ id: string }>(
      `insert into public.trips (patient_id, centre_id, companion_id, scheduled_pickup_at, scheduled_return_at)
       values ($1, $2, $3, now() + make_interval(mins => $4::int), now() + make_interval(mins => $4::int + 300))
       returning id`,
      [ids.patient, ids.centre, companionId, pickupInMinutes],
    );
    return row.id;
  });
}

// Asserts the promise rejects with a Postgres error code (default 42501 = insufficient_privilege).
export async function expectPgError(promise: Promise<unknown>, code = '42501'): Promise<void> {
  try {
    await promise;
  } catch (error: unknown) {
    const { code: actual, message } = (error ?? {}) as { code?: string; message?: string };
    if (actual === code) return;
    throw new Error(`expected SQLSTATE ${code}, got ${actual}: ${message}`);
  }
  throw new Error(`expected SQLSTATE ${code}, but the call succeeded`);
}
