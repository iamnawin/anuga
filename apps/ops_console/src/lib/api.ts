// Typed wrappers over the database RPCs the ops console uses. The database is the
// security boundary: every function here is checked again in SQL (ops only), so
// this layer only shapes data and surfaces database errors unchanged.

export type TripStatus =
  | 'scheduled' | 'companion_en_route' | 'picked_up' | 'at_centre' | 'handed_over'
  | 'session_done' | 'returning' | 'dropped_home' | 'completed'
  | 'cancelled' | 'no_show' | 'issue_reported';

export const TRIP_STATUSES: readonly TripStatus[] = [
  'scheduled', 'companion_en_route', 'picked_up', 'at_centre', 'handed_over',
  'session_done', 'returning', 'dropped_home', 'completed', 'cancelled', 'no_show', 'issue_reported',
];

export interface ScheduleRow {
  schedule_id: string;
  patient_id: string;
  patient_name: string;
  centre_name: string;
  cluster_id: string;
  package_name: string;
  days_of_week: number[];
  pickup_time: string;
  timezone: string;
  active: boolean;
  primary_companion_id: string | null;
  primary_companion_name: string | null;
  backup_companion_id: string | null;
  backup_companion_name: string | null;
  upcoming_trips: number;
}

export interface TripRow {
  trip_id: string;
  scheduled_pickup_at: string;
  scheduled_return_at: string;
  status: TripStatus;
  status_before_issue: TripStatus | null;
  patient_id: string;
  patient_name: string;
  centre_name: string;
  cluster_id: string;
  companion_id: string | null;
  companion_name: string | null;
  schedule_id: string | null;
  primary_companion_id: string | null;
  primary_companion_name: string | null;
  backup_companion_id: string | null;
  backup_companion_name: string | null;
  is_late: boolean;
  updated_at: string;
  fare_amount_paise: number | null;
}

export type ExceptionKind = 'late' | 'no_show' | 'issue_reported';

export interface ExceptionRow {
  trip_id: string;
  kind: ExceptionKind;
  status: TripStatus;
  status_before_issue: TripStatus | null;
  scheduled_pickup_at: string;
  patient_id: string;
  patient_name: string;
  centre_name: string;
  companion_id: string | null;
  companion_name: string | null;
  backup_companion_id: string | null;
  backup_companion_name: string | null;
  last_note: string | null;
  since: string;
}

export type IneligibleReason = 'inactive' | 'not_verified' | 'outside_radius';

export interface CompanionOption {
  companion_id: string;
  full_name: string;
  verification_status: 'pending' | 'verified' | 'suspended';
  active: boolean;
  distance_m: number;
  radius_m: number;
  eligible: boolean;
  reason: IneligibleReason | null;
}

export type InvoiceStatus = 'draft' | 'issued' | 'paid' | 'void';

export interface InvoiceRow {
  invoice_id: string;
  patient_id: string;
  patient_name: string;
  package_name: string;
  period_start: string;
  status: InvoiceStatus;
  total_paise: number;
  visits: number;
  fares_paise: number;
  paid_at: string | null;
}

export interface Transition {
  from_status: TripStatus;
  to_status: TripStatus;
  actor: 'companion' | 'ops' | 'family';
  requires_otp: boolean;
}

// A Postgres error as PostgREST reports it (code is the SQLSTATE).
export class DbError extends Error {
  readonly code: string;
  readonly hint: string | null;
  readonly details: string | null;

  constructor(error: { code?: string; message: string; hint?: string | null; details?: string | null }) {
    super(error.message);
    this.name = 'DbError';
    this.code = error.code ?? '';
    this.hint = error.hint ?? null;
    this.details = error.details ?? null;
  }
}

export interface PgResult<T> {
  data: T | null;
  error: { code?: string; message: string; hint?: string | null; details?: string | null } | null;
}

