import { createOpsApi, DbError, opsActionsFor, type PgResult, type RpcClient, type Transition } from '@/lib/api';

function fakeClient(result: PgResult<unknown>) {
  const calls: { fn: string; args?: Record<string, unknown> }[] = [];
  const client: RpcClient = {
    rpc: (fn, args) => {
      calls.push({ fn, args });
      return Promise.resolve(result);
    },
    from: (table) => ({
      select: (columns) => ({
        eq: (column, value) => {
          calls.push({ fn: `from:${table}`, args: { columns, column, value } });
          return Promise.resolve(result);
        },
      }),
    }),
  };
  return { client, calls };
}

describe('createOpsApi', () => {
  test('maps arguments to the RPC parameter names', async () => {
    const { client, calls } = fakeClient({ data: [], error: null });
    const api = createOpsApi(client);
    await api.tripBoard(new Date('2026-10-07T18:30:00Z'), new Date('2026-10-14T18:29:59Z'), ['scheduled']);
    await api.tripBoard(new Date('2026-10-07T18:30:00Z'), new Date('2026-10-14T18:29:59Z'), []);
    await api.assignTripCompanion('trip-1', 'ravi');
    await api.assignScheduleCompanions('sched-1', 'asha', 'ravi');
    await api.advanceTrip('trip-1', 'cancelled', 'note');
    await api.opsTransitions();
    await api.createScheduleTrips('sched-1');
    expect(calls).toEqual([
      { fn: 'ops_trip_board', args: { p_from: '2026-10-07T18:30:00.000Z', p_to: '2026-10-14T18:29:59.000Z', p_statuses: ['scheduled'] } },
      { fn: 'ops_trip_board', args: { p_from: '2026-10-07T18:30:00.000Z', p_to: '2026-10-14T18:29:59.000Z', p_statuses: null } },
      { fn: 'ops_assign_trip_companion', args: { p_trip_id: 'trip-1', p_companion_id: 'ravi' } },
      { fn: 'ops_assign_schedule_companions', args: { p_schedule_id: 'sched-1', p_primary_id: 'asha', p_backup_id: 'ravi' } },
      { fn: 'advance_trip', args: { p_trip_id: 'trip-1', p_to_status: 'cancelled', p_note: 'note' } },
      { fn: 'from:trip_transitions', args: { columns: 'from_status,to_status,actor,requires_otp', column: 'actor', value: 'ops' } },
      { fn: 'ops_create_schedule_trips', args: { p_schedule_id: 'sched-1' } },
    ]);
  });

  test('turns database errors into DbError with code and hint', async () => {
    const { client } = fakeClient({ data: null, error: { code: 'P0001', message: 'not eligible', hint: 'radius' } });
    const error = await createOpsApi(client).assignTripCompanion('t', 'far').catch((e: unknown) => e);
    expect(error).toBeInstanceOf(DbError);
    expect(error).toMatchObject({ code: 'P0001', message: 'not eligible', hint: 'radius' });
  });
});

describe('opsActionsFor', () => {
  const rules: Transition[] = [
    { from_status: 'issue_reported', to_status: 'cancelled', actor: 'ops', requires_otp: false },
    { from_status: 'issue_reported', to_status: 'companion_en_route', actor: 'ops', requires_otp: false },
    { from_status: 'companion_en_route', to_status: 'picked_up', actor: 'ops', requires_otp: true },
    { from_status: 'scheduled', to_status: 'cancelled', actor: 'family', requires_otp: false },
  ];

  test('offers only ops transitions from the current status', () => {
    expect(opsActionsFor('issue_reported', rules)).toEqual(['cancelled', 'companion_en_route']);
    expect(opsActionsFor('scheduled', rules)).toEqual([]);
  });

  test('never offers a step that needs the pickup OTP', () => {
    expect(opsActionsFor('companion_en_route', rules)).toEqual([]);
  });
});
