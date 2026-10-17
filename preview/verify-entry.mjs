// Entry/navigation regression checks against the actual compiled preview.
import { createServer } from 'node:http';
import { readFile, stat, mkdir, writeFile } from 'node:fs/promises';
import { resolve, extname, sep } from 'node:path';
import { createRequire } from 'node:module';
import assert from 'node:assert/strict';

const require = createRequire(new URL('../apps/ops_console/package.json', import.meta.url));
const { chromium } = require('@playwright/test');
const base = process.env.ANUGA_DEMO_SITE ?? 'http://127.0.0.1:3211';
if (!/^http:\/\/127\.0\.0\.1:3211$|^https:\/\/anuga-interactive-preview(?:-[a-z0-9-]+)?\.vercel\.app$/.test(base)) {
  throw Error('Only the isolated demo or loopback is permitted');
}
const output = process.env.ANUGA_ENTRY_EVIDENCE ?? 'artifacts/interactive-preview/entry';
const root = resolve('artifacts/interactive-preview/.vercel/output/static');
const types = { '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm', '.ttf': 'font/ttf', '.otf': 'font/otf' };
let server;
if (base.startsWith('http:')) {
  server = createServer(async (req, res) => {
    try {
      let file = resolve(root, '.' + decodeURIComponent(new URL(req.url, base).pathname));
      if (file !== root && !file.startsWith(root + sep)) { res.writeHead(403).end(); return; }
      if ((await stat(file)).isDirectory()) file = resolve(file, 'index.html');
      res.writeHead(200, { 'Content-Type': types[extname(file)] ?? 'application/octet-stream' });
      res.end(await readFile(file));
    } catch { res.writeHead(404).end(); }
  });
  await new Promise(r => server.listen(3211, '127.0.0.1', r));
}
await mkdir(output, { recursive: true });
const browser = await chromium.launch({ channel: 'msedge', args: ['--disable-http2'] });
const context = await browser.newContext();
const results = [];
async function check(name, action) {
  try { await action(); results.push({ name, passed: true }); }
  catch (error) { results.push({ name, passed: false, error: error.message }); }
}
async function welcome(page) {
  await page.goto(base);
  await page.locator('iframe').waitFor();
  if (await page.locator('#guide[open]').count()) await page.locator('#guide-close').click();
  await page.frameLocator('iframe').locator('main').waitFor();
}
try {
  for (const width of [360, 1356, 1920]) {
    const page = await context.newPage();
    await page.setViewportSize({ width, height: 720 });
    await welcome(page);
    await check(`Welcome centred with no horizontal overflow at ${width}px`, async () => {
      const layout = await page.frameLocator('iframe').locator('main').evaluate(el => ({ x: el.getBoundingClientRect().x, width: el.getBoundingClientRect().width, viewport: innerWidth, scroll: document.documentElement.scrollWidth }));
      assert.ok(Math.abs(layout.x + layout.width / 2 - layout.viewport / 2) <= 1);
      assert.ok(layout.scroll <= layout.viewport);
    });
    await check(`All preview controls visible and at least 48px at ${width}px`, async () => {
      const boxes = await page.locator('header button').evaluateAll(es => es.map(e => ({ x: e.getBoundingClientRect().x, right: e.getBoundingClientRect().right, height: e.getBoundingClientRect().height })));
      assert.ok(boxes.every(b => b.x >= 0 && b.right <= width && b.height >= 48), JSON.stringify(boxes));
    });
    await page.screenshot({ path: `${output}/welcome-${width}.png` });
    await page.close();
  }
  const page = await context.newPage();
  await welcome(page);
  await page.frameLocator('iframe').getByRole('link', { name: 'Family/Patient sign in', exact: true }).click();
  await page.waitForFunction(() => document.querySelector('iframe').contentWindow.location.pathname.startsWith('/family/'));
  await check('Welcome link synchronizes selected app and bookmark URL', async () => {
    assert.equal(await page.locator('nav .primary').textContent(), 'Family / Patient');
    assert.ok(new URL(page.url()).searchParams.get('screen')?.startsWith('/family/'));
  });
  await page.reload();
  await page.locator('iframe').waitFor();
  await check('Reload preserves chosen app', async () => assert.ok((await page.locator('iframe').getAttribute('src')).startsWith('/family/')));
  await page.getByRole('button', { name: 'Companion', exact: true }).click();
  await page.getByRole('button', { name: 'Welcome', exact: true }).click();
  await check('Browser Back restores the previous app', async () => {
    await page.goBack({ waitUntil: 'domcontentloaded', timeout: 10000 });
    await page.waitForFunction(() => document.querySelector('iframe').contentWindow.location.pathname === '/companion/', null, { timeout: 5000 });
    assert.equal(await page.locator('nav .primary').textContent(), 'Companion');
  });
  await writeFile(`${output}/results.json`, JSON.stringify({ base, results }, null, 2) + '\n');
  console.log(JSON.stringify(results, null, 2));
  if (results.some(r => !r.passed)) process.exitCode = 1;
} finally {
  await browser.close();
  if (server) await new Promise(r => server.close(r));
}
