import { after, afterEach, before, beforeEach } from 'node:test';
import { asAdmin } from './db.ts';

// Independent SQL cases share one seed/database but must not share Companion
// availability. Temporarily detach pre-existing fixture assignments and restore
// those exact IDs afterwards. New trips and every assertion still use genuine
// RPC/trigger enforcement. A chained journey isolates once around its whole suite.
export function isolateCompanionAvailability(chained = false) {
  let previous: { id: string; companion_id: string }[] = [];
  const enter = async () => {
    previous = await asAdmin((db) => db.query<{ id: string; companion_id: string }>(
      'select id,companion_id from public.trips where companion_id is not null'));
    if (previous.length) await asAdmin((db) => db.query(
      'update public.trips set companion_id=null where id=any($1::uuid[])', [previous.map((row) => row.id)]));
  };
  const leave = async () => {
    if (previous.length) await asAdmin((db) => db.query(`update public.trips t set companion_id=p.companion_id
      from jsonb_to_recordset($1::jsonb) as p(id uuid,companion_id uuid) where t.id=p.id`, [JSON.stringify(previous)]));
    previous = [];
  };
  (chained ? before : beforeEach)(enter);
  (chained ? after : afterEach)(leave);
}
