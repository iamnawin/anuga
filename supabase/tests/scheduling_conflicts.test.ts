import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { asAdmin, asServiceRole, asUser, createTrip, createUser, expectPgError, ids, probeAsUser } from './support/db.ts';
import { connectActor, waitForLock } from './support/scheduling_concurrent.ts';

async function companion(): Promise<string> {
  const id = await createUser(randomUUID(), 'companion');
  await asAdmin((db) => db.query(`insert into public.companions
    (id,cluster_id,home_location,verification_status,training_completed)
    select $1,cluster_id,home_location,verification_status,training_completed
    from public.companions where id=$2`, [id, ids.asha]));
  return id;
}

const assign = (trip: string, id: string) => asUser(ids.ops, (db) =>
  db.query('select * from public.ops_assign_trip_companion($1,$2)', [trip, id]));
const start = (trip: string, id: string) => asUser(id, (db) =>
  db.query("select * from public.advance_trip($1,'companion_en_route')", [trip]));

async function schedule(primary: string | null = null): Promise<string> {
  const id = randomUUID();
  await asAdmin((db) => db.query(`insert into public.schedules
    (id,patient_id,package_id,days_of_week,pickup_time,session_minutes,timezone,starts_on,ends_on,primary_companion_id)
    select $1,patient_id,package_id,array[1,2,3,4,5,6,7]::smallint[],pickup_time,session_minutes,timezone,
      current_date+40,current_date+40,$2 from public.schedules where id=$3`, [id, primary, ids.schedule]));
  return id;
}

