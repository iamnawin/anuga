// Real browser regression for role sessions sharing the synthetic test origin.
// ANUGA_TEST_SITE=https://anuga.vercel.app STAGING_TEST_OTP=<test code> node scripts/web-session-smoke.mjs
import { createRequire } from 'node:module';
import { mkdir, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import assert from 'node:assert/strict';

const require = createRequire(new URL('../apps/ops_console/package.json', import.meta.url));
const { chromium, expect } = require('@playwright/test');
const base = process.env.ANUGA_TEST_SITE?.replace(/\/$/, '');
const otp = process.env.STAGING_TEST_OTP;
if (!base || !/^\d{6}$/.test(otp ?? '')) throw new Error('Set ANUGA_TEST_SITE and the six-digit STAGING_TEST_OTP');
if (!['127.0.0.1', 'localhost', 'anuga.vercel.app'].includes(new URL(base).hostname)) {
  throw new Error('Only loopback or the existing synthetic test site is allowed');
}
const output = new URL('../artifacts/web-sessions/', import.meta.url);
await mkdir(output, { recursive: true });
const browser = await chromium.launch({ channel: process.env.BROWSER_CHANNEL, headless: true });
try {
  const context = await browser.newContext({ viewport: { width: 430, height: 900 } });
  const pages = [];
  const results = [];
  async function enter(field, text) {
    // Activating Flutter semantics may replace the initial input element.
    for (let attempt = 0; attempt < 3; attempt++) {
      await field.click();
      await field.press('Control+A');
      await field.pressSequentially(text, { delay: 100 });
      if (await field.inputValue() === text) return;
    }
    await expect(field).toHaveValue(text);
  }
  for (const [app, path, phone, storageKey, expectedId] of [
    ['ops', '/ops/login/', '9000000001', 'companion-ops-auth', '10000000-0000-0000-0000-000000000001'],
    ['family', '/family/', '9000000101', 'anuga-family-auth', '20000000-0000-0000-0000-000000000001'],
    ['companion', '/companion/', '9000000202', 'anuga-companion-auth', '30000000-0000-0000-0000-000000000002'],
  ]) {
    const page = await context.newPage();
    pages.push({ page, app, storageKey, expectedId });
    const errors = [];
    page.on('pageerror', (error) => errors.push(error.message));
    assert.equal((await page.goto(base + path)).status(), 200);
    if (app !== 'ops') {
      await page.locator('flutter-view').waitFor({ timeout: 60000 });
      await page.locator('flt-semantics-placeholder').evaluate((element) => element.click());
    }
    await enter(page.getByRole('textbox').first(), phone);
    await page.getByRole('button', { name: 'Send code', exact: true }).click();
    const code = app === 'ops' ? page.locator('#code') : page.getByRole('textbox', { name: '6-digit code', exact: true });
    await enter(code, otp);
    await page.getByRole('button', { name: 'Sign in', exact: true }).click();
    await expect.poll(() => page.evaluate((key) => !!localStorage.getItem(key), storageKey)).toBe(true);
    const identity = await page.evaluate((key) => JSON.parse(localStorage.getItem(key)).user.id, storageKey);
    assert.equal(identity, expectedId);
    await page.screenshot({ path: fileURLToPath(new URL(`${app}.png`, output)), fullPage: true });
    results.push({ app, identity, errors });
  }
  for (const { page, app, storageKey, expectedId } of pages) {
    await page.reload();
    if (app !== 'ops') {
      await page.locator('flutter-view').waitFor({ timeout: 60000 });
      await page.locator('flt-semantics-placeholder').evaluate((element) => element.click());
      await page.getByRole('button', { name: 'Sign out', exact: true }).waitFor();
    }
    const identity = await page.evaluate((key) => JSON.parse(localStorage.getItem(key))?.user?.id, storageKey);
    assert.equal(identity, expectedId, `${app} session survives other role sign-ins and reload`);
  }
  const companion = pages.at(-1);
  await companion.page.getByRole('button', { name: 'Sign out', exact: true }).click();
  await expect.poll(() => companion.page.evaluate((key) => localStorage.getItem(key), companion.storageKey)).toBe(null);
  for (const { page, app, storageKey, expectedId } of pages.slice(0, 2)) {
    assert.equal(await page.evaluate((key) => JSON.parse(localStorage.getItem(key))?.user?.id, storageKey), expectedId, `${app} survives companion sign-out`);
  }
  assert.ok(results.every((result) => result.errors.length === 0), 'No browser page errors');
  await writeFile(new URL('receipt.json', output), JSON.stringify(results, null, 2));
  console.log('PASS: real role sign-ins, independent reloads and isolated companion sign-out');
} finally {
  await browser.close();
}
