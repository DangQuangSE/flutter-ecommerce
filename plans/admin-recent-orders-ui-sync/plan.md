# Plan: Admin Dashboard Recent Orders — UI Sync with List Page
Status: 🟢 Implemented
Date: 2026-06-17
Mode: Fast
Test: default

## Overview
Đồng bộ giao diện **Đơn hàng gần đây** trên admin dashboard với card trong màn **Quản lý đơn hàng** (XEM TẤT CẢ). Hiện dashboard thiếu SĐT, format giá compact (`159N`), và badge status nhỏ hơn.

---

## Scope Challenge

```
# Scope Challenge:
#   Exists?     → AdminOrderListPage `_OrderCard` ✅ | Dashboard `_recentOrderCard` diverged ❌
#   Minimum?    → Extract shared card widget + dashboard dùng cùng layout/format
#   Complexity? → Fast — 1 widget extract, 2-3 file touch, no API change
#
# Mode: Fast
# Test: default
```

---

## Diff hiện tại (dashboard vs list)

| Thuộc tính | Dashboard `_recentOrderCard` | List `_OrderCard` |
|------------|------------------------------|-------------------|
| SĐT khách | ❌ thiếu | ✅ `order.phoneNumber` |
| Format giá | `NumberFormat.compact` → `159N` | `NumberFormat.currency` → `159.000 đ` |
| Badge status | fontSize 8, w700 | fontSize 10, w600 |
| Icon / layout | giống | giống (reference) |

Data: dashboard đã fetch API qua `AdminBloc` → `adminOrderToRecentOrder` nhưng `RecentOrderEntity` không có `phoneNumber`.

---

## User Stories

### P1 — Must Have
- **US-1**: Card đơn hàng gần đây trên dashboard giống hệt card trong `AdminOrderListPage`.
- **US-2**: Hiển thị mã đơn `#000x`, tên SP, SĐT, giá đầy đủ, badge status cùng style.

### P2 — Should Have
- **US-3**: Tap card dashboard → navigate `adminOrderDetail` (đã có — giữ nguyên).

### P3 — Nice to Have
- **US-4**: Deprecate `RecentOrderEntity` cho dashboard — dùng `AdminOrderEntity` trực tiếp — optional nếu refactor nhỏ hơn add field.

---

## Research Summary

**Primary (RECOMMEND):**
1. Extract `_OrderCard` → `AdminOrderCard` widget dùng chung (`lib/features/admin/presentation/widgets/admin_order_card.dart`).
2. Widget nhận `AdminOrderEntity` + `NumberFormat` + `onTap` — single source of truth.
3. `AdminLoaded` state thêm field `List<AdminOrderEntity> recentOrders` (từ API, size=5).
4. Dashboard render `AdminOrderCard` thay `_recentOrderCard`.
5. `AdminOrderListPage` import `AdminOrderCard` thay private `_OrderCard`.

**Alternative (CAUTION):**
- Chỉ patch `_recentOrderCard` copy-paste layout từ list → nhanh nhưng duplicate, drift lại sau này.

---

## Phases
- [ ] Phase 1: Extract `AdminOrderCard` shared widget
- [ ] Phase 2: Wire dashboard + bloc state to use `AdminOrderEntity` + shared card

---

## Story ↔ Phase Mapping

| Phase | P1 | P2 |
|-------|----|----|
| 1 | US-1, US-2 | — |
| 2 | US-1, US-2 | US-3 |

---

## Risks

| Risk | Mitigation |
|------|------------|
| `RecentOrderEntity` mock fallback khi API lỗi | Fallback: map mock recent orders sang minimal `AdminOrderEntity` hoặc giữ mock stats không có phone |
| Card dài hơn do thêm SĐT | Giống list page — đã verify OK |

---

## Red-Team Review (inline)

| Finding | Verdict |
|---------|---------|
| Duplicate `_OrderCard` nếu không extract | ACCEPTED → Phase 1 |
| Thêm field `recentAdminOrders` vào `AdminLoaded` vs extend `RecentOrderEntity` | ACCEPTED → dùng `AdminOrderEntity` trên state, tránh mapper thừa |
| Mock stats `recentOrders` unused sau refactor | NOTED → giữ trong `AdminStatsEntity` cho mock KPI, dashboard ưu tiên API list |

---

## Ready to Cook

```
/ck:cook --fast plans/admin-recent-orders-ui-sync/plan.md
```
