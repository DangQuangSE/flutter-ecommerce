# Phase 3: OrderBloc + DI Registration

## Goal
State management cho order list: load, filter, pagination, refresh.

**Delivers:** US-1, US-4 | P2: US-5, US-6

---

## Tasks

- [ ] **3.1** `OrderEvent` (sealed):
  - `OrderListRequested` — initial load / refresh (`reset: true`)
  - `OrderListLoadMoreRequested`
  - `OrderFilterChanged(String pill)`
  - `OrderDetailRequested(int orderId)`
- [ ] **3.2** `OrderState` (sealed):
  - `OrderInitial`
  - `OrderListLoading` / `OrderListLoaded` / `OrderListError`
  - `OrderDetailLoading` / `OrderDetailLoaded(OrderEntity)` / `OrderDetailError`
  - Loaded list state: `orders`, `allOrders`, `selectedFilter`, `page`, `isLast`, `isLoadingMore`
- [ ] **3.3** `OrderBloc`:
  - `defaultPageSize = 10`
  - On `OrderListRequested`: emit Loading → fetch page 0 → apply `CustomerOrderFilter` → emit Loaded
  - On `OrderFilterChanged`: re-filter `allOrders` cache, không gọi API
  - On `OrderListLoadMoreRequested`: nếu `!isLast && !isLoadingMore` → fetch `page+1`, append `allOrders`, re-filter
  - Pull-to-refresh = `OrderListRequested(reset: true)`
- [ ] **3.4** Register DI in `injection_container.dart`:
  - `OrderRemoteDataSource` → impl (lazySingleton)
  - `OrderRepository` → impl (lazySingleton)
  - `GetOrdersUseCase` + `GetOrderByIdUseCase` (factory)
  - `OrderBloc` (factory)

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/order/presentation/bloc/order_event.dart` | **New** |
| `lib/features/order/presentation/bloc/order_state.dart` | **New** |
| `lib/features/order/presentation/bloc/order_bloc.dart` | **New** |
| `lib/core/di/injection_container.dart` | **Register** order deps |

---

## Acceptance Criteria

- BLoC states cover Initial / Loading / Success / Error / Empty
- Filter change không trigger API call
- Load-more append đúng
- `dart analyze` pass
