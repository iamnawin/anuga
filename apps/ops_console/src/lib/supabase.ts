import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import type { OpsClient } from './ops.ts';

let client: SupabaseClient | undefined;

// Browser client with the anon key; the signed-in user's JWT does the rest.
// Created lazily so `next build` does not need the env vars.
export function supabase(): SupabaseClient {
  if (!client) {
    const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
    if (!url || !key) {
      throw new Error('Set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY (see .env.example).');
    }
    client = createClient(url, key);
  }
  return client;
}

// supabase-js satisfies OpsClient structurally, but its generic builder types do not
// line up with the narrow interface, hence the cast.
export function opsClient(): OpsClient {
  return supabase() as unknown as OpsClient;
}
