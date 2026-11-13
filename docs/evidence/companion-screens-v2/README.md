# COMP-V2: unified Companion screen implementation

Agent: Codex, Flutter implementation coordinator. Worktree:
`D:\AI-Workspace\Repos\anuga-companion-screens-v2`, branch
`feat/companion-screens-v2`, baseline `b834b53fbc19952e86161d3bdb049354dfb78291`.
Session start was not recorded; first observed clock checkpoint: 2026-11-13
15:05:07 IST. Current founder instruction authorizes this screen task, small
commits, push and draft PR only. No merge, deployment or hosted migrations.

## Specification and implementation plan

Read final spec and related handoff/navigation/master-list/review using `git show`
on `origin/ccr-d6e3aaf3-jvijtn` (research PR #31), without switching branches.
The final spec C1-C20 and founder-approved D1-D7 control implementation; D5=M0.
Local project instructions, product spec, tasks, architecture, execution/ledger,
UX registers, setup, tokens and ADRs were inspected. Global Obsidian preference
path was unavailable; repository documents supply the relevant context.

1. Inspect contracts and references. Verify screen-to-contract mapping below.
2. Build unified Today/Visits/Me, shared person/route/progress presentation and
   Help. Reuse existing themes, language callback and brand assets. Verify role
   routing, empty/loading/error/offline states, first-name-only privacy.
3. Present existing trip states as focused screens/forms. Reuse `CompanionApi`
   and `TripStateMachine`; preserve every persisted step. Verify pickup RPC,
   required handover checkbox, required completion note, issues/no-show, denied
   refresh and transient-error draft retention.
4. Validate EN/TE/HI, light/dark and 200% layouts, full app tests/analyze,
   `scripts/check-all.sh`, source scope and draft PR. Record actual results below.

No change to old apps, shared Dart, RPCs, RLS, auth, payment/upload adapters or
hosted data. Only the unified app's Companion mount changes in `app.dart`.
`url_launcher` and `web` were already locked transitive dependencies; declare
them directly at the existing versions for external phone/map launch and browser
network state. No new SDK, provider or network service.

## Screen coverage and contract gaps

| IDs | Implementation | Contract / limits |
| --- | --- | --- |
| C1, C2 | NEW, deferred | Missing profile-save, ID status/date and training projection. Propose restricted profile/onboarding/verification contract; do not fake it. |
| C3, C4 | CHANGE | `companion_my_trips`; Today/Visits, real dates, Drop/Return times on one visit; no companion greeting identity returned. |
| C5, C6 | CHANGE | Restricted essentials, first names, drawn home/centre route and external Navigate; configured support number missing, button disabled with explanation. |
| C7 | CHANGE | Existing `verify_pickup_otp`, six digits, server attempts-left and known lockout; `no_valid_code` conflates expired/used/locked/unissued, so display combined guidance. |
| C8 | CHANGE, partial | Real centre transition; historical pickup/arrival times require companion-safe event projection, deferred. |
| C9 | CHANGE | Staff-received UI gate, belongings checkbox, optional note through existing handover RPC. Checkboxes are not structured database fields. |
| C10, C11 | CHANGE, partial | Preserve handed_over -> session_done -> returning; use actual scheduled return, no invented handover time or hard-coded session duration. |
| C12, C13 | CHANGE, partial | Preserve dropped_home -> completed with mandatory typed note. Recipient is included in existing completion note, not a new structured field; no invented arrival time. |
| C14 | CHANGE, partial | Completed status and note acknowledgement; named thanks/historic timeline need missing profile/event contracts. |
| C15, C16 | CHANGE, partial | Existing private issue note / no_show transition; no configured wait setting exists, so 15-minute wording/eligibility is deferred. |
| C17, C18 | NEW, partial | Help, emergency 112/108 handoff, language and confirmed sign-out. No invented identity/verification; missing profile/availability/documents links not built. |
| C19, C20 | NEW, deferred | Availability storage, shift settings and verification-only upload adapter/storage/access/limits are missing. Never reuse family vault. |

Read RPCs are limited to `companion_my_trips`; writes to `advance_trip` and
`verify_pickup_otp`. No Family RPC, timeline or vault access is added. Raw contact
phones returned by the legacy model are never rendered; `detailsVisible` is
respected even if stale fields are populated. Eight visual stages map to existing
states; completed shares Home (8). Exception statuses use words without a fake
progress position.

Browser online/offline events proactively show the offline warning and disable
writes. Native transport failures show connection/retry guidance; no new native
connectivity SDK or offline queue. User drafts are memory-only and are cleared on
permission loss. Static Help/Me have no fabricated asynchronous loading/error.
Missing contract capabilities remain explicit open questions, not launch approval.

## Visual reference mapping

Opened all 26 November PNGs in `docs/design/Companion screen/`, the three October
boards and seven logo references through inspection contact sheets. Source
reference images remain in the original worktree, including its untracked assets;
none of that worktree was modified or copied into product code.

| C | November reference filename(s) |
| --- | --- |
| C1 | Invited companion account setup-4.png |
| C2 | Your verification status-13.png |
| C3 | Companion daily visit screen-7.png |
| C4 | Upcoming visits companion screen-2.png |
| C5 | Trip essentials companion screen-1.png |
| C6 | En route to Ravi-6.png |
| C7 | Confirm pickup with six-digit code-5.png |
| C8 | At the centre handover screen-19.png; Dialysis centre pickup check-in-2.png |
| C9 | Confirm handover-3.png |
| C10 | Session in progress-9.png |
| C11 | Returning home-8.png |
| C12 | Home arrival_ add visit note-10.png |
| C13 | Add visit note-11.png |
| C14 | Visit completed confirmation screen-16.png; Completed dialysis visit timeline-4.png |
| C15 | Report an issue bottom sheet-18.png; Dialysis Trip Issue Report Sheet-3.png |
| C16 | Patient pickup confirmation screen-14.png |
| C17 | Help and emergency support screen-15.png |
| C18 | Companion Profile and Settings-20.png; AnugaCare companion profile screen-6.png |
| C19 | Choose your weekly work shifts-17.png; AnugaCare weekly availability settings-1.png |
| C20 | Identity document upload screen-12.png |

`Find a Dialysis Centre Nearby-5.png` has no authorized C1-C20 counterpart and
does not authorize centre search. October `*-9.png` corresponds to C1/C2/C3/C5;
`*-8.png` to C6/C7/C8/C9; `*-10.png` to C11/C12/C13/C14. Their Records/earnings,
receipt uploads, real photos, fake map/ETA, branded shirt and verification badge
content is excluded. Existing original brand assets are reused.

## Validation receipt

Implementation/checkpoint in progress. Do not infer a full check, commit, PR,
merge, deployment or physical/native-speaker approval from this initial plan.
Executed results will replace this paragraph before handoff.
