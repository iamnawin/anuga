// Supabase Edge Function: signed URLs for the private vault bucket (see handler.ts).
import { withCors } from '../_shared/cors.ts';
import { handleVaultRequest, supabaseVaultDeps } from './handler.ts';

const url = Deno.env.get('SUPABASE_URL');
const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

Deno.serve(withCors((request: Request) => {
  if (!url || !anonKey || !serviceKey) return Response.json({ error: 'server misconfigured' }, { status: 500 });
  return handleVaultRequest(request, supabaseVaultDeps(url, anonKey, serviceKey));
}));
