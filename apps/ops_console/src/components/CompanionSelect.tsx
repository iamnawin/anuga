'use client';

import type { CompanionOption } from '@/lib/api';
import { formatKm } from '@/lib/format';
import { useI18n } from './I18nProvider';

// Lists every companion in the patient's cluster, ineligible ones included with
// the reason: ops can still try them, and the database decides.
export function CompanionSelect({
  id, label, options, value, onChange,
}: {
  id: string;
  label: string;
  options: CompanionOption[];
  value: string;
  onChange(value: string): void;
}) {
  const { t } = useI18n();
  return (
    <label htmlFor={id} className="field">
      <span>{label}</span>
      <select id={id} value={value} onChange={(e) => onChange(e.target.value)}>
        <option value="">{t('trips.choose')}</option>
        {options.map((o) => (
          <option key={o.companion_id} value={o.companion_id}>
            {o.full_name} · {t('companion.distance', { km: formatKm(o.distance_m) })} ·{' '}
            {o.eligible ? t('companion.eligible') : t(`companion.reason.${o.reason ?? 'inactive'}`)}
          </option>
        ))}
      </select>
    </label>
  );
}
