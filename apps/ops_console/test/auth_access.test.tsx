import { act, fireEvent, render, screen, waitFor } from '@testing-library/react';
import { AuthProvider, useAuth } from '@/components/AuthProvider';

const fake = vi.hoisted(() => ({
  session: { user: { id: 'ops' } } as { user: { id: string } } | null,
  row: { role: 'ops_admin', full_name: 'Synthetic Ops' } as Record<string, string> | null,
  error: null as object | null,
  state: 'active',
  profile: vi.fn(),
  listener: null as null | ((event: string, session: unknown) => void),
  query: vi.fn(),
}));
vi.mock('@/lib/supabase', () => ({ ACCESS_RECHECK_EVENT: 'anuga:access-recheck', getSupabase: () => ({
  auth: {
    getSession: async () => ({ data: { session: fake.session } }),
    onAuthStateChange: (cb: typeof fake.listener) => {
      fake.listener = cb;
      return { data: { subscription: { unsubscribe: vi.fn() } } };
    },
    signOut: async () => ({ error: null }),
  },
  rpc: fake.query,
  from: () => ({ select: () => ({ eq: () => ({ maybeSingle: fake.profile }) }) }),
}) }));
function Probe() {
  const auth = useAuth();
  return <><p>{auth.status}</p><button onClick={() => void auth.recheck()}>Recheck</button></>;
}
beforeEach(() => {
  fake.session = { user: { id: 'ops' } };
  fake.row = { role: 'ops_admin', full_name: 'Synthetic Ops' };
  fake.error = null;
  fake.state = 'active';
  fake.profile.mockReset().mockImplementation(async () => ({data: fake.row, error: null}));
  fake.query.mockReset().mockImplementation(async () => ({ data: {state: fake.row ? fake.state : 'unconfirmed', role: fake.state === 'active' ? fake.row?.role ?? null : null}, error: fake.error }));
});
test.each([
  ['ops_admin', 'ops'], ['family', 'notOps'], ['companion', 'notOps'], [null, 'unconfirmed'],
])('restored %s resolves to %s', async (role, status) => {
  fake.row = role ? { role, full_name: 'Synthetic' } : null;
  render(<AuthProvider><Probe /></AuthProvider>);
  await screen.findByText(status);
});
test('lookup failure is retryable, not a wrong-role denial', async () => {
  fake.error = { message: 'network' };
  render(<AuthProvider><Probe /></AuthProvider>);
  await screen.findByText('error');
  fake.error = null;
  fireEvent.click(screen.getByText('Recheck'));
  await screen.findByText('ops');
});
test('a late profile result cannot restore access after sign out', async () => {
  let finish!: (value: unknown) => void;
  fake.query.mockReturnValueOnce(new Promise((resolve) => { finish = resolve; }));
  render(<AuthProvider><Probe /></AuthProvider>);
  await waitFor(() => expect(fake.query).toHaveBeenCalled());
  await act(async () => { fake.listener!('SIGNED_OUT', null); });
  await screen.findByText('signedOut');
  await act(async () => { finish({ data: {state:'active',role:'ops_admin'}, error: null }); });
  expect(screen.queryByText('ops')).toBeNull();
});

test.each(['pending', 'disabled'])('authoritative %s never loads a protected profile', async (state) => {
  fake.state = state;
  render(<AuthProvider><Probe /></AuthProvider>);
  await screen.findByText(state);
  expect(fake.profile).not.toHaveBeenCalled();
  fake.state = 'active';
  fireEvent.click(screen.getByText('Recheck'));
  await screen.findByText('ops');
  fake.state = 'disabled';
  await act(async () => { window.dispatchEvent(new Event('anuga:access-recheck')); });
  await screen.findByText('disabled');
});
