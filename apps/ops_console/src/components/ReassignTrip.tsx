'use client';

import { useState } from 'react';
import type { CompanionOption } from '@/lib/api';
import { CompanionSelect } from './CompanionSelect';
import { ErrorMessage } from './ErrorMessage';
import { useOpsApi } from './ApiProvider';
import { useI18n } from './I18nProvider';

export interface ReassignableTrip {
  trip_id: string;
  patient_id: string;
  status: string;
  companion_id: string | null;
  backup_companion_id: string | null;
  backup_companion_name: string | null;
}

// Swap the companion on one scheduled trip: one tap for the schedule's backup,
// or pick any companion in the cluster. The database checks eligibility.
export function ReassignTrip({ trip, onDone }: { trip: ReassignableTrip; onDone(name: string): void }) {
  const { t } = useI18n();
  const api = useOpsApi();
  const [options, setOptions] = useState<CompanionOption[] | null>(null);
  const [choice, setChoice] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<unknown>(null);

  if (trip.status !== 'scheduled') return null;

  const assign = async (companionId: string, name: string) => {
    setBusy(true);
    setError(null);
    try {
      await api().assignTripCompanion(trip.trip_id, companionId);
      setOptions(null);
      onDone(name);
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  };

  const openPicker = async () => {
    setError(null);
    try {
      setOptions(await api().companionOptions(trip.patient_id));
    } catch (e) {
      setError(e);
    }
  };

  const canAssignBackup = trip.backup_companion_id !== null && trip.backup_companion_id !== trip.companion_id;

  return (
    <div className="actions">
      {canAssignBackup && (
        <button type="button" className="btn btn-primary" disabled={busy}
          onClick={() => assign(trip.backup_companion_id!, trip.backup_companion_name ?? '')}>
          {t('trips.assignBackup', { name: trip.backup_companion_name ?? '' })}
        </button>
      )}
      {options === null ? (
        <button type="button" className="btn" disabled={busy} onClick={openPicker}>{t('trips.reassign')}</button>
      ) : (
        <form className="inline-form" onSubmit={(e) => {
          e.preventDefault();
          const picked = options.find((o) => o.companion_id === choice);
          if (picked) assign(picked.companion_id, picked.full_name);
        }}>
          <CompanionSelect id={`reassign-${trip.trip_id}`} label={t('trips.companion')} options={options}
            value={choice} onChange={setChoice} />
          <button type="submit" className="btn btn-primary" disabled={busy || !choice}>{t('trips.assign')}</button>
          <button type="button" className="btn" onClick={() => { setOptions(null); setError(null); }}>
            {t('common.cancel')}
          </button>
        </form>
      )}
      <ErrorMessage error={error} />
    </div>
  );
}
