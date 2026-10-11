import { expect, test, type Page } from '@playwright/test';
import { istToday } from '../src/lib/ops.ts';

// Synthetic seed (supabase/seed/seed.sql) with test OTPs from supabase/config.toml.
const OPS_PHONE = '9000000001';
const COMPANION_PHONE = '9000000201';
const TEST_OTP = '123456';

// The seed schedule runs Mon/Wed/Fri; pick the next such IST day after today.
function nextTripDay(): string {
  const day = new Date(`${istToday()}T00:00:00Z`);
  do day.setUTCDate(day.getUTCDate() + 1); while (![1, 3, 5].includes(day.getUTCDay()));
  return day.toISOString().slice(0, 10);
}

async function signIn(page: Page, phone: string) {
  await page.goto('/login');
  await page.getByLabel('Mobile number').fill(phone);
  await page.getByRole('button', { name: 'Send code' }).click();
  await page.getByLabel('6-digit code').fill(TEST_OTP);
  await page.getByRole('button', { name: 'Sign in' }).click();
}

test('a companion account cannot use the ops console', async ({ page }) => {
  await signIn(page, COMPANION_PHONE);
  await expect(page.getByRole('alert')).toContainText('not an ops account');
  await page.goto('/trips');
  await expect(page).toHaveURL(/\/login$/);
});

test('ops assigns the backup companion to a trip; the database rejects an ineligible one', async ({ page }) => {
  await signIn(page, OPS_PHONE);
  await expect(page).toHaveURL(/\/trips$/);

  await page.getByLabel('Date').fill(nextTripDay());
  const trip = page.getByRole('listitem', { name: /^Trip Lakshmi Rao/ }).first();
  const companion = trip.getByTestId('trip-companion');
  await expect(companion).toHaveText('Asha Companion (synthetic)');

  await trip.getByRole('button', { name: 'Assign backup' }).click();
  await expect(page.getByRole('status')).toContainText('Ravi Companion (synthetic) assigned');
  await expect(companion).toHaveText('Ravi Companion (synthetic)');
  await page.screenshot({ path: 'test-results/assign-backup.png', fullPage: true });

  await trip.getByLabel('Reassign to').selectOption({ label: 'Far Companion (synthetic)' });
  await trip.getByRole('button', { name: 'Reassign' }).click();
  await expect(page.getByRole('alert')).toContainText('not eligible');
  await expect(companion).toHaveText('Ravi Companion (synthetic)');
  await page.screenshot({ path: 'test-results/ineligible-companion.png', fullPage: true });
});
