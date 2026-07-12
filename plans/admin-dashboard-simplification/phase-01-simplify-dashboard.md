# Phase 01: Simplify dashboard

## Objective

Reduce the admin dashboard to the existing Revenue, Orders, and New Customers KPI cards, with one shared reporting-period action and no daily revenue list.

## Spec Coverage

- **P1 — Shared reporting period:** FR-03, FR-04, FR-05, FR-06.
- **P1 — Aggregate revenue and orders:** FR-01, FR-02, FR-06.
- **P2 — Retain customer/comparison context:** FR-01 and existing comparison text when supplied.
- **P3 — Exclusions:** no charts, exports, drill-down analytics, or configurable widgets.
- **Cross-cutting:** FR-07 loading, empty, error, and retry behavior.

## Files

- Modify `lib/features/admin/presentation/widgets/admin_dashboard_tab.dart`.
- Modify `lib/core/constants/app_strings.dart` only if labels for the compact filter action or bottom-sheet options are not already available.
- Modify focused dashboard widget tests if such tests already exist; otherwise add one focused test file under `test/features/admin/presentation/widgets/`.

## Implementation Steps

1. Preserve the current large Revenue card and the current side-by-side Orders and New Customers cards without redesigning their visual treatment.
2. Keep the active start/end date visible near the Revenue card.
3. Replace the visible preset-chip group with one compact filter action positioned with the statistics/range area.
4. Open a modal bottom sheet from that action with exactly four choices: this week, this month, this year, and custom range.
5. Map week, month, and year choices to explicit start/end dates and call the existing shared analytics load/refresh path once per selection.
6. For custom range, reuse the existing date-range picker and call load only after a valid, confirmed range; cancellation performs no refresh.
7. Remove the mapped `revenue.points` daily `ListTile` rows and remove the delivered/average detail line from the default dashboard summary.
8. Preserve current loading feedback, previous-data behavior, safe error message, and retry action.
9. Verify the three cards remain visible and the dashboard contains no daily detail rows after every supported filter selection.

## Design Constraints

**Preflight:** Follow the existing `AdminDashboardTab` composition, `AppStrings` label ownership, and `RevenueAnalyticsCubit.load(start, end)` refresh convention. Keep filtering in the presentation widget, preserve the current card builders, and do not change domain/data/backend layers.

- Keep the change within the existing admin presentation flow and existing `RevenueAnalyticsCubit`; do not introduce a new state-management layer.
- Use one period selection as the source for the dashboard refresh; do not issue separate refresh calls from one user selection.
- Preserve the existing card designs and responsive two-card KPI row.
- The bottom sheet contains only the four specified period options; do not retain 7-day/30-day chips in the default view.
- Do not render `RevenueAnalyticsEntity.points` on the dashboard.
- Do not expose internal exception details and do not remove retry behavior.
- Do not add backend APIs, charts, exports, advanced analytics, or unrelated refactors.

## Quality and Testing State

- **Quality gate:** APPROVED; receipt generation blocked because no working Python runtime is available.
- **Build gate:** Analyzer command attempted twice but hung without output; compile status is unverified.
- **Testing:** Not started.
- **Required checks:** format/analyze the changed Dart scope; run the focused dashboard widget tests; run existing revenue analytics cubit tests relevant to date selection and retry.
- **Manual checks:** verify bottom-sheet choices, custom-range cancellation, one loading transition per confirmed selection, retained previous data on failure, and compact layout on the target emulator width.

## Success Criteria

- Exactly three KPI cards remain: Revenue, Orders, and New Customers.
- The default dashboard shows exactly one compact time-filter action.
- The filter exposes exactly four choices: week, month, year, and custom range.
- A confirmed choice triggers at most one dashboard refresh and the active start/end dates update accordingly.
- No per-day revenue rows are rendered.
- Loading feedback appears promptly; empty/error states remain usable; error state retains a retry action.
- Existing comparison text remains visible whenever the loaded data supplies it.
