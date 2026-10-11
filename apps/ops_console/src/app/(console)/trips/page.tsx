'use client';

import { useEffect, useState } from 'react';
import { CompanionSelect, companionName } from '../../../components/CompanionSelect.tsx';
import { errorText, Notice, type NoticeState } from '../../../components/Notice.tsx';
import {
  assignTripCompanion, backupFor, formatIstTime, istToday, listCompanions, listTrips,
  TRIP_STATUSES, type Companion, type Trip, type TripStatus,
} from '../../../lib/ops.ts';
import { opsClient } from '../../../lib/supabase.ts';

export default function TripsPage() {
  const [day, setDay] = useState(() => istToday());
  const [status, setStatus] = useState<TripStatus | ''>('');
  const [trips, setTrips] = useState<Trip[] | null>(null);
  const [companions, setCompanions] = useState<Companion[]>([]);
  const [notice, setNotice] = useState<NoticeState | null>(null);
  const [version, setVersion] = useState(0);

  useEffect(() => {
    let cancelled = false;
    Promise.all([listTrips(opsClient(), { day, status }), listCompanions(opsClient())]).then(
      ([nextTrips, nextCompanions]) => {
        if (cancelled) return;
        setTrips(nextTrips);
        setCompanions(nextCompanions);
      },
      (error: unknown) => { if (!cancelled) setNotice({ kind: 'error', text: errorText(error) }); },
    );
    return () => { cancelled = true; };
  }, [day, status, version]);

  async function assign(trip: Trip, companionId: string) {
    setNotice(null);
    try {
      await assignTripCompanion(opsClient(), trip.id, companionId);
      setNotice({ kind: 'ok', text: `${companionName(companions, companionId)} assigned to ${trip.patientName}.` });
      setVersion((v) => v + 1);
    } catch (error) {
      setNotice({ kind: 'error', text: errorText(error) });
    }
  }

  return (
    <>
      <h1>Trips</h1>
      <div className="filters">
        <label>
          Date
          <input type="date" value={day} onChange={(e) => e.target.value && setDay(e.target.value)} />
        </label>
        <label>
          Status
          <select value={status} onChange={(e) => setStatus(e.target.value as TripStatus | '')}>
            <option value="">All statuses</option>
            {TRIP_STATUSES.map((s) => <option key={s} value={s}>{s.replaceAll('_', ' ')}</option>)}
          </select>
        </label>
      </div>
      <Notice notice={notice} />
      {trips === null ? <p className="muted">Loading...</p> : trips.length === 0 ? (
        <p className="muted">No trips for this date.</p>
      ) : (
        <ul className="cards">
          {trips.map((trip) => (
            <TripCard key={trip.id} trip={trip} companions={companions} onAssign={assign} />
          ))}
        </ul>
      )}
    </>
  );
}

interface TripCardProps {
  trip: Trip;
  companions: Companion[];
  onAssign: (trip: Trip, companionId: string) => Promise<void>;
}

function TripCard({ trip, companions, onAssign }: TripCardProps) {
  const [choice, setChoice] = useState('');
  const [busy, setBusy] = useState(false);
  const backup = backupFor(trip);

  async function run(companionId: string) {
    setBusy(true);
    await onAssign(trip, companionId);
    setBusy(false);
  }

  return (
    <li className="card" aria-label={`Trip ${trip.patientName} ${formatIstTime(trip.scheduledPickupAt)}`}>
      <div className="row">
        <span className="title">{formatIstTime(trip.scheduledPickupAt)}</span>
        <span>{trip.patientName}</span>
        <span className="muted">to {trip.centreName}</span>
        <span className="badge">{trip.status.replaceAll('_', ' ')}</span>
      </div>
      <div className="row">
        <span>Companion: <strong data-testid="trip-companion">{companionName(companions, trip.companionId)}</strong></span>
        <span className="muted">Backup: {companionName(companions, trip.backupCompanionId)}</span>
      </div>
      {trip.status === 'scheduled' && (
        <div className="row">
          {backup && (
            <button type="button" className="primary" disabled={busy} onClick={() => run(backup)}>
              Assign backup
            </button>
          )}
          <CompanionSelect label="Reassign to" companions={companions} value={choice} onChange={setChoice} />
          <button type="button" disabled={busy || !choice} onClick={() => run(choice)}>Reassign</button>
        </div>
      )}
    </li>
  );
}
