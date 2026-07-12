# Brainstorm: Simplify the admin dashboard

**Date:** 2026-07-12

## Ideas Explored

- Keep the current revenue card but remove the long per-day revenue list.
- Replace the row of time-range buttons with one compact filter action.
- Reuse the existing Order and New Customer KPI cards instead of redesigning them.
- Apply one selected date range to all dashboard KPI cards.

## User's Direction

Keep the current visual structure: one large Revenue card followed by the existing Order and New Customer cards. Add a simple time filter for week, month, year, or a custom range. The dashboard only needs aggregate values and should not show every daily value.

## Open Questions

- None blocking. Existing comparison-to-previous-period behavior is retained when data is available.

## Risks

- Removing the daily list must not remove data needed by other dashboard consumers.
- All KPI requests must use the same selected range to avoid inconsistent figures.
- Custom ranges need clear start/end validation.
