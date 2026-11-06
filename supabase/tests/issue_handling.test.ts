// Issue notes are operational data; Family receives persisted service status.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { asAdmin, asUser, createTrip, expectPgError, ids, probeAsAnon, probeAsUser } from './support/db.ts';
import { isolateCompanionAvailability } from './support/scheduling_fixtures.ts';

type QueueRow = { trip_id: string; status: string; status_before_issue: string | null; companion_id: string; last_note: string | null; since: string };

const serialize = (value: unknown) => JSON.stringify(value, (_key, item: unknown) => typeof item === 'bigint' ? String(item) : item);

const advance = (user: string, trip: string, state: string, note: string | null = null) =>
  asUser(user, (db) => db.query('select * from public.advance_trip($1,$2::public.trip_status,$3)', [trip, state, note]));
const queueRow = async (trip: string) => (await probeAsUser(ids.ops, (db) => db.query<QueueRow>(
  'select trip_id,status,status_before_issue,companion_id,last_note,since::text as since from public.ops_exception_queue() where trip_id=$1', [trip])))[0];
const resolve = (user: string, row: QueueRow, state: string, note: string | null = null) =>
  asUser(user, (db) => db.query('select * from public.ops_resolve_visit_issue($1,$2,$3::public.trip_status,$4)',
    [row.trip_id, row.since, state, note]));

async function familyReads(trip: string, user: string = ids.owner) {
  return probeAsUser(user, async (db) => ({
    timeline: await db.query('select * from public.family_trip_timeline($1)', [trip]),
    inbox: await db.query('select * from public.my_notifications() where trip_id=$1', [trip]),
    events: await db.query('select * from public.trip_events where trip_id=$1', [trip]),
    trip: await db.query('select * from public.trips where id=$1', [trip]),
    notifications: await db.query('select * from public.notifications where trip_id=$1', [trip]),
  }));
}

