// Ops console data layer. The database decides who may do what (grants, RLS,
// security-definer RPCs); this module only shapes requests and results.
// Pure helpers here are unit-tested with node:test (src/lib/ops.test.ts).

export const TIME_ZONE = 'Asia/Kolkata';

export const TRIP_STATUSES = [
  'scheduled', 'companion_en_route', 'picked_up', 'at_centre', 'handed_over',
  'session_done', 'returning', 'dropped_home', 'completed',
  'cancelled', 'no_show', 'issue_reported',
] as const;
export type TripStatus = (typeof TRIP_STATUSES)[number];

export interface DbError {
  message: string;
  code?: string;
  hint?: string | null;
  details?: string | null;
}

type Result = { data: unknown; error: DbError | null };

// The subset of the Supabase client this module uses; tests pass a fake.
export interface OpsClient {
  rpc(fn: string, params: Record<string, unknown>): PromiseLike<Result>;
  from(table: string): QueryBuilder;
}

interface QueryBuilder extends PromiseLike<Result> {
  select(columns: string): QueryBuilder;
  eq(column: string, value: unknown): QueryBuilder;
  in(column: string, values: unknown[]): QueryBuilder;
  gte(column: string, value: unknown): QueryBuilder;
  lt(column: string, value: unknown): QueryBuilder;
  or(filter: string): QueryBuilder;
  order(column: string, options?: { ascending?: boolean }): QueryBuilder;
  maybeSingle(): PromiseLike<Result>;
}

export class OpsError extends Error {
  readonly code?: string;
  constructor(message: string, code?: string) {
    super(message);
    this.name = 'OpsError';
    this.code = code;
  }
}

// Turns a database error into text an ops user can act on. Eligibility and
// state errors come from the RPCs and are shown as written there.
export function describeDbError(error: DbError): string {
  switch (error.code) {
    case '42501':
      return 'Not allowed for this account.';
    case 'P0002':
      return 'Not found. Refresh and try again.';
    case 'P0001':
    case '22023':
      return error.hint ? `${error.message} (${error.hint})` : error.message;
    default:
      return error.message || 'Something went wrong. Try again.';
  }
}

function unwrap<T>({ data, error }: Result): T {
  if (error) throw new OpsError(describeDbError(error), error.code);
  return data as T;
}

// Accepts "9000000001", "09000000001", "+91 90000 00001" etc. and returns E.164.
// Only Indian mobile numbers are accepted in the MVP.
export function normalizeIndianPhone(input: string): string | null {
  let digits = input.replace(/[^\d]/g, '');
  if (digits.length === 12 && digits.startsWith('91')) digits = digits.slice(2);
  else if (digits.length === 11 && digits.startsWith('0')) digits = digits.slice(1);
  return /^[6-9]\d{9}$/.test(digits) ? `+91${digits}` : null;
}

// [start, end) of a calendar day in IST as UTC ISO strings. IST has no DST.
export function istDayRange(day: string): { from: string; to: string } {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(day)) throw new RangeError(`invalid day: ${day}`);
  const start = new Date(`${day}T00:00:00+05:30`);
  const end = new Date(start.getTime() + 24 * 60 * 60 * 1000);
  return { from: start.toISOString(), to: end.toISOString() };
}

export function istToday(now: Date = new Date()): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone: TIME_ZONE }).format(now);
}

export function formatIstTime(iso: string): string {
  return new Intl.DateTimeFormat('en-IN', {
    timeZone: TIME_ZONE, weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit',
  }).format(new Date(iso));
}

const WEEKDAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
export function formatDays(isoDays: number[]): string {
  return [...isoDays].sort((a, b) => a - b).map((d) => WEEKDAYS[d - 1] ?? `?${d}`).join(', ');
}

// Models ---------------------------------------------------------------------

export interface Companion {
  id: string;
  name: string;
  verificationStatus: 'pending' | 'verified' | 'suspended';
  active: boolean;
}

export interface Trip {
  id: string;
  status: TripStatus;
  scheduledPickupAt: string;
  scheduledReturnAt: string;
  patientName: string;
  centreName: string;
  companionId: string | null;
  primaryCompanionId: string | null;
  backupCompanionId: string | null;
}

export interface Schedule {
  id: string;
  patientName: string;
  packageName: string;
  daysOfWeek: number[];
  pickupTime: string;
  active: boolean;
  primaryCompanionId: string | null;
  backupCompanionId: string | null;
}

type Json = Record<string, unknown>;
const obj = (v: unknown): Json => (v && typeof v === 'object' ? (v as Json) : {});

export function toCompanion(row: Json): Companion {
  return {
    id: row.id as string,
    name: (obj(row.profile).full_name as string) || 'Unnamed companion',
    verificationStatus: row.verification_status as Companion['verificationStatus'],
    active: row.active as boolean,
  };
}

