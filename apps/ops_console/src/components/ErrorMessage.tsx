'use client';

import { describeError } from '@/lib/errors';
import { useI18n } from './I18nProvider';

export function ErrorMessage({ error }: { error: unknown }) {
  const { t } = useI18n();
  if (!error) return null;
  const view = describeError(error);
  return (
    <div role="alert" className="alert alert-error">
      <strong>{t(view.key)}</strong>
      {view.detail && <div className="alert-detail">{t('error.database', { message: view.detail })}</div>}
    </div>
  );
}
