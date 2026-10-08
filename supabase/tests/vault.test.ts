// Vault: reads go only through audited functions; companions never get in;
// ops need the owner's active ops_vault_access consent.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, asUser, expectPgError, ids, probeAsUser } from './support/db.ts';

const vaultTables = ['vault_documents', 'vitals', 'medicines'] as const;
const vaultReaders = ['vault_list_documents', 'vault_list_vitals', 'vault_list_medicines'] as const;

async function vaultReadCount(): Promise<number> {
  const [{ n }] = await asAdmin((db) => db.query<{ n: number }>(
    `select count(*)::int as n from public.audit_log where action = 'vault_read' and patient_id = $1`, [ids.patient]));
  return n;
}

describe('vault tables', () => {
  test('no app role can SELECT vault tables directly (so no read escapes the audit)', async () => {
    for (const user of [ids.owner, ids.viewer, ids.asha, ids.ops]) {
      for (const table of vaultTables) {
        await expectPgError(probeAsUser(user, (db) => db.query(`select * from public.${table}`)));
      }
    }
  });

  test('owner can add a vitals entry and the write is audited', async () => {
    const before = await asAdmin((db) => db.query<{ n: number }>(`select count(*)::int as n from public.audit_log where table_name = 'vitals'`));
    await asUser(ids.owner, (db) => db.query(
      `insert into public.vitals (patient_id, kind, value) values ($1, 'bp', '{"systolic": 130, "diastolic": 85}')`,
      [ids.patient]));
    const after = await asAdmin((db) => db.query<{ n: number }>(`select count(*)::int as n from public.audit_log where table_name = 'vitals'`));
    assert.equal(after[0].n, before[0].n + 1);
  });

  test('viewers and companions cannot write to the vault', async () => {
    for (const user of [ids.viewer, ids.asha]) {
      await expectPgError(probeAsUser(user, (db) => db.query(
        `insert into public.vitals (patient_id, kind, value) values ($1, 'bp', '{}')`, [ids.patient])));
    }
  });
});

describe('audited vault reads', () => {
  test('family members read through the functions and each read is logged', async () => {
    for (const user of [ids.owner, ids.viewer]) {
      for (const fn of vaultReaders) {
        const before = await vaultReadCount();
        const rows = await asUser(user, (db) => db.query(`select * from public.${fn}($1, 'family view')`, [ids.patient]));
        assert.ok(rows.length > 0, `${fn} returned no rows`);
        assert.equal(await vaultReadCount(), before + 1, `${fn} by ${user} was not audited`);
      }
    }
    const [last] = await asAdmin((db) => db.query(
      `select actor_id, table_name, details from public.audit_log where action = 'vault_read' order by id desc limit 1`));
    assert.equal(last.actor_id, ids.viewer);
    assert.equal(last.table_name, 'medicines');
    assert.deepEqual(last.details, { basis: 'patient_access', purpose: 'family view' });
  });

  test('companions are denied and the denial leaves no data behind', async () => {
    for (const fn of vaultReaders) {
      await expectPgError(asUser(ids.asha, (db) => db.query(`select * from public.${fn}($1)`, [ids.patient])));
    }
  });

  test('ops are denied without consent, allowed with it, and denied again after withdrawal', async () => {
    await expectPgError(asUser(ids.ops, (db) => db.query('select * from public.vault_list_documents($1)', [ids.patient])));

    const [{ id: consentId }] = await asUser(ids.owner, (db) => db.query<{ id: string }>(
      `insert into public.consents (user_id, patient_id, purpose) values ($1, $2, 'ops_vault_access') returning id`,
      [ids.owner, ids.patient]));

    const before = await vaultReadCount();
    const docs = await asUser(ids.ops, (db) =>
      db.query('select * from public.vault_list_documents($1, $2)', [ids.patient, 'support ticket (synthetic)']));
    assert.equal(docs.length, 1);
    assert.equal(await vaultReadCount(), before + 1);
    const [entry] = await asAdmin((db) => db.query<{ actor_id: string; details: { basis: string } }>(
      `select actor_id, details from public.audit_log where action = 'vault_read' order by id desc limit 1`));
    assert.equal(entry.actor_id, ids.ops);
    assert.equal(entry.details.basis, 'ops_consent');

    await asUser(ids.owner, (db) => db.query('update public.consents set withdrawn_at = now() where id = $1', [consentId]));
    await expectPgError(asUser(ids.ops, (db) => db.query('select * from public.vault_list_documents($1)', [ids.patient])));
  });

  test('a consent given by a non-owner does not unlock ops access', async () => {
    await asUser(ids.viewer, (db) => db.query(
      `insert into public.consents (user_id, patient_id, purpose) values ($1, $2, 'ops_vault_access')`,
      [ids.viewer, ids.patient]));
    await expectPgError(asUser(ids.ops, (db) => db.query('select * from public.vault_list_vitals($1)', [ids.patient])));
  });

  test('the owner can review who read the vault; the viewer cannot', async () => {
    const owner = await probeAsUser(ids.owner, (db) =>
      db.query(`select 1 from public.audit_log where action = 'vault_read'`));
    assert.ok(owner.length > 0);
    const viewer = await probeAsUser(ids.viewer, (db) => db.query('select 1 from public.audit_log'));
    assert.equal(viewer.length, 0);
  });
});
