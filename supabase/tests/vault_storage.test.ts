// Vault files and consents (migration 0800): allowed and denied for each rule.
// Storage itself (bucket, signed URLs) is tested on real Supabase in
// vault_files_function.test.ts; this file covers the database authorization.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, asServiceRole, asUser, expectPgError, ids, probeAsAnon, probeAsUser } from './support/db.ts';

const png = { type: 'image/png', size: 2048 };

async function createDoc(userId: string, title = 'Lab report (synthetic)'): Promise<{ document_id: string; storage_path: string }> {
  const [row] = await asUser(userId, (db) => db.query<{ document_id: string; storage_path: string }>(
    'select * from public.vault_create_document($1, $2, $3, $4, $5)',
    [ids.patient, 'lab_report', title, png.type, png.size]));
  return row;
}

async function setVaultConsent(active: boolean): Promise<void> {
  await asUser(ids.owner, (db) => db.query(`select public.set_consent($1, 'vault', $2)`, [ids.patient, active]));
}

async function withoutVaultConsent(fn: () => Promise<void>): Promise<void> {
  await setVaultConsent(false);
  try {
    await fn();
  } finally {
    await setVaultConsent(true);
  }
}

async function auditCount(action: string): Promise<number> {
  const [{ n }] = await asAdmin((db) => db.query<{ n: number }>(
    'select count(*)::int as n from public.audit_log where action = $1 and patient_id = $2', [action, ids.patient]));
  return n;
}

describe('creating vault documents', () => {
  test('the owner gets a server-generated path under the patient, and the row waits for its file', async () => {
    const doc = await createDoc(ids.owner);
    assert.match(doc.storage_path, new RegExp(`^${ids.patient}/[0-9a-f-]{36}\\.png$`));
    const [row] = await asAdmin((db) => db.query(
      'select status, content_type, size_bytes, uploaded_by from public.vault_documents where id = $1', [doc.document_id]));
    assert.deepEqual(row, { status: 'pending_upload', content_type: 'image/png', size_bytes: 2048, uploaded_by: ids.owner });
  });

  test('viewers, companions and ops cannot create documents', async () => {
    for (const user of [ids.viewer, ids.asha, ids.ops]) {
      await expectPgError(probeAsUser(user, (db) => db.query(
        'select * from public.vault_create_document($1, $2, $3, $4, $5)', [ids.patient, 'lab_report', 'x', png.type, png.size])));
    }
    await expectPgError(probeAsAnon((db) => db.query(
      'select * from public.vault_create_document($1, $2, $3, $4, $5)', [ids.patient, 'lab_report', 'x', png.type, png.size])));
  });

  test('clients can no longer insert document rows (or choose a storage path) directly', async () => {
    await expectPgError(probeAsUser(ids.owner, (db) => db.query(
      `insert into public.vault_documents (patient_id, doc_type, title, storage_path) values ($1, 'other', 'x', 'someone/else.pdf')`,
      [ids.patient])));
  });

  test('file type, size and title are checked', async () => {
    const call = (type: string, size: number, title = 'x') => probeAsUser(ids.owner, (db) => db.query(
      'select * from public.vault_create_document($1, $2, $3, $4, $5)', [ids.patient, 'lab_report', title, type, size]));
    await expectPgError(call('application/x-msdownload', 100), '22023');
    await expectPgError(call('image/png', 0), '22023');
    await expectPgError(call('image/png', 10485761), '22023');
    await expectPgError(call('image/png', 100, '   '), '22023');
    await call('application/pdf', 10485760);
  });

  test('without the owner\'s vault consent nothing new goes into the vault', async () => {
    await withoutVaultConsent(async () => {
      await expectPgError(probeAsUser(ids.owner, (db) => db.query(
        'select * from public.vault_create_document($1, $2, $3, $4, $5)', [ids.patient, 'lab_report', 'x', png.type, png.size])));
      await expectPgError(probeAsUser(ids.owner, (db) => db.query(
        `insert into public.vitals (patient_id, kind, value) values ($1, 'bp', '{}')`, [ids.patient])));
      await expectPgError(probeAsUser(ids.owner, (db) => db.query(
        `insert into public.medicines (patient_id, name) values ($1, 'Synthetic Medicine B')`, [ids.patient])));
    });
    // With consent again, writes work.
    await probeAsUser(ids.owner, (db) => db.query(
      `insert into public.vitals (patient_id, kind, value) values ($1, 'bp', '{}')`, [ids.patient]));
  });
});

