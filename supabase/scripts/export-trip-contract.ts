// Regenerates packages/shared_dart/test/fixtures/trip_contract.json from the migrations.
// Run after changing trip statuses or transitions: pnpm contract:export
import { writeFile } from 'node:fs/promises';
import { getDb } from '../tests/support/db.ts';
import { contractPath, readContractFromDb } from '../tests/support/contract.ts';

const contract = await readContractFromDb(await getDb());
await writeFile(contractPath, JSON.stringify(contract, null, 2) + '\n');
process.stdout.write(`wrote ${contract.transitions.length} transitions to ${contractPath.pathname}\n`);
