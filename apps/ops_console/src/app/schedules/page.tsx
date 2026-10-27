'use client';

import { useCallback, useEffect, useState } from 'react';
import { useOpsApi } from '@/components/ApiProvider';
import { CreateTrips } from '@/components/CreateTrips';
import { ErrorMessage } from '@/components/ErrorMessage';
import { useI18n } from '@/components/I18nProvider';
import { OpsShell } from '@/components/OpsShell';
import { ScheduleAssignForm } from '@/components/ScheduleAssignForm';
import type { ScheduleRow } from '@/lib/api';
import { formatClock } from '@/lib/format';

function SchedulesBoard() {
  const { t } = useI18n();
  const api = useOpsApi();
  const [rows, setRows] = useState<ScheduleRow[] | null>(null);
  const [editing, setEditing] = useState<string | null>(null);
  const [error, setError] = useState<unknown>(null);
  const [notice, setNotice] = useState<string | null>(null);

  const load = useCallback(async () => {
    setError(null);
    try {
      setRows(await api().scheduleBoard());
    } catch (e) {
      setError(e);
    }
  }, [api]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  return (
    <section aria-labelledby="schedules-title">
      <div className="section-head">
        <h1 id="schedules-title">{t('schedules.title')}</h1>
        <button type="button" className="btn" onClick={() => void load()}>{t('common.refresh')}</button>
      </div>
      {notice && <div role="status" className="alert alert-ok">{notice}</div>}
      <ErrorMessage error={error} />
      {rows === null ? <p>{t('common.loading')}</p> : rows.length === 0 ? <p>{t('schedules.empty')}</p> : (
        <ul className="cards">
          {rows.map((s) => (
            <li key={s.schedule_id} className="card" data-schedule-id={s.schedule_id}>
              <div className="card-head">
                <h2>{s.patient_name}</h2>
                {!s.active && <span className="badge badge-muted">{t('schedules.inactive')}</span>}
              </div>
              <dl className="facts">
                <dt>{t('schedules.centre')}</dt><dd>{s.centre_name} · {s.package_name}</dd>
                <dt>{t('schedules.days')}</dt>
                <dd>{s.days_of_week.map((d) => t(`day.${d}` as 'day.1')).join(', ')}</dd>
                <dt>{t('schedules.pickup')}</dt><dd>{formatClock(s.pickup_time)}</dd>
                <dt>{t('schedules.primary')}</dt><dd data-col="primary">{s.primary_companion_name ?? '—'}</dd>
                <dt>{t('schedules.backup')}</dt><dd data-col="backup">{s.backup_companion_name ?? '—'}</dd>
                <dt>{t('schedules.upcoming')}</dt><dd>{s.upcoming_trips}</dd>
              </dl>
              {editing === s.schedule_id ? (
                <ScheduleAssignForm schedule={s} onCancel={() => setEditing(null)} onSaved={() => {
                  setEditing(null);
                  setNotice(t('schedules.saved', { name: s.patient_name }));
                  void load();
                }} />
              ) : (
                <button type="button" className="btn" onClick={() => { setNotice(null); setEditing(s.schedule_id); }}>
                  {t('schedules.change')}
                </button>
              )}
              {s.active && <CreateTrips scheduleId={s.schedule_id} onCreated={() => void load()} />}
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}

export default function SchedulesPage() {
  return <OpsShell><SchedulesBoard /></OpsShell>;
}
