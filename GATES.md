# Gates: care request and visit issue review

OWNS: GATES.md, supabase/migrations/**, supabase/tests/**, apps/ops_console/**, apps/family_app/**, apps/companion_app/**, docs/HANDOFF.md, docs/TASKS.md, docs/evidence/issue-review-2026-11-04/**

Scope: review Request Care through assignment, issue reporting and explicit Ops resolution; fix demonstrated defects and verify privacy, permissions, retry safety and persisted visit integrity. Physical-phone/native-speaker approval, takeover policy, cleanup, merge and deployment are outside this code-review task.

- [x] G1: SQL contracts enforce care permissions, consent, duplicates, issue privacy, guarded resolution and preserved pickup facts
  CHECK: node --test --test-reporter=tap --test-isolation=none supabase/tests/care_requests.test.ts supabase/tests/issue_handling.test.ts
  EXPECT: /# fail 0/
  EVIDENCE: automatic-evidence=v1; definition-sha256=2c48b30cfd89b3afb93bb3034e6e6e35f13fce93c5b94b0aba8ba5a195617140; exit=0; EXPECT=matched; output-sha256=3b7fcbc02fc84b42a53fbcf079668d8aad7b1a8487ec4535a0ec07d130a1e898; output-bytes=5675; shell=C:\WINDOWS\system32\cmd.exe; cwd=D:\AI-Workspace\Repos\anuga-trips-fix; path=994d60dcc68d/58 entries

- [x] G2: required fast regression suite passes for database, Ops, shared Dart and all three Flutter apps
  CHECK: "C:/Program Files/Git/bin/bash.exe" scripts/check-all.sh
  EXPECT: ALL CHECKS PASSED
  EVIDENCE: automatic-evidence=v1; definition-sha256=98df180913d68aff0172d0f3a908ec37f128c7a37a8c1577a342a9393f9642de; exit=0; EXPECT=matched; output-sha256=1931f5454ab81ca90e79eb9a99daa0fb70ce8b1ed3b8d1ff87adcdc8c4521500; output-bytes=59439; shell=C:\WINDOWS\system32\cmd.exe; cwd=D:\AI-Workspace\Repos\anuga-trips-fix; path=994d60dcc68d/58 entries

- [x] G3: final source CI proves the real Supabase and browser care-request/issue journeys
  CHECK: node --input-type=commonjs -e "const {execFileSync}=require('node:child_process');const a=require('node:assert/strict');const sha='335b58bdaf4eaa51210f9d124983cf61e409cc98';const r=JSON.parse(execFileSync('gh',['run','view','41840577234','--json','headSha,conclusion,jobs'],{encoding:'utf8'}));a.equal(r.headSha,sha);a.equal(r.conclusion,'success');a.deepEqual(r.jobs.map(j=>j.name).sort(),['anugacare-app','companion-app','db-tests','family-app','ops-console','shared-dart','supabase-local']);r.jobs.forEach(j=>a.equal(j.conclusion,'success'));const steps=r.jobs.find(j=>j.name==='supabase-local').steps;['Family submits, ops fulfils, Family sees persisted status','Visit issue, explicit Ops resolution, private Family status'].forEach(name=>a.equal(steps.find(s=>s.name===name).conclusion,'success'));a.equal(execFileSync('git',['diff',sha,'--','apps','supabase','packages','scripts','.github','package.json','pnpm-lock.yaml'],{encoding:'utf8'}),'');console.log('CI_ACCEPTANCE_PASSED');"
  EXPECT: CI_ACCEPTANCE_PASSED
  EVIDENCE: automatic-evidence=v1; definition-sha256=9080015dfd7450ef3df6e0f923bfb1d836db539ed403a192ff53cdbcfa630835; exit=0; EXPECT=matched; output-sha256=72b02f9725d798bf68cbd5a562053ceac8d46f9c5aa2694090fd754c3b81af81; output-bytes=21; shell=C:\WINDOWS\system32\cmd.exe; cwd=D:\AI-Workspace\Repos\anuga-trips-fix; path=994d60dcc68d/58 entries

- [x] G4: final source review and receipt reconcile every scoped requirement, changes, evidence and remaining limits
  EVIDENCE: Root traced request, consent, duplicate checks, assignment, private-note paths, guarded incident resolution and persisted Family reads. Fresh read-only review found the booking race; both SQL/widget failures were reproduced before fixes, and final independent source review found no remaining blocker. Acceptance mapping and rollout/device/policy limits are in docs/evidence/issue-review-2026-11-04/README.md; final-source CI summary is ci-summary.json. Five scoped gates met; no deployment or hosted migration is claimed.

- [x] G5: Family care requests retain the newest refresh result, clear failed reads, preserve retry identity and pass EN/TE/HI form checks
  CHECK: flutter test test/care_request_test.dart --reporter expanded
  EXPECT: All tests passed!
  CWD: apps/family_app
  EVIDENCE: automatic-evidence=v1; definition-sha256=d6dd5aaa6cdea5534cd741bf3095381cfa8d8ed1019b5721b71b438b1a79dff5; exit=0; EXPECT=matched; output-sha256=2e9578b3dd1bc8f5efba135cde42c3de4abbdc8180097d814bfe35ca375031ca; output-bytes=1690; shell=C:\WINDOWS\system32\cmd.exe; cwd=D:\AI-Workspace\Repos\anuga-trips-fix\apps\family_app; path=994d60dcc68d/58 entries
