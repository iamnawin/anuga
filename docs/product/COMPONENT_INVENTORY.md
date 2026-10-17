# Component inventory

## ANU-002 working-tree update (2026-10-17)

Implementation locally complete and reviewed over base 69bbb36 on
docs/product-inventory-bootstrap; sole writer Codex coordinator. Welcome, role restoration/denial and
lookup-retry plus authoritative pending/active/disabled lifecycle implemented
and tested locally under provisional F1-F4 defaults; no rollout approval.
[Contract](PILOT_ACCESS_CONTRACT.md), [current evidence](../evidence/anu002-lifecycle/README.md).
Overall ANU-002 remains Partial for device/human/rollout checks. No release/deployment.
[Current review/commit receipt](../evidence/anu002-review/README.md).
Current evidence: [ANU-002 receipt](../delivery/tasks/ANU-002.md) and
[current lifecycle verification](../evidence/anu002-lifecycle/README.md);
[earlier entry evidence](../evidence/anu002/README.md) is historical. All other rows retain
their main/historical verification defaults below.

Audit 2026-10-16, main 64c4603. [Baseline](AUDIT_BASELINE.md). Every row is an
existing source component or repeated pattern; do not create a new abstraction
just because it has an inventory ID. Flutter and React share the design contract,
not imports. Default owners Unassigned except ANU-002 entry changes above; baseline implementation Implemented for listed scope;
baseline verification Partial historical, with current entry checks above; release historical E-RELEASE,
per-variant runtime status Unknown. These 14 records are reusable contracts, not
an exhaustive count of private helper classes.

| ID | Name / actual symbols | Source | Consumers | Variants/behavior | Tokens, interaction, accessibility/localization | Test evidence (located, not run) |
| --- | --- | --- | --- | --- | --- | --- |
| CMP-001 | Shell and navigation; OpsShell / static two-link welcome | [OpsShell.tsx](../../apps/ops_console/src/components/OpsShell.tsx) | SCR-AUTH-001; SCR-OPS-001/002/004/006/008 | Sidebar/wrapping header; root links; role gate in provider | globals.css mint/teal, focus and labelled table regions; welcome has en/te/hi, dark scheme and focus; local browser evidence | ops e2e; root session receipt |
| CMP-002 | Flutter app shell/themes and language menus; FamilyApp / CompanionApp / LanguageMenu | [app.dart](../../apps/family_app/lib/src/app.dart) | All Family views; parallel Companion app.dart | Light/dark; locale; auth/home switch; patient-sensitive navigation | 48 targets, 56 primary, minimum 1.15 text/no upper cap; en/te/hi ARB; startup/resume and Auth/access-event resolver gate implemented/tested; lifecycle gate locally implemented; native/rollout gates open | full_app_test; full_trip_test; l10n tests |
| CMP-003 | Phone field pattern; TextField / labelled HTML input; not shared implementation | [login_screen.dart](../../apps/family_app/lib/src/screens/login_screen.dart) | SCR-AUTH-002/004/006 | tel keyboard/autofill; shared normalizeIndianMobile contract | Theme/CSS boundaries; inline validation/error; busy locks fields/submit and exposes progress | shared phone tests; ops phone_format; full app sign-in tests |
| CMP-004 | Six-digit OTP pattern; Single code TextField/input | [login_screen.dart](../../apps/companion_app/lib/src/screens/login_screen.dart) | SCR-AUTH-003/005/007; SCR-COMP-003 | Login and pickup have different APIs; maxLength 6, code validation | Input labels/autofill for login; no fake countdown; stale code clears; busy locks Change number | full_trip_test; trip_screen_test; ops e2e |
| CMP-005 | Primary/secondary/destructive buttons; Material themes; .btn CSS variants | [globals.css](../../apps/ops_console/src/app/globals.css) | Auth and all action views | Primary, outline, danger; per-screen busy behavior | 48 target/56 Flutter primary; focus/dark; consumer localizes label; no universal busy indicator | components.test; app widget tests; historical S3-S5 visual receipts |
| CMP-006 | Form field and validation pattern; InputDecoration / .field; local errors | [records_tab.dart](../../apps/family_app/lib/src/screens/records_tab.dart) | SCR-FAM-008; SCR-OPS-009; auth forms | Phone/code/title/fare validation; no global validation-summary widget | Large wrapped labels, native keyboard; HTML error alerts; Flutter error text; focus-on-error Unknown | records_test; money.test; phone_format; components.test |
| CMP-007 | Visit/record/bill cards and list rows; Private _TripTile, Card/ListTile patterns | [trips_screen.dart](../../apps/companion_app/lib/src/screens/trips_screen.dart) | SCR-COMP-001; SCR-FAM-002/006/012/015 | Actual schedule/status; hidden detail fallback; no fake avatar/map | Mint surface; wrap; large-text/card interaction; localized status/date | trip/full-app/records/bills tests |
| CMP-008 | Status chips; StatusBadge / Material Chip + statusLabel | [StatusBadge.tsx](../../apps/ops_console/src/components/StatusBadge.tsx) | SCR-OPS-002/006; SCR-COMP-001/002; SCR-FAM-003 | All trip statuses; late and invoice labels local to consumer | Text plus color/glyph; translated; tokens/light-dark; no interaction | messages.test; trip_actions_test; l10n tests |
| CMP-009 | Timeline and facts; Private _Fact, event rows; no cross-platform timeline primitive | [trip_screen.dart](../../apps/family_app/lib/src/screens/trip_screen.dart) | SCR-FAM-003; SCR-COMP-002 facts | Ordered actual trip_events; completed note | Readable labels/date, wrap/scroll; no estimated/fake milestones | family trip_screen_test and supabase_local_test |
| CMP-010 | Confirmation/note/modal pattern; AlertDialog/_NoteDialog/_CancelDialog; native window.confirm | [trip_screen.dart](../../apps/companion_app/lib/src/screens/trip_screen.dart) | SCR-COMP-004/005; SCR-FAM-004/005/007/008/011/014; SCR-OPS-007 | Confirm, cancel, optional reason, required note, source sheet | Scrollable dialogs; standard keyboard/focus; localized buttons; web native confirm; focus return must be checked | app trip/records/bills tests; ops e2e |
| CMP-011 | CarePanel and CareHeading; Reusable Family presentation widgets | [care_ui.dart](../../apps/family_app/lib/src/screens/care_ui.dart) | Family login/records/viewer/consent/bills/trip | Panel/section heading with existing theme | Token surface/padding, wrap and semantic text; disabled/loading provided by consumer | Family full_app/records/bills; S5 visual receipt |
| CMP-012 | Trip action presentation; TripAction widgets driven by actionsFor | [trip_actions.dart](../../apps/companion_app/lib/src/trip_actions.dart) | SCR-COMP-002/003/004/005 | Forward, no-show, issue, completion; state-machine contract | Meaningful glyphs and labels, busy state; no action invented from image | trip_actions_test; trip_screen_test; shared state-machine tests |
| CMP-013 | Patient picker and scalable bottom nav; DropdownButtonFormField / NavigationBar | [home_screen.dart](../../apps/family_app/lib/src/screens/home_screen.dart) | SCR-FAM-001/002/006/012/015 | One/many/no patient; four actual destinations | Bounded scroll header; long labels, text-scale compensation and horizontal nav scroll; localized | full_app_test; S5 large-text two-patient capture receipt |
| CMP-014 | Companion assignment selectors; CompanionSelect / ScheduleAssignForm / ReassignTrip | [CompanionSelect.tsx](../../apps/ops_console/src/components/CompanionSelect.tsx) | SCR-OPS-003/005 | Primary/backup/one trip; eligible/ineligible reason; database validates | Native labelled select, option descriptions, busy/disabled/error; en/te/hi via I18nProvider | components.test; api.test; ops e2e |

