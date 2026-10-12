'use client';

import { useState } from 'react';
import type { ScheduleRow } from '@/lib/api';
import { useOpsApi } from './ApiProvider';
import { ErrorMessage } from './ErrorMessage';
import { useI18n } from './I18nProvider';

export function SchedulePatternForm({ schedule, onSaved, onCancel }: {
  schedule: ScheduleRow;
  onSaved(result: { cancelled: number; generated: number }): void;
  onCancel(): void;
}) {
  const { t } = useI18n();
  const api = useOpsApi();
  const [days, setDays] = useState(() => [...new Set(schedule.days_of_week)].sort((a, b) => a - b));
  const [count, setCount] = useState(days.length);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<unknown>(null);
  const valid = count >= 1 && count <= 4 && days.length === count;
  const helpId = `weekday-help-${schedule.schedule_id}`;

  return (
    <form className="panel" aria-label={t('schedules.changePattern')} onSubmit={async (e) => {
      e.preventDefault();
      if (!valid || busy) return;
      setBusy(true);
      setError(null);
      try {
        onSaved(await api().updateSchedulePattern(schedule.schedule_id, days, schedule.days_of_week));
      } catch (err) {
        setError(err);
      } finally {
        setBusy(false);
      }
    }}>
      <label className="field" htmlFor={`visits-${schedule.schedule_id}`}>
        <span>{t('schedules.visitsPerWeek')}</span>
        <select id={`visits-${schedule.schedule_id}`} value={count} disabled={busy}
          onChange={(e) => setCount(Number(e.target.value))}>
          {count > 4 && <option value={count}>{t('schedules.currentPattern', { count })}</option>}
          {[1, 2, 3, 4].map((n) => <option key={n} value={n}>{n}</option>)}
        </select>
      </label>
      <fieldset className="weekdays" disabled={busy} aria-describedby={helpId}>
        <legend>{t('schedules.days')}</legend>
        <div className="weekday-options">
          {[1, 2, 3, 4, 5, 6, 7].map((day) => (
            <label key={day} className="weekday-option">
              <input type="checkbox" checked={days.includes(day)} disabled={!days.includes(day) && days.length >= count}
                onChange={(e) => setDays(e.target.checked
                  ? [...days, day].sort((a, b) => a - b) : days.filter((d) => d !== day))} />
              {t(`day.${day}` as 'day.1')}
            </label>
          ))}
        </div>
      </fieldset>
      <p id={helpId} className="muted" aria-live="polite">{t('schedules.chooseDays', { count, selected: days.length })}</p>
      <p className="muted">{t('schedules.patternEffect')}</p>
      <div className="actions">
        <button type="submit" className="btn btn-primary" disabled={busy || !valid}>
          {t(busy ? 'schedules.savingPattern' : 'schedules.savePattern')}
        </button>
        <button type="button" className="btn" onClick={onCancel} disabled={busy}>{t('common.cancel')}</button>
      </div>
      <ErrorMessage error={error} />
    </form>
  );
}
