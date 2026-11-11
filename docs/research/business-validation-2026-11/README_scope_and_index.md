# AnugaCare business research: index and scope

Folder: `docs/research/business-validation-2026-11/`. Research only. No application code, no changes to development branches, no outreach, no spend.
Labels used throughout: `[V]` found in a source, `[E]` estimate, `[U]` not found or conflicting, `[I]` needs interviews, a centre, a broker, a CA or a lawyer.

## Strategic frame (from 2026-11-11)

AnugaCare is a trusted companionship and assisted-mobility service. **Dialysis recurring visits are the market-entry wedge (scenario D1), not the brand.** Start with `AnugaCare_Strategy_v2_Long_Term_Vision.md`.

## Files

| File | Scope | Notes |
|---|---|---|
| `AnugaCare_Strategy_v2_Long_Term_Vision.md` | **Whole business** | Vision, brand, service categories, phased roadmap, acquisition, positioning, two-week trial, narrow vs broad |
| `AnugaCare_Hospital_and_Centre_Partnership_Strategy.md` | Whole business (dialysis first) | No assumed permission or endorsement; verified handover |
| `AnugaCare_Final_Pricing_and_Decision_Memo.md` | **D1 dialysis** | Pricing, success conditions, decision memo for the dialysis launch |
| `AnugaCare_Pricing_Structure_and_Bypass_Defence.md` | **D1 dialysis** | Pricing structure and bypass defence (bypass principles are general) |
| `AnugaCare_Mobility_Waiting_and_Segment_Analysis.md` | **D1 dialysis** | Vehicle costs, wait time, segments, frequency, companion vehicles |
| `AnugaCare_Scheduling_Analysis.md` | **D1 dialysis** | Day-level simulation; reliable visits per companion per day |
| `AnugaCare_Companion_Model_Recruitment_and_Pay.md` | **D1 dialysis** pay figures; selection process is general | Open vs curated platform, pay, funnel, legal form |
| `AnugaCare_Interview_Script_and_Deposit_Offer.md` | **D1 dialysis** | Drafts only, never sent |
| `AnugaCare_Validation_Round2_Report.md` | **D1 dialysis** | Round 2 challenge of price, break-even and centres |
| `v1-original/` | **D1 dialysis**, preserved unchanged | Original report and models with checksums in `CHECKSUMS.txt` |
| `model_v2` to `model_v10` scripts and results | **D1 dialysis** | Sensitivity, projection, pricing, mobility, frequency, vehicles, scheduling |
| `model_v11_trial_and_category_floors.py` / `model_v11_results.md` | Trial = D1; category floors = other categories (lower bounds only, not dialysis economics) | Run `python3 model_v11_trial_and_category_floors.py` |

## Rule for readers

**Do not apply dialysis unit economics to other service categories.** Prices, margins, scheduling limits and companion numbers in D1 files belong to dialysis. Each future category needs its own measured pilot before any price or margin is published. Cost floors in model_v11 are lower bounds from hours, wages and fixed costs; they are not forecasts.

## Reproducing results

All scripts are standalone Python 3 with numpy: `python3 model_vN_....py > model_vN_results.md`. Later scripts import earlier ones, so keep them in the same folder.
