// Real browser journey against Supabase local in CI. CARE_PREVIEW_URL optionally
// drives the explicitly configured synthetic hosted preview with an environment OTP.
import { expect, test, type Page } from '@playwright/test';
import { mkdirSync, writeFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';

const enabled = Boolean(process.env.CARE_REQUEST_JOURNEY);
test.skip(!enabled, 'CARE_REQUEST_JOURNEY=1 with Supabase local and built PWA');
const shots = 'test-results/care-request';
const preview = process.env.CARE_PREVIEW_URL;
const opsPath = (path: string) => preview ? `/ops${path}/` : path;

async function enableFlutter(page: Page) {
  await page.getByRole('button', { name: 'Enable accessibility' }).evaluate((element) => (element as HTMLElement).click());
}

// Flutter replaces its semantic editing node on focus. Use real keyboard input
// after the editing connection settles; never put credentials in screenshots.
async function enterFlutter(page: Page, name: string, value: string) {
  await page.getByRole('textbox', { name, exact: true }).click();
  await page.waitForTimeout(350);
  await page.keyboard.press('ArrowLeft');
  await page.waitForTimeout(150);
  await page.keyboard.press('ControlOrMeta+A');
  await page.keyboard.insertText(value);
}

test('Family submits -> ops sees and confirms -> Family sees persisted assignment', async ({ browser }) => {
  test.setTimeout(150_000);
  mkdirSync(shots, { recursive: true });
  const familyContext = await browser.newContext({ viewport: { width: 390, height: 844 }, hasTouch: true });
  const opsContext = await browser.newContext({ baseURL: preview ?? `http://127.0.0.1:${process.env.OPS_CONSOLE_PORT ?? 3000}` });
  const family = await familyContext.newPage();
  const ops = await opsContext.newPage();
  family.setDefaultTimeout(30_000);
  ops.setDefaultTimeout(30_000);
  const receipt: Record<string, unknown> = { backend: preview ? 'Existing hosted synthetic Supabase: real Auth/Postgres/RPCs/RLS' : 'Supabase local: real Auth/Postgres/RPCs/RLS', surface: 'desktop Chromium phone viewport, not a physical phone' };
  const otp = preview ? process.env.CARE_TEST_OTP : '123456';
  if (!otp) throw new Error('Set CARE_TEST_OTP for the authorized synthetic preview; never record the code.');
  try {
    await family.goto(preview ? `${preview}/app/` : 'http://127.0.0.1:3103/app/');
    await enableFlutter(family);
    await enterFlutter(family, 'Mobile number', '9000000101');
    await family.getByRole('button', { name: 'Send code', exact: true }).click();
    await enterFlutter(family, '6-digit code', otp);
    await family.getByRole('button', { name: 'Sign in', exact: true }).click();
    await family.getByRole('button', { name: 'Request care', exact: true }).waitFor();
    await expect(family.getByText('Lakshmi Rao (synthetic)', { exact: true })).toBeVisible();
    await family.getByRole('button', { name: 'Request care', exact: true }).click();
    await family.getByText('Package', { exact: true }).click();
    await family.getByRole('menuitem', { name: 'Basic', exact: true }).click();
    const day = new Date(Date.now() + (3 * 24 * 60 + 330) * 60_000).toISOString().slice(0, 10);
    const minute = 18 * 60 + Math.floor(Math.random() * 60);
    const pickupTime = `${Math.floor(minute / 60).toString().padStart(2, '0')}:${(minute % 60).toString().padStart(2, '0')}`;
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
    await expect(familyCard('Pending ops confirmation')).toBeVisible();
    const pendingRead = family.waitForResponse((r) => r.url().endsWith('/rpc/family_care_requests'));
    await family.reload();
    await enableFlutter(family);
    const pendingRows = await (await pendingRead).json() as { schedule_id: string; request_state: string }[];
    expect(pendingRows.find((row) => row.schedule_id === scheduleId)?.request_state).toBe('pending');
    await expect(familyCard('Pending ops confirmation')).toBeVisible();
    receipt.family_after_reload = 'pending';
    await family.screenshot({ path: `${shots}/03-family-persisted-pending.png` });

    await ops.goto(opsPath('/login'));
    await ops.getByLabel('Mobile number').fill('9000000001');
    await ops.getByRole('button', { name: 'Send code' }).click();
    await ops.getByLabel('6-digit code').fill(otp);
    await ops.getByRole('button', { name: 'Sign in', exact: true }).click();
    await expect(ops).toHaveURL(/\/trips\/?$/);
    await ops.goto(opsPath('/schedules'));
    const card = ops.locator(`[data-schedule-id="${scheduleId}"]`);
    await expect(card.getByText('Care request', { exact: true })).toBeVisible();
    await expect(card.getByText('Pending ops', { exact: true })).toBeVisible();
    receipt.ops_sees_request = true;
    await card.screenshot({ path: `${shots}/04-ops-pending-request.png` });
    await card.getByRole('button', { name: 'Confirm request', exact: true }).click();
    await expect(card.getByText('Confirmed', { exact: true })).toBeVisible();
    await family.getByRole('button', { name: 'Refresh', exact: true }).click();
    await expect(familyCard('Confirmed · companion not assigned')).toBeVisible();
    receipt.family_after_confirmation = 'confirmed';
    await family.screenshot({ path: `${shots}/05-family-confirmed.png` });

    await card.getByRole('button', { name: 'Change companions', exact: true }).click();
    const primary = card.getByLabel('Primary companion');
    const backup = card.getByLabel('Backup companion');
    const asha = primary.locator('option').filter({ hasText: 'Asha Companion (synthetic)' });
    const ravi = backup.locator('option').filter({ hasText: 'Ravi Companion (synthetic)' });
    await expect(asha).toHaveCount(1);
    await expect(ravi).toHaveCount(1);
    await primary.selectOption((await asha.getAttribute('value'))!);
    await backup.selectOption((await ravi.getAttribute('value'))!);
    await card.getByRole('button', { name: 'Save', exact: true }).click();
    await expect(card.getByText('Assigned', { exact: true })).toBeVisible();
    await card.screenshot({ path: `${shots}/06-ops-assigned.png` });
    const assignedRead = family.waitForResponse((r) => r.url().endsWith('/rpc/family_care_requests'));
    await family.reload();
    await enableFlutter(family);
    const assignedRows = await (await assignedRead).json() as { schedule_id: string; request_state: string }[];
    expect(assignedRows.find((row) => row.schedule_id === scheduleId)?.request_state).toBe('assigned');
    await expect(familyCard('Confirmed · companion assigned')).toBeVisible();
    receipt.family_after_assigned_reload = 'assigned';
    await family.screenshot({ path: `${shots}/07-family-persisted-assigned.png` });
    await family.getByRole('button', { name: 'Sign out', exact: true }).click();
    receipt.result = 'Pass';
  } finally {
    writeFileSync(`${shots}/receipt.json`, JSON.stringify(receipt, null, 2) + '\n');
    await familyContext.close();
    await opsContext.close();
  }
});
