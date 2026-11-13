# Family and patient screens v2

## Authorization and baseline

Codex, Family UI implementation. Session started 2026-11-13 19:02:54 IST.
Worktree: `D:\AI-Workspace\Repos\anuga-family-screens-v2`.
Branch: `feat/family-screens-v2`; baseline `b834b53fbc19952e86161d3bdb049354dfb78291`.
Push account verified by `gh auth status`: **iamnawin**; commit identity
`iamnawin <naveen.naidu21@gmail.com>`.

Binding specification: `origin/ccr-d6e3aaf3-jvijtn:docs/research/business-validation-2026-11/screen_mockups/Family_Screens_FINAL_Spec_v1.md`.
Founder approved the plan, six sequential groups, and `url_launcher ^6.3.3`
for dialer handoff only (112/108/configured support). No other new packages.
Support remains unavailable until a real configured number exists. Draft PR
only; no merge, deploy, migration, hosted mutation or real data authorized.

## Screen / contract inventory

| Screens | Existing presentation | Existing contract |
| --- | --- | --- |
| F12, F13, F34, F35 | Home/patient dropdown; new dashboard and access variants | family_my_patients, family_trip_board, my_notifications |
| F14 | BookingsTab | family_trip_board, family_care_requests |
| F15, F16 | TripScreen / cancel dialog | family_trip_board, family_trip_timeline, issue_pickup_otp, advance_trip |
| F38 | CareRequestScreen | family_care_options, family_request_care, family_care_requests, family_consents |
| F18 | InboxTab | my_notifications |
| F19-F21 | RecordsTab / picker / RecordScreen | audited vault_list_documents; existing PhotoSource and VaultFiles |
| F22-F23 | BillsTab / BillScreen | family_invoices, family_invoice_lines, existing Payments |
| F27, F31, F32 | New More / Help / About; legal notice blocked | existing locale/sign-out; static approved copy/build metadata |
| F28 | Existing merged ConsentScreen, targeted specification changes | family_consents, set_consent |

Verified: assigned/primary/backup companion names exist, no avatar choice. Display
assigned first name only. Owner/editor/patient may issue pickup codes in scheduled
or companion_en_route; viewer cannot. Owner/editor may cancel only scheduled visits.
Updates currently have nullable trip_id and no navigation handler. Database invoice
reads allow editors; UI must hide/deny Bills for every non-owner without claiming
the database has changed.

## Open backend proposals (not implemented)

1. Safe account display-name projection for personalized owner greeting. Generic greeting meanwhile.
2. Recurring schedule projection for weekly pattern. Do not infer a routine from visits.
3. Latest historical visit / paginated history projection. Do not claim loaded partial history is definitive.
4. Guarded Family address projection for home and centre. Route is schematic with available labels only.
5. Guarded visit-by-ID read for historical notification links. Only resolved rows open a visit; null/unresolved IDs get truthful information.
6. Configured support number read. Keep Call AnugaCare support label and unavailable explanation, no hard-coded number.
7. Explicit invoice due date / overdue state. Only Issued/Paid supported today.
8. Lawyer-approved privacy notice text/destination. No invented policy, terms or retention promises.
9. Upload-limit projection / structured too-large error. Existing server rejects oversized files; no client numeric business limit.
10. Owner-only invoice and line-item reads, with allowed owner and denied editor/viewer/patient tests. Separate backend task; no migration in this branch.

Section 4 stays excluded: self-setup, prepaid plans, payment links, receipts,
refunds, reschedule, invite family and deletion. No map/ETA/countdown/rating,
notification count, photo avatars, companion calling or verification badge.

## Visual sources

Opened October boards: `Family visit companion app flow-4.png` (F12/F14/F15),
`Visit summary and private health vault-5.png` (F15/F19-F21),
`A simpler patient companion view-7.png` (F35/F15/F31), and
`Family vault and prescription overview-14.png` (F27 visual vocabulary).
No FAM-1 through FAM-5 boards found on main. Images never authorize capabilities.

## Delivery ledger

| Group | Screens | State | Actual checks / delivery |
| --- | --- | --- | --- |
| 1 | F12 F13 F34 F35 | Locally complete; first push pending | Final check-all PASS: Family109/6 existing skips, unified91; 9 readable PNGs; review clear. |
| 2 | F14 F15 F16 | Pending | Not run |
| 3 | F38 F18 | Pending | Not run |
| 4 | F19 F20 F21 | Pending | Not run |
| 5 | F22 F23 | Pending | Not run |
| 6 | F27 F28 F31 F32 (About only) | Pending | Not run |

Each group: meaningful tests, analyze/test in both apps, actual synthetic renders
(light/dark/te or hi/200%), same-commit docs, push to the same draft PR, then verify
CI before starting the next. `scripts/check-all.sh` runs before each push.
Passed/failed/skipped/unavailable results are recorded separately. No phone,
native-speaker, real-Supabase or deployment pass is implied by widget screenshots.

### Group 1 validation history

- Baseline `flutter test --reporter expanded`: Family **94 passed / 6 existing skips**;
  unified **87 passed**. `flutter pub get` passed in all three Flutter packages.
- New unified shell tests first failed all four access levels against the original
  navigation (expected RED); later 3 passed / patient Help label failed. Corrected
  the navigation label rather than weakening the assertion.
- First `scripts/check-all.sh`: DB **209 passed / 11 existing skips**, Ops **70 passed**
  plus lint/typecheck/build, shared Dart **29 passed**, Companion **58 passed / 3 existing skips**,
  Family **106 passed / 6 existing skips**, analyzers passed. Unified **87 passed / 4 failed**:
  old routing tests expected the previous no-patient copy; update their assertions
  to the specification's localized setup/support explanation. Overall invocation failed.
- First unified `flutter build web --release --no-web-resources-cdn
  --dart-define=SUPABASE_URL=https://example.invalid
  --dart-define=SUPABASE_PUBLISHABLE_KEY=synthetic-build-only`: **PASS**, 43.3s.
  Existing CupertinoIcons font warning remains. This is a local synthetic build,
  with no hosted connection or deployment.
- Fresh review identified picker revocation visibility, patient sign-out reachability,
  and active-tab preservation across native picker/resume. Fixes and regressions
  required before delivery. Initial seven readable captures will be refreshed after fixes.
- Final `scripts/check-all.sh` (`artifacts/check-all-group1-final.log`): **ALL CHECKS PASSED**.
  DB **209 passed / 11 existing skips**; Ops **70 passed** plus lint/typecheck/build;
  shared Dart **29 passed** plus format/analyze; Companion **58 passed / 3 existing skips**;
  Family **109 passed / 6 existing skips**; unified **91 passed**. Both app
  `flutter analyze --fatal-infos` invocations passed with no issues; all format checks passed.
- New Home suite **15 passed**, including immediate picker revocation, confirmed
  patient sign-out, stable Records state through access refresh/resume, changed-state
  code removal, and issued-code consumption while backgrounded. Unified adds four
  access-level integration tests with no invoice/vault prefetch and session clearing.
  All reported review findings addressed; no unresolved medium finding.
- `flutter test test/support/capture_family.dart --reporter expanded`: **1 passed**;
  scoped harness analysis and diff check passed. Nine final actual widget PNGs,
  with local system fonts loaded only by the test harness. Initial Ahem renders and
  one wrong scroll finder were corrected; final renders opened and checked.
  Normal390px English owner navigation fits five destinations; Telugu/200% scroll.
  Viewport screenshots show scrollable content, not full-page captures.
- No native phone, dialer, real Supabase journey or native-speaker review run.
  Existing local-Supabase skips remain unchanged; no new skipped or weakened tests.
