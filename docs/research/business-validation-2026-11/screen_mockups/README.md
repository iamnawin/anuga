# Screen mockups

One folder per screen: the image (`mockup.webp`) and a `README.md` with a verdict, what each element does and the data it uses, and the changes needed. Images are direction, not specification.

## Review of the 5 companion screens you shared (2026-11-12)

| Folder | Screen | Verdict |
|---|---|---|
| `C18_me` | Me | Good. 4 small fixes |
| `C8_at_the_centre` | At the centre | Good. Add progress bar, Navigate, times |
| `C15_report_issue` | Report an issue | Sheet fine. Behind it: raw phone number, non-dialysis wording, odd date |
| `C19_availability` | Availability | Redesign: per-day grid, shifts that match scheduling, no Evening |
| `C14_visit_completed` | Visit completed | Nearly there. Duplicate title, add summary |

Common issues across all five:
- Pick one bottom nav for the companion app and use it everywhere.
- Same header pattern on every screen.
- Every screen needs loading, error and offline states.
- Telugu and Hindi, dark mode and 200% text are not shown.
- No icon fits the patient or centre yet (see `_new_features`).

## New features: `_new_features/README.md`
Centre search with photo, profile pictures, map navigation. Proposals only.

## Rest of the screens
Other screens are listed in `../AnugaCare_Screen_Master_List.md`. Folders for them are created as mockups arrive.
