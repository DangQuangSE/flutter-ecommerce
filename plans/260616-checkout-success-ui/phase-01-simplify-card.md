# Phase 1: Simplify Checkout Success Card

**Goal:** Card chỉ còn mã đơn + trạng thái "Đang xử lý".

**Covers:** US-1, US-2, US-3

**Dependencies:** None

---

## Tasks

- [ ] Mở `lib/features/checkout/presentation/pages/checkout_success_page.dart`
- [ ] Trong `Column` của Transaction Detail Card, giữ:
  ```dart
  _buildInvoiceRow('Mã đơn hàng', orderReference, isBold: true),
  const SizedBox(height: 12),
  _buildInvoiceRow('Trạng thái đơn hàng', 'Đang xử lý'),
  ```
- [ ] Xóa rows: Thời gian giao dự kiến, Hình thức thanh toán
- [ ] Xóa `isSuccessColor` khỏi `_buildInvoiceRow` nếu không còn caller dùng

---

## Acceptance Criteria

1. Screenshot/logic: 2 rows only
2. Status text exactly `Đang xử lý`
3. `dart analyze` zero errors

---

## Files

| Action | Path |
|--------|------|
| MODIFY | `lib/features/checkout/presentation/pages/checkout_success_page.dart` |
