'use client';

import type { ReactNode } from 'react';
import { ApiProvider } from '@/components/ApiProvider';
import { AuthProvider } from '@/components/AuthProvider';
import { I18nProvider } from '@/components/I18nProvider';

export function Providers({ children }: { children: ReactNode }) {
  return (
    <I18nProvider>
      <AuthProvider>
        <ApiProvider>{children}</ApiProvider>
      </AuthProvider>
    </I18nProvider>
  );
}
