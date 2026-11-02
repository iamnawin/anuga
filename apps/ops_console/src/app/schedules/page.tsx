'use client';

import { useCallback, useEffect, useState } from 'react';
import { useOpsApi } from '@/components/ApiProvider';
import { CreateTrips } from '@/components/CreateTrips';
import { ErrorMessage } from '@/components/ErrorMessage';
import { useI18n } from '@/components/I18nProvider';
import { OpsShell } from '@/components/OpsShell';
import { ScheduleAssignForm } from '@/components/ScheduleAssignForm';
import type { CareRequestRow, ScheduleRow } from '@/lib/api';
import type { Language, MessageKey } from '@/lib/messages';
import { formatClock, OPS_TIME_ZONE } from '@/lib/format';

function requestStateLabel(state: CareRequestRow['request_state'], t: (key: MessageKey) => string) {
  switch (state) {
    case 'pending': return t('careRequests.pending');
    case 'confirmed': return t('careRequests.confirmed');
    case 'assigned': return t('careRequests.assigned');
    case 'inactive': return t('schedules.inactive');
    default: return t(`status.${state}`);
  }
}

function requestPickup(iso: string, lang: Language) {
  return new Intl.DateTimeFormat(`${lang}-IN`, {
    timeZone: OPS_TIME_ZONE, day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit', hour12: false,
  }).format(new Date(iso));
}

function SchedulesBoard() {
  const { t, lang } = useI18n();
  const api = useOpsApi();
  const [rows, setRows] = useState<ScheduleRow[] | null>(null);
  const [requests, setRequests] = useState<CareRequestRow[]>([]);
  const [editing, setEditing] = useState<string | null>(null);
  const [error, setError] = useState<unknown>(null);
  const [notice, setNotice] = useState<string | null>(null);

  const load = useCallback(async () => {
    setError(null);
    try {
      const [schedules, careRequests] = await Promise.all([api().scheduleBoard(), api().careRequests()]);
      setRows(schedules);
      setRequests(careRequests);
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
          {rows.map((s) => {
            const request = requests.find((r) => r.schedule_id === s.schedule_id);
            return (
              <li key={s.schedule_id} className="card" data-schedule-id={s.schedule_id}>
                <div className="card-head">
                  <h2>{s.patient_name}</h2>
                  {request && <span className="badge badge-muted">{t('careRequests.label')}</span>}
                  {!s.active && <span className="badge badge-muted">{t('schedules.inactive')}</span>}
                </div>
                <dl className="facts">
                  {request && <>
                    <dt>{t('careRequests.pickup')}</dt>
                    <dd><time dateTime={request.pickup_at}>{requestPickup(request.pickup_at, lang)}</time></dd>
                    <dt>{t('careRequests.status')}</dt>
                    <dd data-col="request-state">{requestStateLabel(request.request_state, t)}</dd>
                  </>}
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
                {s.active && <CreateTrips scheduleId={s.schedule_id}
                  careRequest={request !== undefined} onCreated={() => void load()} />}
              </li>
            );
          })}
        </ul>
      )}
    </section>
  );
}

export default function SchedulesPage() {
  return <OpsShell><SchedulesBoard /></OpsShell>;
}
