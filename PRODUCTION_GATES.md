# Gates: production hardening, 2026-11-04

Scope: executable fixes and evidence; no merge, deploy, hosted cleanup, real SMS/payment or production changes. Prior GATES.md is the completed feature review, not production approval. This ledger governs the new hardening milestone.

- [x] G1: consent withdrawal masks Companion reads and denies actions for existing identities, with grant/restore/history tests
  CHECK: node --test --test-reporter=tap --test-isolation=none supabase/tests/consent_withdrawal.test.ts
  EXPECT: /# fail 0/
  EVIDENCE: automatic-evidence=v1; definition-sha256=7315517d62fb270e6910367877bfc347a96f4a08ac881f2bd5981add3e116adc; exit=0; EXPECT=matched; output-sha256=26fac2455737ebf6e0f386291e73dff1a45416407b294b6efda4bed689e29df8; output-bytes=1319; shell=C:\WINDOWS\system32\cmd.exe; cwd=D:\AI-Workspace\Repos\anuga-trips-fix; path=994d60dcc68d/58 entries

- [ ] G2: database assignment conflicts, late completion, concurrent assignment attempts and started-visit reassignment are covered
  EVIDENCE: pending

- [ ] G3: delayed role lookups cannot restore obsolete authenticated UI in Ops or unified app
  EVIDENCE: pending; requires failing-before/passing-after controlled tests in both clients

- [ ] G4: environment attestation, truthful notifications, operational runbooks and owner decisions reconcile the existing matrix
  EVIDENCE: pending

- [x] G5: full local regression suite passes on final technical source
  CHECK: "C:/Program Files/Git/bin/bash.exe" scripts/check-all.sh
  EXPECT: ALL CHECKS PASSED
  EVIDENCE: automatic-evidence=v1; definition-sha256=98df180913d68aff0172d0f3a908ec37f128c7a37a8c1577a342a9393f9642de; exit=0; EXPECT=matched; output-sha256=bc249a83be76d0c13f6d250af6ed4ebfd8b8893dc6245f0a1a34cf29e8dfda18; output-bytes=60073; shell=C:\WINDOWS\system32\cmd.exe; cwd=D:\AI-Workspace\Repos\anuga-trips-fix; path=994d60dcc68d/58 entries

- [ ] G6: technical candidates pass applicable real-Supabase/browser CI and Android build jobs
  EVIDENCE: pending

- [ ] G7: physical Android Chrome/PWA and native-speaker healthcare approval have actual signed receipts
  EVIDENCE: pending; hardware and human reviewers unavailable

- [ ] G8: production boundary/schema/backup restore, active-visit safety workflow and release approval have actual attestations
  EVIDENCE: pending; production changes/deployment not authorized

- [ ] G9: final 31-row matrix/dashboard records exact fixes, PRs, evidence and remaining owner decisions
  EVIDENCE: pending
