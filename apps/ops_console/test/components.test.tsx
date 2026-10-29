import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import type { ReactNode } from 'react';
import { ApiProvider } from '@/components/ApiProvider';
import { I18nProvider } from '@/components/I18nProvider';
import { CreateTrips } from '@/components/CreateTrips';
import { FareEditor } from '@/components/FareEditor';
import { ReassignTrip, type ReassignableTrip } from '@/components/ReassignTrip';
import { ScheduleAssignForm } from '@/components/ScheduleAssignForm';
import { DbError, type CompanionOption, type OpsApi, type ScheduleRow } from '@/lib/api';

const options: CompanionOption[] = [
  { companion_id: 'asha', full_name: 'Asha', verification_status: 'verified', active: true, distance_m: 520, radius_m: 3000, eligible: true, reason: null },
  { companion_id: 'ravi', full_name: 'Ravi', verification_status: 'verified', active: true, distance_m: 1900, radius_m: 3000, eligible: true, reason: null },
  { companion_id: 'far', full_name: 'Far', verification_status: 'verified', active: true, distance_m: 9100, radius_m: 3000, eligible: false, reason: 'outside_radius' },
];

const notEligible = new DbError({
  code: 'P0001', message: 'companion far is not eligible for patient p1',
  hint: 'must be verified, active, in the cluster and within its radius',
});

function fakeApi(overrides: Partial<OpsApi> = {}): OpsApi {
  return {
    scheduleBoard: vi.fn(), tripBoard: vi.fn(), exceptionQueue: vi.fn(), opsTransitions: vi.fn(), advanceTrip: vi.fn(),
    recordTripFare: vi.fn().mockResolvedValue(undefined), invoices: vi.fn(), generateInvoice: vi.fn(), issueInvoice: vi.fn(),
    companionOptions: vi.fn().mockResolvedValue(options),
    assignTripCompanion: vi.fn().mockResolvedValue(undefined),
    assignScheduleCompanions: vi.fn().mockResolvedValue(undefined),
    createScheduleTrips: vi.fn().mockResolvedValue([]),
    ...overrides,
  };
}

function wrap(api: OpsApi, ui: ReactNode) {
  return render(<I18nProvider><ApiProvider api={() => api}>{ui}</ApiProvider></I18nProvider>);
}

const trip: ReassignableTrip = {
  trip_id: 't1', patient_id: 'p1', status: 'scheduled', companion_id: 'asha',
  backup_companion_id: 'ravi', backup_companion_name: 'Ravi',
};

describe('ReassignTrip', () => {
  test('one tap assigns the schedule backup', async () => {
    const api = fakeApi();
    const onDone = vi.fn();
    wrap(api, <ReassignTrip trip={trip} onDone={onDone} />);
    fireEvent.click(screen.getByRole('button', { name: 'Assign backup: Ravi' }));
    await waitFor(() => expect(onDone).toHaveBeenCalledWith('Ravi'));
    expect(api.assignTripCompanion).toHaveBeenCalledWith('t1', 'ravi');
  });

  test('shows the database eligibility error when ops picks an ineligible companion', async () => {
    const api = fakeApi({ assignTripCompanion: vi.fn().mockRejectedValue(notEligible) });
    const onDone = vi.fn();
    wrap(api, <ReassignTrip trip={trip} onDone={onDone} />);
    fireEvent.click(screen.getByRole('button', { name: 'Reassign' }));
    const select = await screen.findByLabelText('Companion');
    expect(screen.getByRole('option', { name: /Far · 9.1 km · outside radius/ })).toBeTruthy();
    fireEvent.change(select, { target: { value: 'far' } });
    fireEvent.click(screen.getByRole('button', { name: 'Assign' }));
    const alert = await screen.findByRole('alert');
    expect(alert.textContent).toContain('not eligible for this patient');
    expect(alert.textContent).toContain('within its radius');
    expect(onDone).not.toHaveBeenCalled();
  });

  test('offers nothing once the trip has started', () => {
    const { container } = wrap(fakeApi(), <ReassignTrip trip={{ ...trip, status: 'picked_up' }} onDone={vi.fn()} />);
    expect(container.textContent).toBe('');
  });

  test('hides the backup shortcut when the backup is already on the trip', () => {
    wrap(fakeApi(), <ReassignTrip trip={{ ...trip, companion_id: 'ravi' }} onDone={vi.fn()} />);
    expect(screen.queryByRole('button', { name: /Assign backup/ })).toBeNull();
  });
});

