#!/usr/bin/env bash
# Builds the staging site: ops console (/ops/), family app (/family/), companion
# app (/companion/) and the unified AnugaCare app (/app/) as static files in Vercel's
# prebuilt format, pointed at the staging Supabase project. SYNTHETIC DATA ONLY: see docs/adr/0004-hosted-staging.md.
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
pnpm install --frozen-lockfile
(cd apps/ops_console && OPS_STATIC_EXPORT=1 OPS_BASE_PATH=/ops NEXT_TELEMETRY_DISABLED=1 \
  NEXT_PUBLIC_SUPABASE_URL="$STAGING_SUPABASE_URL" NEXT_PUBLIC_SUPABASE_ANON_KEY="$STAGING_SUPABASE_ANON_KEY" \
  pnpm exec next build)
cp -r apps/ops_console/out "$OUT/static/ops"

for pair in family_app:family companion_app:companion anugacare_app:app; do
  dir=${pair%%:*} app=${pair#*:}
  step "$dir -> /$app/"
  (cd "apps/$dir" && flutter pub get && flutter build web --release --no-web-resources-cdn --base-href "/$app/" \
    --dart-define=SUPABASE_URL="$STAGING_SUPABASE_URL" --dart-define=SUPABASE_PUBLISHABLE_KEY="$STAGING_SUPABASE_ANON_KEY")
  cp -r "apps/$dir/build/web" "$OUT/static/$app"
done

step "app entry and routing"
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
<meta http-equiv="refresh" content="0;url=/app/">
</head>
<body>
<p><a href="/app/">Open AnugaCare</a></p>
</body>
</html>
HTML

# Directory URLs serve their index.html; /ops, /family, /companion and /app get a trailing slash.
cat > "$OUT/config.json" <<'JSON'
{
  "version": 3,
  "routes": [
    { "src": "/(.*)", "headers": { "X-Robots-Tag": "noindex, nofollow" }, "continue": true },
    { "src": "^/$", "status": 307, "headers": { "Location": "/app/", "Cache-Control": "no-store" } },
    { "src": "^/(ops|family|companion|app)$", "status": 308, "headers": { "Location": "/$1/" } },
    { "handle": "filesystem" },
    { "src": "^/(.+)/$", "dest": "/$1/index.html" }
  ]
}
JSON

step "staging site built: $OUT"
