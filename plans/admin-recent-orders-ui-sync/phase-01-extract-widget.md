# Phase 1: Extract AdminOrderCard Shared Widget

## Goal
Tách `_OrderCard` từ `admin_order_list_page.dart` thành widget tái sử dụng.

**Delivers:** US-1, US-2 (widget foundation)

---

## Tasks

- [ ] **1.1** Tạo `lib/features/admin/presentation/widgets/admin_order_card.dart`:
  - Params: `AdminOrderEntity order`, `NumberFormat currencyFormat`, `VoidCallback onTap`
  - Layout giữ nguyên từ `_OrderCard`: icon box, displayCode, productName, phoneNumber, price, status badge
- [ ] **1.2** `AdminOrderListPage`: xóa class `_OrderCard`, import + dùng `AdminOrderCard`
- [ ] **1.3** Verify list page không đổi behavior

---

## Acceptance Criteria

- `AdminOrderCard` là single definition cho order card admin
- `dart analyze` pass
