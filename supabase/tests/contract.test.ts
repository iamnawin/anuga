// Fails when the SQL state machine drifts from the committed contract that the
// Dart package is tested against. Fix by running `pnpm contract:export` and
// updating packages/shared_dart to match.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { asAdmin } from './support/db.ts';
import { contractPath, readContractFromDb, type TripContract } from './support/contract.ts';

test('trip_contract.json matches the database state machine', async () => {
  const committed = JSON.parse(await readFile(contractPath, 'utf8')) as TripContract;
  const actual = await asAdmin((db) => readContractFromDb(db));
  assert.deepEqual(committed, actual);
});
