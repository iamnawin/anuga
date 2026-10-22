'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useEffect, type ReactNode } from 'react';
import { LANGUAGES, type Language } from '@/lib/messages';
import { useAuth } from './AuthProvider';
import { useI18n } from './I18nProvider';

const LANGUAGE_NAMES: Record<Language, string> = { en: 'English', te: 'తెలుగు', hi: 'हिन्दी' };

export function LanguageSwitcher() {
  const { lang, setLang, t } = useI18n();
  return (
    <label className="lang">
      <span>{t('lang.label')}</span>
      <select value={lang} onChange={(e) => setLang(e.target.value as Language)}>
        {LANGUAGES.map((l) => <option key={l} value={l}>{LANGUAGE_NAMES[l]}</option>)}
      </select>
    </label>
  );
}

// Every console page renders inside this shell. Anyone who is not signed in as
// ops is sent to /login; the database refuses their RPCs regardless.
export function OpsShell({ children }: { children: ReactNode }) {
  const { status, userName, signOut } = useAuth();
  const { t } = useI18n();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (status === 'signedOut' || status === 'notOps') router.replace('/login');
  }, [status, router]);

  if (status !== 'ops') return <main className="page"><p>{t('common.loading')}</p></main>;

  const links = [
    { href: '/trips', label: t('nav.trips') },
    { href: '/schedules', label: t('nav.schedules') },
    { href: '/exceptions', label: t('nav.exceptions') },
    { href: '/billing', label: t('nav.billing') },
  ];

  return (
    <div className="ops-layout">
      <aside className="sidebar">
        <div className="brand-block">
          <strong className="brand">AnugaCare</strong>
        </div>
        <nav aria-label="Main">
          {links.map((l) => (
            <Link key={l.href} href={l.href} className="navlink" aria-current={pathname === l.href ? 'page' : undefined}>
              {l.label}
            </Link>
          ))}
        </nav>
      </aside>
      <div className="workspace">
        <header className="topbar">
          <div className="topbar-end">
            <LanguageSwitcher />
            <span className="user">{userName}</span>
            <button type="button" className="btn" onClick={() => signOut().then(() => router.replace('/login'))}>
              {t('nav.signOut')}
            </button>
          </div>
        </header>
        <main className="page">{children}</main>
        <footer className="footer">{t('app.synthetic')}</footer>
      </div>
    </div>
  );
}
