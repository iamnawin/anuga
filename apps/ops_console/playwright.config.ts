import { defineConfig, devices } from '@playwright/test';
import { existsSync } from 'node:fs';

// The e2e suite drives the built console against Supabase local (`supabase start`
// + `supabase db reset`). It commits data: reset the database before each run.
if (existsSync('.env.local')) process.loadEnvFile('.env.local');

const port = Number(process.env.OPS_CONSOLE_PORT ?? 3000);

export default defineConfig({
  testDir: 'e2e',
  fullyParallel: false,
  workers: 1,
  retries: 0,
  forbidOnly: Boolean(process.env.CI),
  timeout: 60_000,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL: `http://127.0.0.1:${port}`,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    command: `pnpm exec next start --port ${port} --hostname 127.0.0.1`,
    url: `http://127.0.0.1:${port}/login`,
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
});
