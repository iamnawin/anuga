# Gates: production hardening, 2026-11-04

Scope: executable fixes and evidence; no merge, deploy, hosted cleanup, real SMS/payment or production changes. Prior GATES.md is the completed feature review, not production approval. This ledger governs the new hardening milestone.

- [x] G1: consent withdrawal masks Companion reads and denies actions for existing identities, with grant/restore/history tests
  CHECK: node --test --test-reporter=tap --test-isolation=none supabase/tests/consent_withdrawal.test.ts
  EXPECT: /# fail 0/
  EVIDENCE: automatic-evidence=v1; definition-sha256=7315517d62fb270e6910367877bfc347a96f4a08ac881f2bd5981add3e116adc; exit=0; EXPECT=matched; output-sha256=26fac2455737ebf6e0f386291e73dff1a45416407b294b6efda4bed689e29df8; output-bytes=1319; shell=C:\WINDOWS\system32\cmd.exe; cwd=D:\AI-Workspace\Repos\anuga-trips-fix; path=994d60dcc68d/58 entries

- [x] G2: database assignment conflicts, late completion, concurrent assignment attempts and started-visit reassignment are covered
  CHECK: node --test --test-reporter=tap --test-isolation=none supabase/tests/scheduling_conflicts.test.ts
  EXPECT: /# fail 0/
  EVIDENCE: automatic-evidence=v1; definition-sha256=226194469a66b0cb6f7302b4a00ff2651a56c77decfa6a8337e67c7eea75b5e6; exit=0; EXPECT=matched; output-sha256=af53b44a714db94020f65c34b63cf3dd096a01672cc1cc32dca58d6c203dfd5e; output-bytes=3109; shell=C:\WINDOWS\system32\cmd.exe; cwd=D:\AI-Workspace\Repos\anuga-trips-fix; path=994d60dcc68d/58 entries

- [x] G3: delayed role lookups cannot restore obsolete authenticated UI in Ops or unified app
  EVIDENCE: Four Ops regressions and two unified Flutter regressions failed before/passed after. PR25 CI 41993514673 passes all seven jobs, including real Supabase and debug APKs. Physical-device expiry remains G7.

- [x] G4: environment attestation, truthful notifications, operational runbooks and owner decisions reconcile the existing matrix
  CHECK: node --test --test-reporter=tap --test-isolation=none supabase/tests/dispatcher_unit.test.ts supabase/tests/vault_files_unit.test.ts supabase/tests/payments_unit.test.ts supabase/tests/production_attestation.test.ts
  EXPECT: /# fail 0/
  EVIDENCE: automatic-evidence=v1; definition-sha256=d85e5d88ff4309a713bde2094d601779923f3e6c4a08f1da844c52914c1ce5f0; exit=0; EXPECT=matched; output-sha256=4244bc5de828cd0169c00ee80bfcde33084550d91b7d03d0c8976e44ba414bc7; output-bytes=8672; shell=C:\WINDOWS\system32\cmd.exe; cwd=D:\AI-Workspace\Repos\anuga-trips-fix; path=994d60dcc68d/58 entries

- [x] G5: full local regression suite passes on final technical source
  CHECK: "C:/Program Files/Git/bin/bash.exe" scripts/check-all.sh
  EXPECT: ALL CHECKS PASSED
  EVIDENCE: automatic-evidence=v1; definition-sha256=98df180913d68aff0172d0f3a908ec37f128c7a37a8c1577a342a9393f9642de; exit=0; EXPECT=matched; output-sha256=bc249a83be76d0c13f6d250af6ed4ebfd8b8893dc6245f0a1a34cf29e8dfda18; output-bytes=60073; shell=C:\WINDOWS\system32\cmd.exe; cwd=D:\AI-Workspace\Repos\anuga-trips-fix; path=994d60dcc68d/58 entries. After later stacked changes, combined DB 215/215 decided cases pass (11 environment skips); root/Ops/shared checks passed before one local analyzer stall, then Companion/Family/unified analyze and 57/57/39 tests passed on clean reruns. Final-source CI is G6.

- [x] G6: technical candidates pass applicable real-Supabase/browser CI and Android build jobs
  EVIDENCE: PR24 CI 41849818581, PR25 CI 41993514673, PR26 CI 42041948190 and final technical source PR27 CI 42041948258 each pass all seven jobs. PR27 run 42041948258 verifies commit 618af1d85e62b91e19fee0507c0ac4aa6ac5b720, including real Supabase/browser journeys and all Android debug builds.

- [ ] G7: physical Android Chrome/PWA and native-speaker healthcare approval have actual signed receipts
  EVIDENCE: pending; hardware and human reviewers unavailable

- [ ] G8: production boundary/schema/backup restore, active-visit safety workflow and release approval have actual attestations
  EVIDENCE: pending; production changes/deployment not authorized

- [x] G9: final 31-row matrix/dashboard records exact fixes, PRs, evidence and remaining owner decisions
  EVIDENCE: `docs/PRODUCTION_READINESS.md` remains the 31-row source of truth; `docs/PRODUCTION_READINESS_DASHBOARD.md` links technical progress, owners, decisions and the exact external evidence sequence. Final technical source CI is 42041948258.