describe('upload confirmation', () => {
  test('editors get the pending path; only the service role marks it uploaded, once', async () => {
    const doc = await createDoc(ids.owner);
    const [{ path }] = await probeAsUser(ids.owner, (db) =>
      db.query<{ path: string }>('select public.vault_upload_target($1) as path', [doc.document_id]));
    assert.equal(path, doc.storage_path);
    for (const user of [ids.viewer, ids.asha, ids.ops]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select public.vault_upload_target($1)', [doc.document_id])));
    }
    await expectPgError(probeAsUser(ids.owner, (db) => db.query('select public.vault_mark_uploaded($1, 10)', [doc.document_id])));
    await asServiceRole((db) => db.query('select public.vault_mark_uploaded($1, 2000)', [doc.document_id]));
    await expectPgError(asServiceRole((db) => db.query('select public.vault_mark_uploaded($1, 2000)', [doc.document_id])), '22023');
    await expectPgError(probeAsUser(ids.owner, (db) => db.query('select public.vault_upload_target($1)', [doc.document_id])), '22023');
  });
});

describe('downloading vault documents', () => {
  test('family members get the path, and each request is an audited vault read', async () => {
    const doc = await createDoc(ids.owner);
    await asServiceRole((db) => db.query('select public.vault_mark_uploaded($1, 2048)', [doc.document_id]));
    for (const user of [ids.owner, ids.viewer]) {
      const before = await auditCount('vault_read');
      const [row] = await asUser(user, (db) => db.query<{ storage_path: string; content_type: string; url_seconds: number }>(
        'select * from public.vault_document_download($1, $2)', [doc.document_id, 'view report']));
      assert.deepEqual(row, { storage_path: doc.storage_path, content_type: 'image/png', url_seconds: 60 });
      assert.equal(await auditCount('vault_read'), before + 1);
    }
  });

  test('companions are denied; ops need the owner\'s ops consent; unknown ids look forbidden', async () => {
    const doc = await createDoc(ids.owner);
    await asServiceRole((db) => db.query('select public.vault_mark_uploaded($1, 2048)', [doc.document_id]));
    const download = (user: string, id = doc.document_id) =>
      asUser(user, (db) => db.query('select * from public.vault_document_download($1)', [id]));
    await expectPgError(download(ids.asha));
    await expectPgError(download(ids.ops));
    await asUser(ids.owner, (db) => db.query(`select public.set_consent($1, 'ops_vault_access', true)`, [ids.patient]));
    try {
      const rows = await download(ids.ops);
      assert.equal(rows.length, 1);
    } finally {
      await asUser(ids.owner, (db) => db.query(`select public.set_consent($1, 'ops_vault_access', false)`, [ids.patient]));
    }
    await expectPgError(download(ids.ops));
    await expectPgError(download(ids.owner, '00000000-0000-0000-0000-00000000beef'));
  });

  test('a document still waiting for its file cannot be downloaded', async () => {
    const doc = await createDoc(ids.owner);
    await expectPgError(asUser(ids.owner, (db) => db.query('select * from public.vault_document_download($1)', [doc.document_id])), '22023');
  });
});

describe('consents', () => {
  test('the owner sees every purpose and can change them; changes are audited', async () => {
    const rows = await probeAsUser(ids.owner, (db) => db.query('select * from public.family_consents($1)', [ids.patient]));
    assert.deepEqual(rows.map((r) => [r.purpose, r.active, r.can_change]), [
      ['trips', true, true], ['vault', true, true], ['ops_vault_access', false, true],
    ]);
    const before = await auditCount('insert');
    const [{ active }] = await asUser(ids.owner, (db) => db.query<{ active: boolean }>(
      `select public.set_consent($1, 'ops_vault_access', true) as active`, [ids.patient]));
    assert.equal(active, true);
    // Giving it twice does not add a second active row.
    await asUser(ids.owner, (db) => db.query(`select public.set_consent($1, 'ops_vault_access', true)`, [ids.patient]));
    const [{ n }] = await asAdmin((db) => db.query<{ n: number }>(
      `select count(*)::int as n from public.consents
       where patient_id = $1 and user_id = $2 and purpose = 'ops_vault_access' and withdrawn_at is null`,
      [ids.patient, ids.owner]));
    assert.equal(n, 1);
    const [{ off }] = await asUser(ids.owner, (db) => db.query<{ off: boolean }>(
      `select public.set_consent($1, 'ops_vault_access', false) as off`, [ids.patient]));
    assert.equal(off, false);
    assert.ok(await auditCount('insert') > before, 'consent changes are audited by the consents trigger');
  });

  test('a viewer sees the status but cannot change it; strangers and companions see nothing', async () => {
    const rows = await probeAsUser(ids.viewer, (db) => db.query('select * from public.family_consents($1)', [ids.patient]));
    assert.ok(rows.every((r) => r.can_change === false));
    await expectPgError(probeAsUser(ids.viewer, (db) => db.query(`select public.set_consent($1, 'vault', false)`, [ids.patient])));
    for (const user of [ids.asha, ids.ops]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.family_consents($1)', [ids.patient])));
      await expectPgError(probeAsUser(user, (db) => db.query(`select public.set_consent($1, 'vault', true)`, [ids.patient])));
    }
  });
});
