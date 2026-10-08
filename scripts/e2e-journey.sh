#!/usr/bin/env bash
# M7: the first working journey, across apps, against Supabase local.
#
#   ops assigns a companion -> family sees the booking -> companion picks up with the
#   family's code and hands over at the centre -> family receives status (dispatched by
#   the notify-dispatch Edge Function) -> return journey completes -> ops sees it closed
#   -> ops records the fare and issues the bill -> family pays it (test mode) -> ops sees it paid.
#
# Uses the real clients: the ops console in a browser (Playwright), and the Dart API
# layers of the companion and family apps (same adapters the apps use). Synthetic data
# only. Needs: Supabase local running with the edge runtime, Node 24 + pnpm, Flutter,
# Playwright's Chromium, and a built ops console (`pnpm --filter @companion/ops_console build`).
#
#   SUPABASE_CLI="pnpm dlx supabase@2.120.0" scripts/e2e-journey.sh    # default CLI: supabase
#
# Evidence goes to $JOURNEY_OUT (default artifacts/journey): journey.log + screenshots.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT=${JOURNEY_OUT:-$ROOT/artifacts/journey}
SUPABASE_CLI=${SUPABASE_CLI:-supabase}
mkdir -p "$OUT/screenshots"
: > "$OUT/journey.log"
exec > >(tee -a "$OUT/journey.log") 2>&1

step() { printf '\n=== %s  %s\n' "$(date -u +%H:%M:%SZ)" "$*"; }
ops() { (cd "$ROOT/apps/ops_console" && SCREENSHOT_DIR="$OUT/screenshots" pnpm exec playwright test e2e/journey.spec.ts --reporter=list -g "$1"); }
dart_step() { (cd "$ROOT/apps/$1" && flutter test test/journey_test.dart --reporter=expanded --plain-name "$2"); }
helper() { node "$ROOT/scripts/journey.ts" "$@"; }

cd "$ROOT"
step "0. fresh synthetic seed and today's visit"
$SUPABASE_CLI db reset
eval "$($SUPABASE_CLI status -o env)"
export JOURNEY_STATE="$OUT/state.json" DATABASE_URL="$DB_URL" SUPABASE_URL="$API_URL" \
  SUPABASE_PUBLISHABLE_KEY="$PUBLISHABLE_KEY" SUPABASE_SERVICE_ROLE_KEY="$SERVICE_ROLE_KEY" \
  NEXT_PUBLIC_SUPABASE_URL="$API_URL" NEXT_PUBLIC_SUPABASE_ANON_KEY="$ANON_KEY"
helper setup

step "1. ops console: ops assigns the backup companion (browser)"
ops "journey 1:"

step "2. family: sees the booking, issues the pickup code"
dart_step family_app "journey 2:"

step "3. companion: sets off, picks up with the family's code, hands over at the centre"
dart_step companion_app "journey 3:"

step "3b. notify-dispatch: family receives the updates so far"
helper dispatch companion_changed,companion_en_route,picked_up,at_centre,handed_over

step "4. family: timeline and updates show the handover"
dart_step family_app "journey 4:"

step "5. companion: return journey, completes with a post-visit note"
dart_step companion_app "journey 5:"

step "5b. notify-dispatch: family receives the return-journey updates"
helper dispatch session_done,returning,dropped_home,completed

step "6. family: visit completed with the note"
dart_step family_app "journey 6:"

step "7. ops console: visit completed, exception queue clear (browser)"
ops "journey 7:"

step "8. ops console: records the cab fare, issues the month's invoice (browser)"
ops "journey 8:"

step "8b. notify-dispatch: the owner gets the bill"
helper dispatch-bill "₹550.00"

step "9. family: owner pays the bill in test mode; viewer cannot see bills"
dart_step family_app "journey 9:"

step "10. ops console: invoice paid (browser)"
ops "journey 10:"

step "report"
helper report
step "JOURNEY PASSED"
