# Welcome as the root entry

ROOT-ENTRY-20261113, Codex-owned routing correction requested explicitly by founder.
Root307 -> /app/ with no-store; fallback HTML forwards too. Existing applications
and authenticated-session behavior are unchanged; no other component merge.
Local syntax/config/no-loop/artifact checks passed. [Live proof](live-validation.json)
and [deployment metadata](deployment.json) confirm the published result:

- Bare root returns307 to `/app/`, with `Cache-Control: no-store`.
- Fresh signed-out Chrome lands on Welcome with the illustration; no chooser.
- Direct `/ops/login/` returns200; existing app bundle hashes are unchanged.
- [Screenshot from root navigation](root-welcome.png) was visually inspected.

Only Codex-owned [PR #41](https://github.com/iamnawin/anuga/pull/41) was merged
for this explicit request. Merge `29a8356`, READY deployment
`dpl_Hh646SE3ibGmxdFQe23oYjBsYjuC`. No other component, auth, database or session
behavior changed. Existing signed-in visitors still reach their role Home.

Application source `e8e0063` and its seven-job successful CI/artifacts were reused;
the new routing main CI is tracked on run43448459235 and was still in progress
when this receipt was written. No pending check is counted as passed. Earlier
scope-correction documentation PR #40 remains open and unmerged. This final
documentation receipt is also for review only; no further merge is planned.
