'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import { useOpsApi } from '@/components/ApiProvider';
import { ErrorMessage } from '@/components/ErrorMessage';
import { useI18n } from '@/components/I18nProvider';
import { OpsShell } from '@/components/OpsShell';
import type { InvoiceRow, ScheduleRow } from '@/lib/api';
import { istToday } from '@/lib/format';
import { formatRupees, monthStart } from '@/lib/money';

// Previous calendar month in India time, as YYYY-MM (bills are usually made after the month ends).
function previousMonth(today: string): string {
  const [y, m] = today.split('-').map(Number);
  return m === 1 ? `${y - 1}-12` : `${y}-${String(m - 1).padStart(2, '0')}`;
}

function BillingBoard() {
  const { t, lang } = useI18n();
  const api = useOpsApi();
  const [month, setMonth] = useState(() => previousMonth(istToday()));
  const [patients, setPatients] = useState<ScheduleRow[] | null>(null);
  const [invoices, setInvoices] = useState<InvoiceRow[]>([]);
  const [error, setError] = useState<unknown>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [busy, setBusy] = useState<string | null>(null);

  const load = useCallback(async () => {
    setError(null);
    try {
      const [schedules, rows] = await Promise.all([api().scheduleBoard(), api().invoices(monthStart(month))]);
      setPatients(schedules.filter((s) => s.active));
      setInvoices(rows);
    } catch (e) {
      setError(e);
    }
  }, [api, month]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  // One row per patient with an active schedule (the package comes from it).
  const rows = useMemo(() => {
    const seen = new Set<string>();
    return (patients ?? []).filter((p) => !seen.has(p.patient_id) && seen.add(p.patient_id)).map((p) => ({
      patient: p,
      invoice: invoices.find((i) => i.patient_id === p.patient_id) ?? null,
    }));
  }, [patients, invoices]);

  const act = async (key: string, action: () => Promise<unknown>, done: string) => {
    setBusy(key);
    setError(null);
    setNotice(null);
    try {
      await action();
      setNotice(done);
      await load();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(null);
    }
  };

  return (
    <section aria-labelledby="billing-title">
      <div className="section-head">
        <h1 id="billing-title">{t('billing.title')}</h1>
        <button type="button" className="btn" onClick={() => void load()}>{t('common.refresh')}</button>
      </div>
      <form className="filters" onSubmit={(e) => e.preventDefault()}>
        <label className="field" htmlFor="billing-month">
          <span>{t('billing.month')}</span>
          <input id="billing-month" type="month" value={month} onChange={(e) => e.target.value && setMonth(e.target.value)} />
        </label>
      </form>
      <p className="muted">{t('billing.emptyHint')}</p>
      {notice && <div role="status" className="alert alert-ok">{notice}</div>}
      <ErrorMessage error={error} />
      {patients === null ? <p>{t('common.loading')}</p> : (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th scope="col">{t('billing.patient')}</th>
                <th scope="col">{t('billing.visits')}</th>
                <th scope="col">{t('billing.fares')}</th>
                <th scope="col">{t('billing.total')}</th>
                <th scope="col">{t('billing.status')}</th>
                <th scope="col">{t('trips.actions')}</th>
              </tr>
            </thead>
            <tbody>
              {rows.map(({ patient, invoice }) => (
                <tr key={patient.patient_id} data-patient-id={patient.patient_id} data-invoice-status={invoice?.status ?? 'none'}>
                  <td>{patient.patient_name}<div className="muted">{patient.package_name}</div></td>
                  <td>{invoice?.visits ?? '—'}</td>
                  <td>{invoice ? formatRupees(invoice.fares_paise, lang) : '—'}</td>
                  <td data-col="total">{invoice ? formatRupees(invoice.total_paise, lang) : '—'}</td>
                  <td>{invoice ? t(`billing.status.${invoice.status}`) : t('billing.none')}</td>
                  <td>
                    <div className="actions">
                      {(!invoice || invoice.status === 'draft') && (
                        <button type="button" className="btn" disabled={busy !== null}
                          onClick={() => void act(`g-${patient.patient_id}`,
                            () => api().generateInvoice(patient.patient_id, monthStart(month)),
                            t('billing.generated', { name: patient.patient_name }))}>
                          {invoice ? t('billing.rebuild') : t('billing.generate')}
                        </button>
                      )}
                      {invoice?.status === 'draft' && invoice.total_paise > 0 && (
                        <button type="button" className="btn btn-primary" disabled={busy !== null}
                          onClick={() => void act(`i-${invoice.invoice_id}`, () => api().issueInvoice(invoice.invoice_id),
                            t('billing.issuedNotice', { name: patient.patient_name }))}>
                          {t('billing.issue')}
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </section>
  );
}

export default function BillingPage() {
  return <OpsShell><BillingBoard /></OpsShell>;
}
