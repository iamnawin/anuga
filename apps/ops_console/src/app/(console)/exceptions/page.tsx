'use client';

import { useEffect, useState } from 'react';
import { companionName } from '../../../components/CompanionSelect.tsx';
import { errorText, Notice, type NoticeState } from '../../../components/Notice.tsx';
import {
  formatIstTime, listCompanions, listExceptions, type Companion, type ExceptionKind, type Trip,
} from '../../../lib/ops.ts';
import { opsClient } from '../../../lib/supabase.ts';

const LABELS: Record<ExceptionKind, string> = {
  issue_reported: 'Issue reported',
  no_show: 'No-show',
  late: 'Late: pickup time passed',
};

export default function ExceptionsPage() {
  const [items, setItems] = useState<Array<Trip & { kind: ExceptionKind }> | null>(null);
  const [companions, setCompanions] = useState<Companion[]>([]);
  const [notice, setNotice] = useState<NoticeState | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const [nextItems, nextCompanions] = await Promise.all([
          listExceptions(opsClient(), new Date()), listCompanions(opsClient()),
        ]);
        setItems(nextItems);
        setCompanions(nextCompanions);
      } catch (error) {
        setNotice({ kind: 'error', text: errorText(error) });
      }
    })();
  }, []);

  return (
    <>
      <h1>Exceptions (last 7 days)</h1>
      <Notice notice={notice} />
      {items === null ? <p className="muted">Loading...</p> : items.length === 0 ? (
        <p className="muted">No exceptions. All trips are on track.</p>
      ) : (
        <ul className="cards">
          {items.map((trip) => (
            <li key={trip.id} className="card">
              <div className="row">
                <span className="badge alert">{LABELS[trip.kind]}</span>
                <span className="title">{formatIstTime(trip.scheduledPickupAt)}</span>
                <span>{trip.patientName}</span>
                <span className="muted">to {trip.centreName}</span>
              </div>
              <div className="row">
                <span>Companion: <strong>{companionName(companions, trip.companionId)}</strong></span>
                <span className="muted">Backup: {companionName(companions, trip.backupCompanionId)}</span>
              </div>
            </li>
          ))}
        </ul>
      )}
    </>
  );
}
