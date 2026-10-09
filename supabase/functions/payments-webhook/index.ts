// Supabase Edge Function: provider webhooks (verify_jwt = false in config.toml; the
// body signature is the authentication). See _shared/payments.ts.
import { ConfigError, handleWebhook, postgrest, selectPaymentAdapter } from '../_shared/payments.ts';

Deno.serve((request: Request) => {
  const url = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !anonKey || !serviceKey) return Response.json({ error: 'server misconfigured' }, { status: 500 });
  try {
    const adapter = selectPaymentAdapter(Deno.env.toObject());
    return handleWebhook(request, { adapter, ...postgrest(url, anonKey, serviceKey) });
  } catch (error) {
    if (error instanceof ConfigError) return Response.json({ error: 'payments not configured', message: error.message }, { status: 500 });
    throw error;
  }
});
