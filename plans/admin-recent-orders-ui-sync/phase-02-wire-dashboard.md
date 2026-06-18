# Phase 2: Wire Dashboard to Shared Card

## Goal
Dashboard "Đơn hàng gần đây" dùng `AdminOrderCard` + `AdminOrderEntity` từ API.

**Delivers:** US-1–3

---

## Tasks

- [ ] **2.1** `AdminLoaded` state: thêm `List<AdminOrderEntity> recentOrders` (default `[]`)
- [ ] **2.2** `AdminBloc._onStatsRequested`: populate `recentOrders` từ `getAdminOrdersUseCase(page:0, size:5)` content; fallback `[]` nếu API lỗi (không dùng mock RecentOrderEntity cho UI)
- [ ] **2.3** `admin_dashboard_tab.dart`:
  - Xóa `_recentOrderCard` và `shortCurrencyFormat`
  - Dùng `NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')` giống list page
  - Map `state.recentOrders` → `AdminOrderCard` với `onTap` → `adminOrderDetail`
- [ ] **2.4** Empty state: nếu `recentOrders.isEmpty` → text "Chưa có đơn hàng" (optional, P2)

---

## Files to Touch

| File | Change |
|------|--------|
| `admin_state.dart` | Add `recentOrders` field |
| `admin_bloc.dart` | Pass `AdminOrderEntity` list |
| `admin_dashboard_tab.dart` | Use `AdminOrderCard` |

---

## Acceptance Criteria

- Dashboard cards hiển thị SĐT + giá `xxx.xxx đ` + badge giống list
- Tap navigate detail
- `dart analyze` pass
