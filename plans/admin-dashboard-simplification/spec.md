# Spec: Simplified admin dashboard statistics

**Date:** 2026-07-12
**Status:** Ready

---

## Problem Statement

The admin dashboard is cluttered by preset buttons and a full daily revenue list. Administrators need a compact summary of revenue, orders, and new customers for one selected reporting period.

---

## User Stories

- **[P1]** As an admin, I want to choose a reporting period so that all dashboard totals describe the same interval.
  Accepted when: the filter offers this week, this month, this year, and a valid custom date range.

- **[P1]** As an admin, I want to see aggregate revenue and total orders without a daily list so that I can scan performance quickly.
  Accepted when: the revenue card and order card update after every filter selection and no per-day rows appear.

- **[P2]** As an admin, I want to retain the new-customer card and previous-period comparison so that the simplified dashboard still provides useful context.
  Accepted when: the existing card remains and comparison text is shown whenever the API provides comparison data.

- **[P3]** Interactive charts, exports, drill-down analytics, and configurable dashboard widgets are out of scope.

---

## Functional Requirements

1. FR-01: Preserve the existing large Revenue card and the existing Order and New Customer KPI cards.
2. FR-02: Remove the daily revenue row list from the dashboard.
3. FR-03: Replace the visible preset button group with one compact filter action.
4. FR-04: The filter must support this week, this month, this year, and a custom date range.
5. FR-05: Display the active start and end dates near the revenue card.
6. FR-06: Apply the selected period to revenue and total orders as one dashboard refresh; retain the existing New Customers card and its current stats source.
7. FR-07: Preserve loading, empty, error, and retry states.

---

## Non-Functional Requirements

- Performance: a filter selection triggers at most one dashboard refresh operation and shows loading feedback within 100 ms.
- Security: retain the existing admin authorization and do not introduce new public endpoints.
- Availability: a failed refresh must keep a retry action available and must not display internal exception details.

---

## Success Criteria

- [ ] Daily detail rows: 0 rows rendered on the dashboard.
- [ ] Visible time-filter controls in the default state: 1 compact action.
- [ ] KPI consistency: revenue and orders use the same start and end dates in 100% of refreshes.
- [ ] Supported periods: 4 options (week, month, year, custom range).
- [ ] Existing KPI cards retained: 3 cards (Revenue, Orders, New Customers).

---

## Out of Scope

- Revenue charts and daily breakdowns.
- CSV/PDF export.
- Product rankings or advanced analytics.
- User-configurable dashboard layouts.

---

## Assumptions

- The existing analytics API can return aggregate values for an explicit date range.
- The existing Order and New Customer card designs remain unchanged.
