# Phase 4: Presentation — Admin Order UI

## Goal
Màn hình admin list + detail wired to Cubit; liên kết dashboard.

**Delivers:** US-1–4 (UI), US-5–7 (P2), US-8

---

## Tasks

- [ ] **4.1** Routes in `app_routes.dart` + `app_router.dart`:
  - `/admin/orders` → `AdminOrderListPage`
  - `/admin/orders/:orderId` → `AdminOrderDetailPage`
  - Wrap with `BlocProvider(create: (_) => sl<AdminOrderCubit>()..loadOrders())`
- [ ] **4.2** `AdminOrderListPage`:
  - AppBar "Quản lý đơn hàng"
  - Search field → debounce 400ms → `applyFilters(search: ...)`
  - Horizontal status chips (Tất cả + từng OrderStatus) → `applyFilters(status: ...)`
  - ListView cards — reuse style `_buildRecentOrderCard` from dashboard:
    - Mã đơn, tên SP đầu, tổng tiền, badge status VI
  - Tap card → `context.pushNamed(AppRoutes.adminOrderDetail, pathParameters: {'orderId': '$id'})`
  - `ScrollController` listener → `loadMoreOrders()` near bottom
  - Loading / empty / error states
- [ ] **4.3** `AdminOrderDetailPage`:
  - Layout inspired by `order_detail_page.dart` (sections: status, info, address, items, summary)
  - Data from `AdminOrderCubit.loadOrderDetail(orderId)`
  - **Status update UI:** dropdown or bottom sheet chọn trạng thái mới → confirm → `updateStatus`
  - Allowed statuses: all enum values (backend validates transitions)
- [ ] **4.4** Dashboard integration (`admin_dashboard_page.dart`):
  - "XEM TẤT CẢ" → `context.pushNamed(AppRoutes.adminOrders)`
  - Tap recent order card → navigate to detail (P2)
- [ ] **4.5** (P2) Recent orders on dashboard:
  - Option A: inject `GetAdminOrdersUseCase` into `AdminBloc`, fetch `size: 5, sort: createdAt,desc` on load
  - Option B: separate mini-fetch in dashboard init — prefer Option A if AdminBloc load already exists
  - Map `AdminOrderEntity` → `RecentOrderEntity` adapter or replace `RecentOrderEntity` usage

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/app/router/app_routes.dart` | Add `adminOrders`, `adminOrderDetail` |
| `lib/app/router/app_router.dart` | Register routes + BlocProvider |
| `lib/features/admin/presentation/pages/admin_order_list_page.dart` | **New** |
| `lib/features/admin/presentation/pages/admin_order_detail_page.dart` | **New** |
| `lib/features/admin/presentation/pages/admin_dashboard_page.dart` | Wire navigation + optional recent orders |
| `lib/features/admin/presentation/bloc/admin_bloc.dart` | (P2) fetch recent orders |

---

## UI Reference

Copy visual language from:
- `admin_dashboard_page.dart` → `_buildRecentOrderCard`, KPI spacing, Inter/Lexend fonts
- `order_detail_page.dart` → section headers, item cards, summary block
- `brand_management_page.dart` → search + list CRUD patterns

---

## Acceptance Criteria

- [ ] Admin login → navigate to orders list → sees real data from backend.
- [ ] Filter by status changes list without app restart.
- [ ] Detail shows all order items with image, size, color, qty, price.
- [ ] Status update reflects on detail + pops message snackbar.
- [ ] Non-admin cannot access `/admin/orders` (existing router guard).

---

## Dependencies
- Phase 3 complete.
