// The trip state-machine contract shared by SQL and Dart.
// Source of truth: public.trip_status, public.transition_actor and public.trip_transitions.
import type { Db } from './db.ts';

export const contractPath = new URL('../../../packages/shared_dart/test/fixtures/trip_contract.json', import.meta.url);

export interface TripContract {
  trip_status: string[];
  transition_actor: string[];
  transitions: { from: string; to: string; actor: string; requires_otp: boolean }[];
}

export async function readContractFromDb(db: Db): Promise<TripContract> {
  const statuses = await db.query<{ v: string }>(`select unnest(enum_range(null::public.trip_status))::text as v`);
  const actors = await db.query<{ v: string }>(`select unnest(enum_range(null::public.transition_actor))::text as v`);
  const transitions = await db.query<{ from: string; to: string; actor: string; requires_otp: boolean }>(
    `select from_status::text as "from", to_status::text as "to", actor::text as actor, requires_otp
     from public.trip_transitions order by actor, from_status, to_status`);
  return {
    trip_status: statuses.map((r) => r.v),
    transition_actor: actors.map((r) => r.v),
    transitions,
  };
}
