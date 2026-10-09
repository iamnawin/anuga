'use client';

import { useCallback, useEffect, useState } from 'react';
import { useOpsApi } from '@/components/ApiProvider';
import { ErrorMessage } from '@/components/ErrorMessage';
import { FareEditor } from '@/components/FareEditor';
import { useI18n } from '@/components/I18nProvider';
import { OpsShell } from '@/components/OpsShell';
import { ReassignTrip } from '@/components/ReassignTrip';
import { StatusBadge } from '@/components/StatusBadge';
import { TRIP_STATUSES, type TripRow, type TripStatus } from '@/lib/api';
import { formatDateTime, istRange, istToday } from '@/lib/format';

const DAY_OPTIONS = [1, 3, 7, 14];

function TripsBoard() {
  const { t, lang } = useI18n();
  const api = useOpsApi();
  const [day, setDay] = useState(istToday);
  const [days, setDays] = useState(7);
  const [status, setStatus] = useState<TripStatus | ''>('');
  const [trips, setTrips] = useState<TripRow[] | null>(null);
  const [error, setError] = useState<unknown>(null);
  const [notice, setNotice] = useState<string | null>(null);

  const load = useCallback(async () => {
    setError(null);
    try {
      const { from, to } = istRange(day, days);
      setTrips(await api().tripBoard(from, to, status ? [status] : undefined));
    } catch (e) {
      setError(e);
    }
  }, [api, day, days, status]);

  useEffect(() => {
    // Fetching on filter change; load() sets state after the request resolves.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  return (
    <section aria-labelledby="trips-title">
      <div className="section-head">
        <h1 id="trips-title">{t('trips.title')}</h1>
        <button type="button" className="btn" onClick={() => void load()}>{t('common.refresh')}</button>
      </div>
      <form className="filters" onSubmit={(e) => e.preventDefault()}>
        <label className="field" htmlFor="from-day">
          <span>{t('trips.from')}</span>
          <input id="from-day" type="date" value={day} onChange={(e) => e.target.value && setDay(e.target.value)} />
        </label>
        <label className="field" htmlFor="days">
          <span>{t('trips.days')}</span>
          <select id="days" value={days} onChange={(e) => setDays(Number(e.target.value))}>
            {DAY_OPTIONS.map((n) => <option key={n} value={n}>{n}</option>)}
          </select>
        </label>
        <label className="field" htmlFor="status">
          <span>{t('trips.status')}</span>
          <select id="status" value={status} onChange={(e) => setStatus(e.target.value as TripStatus | '')}>
            <option value="">{t('trips.allStatuses')}</option>
            {TRIP_STATUSES.map((s) => <option key={s} value={s}>{t(`status.${s}`)}</option>)}
          </select>
        </label>
      </form>
      {notice && <div role="status" className="alert alert-ok">{notice}</div>}
      <ErrorMessage error={error} />
      {trips === null ? <p>{t('common.loading')}</p> : trips.length === 0 ? <p>{t('trips.empty')}</p> : (
        <>
          <p className="muted">{t('trips.count', { count: trips.length })}</p>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th scope="col">{t('trips.pickup')}</th>
                  <th scope="col">{t('trips.patient')}</th>
                  <th scope="col">{t('trips.status')}</th>
                  <th scope="col">{t('trips.companion')}</th>
                  <th scope="col">{t('trips.actions')}</th>
                </tr>
              </thead>
              <tbody>
                {trips.map((trip) => (
                  <tr key={trip.trip_id} data-trip-id={trip.trip_id}>
                    <td>{formatDateTime(trip.scheduled_pickup_at, lang)}</td>
                    <td>{trip.patient_name}<div className="muted">{trip.centre_name}</div></td>
                    <td>
                      <StatusBadge status={trip.status} />
                      {trip.is_late && <span className="badge badge-bad">{t('trips.late')}</span>}
                    </td>
                    <td data-col="companion">{trip.companion_name ?? t('trips.unassigned')}</td>
                    <td>
                      <ReassignTrip trip={trip} onDone={(name) => {
                        setNotice(t('trips.reassigned', { name }));
                        void load();
                      }} />
                      {trip.status === 'completed' && (
                        <FareEditor tripId={trip.trip_id} farePaise={trip.fare_amount_paise} onSaved={() => void load()} />
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </section>
  );
}

export default function TripsPage() {
  return <OpsShell><TripsBoard /></OpsShell>;
}
