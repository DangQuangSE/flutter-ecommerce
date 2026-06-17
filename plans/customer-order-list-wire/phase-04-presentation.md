# Phase 4: Wire OrderListPage Presentation

## Goal
Thay mock data bằng `BlocProvider` + `OrderBloc`, giữ UI design hiện tại.

**Delivers:** US-1–4 | P2: US-5–7

---

## Tasks

- [ ] **4.1** Router: wrap `OrderListPage` với `BlocProvider(create: (_) => sl<OrderBloc>()..add(OrderListRequested()))` trong `app_router.dart` (pattern các page khác).
- [ ] **4.2** Refactor `OrderListPage`:
  - Xóa `_mockOrders` và `Map<String, dynamic>` item builder
  - `BlocBuilder<OrderBloc, OrderState>` cho body content
  - Loading → `CircularProgressIndicator` centered
  - Error → message + retry button (`OrderListRequested`)
  - Empty (filtered or no orders) → giữ `_buildEmptyState()`
  - Success → `ListView.separated` với `OrderEntity` typed items
- [ ] **4.3** Filter pills: `onTap` dispatch `OrderFilterChanged(filter)` thay `setState`
- [ ] **4.4** List item `_buildOrderListItem(OrderEntity order)`:
  - `displayCode`, `statusLabel`, `statusColor`
  - `primaryItem.productName`, `size`, `quantity`
  - `totalAmount` formatted
  - `createdAt` formatted `dd/MM/yyyy`
  - `CachedNetworkImage` cho `primaryItem.imageUrl` (fallback icon)
  - `onTap` → `context.goNamed(AppRoutes.orderDetail, pathParameters: {'orderId': order.id.toString()})`
- [ ] **4.5** Pagination: `NotificationListener<ScrollNotification>` hoặc scroll controller detect bottom → `OrderListLoadMoreRequested`
- [ ] **4.6** Pull-to-refresh: `RefreshIndicator` wrap scroll view → `OrderListRequested`
- [ ] **4.7** Load-more indicator ở cuối list khi `isLoadingMore`

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/order/presentation/pages/order_list_page.dart` | **Major refactor** |
| `lib/app/router/app_router.dart` | **BlocProvider** wrap |

---

## Out of Scope

- Backend changes

---

## Acceptance Criteria

- Không còn `_mockOrders` trong order_list_page
- UI giữ filter pills + card style + empty state
- `cached_network_image` cho network images
- `ListView.separated` / builder cho dynamic list
- `dart analyze` pass
