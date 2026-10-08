'use client';

import { createContext, useCallback, useContext, useEffect, useState, type ReactNode } from 'react';
import type { Session } from '@supabase/supabase-js';
import { getSupabase } from '@/lib/supabase';

// 'notOps': signed in, but the profile role is not ops_admin. The console then
// shows nothing; the database would refuse every ops RPC anyway.
export type AuthStatus = 'loading' | 'signedOut' | 'notOps' | 'ops';

interface Auth {
  status: AuthStatus;
  userName: string | null;
  signOut(): Promise<void>;
}

const AuthContext = createContext<Auth | null>(null);

async function resolveRole(session: Session | null): Promise<{ status: AuthStatus; userName: string | null }> {
  if (!session) return { status: 'signedOut', userName: null };
  const { data, error } = await getSupabase()
    .from('profiles').select('role, full_name').eq('id', session.user.id).maybeSingle();
  if (error || !data) return { status: 'notOps', userName: null };
  return { status: data.role === 'ops_admin' ? 'ops' : 'notOps', userName: data.full_name as string };
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<{ status: AuthStatus; userName: string | null }>({
    status: 'loading', userName: null,
  });

  useEffect(() => {
    const supabase = getSupabase();
    let cancelled = false;
    const update = (session: Session | null) => {
      resolveRole(session).then((next) => {
        if (!cancelled) setState(next);
      });
    };
    supabase.auth.getSession().then(({ data }) => update(data.session));
    const { data: listener } = supabase.auth.onAuthStateChange((event, session) => {
      // Defer the profile query: Supabase recommends not awaiting inside this callback.
      if (event !== 'INITIAL_SESSION') setTimeout(() => update(session), 0);
    });
    return () => {
      cancelled = true;
      listener.subscription.unsubscribe();
    };
  }, []);

  const signOut = useCallback(async () => {
    await getSupabase().auth.signOut();
    setState({ status: 'signedOut', userName: null });
  }, []);

  return <AuthContext.Provider value={{ ...state, signOut }}>{children}</AuthContext.Provider>;
}

export function useAuth(): Auth {
  const value = useContext(AuthContext);
  if (!value) throw new Error('useAuth must be used inside AuthProvider');
  return value;
}