describe('visit issue handling', () => {
  isolateCompanionAvailability();
  test('Ops sees the required issue note and prior stage; every Family-readable path excludes it', async () => {
    const trip = await createTrip(25);
    await advance(ids.asha, trip, 'companion_en_route');
    await expectPgError(advance(ids.asha, trip, 'issue_reported', '  '), '22023');
    const marker = 'INTERNAL_ISSUE_dispatch_details_synthetic';
    const response = await advance(ids.asha, trip, 'issue_reported', marker);
    assert.equal(response[0].status, 'issue_reported');
    assert.ok(!serialize(response).includes(marker));
    const row = await queueRow(trip);
    assert.equal(row.status, 'issue_reported');
    assert.equal(row.status_before_issue, 'companion_en_route');
    assert.equal(row.companion_id, ids.asha);
    assert.equal(row.last_note, marker);
    for (const user of [ids.owner, ids.viewer]) {
      const visible = await familyReads(trip, user);
      assert.ok(!serialize(visible).includes(marker));
      assert.equal(visible.timeline.at(-1)?.to_status, 'issue_reported');
      assert.equal(visible.timeline.at(-1)?.note, null);
      assert.ok(visible.notifications.every((n) => (n.payload as { note: string | null }).note === null));
    }
    const [{ note }] = await asAdmin((db) => db.query<{ note: string }>(
      `select i.note from private.trip_event_internal_notes i join public.trip_events e on e.id=i.event_id
       where e.trip_id=$1`, [trip]));
    assert.equal(note, marker);
  });

  test('only guarded Ops reads can expose an internal issue note', async () => {
    const trip = await createTrip(25);
    await advance(ids.asha, trip, 'companion_en_route');
    await advance(ids.asha, trip, 'issue_reported', 'Internal operational note (synthetic)');
    for (const user of [ids.owner, ids.viewer, ids.asha, ids.ravi, ids.ops]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from private.trip_event_internal_notes')));
    }
    await expectPgError(probeAsAnon((db) => db.query('select * from private.trip_event_internal_notes')));
    for (const user of [ids.owner, ids.viewer, ids.asha, ids.ravi]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.ops_exception_queue()')));
    }
    assert.equal((await queueRow(trip)).last_note, 'Internal operational note (synthetic)');
  });

  test('explicit Ops resume preserves stage/assignment and keeps its resolution note internal', async () => {
    const trip = await createTrip(25);
    await advance(ids.asha, trip, 'companion_en_route');
    await advance(ids.asha, trip, 'issue_reported', 'Issue note (synthetic)');
    const row = await queueRow(trip);
    await expectPgError(advance(ids.asha, trip, 'companion_en_route'), '22023');
    await expectPgError(asUser(ids.ops, (db) => db.query('select public.ops_assign_trip_companion($1,$2)', [trip, ids.ravi])), '22023');
    const marker = 'INTERNAL_RESOLUTION_dispatch_discussion_synthetic';
    const response = await resolve(ids.ops, row, 'companion_en_route', marker);
    assert.equal(response[0].status, 'companion_en_route');
    assert.equal(response[0].companion_id, ids.asha);
    assert.ok(!serialize(response).includes(marker));
    assert.equal(await queueRow(trip), undefined);
    const visible = await familyReads(trip);
    assert.ok(!serialize(visible).includes(marker));
    assert.equal(visible.timeline.at(-1)?.to_status, 'companion_en_route');
    assert.equal(visible.timeline.at(-1)?.note, null);
    // Resuming an en-route issue must not bypass pickup verification.
    await expectPgError(advance(ids.asha, trip, 'picked_up'), '22023');
    const [{ code }] = await asUser(ids.owner, (db) => db.query<{ code: string }>('select public.issue_pickup_otp($1) as code', [trip]));
    const [{ result }] = await asUser(ids.asha, (db) => db.query<{ result: { ok: boolean } }>(
      'select public.verify_pickup_otp($1,$2) as result', [trip, code]));
    assert.equal(result.ok, true);
  });

  test('resolution denies non-Ops, arbitrary destination, stale resumed and newly reissued incidents', async () => {
    const trip = await createTrip(25);
    await advance(ids.asha, trip, 'companion_en_route');
    await advance(ids.asha, trip, 'issue_reported', 'First issue (synthetic)');
    const first = await queueRow(trip);
    for (const user of [ids.owner, ids.viewer, ids.asha, ids.ravi]) {
      await expectPgError(resolve(user, first, 'companion_en_route'));
    }
    await expectPgError(probeAsAnon((db) => db.query(
      "select public.ops_resolve_visit_issue($1,$2,'companion_en_route',null)", [trip, first.since])));
    await expectPgError(resolve(ids.ops, first, 'picked_up'), '22023');
    await expectPgError(resolve(ids.ops, first, 'completed'), '22023');
    await resolve(ids.ops, first, 'companion_en_route');
    await expectPgError(resolve(ids.ops, first, 'companion_en_route'), '22023');
    await advance(ids.asha, trip, 'issue_reported', 'Second issue (synthetic)');
    const second = await queueRow(trip);
    await expectPgError(resolve(ids.ops, first, 'cancelled'), '22023');
    assert.equal((await queueRow(trip)).last_note, 'Second issue (synthetic)');
    await resolve(ids.ops, second, 'companion_en_route');
  });

  test('resuming a picked-up issue preserves the original verified pickup time', async () => {
    const trip = await createTrip(25);
    await advance(ids.asha, trip, 'companion_en_route');
    const [{ code }] = await asUser(ids.owner, (db) => db.query<{ code: string }>(
      'select public.issue_pickup_otp($1) as code', [trip]));
    await asUser(ids.asha, (db) => db.query('select public.verify_pickup_otp($1,$2)', [trip, code]));
    const [before] = await probeAsUser(ids.ops, (db) => db.query(
      'select picked_up_at::text as picked_up_at, scheduled_pickup_at::text as scheduled_pickup_at, companion_id from public.trips where id=$1', [trip]));
    assert.ok(before.picked_up_at);
    await advance(ids.asha, trip, 'issue_reported', 'Transport delay after pickup (synthetic)');
    await resolve(ids.ops, await queueRow(trip), 'picked_up', 'Resume the same journey (synthetic)');
    const [after] = await probeAsUser(ids.ops, (db) => db.query(
      'select picked_up_at::text as picked_up_at, scheduled_pickup_at::text as scheduled_pickup_at, companion_id from public.trips where id=$1', [trip]));
    assert.deepEqual(after, before);
    // An incident resume is a new status event, not another verified pickup.
    const visible = await familyReads(trip);
    assert.equal(visible.timeline.at(-1)?.from_status, 'issue_reported');
    assert.equal(visible.timeline.at(-1)?.to_status, 'picked_up');
    await advance(ids.asha, trip, 'at_centre');
  });

  test('missing prior stage cannot invent a restart; explicit cancellation remains a separate supported action', async () => {
    const trip = await createTrip(25);
    await advance(ids.asha, trip, 'companion_en_route');
    await advance(ids.asha, trip, 'issue_reported', 'Missing-stage fixture (synthetic)');
    await asAdmin((db) => db.query('update public.trips set status_before_issue=null where id=$1', [trip]));
    const row = await queueRow(trip);
    await expectPgError(resolve(ids.ops, row, 'companion_en_route'), '22023');
    const [cancelled] = await resolve(ids.ops, row, 'cancelled', 'Internal cancellation context (synthetic)');
    assert.equal(cancelled.status, 'cancelled');
    assert.equal(cancelled.companion_id, ids.asha);
  });

  test('existing generic Ops completion cannot copy an internal note into a public trip or notification', async () => {
    const trip = await createTrip(25);
    await advance(ids.asha, trip, 'companion_en_route');
    await advance(ids.asha, trip, 'issue_reported', 'Issue before Ops completion (synthetic)');
    const marker = 'INTERNAL_OPS_COMPLETION_synthetic';
    // The broad pre-existing RPC remains unchanged; this UI does not offer this skip.
    const response = await advance(ids.ops, trip, 'completed', marker);
    assert.equal(response[0].status, 'completed');
    assert.equal(response[0].post_visit_note, null);
    assert.ok(!serialize(await familyReads(trip)).includes(marker));
  });

  test('companion handover and required completion notes remain Family-facing', async () => {
    const trip = await createTrip(25);
    await advance(ids.asha, trip, 'companion_en_route');
    const [{ code }] = await asUser(ids.owner, (db) => db.query<{ code: string }>('select public.issue_pickup_otp($1) as code', [trip]));
    await asUser(ids.asha, (db) => db.query('select public.verify_pickup_otp($1,$2)', [trip, code]));
    await advance(ids.asha, trip, 'at_centre');
    await advance(ids.asha, trip, 'handed_over', 'Public handover note (synthetic)');
    for (const state of ['session_done', 'returning', 'dropped_home']) await advance(ids.asha, trip, state);
    await expectPgError(advance(ids.asha, trip, 'completed', ''), '22023');
    await advance(ids.asha, trip, 'completed', 'Public completion note (synthetic)');
    const visible = await familyReads(trip);
    assert.ok(serialize(visible).includes('Public handover note (synthetic)'));
    assert.equal(visible.trip[0].post_visit_note, 'Public completion note (synthetic)');
    assert.equal(visible.timeline.at(-1)?.note, 'Public completion note (synthetic)');
  });

  test('historical redaction preserves event IDs, active state, assignment, times and notification bookkeeping on rerun', async () => {
    const trip = await createTrip(25);
    const completed = await createTrip(26);
    const marker = 'INTERNAL_HISTORICAL_synthetic';
    const marker2 = 'INTERNAL_HISTORICAL_OPS_COMPLETE_synthetic';
    const [event] = await asAdmin((db) => db.query<{ id: string }>(
      `insert into public.trip_events (trip_id,from_status,to_status,actor_kind,note)
       values ($1,'picked_up','issue_reported','companion',$2) returning id`, [trip, marker]));
    await asAdmin((db) => db.query("update public.trips set status='issue_reported',status_before_issue='picked_up' where id=$1", [trip]));
    await asAdmin((db) => db.query(`insert into public.notifications (trip_id,recipient_id,channel,template,payload,status,attempts)
      values ($1,$2,'push','trip_status_changed',jsonb_build_object('from_status','picked_up','to_status','issue_reported','note',$3::text),'pending',2)`,
    [trip, ids.owner, marker]));
    await asAdmin((db) => db.query(`insert into public.trip_events (trip_id,from_status,to_status,actor_kind,note)
      values ($1,'issue_reported','completed','ops',$2)`, [completed, marker2]));
    await asAdmin((db) => db.query("update public.trips set status='completed',post_visit_note=$2 where id=$1", [completed, marker2]));
    const before = await probeAsUser(ids.ops, (db) => db.query('select to_jsonb(t) as row from public.trips t where id=$1', [trip]));
    const beforeEvent = await asAdmin((db) => db.query('select id,created_at from public.trip_events where id=$1', [event.id]));
    const sql = await readFile(new URL('../migrations/20261103000100_private_visit_issue_notes.sql', import.meta.url), 'utf8');
    await asAdmin((db) => db.exec(sql));
    await asAdmin((db) => db.exec(sql));
    // Restore subsequent function definitions after replaying this historical migration.
    const followup = await readFile(new URL('../migrations/20261104000100_preserve_issue_pickup_time.sql', import.meta.url), 'utf8');
    await asAdmin((db) => db.exec(followup));
    assert.deepEqual(await probeAsUser(ids.ops, (db) => db.query('select to_jsonb(t) as row from public.trips t where id=$1', [trip])), before);
    assert.deepEqual(await asAdmin((db) => db.query('select id,created_at from public.trip_events where id=$1', [event.id])), beforeEvent);
    assert.ok(!serialize(await familyReads(trip)).includes(marker));
    assert.ok(!serialize(await familyReads(completed)).includes(marker2));
    assert.equal((await queueRow(trip)).last_note, marker);
    const [notice] = await probeAsUser(ids.owner, (db) => db.query('select status,attempts from public.notifications where trip_id=$1', [trip]));
    assert.deepEqual(notice, { status: 'pending', attempts: 2 });
    const [{ count }] = await asAdmin((db) => db.query<{ count: number }>(
      'select count(*)::integer as count from private.trip_event_internal_notes where event_id=$1', [event.id]));
    assert.equal(count, 1);
  });
});