## Related actual source locations

- [Companion shell/theme/language](../../apps/companion_app/lib/src/app.dart) and
  [Family shell](../../apps/family_app/lib/src/app.dart) are separate implementations.
- [ErrorMessage](../../apps/ops_console/src/components/ErrorMessage.tsx) uses existing
  error mapping/alert presentation; [I18nProvider](../../apps/ops_console/src/components/I18nProvider.tsx)
  supplies Ops strings from [messages](../../apps/ops_console/src/lib/messages.ts).
- [ScheduleAssignForm](../../apps/ops_console/src/components/ScheduleAssignForm.tsx),
  [ReassignTrip](../../apps/ops_console/src/components/ReassignTrip.tsx),
  [FareEditor](../../apps/ops_console/src/components/FareEditor.tsx) own inline form state.
- AuthProvider/ApiProvider are infrastructure, not new UI primitives. Preserve them.
- Loading/empty/error/retry states are currently local Text/p elements and refresh
  actions; no universal EmptyState, RetryBanner or ValidationSummary exists.
  Family initial patient load and image viewer lack explicit retry; bill-line
  loading has no explicit failure catch. Do not inventory those as finished components.

## Evidence index

| Platform | Exact evidence paths | What it establishes |
| --- | --- | --- |
| Family | [full app](../../apps/family_app/test/full_app_test.dart), [trip](../../apps/family_app/test/trip_screen_test.dart), [records](../../apps/family_app/test/records_test.dart), [bills](../../apps/family_app/test/bills_test.dart), [l10n](../../apps/family_app/test/l10n_test.dart) | Existing assertions, including no-linked-patient and viewer denial; not executed today |
| Companion | [full trip](../../apps/companion_app/test/full_trip_test.dart), [trip](../../apps/companion_app/test/trip_screen_test.dart), [actions](../../apps/companion_app/test/trip_actions_test.dart), [l10n](../../apps/companion_app/test/l10n_test.dart) | Wrong role/new-number rejection, journey/actions; not executed today |
| Ops | [components](../../apps/ops_console/test/components.test.tsx), [API](../../apps/ops_console/test/api.test.ts), [phone](../../apps/ops_console/test/phone_format.test.ts), [messages](../../apps/ops_console/test/messages.test.ts), [browser](../../apps/ops_console/e2e/ops_console.spec.ts) | Located/read component/API/role assertions; not executed today |
| Historical visuals | [S3](../evidence/s3-ui/README.md), [S4](../evidence/s4-ui/README.md), [S5](../evidence/s5-ui/README.md) | Browser intercepted or widget synthetic render receipts; not device or current runtime verification |

Source tokens: [design contract](../design/tokens.md), Ops globals.css and the two
app themes. Loading/error/disabled semantics vary by consumer; inspect and specify
them for a scheduled change. Native-speaker quality of Telugu/Hindi remains Unknown.
