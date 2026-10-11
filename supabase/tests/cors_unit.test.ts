// CORS wrapper for the functions browsers call (vault-files, payments).
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { corsHeaders, withCors } from '../functions/_shared/cors.ts';

describe('withCors', () => {
  test('answers a preflight without calling the handler', async () => {
    let called = false;
    const handler = withCors(() => {
      called = true;
      return new Response('x');
    });
    const response = await handler(new Request('http://fn/', { method: 'OPTIONS' }));
    assert.equal(response.status, 204);
    assert.equal(called, false);
    for (const [name, value] of Object.entries(corsHeaders)) assert.equal(response.headers.get(name), value);
  });

  test('keeps the handler status, body and headers, and adds the CORS headers', async () => {
    const handler = withCors(() => Response.json({ error: 'not_allowed' }, { status: 403 }));
    const response = await handler(new Request('http://fn/', { method: 'POST' }));
    assert.equal(response.status, 403);
    assert.equal(response.headers.get('content-type'), 'application/json');
    assert.equal(response.headers.get('access-control-allow-origin'), '*');
    assert.deepEqual(await response.json(), { error: 'not_allowed' });
  });
});
