'use client';

import { useRouter } from 'next/navigation';
import { useState, type FormEvent } from 'react';
import { errorText, Notice, type NoticeState } from '../../components/Notice.tsx';
import { currentRole, normalizeIndianPhone } from '../../lib/ops.ts';
import { opsClient, supabase } from '../../lib/supabase.ts';

export default function LoginPage() {
  const router = useRouter();
  const [phoneInput, setPhoneInput] = useState('');
  const [phone, setPhone] = useState<string | null>(null);
  const [code, setCode] = useState('');
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<NoticeState | null>(null);

  async function sendCode(event: FormEvent) {
    event.preventDefault();
    const normalized = normalizeIndianPhone(phoneInput);
    if (!normalized) {
      setNotice({ kind: 'error', text: 'Enter a 10-digit Indian mobile number.' });
      return;
    }
    setBusy(true);
    setNotice(null);
    // shouldCreateUser: false, so only existing accounts can sign in.
    const { error } = await supabase().auth.signInWithOtp({ phone: normalized, options: { shouldCreateUser: false } });
    setBusy(false);
    if (error) {
      setNotice({ kind: 'error', text: error.message });
      return;
    }
    setPhone(normalized);
  }

  async function verifyCode(event: FormEvent) {
    event.preventDefault();
    if (!phone) return;
    setBusy(true);
    setNotice(null);
    try {
      const { data, error } = await supabase().auth.verifyOtp({ phone, token: code.trim(), type: 'sms' });
      if (error || !data.user) throw new Error(error?.message ?? 'Sign-in failed.');
      if ((await currentRole(opsClient(), data.user.id)) !== 'ops_admin') {
        await supabase().auth.signOut();
        throw new Error('This account is not an ops account.');
      }
      router.replace('/trips');
    } catch (error) {
      setNotice({ kind: 'error', text: errorText(error) });
      setBusy(false);
    }
  }

  return (
    <main className="login">
      <h1>Ops sign in</h1>
      <Notice notice={notice} />
      {phone === null ? (
        <form onSubmit={sendCode} className="login">
          <label>
            Mobile number
            <input type="tel" inputMode="tel" autoComplete="tel" value={phoneInput}
              onChange={(e) => setPhoneInput(e.target.value)} placeholder="90000 00001" required />
          </label>
          <button className="primary" type="submit" disabled={busy}>Send code</button>
        </form>
      ) : (
        <form onSubmit={verifyCode} className="login">
          <p className="muted">Code sent to {phone}.</p>
          <label>
            6-digit code
            <input inputMode="numeric" autoComplete="one-time-code" pattern="\d{6}" maxLength={6}
              value={code} onChange={(e) => setCode(e.target.value)} required />
          </label>
          <button className="primary" type="submit" disabled={busy}>Sign in</button>
          <button type="button" onClick={() => { setPhone(null); setCode(''); }} disabled={busy}>
            Use a different number
          </button>
        </form>
      )}
    </main>
  );
}
