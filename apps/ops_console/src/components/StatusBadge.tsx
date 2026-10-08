'use client';

import type { TripStatus } from '@/lib/api';
import { useI18n } from './I18nProvider';

const TONE: Record<TripStatus, string> = {
  scheduled: 'neutral', companion_en_route: 'active', picked_up: 'active', at_centre: 'active',
  handed_over: 'active', session_done: 'active', returning: 'active', dropped_home: 'active',
  completed: 'good', cancelled: 'muted', no_show: 'warn', issue_reported: 'bad',
};

export function StatusBadge({ status }: { status: TripStatus }) {
  const { t } = useI18n();
  return <span className={`badge badge-${TONE[status]}`} data-status={status}>{t(`status.${status}`)}</span>;
}