describe('pilot companion occupancy', () => {
  test('overlapping assignments fail, but adjacent pickup/return boundaries are allowed', async () => {
    const id = await companion();
    const first = await createTrip(2400, null);
    const overlap = await createTrip(2500, null);
    const adjacent = await createTrip(2700, null);
    // Give the adjacent visit the exact first return boundary, without clock drift.
    await asAdmin((db) => db.query(`update public.trips set
      scheduled_pickup_at=(select scheduled_return_at from public.trips where id=$2),
      scheduled_return_at=(select scheduled_return_at+interval '5 hours' from public.trips where id=$2)
      where id=$1`, [adjacent, first]));
    await assign(first, id);
    await expectPgError(assign(overlap, id), '22023');
    assert.equal((await assign(adjacent, id))[0].companion_id, id);
  });

  test('late actual completion extends the occupied interval', async () => {
    const id = await companion();
    const first = await createTrip(-600, id);
    const overlap = await createTrip(-100, null);
    const after = await createTrip(20, null);
    await asAdmin((db) => db.query("update public.trips set status='completed',completed_at=now()-interval '10 minutes' where id=$1", [first]));
    await expectPgError(assign(overlap, id), '22023');
    assert.equal((await assign(after, id))[0].companion_id, id);
  });

  test('an unfinished overrun blocks assignment until completion; completion is never rejected', async () => {
    const id = await companion();
    const first = await createTrip(-600, id);
    const next = await createTrip(20, null);
    await asAdmin((db) => db.query("update public.trips set status='dropped_home' where id=$1", [first]));
    await expectPgError(assign(next, id), '22023');
    const [done] = await asUser(id, (db) => db.query("select * from public.advance_trip($1,'completed','Synthetic completion')", [first]));
    assert.equal(done.status, 'completed');
    assert.equal((await assign(next, id))[0].companion_id, id);
  });

  test('a second preassigned visit cannot start while a visit is underway or in an issue', async () => {
    const id = await companion();
    const first = await createTrip(25, id);
    const next = await createTrip(26, id);
    await start(first, id);
    await expectPgError(start(next, id), '22023');
    await asUser(id, (db) => db.query("select * from public.advance_trip($1,'issue_reported','Synthetic issue')", [first]));
    await expectPgError(start(next, id), '22023');
    await asUser(ids.ops, (db) => db.query("select * from public.advance_trip($1,'cancelled','Synthetic continuity handled')", [first]));
    assert.equal((await start(next, id))[0].status, 'companion_en_route');
  });

  test('routine reassignment remains denied at every started stage and for issue_reported', async () => {
    const id = await companion();
    const backup = await companion();
    const trip = await createTrip(25, id);
    for (const status of ['companion_en_route', 'picked_up', 'at_centre', 'handed_over', 'session_done', 'returning', 'dropped_home', 'issue_reported']) {
      await asAdmin((db) => db.query('update public.trips set status=$2::public.trip_status where id=$1', [trip, status]));
      await expectPgError(assign(trip, backup), '22023');
      await expectPgError(asServiceRole((db) => db.query('update public.trips set companion_id=null where id=$1', [trip])), '22023');
    }
  });

  test('service-role inserts cannot bypass overlapping assignment enforcement', async () => {
    const id = await companion();
    const first = await createTrip(2400, null);
    await assign(first, id);
    await expectPgError(asServiceRole((db) => db.query(`insert into public.trips
      (patient_id,centre_id,companion_id,scheduled_pickup_at,scheduled_return_at)
      select patient_id,centre_id,companion_id,scheduled_pickup_at,scheduled_return_at from public.trips where id=$1`, [first])), '22023');
  });

  test('non-Ops cannot assign a conflict-free trip', async () => {
    const id = await companion();
    const trip = await createTrip(2400, null);
    for (const user of [ids.owner, ids.viewer, id]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select public.ops_assign_trip_companion($1,$2)', [trip, id])));
    }
  });

  test('recurring generation is idempotent and a conflicting schedule rolls back its insert', async () => {
    const id = await companion();
    const first = await schedule(id);
    const conflict = await schedule(id);
    const generate = (scheduleId: string) => asUser(ids.ops, (db) => db.query<{ count: number }>(
      'select public.ops_generate_trips($1,current_date+40,1) as count', [scheduleId]));
    assert.equal((await generate(first))[0].count, 1);
    assert.equal((await generate(first))[0].count, 0);
    await expectPgError(generate(conflict), '22023');
    const [row] = await asAdmin((db) => db.query<{ count: number }>(
      'select count(*)::integer as count from public.trips where schedule_id=$1', [conflict]));
    assert.equal(row.count, 0);
  });

  test('recurring generation also detects an overlapping standalone visit', async () => {
    const id = await companion();
    const scheduleId = await schedule(id);
    await asAdmin((db) => db.query(`insert into public.trips
      (patient_id,centre_id,companion_id,scheduled_pickup_at,scheduled_return_at)
      select s.patient_id,p.centre_id,s.primary_companion_id,
        (s.starts_on+s.pickup_time) at time zone s.timezone,
        ((s.starts_on+s.pickup_time) at time zone s.timezone)+make_interval(mins=>s.session_minutes)
      from public.schedules s join public.patients p on p.id=s.patient_id where s.id=$1`, [scheduleId]));
    await expectPgError(asUser(ids.ops, (db) => db.query(
      'select public.ops_generate_trips($1,current_date+40,1)', [scheduleId])), '22023');
  });

  test('bulk recurring reassignment rolls back schedule and every moved trip on conflict', async () => {
    const id = await companion();
    const backup = await companion();
    const scheduleId = await schedule();
    const first = await createTrip(2400, null);
    const second = await createTrip(2500, null);
    await asAdmin((db) => db.query('update public.trips set schedule_id=$1 where id=any($2::uuid[])', [scheduleId, [first, second]]));
    await expectPgError(asUser(ids.ops, (db) => db.query(
      'select public.ops_assign_schedule_companions($1,$2,$3)', [scheduleId, id, backup])), '22023');
    const [row] = await asAdmin((db) => db.query('select primary_companion_id,backup_companion_id from public.schedules where id=$1', [scheduleId]));
    assert.equal(row.primary_companion_id, null);
    assert.equal(row.backup_companion_id, null);
    const trips = await asAdmin((db) => db.query('select companion_id from public.trips where schedule_id=$1', [scheduleId]));
    assert.equal(trips.length, 2);
    assert.ok(trips.every((trip) => trip.companion_id === null));
  });

  test('concurrent overlapping assignments serialize; the losing request observes the conflict', { skip: !process.env.DATABASE_URL }, async () => {
    const id = await companion();
    const first = await createTrip(2400, null);
    const second = await createTrip(2401, null);
    const a = await connectActor(ids.ops);
    const b = await connectActor(ids.ops);
    let pending: Promise<void> | undefined;
    try {
      await a.query('select public.ops_assign_trip_companion($1,$2)', [first, id]);
      const { rows: [{ pid }] } = await b.query('select pg_backend_pid() as pid');
      pending = expectPgError(b.query('select public.ops_assign_trip_companion($1,$2)', [second, id]), '22023');
      void pending.catch(() => {});
      await waitForLock(a, pid);
      await a.query('commit');
      await pending;
    } finally {
      await a.query('rollback');
      await b.query('rollback');
      await a.end();
      await b.end();
    }
    const [row] = await asAdmin((db) => db.query('select companion_id from public.trips where id=$1', [second]));
    assert.equal(row.companion_id, null);
  });

  test('concurrent starts cannot begin two preassigned visits', { skip: !process.env.DATABASE_URL }, async () => {
    const id = await companion();
    const first = await createTrip(25, id);
    const second = await createTrip(26, id);
    const a = await connectActor(id);
    const b = await connectActor(id);
    let pending: Promise<void> | undefined;
    try {
      await a.query("select public.advance_trip($1,'companion_en_route')", [first]);
      const { rows: [{ pid }] } = await b.query('select pg_backend_pid() as pid');
      pending = expectPgError(b.query("select public.advance_trip($1,'companion_en_route')", [second]), '22023');
      void pending.catch(() => {});
      await waitForLock(a, pid);
      await a.query('commit');
      await pending;
    } finally {
      await a.query('rollback');
      await b.query('rollback');
      await a.end();
      await b.end();
    }
    const [row] = await asAdmin((db) => db.query('select status from public.trips where id=$1', [second]));
    assert.equal(row.status, 'scheduled');
  });
});
