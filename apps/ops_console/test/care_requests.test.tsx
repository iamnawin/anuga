import { fireEvent, render, screen, waitFor, within } from '@testing-library/react';
import type { ReactNode } from 'react';
import SchedulesPage from '@/app/schedules/page';
import { ApiProvider } from '@/components/ApiProvider';
import { I18nProvider } from '@/components/I18nProvider';
import type { CareRequestRow, OpsApi, ScheduleRow } from '@/lib/api';

vi.mock('@/components/OpsShell', () => ({ OpsShell: ({ children }: { children: ReactNode }) => children }));

const schedule: ScheduleRow = {
  schedule_id: 'request-1', patient_id: 'p1', patient_name: 'Lakshmi (synthetic)', centre_name: 'Centre 1', cluster_id: 'c1',
  package_name: 'Basic', days_of_week: [3], pickup_time: '00:15:00', timezone: 'Asia/Kolkata', active: true,
  primary_companion_id: null, primary_companion_name: null, backup_companion_id: null,
  backup_companion_name: null, upcoming_trips: 0,
};
const request: CareRequestRow = {
  schedule_id: schedule.schedule_id, patient_id: schedule.patient_id, patient_name: schedule.patient_name,
  centre_id: 'centre1', centre_name: 'Centre 1', package_id: 'package1', package_name: 'Basic',
  pickup_at: '2027-02-09T18:45:00Z', trip_id: null, trip_status: null, companion_name: null, request_state: 'pending',
};
function apiFor(requests: CareRequestRow[]): OpsApi {
  return {
    scheduleBoard: vi.fn().mockResolvedValue([schedule]), careRequests: vi.fn().mockResolvedValue(requests),
    tripBoard: vi.fn(), exceptionQueue: vi.fn(), opsTransitions: vi.fn(), companionOptions: vi.fn(),
    assignScheduleCompanions: vi.fn(), createScheduleTrips: vi.fn().mockResolvedValue([]),
    confirmCareRequest: vi.fn().mockResolvedValue([]),
    assignTripCompanion: vi.fn(), advanceTrip: vi.fn(), recordTripFare: vi.fn(), invoices: vi.fn(),
    generateInvoice: vi.fn(), issueInvoice: vi.fn(),
  };
}
function show(api: OpsApi) {
  return render(<I18nProvider><ApiProvider api={() => api}><SchedulesPage /></ApiProvider></I18nProvider>);
}

describe('care requests in existing schedules workflow', () => {
  test('shows persisted pending request with exact IST date and uses consent-checked confirmation', async () => {
    const api = apiFor([request]);
    show(api);
    const card = (await screen.findByText('Lakshmi (synthetic)')).closest('li')!;
    expect(within(card).getByText('Care request')).toBeTruthy();
    expect(within(card).getByText('Pending ops')).toBeTruthy();
    expect(card.textContent).toContain('10 Feb');
    expect(card.textContent).toContain('00:15');
    fireEvent.click(within(card).getByRole('button', { name: 'Confirm request' }));
    await waitFor(() => expect(api.confirmCareRequest).toHaveBeenCalledWith('request-1'));
    expect(api.createScheduleTrips).not.toHaveBeenCalled();
  });

  test('uses backend assigned state and actual completed trip status', async () => {
    const api = apiFor([{ ...request, trip_id: 't1', trip_status: 'completed', companion_name: 'Asha', request_state: 'completed' }]);
    show(api);
    const card = (await screen.findByText('Lakshmi (synthetic)')).closest('li')!;
    expect(within(card).getByText('Completed')).toBeTruthy();
    expect(within(card).queryByText('Pending ops')).toBeNull();
  });

  test('ordinary weekly schedules keep the configured generation window', async () => {
    const api = apiFor([]);
    show(api);
    await screen.findByText('Lakshmi (synthetic)');
    expect(screen.queryByText('Care request')).toBeNull();
    fireEvent.click(screen.getByRole('button', { name: 'Create trips' }));
    await waitFor(() => expect(api.createScheduleTrips).toHaveBeenCalledWith('request-1'));
  });
});
