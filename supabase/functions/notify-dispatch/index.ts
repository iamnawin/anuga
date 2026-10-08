// Supabase Edge Function: drains the notifications outbox once per call.
// Invoke on a schedule (e.g. every minute) with the service-role key; any other
// caller is refused. Adapters come from env (default `test`; see adapters.ts).
import { ConfigError, selectAdapters } from './adapters.ts';
import { drain } from './dispatcher.ts';
import { restStore } from './rest_store.ts';

function jwtRole(authorization: string | null): string | null {
  const token = authorization?.replace(/^Bearer\s+/i, '') ?? '';
  const part = token.split('.')[1];
  if (!part) return null;
  try {
    const json = JSON.parse(atob(part.replace(/-/g, '+').replace(/_/g, '/')));
    return typeof json.role === 'string' ? json.role : null;
  } catch {
    return null;
  }
}

Deno.serve(async (request: Request) => {
  if (request.method !== 'POST') return new Response('method not allowed', { status: 405 });
  // The platform verifies the JWT signature (verify_jwt); only the service role may dispatch.
  if (jwtRole(request.headers.get('Authorization')) !== 'service_role') {
    return new Response('forbidden', { status: 403 });
  }
  const url = Deno.env.get('SUPABASE_URL');
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !key) return new Response('server misconfigured', { status: 500 });

  const store = restStore(url, key);
  try {
    const adapters = selectAdapters(Deno.env.toObject(), store);
    const summary = await drain(store, adapters, { limit: 50 });
    return Response.json(summary);
  } catch (error) {
    const status = error instanceof ConfigError ? 500 : 502;
    return Response.json({ error: (error as Error).message }, { status });
  }
});
