import { act, render, screen, waitFor } from '@testing-library/react';
import type { AuthChangeEvent, Session } from '@supabase/supabase-js';
import { AuthProvider, useAuth } from '@/components/AuthProvider';

const mock = vi.hoisted(() => ({ getSession: vi.fn(), maybeSingle: vi.fn(), callback: null as null | ((event: AuthChangeEvent, session: Session | null) => void) }));
vi.mock('@/lib/supabase', () => ({ getSupabase: () => ({
  auth: {
    getSession: mock.getSession,
    onAuthStateChange: (callback: typeof mock.callback) => {
      mock.callback = callback;
      return { data: { subscription: { unsubscribe: vi.fn() } } };
    },
    signOut: vi.fn().mockResolvedValue({ error: null }),
  },
  from: () => ({ select: () => ({ eq: () => ({ maybeSingle: mock.maybeSingle }) }) }),
}) }));

function pending<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>((done) => { resolve = done; });
  return { promise, resolve };
}
const session = { user: { id: 'synthetic-ops' } } as Session;
const ops = { data: { role: 'ops_admin', full_name: 'Old Ops' }, error: null };
function State() {
  const auth = useAuth();
  return <div data-testid="auth">{auth.status}:{auth.userName}</div>;
}
const mount = () => render(<AuthProvider><State /></AuthProvider>);

beforeEach(() => {
  mock.getSession.mockReset().mockResolvedValue({ data: { session } });
  mock.maybeSingle.mockReset().mockResolvedValue(ops);
  mock.callback = null;
});

test('a late role response cannot restore Ops after sign-out', async () => {
  const role = pending<typeof ops>();
  mock.maybeSingle.mockReturnValue(role.promise);
  mount();
  await waitFor(() => expect(mock.maybeSingle).toHaveBeenCalledOnce());
  await act(async () => { mock.callback?.('SIGNED_OUT', null); });
  await waitFor(() => expect(screen.getByTestId('auth').textContent).toBe('signedOut:'));
  await act(async () => { role.resolve(ops); });
  expect(screen.getByTestId('auth').textContent).toBe('signedOut:');
});

test('a stored-session response cannot supersede a newer sign-out event', async () => {
  const boot = pending<{ data: { session: Session } }>();
  mock.getSession.mockReturnValue(boot.promise);
  mount();
  await act(async () => { mock.callback?.('SIGNED_OUT', null); });
  await waitFor(() => expect(screen.getByTestId('auth').textContent).toBe('signedOut:'));
  await act(async () => { boot.resolve({ data: { session } }); });
  expect(screen.getByTestId('auth').textContent).toBe('signedOut:');
  expect(mock.maybeSingle).not.toHaveBeenCalled();
});

test('account switching clears the old name and ignores its delayed lookup', async () => {
  const old = pending<typeof ops>();
  const next = pending<typeof ops>();
  mock.maybeSingle.mockReturnValueOnce(old.promise).mockReturnValueOnce(next.promise);
  mount();
  await waitFor(() => expect(mock.maybeSingle).toHaveBeenCalledTimes(1));
  await act(async () => { mock.callback?.('SIGNED_IN', { user: { id: 'new-family' } } as Session); });
  expect(screen.getByTestId('auth').textContent).toBe('loading:');
  await waitFor(() => expect(mock.maybeSingle).toHaveBeenCalledTimes(2));
  await act(async () => { next.resolve({ data: { role: 'family', full_name: 'New Family' }, error: null }); });
  await act(async () => { old.resolve(ops); });
  expect(screen.getByTestId('auth').textContent).toBe('notOps:New Family');
});

test('a transport rejection during role resolution fails closed', async () => {
  mock.maybeSingle.mockRejectedValue(new Error('offline synthetic'));
  mount();
  await waitFor(() => expect(screen.getByTestId('auth').textContent).toBe('notOps:'));
});
