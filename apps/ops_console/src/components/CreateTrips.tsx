'use client';

import { useState } from 'react';
import type { CreatedTripDate } from '@/lib/api';
import { formatDateTime } from '@/lib/format';
import { ErrorMessage } from './ErrorMessage';
import { useOpsApi } from './ApiProvider';
import { useI18n } from './I18nProvider';

// Generates a schedule's trips for the configured window (trip_generation_days).
// Safe to press again: dates that already have a trip are reported as skipped.
export function CreateTrips({ scheduleId, onCreated }: { scheduleId: string; onCreated(): void }) {
  const { t, lang } = useI18n();
  const api = useOpsApi();
  const [result, setResult] = useState<CreatedTripDate[] | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<unknown>(null);
  const created = result?.filter((r) => r.created).length ?? 0;

  return (
    <div>
      <button type="button" className="btn btn-primary" disabled={busy} onClick={async () => {
        setBusy(true);
        setError(null);
        try {
          const rows = await api().createScheduleTrips(scheduleId);
          setResult(rows);
          onCreated();
        } catch (err) {
          setError(err);
        } finally {
          setBusy(false);
        }
      }}>{t('schedules.createTrips')}</button>
      <ErrorMessage error={error} />
      {result && (
        <div role="status" className="panel">
          <p>{result.length === 0
            ? t('schedules.noDates')
            : t('schedules.createdSummary', { created, skipped: result.length - created })}</p>
          {result.length > 0 && (
            <dl className="facts">
              {result.map((r) => (
                <div key={r.pickup_date} style={{ display: 'contents' }}>
                  <dt>{formatDateTime(r.pickup_at, lang)}</dt>
                  <dd>{t(r.created ? 'schedules.tripCreated' : 'schedules.tripSkipped')}</dd>
                </div>
              ))}
            </dl>
          )}
        </div>
      )}
    </div>
  );
}
