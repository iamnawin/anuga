// Offline synthetic-only dry run. No DB connection, SQL execution or user mutation.
import { readFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';

type Account = { id: string; role: string; has_profile?: boolean; state?: string; authority_ref?: string };
type Input = { synthetic_only: boolean; accounts: Account[] };
export function classifyBackfill(inventory: Input, roster: Input) {
  const errors: string[] = [];
  if (inventory.synthetic_only !== true || roster.synthetic_only !== true) errors.push('synthetic_only=true required; no real-user classification');
  if (errors.length) return { ok: false, mode: 'refused: not synthetic', classifications: [] as {id: string; role: string | null; state: string | null; result: string}[], errors };
  const actual = new Map<string, Account>();
  const reviewed = new Map<string, Account>();
  for (const [label, rows, map] of [['inventory', inventory.accounts, actual], ['roster', roster.accounts, reviewed]] as const) {
    for (const row of rows) {
      if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(row.id) || map.has(row.id)) errors.push(label + ': invalid/duplicate UUID');
      if (!['family','companion','ops_admin'].includes(row.role)) errors.push(label + ': invalid role');
      map.set(row.id, row);
    }
  }
  const classifications = [...new Set([...actual.keys(), ...reviewed.keys()])].sort().map(id => {
    const user = actual.get(id), entry = reviewed.get(id);
    let result = 'matched';
    if (!user) result = 'missing_identity';
    else if (user.has_profile !== true) result = 'missing_profile';
    else if (!entry) result = 'unknown_identity';
    else if (entry.role !== user.role) result = 'role_mismatch';
    else if (!['pending','active','disabled'].includes(entry.state ?? '') || !entry.authority_ref?.startsWith('synthetic:')) result = 'invalid_classification';
    if (result !== 'matched') errors.push(id + ': ' + result);
    return { id, role: user?.role ?? null, state: entry?.state ?? null, result };
  });
  return { ok: errors.length === 0, mode: 'synthetic dry-run; provisional assumptions, not rollout approval', classifications, errors };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const [inventoryPath, rosterPath] = process.argv.slice(2);
  if (!inventoryPath || !rosterPath) throw new Error('Usage: node supabase/scripts/pilot-backfill.ts <synthetic-inventory.json> <synthetic-roster.json>');
  const result = classifyBackfill(JSON.parse(await readFile(inventoryPath, 'utf8')), JSON.parse(await readFile(rosterPath, 'utf8')));
  console.log(JSON.stringify(result, null, 2));
  if (!result.ok) process.exitCode = 1;
}
