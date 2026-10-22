// End-to-end against Supabase local with the synthetic seed. Real phone-OTP
// sign-in (test OTP from supabase/config.toml), real RPCs, real RLS.
import { expect, test, type Browser, type Page } from '@playwright/test';
import { createClient } from '@supabase/supabase-js';
import { mkdirSync } from 'node:fs';

const OTP = '123456';
const OPS_PHONE = '9000000001';
const OWNER_PHONE = '9000000101';
// Ravi has a scheduled trip whatever the earlier tests did (backup assignment, then primary).
const RAVI_PHONE = '+919000000202';
const RAVI = 'Ravi Companion (synthetic)';
const FAR = 'Far Companion (synthetic)';
const shots = process.env.SCREENSHOT_DIR ?? 'test-results/screenshots';
mkdirSync(shots, { recursive: true });
// Supabase Auth limits OTP requests per number (one per few seconds), so the
// ops session from the sign-in test is saved and reused by later tests.
const opsState = 'test-results/ops-session.json';

async function signIn(page: Page, phone: string) {
  await page.goto('/login');
  await page.getByLabel('Mobile number').fill(phone);
  await page.getByRole('button', { name: 'Send code' }).click();
  await page.getByLabel('6-digit code').fill(OTP);
  await page.getByRole('button', { name: 'Sign in' }).click();
}

async function asOps(browser: Browser, path = '/trips'): Promise<Page> {
  const context = await browser.newContext({ storageState: opsState });
  const page = await context.newPage();
  await page.goto(path);
  return page;
}

async function rpcClientFor(phone: string) {
  const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } });
  await supabase.auth.signInWithOtp({ phone, options: { shouldCreateUser: false } });
  const { error } = await supabase.auth.verifyOtp({ phone, token: OTP, type: 'sms' });
  if (error) throw error;
  return supabase;
}

// A companion acting from their own (future) app: signs in by phone OTP and uses the RPCs.
// Ravi's seed trips can be days ahead, past the companion start window, so ops sets the
// trip on its way (allowed for ops) and Ravi then reports the issue.
async function companionReportsIssue(note: string): Promise<string> {
  const ravi = await rpcClientFor(RAVI_PHONE);
  const { data: trips, error } = await ravi.rpc('companion_my_trips');
  if (error) throw error;
  const trip = (trips as { trip_id: string; status: string }[]).filter((t) => t.status === 'scheduled').at(-1);
  if (!trip) throw new Error('Ravi has no scheduled trip');

  const ops = await rpcClientFor(`+91${OPS_PHONE}`);
  const { error: startError } = await ops.rpc('advance_trip', { p_trip_id: trip.trip_id, p_to_status: 'companion_en_route' });
  if (startError) throw startError;
  await ops.auth.signOut({ scope: 'local' }); // keep the saved browser ops session valid

  const { error: issueError } = await ravi.rpc('advance_trip', { p_trip_id: trip.trip_id, p_to_status: 'issue_reported', p_note: note });
  if (issueError) throw issueError;
  await ravi.auth.signOut();
  return trip.trip_id;
}

test.describe.configure({ mode: 'serial' });

test('a family account cannot use the ops console', async ({ page }) => {
  await signIn(page, OWNER_PHONE);
  await expect(page.locator('main').getByRole('alert')).toContainText('not an ops account');
  await expect(page).toHaveURL(/\/login$/);
  await expect(page.getByLabel('Mobile number')).toBeVisible();
});

test('ops signs in with phone OTP and assigns the backup companion to a trip', async ({ page }) => {
  await page.goto('/login');
  await page.screenshot({ path: `${shots}/01-login.png`, fullPage: true });
  await signIn(page, OPS_PHONE);
  await expect(page).toHaveURL(/\/trips$/);
  await expect(page.getByRole('heading', { name: 'Trips board' })).toBeVisible();
  await page.context().storageState({ path: opsState });

  const row = page.locator('tr[data-trip-id]', { has: page.getByRole('button', { name: `Assign backup: ${RAVI}` }) }).first();
  await expect(row).toBeVisible();
  const tripId = await row.getAttribute('data-trip-id');
  await expect(row.locator('[data-col=companion]')).toHaveText('Asha Companion (synthetic)');
  await page.screenshot({ path: `${shots}/02-trips-board.png`, fullPage: true });

  await row.getByRole('button', { name: `Assign backup: ${RAVI}` }).click();
  await expect(page.getByRole('status')).toHaveText(`Trip reassigned to ${RAVI}.`);
  const updated = page.locator(`tr[data-trip-id="${tripId}"]`);
  await expect(updated.locator('[data-col=companion]')).toHaveText(RAVI);
  await expect(updated.getByRole('button', { name: /Assign backup/ })).toHaveCount(0);
  await page.screenshot({ path: `${shots}/03-backup-assigned.png`, fullPage: true });

  // Persisted in the database, not just in the page.
  await page.reload();
  await expect(page.locator(`tr[data-trip-id="${tripId}"] [data-col=companion]`)).toHaveText(RAVI);
});

