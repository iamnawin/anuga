// Real synthetic three-role issue handling. No mocked responses or rule bypasses.
import { expect, test, type Locator, type Page } from '@playwright/test';
import { mkdirSync, writeFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';

test.skip(!process.env.CARE_REQUEST_JOURNEY, 'CARE_REQUEST_JOURNEY=1 with real Supabase and built PWA');
test.use({ trace: 'off', screenshot: 'off', video: 'off' });
const shots = 'test-results/issue-handling';
const preview = process.env.CARE_PREVIEW_URL;
const pwa = preview ? `${preview}/app/` : 'http://127.0.0.1:3103/app/';
const opsPath = (path: string) => preview ? `/ops${path}/` : path;
const isRpc = (url: string, name: string) => new URL(url).pathname === `/rest/v1/rpc/${name}`;

async function enableFlutter(page: Page) {
  await page.getByRole('button', { name: 'Enable accessibility' }).evaluate((node) => (node as HTMLElement).click());
}

async function revealFlutter(page: Page, locator: Locator) {
  for (let i = 0; i < 20; i++) {
    if (await locator.isVisible()) return;
    await page.mouse.move(190, 650);
    await page.mouse.wheel(0, 500);
    await page.waitForTimeout(150);
  }
  await expect(locator).toBeVisible();
}

async function enterFlutter(page: Page, name: string, value: string) {
  await page.getByRole('textbox', { name: name === 'Mobile number' ? /^Mobile number\b/ : name, exact: true }).click();
  await page.waitForTimeout(350);
  await page.keyboard.press('ArrowLeft');
  await page.waitForTimeout(150);
  await page.keyboard.press('ControlOrMeta+A');
  await page.keyboard.insertText(value);
}

async function identity(page: Page, phone: string, action = 'Sign in') {
  const verified = page.waitForResponse((r) => new URL(r.url()).pathname === '/auth/v1/verify');
  await page.getByRole('button', { name: action, exact: true }).click();
  const response = await verified;
  expect(response.status()).toBe(200);
  const { user } = await response.json() as { user: { id: string; phone: string } };
  expect(user.phone.replace(/^\+/, '')).toBe(`91${phone}`);
  return { user_id: user.id, phone: user.phone };
}

test('underway issue -> internal ops resolution -> same companion completes -> Family sees service progress only', async ({ browser }) => {
  test.setTimeout(240_000);
  mkdirSync(shots, { recursive: true });
  const familyContext = await browser.newContext({ viewport: { width: 390, height: 844 }, hasTouch: true });
  const companionContext = await browser.newContext({ viewport: { width: 390, height: 844 }, hasTouch: true });
  const opsContext = await browser.newContext({ baseURL: preview ?? `http://127.0.0.1:${process.env.OPS_CONSOLE_PORT ?? 3000}` });
  const family = await familyContext.newPage();
  const companion = await companionContext.newPage();
  const ops = await opsContext.newPage();
  const receipt: Record<string, unknown> = {
    backend: preview ? 'Existing hosted synthetic Supabase: real Auth/Postgres/RPCs/RLS' : 'Supabase local: real Auth/Postgres/RPCs/RLS',
    surface: 'desktop Chromium phone viewport; no physical-device claim',
    current_stage: 'Family request',
  };
  const otp = preview ? process.env.CARE_TEST_OTP : '123456';
  if (!otp) throw new Error('Set CARE_TEST_OTP for the synthetic preview; never record the code.');
  const issueMarker = `Internal transport issue ${randomUUID()} (synthetic)`;
  const resolutionMarker = `Internal transport resolution ${randomUUID()} (synthetic)`;
  const containsPrivate = (body: unknown) => [issueMarker, resolutionMarker].some((marker) => JSON.stringify(body).includes(marker));
  try {
    await family.goto(pwa);
    await enableFlutter(family);
    await family.getByRole('button', { name: 'Get started', exact: true }).click();
    await enterFlutter(family, 'Mobile number', '9000000101');
    await family.getByRole('button', { name: 'Send verification code', exact: true }).click();
    await enterFlutter(family, '6-digit code', otp);
    const familyIdentity = await identity(family, '9000000101', 'Verify code');
    receipt.family_identity = familyIdentity;
    await family.getByRole('button', { name: 'Request care', exact: true }).click();
    await family.getByText('Package', { exact: true }).click();
    await family.getByRole('menuitem', { name: 'Basic', exact: true }).click();
    const pickup = process.env.ISSUE_PICKUP_AT ? new Date(process.env.ISSUE_PICKUP_AT)
      : new Date(Math.ceil(Date.now() / 60_000) * 60_000 + (60 + Math.floor(Math.random() * 20)) * 60_000);
    if (pickup.getUTCHours() === 1 && pickup.getUTCMinutes() === 30) pickup.setUTCMinutes(31);
    const ist = new Date(pickup.getTime() + 330 * 60_000).toISOString();
    const day = ist.slice(0, 10);
    const time = ist.slice(11, 16);
    receipt.pickup_ist = `${day} ${time}`;
    await enterFlutter(family, 'Pickup date (IST)', day);
    await enterFlutter(family, 'Pickup time (IST)', time);
    await family.getByRole('button', { name: 'Review request', exact: true }).click();
    const submitted = family.waitForResponse((r) => isRpc(r.url(), 'family_request_care'));
    await family.getByRole('button', { name: 'Submit request', exact: true }).click();
    const submission = await submitted;
    expect(submission.status()).toBe(200);
    const scheduleId = await submission.json() as string;
    receipt.schedule_id = scheduleId;
    const rest = new URL('/rest/v1/', submission.url()).href;
    const familyHeaders = Object.fromEntries(Object.entries(await submission.request().allHeaders())
      .filter(([name]) => ['authorization', 'apikey', 'content-type'].includes(name)));
    const familyCard = (label: string) => family.getByRole('group', { name: new RegExp(`${time}\\s+${label}`) }).first();

    await ops.goto(opsPath('/login'));
    await ops.getByLabel('Mobile number').fill('9000000001');
    await ops.getByRole('button', { name: 'Send code' }).click();
    await ops.getByLabel('6-digit code').fill(otp);
    receipt.ops_identity = await identity(ops, '9000000001');
    await expect(ops).toHaveURL(/\/trips\/?$/);
    await ops.goto(opsPath('/schedules'));
    const schedule = ops.locator(`[data-schedule-id="${scheduleId}"]`);
    const confirmed = ops.waitForResponse((r) => isRpc(r.url(), 'ops_confirm_care_request'));
    await schedule.getByRole('button', { name: 'Confirm request', exact: true }).click();
    const confirmation = await confirmed;
    expect(confirmation.status()).toBe(200);
    const opsHeaders = Object.fromEntries(Object.entries(await confirmation.request().allHeaders())
      .filter(([name]) => ['authorization', 'apikey', 'content-type'].includes(name)));
    await expect(schedule.getByText('Confirmed', { exact: true })).toBeVisible();
    await schedule.getByRole('button', { name: 'Change companions', exact: true }).click();
    const primary = schedule.getByLabel('Primary companion');
    const backup = schedule.getByLabel('Backup companion');
    const asha = await primary.locator('option').filter({ hasText: 'Asha Companion (synthetic)' }).getAttribute('value');
    const ravi = await backup.locator('option').filter({ hasText: 'Ravi Companion (synthetic)' }).getAttribute('value');
    expect(Boolean(asha && ravi)).toBe(true);
    await primary.selectOption(asha!);
    await backup.selectOption(ravi!);
    await schedule.getByRole('button', { name: 'Save', exact: true }).click();
    await expect(schedule.getByText('Assigned', { exact: true })).toBeVisible();
    const assignedRead = family.waitForResponse((r) => isRpc(r.url(), 'family_care_requests'));
    await family.reload();
    await enableFlutter(family);
    const assignedRows = await (await assignedRead).json() as { schedule_id: string; trip_id: string; request_state: string }[];
    const assigned = assignedRows.find((row) => row.schedule_id === scheduleId)!;
    expect(assigned.request_state).toBe('assigned');
    const tripId = assigned.trip_id;
    receipt.trip_id = tripId;
    const patientId = (submission.request().postDataJSON() as { p_patient_id: string }).p_patient_id;
    await revealFlutter(family, familyCard('Confirmed · companion assigned'));
    await familyCard('Confirmed · companion assigned').getByRole('button', { name: 'Open visit', exact: true }).click();
    await expect(family.getByRole('button', { name: 'Get pickup code', exact: true })).toBeVisible();

    await companion.goto(pwa);
    await enableFlutter(companion);
    await companion.getByRole('button', { name: 'Get started', exact: true }).click();
    await enterFlutter(companion, 'Mobile number', '9000000201');
    await companion.getByRole('button', { name: 'Send verification code', exact: true }).click();
    await enterFlutter(companion, '6-digit code', otp);
    const companionRead = companion.waitForResponse((r) => isRpc(r.url(), 'companion_my_trips'));
    const companionIdentity = await identity(companion, '9000000201', 'Verify code');
    receipt.companion_identity = companionIdentity;
    expect(companionIdentity.user_id).toBe(asha);
    const companionTrips = await (await companionRead).json() as { trip_id: string; status: string; details_visible: boolean }[];
    const companionTrip = companionTrips.find((row) => row.trip_id === tripId);
    expect(companionTrip?.status).toBe('scheduled');
    expect(companionTrip?.details_visible).toBe(true);
    const companionTile = () => companion.getByRole('group', { name: new RegExp(`${time}.*Lakshmi Rao`) }).first();
    await revealFlutter(companion, companionTile());
    await companionTile().click();
    const advance = async (button: string, status: string, note?: string) => {
      receipt.current_stage = status;
      const response = companion.waitForResponse((r) => isRpc(r.url(), 'advance_trip'));
      await companion.getByRole('button', { name: button, exact: true }).click();
      if (note !== undefined) {
        await enterFlutter(companion, '', note);
        await companion.getByRole('button', { name: 'Submit', exact: true }).click();
      }
      const result = await response;
      expect(result.status()).toBe(200);
      const body = await result.json();
      const row = Array.isArray(body) ? body[0] : body;
      expect(row.id).toBe(tripId);
      expect(row.status).toBe(status);
    };
    const refreshFamily = async (status: string, label: string) => {
      const boardRead = family.waitForResponse((r) => isRpc(r.url(), 'family_trip_board'));
      const timelineRead = family.waitForResponse((r) => isRpc(r.url(), 'family_trip_timeline'));
      await family.getByRole('button', { name: /^Refresh(?: Refresh)?$/ }).click();
      const board = await (await boardRead).json() as { trip_id: string; status: string }[];
      const timeline = await (await timelineRead).json() as { to_status: string; created_at: string; note: string | null }[];
      expect(board.find((row) => row.trip_id === tripId)?.status).toBe(status);
      expect(timeline.at(-1)?.to_status).toBe(status);
      expect(containsPrivate(timeline)).toBe(false);
      await expect(family.getByRole('checkbox', { name: label, exact: true })).toBeVisible();
      return timeline;
    };
    await advance("I'm on my way", 'companion_en_route');
    await refreshFamily('companion_en_route', 'Companion on the way');
    const issued = family.waitForResponse((r) => isRpc(r.url(), 'issue_pickup_otp'));
    await family.getByRole('button', { name: 'Get pickup code', exact: true }).click();
    const code = await (await issued).json() as string;
    expect(/^\d{6}$/.test(code)).toBe(true);
    await family.getByRole('button', { name: 'Close', exact: true }).click();
    await enterFlutter(companion, 'Pickup code from the family', code);
    const verified = companion.waitForResponse((r) => isRpc(r.url(), 'verify_pickup_otp'));
    await companion.getByRole('button', { name: 'Verify code and pick up', exact: true }).click();
    const verification = await (await verified).json() as { ok: boolean; status: string };
    expect(verification.ok && verification.status === 'picked_up').toBe(true);
    const pickupRead = await opsContext.request.get(`${rest}trips?id=eq.${tripId}&select=picked_up_at`, { headers: opsHeaders });
    expect(pickupRead.status()).toBe(200);
    const [originalPickup] = await pickupRead.json() as { picked_up_at: string }[];
    expect(originalPickup.picked_up_at).toBeTruthy();
    await refreshFamily('picked_up', 'Picked up');
    await companion.screenshot({ path: `${shots}/01-companion-underway.png` });

    await advance('Report an issue', 'issue_reported', issueMarker);
    const issueEvents = await refreshFamily('issue_reported', 'Service issue');
    receipt.issue_reported_at = issueEvents.at(-1)!.created_at;
    await family.screenshot({ path: `${shots}/02-family-service-issue.png` });
    const queueRead = ops.waitForResponse((r) => isRpc(r.url(), 'ops_exception_queue'));
    await ops.goto(opsPath('/exceptions'));
    const queueRows = await (await queueRead).json() as { trip_id: string; status: string; status_before_issue: string; companion_id: string; last_note: string }[];
    const queued = queueRows.find((row) => row.trip_id === tripId)!;
    expect(queued.status).toBe('issue_reported');
    expect(queued.status_before_issue).toBe('picked_up');
    expect(queued.companion_id).toBe(asha);
    expect(queued.last_note === issueMarker).toBe(true);
    const issue = ops.locator(`[data-trip-id="${tripId}"][data-kind="issue_reported"]`);
    await expect(issue.getByText(issueMarker, { exact: true })).toBeVisible();
    await expect(issue.getByText('Picked up', { exact: true })).toBeVisible();
    await expect(issue.locator('[data-col="companion"]')).toHaveText('Asha Companion (synthetic)');
    await issue.screenshot({ path: `${shots}/03-ops-internal-issue.png` });

    // Deliberate authenticated denied-action check: no caller-side bypass,
    // and no other trip is touched. The backend must keep the underway assignee.
    const reassignment = await opsContext.request.post(`${rest}rpc/ops_assign_trip_companion`, {
      headers: opsHeaders, data: { p_trip_id: tripId, p_companion_id: ravi },
    });
    expect([400, 403].includes(reassignment.status())).toBe(true);
    const rejection = await reassignment.json() as { code: string };
    expect(['22023', '42501'].includes(rejection.code)).toBe(true);
    receipt.underway_reassignment_denied = true;

    const privacyCheck = async () => {
      const checks: Record<string, boolean> = {};
      for (const [fn, data] of [
        ['family_trip_timeline', { p_trip_id: tripId }],
        ['family_trip_board', { p_patient_id: patientId }],
        ['family_care_requests', { p_patient_id: patientId }],
        ['my_notifications', {}],
      ] as const) {
        const response = await familyContext.request.post(`${rest}rpc/${fn}`, { headers: familyHeaders, data });
        expect(response.status()).toBe(200);
        checks[fn] = !containsPrivate(await response.json());
        expect(checks[fn]).toBe(true);
      }
      for (const [table, filter] of [['trips', `id=eq.${tripId}`], ['trip_events', `trip_id=eq.${tripId}`], ['notifications', `trip_id=eq.${tripId}`]]) {
        const response = await familyContext.request.get(`${rest}${table}?${filter}&select=*`, { headers: familyHeaders });
        expect([200, 403].includes(response.status())).toBe(true);
        checks[`direct_${table}`] = !containsPrivate(await response.json());
        expect(checks[`direct_${table}`]).toBe(true);
      }
      return checks;
    };
    receipt.family_private_notes_absent_during_issue = await privacyCheck();
    await issue.getByLabel('Resolution note (internal, optional)', { exact: true }).fill(resolutionMarker);
    receipt.current_stage = 'Ops resumes picked_up';
    ops.once('dialog', async (dialog) => {
      expect(dialog.message()).toContain('Picked up');
      await dialog.accept();
    });
    const resolved = ops.waitForResponse((r) => isRpc(r.url(), 'ops_resolve_visit_issue'));
    await issue.getByRole('button', { name: 'Move to: Picked up', exact: true }).click();
    const resolution = await resolved;
    expect(resolution.status()).toBe(200);
    const resolutionBody = await resolution.json();
    const resumedTrip = Array.isArray(resolutionBody) ? resolutionBody[0] : resolutionBody;
    expect(resumedTrip.picked_up_at).toBe(originalPickup.picked_up_at);
    receipt.original_pickup_time_preserved = true;
    await expect(issue).toHaveCount(0);
    const resumedEvents = await refreshFamily('picked_up', 'Picked up');
    receipt.resumed_at = resumedEvents.at(-1)!.created_at;
    receipt.family_private_notes_absent_after_resolution = await privacyCheck();
    const resumedFamilyRead = family.waitForResponse((r) => isRpc(r.url(), 'family_care_requests'));
    await family.reload();
    await enableFlutter(family);
    const resumedRequests = await (await resumedFamilyRead).json() as {
      schedule_id: string; trip_id: string; request_state: string; companion_name: string;
    }[];
    const resumedRequest = resumedRequests.find((row) => row.schedule_id === scheduleId)!;
    expect(resumedRequest.trip_id).toBe(tripId);
    expect(resumedRequest.request_state).toBe('picked_up');
    expect(resumedRequest.companion_name).toBe('Asha Companion (synthetic)');
    await revealFlutter(family, familyCard('Picked up'));
    await familyCard('Picked up').getByRole('button', { name: 'Open visit', exact: true }).click();
    await expect(family.getByRole('checkbox', { name: 'Picked up', exact: true })).toBeVisible();
    const refreshedCompanion = companion.waitForResponse((r) => isRpc(r.url(), 'companion_my_trips'));
    await companion.reload();
    await enableFlutter(companion);
    const refreshedTrips = await (await refreshedCompanion).json() as { trip_id: string; status: string }[];
    expect(refreshedTrips.find((row) => row.trip_id === tripId)?.status).toBe('picked_up');
    await revealFlutter(companion, companionTile());
    await companionTile().click();
    await expect(companion.getByRole('button', { name: 'Reached the centre', exact: true })).toBeVisible();
    // Asha still reads and acts on this exact trip; Ravi's denied assignment did
    // not transfer it. Continue ordinary supported stages, with the required note.
    await advance('Reached the centre', 'at_centre');
    await advance('Handed over at the centre', 'handed_over', 'Centre handover completed (synthetic).');
    await advance('Session finished', 'session_done');
    await advance('Starting the return journey', 'returning');
    await advance('Dropped home safely', 'dropped_home');
    const completionNote = 'Returned home safely after ops resolved transport issue (synthetic).';
    await advance('Complete visit', 'completed', completionNote);
    const completedEvents = await refreshFamily('completed', 'Completed');
    expect(completedEvents.at(-1)?.note).toBe(completionNote);
    await family.screenshot({ path: `${shots}/04-family-completed.png` });
    await expect(companion.getByText('This trip is closed.', { exact: true })).toBeVisible();
    const completedCompanionRead = companion.waitForResponse((r) => isRpc(r.url(), 'companion_my_trips'));
    await companion.reload();
    await enableFlutter(companion);
    const completedTrips = await (await completedCompanionRead).json() as { trip_id: string; status: string }[];
    expect(completedTrips.find((row) => row.trip_id === tripId)?.status).toBe('completed');
    await revealFlutter(companion, companionTile());
    await expect(companionTile().getByRole('checkbox', { name: 'Completed', exact: true })).toBeVisible();
    await ops.goto(opsPath('/trips'));
    const completedTrip = ops.locator(`[data-trip-id="${tripId}"]`);
    await expect(completedTrip.getByText('Completed', { exact: true })).toBeVisible();
    await expect(completedTrip.locator('[data-col="companion"]')).toHaveText('Asha Companion (synthetic)');
    await completedTrip.screenshot({ path: `${shots}/05-ops-completed.png` });
    receipt.completion = { family: 'completed', companion: 'completed', ops: 'completed', assignee_unchanged: true };
    receipt.required_completion_note_persisted = true;
    receipt.family_private_notes_absent_at_completion = await privacyCheck();
    delete receipt.current_stage;
    receipt.result = 'Pass';
  } catch (error) {
    receipt.result = 'Fail';
    throw error;
  } finally {
    writeFileSync(`${shots}/receipt.json`, `${JSON.stringify(receipt, null, 2)}\n`);
    await familyContext.close();
    await companionContext.close();
    await opsContext.close();
  }
});
