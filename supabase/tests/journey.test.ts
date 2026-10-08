// First working journey, end to end at the database layer. Each step is a
// separate committed "request" by the user who would make it in the apps:
// ops assigns -> family sees booking -> companion picks up (OTP) and hands over
// at the centre -> family receives status -> return journey completes.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, asUser, createTrip, expectPgError, ids, probeAsUser } from './support/db.ts';

type TripStatus = string;

async function advance(userId: string, tripId: string, to: TripStatus, note: string | null = null): Promise<TripStatus> {
  const [row] = await asUser(userId, (db) =>
    db.query<{ status: TripStatus }>('select status from public.advance_trip($1, $2::public.trip_status, $3)',
      [tripId, to, note]));
  return row.status;
}

async function familyStatusNotifications(tripId: string): Promise<TripStatus[]> {
  const rows = await probeAsUser(ids.owner, (db) => db.query<{ to_status: TripStatus }>(
    `select payload ->> 'to_status' as to_status from public.notifications
     where trip_id = $1 and template = 'trip_status_changed' and channel = 'whatsapp' order by id`, [tripId]));
  return rows.map((r) => r.to_status);
}

describe('first journey', () => {
  let tripId = '';
  let otp = '';

  test('ops assigns the trip to the backup companion because the primary is unavailable', async () => {
    tripId = await createTrip(45, null);
    const [trip] = await asUser(ids.ops, (db) =>
      db.query<{ companion_id: string }>('select companion_id from public.ops_assign_trip_companion($1, $2)',
        [tripId, ids.ravi]));
    assert.equal(trip.companion_id, ids.ravi);
    const companionNotice = await probeAsUser(ids.ravi, (db) =>
      db.query(`select 1 from public.notifications where trip_id = $1 and template = 'trip_assigned'`, [tripId]));
    assert.equal(companionNotice.length, 1);
  });

  test('family sees the booking with the assigned companion', async () => {
    const rows = await probeAsUser(ids.viewer, (db) =>
      db.query('select * from public.family_trip_board($1)', [ids.patient]));
    const booking = rows.find((r) => r.trip_id === tripId);
    assert.ok(booking);
    assert.equal(booking.status, 'scheduled');
    assert.equal(booking.companion_name, 'Ravi Companion (synthetic)');
    const notices = await probeAsUser(ids.viewer, (db) =>
      db.query(`select channel from public.notifications where trip_id = $1 and template = 'companion_changed'`, [tripId]));
    assert.deepEqual(notices.map((n) => n.channel).sort(), ['push', 'whatsapp']);
  });

  test('companion sets off and sees the restricted pickup sheet', async () => {
    assert.equal(await advance(ids.ravi, tripId, 'companion_en_route'), 'companion_en_route');
    const sheet = await probeAsUser(ids.ravi, (db) => db.query('select * from public.companion_my_trips()'));
    const trip = sheet.find((r) => r.trip_id === tripId);
    assert.equal(trip?.details_visible, true);
    assert.equal(trip?.home_address, '22 Sample Colony, Hyderabad (synthetic)');
  });

  test('companion cannot mark pickup without the OTP', async () => {
    await expectPgError(asUser(ids.ravi, (db) =>
      db.query(`select public.advance_trip($1, 'picked_up')`, [tripId])), '22023');
  });

  test('a viewer cannot issue the pickup OTP; the owner can', async () => {
    await expectPgError(asUser(ids.viewer, (db) => db.query('select public.issue_pickup_otp($1)', [tripId])));
    const [{ code }] = await asUser(ids.owner, (db) =>
      db.query<{ code: string }>('select public.issue_pickup_otp($1) as code', [tripId]));
    assert.match(code, /^\d{6}$/);
    otp = code;
  });

  test('a wrong code is rejected and the failed attempt is counted', async () => {
    const [{ result }] = await asUser(ids.ravi, (db) =>
      db.query<{ result: { ok: boolean; reason: string; attempts_left: number } }>(
        `select public.verify_pickup_otp($1, 'abcdef') as result`, [tripId]));
    assert.equal(result.ok, false);
    assert.equal(result.reason, 'wrong_code');
    const [{ attempts }] = await asAdmin((db) =>
      db.query<{ attempts: number }>('select attempts from public.trip_otps where trip_id = $1', [tripId]));
    assert.equal(attempts, 1);
  });

  test('another companion cannot use the code', async () => {
    await expectPgError(asUser(ids.asha, (db) => db.query('select public.verify_pickup_otp($1, $2)', [tripId, otp])));
  });

  test('the assigned companion verifies the OTP at pickup', async () => {
    const [{ result }] = await asUser(ids.ravi, (db) =>
      db.query<{ result: { ok: boolean; status: string } }>(
        'select public.verify_pickup_otp($1, $2, 17.495, 78.405) as result', [tripId, otp]));
    assert.deepEqual(result, { ok: true, status: 'picked_up' });
  });

  test('the same code cannot be reused', async () => {
    await expectPgError(asUser(ids.ravi, (db) => db.query('select public.verify_pickup_otp($1, $2)', [tripId, otp])),
      '22023');
  });

  test('companion reaches the centre and hands over to staff', async () => {
    assert.equal(await advance(ids.ravi, tripId, 'at_centre'), 'at_centre');
    assert.equal(await advance(ids.ravi, tripId, 'handed_over', 'Handed to front desk (synthetic staff)'), 'handed_over');
  });

  test('family cannot move the trip forward', async () => {
    await expectPgError(asUser(ids.owner, (db) =>
      db.query(`select public.advance_trip($1, 'session_done')`, [tripId])), '22023');
    await expectPgError(asUser(ids.viewer, (db) =>
      db.query(`select public.advance_trip($1, 'session_done')`, [tripId])));
  });

  test('return journey completes with a post-visit note', async () => {
    assert.equal(await advance(ids.ravi, tripId, 'session_done'), 'session_done');
    assert.equal(await advance(ids.ravi, tripId, 'returning'), 'returning');
    assert.equal(await advance(ids.ravi, tripId, 'dropped_home'), 'dropped_home');
    assert.equal(await advance(ids.ravi, tripId, 'completed', 'Session went well; report collected.'), 'completed');
    const [trip] = await probeAsUser(ids.owner, (db) =>
      db.query('select status, post_visit_note, picked_up_at, completed_at from public.trips where id = $1', [tripId]));
    assert.equal(trip.status, 'completed');
    assert.equal(trip.post_visit_note, 'Session went well; report collected.');
    assert.ok(trip.picked_up_at && trip.completed_at);
  });

  test('family received a status update for every step, in order', async () => {
    assert.deepEqual(await familyStatusNotifications(tripId), [
      'companion_en_route', 'picked_up', 'at_centre', 'handed_over',
      'session_done', 'returning', 'dropped_home', 'completed',
    ]);
    const viewerCopies = await probeAsUser(ids.viewer, (db) =>
      db.query(`select 1 from public.notifications where trip_id = $1 and template = 'trip_status_changed'`, [tripId]));
    assert.equal(viewerCopies.length, 16, 'viewer gets push + whatsapp for each of 8 steps');
  });

  test('the timeline is visible to family and records who acted', async () => {
    const events = await probeAsUser(ids.viewer, (db) => db.query<{ to_status: string; actor_kind: string }>(
      'select to_status, actor_kind from public.trip_events where trip_id = $1 order by id', [tripId]));
    assert.equal(events.length, 8);
    assert.ok(events.every((e) => e.actor_kind === 'companion'));
  });

  test('a completed trip cannot move again', async () => {
    await expectPgError(asUser(ids.ops, (db) =>
      db.query(`select public.advance_trip($1, 'cancelled')`, [tripId])), '22023');
  });
});

