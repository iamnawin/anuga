import { act, fireEvent, render, screen, waitFor, within } from '@testing-library/react';
import type { ReactNode } from 'react';
import ExceptionsPage from '@/app/exceptions/page';
import { ApiProvider } from '@/components/ApiProvider';
import { I18nProvider } from '@/components/I18nProvider';
import { DbError, type ExceptionRow, type OpsApi, type Transition } from '@/lib/api';

vi.mock('@/components/OpsShell', () => ({ OpsShell: ({ children }: { children: ReactNode }) => children }));

const issue: ExceptionRow = {
  trip_id: 't1', kind: 'issue_reported', status: 'issue_reported', status_before_issue: 'picked_up',
  scheduled_pickup_at: '2026-11-03T10:30:00Z', patient_id: 'p1', patient_name: 'Lakshmi (synthetic)',
  centre_name: 'Centre 1', companion_id: 'asha', companion_name: 'Asha (synthetic)',
  backup_companion_id: 'ravi', backup_companion_name: 'Ravi (synthetic)',
  last_note: 'Internal problem marker', since: '2026-11-03T10:45:00Z',
};
const transitions: Transition[] = [
  { from_status: 'issue_reported', to_status: 'picked_up', actor: 'ops', requires_otp: false },
  { from_status: 'issue_reported', to_status: 'companion_en_route', actor: 'ops', requires_otp: false },
  { from_status: 'issue_reported', to_status: 'cancelled', actor: 'ops', requires_otp: false },
];
function apiFor(rows: ExceptionRow[] = [issue]): OpsApi {
  return {
    exceptionQueue: vi.fn().mockResolvedValue(rows), opsTransitions: vi.fn().mockResolvedValue(transitions),
    advanceTrip: vi.fn().mockResolvedValue(undefined), resolveVisitIssue: vi.fn().mockResolvedValue(undefined),
    assignTripCompanion: vi.fn(), companionOptions: vi.fn(),
  } as unknown as OpsApi;
}
function show(api: OpsApi) {
  return render(<I18nProvider><ApiProvider api={() => api}><ExceptionsPage /></ApiProvider></I18nProvider>);
}
const card = () => screen.getByText(issue.patient_name, { exact: false }).closest('li')!;
const deferred = <T,>() => {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>((done) => { resolve = done; });
  return { promise, resolve };
};

afterEach(() => vi.restoreAllMocks());

