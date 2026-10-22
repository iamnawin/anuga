// Separate origins keep each role's Supabase browser session independent.
import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { dirname, extname, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const types = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json', '.css': 'text/css', '.wasm': 'application/wasm',
  '.png': 'image/png', '.svg': 'image/svg+xml', '.ico': 'image/x-icon',
  '.ttf': 'font/ttf', '.otf': 'font/otf', '.woff2': 'font/woff2',
};

for (const [name, port, directory] of [
  ['Ops', 3100, 'apps/ops_console/out'],
  ['Family', 3101, 'apps/family_app/build/web'],
  ['Companion', 3102, 'apps/companion_app/build/web'],
]) {
  const base = resolve(root, directory);
  await stat(resolve(base, 'index.html'));
  const server = createServer(async (req, res) => {
    try {
      if (!['GET', 'HEAD'].includes(req.method)) {
        res.writeHead(405, { Allow: 'GET, HEAD' }).end();
        return;
      }
      let path = resolve(base, `.${decodeURIComponent(new URL(req.url, 'http://localhost').pathname)}`);
      if (path !== base && !path.startsWith(base + sep)) {
        res.writeHead(403).end();
        return;
      }
      if ((await stat(path)).isDirectory()) path = resolve(path, 'index.html');
      const body = await readFile(path);
      res.writeHead(200, {
        'Content-Type': types[extname(path)] ?? 'application/octet-stream',
        'Cache-Control': 'no-store', 'X-Robots-Tag': 'noindex, nofollow',
      });
      res.end(req.method === 'HEAD' ? undefined : body);
    } catch {
      res.writeHead(404).end('Not found');
    }
  });
  server.on('error', (error) => { console.error(`${name}: ${error.message}`); process.exit(1); });
  server.listen(port, '127.0.0.1', () => console.log(`${name}: http://127.0.0.1:${port}/`));
}
