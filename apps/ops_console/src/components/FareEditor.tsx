'use client';

import { useState } from 'react';
import { parseRupees } from '@/lib/money';
import { useOpsApi } from './ApiProvider';
import { ErrorMessage } from './ErrorMessage';
import { useI18n } from './I18nProvider';

// Actual cab/auto fare for a completed trip (passed through to the bill at cost).
export function FareEditor({ tripId, farePaise, onSaved }: { tripId: string; farePaise: number | null; onSaved(): void }) {
  const { t } = useI18n();
  const api = useOpsApi();
  const [value, setValue] = useState(farePaise === null ? '' : (farePaise / 100).toString());
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);

  return (
    <form className="inline-form" onSubmit={async (e) => {
      e.preventDefault();
      setMessage(null);
      setError(null);
      const paise = parseRupees(value);
      if (paise === null) return setMessage(t('fare.invalid'));
      setBusy(true);
      try {
        await api().recordTripFare(tripId, paise);
        setMessage(t('fare.saved'));
        onSaved();
      } catch (err) {
        setError(err);
      } finally {
        setBusy(false);
      }
    }}>
      <label className="field" htmlFor={`fare-${tripId}`}>
        <span>{t('fare.label')}</span>
        <input id={`fare-${tripId}`} inputMode="decimal" value={value} size={8} onChange={(e) => setValue(e.target.value)} />
      </label>
      <button type="submit" className="btn" disabled={busy}>{t('fare.save')}</button>
      {message && <span role="status" className="muted">{message}</span>}
      <ErrorMessage error={error} />
    </form>
  );
}
