# Text size preference - 2026-11-14

Agent: Codex. Task: `TEXT-SIZE-20261114`.
Worktree: `D:/AI-Workspace/Repos/anuga-text-size`, branch `feat/text-size-preference`,
starting commit `67cca2ec2434d6870f66b05596f4791de9e92c72`.
First observed session clock: 19:08:20 IST.

The founder reports the font is too large and requests a setting. The unified
root forced a minimum 115% scale. The regression test reproduced20 becoming23.

## Behavior

- Small90%, Standard100% (new default), Large115%, Extra large130%.
- Compose the factor with the device's actual, potentially nonlinear scaler.
  Preserve fonts, themes and touch targets.
- Reuse one control on Welcome, Family More, patient Help and Companion Me.
- Retain on navigation/sign-out; load/save the enum name through the existing
  SharedPreferencesAsync store (`anuga-text-size`). Missing/invalid names use
  Standard. Blocked storage still permits changes for the current session.
- Device/app preference; no patient or server account data. Existing language
  and auth storage keys remain independent.
- Optional widget slots preserve standalone apps. The unified app replaces its
  forced minimum; standalone legacy scaling stays intact.
- No new dependency, RPC, access rule, migration or provider change.

## Checks and retained failures

- Default-scale regression RED: expected20, actual23.
- Focused10 PASS: default/fallback, nonlinear scaling, selection/restored startup,
  no extra role/RPC calls, sign-out retention, owner/patient entry points, and
  EN/TE/HI at200% device text. Extra-large additionally exercises phone/OTP at
  360px with a keyboard inset.
- Initial tests found mismatched style inheritance during the new row's
  Companion-to-Welcome transition. Normalized only the row's styles; themes and
  animations remain. Removed a theme-cache experiment. Tests scroll settings
  into view, including lazy patient Help rows.
- First full check stopped on Family home formatting; corrected with dart format.
- Final full checks, CI, release build and real browser persistence pending at
  this checkpoint. Logs remain under ignored `artifacts/`.
- No physical-device/native-speaker acceptance claimed.

## Delivery boundary

Prepare a feature PR and synthetic preview. AGENTS explicitly limits prior merge/
publication authorization to its earlier task; this new feature's main merge
and live publication need founder approval after the reviewable work is ready.


2026-11-14 19:36:06 IST - TEXT-SIZE-20261114: scripts/check-all.sh ALL CHECKS PASSED: DB209/11 existing skips, Ops70+lint/typecheck/build, shared39, legacy Companion58/3 existing skips, Family181/6 existing skips, unified167. Format and fatal-info analyzers clean. Includes10 focused text-size cases with200% device scaling and Extra-large phone/OTP/keyboard across EN/TE/HI. Final lint null-aware collection warning corrected. Implementation commit/push/PR next; release build/browser persistence pending. No main merge or live deployment.
