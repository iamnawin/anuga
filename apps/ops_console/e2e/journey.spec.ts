// M7 journey steps for the ops console, driven by scripts/e2e-journey.sh.
// Skipped unless JOURNEY_STATE points at the journey state file (trip id).
import { expect, test, type Page } from '@playwright/test';
import { readFileSync } from 'node:fs';

const statePath = process.env.JOURNEY_STATE;
const shots = process.env.SCREENSHOT_DIR ?? 'test-results/screenshots';
const RAVI = 'Ravi Companion (synthetic)';

test.skip(!statePath, 'run through scripts/e2e-journey.sh');

const tripId = () => (JSON.parse(readFileSync(statePath!, 'utf8')) as { tripId: string }).tripId;

async function signInAsOps(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Mobile number').fill('9000000001');
  await page.getByRole('button', { name: 'Send code' }).click();
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
