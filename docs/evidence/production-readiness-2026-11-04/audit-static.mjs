// Read-only audit. Never sends OTPs, signs in, changes data or installs dependencies.
// Run from any directory: node <this-file> [--network]
import { readFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { dirname, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '../../..');
const read = (file) => readFileSync(resolve(root, file), 'utf8');
const load = (file) => import(pathToFileURL(resolve(root, file)).href);
const keys = (object) => Object.keys(object).filter((key) => !key.startsWith('@')).sort();
const tokens = (text) => [...new Set([...text.matchAll(/\{([A-Za-z]\w*)(?=\s*[,}])/g)].map((m) => m[1]))].sort();
const same = (left, right) => JSON.stringify(left) === JSON.stringify(right);

function compare(name, catalogues) {
  const english = catalogues.en;
  return { name, englishKeys: keys(english).length, languages: ['te', 'hi'].map((lang) => {
    const translated = catalogues[lang];
    return {
      lang,
      keys: keys(translated).length,
      missing: keys(english).filter((key) => !(key in translated)),
      extra: keys(translated).filter((key) => !(key in english)),
      empty: keys(translated).filter((key) => typeof translated[key] !== 'string' || !translated[key].trim()),
      placeholderMismatch: keys(english).filter((key) => typeof translated[key] === 'string'
        && !same(tokens(english[key]), tokens(translated[key]))),
      identicalToEnglish: keys(english).filter((key) => translated[key] === english[key]),
      stringsWithoutNativeScript: keys(translated).filter((key) => typeof translated[key] === 'string'
        && !(lang === 'te' ? /\p{Script=Telugu}/u : /\p{Script=Devanagari}/u).test(translated[key])),
    };
  }) };
}

const catalogues = [];
for (const app of ['anugacare_app', 'family_app', 'companion_app']) {
  catalogues.push(compare(app, Object.fromEntries(['en', 'te', 'hi'].map((lang) =>
    [lang, JSON.parse(read(`apps/${app}/lib/l10n/app_${lang}.arb`))]))));
}
const { messages } = await load('apps/ops_console/src/lib/messages.ts');
catalogues.push(compare('ops_console', messages));
const { render, TEMPLATES, STATUSES } = await load('supabase/functions/notify-dispatch/messages.ts');
const notifications = [];
for (const lang of ['en', 'te', 'hi']) {
  for (const template of TEMPLATES) {
    for (const status of template === 'trip_status_changed' ? STATUSES : [null]) {
      const message = render(template, { to_status: status, total_paise: 12345, period_start: '2026-11-01', note: 'PRIVATE_AUDIT_MARKER' }, lang);
      notifications.push({ lang, template, status, nonEmpty: !!message.title.trim() && !!message.body.trim(),
        unresolvedTokens: tokens(message.title + ' ' + message.body),
        privateMarkerAbsent: !JSON.stringify(message).includes('PRIVATE_AUDIT_MARKER') });
    }
  }
}
const tracked = execFileSync('git', ['ls-files'], { cwd: root, encoding: 'utf8' }).trim().split(/\r?\n/);
const hardcodedTextCandidates = [];
const credentialIndicators = [];
for (const file of tracked.filter((file) => /\.(?:ts|tsx|dart|sql|json|yml|yaml|mjs|sh|ps1|toml|md|example)$/.test(file))) {
  read(file).split(/\r?\n/).forEach((line, index) => {
    if (/-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|AKIA[0-9A-Z]{16}|sk_live_[A-Za-z0-9]{20,}|rzp_live_[A-Za-z0-9]{10,}/.test(line)) {
      credentialIndicators.push({ file, line: index + 1, kind: 'private-key or live-provider key pattern; value omitted' });
    }
    for (const match of line.matchAll(/eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/g)) {
      try {
        const claims = JSON.parse(Buffer.from(match[0].split('.')[1], 'base64url'));
        if (claims.role === 'service_role') credentialIndicators.push({ file, line: index + 1, kind: 'service-role JWT; value omitted' });
      } catch { /* Not a decodable JWT; this is a heuristic, not a historical secret scan. */ }
    }
  });
}
for (const file of tracked.filter((file) => /^apps\/[^/]+\/lib\/(?:src|main)/.test(file) && file.endsWith('.dart'))) {
  read(file).split(/\r?\n/).forEach((line, index) => {
    if (/\b(?:Text|SelectableText)\(\s*['"][A-Za-z]/.test(line)) {
      hardcodedTextCandidates.push({ file, line: index + 1, text: line.trim() });
    }
  });
}
const result = { source: execFileSync('git', ['rev-parse', 'HEAD'], { cwd: root, encoding: 'utf8' }).trim(),
  checkedAtUtc: new Date().toISOString(), catalogues, notifications, hardcodedTextCandidates, credentialIndicators,
  limits: ['Token/key checks do not approve translation meaning or all ICU grammar.',
    'Hardcoded-text search is heuristic; source review and rendered screens are still required.',
    'No authenticated hosted rows, auth accounts, Storage objects, secrets or logs are inventoried.'] };
result.structuralPass = catalogues.every((catalogue) => catalogue.languages.every((lang) =>
  !lang.missing.length && !lang.extra.length && !lang.empty.length && !lang.placeholderMismatch.length))
  && notifications.every((message) => message.nonEmpty && !message.unresolvedTokens.length && message.privateMarkerAbsent);

if (process.argv.includes('--network')) {
  const observed = {};
  const request = (url, options = {}) => fetch(url, { ...options, signal: AbortSignal.timeout(30000) });
  for (const path of ['/', '/app/', '/ops/login/', '/family/', '/companion/']) {
    try {
      const response = await request(`https://anuga.vercel.app${path}`);
      observed[path] = { status: response.status, finalUrl: response.url };
    } catch (error) { observed[path] = { unverified: error.message }; }
  }
  try {
    const response = await request('https://anuga.vercel.app/app/main.dart.js');
    const bundle = Buffer.from(await response.arrayBuffer());
    const receipt = JSON.parse(read('docs/evidence/issue-handling-2026-11-03/pr21-deployment.json'));
    const sha256 = createHash('sha256').update(bundle).digest('hex');
    observed.appBundle = { status: response.status, bytes: bundle.length, sha256,
      matchesRecordedPr21: sha256 === receipt.app_bundle_sha256, recordedSource: receipt.source };
  } catch (error) { observed.appBundle = { unverified: error.message }; }
  try {
    const workflow = read('.github/workflows/deploy-staging.yml');
    const url = workflow.match(/^  STAGING_SUPABASE_URL: (.+)$/m)[1].trim();
    const key = workflow.match(/^  STAGING_SUPABASE_ANON_KEY: (.+)$/m)[1].trim();
    const role = JSON.parse(Buffer.from(key.split('.')[1], 'base64url')).role;
    const response = await request(`${url}/auth/v1/settings`, { headers: { apikey: key } });
    const settings = await response.json();
    observed.auth = { url, publicKeyRole: role, status: response.status,
      phoneEnabled: settings.external?.phone, disableSignup: settings.disable_signup,
      smsProvider: settings.sms_provider, smsAutoconfirm: settings.sms_autoconfirm,
      unverified: ['test-phone map/OTP values', 'SMS credentials', 'MFA', 'session timeout dashboard', 'region/plan/backups'] };
    const anonymous = await request(`${url}/rest/v1/patients?select=id&limit=1`, { headers: { apikey: key, Authorization: `Bearer ${key}` } });
    const rows = await anonymous.json();
    observed.anonymousPatients = { status: anonymous.status, rowsReturned: Array.isArray(rows) ? rows.length : null };
  } catch (error) { observed.auth = { unverified: error.message }; }
  result.publicHttp = observed;
}
console.log(JSON.stringify(result, null, 2));
if (!result.structuralPass) process.exitCode = 1;
