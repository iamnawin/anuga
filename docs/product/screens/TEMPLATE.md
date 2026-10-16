# Screen specification template

ID/name; task/owner; base SHA; design/implementation/verification/release status;
approval evidence or pending decision. Link inventory/feature/component IDs.

1. User, patient access level, purpose and concrete scenario.
2. Entry/route, back/exit paths and session/role behavior.
3. Annotated layout, preferred reference filename/panel and intentional differences.
4. Actual reused components/tokens and source paths; no invented shared implementation.
5. Fields/defaults, validation and data source. No hardcoded patient/demo facts.
6. Action table: actor/input → handler/API → result/state/notification → failure/retry.
7. Loading, empty, no access, validation, offline/failure, submitting, success/retry;
   mark not applicable with reason, not omitted.
8. Permissions for owner/editor/patient/viewer, assigned/unassigned Companion,
   Ops/anonymous; distinguish presentation and database enforcement.
9. Narrow/wide, keyboard/focus, screen reader, full large text, dark, en/te/hi.
10. Testable scenarios, exact evidence/checks/SHA, skipped checks, dependencies and
    founder decisions. Do not mark Approved/Passed/released without actual evidence.
