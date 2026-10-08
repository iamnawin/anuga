#!/usr/bin/env bash
# Every fast check CI runs, without Docker: run before each push.
# Real-Supabase checks (db:test:supabase, journeys) need Docker: see docs/SETUP.md.
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
step() { printf '\n=== %s\n' "$*"; }

step "root: install, typecheck, database tests (PGlite)"
pnpm install --frozen-lockfile
pnpm typecheck
pnpm db:test

step "ops console: lint, typecheck, unit tests, build"
(cd apps/ops_console && pnpm lint && pnpm typecheck && pnpm test && pnpm build)

step "shared_dart: format, analyze, test"
(cd packages/shared_dart && dart pub get && dart format --output=none --set-exit-if-changed lib test && dart analyze --fatal-infos && dart test)

for app in companion_app family_app; do
  step "$app: format, analyze, test"
  (cd "apps/$app" && flutter pub get && dart format --output=none --set-exit-if-changed lib/main.dart lib/src test \
    && flutter analyze --fatal-infos && flutter test)
done

step "ALL CHECKS PASSED"
