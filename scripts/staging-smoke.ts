// Smoke test against the hosted staging project (synthetic data only). Run by the
// deploy-staging workflow after each deploy:
//   STAGING_SUPABASE_URL=... STAGING_SUPABASE_ANON_KEY=... STAGING_TEST_OTP=... node scripts/staging-smoke.ts
// Signs in seed accounts with the staging test OTP and checks one allowed and one
// denied path per role, plus CORS on the functions browsers call. Changes no data.
import assert from 'node:assert/strict';

const url = process.env.STAGING_SUPABASE_URL?.replace(/\/$/, '');
const anonKey = process.env.STAGING_SUPABASE_ANON_KEY;
const otp = process.env.STAGING_TEST_OTP;
if (!url || !anonKey || !otp) throw new Error('set STAGING_SUPABASE_URL, STAGING_SUPABASE_ANON_KEY and STAGING_TEST_OTP');

const phones = { ops: '919000000001', owner: '919000000101', asha: '919000000201' };

async function signIn(phone: string): Promise<string> {
  const headers = { apikey: anonKey!, 'Content-Type': 'application/json' };
  const sent = await fetch(`${url}/auth/v1/otp`, { method: 'POST', headers, body: JSON.stringify({ phone }) });
  assert.ok(sent.ok, `otp request for ${phone}: HTTP ${sent.status} ${await sent.text()}`);
  const verified = await fetch(`${url}/auth/v1/verify`, {
    method: 'POST', headers, body: JSON.stringify({ type: 'sms', phone, token: otp }),
  });
  const body = (await verified.json()) as { access_token?: string };
  assert.ok(verified.ok && body.access_token, `sign-in for ${phone}: HTTP ${verified.status}`);
  return body.access_token!;
}

async function rpc(token: string | null, fn: string, args: Record<string, unknown> = {}) {
  const response = await fetch(`${url}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: { apikey: anonKey!, Authorization: `Bearer ${token ?? anonKey}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(args),
  });
  const text = await response.text();
  return { status: response.status, body: text ? JSON.parse(text) : null };
}

const denied = (r: { status: number; body: { code?: string } | null }) =>
  r.status >= 400 && (r.body?.code === '42501' || r.status === 401 || r.status === 403 || r.status === 404);

function check(name: string, ok: boolean, detail = '') {
  console.log(`${ok ? 'ok  ' : 'FAIL'} ${name}${detail ? ` (${detail})` : ''}`);
  if (!ok) process.exitCode = 1;
}

const week = { p_from: new Date(Date.now() - 86400000).toISOString(), p_to: new Date(Date.now() + 14 * 86400000).toISOString() };

// Not signed in.
check('anon: family_my_patients denied', denied(await rpc(null, 'family_my_patients')));

// Ops.
const ops = await signIn(phones.ops);
const board = await rpc(ops, 'ops_trip_board', week);
check('ops: trip board lists synthetic trips', board.status === 200 && board.body.length > 0, `${board.body?.length} trips`);

// Family owner.
const owner = await signIn(phones.owner);
const patients = await rpc(owner, 'family_my_patients');
check('owner: sees their patient', patients.status === 200 && patients.body[0]?.access_level === 'owner');
check('owner: ops trip board denied', denied(await rpc(owner, 'ops_trip_board', week)));

// Companion.
const asha = await signIn(phones.asha);
const trips = await rpc(asha, 'companion_my_trips', week);
check('companion: sees assigned trips', trips.status === 200 && trips.body.length > 0, `${trips.body?.length} trips`);
const direct = await fetch(`${url}/rest/v1/patients?select=id`, { headers: { apikey: anonKey, Authorization: `Bearer ${asha}` } });
check('companion: patients table returns nothing', direct.status !== 200 || ((await direct.json()) as unknown[]).length === 0);

// Edge Functions called from browsers.
for (const fn of ['vault-files', 'payments']) {
  const preflight = await fetch(`${url}/functions/v1/${fn}`, {
    method: 'OPTIONS', headers: { Origin: 'https://staging.example', 'Access-Control-Request-Method': 'POST' },
  });
  check(`${fn}: CORS preflight`, preflight.ok && preflight.headers.get('access-control-allow-origin') === '*', `HTTP ${preflight.status}`);
}
const noLogin = await fetch(`${url}/functions/v1/payments`, { method: 'POST', body: '{}' });
check('payments: refused without sign-in', noLogin.status === 401, `HTTP ${noLogin.status}`);
const asCompanion = await fetch(`${url}/functions/v1/vault-files`, {
  method: 'POST',
  headers: { apikey: anonKey, Authorization: `Bearer ${asha}`, 'Content-Type': 'application/json' },
  body: JSON.stringify({ action: 'upload', patient_id: '70000000-0000-0000-0000-000000000001', doc_type: 'other', title: 'x', content_type: 'image/png', size_bytes: 10 }),
});
check('vault-files: companion cannot upload', asCompanion.status === 403, `HTTP ${asCompanion.status}`);

if (process.exitCode) console.log('\nstaging smoke test FAILED');
else console.log('\nstaging smoke test passed');
