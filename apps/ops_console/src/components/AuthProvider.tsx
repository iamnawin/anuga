'use client';

import { createContext, useCallback, useContext, useEffect, useRef, useState, type ReactNode } from 'react';
import type { Session } from '@supabase/supabase-js';
import { getSupabase, ACCESS_RECHECK_EVENT } from '@/lib/supabase';

// 'notOps': signed in, but the profile role is not ops_admin. The console then
// shows nothing; the database would refuse every ops RPC anyway.
export type AuthStatus = 'loading' | 'signedOut' | 'notOps' | 'unconfirmed' | 'pending' | 'disabled' | 'error' | 'ops';

interface Auth {
  status: AuthStatus;
  userName: string | null;
  signOut(): Promise<void>;
  recheck(): Promise<void>;
}

const AuthContext = createContext<Auth | null>(null);

async function resolveRole(session: Session | null): Promise<{ status: AuthStatus; userName: string | null }> {
  if (!session) return { status: 'signedOut', userName: null };
  const { data, error } = await getSupabase().rpc('my_account_access');
  if (error) return { status: 'error', userName: null };
  if (!data || !['active', 'pending', 'disabled', 'unconfirmed'].includes(data.state)) return { status: 'error', userName: null };
  if (data.state !== 'active') {
    if (data.role !== null) return { status: 'error', userName: null };
    return { status: data.state, userName: null };
  }
  if (!['family', 'companion', 'ops_admin'].includes(data.role)) return { status: 'error', userName: null };
  if (data.role !== 'ops_admin') return { status: 'notOps', userName: null };
  const profile = await getSupabase().from('profiles').select('full_name').eq('id', session.user.id).maybeSingle();
  if (profile.error || !profile.data) return { status: 'error', userName: null };
  return { status: 'ops', userName: profile.data.full_name as string };
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<{ status: AuthStatus; userName: string | null }>({
    status: 'loading', userName: null,
  });

  const request = useRef(0);
  const mounted = useRef(true);

  const update = useCallback(async (session: Session | null, version: number) => {
    try {
      const next = await resolveRole(session);
      if (mounted.current && version === request.current) setState(next);
    } catch {
      if (mounted.current && version === request.current) setState({ status: 'error', userName: null });
    }
  }, []);

  const recheck = useCallback(async () => {
    const version = ++request.current;
    setState({ status: 'loading', userName: null });
    try {
      const { data, error } = await getSupabase().auth.getSession();
      if (error) throw error;
      await update(data.session, version);
    } catch {
      if (mounted.current && version === request.current) setState({ status: 'error', userName: null });
    }
  }, [update]);

  useEffect(() => {
    mounted.current = true;
    const supabase = getSupabase();
    const version = ++request.current;
    void supabase.auth.getSession().then(({ data, error }) => {
      if (error) throw error;
      return update(data.session, version);
    }).catch(() => {
      if (mounted.current && version === request.current) setState({ status: 'error', userName: null });
    });
    const { data: listener } = supabase.auth.onAuthStateChange((event, session) => {
      if (event === 'INITIAL_SESSION') return;
      const version = ++request.current;
      // Hide protected children immediately; query outside Supabase's auth callback.
      setState({ status: session ? 'loading' : 'signedOut', userName: null });
      if (session) setTimeout(() => {
        if (mounted.current && version === request.current) void update(session, version);
      }, 0);
    });
    const onFocus = () => { void recheck(); };
    window.addEventListener('focus', onFocus);
    window.addEventListener(ACCESS_RECHECK_EVENT, onFocus);
    return () => {
      mounted.current = false;
      listener.subscription.unsubscribe();
      window.removeEventListener('focus', onFocus);
      window.removeEventListener(ACCESS_RECHECK_EVENT, onFocus);
    };
  }, [recheck, update]);

  const signOut = useCallback(async () => {
    const version = ++request.current;
    setState({ status: 'loading', userName: null });
    try {
      const { error } = await getSupabase().auth.signOut();
      if (error) throw error;
      if (mounted.current && version === request.current) setState({ status: 'signedOut', userName: null });
    } catch {
      if (mounted.current && version === request.current) setState({ status: 'error', userName: null });
    }
  }, []);

  return <AuthContext.Provider value={{ ...state, signOut, recheck }}>{children}</AuthContext.Provider>;
}

export function useAuth(): Auth {
  const value = useContext(AuthContext);
  if (!value) throw new Error('useAuth must be used inside AuthProvider');
  return value;
}
