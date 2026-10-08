// M7 journey steps for the ops console, driven by scripts/e2e-journey.sh.
// Skipped unless JOURNEY_STATE points at the journey state file (trip id).
import { expect, test, type Page } from '@playwright/test';
import { readFileSync } from 'node:fs';

const statePath = process.env.JOURNEY_STATE;
const shots = process.env.SCREENSHOT_DIR ?? 'test-results/screenshots';
const RAVI = 'Ravi Companion (synthetic)';

test.skip(!statePath, 'run through scripts/e2e-journey.sh');

const state = () => JSON.parse(readFileSync(statePath!, 'utf8')) as { tripId: string; month: string };
const tripId = () => state().tripId;

// Steps run seconds apart and Supabase Auth allows one OTP request per number every
// few seconds: if the console shows that wait, wait it out and send again.
async function signInAsOps(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Mobile number').fill('9000000001');
  for (let attempt = 0; attempt < 5; attempt++) {
    await page.getByRole('button', { name: 'Send code' }).click();
    const code = page.getByLabel('6-digit code');
    const limited = page.locator('main').getByRole('alert').filter({ hasText: /only request this after/ });
    await expect(code.or(limited)).toBeVisible();
    if (await code.isVisible()) break;
    const seconds = Number(/after (\d+) seconds?/.exec((await limited.textContent()) ?? '')?.[1] ?? '5');
    await page.waitForTimeout((seconds + 1) * 1000);
  }
  await page.getByLabel('6-digit code').fill('123456');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page.getByRole('heading', { name: 'Trips board' })).toBeVisible();
}

test('journey 1: ops assigns the backup companion to today\'s visit', async ({ page }) => {
  await signInAsOps(page);
  const row = page.locator(`tr[data-trip-id="${tripId()}"]`);
  await expect(row.locator('[data-col=companion]')).toHaveText('Asha Companion (synthetic)');
  await row.getByRole('button', { name: `Assign backup: ${RAVI}` }).click();
  await expect(row.locator('[data-col=companion]')).toHaveText(RAVI);
  await page.screenshot({ path: `${shots}/journey-1-ops-assigns-backup.png`, fullPage: true });
});

test('journey 7: ops sees the visit completed and nothing in the exception queue', async ({ page }) => {
  await signInAsOps(page);
  const row = page.locator(`tr[data-trip-id="${tripId()}"]`);
  await expect(row.locator('[data-status]')).toHaveAttribute('data-status', 'completed');
  await expect(row.locator('[data-col=companion]')).toHaveText(RAVI);
  await page.screenshot({ path: `${shots}/journey-7-ops-sees-completed.png`, fullPage: true });
  await page.getByRole('link', { name: 'Exceptions' }).click();
  await expect(page.getByRole('heading', { name: 'Exception queue' })).toBeVisible();
  await expect(page.locator(`[data-trip-id="${tripId()}"]`)).toHaveCount(0);
});

test('journey 8: ops records the cab fare and issues the month\'s invoice', async ({ page }) => {
  await signInAsOps(page);
  const row = page.locator(`tr[data-trip-id="${tripId()}"]`);
  await row.getByLabel('Fare (₹)').fill('150');
  await row.getByRole('button', { name: 'Save fare' }).click();
  await expect(row.getByRole('status')).toHaveText('Fare saved.');

  await page.getByRole('link', { name: 'Billing' }).click();
  await page.getByLabel('Month').fill(state().month);
  const bill = page.locator('tr[data-patient-id]', { hasText: 'Lakshmi Rao (synthetic)' });
  await bill.getByRole('button', { name: 'Generate invoice' }).click();
  await expect(bill).toHaveAttribute('data-invoice-status', 'draft');
  // One completed visit (Basic, ₹400) + the ₹150 fare.
  await expect(bill.locator('[data-col=total]')).toHaveText('₹550.00');
  await bill.getByRole('button', { name: 'Issue to family' }).click();
  await expect(bill).toHaveAttribute('data-invoice-status', 'issued');
  await page.screenshot({ path: `${shots}/journey-8-ops-issues-invoice.png`, fullPage: true });
});

test('journey 10: ops sees the invoice paid', async ({ page }) => {
  await signInAsOps(page);
  await page.getByRole('link', { name: 'Billing' }).click();
  await page.getByLabel('Month').fill(state().month);
  const bill = page.locator('tr[data-patient-id]', { hasText: 'Lakshmi Rao (synthetic)' });
  await expect(bill).toHaveAttribute('data-invoice-status', 'paid');
  await page.screenshot({ path: `${shots}/journey-10-ops-sees-paid.png`, fullPage: true });
});
