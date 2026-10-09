// Amounts are stored in paise (integers). Ops types rupees.
const LOCALES = { en: 'en-IN', te: 'te-IN', hi: 'hi-IN' } as const;

export function formatRupees(paise: number, lang: keyof typeof LOCALES = 'en'): string {
  return new Intl.NumberFormat(LOCALES[lang], { style: 'currency', currency: 'INR', maximumFractionDigits: 2 })
    .format(paise / 100);
}

// "180", "180.5", "1,250.75", "₹ 99" -> paise; null when not a valid amount (max 2 decimals).
export function parseRupees(input: string): number | null {
  const cleaned = input.replace(/[₹,\s]/g, '');
  if (!/^\d+(\.\d{1,2})?$/.test(cleaned)) return null;
  const [whole, fraction = ''] = cleaned.split('.');
  return Number(whole) * 100 + Number(fraction.padEnd(2, '0'));
}

// First day of a month as YYYY-MM-01 from an <input type="month"> value (YYYY-MM).
export function monthStart(month: string): string {
  if (!/^\d{4}-\d{2}$/.test(month)) throw new Error(`invalid month ${month}`);
  return `${month}-01`;
}