export function toTrip(row: Json): Trip {
  const schedule = obj(row.schedule);
  return {
    id: row.id as string,
    status: row.status as TripStatus,
    scheduledPickupAt: row.scheduled_pickup_at as string,
    scheduledReturnAt: row.scheduled_return_at as string,
    patientName: (obj(row.patient).full_name as string) ?? '',
    centreName: (obj(row.centre).name as string) ?? '',
    companionId: (row.companion_id as string | null) ?? null,
    primaryCompanionId: (schedule.primary_companion_id as string | null) ?? null,
    backupCompanionId: (schedule.backup_companion_id as string | null) ?? null,
  };
}

export function toSchedule(row: Json): Schedule {
  return {
    id: row.id as string,
    patientName: (obj(row.patient).full_name as string) ?? '',
    packageName: (obj(row.package).name as string) ?? '',
    daysOfWeek: row.days_of_week as number[],
    pickupTime: String(row.pickup_time).slice(0, 5),
    active: row.active as boolean,
    primaryCompanionId: (row.primary_companion_id as string | null) ?? null,
    backupCompanionId: (row.backup_companion_id as string | null) ?? null,
  };
}

// Exceptions -------------------------------------------------------------------

export type ExceptionKind = 'issue_reported' | 'no_show' | 'late';

// A trip is late when its pickup time has passed and nobody has set off.
export function exceptionKind(trip: Pick<Trip, 'status' | 'scheduledPickupAt'>, now: Date): ExceptionKind | null {
  if (trip.status === 'issue_reported' || trip.status === 'no_show') return trip.status;
  if (trip.status === 'scheduled' && new Date(trip.scheduledPickupAt) < now) return 'late';
  return null;
}

// The trip's next companion if ops "uses the backup": the schedule's backup,
// unless it is already on the trip.
export function backupFor(trip: Trip): string | null {
  return trip.backupCompanionId && trip.backupCompanionId !== trip.companionId ? trip.backupCompanionId : null;
}

// Queries ----------------------------------------------------------------------

const TRIP_COLUMNS = `id, status, scheduled_pickup_at, scheduled_return_at, companion_id,
  patient:patients(full_name), centre:centres(name),
  schedule:schedules(primary_companion_id, backup_companion_id)`;

export async function currentRole(client: OpsClient, userId: string): Promise<string | null> {
  const row = unwrap<Json | null>(await client.from('profiles').select('role').eq('id', userId).maybeSingle());
  return (row?.role as string | undefined) ?? null;
}

export async function listCompanions(client: OpsClient): Promise<Companion[]> {
  const rows = unwrap<Json[]>(await client.from('companions')
    .select('id, verification_status, active, profile:profiles(full_name)')
    .order('id'));
  return rows.map(toCompanion).sort((a, b) => a.name.localeCompare(b.name));
}

export async function listTrips(
  client: OpsClient, filter: { day: string; status?: TripStatus | '' },
): Promise<Trip[]> {
  const { from, to } = istDayRange(filter.day);
  let query = client.from('trips').select(TRIP_COLUMNS)
    .gte('scheduled_pickup_at', from).lt('scheduled_pickup_at', to);
  if (filter.status) query = query.eq('status', filter.status);
  return unwrap<Json[]>(await query.order('scheduled_pickup_at')).map(toTrip);
}

// Exceptions from the last `days` days: issue_reported, no_show, or late.
export async function listExceptions(client: OpsClient, now: Date, days = 7): Promise<Array<Trip & { kind: ExceptionKind }>> {
  const since = new Date(now.getTime() - days * 24 * 60 * 60 * 1000).toISOString();
  const rows = unwrap<Json[]>(await client.from('trips').select(TRIP_COLUMNS)
    .gte('scheduled_pickup_at', since)
    .or(`status.in.(issue_reported,no_show),and(status.eq.scheduled,scheduled_pickup_at.lt.${now.toISOString()})`)
    .order('scheduled_pickup_at'));
  return rows.map(toTrip).flatMap((trip) => {
    const kind = exceptionKind(trip, now);
    return kind ? [{ ...trip, kind }] : [];
  });
}

export async function listSchedules(client: OpsClient): Promise<Schedule[]> {
  const rows = unwrap<Json[]>(await client.from('schedules')
    .select(`id, days_of_week, pickup_time, active, primary_companion_id, backup_companion_id,
      patient:patients(full_name), package:packages(name)`)
    .order('created_at'));
  return rows.map(toSchedule);
}

// Commands (authorized and validated by the database) ----------------------------

export async function assignScheduleCompanions(
  client: OpsClient, scheduleId: string, primaryId: string, backupId: string,
): Promise<void> {
  unwrap(await client.rpc('ops_assign_schedule_companions', {
    p_schedule_id: scheduleId, p_primary_id: primaryId, p_backup_id: backupId,
  }));
}

export async function assignTripCompanion(client: OpsClient, tripId: string, companionId: string): Promise<void> {
  unwrap(await client.rpc('ops_assign_trip_companion', { p_trip_id: tripId, p_companion_id: companionId }));
}
