'use client';

import { useCallback, useEffect, useRef, useState } from 'react';
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
  const [notes, setNotes] = useState<Record<string, string>>({});
  const request = useRef(0);
  const acting = useRef(false);
  const mounted = useRef(true);

  const load = useCallback(async () => {
    const current = ++request.current;
    setRows(null);
    setTransitions([]);
    setNotes({});
    setError(null);
    try {
      const [queue, rules] = await Promise.all([api().exceptionQueue(), api().opsTransitions()]);
      if (current === request.current) {
        setRows(queue);
        setTransitions(rules);
      }
    } catch (e) {
      if (current === request.current) setError(e);
    }
  }, [api]);

  useEffect(() => {
    mounted.current = true;
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
    return () => { mounted.current = false; ++request.current; };
  }, [load]);

  const move = async (row: ExceptionRow, to: TripStatus) => {
    if (acting.current || !actionsFor(row).includes(to)) return;
    const confirmation = to === 'cancelled'
      ? t('exceptions.confirmCancel')
      : t('exceptions.confirmResume', { status: t(`status.${to}`) });
    if (!window.confirm(confirmation)) return;
    const note = notes[row.trip_id]?.trim() || t('exceptions.resolveNote');
    acting.current = true;
    const current = ++request.current;
    setBusy(true);
    setRows(null);
    setTransitions([]);
    setError(null);
    setNotice(null);
    try {
      if (row.kind === 'issue_reported') {
        await api().resolveVisitIssue(row.trip_id, row.since, to, note);
      } else {
        await api().advanceTrip(row.trip_id, to, note);
      }
      if (current === request.current) {
        setNotice(t('exceptions.done', { status: t(`status.${to}`) }));
        await load();
      }
    } catch (e) {
      if (current === request.current) setError(e);
    } finally {
      acting.current = false;
      if (mounted.current) setBusy(false);
    }
  };

  // For an issue, offer to resume where the trip was, or cancel; the full list of
  // ops transitions would be noise here. Both still come from the rules table.
  const actionsFor = (row: ExceptionRow): TripStatus[] => {
    const allowed = opsActionsFor(row.status, transitions);
    const wanted: TripStatus[] = row.kind === 'issue_reported'
      ? [...(row.status_before_issue ? [row.status_before_issue] : []), 'cancelled']
      : ['cancelled'];
    return wanted.filter((s) => allowed.includes(s));
  };

  return (
    <section aria-labelledby="exceptions-title">
      <div className="section-head">
        <h1 id="exceptions-title">{t('exceptions.title')}</h1>
        <button type="button" className="btn" disabled={busy} onClick={() => { setNotice(null); void load(); }}>{t('common.refresh')}</button>
      </div>
      {notice && <div role="status" className="alert alert-ok">{notice}</div>}
      <ErrorMessage error={error} />
      {rows === null ? (!error && <p>{t('common.loading')}</p>) : rows.length === 0 ? <p>{t('exceptions.empty')}</p> : (
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
                {row.kind === 'issue_reported' && <>
                  <dt>{t('exceptions.beforeIssue')}</dt>
                  <dd>{row.status_before_issue ? t(`status.${row.status_before_issue}`) : t('exceptions.unknownStage')}</dd>
                </>}
                {row.last_note && <><dt>{t(row.kind === 'issue_reported' ? 'exceptions.internalIssueNote' : 'exceptions.note')}</dt><dd>{row.last_note}</dd></>}
                <dt>{t(row.kind === 'issue_reported' ? 'exceptions.reportedAt' : 'exceptions.since')}</dt><dd>{formatDateTime(row.since, lang)}</dd>
              </dl>
              {row.kind === 'issue_reported' && !row.status_before_issue && <p className="alert alert-error">{t('exceptions.missingStage')}</p>}
              <ReassignTrip trip={row} onDone={(name) => {
                setNotice(t('trips.reassigned', { name }));
                void load();
              }} />
              {actionsFor(row).length > 0 && (
                <div className="field">
                  <label htmlFor={`resolution-note-${row.trip_id}`}>{t('exceptions.resolutionNote')}</label>
                  <input id={`resolution-note-${row.trip_id}`} type="text" value={notes[row.trip_id] ?? ''}
                    aria-describedby={`resolution-help-${row.trip_id}`} disabled={busy}
                    onChange={(e) => setNotes((before) => ({ ...before, [row.trip_id]: e.target.value }))} />
                  <small id={`resolution-help-${row.trip_id}`}>{t('exceptions.resolutionPrivate')}</small>
                </div>
              )}
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
