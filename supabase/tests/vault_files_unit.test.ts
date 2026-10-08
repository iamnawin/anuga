// Unit tests for the vault-files Edge Function handler with fake dependencies:
// it must ask the database (as the caller) before signing anything.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { handleVaultRequest, RpcError, supabaseVaultDeps, type VaultDeps } from '../functions/vault-files/handler.ts';

const b64 = (o: object) => Buffer.from(JSON.stringify(o)).toString('base64url');
const userJwt = `${b64({ alg: 'HS256' })}.${b64({ role: 'authenticated', sub: 'u1' })}.sig`;
const anonJwt = `${b64({ alg: 'HS256' })}.${b64({ role: 'anon' })}.sig`;

function fakeDeps(overrides: Partial<VaultDeps> = {}) {
  const calls: string[] = [];
  const deps: VaultDeps = {
    userRpc: async (jwt, fn) => {
      calls.push(`user:${fn}`);
      assert.equal(jwt, userJwt, 'database calls carry the caller\'s JWT');
      if (fn === 'vault_create_document') return [{ document_id: 'd1', storage_path: 'p1/d1.png' }];
      if (fn === 'vault_upload_target') return 'p1/d1.png';
      if (fn === 'vault_document_download') return [{ storage_path: 'p1/d1.png', content_type: 'image/png', url_seconds: 60 }];
      throw new Error(fn);
    },
    serviceRpc: async (fn) => { calls.push(`service:${fn}`); return null; },
    signUpload: async (path) => { calls.push(`signUpload:${path}`); return `/storage/v1/object/upload/sign/vault/${path}?token=t`; },
    signDownload: async (path, s) => { calls.push(`signDownload:${path}:${s}`); return `/storage/v1/object/sign/vault/${path}?token=t`; },
    objectSize: async (path) => { calls.push(`objectSize:${path}`); return 2048; },
    ...overrides,
  };
  return { deps, calls };
}

const post = (body: unknown, jwt: string | null = userJwt) => new Request('http://edge/vault-files', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', ...(jwt ? { Authorization: `Bearer ${jwt}` } : {}) },
  body: JSON.stringify(body),
});

describe('vault-files handler', () => {
  test('upload: database first, then a signed URL for the path the database chose', async () => {
    const { deps, calls } = fakeDeps();
    const response = await handleVaultRequest(post({ action: 'upload', patient_id: 'p1', doc_type: 'lab_report',
      title: 'x', content_type: 'image/png', size_bytes: 2048, storage_path: '../other-patient/x.png' }), deps);
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), { document_id: 'd1', upload_path: '/storage/v1/object/upload/sign/vault/p1/d1.png?token=t' });
    assert.deepEqual(calls, ['user:vault_create_document', 'signUpload:p1/d1.png'], 'a client-supplied path is ignored');
  });

  test('confirm: only marks uploaded when the object exists', async () => {
    const ok = fakeDeps();
    assert.equal((await handleVaultRequest(post({ action: 'confirm', document_id: 'd1' }), ok.deps)).status, 200);
    assert.deepEqual(ok.calls, ['user:vault_upload_target', 'objectSize:p1/d1.png', 'service:vault_mark_uploaded']);
    const missing = fakeDeps({ objectSize: async () => null });
    const response = await handleVaultRequest(post({ action: 'confirm', document_id: 'd1' }), missing.deps);
    assert.equal(response.status, 400);
    assert.ok(!missing.calls.includes('service:vault_mark_uploaded'));
  });

  test('download: the audited authorization runs before signing, with the lifetime from the database', async () => {
    const { deps, calls } = fakeDeps();
    const response = await handleVaultRequest(post({ action: 'download', document_id: 'd1' }), deps);
    assert.deepEqual(await response.json(), {
      download_path: '/storage/v1/object/sign/vault/p1/d1.png?token=t', content_type: 'image/png', expires_in: 60,
    });
    assert.deepEqual(calls, ['user:vault_document_download', 'signDownload:p1/d1.png:60']);
  });

  test('a database refusal signs nothing and maps to 403 / 400', async () => {
    for (const [code, status] of [['42501', 403], ['22023', 400]] as const) {
      const { deps, calls } = fakeDeps({ userRpc: async () => { throw new RpcError({ status: 403, code, message: 'no' }); } });
      const response = await handleVaultRequest(post({ action: 'download', document_id: 'd1' }), deps);
      assert.equal(response.status, status);
      assert.deepEqual(calls, []);
    }
  });

  test('requires a signed-in user, POST, JSON and a known action', async () => {
    const { deps, calls } = fakeDeps();
    assert.equal((await handleVaultRequest(post({ action: 'download' }, null), deps)).status, 401);
    assert.equal((await handleVaultRequest(post({ action: 'download' }, anonJwt), deps)).status, 401);
    assert.equal((await handleVaultRequest(new Request('http://edge/vault-files', { method: 'GET' }), deps)).status, 405);
    assert.equal((await handleVaultRequest(new Request('http://edge/vault-files', {
      method: 'POST', headers: { Authorization: `Bearer ${userJwt}` }, body: 'nope',
    }), deps)).status, 400);
    assert.equal((await handleVaultRequest(post({ action: 'delete' }), deps)).status, 400);
    assert.deepEqual(calls, []);
  });

  test('the REST deps call PostgREST as the user and Storage as the service role', async () => {
    const seen: { url: string; auth: string }[] = [];
    const fakeFetch = (async (url: string, init: RequestInit) => {
      seen.push({ url, auth: (init.headers as Record<string, string>).Authorization });
      // Like Storage: a JSON request needs a body.
      if (url.includes('/storage/') && init.body === undefined) return new Response('{"error":"empty body"}', { status: 400 });
      if (url.includes('/rpc/')) return new Response('[{"storage_path":"p/d.png","content_type":"image/png","url_seconds":60}]');
      if (url.includes('/upload/sign/')) return new Response('{"url":"/object/upload/sign/vault/p/d.png?token=u"}');
      return new Response('{"signedURL":"/object/sign/vault/p/d.png?token=t"}');
    }) as unknown as typeof fetch;
    const deps = supabaseVaultDeps('http://kong:8000/', 'anon', 'service', fakeFetch);
    await deps.userRpc('user-jwt', 'vault_document_download', {});
    assert.equal(await deps.signDownload('p/d.png', 60), '/storage/v1/object/sign/vault/p/d.png?token=t');
    assert.equal(await deps.signUpload('p/d.png'), '/storage/v1/object/upload/sign/vault/p/d.png?token=u');
    assert.deepEqual(seen, [
      { url: 'http://kong:8000/rest/v1/rpc/vault_document_download', auth: 'Bearer user-jwt' },
      { url: 'http://kong:8000/storage/v1/object/sign/vault/p/d.png', auth: 'Bearer service' },
      { url: 'http://kong:8000/storage/v1/object/upload/sign/vault/p/d.png', auth: 'Bearer service' },
    ]);
  });
});