describe('exceptions', () => {
  test('family can cancel a scheduled trip but not one already under way', async () => {
    const scheduled = await createTrip(120);
    assert.equal(await advance(ids.owner, scheduled, 'cancelled', 'Admitted elsewhere'), 'cancelled');
    const underway = await createTrip(30);
    await advance(ids.asha, underway, 'companion_en_route');
    await expectPgError(asUser(ids.owner, (db) =>
      db.query(`select public.advance_trip($1, 'cancelled')`, [underway])), '22023');
  });

  test('companion reports an issue and ops resolves it back into the journey', async () => {
    const trip = await createTrip(20);
    await advance(ids.asha, trip, 'companion_en_route');
    assert.equal(await advance(ids.asha, trip, 'issue_reported', 'Auto broke down'), 'issue_reported');
    const [{ status_before_issue }] = await asAdmin((db) =>
      db.query('select status_before_issue from public.trips where id = $1', [trip]));
    assert.equal(status_before_issue, 'companion_en_route');
    await expectPgError(asUser(ids.asha, (db) =>
      db.query(`select public.advance_trip($1, 'companion_en_route')`, [trip])), '22023');
    assert.equal(await advance(ids.ops, trip, 'companion_en_route', 'Replacement cab booked'), 'companion_en_route');
  });

  test('an OTP locks after the configured number of wrong attempts', async () => {
    const trip = await createTrip(10);
    await advance(ids.asha, trip, 'companion_en_route');
    const [{ code }] = await asUser(ids.owner, (db) =>
      db.query<{ code: string }>('select public.issue_pickup_otp($1) as code', [trip]));
    for (let i = 0; i < 5; i++) {
      await asUser(ids.asha, (db) => db.query(`select public.verify_pickup_otp($1, 'zzzzzz')`, [trip]));
    }
    const [{ result }] = await asUser(ids.asha, (db) =>
      db.query<{ result: { ok: boolean; reason: string } }>('select public.verify_pickup_otp($1, $2) as result', [trip, code]));
    assert.deepEqual(result, { ok: false, reason: 'no_valid_code', attempts_left: 0 });
  });
});
