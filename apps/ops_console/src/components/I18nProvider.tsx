'use client';

import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { isLanguage, translate, type Language, type MessageKey } from '@/lib/messages';

const STORAGE_KEY = 'companion-ops-language';

interface I18n {
  lang: Language;
  setLang(lang: Language): void;
  t(key: MessageKey, vars?: Record<string, string | number>): string;
}

const I18nContext = createContext<I18n | null>(null);

export function I18nProvider({ children, initial = 'en' }: { children: ReactNode; initial?: Language }) {
  const [lang, setLangState] = useState<Language>(initial);

  useEffect(() => {
    try {
      const saved = window.localStorage.getItem(STORAGE_KEY);
      // Restoring a saved preference after hydration; the server always renders English.
      // eslint-disable-next-line react-hooks/set-state-in-effect
      if (isLanguage(saved)) setLangState(saved);
    } catch {
      // Storage can be unavailable (private mode); English is the fallback.
    }
  }, []);

  useEffect(() => {
    document.documentElement.lang = lang;
  }, [lang]);

  const setLang = useCallback((next: Language) => {
    setLangState(next);
    try {
      window.localStorage.setItem(STORAGE_KEY, next);
    } catch {
      // Preference is a convenience only.
    }
  }, []);

  const value = useMemo<I18n>(() => ({
    lang,
    setLang,
    t: (key, vars) => translate(lang, key, vars),
  }), [lang, setLang]);

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useI18n(): I18n {
  const value = useContext(I18nContext);
  if (!value) throw new Error('useI18n must be used inside I18nProvider');
  return value;
}