describe('ScheduleAssignForm', () => {
  const schedule: ScheduleRow = {
    schedule_id: 's1', patient_id: 'p1', patient_name: 'Lakshmi', centre_name: 'Centre 1', cluster_id: 'c1',
    package_name: 'Basic', days_of_week: [1, 3, 5], pickup_time: '07:00:00', timezone: 'Asia/Kolkata', active: true,
    primary_companion_id: 'asha', primary_companion_name: 'Asha', backup_companion_id: 'ravi',
    backup_companion_name: 'Ravi', upcoming_trips: 6,
  };

  test('saves primary and backup through the RPC', async () => {
    const api = fakeApi();
    const onSaved = vi.fn();
    wrap(api, <ScheduleAssignForm schedule={schedule} onSaved={onSaved} onCancel={vi.fn()} />);
    await screen.findAllByRole('option', { name: /Far/ });
    fireEvent.change(screen.getByLabelText('Primary companion'), { target: { value: 'ravi' } });
    fireEvent.change(screen.getByLabelText('Backup companion'), { target: { value: 'asha' } });
    fireEvent.click(screen.getByRole('button', { name: 'Save' }));
    await waitFor(() => expect(onSaved).toHaveBeenCalled());
    expect(api.assignScheduleCompanions).toHaveBeenCalledWith('s1', 'ravi', 'asha');
  });

  test('shows the database error and stays open', async () => {
    const api = fakeApi({ assignScheduleCompanions: vi.fn().mockRejectedValue(notEligible) });
    const onSaved = vi.fn();
    wrap(api, <ScheduleAssignForm schedule={schedule} onSaved={onSaved} onCancel={vi.fn()} />);
    await screen.findAllByRole('option', { name: /Far/ });
    fireEvent.change(screen.getByLabelText('Backup companion'), { target: { value: 'far' } });
    fireEvent.click(screen.getByRole('button', { name: 'Save' }));
    expect((await screen.findByRole('alert')).textContent).toContain('not eligible');
    expect(onSaved).not.toHaveBeenCalled();
  });
});

describe('CreateTrips', () => {
  test('shows which dates were created and which were skipped', async () => {
    const api = fakeApi({ createScheduleTrips: vi.fn().mockResolvedValue([
      { pickup_date: '2026-10-28', pickup_at: '2026-10-28T01:30:00Z', created: false },
      { pickup_date: '2026-10-30', pickup_at: '2026-10-30T01:30:00Z', created: true },
    ]) });
    const onCreated = vi.fn();
    wrap(api, <CreateTrips scheduleId="s1" onCreated={onCreated} />);
    fireEvent.click(screen.getByRole('button', { name: 'Create trips' }));
    const status = await screen.findByRole('status');
    expect(api.createScheduleTrips).toHaveBeenCalledWith('s1');
    expect(onCreated).toHaveBeenCalled();
    expect(status.textContent).toContain('Created 1, skipped 1 (already scheduled).');
    expect(status.textContent).toContain('Already scheduled');
    expect(status.textContent).toMatch(/30 Oct.*Created/);
  });

  test('shows the database error and no result', async () => {
    const api = fakeApi({ createScheduleTrips: vi.fn().mockRejectedValue(new DbError({ code: '42501', message: 'ops only' })) });
    const onCreated = vi.fn();
    wrap(api, <CreateTrips scheduleId="s1" onCreated={onCreated} />);
    fireEvent.click(screen.getByRole('button', { name: 'Create trips' }));
    expect((await screen.findByRole('alert')).textContent).toBeTruthy();
    expect(screen.queryByRole('status')).toBeNull();
    expect(onCreated).not.toHaveBeenCalled();
  });
});

describe('FareEditor', () => {
  test('saves rupees as paise', async () => {
    const api = fakeApi();
    const onSaved = vi.fn();
    wrap(api, <FareEditor tripId="t1" farePaise={null} onSaved={onSaved} />);
    fireEvent.change(screen.getByLabelText('Fare (₹)'), { target: { value: '180.50' } });
    fireEvent.click(screen.getByRole('button', { name: 'Save fare' }));
    await waitFor(() => expect(onSaved).toHaveBeenCalled());
    expect(api.recordTripFare).toHaveBeenCalledWith('t1', 18050);
    expect(screen.getByRole('status').textContent).toBe('Fare saved.');
  });

  test('rejects text that is not an amount, without calling the database', () => {
    const api = fakeApi();
    wrap(api, <FareEditor tripId="t1" farePaise={18000} onSaved={vi.fn()} />);
    expect((screen.getByLabelText('Fare (₹)') as HTMLInputElement).value).toBe('180');
    fireEvent.change(screen.getByLabelText('Fare (₹)'), { target: { value: 'about 200' } });
    fireEvent.click(screen.getByRole('button', { name: 'Save fare' }));
    expect(screen.getByRole('status').textContent).toContain('Enter the fare in rupees');
    expect(api.recordTripFare).not.toHaveBeenCalled();
  });

  test('shows the database refusal (fare on an issued invoice)', async () => {
    const api = fakeApi({ recordTripFare: vi.fn().mockRejectedValue(new DbError({ code: '22023', message: 'trip is on an issued invoice' })) });
    wrap(api, <FareEditor tripId="t1" farePaise={null} onSaved={vi.fn()} />);
    fireEvent.change(screen.getByLabelText('Fare (₹)'), { target: { value: '90' } });
    fireEvent.click(screen.getByRole('button', { name: 'Save fare' }));
    expect((await screen.findByRole('alert')).textContent).toContain('trip is on an issued invoice');
  });
});
