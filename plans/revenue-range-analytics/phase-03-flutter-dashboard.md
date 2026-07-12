# Phase 3: Flutter dashboard

## Goal

Let admins choose presets or a custom inclusive range and reliably view the backend’s realized-revenue summary and series.

## Design Constraints

- Follow existing data/domain/presentation boundaries; do not overload `AdminBloc` or `AdminOrderCubit` with revenue state.
- Create a dedicated `RevenueAnalyticsCubit` with immutable states and a monotonically increasing request token. Only the latest token may emit success/error; older responses are ignored.
- Flutter sends ISO calendar dates only and displays the exact range echoed by backend.
- Presets are deterministic in the app’s configured/business local calendar: last 7 days including today, last 30 including today, current month, current year.
- `growthPercent=null` renders a neutral “không có dữ liệu kỳ trước,” never `∞%` or `100%`.
- Keep previous successful data visible during refresh where practical, with an explicit refreshing indicator; first-load, empty, error, stale refresh and success states are distinct.
- Dashboard reloads once when opened/revisited and after an order status update that may affect eligibility. Avoid duplicate network calls from rebuilds/tab animation.
- Chart labels and buckets come from API grouping; Flutter must not recompute revenue aggregation.

## Exact Files and Steps

Flutter root: `D:/GitHub/flutter-ecommerce`.

1. Add typed domain objects under `lib/features/admin/domain/entities/`:
   - revenue range,
   - summary,
   - bucket point/grouping.
2. Add JSON models under `lib/features/admin/data/models/` with defensive numeric/date parsing and explicit nullable growth handling.
3. Extend:
   - `lib/features/admin/data/datasources/admin_remote_datasource.dart`
   - `lib/features/admin/data/datasources/admin_remote_datasource_impl.dart`
   - `lib/features/admin/domain/repositories/admin_repository.dart`
   - `lib/features/admin/data/repositories/admin_repository_impl.dart`
   with ranged revenue loading. Add endpoint constants if this project centralizes API paths.
4. Add `lib/features/admin/domain/usecases/get_revenue_analytics_usecase.dart` accepting validated start/end dates.
5. Add `revenue_analytics_cubit.dart` and `revenue_analytics_state.dart` under `lib/features/admin/presentation/cubit/`:
   - default 7-day range,
   - preset selection,
   - custom selection,
   - refresh,
   - latest-request token guard,
   - range validation before network request.
6. Register datasource/repository/use case/Cubit additions in `lib/features/admin/admin_module.dart` and/or `lib/injection_container.dart` following existing lifetime conventions.
7. Refactor `lib/features/admin/presentation/widgets/admin_dashboard_tab.dart` (and `admin_dashboard_page.dart` if lifecycle ownership lives there):
   - visible selected range and preset chips/menu,
   - `showDateRangePicker` with <=5-year constraints,
   - realized revenue, completed count, average value, comparison copy,
   - accessible chart/series or compact bucket list consistent with existing UI,
   - loading/refresh/error/empty states and retry.
8. Update navigation/tab lifecycle in the owning admin shell so revisiting dashboard triggers exactly one refresh.
9. Connect successful admin order status update in `admin_order_cubit.dart`/owning page through a small invalidation/refresh signal. Prefer returning an update result and refreshing on dashboard resume rather than coupling Cubits directly.
10. Add localized strings in `lib/core/constants/app_strings.dart`; keep labels explicit that this is realized revenue for the selected range.

## Tests Planned for Later `ck:test`

- Model parsing for decimal values, nullable growth, grouping and malformed payload behavior.
- Repository/use-case propagates exact `YYYY-MM-DD` parameters.
- Preset boundary tests with injected/fixed current date.
- Cubit: newest of overlapping requests wins; old success/error cannot overwrite current state.
- Cubit: invalid range is rejected locally; retry and refresh preserve/replace state correctly.
- Widget: presets/custom picker display echoed range and metrics; zero previous revenue renders neutral copy.
- Widget: loading, empty, error and chart groupings render without overflow at supported screen sizes.
- Navigation: dashboard revisit causes one request; rebuild does not cause duplicates.
- Admin delivery success followed by return to dashboard triggers one fresh request.

## Build and Quality Gate

- Run `dart format --output=none --set-exit-if-changed` on touched Dart files.
- Run `flutter analyze` and a debug Android build/compile gate; read complete output.
- Later `ck:test`: targeted Cubit/model/widget/navigation tests, then relevant Flutter suite.
- Code review must inspect stale-request handling, lifecycle duplication, date boundaries, accessibility and responsive overflow.
- Run `git diff --check`.

## Success Criteria

- Every preset and valid custom selection calls the endpoint with correct inclusive ISO dates.
- Late responses never replace results for a newer selection.
- Dashboard clearly shows selected range, realized revenue, count, average, comparison and series.
- Nullable growth, empty results and errors render safely.
- Revisiting after an eligible order transition produces one fresh load.

## Spec Coverage

- P1 custom range and dashboard accuracy.
- P2 presets.
- FR-12, FR-13, FR-14.

## Quality and Testing State

- Quality: `ck:quality --gate` approved 2026-07-12 (report: `quality/phase-03-flutter-dashboard-quality-report.json`, receipt: `quality/phase-03-flutter-dashboard-receipt.json`). All 5 findings (1 HIGH invalidation-revision gap, 2 MEDIUM hardcoded strings, 2 LOW import/curly-brace) resolved and verified.
- Testing: not started; cases above are reserved for later `ck:test`.
- Analyze/build gate: `dart format` clean, `flutter analyze` 0 errors/warnings on phase-touched files, `flutter build apk --debug` succeeded, `git diff --check` clean.

## Binding Provider, Source and Refresh Integration

1. Extend the existing `AdminRemoteDataSource`/implementation and `AdminRepository`/implementation; do not create a parallel datasource. Keep the old dashboard-summary method/model for legacy cards.
2. Register `GetRevenueAnalyticsUseCase` and a factory `RevenueAnalyticsCubit` in `lib/features/admin/admin_module.dart`.
3. `AdminDashboardPage` adds the Cubit to its existing `MultiBlocProvider` and performs the sole initial load. `AdminDashboardTab` consumes it with `BlocBuilder/BlocConsumer` and never fetches from `build`.
4. Centralize bottom-navigation changes in `AdminDashboardPage`: only a transition from a non-dashboard tab to index 0 may refresh, exactly once.
5. A successful `AdminOrderCubit.updateStatus` that can change eligibility increments/exposes an `analyticsInvalidationRevision`. The dashboard page remembers the last consumed revision and refreshes once on dashboard re-entry. Cubits do not call each other, and ordinary rebuild/tab animation does not fetch.
6. Existing `AdminBloc` remains the provider/source for legacy order/customer dashboard metrics; ranged revenue comes only from `RevenueAnalyticsCubit`.
