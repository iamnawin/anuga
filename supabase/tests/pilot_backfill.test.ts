import assert from 'node:assert/strict';
import { test } from 'node:test';
import { classifyBackfill } from '../scripts/pilot-backfill.ts';

const id = '20000000-0000-0000-0000-000000000001';
const inventory = { synthetic_only: true, accounts: [{ id, role: 'family', has_profile: true }] };
const roster = { synthetic_only: true, accounts: [{ id, role: 'family', state: 'active', authority_ref: 'synthetic:local-assumption' }] };
test('dry run classifies exactly reviewed synthetic identities without changing its inputs', () => {
  const before = JSON.stringify({ inventory, roster });
  const result = classifyBackfill(inventory, roster);
  assert.equal(result.ok, true);
  assert.equal(result.classifications[0].state, 'active');
  assert.equal(JSON.stringify({ inventory, roster }), before);
});
test('unknown, missing, duplicate, role mismatch and missing profile all abort classification', () => {
  for (const accounts of [[], [...roster.accounts, ...roster.accounts], [{ ...roster.accounts[0], role: 'ops_admin' }],
    [{ ...roster.accounts[0], id: '20000000-0000-0000-0000-000000000002' }]]) {
    assert.equal(classifyBackfill(inventory, { ...roster, accounts }).ok, false);
  }
  assert.equal(classifyBackfill({ ...inventory, accounts: [{ ...inventory.accounts[0], has_profile: false }] }, roster).ok, false);
});
test('real/unlabelled inventories, invalid states and absent synthetic authority do not pass', () => {
  assert.equal(classifyBackfill({ ...inventory, synthetic_only: false }, roster).ok, false);
  for (const item of [{ ...roster.accounts[0], state: 'approved' }, { ...roster.accounts[0], authority_ref: '' }]) {
    assert.equal(classifyBackfill(inventory, { ...roster, accounts: [item] }).ok, false);
  }
});
