// Real browser journey against Supabase local in CI. CARE_PREVIEW_URL optionally
// drives the explicitly configured synthetic hosted preview with an environment OTP.
import { expect, test, type Page, type Locator } from '@playwright/test';
import { mkdirSync, writeFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';

const enabled = Boolean(process.env.CARE_REQUEST_JOURNEY);
test.skip(!enabled, 'CARE_REQUEST_JOURNEY=1 with Supabase local and built PWA');
const shots = 'test-results/care-request';
const preview = process.env.CARE_PREVIEW_URL;
const opsPath = (path: string) => preview ? `/ops${path}/` : path;
// Auth and pickup codes are transient UI inputs, never diagnostic artifacts.
test.use({ trace: 'off', screenshot: 'off', video: 'off' });

type CareRow = { schedule_id: string; request_state: string; trip_id: string | null };
type EventRow = { to_status: string; created_at: string; note: string | null };

async function signedInIdentity(page: Page, expectedPhone: string, action = 'Sign in') {
  const verified = page.waitForResponse((r) => new URL(r.url()).pathname === '/auth/v1/verify');
  await page.getByRole('button', { name: action, exact: true }).click();
  const response = await verified;
  expect(response.status()).toBe(200);
  const { user } = await response.json() as { user: { id: string; phone: string } };
  expect(user.phone.replace(/^\+/, '')).toBe(expectedPhone);
  return { user_id: user.id, phone: user.phone };
}

function milestoneTime(value: string) {
  return `${new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Asia/Kolkata', day: 'numeric', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit', second: '2-digit', hourCycle: 'h23',
  }).format(new Date(value))} IST`;
}

async function enableFlutter(page: Page) {
  await page.getByRole('button', { name: 'Enable accessibility' }).evaluate((element) => (element as HTMLElement).click());
}

async function revealFlutter(page: Page, locator: Locator) {
  for (let scroll = 0; scroll < 20; scroll++) {
    if (await locator.isVisible()) return;
    await page.mouse.move(190, 650);
    await page.mouse.wheel(0, 500);
    await page.waitForTimeout(150);
  }
  await expect(locator).toBeVisible();
}

// Flutter replaces its semantic editing node on focus. Use real keyboard input
// after the editing connection settles; never put credentials in screenshots.
async function enterFlutter(page: Page, name: string, value: string) {
  await page.getByRole('textbox', { name: name === 'Mobile number' ? /^Mobile number\b/ : name, exact: true }).click();
  await page.waitForTimeout(350);
  await page.keyboard.press('ArrowLeft');
  await page.waitForTimeout(150);
  await page.keyboard.press('ControlOrMeta+A');
  await page.keyboard.insertText(value);
}

test('Family request -> assigned companion journey -> persisted completion across roles', async ({ browser }) => {
  test.setTimeout(240_000);
  mkdirSync(shots, { recursive: true });
  const familyContext = await browser.newContext({ viewport: { width: 390, height: 844 }, hasTouch: true });
  const opsContext = await browser.newContext({ baseURL: preview ?? `http://127.0.0.1:${process.env.OPS_CONSOLE_PORT ?? 3000}` });
  const companionContext = await browser.newContext({ viewport: { width: 390, height: 844 }, hasTouch: true });
  const family = await familyContext.newPage();
  const ops = await opsContext.newPage();
  const companion = await companionContext.newPage();
  family.setDefaultTimeout(30_000);
  ops.setDefaultTimeout(30_000);
  const receipt: Record<string, unknown> = { backend: preview ? 'Existing hosted synthetic Supabase: real Auth/Postgres/RPCs/RLS' : 'Supabase local: real Auth/Postgres/RPCs/RLS', surface: 'desktop Chromium phone viewport, not a physical phone' };
  const otp = preview ? process.env.CARE_TEST_OTP : '123456';
  if (!otp) throw new Error('Set CARE_TEST_OTP for the authorized synthetic preview; never record the code.');
  try {
    await family.goto(preview ? `${preview}/app/` : 'http://127.0.0.1:3103/app/');
    await enableFlutter(family);
    await family.getByRole('button', { name: 'Get started', exact: true }).click();
    await enterFlutter(family, 'Mobile number', '9000000101');
    await family.getByRole('button', { name: 'Send verification code', exact: true }).click();
    await enterFlutter(family, '6-digit code', otp);
    receipt.family_identity = await signedInIdentity(family, '919000000101', 'Verify code');
    // The patient card merges its name and centre into one semantic label.
    await expect(family.getByRole('button', { name: /Lakshmi Rao \(synthetic\)/ })).toBeVisible();
    await family.getByRole('tab', { name: 'Visits', exact: true }).click();
    await family.getByRole('button', { name: 'Request a visit', exact: true }).waitFor();
    await family.getByRole('button', { name: 'Request a visit', exact: true }).click();
    await family.getByText('Package', { exact: true }).click();
    await family.getByRole('menuitem', { name: 'Basic', exact: true }).click();
    // Whole-minute pickup shortly ahead, inside the unchanged 180-minute Start
    // window. Convert the same instant to IST date AND time across midnight.
    const pickup = process.env.CARE_PICKUP_AT ? new Date(process.env.CARE_PICKUP_AT)
      : new Date(Math.ceil(Date.now() / 60_000) * 60_000 + (30 + Math.floor(Math.random() * 10)) * 60_000);
    // The seeded recurring schedule owns 07:00 IST; use a distinct demo intent.
    if (pickup.getUTCHours() === 1 && pickup.getUTCMinutes() === 30) pickup.setUTCMinutes(31);
    const pickupIst = new Date(pickup.getTime() + 330 * 60_000).toISOString();
    const day = pickupIst.slice(0, 10);
    const pickupTime = pickupIst.slice(11, 16);
    await enterFlutter(family, 'Pickup date (IST)', day);
    await enterFlutter(family, 'Pickup time (IST)', pickupTime);
    await family.screenshot({ path: `${shots}/01-family-request.png` });
    await family.getByRole('button', { name: 'Review request', exact: true }).click();
    await expect(family.getByRole('button', { name: 'Submit request', exact: true })).toBeVisible();
    await family.screenshot({ path: `${shots}/02-family-review.png` });
    const submitted = family.waitForResponse((response) => response.url().endsWith('/rpc/family_request_care'));
    await family.getByRole('button', { name: 'Submit request', exact: true }).click();
    const response = await submitted;
    expect(response.status()).toBe(200);
    const scheduleId = await response.json() as string;
    receipt.schedule_id = scheduleId;
    receipt.pickup_date_ist = day;
    receipt.pickup_time_ist = pickupTime;
    const intent = response.request().postDataJSON() as Record<string, unknown>;
    const headers = Object.fromEntries(Object.entries(await response.request().allHeaders())
      .filter(([name]) => ['authorization', 'apikey', 'content-type'].includes(name)));
    // Separate real HTTP transactions, including accidental different retry IDs.
    const retries = await Promise.all([randomUUID(), randomUUID()].map((id) =>
      familyContext.request.post(response.url(), { headers, data: { ...intent, p_request_id: id } })));
    for (const retry of retries) {
      expect(retry.status()).toBe(200);
      expect(await retry.json()).toBe(scheduleId);
    }
    receipt.concurrent_retries_return_same_schedule = true;
    // Pending cards merge into text; confirmed cards become groups with an Open visit button.
    const familyCard = (label: string) => {
      const name = new RegExp(`${pickupTime}\\s+${label}`);
      return label === 'Pending ops confirmation'
        ? family.getByText(name).last()
        : family.getByRole('group', { name }).first();
    };
    await revealFlutter(family, familyCard('Pending ops confirmation'));
    const pendingRead = family.waitForResponse((r) => r.url().endsWith('/rpc/family_care_requests'));
    await family.reload();
    await enableFlutter(family);
    await family.getByRole('tab', { name: 'Visits', exact: true }).click();
    const pendingRows = await (await pendingRead).json() as { schedule_id: string; request_state: string }[];
    expect(pendingRows.find((row) => row.schedule_id === scheduleId)?.request_state).toBe('pending');
    await revealFlutter(family, familyCard('Pending ops confirmation'));
    receipt.family_after_reload = 'pending';
    await family.screenshot({ path: `${shots}/03-family-persisted-pending.png` });

    await ops.goto(opsPath('/login'));
    await ops.getByLabel('Mobile number').fill('9000000001');
    await ops.getByRole('button', { name: 'Send code' }).click();
    await ops.getByLabel('6-digit code').fill(otp);
    receipt.ops_identity = await signedInIdentity(ops, '919000000001');
    await expect(ops).toHaveURL(/\/trips\/?$/);
    await ops.goto(opsPath('/schedules'));
    const card = ops.locator(`[data-schedule-id="${scheduleId}"]`);
    await expect(card.getByText('Care request', { exact: true })).toBeVisible();
    await expect(card.getByText('Pending ops', { exact: true })).toBeVisible();
    receipt.ops_sees_request = true;
    await card.screenshot({ path: `${shots}/04-ops-pending-request.png` });
    await card.getByRole('button', { name: 'Confirm request', exact: true }).click();
    await expect(card.getByText('Confirmed', { exact: true })).toBeVisible();
    await family.reload();
    await enableFlutter(family);
    await family.getByRole('tab', { name: 'Visits', exact: true }).click();
    await revealFlutter(family, familyCard('Confirmed · companion not assigned'));
    receipt.family_after_confirmation = 'confirmed';
    await family.screenshot({ path: `${shots}/05-family-confirmed.png` });

    await card.getByRole('button', { name: 'Change companions', exact: true }).click();
    const primary = card.getByLabel('Primary companion');
    const backup = card.getByLabel('Backup companion');
    // The fresh seed assigns Asha to recurring 07:00-12:00 visits on
    // Mon/Wed/Fri. A same-day near-term request can overlap that occupied
    // interval, so use the verified but unoccupied seeded backup as primary.
    const ravi = primary.locator('option').filter({ hasText: 'Ravi Companion (synthetic)' });
    const asha = backup.locator('option').filter({ hasText: 'Asha Companion (synthetic)' });
    await expect(ravi).toHaveCount(1);
    await expect(asha).toHaveCount(1);
    await primary.selectOption((await ravi.getAttribute('value'))!);
    await backup.selectOption((await asha.getAttribute('value'))!);
    const assignmentSaved = ops.waitForResponse((r) => r.url().endsWith('/rpc/ops_assign_schedule_companions'));
    await card.getByRole('button', { name: 'Save', exact: true }).click();
    const assignmentResponse = await assignmentSaved;
    const assignmentBody = await assignmentResponse.text();
    expect(assignmentResponse.status(), assignmentBody).toBe(200);
    receipt.assignment_response_status = assignmentResponse.status();
    await expect(card.getByText('Assigned', { exact: true })).toBeVisible();
    await card.screenshot({ path: `${shots}/06-ops-assigned.png` });
    const assignedRead = family.waitForResponse((r) => r.url().endsWith('/rpc/family_care_requests'));
    await family.reload();
    await enableFlutter(family);
    await family.getByRole('tab', { name: 'Visits', exact: true }).click();
    const assignedRows = await (await assignedRead).json() as CareRow[];
    const assigned = assignedRows.find((row) => row.schedule_id === scheduleId)!;
    expect(assigned.request_state).toBe('assigned');
    expect(assigned.trip_id).toBeTruthy();
    const tripId = assigned.trip_id!;
    receipt.trip_id = tripId;
    await revealFlutter(family, familyCard('Confirmed · companion assigned'));
    receipt.family_after_assigned_reload = 'assigned';
    await family.screenshot({ path: `${shots}/07-family-persisted-assigned.png` });

    const pwa = preview ? `${preview}/app/` : 'http://127.0.0.1:3103/app/';
    await companion.goto(pwa);
    await enableFlutter(companion);
    await companion.getByRole('button', { name: 'Get started', exact: true }).click();
    await enterFlutter(companion, 'Mobile number', '9000000202');
    await companion.getByRole('button', { name: 'Send verification code', exact: true }).click();
    await enterFlutter(companion, '6-digit code', otp);
    const companionRead = companion.waitForResponse((r) => r.url().endsWith('/rpc/companion_my_trips'));
    receipt.companion_identity = await signedInIdentity(companion, '919000000202', 'Verify code');
    const companionTrips = await (await companionRead).json() as { trip_id: string; status: string; details_visible: boolean }[];
    const companionTrip = companionTrips.find((row) => row.trip_id === tripId);
    expect(companionTrip?.status).toBe('scheduled');
    expect(companionTrip?.details_visible).toBe(true);
    // Select the restricted card by its persisted ID, independent of localized
    // time formatting and first-name presentation.
    const companionTile = () => companion.locator(`[flt-semantics-identifier="companion-trip-${tripId}"]`);
    await revealFlutter(companion, companionTile());
    await companionTile().getByRole('button', { name: 'Open visit', exact: true }).click();
    await expect(companion.getByRole('button', { name: 'Start journey', exact: true })).toBeVisible();
    await companion.screenshot({ path: `${shots}/08-companion-assigned-visit.png` });
    await familyCard('Confirmed · companion assigned').getByRole('button', { name: 'Open visit', exact: true }).click();
    await expect(family.getByRole('button', { name: 'Get pickup code', exact: true })).toBeVisible();

    const milestones: { status: string; latest_event_at: string }[] = [];
    receipt.milestones = milestones;
    const refreshFamily = async (status: string, label: string) => {
      const boardRead = family.waitForResponse((r) => r.url().endsWith('/rpc/family_trip_board'));
      const timelineRead = family.waitForResponse((r) => r.url().endsWith('/rpc/family_trip_timeline'));
      await family.getByRole('button', { name: /^Refresh(?: Refresh)?$/ }).click();
      const board = await (await boardRead).json() as { trip_id: string; status: string }[];
      const events = await (await timelineRead).json() as EventRow[];
      expect(board.find((row) => row.trip_id === tripId)?.status).toBe(status);
      expect(events.at(-1)?.to_status).toBe(status);
      const latest = events.at(-1)!;
      await expect(family.getByRole('checkbox', { name: label, exact: true })).toBeVisible();
      await expect(family.getByText(`Latest visit update: ${milestoneTime(latest.created_at)}`, { exact: false })).toBeVisible();
      milestones.push({ status, latest_event_at: latest.created_at });
      return events;
    };
    const advance = async (label: string, status: string, familyLabel: string, note?: string) => {
      receipt.current_stage = status;
      if (status === 'handed_over') {
        await companion.getByRole('button', { name: 'Continue to handover', exact: true }).click();
        const received = companion.getByRole('checkbox', { name: 'Patient received by centre staff', exact: true });
        await received.click();
        await expect(received).toBeChecked();
        await enterFlutter(companion, 'Handover note (optional)', note!);
      } else if (status === 'completed') {
        await companion.getByRole('button', { name: 'Add visit note', exact: true }).click();
        await enterFlutter(companion, 'Visit note', note!);
      }
      const changed = companion.waitForResponse((r) => r.url().endsWith('/rpc/advance_trip'));
      await companion.getByRole('button', { name: label, exact: true }).click();
      const result = await changed;
      expect(result.status()).toBe(200);
      const body = await result.json();
      const persisted = Array.isArray(body) ? body[0] : body;
      expect(persisted.id).toBe(tripId);
      expect(persisted.status).toBe(status);
      return refreshFamily(status, familyLabel);
    };

    await advance('Start journey', 'companion_en_route', 'Companion on the way');
    const issued = family.waitForResponse((r) => r.url().endsWith('/rpc/issue_pickup_otp'));
    await family.getByRole('button', { name: 'Get pickup code', exact: true }).click();
    const pickupCode = await (await issued).json() as string;
    expect(/^\d{6}$/.test(pickupCode)).toBe(true);
    await family.getByRole('button', { name: 'Close', exact: true }).click();
    await companion.getByRole('button', { name: 'Confirm pickup', exact: true }).click();
    await enterFlutter(companion, '6-digit pickup code', pickupCode);
    receipt.current_stage = 'picked_up';
    const verified = companion.waitForResponse((r) => r.url().endsWith('/rpc/verify_pickup_otp'));
    await companion.getByRole('button', { name: 'Verify and confirm pickup', exact: true }).click();
    const verification = await (await verified).json() as { ok: boolean; status: string };
    expect(verification.ok).toBe(true);
    expect(verification.status).toBe('picked_up');
    await refreshFamily('picked_up', 'Picked up');
    await advance('Confirm arrival at centre', 'at_centre', 'At the centre');
    await family.screenshot({ path: `${shots}/09-family-at-centre.png` });
    await advance('Confirm handover', 'handed_over', 'Handed to centre staff', 'Handed over to centre staff (synthetic).');
    await advance('Confirm session finished', 'session_done', 'Session finished');
    await advance('Start return journey', 'returning', 'On the way home');
    await advance('Confirm home arrival', 'dropped_home', 'Home');
    const completionNote = 'Returned home safely; family informed (synthetic).';
    const completedEvents = await advance('Submit and complete visit', 'completed', 'Visit complete', completionNote);
    expect(completedEvents.at(-1)?.note).toBe(`Handed to: Family member\n${completionNote}`);
    receipt.milestones = milestones;
    receipt.pickup_verified = true;
    receipt.required_completion_note_persisted = true;
    await expect(companion.getByRole('heading', { name: 'Visit completed', exact: true })).toBeVisible();
    await companion.screenshot({ path: `${shots}/10-companion-completed.png` });
    // Read completion again from each role after navigation/reload, rather than
    // inferring it from a mutation reply or a timeline alone.
    const completedCompanionRead = companion.waitForResponse((r) => r.url().endsWith('/rpc/companion_my_trips'));
    await companion.reload();
    await enableFlutter(companion);
    const reloadedTrips = await (await completedCompanionRead).json() as { trip_id: string; status: string }[];
    expect(reloadedTrips.find((row) => row.trip_id === tripId)?.status).toBe('completed');
    await revealFlutter(companion, companionTile());
    await expect(companionTile().getByRole('group', { name: /\bCompleted\b/ })).toBeVisible();
    const completedFamilyRead = family.waitForResponse((r) => r.url().endsWith('/rpc/family_care_requests'));
    await family.reload();
    await enableFlutter(family);
    await family.getByRole('tab', { name: 'Visits', exact: true }).click();
    const completedRequests = await (await completedFamilyRead).json() as CareRow[];
    expect(completedRequests.find((row) => row.schedule_id === scheduleId)?.request_state).toBe('completed');
    await revealFlutter(family, familyCard('Visit complete'));
    await family.screenshot({ path: `${shots}/11-family-persisted-completed.png` });
    await ops.goto(opsPath('/trips'));
    const opsTrip = ops.locator(`[data-trip-id="${tripId}"]`);
    await expect(opsTrip.getByText('Completed', { exact: true })).toBeVisible();
    await opsTrip.screenshot({ path: `${shots}/12-ops-completed.png` });
    receipt.completion_after_reload = { family: 'completed', companion: 'completed', ops: 'completed' };
    await family.getByRole('tab', { name: 'More', exact: true }).click();
    await family.getByText('Sign out', { exact: true }).click();
    await family.getByRole('button', { name: 'Sign out', exact: true }).click();
    delete receipt.current_stage;
    receipt.result = 'Pass';
  } catch (error) {
    receipt.result = 'Fail';
    // The test reporter holds the assertion; receipts never copy request bodies.
    throw error;
  } finally {
    writeFileSync(`${shots}/receipt.json`, JSON.stringify(receipt, null, 2) + '\n');
    await familyContext.close();
    await opsContext.close();
    await companionContext.close();
  }
});