describe('Ops visit issue handling', () => {
  test('shows the persisted prior stage, assignment and private issue note without underway reassignment', async () => {
    const api = apiFor();
    show(api);
    await screen.findByText('Internal problem marker');
    expect(within(card()).getByText('Stage before issue')).toBeTruthy();
    expect(within(card()).getByText('Picked up', { exact: true })).toBeTruthy();
    expect(within(card()).getByText('Internal issue note')).toBeTruthy();
    expect(within(card()).getByText('Asha (synthetic)', { exact: true })).toBeTruthy();
    expect(within(card()).queryByRole('button', { name: /Assign|Reassign/ })).toBeNull();
    expect(within(card()).queryByRole('button', { name: 'Move to: Companion on the way' })).toBeNull();
  });

  test('explicitly confirms a resume at the stored stage and records the internal resolution note', async () => {
    const confirm = vi.spyOn(window, 'confirm').mockReturnValue(false);
    const api = apiFor();
    show(api);
    await screen.findByText('Internal problem marker');
    fireEvent.change(screen.getByLabelText('Resolution note (internal, optional)'), { target: { value: '  Transport arranged internally.  ' } });
    fireEvent.click(screen.getByRole('button', { name: 'Move to: Picked up' }));
    expect(confirm).toHaveBeenCalledWith(expect.stringContaining('Picked up'));
    expect(api.resolveVisitIssue).not.toHaveBeenCalled();
    confirm.mockReturnValue(true);
    vi.mocked(api.exceptionQueue).mockResolvedValue([]);
    fireEvent.click(screen.getByRole('button', { name: 'Move to: Picked up' }));
    await waitFor(() => expect(api.resolveVisitIssue).toHaveBeenCalledWith('t1', issue.since, 'picked_up', 'Transport arranged internally.'));
    await screen.findByText('Nothing needs attention.');
    expect(api.assignTripCompanion).not.toHaveBeenCalled();
  });

  test('missing prior stage is blocked instead of inventing a restart', async () => {
    show(apiFor([{ ...issue, status_before_issue: null }]));
    await screen.findByText('Internal problem marker');
    expect(screen.getByText('The previous stage is missing. Resume is blocked; review this visit with ops.')).toBeTruthy();
    expect(screen.queryByRole('button', { name: 'Move to: Companion on the way' })).toBeNull();
    expect(screen.queryByRole('button', { name: 'Move to: Picked up' })).toBeNull();
  });

  test('cancellation still requires explicit confirmation and uses the existing fallback note', async () => {
    const confirm = vi.spyOn(window, 'confirm').mockReturnValue(false);
    const api = apiFor();
    show(api);
    await screen.findByText('Internal problem marker');
    fireEvent.click(screen.getByRole('button', { name: 'Move to: Cancelled' }));
    expect(api.resolveVisitIssue).not.toHaveBeenCalled();
    confirm.mockReturnValue(true);
    vi.mocked(api.exceptionQueue).mockResolvedValue([]);
    fireEvent.click(screen.getByRole('button', { name: 'Move to: Cancelled' }));
    await waitFor(() => expect(api.resolveVisitIssue).toHaveBeenCalledWith('t1', issue.since, 'cancelled', 'Resolved by ops'));
  });

  test('failed refresh removes stale issue details and actions, then Refresh recovers', async () => {
    const api = apiFor();
    show(api);
    await screen.findByText('Internal problem marker');
    vi.mocked(api.exceptionQueue).mockRejectedValueOnce(new Error('offline'));
    fireEvent.click(screen.getByRole('button', { name: 'Refresh' }));
    await screen.findByRole('alert');
    expect(screen.queryByText('Internal problem marker')).toBeNull();
    expect(screen.queryByRole('button', { name: 'Move to: Picked up' })).toBeNull();
    fireEvent.click(screen.getByRole('button', { name: 'Refresh' }));
    await screen.findByText('Internal problem marker');
  });

  test('an older refresh cannot replace the latest persisted queue', async () => {
    const api = apiFor();
    show(api);
    await screen.findByText('Internal problem marker');
    const slow = deferred<ExceptionRow[]>();
    vi.mocked(api.exceptionQueue).mockImplementationOnce(() => slow.promise).mockResolvedValueOnce([]);
    fireEvent.click(screen.getByRole('button', { name: 'Refresh' }));
    expect(screen.queryByText('Internal problem marker')).toBeNull();
    fireEvent.click(screen.getByRole('button', { name: 'Refresh' }));
    await screen.findByText('Nothing needs attention.');
    await act(async () => slow.resolve([issue]));
    expect(screen.queryByText('Internal problem marker')).toBeNull();
  });

  test('a rejected mutation hides stale actions and does not replay on refresh', async () => {
    vi.spyOn(window, 'confirm').mockReturnValue(true);
    const api = apiFor();
    vi.mocked(api.resolveVisitIssue).mockRejectedValue(new DbError({ code: '42501', message: 'ops only' }));
    show(api);
    await screen.findByText('Internal problem marker');
    fireEvent.click(screen.getByRole('button', { name: 'Move to: Picked up' }));
    await screen.findByText('You are not allowed to do this.');
    expect(screen.queryByText('Internal problem marker')).toBeNull();
    fireEvent.click(screen.getByRole('button', { name: 'Refresh' }));
    await screen.findByText('Internal problem marker');
    expect(api.resolveVisitIssue).toHaveBeenCalledTimes(1);
  });
});
