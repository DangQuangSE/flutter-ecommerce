# Phase 3: AdminOrderCubit + DI

## Goal
State management cho list/detail/status update; đăng ký DI.

**Delivers:** US-1–4 (state layer), US-8 (refresh events)

---

## Tasks

- [ ] **3.1** `AdminOrderState` (sealed / Equatable):
  - `AdminOrderInitial`
  - `AdminOrderListLoading` / `AdminOrderListLoaded` (orders, page, hasMore, search, statusFilter, message?)
  - `AdminOrderListError(message)`
  - `AdminOrderDetailLoading` / `AdminOrderDetailLoaded(order, isUpdatingStatus, message?)`
  - `AdminOrderDetailError(message)`
- [ ] **3.2** `AdminOrderCubit` methods:
  - `loadOrders({reset = true})` — page 0, replace list
  - `loadMoreOrders()` — append if `!isLast`
  - `applyFilters({String? search, String? status})` — reset + reload
  - `loadOrderDetail(int id)`
  - `updateStatus(int id, String newStatus)` — optimistic optional; refresh detail on success
  - `refresh()` — reload current view
- [ ] **3.3** Register in `injection_container.dart`:
  ```dart
  sl.registerLazySingleton<AdminOrderRemoteDataSource>(...);
  sl.registerLazySingleton<AdminOrderRepository>(...);
  sl.registerFactory<GetAdminOrdersUseCase>(...);
  sl.registerFactory<GetAdminOrderDetailUseCase>(...);
  sl.registerFactory<UpdateAdminOrderStatusUseCase>(...);
  sl.registerFactory<AdminOrderCubit>(() => AdminOrderCubit(...));
  ```

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/admin/presentation/cubit/admin_order_state.dart` | **New** |
| `lib/features/admin/presentation/cubit/admin_order_cubit.dart` | **New** |
| `lib/core/di/injection_container.dart` | Register admin order stack |

---

## Acceptance Criteria

- [ ] Cubit emits loading → loaded/error correctly on list fetch.
- [ ] `loadMoreOrders` không gọi khi `isLast == true`.
- [ ] Status update emits snackbar message via `message` field.
- [ ] `AdminOrderCubit` là `registerFactory` (mỗi route instance riêng).

---

## Dependencies
- Phase 2 complete.