// The subset of the Supabase client this module needs, so tests can pass a fake.
export interface RpcClient {
  rpc(fn: string, args?: Record<string, unknown>): PromiseLike<PgResult<unknown>>;
  from(table: string): {
    select(columns: string): {
      eq(column: string, value: string): PromiseLike<PgResult<unknown>>;
    };
  };
}

async function call<T>(promise: PromiseLike<PgResult<unknown>>): Promise<T> {
  const { data, error } = await promise;
  if (error) throw new DbError(error);
  return data as T;
}

export interface OpsApi {
  scheduleBoard(): Promise<ScheduleRow[]>;
  tripBoard(from: Date, to: Date, statuses?: TripStatus[]): Promise<TripRow[]>;
  exceptionQueue(): Promise<ExceptionRow[]>;
  companionOptions(patientId: string): Promise<CompanionOption[]>;
  opsTransitions(): Promise<Transition[]>;
  assignScheduleCompanions(scheduleId: string, primaryId: string, backupId: string): Promise<void>;
  updateSchedulePattern(scheduleId: string, days: number[], expectedDays: number[]): Promise<{ cancelled: number; generated: number }>;
  assignTripCompanion(tripId: string, companionId: string): Promise<void>;
  advanceTrip(tripId: string, to: TripStatus, note: string | null): Promise<void>;
  recordTripFare(tripId: string, farePaise: number): Promise<void>;
  invoices(monthStart: string): Promise<InvoiceRow[]>;
  generateInvoice(patientId: string, monthStart: string): Promise<string>;
  issueInvoice(invoiceId: string): Promise<void>;
}

export function createOpsApi(client: RpcClient): OpsApi {
  return {
    scheduleBoard: () => call(client.rpc('ops_schedule_board')),
    updateSchedulePattern: (scheduleId, days, expectedDays) => call(client.rpc('ops_update_schedule_pattern', {
      p_schedule_id: scheduleId, p_days_of_week: days, p_expected_days: expectedDays,
    })),
    tripBoard: (from, to, statuses) => call(client.rpc('ops_trip_board', {
      p_from: from.toISOString(),
      p_to: to.toISOString(),
      p_statuses: statuses && statuses.length > 0 ? statuses : null,
    })),
    exceptionQueue: () => call(client.rpc('ops_exception_queue')),
    companionOptions: (patientId) => call(client.rpc('ops_companion_options', { p_patient_id: patientId })),
    opsTransitions: () => call(client.from('trip_transitions').select('from_status,to_status,actor,requires_otp').eq('actor', 'ops')),
    assignScheduleCompanions: async (scheduleId, primaryId, backupId) => {
      await call(client.rpc('ops_assign_schedule_companions', {
        p_schedule_id: scheduleId, p_primary_id: primaryId, p_backup_id: backupId,
      }));
    },
    assignTripCompanion: async (tripId, companionId) => {
      await call(client.rpc('ops_assign_trip_companion', { p_trip_id: tripId, p_companion_id: companionId }));
    },
    advanceTrip: async (tripId, to, note) => {
      await call(client.rpc('advance_trip', { p_trip_id: tripId, p_to_status: to, p_note: note }));
    },
    recordTripFare: async (tripId, farePaise) => {
      await call(client.rpc('ops_record_trip_fare', { p_trip_id: tripId, p_fare_paise: farePaise }));
    },
    invoices: (month) => call(client.rpc('ops_invoices', { p_month: month })),
    generateInvoice: (patientId, month) => call(client.rpc('ops_generate_invoice', { p_patient_id: patientId, p_month: month })),
    issueInvoice: async (invoiceId) => {
      await call(client.rpc('ops_issue_invoice', { p_invoice_id: invoiceId }));
    },
  };
}

// Ops actions offered for a trip, derived from the transitions table (rules as data).
// Steps that need the pickup OTP are never offered to ops.
export function opsActionsFor(status: TripStatus, transitions: Transition[]): TripStatus[] {
  return transitions
    .filter((t) => t.actor === 'ops' && t.from_status === status && !t.requires_otp)
    .map((t) => t.to_status);
}
