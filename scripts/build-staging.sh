#!/usr/bin/env bash
# Builds the staging site: ops console (/ops/), family app (/family/) and companion
# app (/companion/) as static files in Vercel's prebuilt format, pointed at the
# staging Supabase project. SYNTHETIC DATA ONLY: see docs/adr/0004-hosted-staging.md.
#
#   STAGING_SUPABASE_URL=https://<ref>.supabase.co STAGING_SUPABASE_ANON_KEY=<public anon key> \
#     scripts/build-staging.sh
#
# Output: artifacts/staging/.vercel/output (deploy with `vercel deploy --prebuilt`).
# Both values are public client settings; no secret is used or written here.
set -euo pipefail
# Git Bash otherwise rewrites /ops and Flutter base hrefs as Windows paths.
case "$(uname -s)" in
  MINGW*|MSYS*) export MSYS_NO_PATHCONV=1; export MSYS2_ENV_CONV_EXCL="${MSYS2_ENV_CONV_EXCL:+$MSYS2_ENV_CONV_EXCL;}OPS_BASE_PATH" ;;
esac
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
: "${STAGING_SUPABASE_URL:?set STAGING_SUPABASE_URL}"
: "${STAGING_SUPABASE_ANON_KEY:?set STAGING_SUPABASE_ANON_KEY}"
step() { printf '\n=== %s\n' "$*"; }

OUT=artifacts/staging/.vercel/output
node -e 'const fs = require("node:fs"), p = require("node:path"); const root = process.cwd(), target = p.resolve(root, "artifacts/staging/.vercel/output"); if (target !== p.join(root, "artifacts", "staging", ".vercel", "output")) throw new Error("Unexpected build target"); fs.rmSync(target, { recursive: true, force: true, maxRetries: 3, retryDelay: 100 });'
mkdir -p "$OUT/static"

step "ops console -> /ops/"
(cd apps/ops_console && OPS_STATIC_EXPORT=1 OPS_BASE_PATH=/ops NEXT_TELEMETRY_DISABLED=1 \
  NEXT_PUBLIC_SUPABASE_URL="$STAGING_SUPABASE_URL" NEXT_PUBLIC_SUPABASE_ANON_KEY="$STAGING_SUPABASE_ANON_KEY" \
  pnpm exec next build)
cp -r apps/ops_console/out "$OUT/static/ops"

for app in family companion; do
  step "${app}_app -> /$app/"
  (cd "apps/${app}_app" && flutter pub get && flutter build web --release --no-web-resources-cdn --base-href "/$app/" \
    --dart-define=SUPABASE_URL="$STAGING_SUPABASE_URL" --dart-define=SUPABASE_PUBLISHABLE_KEY="$STAGING_SUPABASE_ANON_KEY")
  cp -r "apps/${app}_app/build/web" "$OUT/static/$app"
done

step "landing page and routing"
cp docs/logo/anugacare-lockup.png "$OUT/static/anugacare-lockup.png"
cp apps/family_app/web/favicon.png "$OUT/static/favicon.png"
cat > "$OUT/static/index.html" <<'HTML'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex, nofollow">
<title>AnugaCare</title>
<link rel="icon" type="image/png" href="/favicon.png">
<style>
  body { font-family: system-ui, sans-serif; margin: 0; padding: 24px 16px; background: #F7FBFA; color: #10243A; }
  main { max-width: 480px; margin: 0 auto; }
  h1 { margin: 0 0 16px; text-align: center; }
  h1 img { width: 240px; max-width: 70%; height: auto; }
  .banner { background: #fff3cd; border: 2px solid #8a6d00; padding: 12px 16px; border-radius: 8px; font-size: 18px; }
  a.app { display: block; margin: 16px 0; padding: 20px; min-height: 56px; border-radius: 12px; background: #00666B;
          color: #fff; font-size: 22px; text-decoration: none; }
  a.app span { display: block; font-size: 16px; opacity: .9; margin-top: 4px; }
</style>
</head>
<body>
<main>
  <h1><img src="/anugacare-lockup.png" alt="AnugaCare: someone beside you, every visit." width="240" height="235"></h1>
  <p class="banner"><strong>Test site.</strong> All people, patients and bills here are invented. Payments are simulated.</p>
  <a class="app" href="/ops/">Ops console<span>Trips, schedules, exceptions, billing</span></a>
  <a class="app" href="/family/">Family app / కుటుంబం / परिवार<span>Bookings, pickup code, records, bills</span></a>
  <a class="app" href="/companion/">Companion app / సహాయకుడు / साथी<span>Today's visits, pickup code check</span></a>
</main>
</body>
</html>
HTML

# Directory URLs serve their index.html; /ops, /family and /companion get a trailing slash.
cat > "$OUT/config.json" <<'JSON'
{
  "version": 3,
  "routes": [
    { "src": "/(.*)", "headers": { "X-Robots-Tag": "noindex, nofollow" }, "continue": true },
    { "src": "^/(ops|family|companion)$", "status": 308, "headers": { "Location": "/$1/" } },
    { "handle": "filesystem" },
    { "src": "^/(.+)/$", "dest": "/$1/index.html" }
  ]
}
JSON

step "staging site built: $OUT"
