'use client';

import { useEffect, useState } from 'react';
import { CompanionSelect, companionName } from '../../../components/CompanionSelect.tsx';
import { errorText, Notice, type NoticeState } from '../../../components/Notice.tsx';
import {
  assignScheduleCompanions, formatDays, listCompanions, listSchedules, type Companion, type Schedule,
} from '../../../lib/ops.ts';
import { opsClient } from '../../../lib/supabase.ts';

export default function SchedulesPage() {
  const [schedules, setSchedules] = useState<Schedule[] | null>(null);
  const [companions, setCompanions] = useState<Companion[]>([]);
  const [notice, setNotice] = useState<NoticeState | null>(null);
  const [version, setVersion] = useState(0);

  useEffect(() => {
    let cancelled = false;
    Promise.all([listSchedules(opsClient()), listCompanions(opsClient())]).then(
      ([nextSchedules, nextCompanions]) => {
        if (cancelled) return;
        setSchedules(nextSchedules);
        setCompanions(nextCompanions);
      },
      (error: unknown) => { if (!cancelled) setNotice({ kind: 'error', text: errorText(error) }); },
    );
    return () => { cancelled = true; };
  }, [version]);

  async function save(schedule: Schedule, primaryId: string, backupId: string) {
    setNotice(null);
    try {
      await assignScheduleCompanions(opsClient(), schedule.id, primaryId, backupId);
      setNotice({ kind: 'ok', text: `Saved companions for ${schedule.patientName}. Upcoming trips use the new primary.` });
      setVersion((v) => v + 1);
    } catch (error) {
      setNotice({ kind: 'error', text: errorText(error) });
    }
  }

  return (
    <>
      <h1>Schedules</h1>
      <Notice notice={notice} />
      {schedules === null ? <p className="muted">Loading...</p> : schedules.length === 0 ? (
        <p className="muted">No schedules yet.</p>
      ) : (
        <ul className="cards">
          {schedules.map((schedule) => (
            <ScheduleCard key={schedule.id} schedule={schedule} companions={companions} onSave={save} />
          ))}
        </ul>
      )}
    </>
  );
}

interface ScheduleCardProps {
  schedule: Schedule;
  companions: Companion[];
  onSave: (schedule: Schedule, primaryId: string, backupId: string) => Promise<void>;
}

function ScheduleCard({ schedule, companions, onSave }: ScheduleCardProps) {
  const [primary, setPrimary] = useState(schedule.primaryCompanionId ?? '');
  const [backup, setBackup] = useState(schedule.backupCompanionId ?? '');
  const [busy, setBusy] = useState(false);

  async function submit() {
    setBusy(true);
    await onSave(schedule, primary, backup);
    setBusy(false);
  }

  return (
    <li className="card" aria-label={`Schedule ${schedule.patientName}`}>
      <div className="row">
        <span className="title">{schedule.patientName}</span>
        <span>{formatDays(schedule.daysOfWeek)} at {schedule.pickupTime}</span>
        <span className="muted">{schedule.packageName}</span>
        {!schedule.active && <span className="badge">inactive</span>}
      </div>
      <p className="muted">
        Now: {companionName(companions, schedule.primaryCompanionId)} (primary),{' '}
        {companionName(companions, schedule.backupCompanionId)} (backup)
      </p>
      <div className="row">
        <CompanionSelect label="Primary" companions={companions} value={primary} onChange={setPrimary} />
        <CompanionSelect label="Backup" companions={companions} value={backup} onChange={setBackup} />
        <button type="button" className="primary" disabled={busy || !primary || !backup} onClick={submit}>
          Save
        </button>
      </div>
    </li>
  );
}
