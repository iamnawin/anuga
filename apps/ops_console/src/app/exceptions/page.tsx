'use client';

import { useCallback, useEffect, useState } from 'react';
import { useOpsApi } from '@/components/ApiProvider';
import { ErrorMessage } from '@/components/ErrorMessage';
import { useI18n } from '@/components/I18nProvider';
import { OpsShell } from '@/components/OpsShell';
import { ReassignTrip } from '@/components/ReassignTrip';
import { StatusBadge } from '@/components/StatusBadge';
import { opsActionsFor, type ExceptionRow, type Transition, type TripStatus } from '@/lib/api';
import { formatDateTime } from '@/lib/format';

function ExceptionQueue() {
  const { t, lang } = useI18n();
  const api = useOpsApi();
  const [rows, setRows] = useState<ExceptionRow[] | null>(null);
  const [transitions, setTransitions] = useState<Transition[]>([]);
  const [error, setError] = useState<unknown>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const load = useCallback(async () => {
    setError(null);
    try {
      const [queue, rules] = await Promise.all([api().exceptionQueue(), api().opsTransitions()]);
      setRows(queue);
      setTransitions(rules);
    } catch (e) {
      setError(e);
    }
  }, [api]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  const move = async (row: ExceptionRow, to: TripStatus) => {
    if (to === 'cancelled' && !window.confirm(t('exceptions.confirmCancel'))) return;
    setBusy(true);
    setError(null);
    try {
      await api().advanceTrip(row.trip_id, to, t('exceptions.resolveNote'));
      setNotice(t('exceptions.done', { status: t(`status.${to}`) }));
      await load();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  };

  // For an issue, offer to resume where the trip was, or cancel; the full list of
  // ops transitions would be noise here. Both still come from the rules table.
  const actionsFor = (row: ExceptionRow): TripStatus[] => {
    const allowed = opsActionsFor(row.status, transitions);
    const wanted: TripStatus[] = row.kind === 'issue_reported'
      ? [row.status_before_issue ?? 'companion_en_route', 'cancelled']
      : ['cancelled'];
    return wanted.filter((s) => allowed.includes(s));
  };

  return (
    <section aria-labelledby="exceptions-title">
      <div className="section-head">
        <h1 id="exceptions-title">{t('exceptions.title')}</h1>
        <button type="button" className="btn" onClick={() => void load()}>{t('common.refresh')}</button>
      </div>
      {notice && <div role="status" className="alert alert-ok">{notice}</div>}
      <ErrorMessage error={error} />
      {rows === null ? <p>{t('common.loading')}</p> : rows.length === 0 ? <p>{t('exceptions.empty')}</p> : (
        <ul className="cards">
          {rows.map((row) => (
            <li key={row.trip_id} className={`card card-${row.kind}`} data-trip-id={row.trip_id} data-kind={row.kind}>
              <div className="card-head">
                <h2>{t(`exceptions.kind.${row.kind}`)}</h2>
                <StatusBadge status={row.status} />
              </div>
              <dl className="facts">
                <dt>{t('trips.patient')}</dt><dd>{row.patient_name} · {row.centre_name}</dd>
                <dt>{t('trips.pickup')}</dt><dd>{formatDateTime(row.scheduled_pickup_at, lang)}</dd>
                <dt>{t('trips.companion')}</dt><dd data-col="companion">{row.companion_name ?? t('trips.unassigned')}</dd>
                {row.last_note && <><dt>{t('exceptions.note')}</dt><dd>{row.last_note}</dd></>}
                <dt>{t('exceptions.since')}</dt><dd>{formatDateTime(row.since, lang)}</dd>
              </dl>
              <ReassignTrip trip={row} onDone={(name) => {
                setNotice(t('trips.reassigned', { name }));
                void load();
              }} />
              <div className="actions">
                {actionsFor(row).map((to) => (
                  <button key={to} type="button" className={to === 'cancelled' ? 'btn btn-danger' : 'btn'}
                    disabled={busy} onClick={() => void move(row, to)}>
                    {t('exceptions.moveTo', { status: t(`status.${to}`) })}
                  </button>
                ))}
              </div>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}

export default function ExceptionsPage() {
  return <OpsShell><ExceptionQueue /></OpsShell>;
}