test('the database rejects an ineligible companion and the console shows why', async ({ browser }) => {
  const page = await asOps(browser);
  const firstRow = page.locator('tr[data-trip-id]', { has: page.getByRole('button', { name: 'Reassign' }) }).first();
  const row = page.locator(`tr[data-trip-id="${await firstRow.getAttribute('data-trip-id')}"]`);
  await row.getByRole('button', { name: 'Reassign' }).click();
  const select = row.getByLabel('Companion');
  const far = select.locator('option', { hasText: FAR });
  await expect(far).toContainText('outside radius');
  await select.selectOption({ label: (await far.textContent())! });
  await row.getByRole('button', { name: 'Assign', exact: true }).click();
  const alert = row.getByRole('alert');
  await expect(alert).toContainText('not eligible for this patient');
  await expect(alert).toContainText('within its radius');
  await page.screenshot({ path: `${shots}/04-ineligible-rejected.png`, fullPage: true });
});

test('schedules: change primary/backup, with database validation', async ({ browser }) => {
  const page = await asOps(browser);
  await page.getByRole('link', { name: 'Schedules' }).click();
  const card = page.locator('[data-schedule-id]').first();
  await expect(card.locator('[data-col=backup]')).toHaveText(RAVI);
  await card.getByRole('button', { name: 'Change companions' }).click();

  const backup = card.getByLabel('Backup companion');
  await expect(backup.locator('option', { hasText: FAR })).toHaveCount(1);
  await backup.selectOption({ label: (await backup.locator('option', { hasText: FAR }).textContent())! });
  await card.getByRole('button', { name: 'Save' }).click();
  await expect(card.getByRole('alert')).toContainText('not eligible');
  await page.screenshot({ path: `${shots}/05-schedule-rejected.png`, fullPage: true });

  // Swap primary and backup: allowed.
  const primary = card.getByLabel('Primary companion');
  await primary.selectOption({ label: (await primary.locator('option', { hasText: RAVI }).textContent())! });
  await backup.selectOption({ label: (await backup.locator('option', { hasText: 'Asha Companion' }).textContent())! });
  await card.getByRole('button', { name: 'Save' }).click();
  await expect(page.getByRole('status')).toContainText('Companions saved');
  await expect(card.locator('[data-col=primary]')).toHaveText(RAVI);
  await expect(card.locator('[data-col=backup]')).toHaveText('Asha Companion (synthetic)');
});

test('exception queue: a companion reports an issue, ops resolves it', async ({ browser }) => {
  const tripId = await companionReportsIssue('Auto broke down near the centre (synthetic)');
  const page = await asOps(browser);
  await page.getByRole('link', { name: 'Exceptions' }).click();
  const card = page.locator(`[data-trip-id="${tripId}"]`);
  await expect(card).toHaveAttribute('data-kind', 'issue_reported');
  await expect(card).toContainText('Auto broke down near the centre (synthetic)');
  await page.screenshot({ path: `${shots}/06-exception-queue.png`, fullPage: true });

  await card.getByRole('button', { name: 'Move to: Companion on the way' }).click();
  await expect(page.getByRole('status')).toContainText('Trip moved to Companion on the way');
  await expect(page.locator(`[data-trip-id="${tripId}"]`)).toHaveCount(0);
});

test('billing: a month without completed visits gives an empty draft that cannot be issued', async ({ browser }) => {
  const page = await asOps(browser);
  await page.getByRole('link', { name: 'Billing' }).click();
  await page.getByLabel('Month').fill('2025-02');
  const bill = page.locator('tr[data-patient-id]', { hasText: 'Lakshmi Rao (synthetic)' });
  await expect(bill).toHaveAttribute('data-invoice-status', 'none');
  await bill.getByRole('button', { name: 'Generate invoice' }).click();
  await expect(bill).toHaveAttribute('data-invoice-status', 'draft');
  await expect(bill.locator('[data-col=total]')).toHaveText('₹0.00');
  await expect(bill.getByRole('button', { name: 'Issue to family' })).toHaveCount(0);
  await expect(bill.getByRole('button', { name: 'Rebuild draft' })).toBeVisible();
});

test('the console is translated into Telugu and Hindi', async ({ browser }) => {
  const page = await asOps(browser);
  await page.getByLabel('Language').selectOption('te');
  await expect(page.getByRole('heading', { name: 'ప్రయాణాల బోర్డు' })).toBeVisible();
  await page.screenshot({ path: `${shots}/07-telugu.png`, fullPage: true });
  await page.getByLabel('భాష').selectOption('hi');
  await expect(page.getByRole('heading', { name: 'यात्रा बोर्ड' })).toBeVisible();
  await page.getByLabel('भाषा').selectOption('en');
});
