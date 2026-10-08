'use client';

import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { createOpsApi, type OpsApi, type PgResult } from './api';

let client: SupabaseClient | undefined;

// Browser client with the public anon key. Every request carries the signed-in
// user's JWT; permissions are enforced by the database (grants, RLS, RPC checks).
export function getSupabase(): SupabaseClient {
  if (!client) {
    const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
    if (!url || !anonKey) {
      throw new Error('NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY must be set (see .env.example)');
    }
    client = createClient(url, anonKey, { auth: { persistSession: true, storageKey: 'companion-ops-auth' } });
  }
  return client;
}

type Result = PromiseLike<PgResult<unknown>>;

// Explicit adapter: matching the full client type structurally is too deep for tsc.
export function getOpsApi(): OpsApi {
  const supabase = getSupabase();
  return createOpsApi({
    rpc: (fn, args) => supabase.rpc(fn, args) as unknown as Result,
    from: (table) => ({
      select: (columns) => ({
        eq: (column, value) => supabase.from(table).select(columns).eq(column, value) as unknown as Result,
      }),
    }),
  });
}
