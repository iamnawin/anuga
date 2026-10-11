// CORS for functions that browsers call (the web builds of the apps). Requests are
// authorized by the bearer token, never cookies, so any origin may send them; the
// token and the database decide what the caller can do.

export const corsHeaders: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

type Handler = (request: Request) => Response | Promise<Response>;

/** Answers preflight requests and adds the CORS headers to every response. */
export function withCors(handler: Handler): (request: Request) => Promise<Response> {
  return async (request) => {
    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: corsHeaders });
    const response = await handler(request);
    const headers = new Headers(response.headers);
    for (const [name, value] of Object.entries(corsHeaders)) headers.set(name, value);
    return new Response(response.body, { status: response.status, statusText: response.statusText, headers });
  };
}
