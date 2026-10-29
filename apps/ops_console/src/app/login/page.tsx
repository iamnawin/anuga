'use client';

import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { useAuth } from '@/components/AuthProvider';
import { useI18n } from '@/components/I18nProvider';
import { LanguageSwitcher } from '@/components/OpsShell';
import { isOtpCode, normalizeIndianMobile } from '@/lib/phone';
import { getSupabase } from '@/lib/supabase';

export default function LoginPage() {
  const { t } = useI18n();
  const { status, signOut } = useAuth();
  const router = useRouter();
  const [phoneInput, setPhoneInput] = useState('');
  const [phone, setPhone] = useState<string | null>(null);
  const [code, setCode] = useState('');
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [rejected, setRejected] = useState(false);

  useEffect(() => {
    if (status === 'ops') router.replace('/trips');
    if (status === 'notOps') {
      // A non-ops account signed in here: show why, and end its session.
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setRejected(true);
      setPhone(null);
      setCode('');
      void signOut();
    }
  }, [status, router, signOut]);

  const sendCode = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage(null);
    setRejected(false);
    const normalized = normalizeIndianMobile(phoneInput);
    if (!normalized) return setMessage(t('login.invalidPhone'));
    setBusy(true);
    // shouldCreateUser: false — the console never creates accounts.
    const { error } = await getSupabase().auth.signInWithOtp({ phone: normalized, options: { shouldCreateUser: false } });
    setBusy(false);
    if (error) return setMessage(error.message);
    setPhone(normalized);
  };

  const verify = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage(null);
    if (!phone) return;
    if (!isOtpCode(code)) return setMessage(t('login.invalidCode'));
    setBusy(true);
    const { error } = await getSupabase().auth.verifyOtp({ phone, token: code.trim(), type: 'sms' });
    setBusy(false);
    if (error) setMessage(error.message);
  };

  return (
    <main className="page login">
      <div className="brand-block login-brand"><strong className="brand">AnugaCare</strong></div>
      <div className="login-head">
        <h1>{t('login.title')}</h1>
        <LanguageSwitcher />
      </div>
      {rejected && <div role="alert" className="alert alert-error">{t('login.notOps')}</div>}
      {phone === null ? (
        <form className="panel" onSubmit={sendCode}>
          <label className="field" htmlFor="phone">
            <span>{t('login.phone')}</span>
            <input id="phone" name="phone" type="tel" inputMode="tel" autoComplete="tel" value={phoneInput}
              onChange={(e) => setPhoneInput(e.target.value)} aria-describedby="phone-hint" />
            <small id="phone-hint">{t('login.phoneHint')}</small>
          </label>
          <button type="submit" className="btn btn-primary" disabled={busy}>{t('login.sendCode')}</button>
        </form>
      ) : (
        <form className="panel" onSubmit={verify}>
          <p>{t('login.codeSent', { phone })}</p>
          <label className="field" htmlFor="code">
            <span>{t('login.code')}</span>
            <input id="code" name="code" inputMode="numeric" autoComplete="one-time-code" maxLength={6} value={code}
              onChange={(e) => setCode(e.target.value)} />
          </label>
          <div className="actions">
            <button type="submit" className="btn btn-primary" disabled={busy}>{t('login.verify')}</button>
            <button type="button" className="btn" onClick={() => { setPhone(null); setCode(''); }}>
              {t('login.changeNumber')}
            </button>
          </div>
        </form>
      )}
      {message && <div role="alert" className="alert alert-error">{message}</div>}
      <p className="footer">{t('app.synthetic')}</p>
    </main>
  );
}
