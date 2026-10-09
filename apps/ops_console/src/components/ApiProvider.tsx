'use client';

import { createContext, useContext, type ReactNode } from 'react';
import type { OpsApi } from '@/lib/api';
import { getOpsApi } from '@/lib/supabase';

// A getter, not an instance: the Supabase client is created on first use in the
// browser, never during server prerendering.
const ApiContext = createContext<() => OpsApi>(getOpsApi);

export function ApiProvider({ api, children }: { api?: () => OpsApi; children: ReactNode }) {
  return <ApiContext.Provider value={api ?? getOpsApi}>{children}</ApiContext.Provider>;
}

export function useOpsApi(): () => OpsApi {
  return useContext(ApiContext);
}
