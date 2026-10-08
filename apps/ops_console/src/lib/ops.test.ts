import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  assignTripCompanion, backupFor, describeDbError, exceptionKind, formatDays, istDayRange, istToday,
  normalizeIndianPhone, OpsError, toSchedule, toTrip, type OpsClient, type Trip,
} from './ops.ts';

test('normalizeIndianPhone accepts common Indian formats', () => {
  for (const input of ['9000000001', '09000000001', '+91 90000 00001', '919000000001']) {
    assert.equal(normalizeIndianPhone(input), '+919000000001', input);
  }
});

test('normalizeIndianPhone rejects non-mobile numbers', () => {
  for (const input of ['', '12345', '5000000001', '+1 415 212 7777', 'abc']) {
    assert.equal(normalizeIndianPhone(input), null, input);
  }
});

test('istDayRange covers one IST calendar day', () => {
  assert.deepEqual(istDayRange('2026-10-08'), {
    from: '2026-10-07T18:30:00.000Z',
    to: '2026-10-08T18:30:00.000Z',
  });
  assert.throws(() => istDayRange('8/10/2026'), RangeError);
});

test('istToday uses IST, not UTC', () => {
  assert.equal(istToday(new Date('2026-10-07T19:00:00Z')), '2026-10-08');
});

test('formatDays orders ISO weekdays', () => {
  assert.equal(formatDays([5, 1, 3]), 'Mon, Wed, Fri');
});

test('describeDbError shows eligibility errors with their hint', () => {
  assert.equal(
    describeDbError({ code: 'P0001', message: 'companion x is not eligible for patient y', hint: 'must be verified' }),
    'companion x is not eligible for patient y (must be verified)',
  );
  assert.equal(describeDbError({ code: '42501', message: 'ops only' }), 'Not allowed for this account.');
  assert.equal(describeDbError({ code: '22023', message: 'only scheduled trips can be reassigned' }),
    'only scheduled trips can be reassigned');
});

const now = new Date('2026-10-08T03:00:00Z');

test('exceptionKind: late, no-show and issue', () => {
  assert.equal(exceptionKind({ status: 'scheduled', scheduledPickupAt: '2026-10-08T01:30:00Z' }, now), 'late');
  assert.equal(exceptionKind({ status: 'scheduled', scheduledPickupAt: '2026-10-08T05:00:00Z' }, now), null);
  assert.equal(exceptionKind({ status: 'no_show', scheduledPickupAt: '2026-10-08T01:30:00Z' }, now), 'no_show');
  assert.equal(exceptionKind({ status: 'issue_reported', scheduledPickupAt: '2026-10-08T01:30:00Z' }, now), 'issue_reported');
  assert.equal(exceptionKind({ status: 'companion_en_route', scheduledPickupAt: '2026-10-08T01:30:00Z' }, now), null);
});

const trip: Trip = toTrip({
  id: 't1', status: 'scheduled', scheduled_pickup_at: '2026-10-08T01:30:00Z', scheduled_return_at: '2026-10-08T06:30:00Z',
  companion_id: 'asha', patient: { full_name: 'Lakshmi' }, centre: { name: 'Centre 1' },
  schedule: { primary_companion_id: 'asha', backup_companion_id: 'ravi' },
});

test('toTrip maps embedded rows', () => {
  assert.equal(trip.patientName, 'Lakshmi');
  assert.equal(trip.centreName, 'Centre 1');
  assert.equal(trip.backupCompanionId, 'ravi');
});

test('toTrip tolerates a trip without a schedule', () => {
  const adHoc = toTrip({ id: 't2', status: 'scheduled', companion_id: null, schedule: null, patient: null, centre: null });
  assert.equal(adHoc.backupCompanionId, null);
  assert.equal(backupFor(adHoc), null);
});

test('backupFor offers the backup only when it is not already on the trip', () => {
  assert.equal(backupFor(trip), 'ravi');
  assert.equal(backupFor({ ...trip, companionId: 'ravi' }), null);
});

test('toSchedule trims seconds from pickup time', () => {
  const s = toSchedule({ id: 's', days_of_week: [1, 3, 5], pickup_time: '07:00:00', active: true, patient: { full_name: 'L' } });
  assert.equal(s.pickupTime, '07:00');
});

function fakeClient(result: { data: unknown; error: { message: string; code?: string } | null }) {
  const calls: Array<[string, Record<string, unknown>]> = [];
  const client = {
    rpc: (fn: string, params: Record<string, unknown>) => { calls.push([fn, params]); return Promise.resolve(result); },
    from: () => { throw new Error('not used'); },
  } as unknown as OpsClient;
  return { client, calls };
}

test('assignTripCompanion calls the RPC with named parameters', async () => {
  const { client, calls } = fakeClient({ data: {}, error: null });
  await assignTripCompanion(client, 't1', 'ravi');
  assert.deepEqual(calls, [['ops_assign_trip_companion', { p_trip_id: 't1', p_companion_id: 'ravi' }]]);
});

test('assignTripCompanion surfaces the database refusal', async () => {
  const { client } = fakeClient({ data: null, error: { code: '42501', message: 'ops only' } });
  await assert.rejects(assignTripCompanion(client, 't1', 'ravi'), (e: unknown) =>
    e instanceof OpsError && e.code === '42501' && e.message === 'Not allowed for this account.');
});
