// Local visual acceptance only: real Flutter web widgets, synthetic backend fixture.
// Build apps/family_app/test/home_preview.dart to artifacts/anu003/preview first.
import { createServer } from 'node:http';
import { readFile, stat, mkdir, writeFile } from 'node:fs/promises';
import { resolve, extname, sep } from 'node:path';
import { createRequire } from 'node:module';
import assert from 'node:assert/strict';

const require = createRequire(new URL('../apps/ops_console/package.json', import.meta.url));
const { chromium } = require('@playwright/test');
const root = resolve('artifacts/anu003/preview');
const output = 'artifacts/anu003/browser';
await stat(resolve(root, 'index.html'));
await mkdir(output, { recursive: true });
const types = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm', '.ttf': 'font/ttf', '.otf': 'font/otf', '.png': 'image/png', '.woff2': 'font/woff2' };
const server = createServer(async (req, res) => {
  try {
    let file = resolve(root, '.' + decodeURIComponent(new URL(req.url, 'http://127.0.0.1').pathname));
    if (file !== root && !file.startsWith(root + sep)) { res.writeHead(403).end(); return; }
    if ((await stat(file)).isDirectory()) file = resolve(file, 'index.html');
    res.writeHead(200, { 'Content-Type': types[extname(file)] ?? 'application/octet-stream', 'Cache-Control': 'no-store' });
    res.end(await readFile(file));
  } catch { res.writeHead(404).end(); }
});
await new Promise(resolve => server.listen(3111, '127.0.0.1', resolve));
const browser = await chromium.launch({ channel: process.env.BROWSER_CHANNEL ?? 'msedge', headless: true });
const context = await browser.newContext();
const cases = [
  ['empty', 'en', 360, false, 1.15], ['empty', 'te', 360, true, 2], ['empty', 'hi', 430, false, 3],
  ['patients-error', 'en', 360, false, 1.15], ['patients-denied', 'te', 430, true, 2],
  ['loading', 'en', 360, false, 1.15], ['bookings-loading', 'en', 430, false, 1.15],
  ['bookings-empty', 'hi', 430, true, 2], ['bookings-error', 'te', 360, false, 1.15],
  ['bookings-denied', 'en', 430, false, 1.15], ['populated', 'en', 1440, false, 1.15],
  ['multi', 'en', 360, true, 2], ['populated', 'te', 430, true, 1.15], ['populated', 'hi', 1440, false, 2],
  ['populated', 'en', 360, false, 3],
];
const results = [];
try {
  for (const [state, locale, width, dark, scale] of cases.filter(c => !process.env.ANU003_VISUAL_STATE || c[0] === process.env.ANU003_VISUAL_STATE)) {
    const page = await context.newPage();
    await page.setViewportSize({ width, height: 800 });
    const errors = [];
    page.on('pageerror', e => errors.push(e.message));
    page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
    const url = new URL('http://127.0.0.1:3111/');
    for (const [k, v] of Object.entries({ state, locale, dark, scale })) url.searchParams.set(k, String(v));
    await page.goto(url.href);
    await page.locator('flutter-view').waitFor();
    const semantics = page.locator('flt-semantics-placeholder');
    await semantics.evaluate(element => element.click());
    await page.getByText('ANUGA', { exact: true }).waitFor();
    await page.getByRole('button').first().waitFor();
    const strings = JSON.parse(await readFile(`apps/family_app/lib/l10n/app_${locale}.arb`, 'utf8'));
    const expected = state === 'empty' ? strings.noPatients
      : state.endsWith('denied') ? strings.errorNotAllowed
      : state.endsWith('error') ? strings.errorGeneric
      : state.includes('loading') ? strings.loading
      : state === 'bookings-empty' ? strings.noTrips : 'Lakshmi Rao (synthetic)';
    if (state === 'bookings-empty' && scale >= 2) {
      // Flutter's lazy list does not expose clipped, below-fold text to semantics.
      await page.waitForLoadState('networkidle');
      await page.waitForTimeout(500);
      await page.mouse.move(width / 2, 500);
      await page.mouse.wheel(0, 400);
      await page.waitForTimeout(200);
    }
    await page.getByText(expected, { exact: state !== 'bookings-empty' }).last().waitFor({ state: 'attached' });
    // CanvasKit may publish semantics before its fallback script fonts finish.
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(500);
    const name = `${state}-${locale}-${width}-${scale}-${dark ? 'dark' : 'light'}`;
    await page.screenshot({ path: `${output}/${name}.png` });
    if (scale >= 2) {
      await page.mouse.move(width / 2, 500);
      await page.mouse.wheel(0, 650);
      await page.waitForTimeout(150);
      await page.screenshot({ path: `${output}/${name}-scrolled.png` });
    }
    if (state === 'empty' && locale === 'en') {
      await page.keyboard.press('Tab');
      await page.screenshot({ path: `${output}/empty-keyboard-focus.png` });
    }
    if (state === 'patients-error') {
      await page.getByRole('button', { name: 'Refresh', exact: true }).last().click();
      await page.getByText('Lakshmi Rao (synthetic)', { exact: true }).waitFor();
      await page.screenshot({ path: `${output}/error-recovered.png` });
    }
    assert.deepEqual(errors, [], name + ': browser rendering errors');
    results.push({ state, locale, width, dark, scale, errors });
    await page.close();
  }
  await writeFile(output + '/results.json', JSON.stringify({ environment: 'loopback synthetic UI fixture; production widgets, no real Auth/DB', results, nativeLanguageReview: 'not performed', deviceAcceptance: 'not performed' }, null, 2));
  console.log(`Visual fixture cases passed: ${results.length}`);
} finally {
  await browser.close();
  await new Promise(resolve => server.close(resolve));
}
