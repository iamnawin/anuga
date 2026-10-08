// Display helpers. Trips are stored in UTC; ops works in India time.
export const OPS_TIME_ZONE = 'Asia/Kolkata';

const LOCALES = { en: 'en-IN', te: 'te-IN', hi: 'hi-IN' } as const;

export function formatDateTime(iso: string, lang: keyof typeof LOCALES = 'en'): string {
  return new Intl.DateTimeFormat(LOCALES[lang], {
    timeZone: OPS_TIME_ZONE, weekday: 'short', day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit',
    hour12: false,
  }).format(new Date(iso));
}

// '07:00:00' -> '07:00'
export function formatClock(time: string): string {
  return time.slice(0, 5);
}

export function formatKm(metres: number): string {
  return (metres / 1000).toFixed(1);
}

// Start of a calendar day in India time, as an absolute instant.
// IST has no daylight saving: always UTC+05:30.
export function istDayStart(day: string): Date {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(day)) throw new Error(`invalid day ${day}`);
  return new Date(`${day}T00:00:00+05:30`);
}

// Range covering `days` whole India-time days starting at `day`.
export function istRange(day: string, days: number): { from: Date; to: Date } {
  const from = istDayStart(day);
  const to = new Date(from.getTime() + days * 24 * 60 * 60 * 1000 - 1);
  return { from, to };
}

// Today's date in India time as YYYY-MM-DD.
export function istToday(now: Date = new Date()): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone: OPS_TIME_ZONE, year: 'numeric', month: '2-digit', day: '2-digit' })
    .format(now);
}
