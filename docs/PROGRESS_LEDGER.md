# AnugaCare progress ledger

Last reconciled: 2026-11-09 19:45:00 IST (Asia/Kolkata)

Current multi-agent checkpoint:
- **Codex (`feat/g7-ui-staging`, PR #28):** `7fa7cb2` / `e80ffd0`, CI `42343362420` seven successful jobs; independent review ready to merge, no Critical/Important findings. Owns PR #28 integration and `REL-002` hosted migration application.
- **Gemini CLI (`feat/anugacare-ui-modernization` in `D:\AI-Workspace\Ideas\Anuga`, PR #29):** Branched from `origin/main` (`ea6d142`). `WP-0` (`71fb555`), `WP-1`–`WP-6` (`d22c39d`), CI fix (`c4ced74`), and docs (`631ac5d`) pushed to **PR #29** (`https://github.com/iamnawin/anuga/pull/29`) and verified in **GitHub Actions CI runs `42625907826` and `42628795153` (`7/7` jobs `SUCCESS`)**. Synthetic Supabase (`vsvkllfgrnlbhdydysny`) identity, migration history, backup state, and RPC compatibility verified read-only; non-production Vercel preview deployed at `https://anuga-ptkyex1az-iamnawins-projects.vercel.app` (`dpl_6673mDsp1iZULg4uPa4SD8HPz2kC`, `READY`).

Statuses are `NOT_STARTED`, `IN_PROGRESS`, `IMPLEMENTED`, `VERIFIED`, `MERGED`
or `BLOCKED`. A higher state is never inferred from a lower one.

## Fixed task weights

The mission has 100 fixed points. Progress is recalculated from the evidence in
the task table, not estimated from chat activity.

| Task | Weight | Status | Dependency | Objective and acceptance | Branch / commit / PR | Tests and evidence | Remaining work / exact next action |
| --- | ---: | --- | --- | --- | --- | --- | --- |
| STATE-001 Durable recovery state | 5 | MERGED | None | Execution state, ledger, recovery and release checklist exist; HANDOFF/TASKS agree with Git and CI | Checkpoints `7a06f1b`, `c9cbf9f`; merged through PR #27 at `ea6d142` | Diff checks and corrected full-suite gate pass | Preserve these files at every later checkpoint |
| INT-001 Repository and PR audit | 8 | MERGED | None | Main, worktrees, local changes, PRs #21-#27, CI and migration chain are inventoried from actual sources | Evidence merged through PR #27 | Literal ancestry, diffs, migrations and seven-job CI verified before each merge | Reconcile again before deployment |
| INT-002 Hardening stack integration | 10 | MERGED | INT-001 | #22-#27 remain compatible and land on main in order without weakening access controls | Merge commits `a8109ae`, `5b838b6`, `8d175b4`, `038fb67`, `88b0c0b`, `ea6d142` | Final head CI `42203978157` 7/7; main run `42205624861` green; hosted changes none | Retain undeployed state until hosted prerequisites pass |
| UI-001 Brand system and reference reconciliation | 7 | VERIFIED | INT-002 | Existing tokens remain authoritative; new boards are stored as source references and mapped to supported capabilities | Codex `feat/g7-ui-staging` (`17b6021`..`7fa7cb2`) + Gemini CLI PR #29 (`71fb555`..`c4ced74`) | Three inputs mapped; 17 PR #28 + 5 PR #29 CI screenshots inspected; `docs/UX_AUDIT.md` & `docs/UX_IMPLEMENTATION_PLAN.md` recorded | Reconcile PR #28 and PR #29 on merge |
| UI-002 Family experience | 10 | VERIFIED | UI-001 | Supported request, pending, confirmation, assignment, OTP, milestones, refresh and completion screens use real RPC data and accessible states | Codex PR #28 (`0644dd9`) + Gemini CLI PR #29 (`c4ced74`) | PR #29 CI `42625907826` 7/7 green (`family-app`, `anugacare-app`, `supabase-local` Playwright E2E) | Coordinate PR #28 / #29 merge; product decisions `DEC-01` & E2E picker update optional |
| UI-003 Patient-supported experience | 5 | VERIFIED | UI-001 | Deliver the elderly-friendly view permitted by the existing role/access contract; no invented independent role | Codex PR #28 (`0644dd9`) + Gemini CLI PR #29 (`c4ced74`) | Existing role contract retained; inline pickup code card (`Key('active-pickup-code-card')`) & emergency banner verified in CI `42625907826` | Human device/language approval remains `QA-002` |
| UI-004 Companion experience | 10 | VERIFIED | UI-001, INT-002 | Present the real nine-state lifecycle, prerequisites, retries and persistence without replacing it with four fictional states | Codex PR #28 (`8eb152e`) + Gemini CLI PR #29 (`c4ced74`) | PR #29 CI `42625907826` 7/7 green (`companion-app` 58/58 + APK + `supabase-local` journey) | Coordinate PR #28 / #29 merge; product decision `DEC-02` for `no_show` time-gate |
| NAV-001 Companion navigation handoff | 6 | NOT_STARTED | UI-004 | Use configured real map/navigation capability or an honest external handoff; no fake map, route or ETA | None | No evidence yet | Inventory current location libraries/config and choose the smallest supported action |
| PWA-001 Installability and privacy cache | 8 | IMPLEMENTED | INT-002 | Manifest, icons, scope, service worker, session restore, update and private-cache behavior are verified on deployed staging | PR #20 merged before current stack | Existing PWA readiness tests/docs; physical install not performed | Re-audit current main after stack/UI integration; run desktop checks and prepare physical-device cases |
| QA-001 Complete synthetic journey | 10 | VERIFIED | INT-002, UI-002, UI-004 | Family -> Ops -> Companion -> Family persists with OTP, handover, return, issue privacy and denial controls | PR #28 (`7fa7cb2`, CI `42343362420`) + PR #29 (`c4ced74`, CI `42625907826`) | Both PR #28 and PR #29 pass 7/7 CI jobs including `supabase-local` (`care_request.spec.ts`, `issue_handling.spec.ts`, `scripts/e2e-journey.sh`) | Rerun against deployed synthetic staging after `REL-002` unblocks |
| QA-002 Physical mobile and language acceptance | 6 | BLOCKED | PWA-001, REL-002 | Android Chrome/PWA, small-screen/200% text and human Telugu/Hindi wording are signed with real evidence | Gemini CLI PR #29 (`c4ced74`, `WP-5` `UX-06` TE/HI copy updates) | Automated locale & 200% text tests pass; no physical device or human language approval supplied | Founder runs device plan on Android phone; named TE/HI reviewers sign results |
| REL-001 Main PR/CI completion | 7 | IN_PROGRESS | INT-002 | In-scope stack and later UI release PRs are merged with required CI and exact SHAs recorded | #22-#27 merged; Codex PR #28 (`7fa7cb2`); Gemini CLI PR #29 (`c4ced74`) | PR #28 CI `42343362420` 7/7 green; PR #29 CI `42625907826` 7/7 green | Reconcile and merge PR #28 and PR #29 into `main` when authorized |
| REL-002 Synthetic staging deployment | 8 | BLOCKED | REL-001, PWA-001, QA-001 | Exact main commit and compatible migrations deploy only to positively identified synthetic staging; URLs and role workflows are verified | Preview `dpl_6673mDsp1iZULg4uPa4SD8HPz2kC` READY at `https://anuga-ptkyex1az-iamnawins-projects.vercel.app`; production alias `https://anuga.vercel.app` remains PR #21 (`21ae9bc`) | Supabase CLI verified `vsvkllfgrnlbhdydysny` (`ap-south-1`, PG `17.11.0.003`), migration table, backups (`pitr_enabled: false`, `backups: []`), and 10/10 `staging-smoke.ts` pass; 5 preview routes HTTP 200 | Reconcile remote `schema_migrations`, apply Nov 4 migrations (`20261104000100`–`20261104000300`) when authorized, and promote after PR #28/#29 merge |

## Progress calculation

Current evidence-weighted state at 2026-11-09 19:15 IST:

- Implemented: 73/100 (STATE-001, INT-001, INT-002, UI-001, UI-002, UI-003, UI-004, PWA-001, QA-001)
- Verified: 65/100 (STATE-001, INT-001, INT-002, UI-001, UI-002, UI-003, UI-004, QA-001)
- Merged into current `main`: 23/100 (STATE-001, INT-001, INT-002)
- Deployed and verified on synthetic staging: 0/100 for this mission's target commit

These figures intentionally exclude earlier main functionality unless it satisfies
a named mission task. Blocked work remains in the denominator.
