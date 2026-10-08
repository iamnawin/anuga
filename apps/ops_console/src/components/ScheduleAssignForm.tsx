'use client';

import { useEffect, useState } from 'react';
import type { CompanionOption, ScheduleRow } from '@/lib/api';
import { CompanionSelect } from './CompanionSelect';
import { ErrorMessage } from './ErrorMessage';
import { useOpsApi } from './ApiProvider';
import { useI18n } from './I18nProvider';

// Sets the fixed primary + backup for a weekly pattern. Validation is the
// database's job (eligibility, two different companions); errors are shown as-is.
export function ScheduleAssignForm({
  schedule, onSaved, onCancel,
}: {
  schedule: ScheduleRow;
  onSaved(): void;
  onCancel(): void;
}) {
  const { t } = useI18n();
  const api = useOpsApi();
  const [options, setOptions] = useState<CompanionOption[]>([]);
  const [primary, setPrimary] = useState(schedule.primary_companion_id ?? '');
  const [backup, setBackup] = useState(schedule.backup_companion_id ?? '');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<unknown>(null);

  useEffect(() => {
    let cancelled = false;
    api().companionOptions(schedule.patient_id)
      .then((rows) => { if (!cancelled) setOptions(rows); })
      .catch((e: unknown) => { if (!cancelled) setError(e); });
    return () => { cancelled = true; };
  }, [api, schedule.patient_id]);

  return (
    <form className="panel" aria-label={t('schedules.change')} onSubmit={async (e) => {
      e.preventDefault();
      setBusy(true);
      setError(null);
      try {
        await api().assignScheduleCompanions(schedule.schedule_id, primary, backup);
        onSaved();
      } catch (err) {
        setError(err);
      } finally {
        setBusy(false);
      }
    }}>
      <CompanionSelect id={`primary-${schedule.schedule_id}`} label={t('schedules.primary')}
        options={options} value={primary} onChange={setPrimary} />
      <CompanionSelect id={`backup-${schedule.schedule_id}`} label={t('schedules.backup')}
        options={options} value={backup} onChange={setBackup} />
      <div className="actions">
        <button type="submit" className="btn btn-primary" disabled={busy || !primary || !backup}>{t('common.save')}</button>
        <button type="button" className="btn" onClick={onCancel}>{t('common.cancel')}</button>
      </div>
      <ErrorMessage error={error} />
    </form>
  );
}
