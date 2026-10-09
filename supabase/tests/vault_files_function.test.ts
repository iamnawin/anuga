// The vault-files Edge Function on Supabase local (edge runtime + storage), with
// real phone-OTP sessions. Skipped unless SUPABASE_URL, SUPABASE_ANON_KEY,
// SUPABASE_SERVICE_ROLE_KEY and DATABASE_URL are set (CI job supabase-local).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, ids } from './support/db.ts';

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;
const skip = !(url && anonKey && process.env.SUPABASE_SERVICE_ROLE_KEY && process.env.DATABASE_URL)
  && 'needs Supabase local with storage and the edge runtime';

// Synthetic "report": a valid 1x1 PNG.
const pngBytes = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==', 'base64');

async function signIn(phone: string): Promise<string> {
  const headers = { apikey: anonKey!, 'Content-Type': 'application/json' };
  await fetch(`${url}/auth/v1/otp`, { method: 'POST', headers, body: JSON.stringify({ phone, create_user: false }) });
  const response = await fetch(`${url}/auth/v1/verify`, {
    method: 'POST', headers, body: JSON.stringify({ phone, token: '123456', type: 'sms' }),
  });
  const body = (await response.json()) as { access_token?: string };
  assert.ok(body.access_token, `sign-in failed for ${phone}`);
  return body.access_token;
}

const call = (jwt: string, body: object) => fetch(`${url}/functions/v1/vault-files`, {
  method: 'POST', headers: { Authorization: `Bearer ${jwt}`, 'Content-Type': 'application/json' }, body: JSON.stringify(body),
});

test('vault files: owner uploads, family downloads with a short-lived URL, others are refused', { skip }, async () => {
  const [owner, viewer, asha, ops] = await Promise.all(
    ['+919000000101', '+919000000102', '+919000000201', '+919000000001'].map(signIn));

  // Upload: a signed URL for a path the database chose.
  const start = await call(owner, { action: 'upload', patient_id: ids.patient, doc_type: 'lab_report',
    title: 'Monthly labs photo (synthetic)', content_type: 'image/png', size_bytes: pngBytes.length });
  assert.equal(start.status, 200, await start.clone().text());
  const { document_id, upload_path } = (await start.json()) as { document_id: string; upload_path: string };
  assert.match(upload_path, new RegExp(`^/storage/v1/object/upload/sign/vault/${ids.patient}/${document_id}\\.png\\?token=`));

  // Download before the file exists is refused.
  assert.equal((await call(owner, { action: 'download', document_id })).status, 400);
  const early = await call(owner, { action: 'confirm', document_id });
  assert.equal(early.status, 400, 'confirm without a file');

  const put = await fetch(`${url}${upload_path}`, { method: 'PUT', headers: { 'Content-Type': 'image/png' }, body: pngBytes });
  assert.equal(put.status, 200, await put.clone().text());
  // The signed upload URL cannot overwrite the file.
  assert.notEqual((await fetch(`${url}${upload_path}`, { method: 'PUT', headers: { 'Content-Type': 'image/png' }, body: pngBytes })).status, 200);

  const confirm = await call(owner, { action: 'confirm', document_id });
  assert.equal(confirm.status, 200, await confirm.clone().text());
  assert.equal(((await confirm.json()) as { size_bytes: number }).size_bytes, pngBytes.length);

  // Viewer downloads through a signed URL; bytes match; the read is audited.
  const [{ n: before }] = await asAdmin((db) => db.query<{ n: number }>(
    `select count(*)::int as n from public.audit_log where action = 'vault_read' and actor_id = $1`, [ids.viewer]));
  const dl = await call(viewer, { action: 'download', document_id, purpose: 'family viewing report' });
  assert.equal(dl.status, 200, await dl.clone().text());
  const { download_path, expires_in } = (await dl.json()) as { download_path: string; expires_in: number };
  assert.equal(expires_in, 60);
  const file = await fetch(`${url}${download_path}`);
  assert.equal(file.status, 200);
  assert.deepEqual(Buffer.from(await file.arrayBuffer()), pngBytes);
  const [{ n: after }] = await asAdmin((db) => db.query<{ n: number }>(
    `select count(*)::int as n from public.audit_log where action = 'vault_read' and actor_id = $1`, [ids.viewer]));
  assert.equal(after, before + 1);

  // Companion and ops (no consent) are refused by the database; the viewer cannot upload.
  for (const jwt of [asha, ops]) assert.equal((await call(jwt, { action: 'download', document_id })).status, 403);
  assert.equal((await call(viewer, { action: 'upload', patient_id: ids.patient, doc_type: 'lab_report', title: 'x',
    content_type: 'image/png', size_bytes: 10 })).status, 403);
  assert.equal((await call(anonKey!, { action: 'download', document_id })).status, 401);

  // No way around the function: the bucket is private and has no object policies for app roles.
  const objectPath = `${ids.patient}/${document_id}.png`;
  for (const auth of [owner, anonKey!]) {
    const direct = await fetch(`${url}/storage/v1/object/authenticated/vault/${objectPath}`, {
      headers: { apikey: anonKey!, Authorization: `Bearer ${auth}` },
    });
    assert.ok(direct.status >= 400, `direct read must fail, got ${direct.status}`);
  }
  assert.ok((await fetch(`${url}/storage/v1/object/public/vault/${objectPath}`)).status >= 400, 'no public URL');
  const directUpload = await fetch(`${url}/storage/v1/object/vault/${ids.patient}/sneaky.png`, {
    method: 'POST', headers: { apikey: anonKey!, Authorization: `Bearer ${owner}`, 'Content-Type': 'image/png' }, body: pngBytes,
  });
  assert.ok(directUpload.status >= 400, `direct upload must fail, got ${directUpload.status}`);
});
