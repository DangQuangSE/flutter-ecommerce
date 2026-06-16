# Phase 3: Labels Polish + PaymentQrCard Cleanup

**Goal:** Loại bỏ text "Vietcombank Pay" còn sót; dọn dead code.

**Covers:** US-4, US-5 (P2/P3)

**Dependencies:** Phase 2

---

## Tasks

### 1. `order_status_label.dart`

- [ ] Cập nhật `paymentMethodVi`:
  - `'BANK_TRANSFER'` → `'VNPay'` (thay vì "Chuyển khoản ngân hàng")
  - Giữ `'COD'` → `'Thanh toán khi nhận hàng'`

### 2. `checkout_success_page.dart`

- [ ] Thay hardcode `'Vietcombank Pay'` (line ~115) bằng text generic, ví dụ: `'Đã xác nhận'` hoặc `'Thanh toán đã ghi nhận'`
- [ ] **Không** truyền payment method qua route extra (user decision)

### 3. Remove `PaymentQrCard`

- [ ] Xác nhận không còn import (`grep PaymentQrCard`)
- [ ] Xóa `lib/features/cart/presentation/widgets/payment_qr_card.dart`

### 4. Optional consistency

- [ ] `order_detail_page.dart` mock data `'QR Code / Ví điện tử'` — chỉ sửa nếu page đã wire API thật (out of scope nếu vẫn mock)

---

## Acceptance Criteria

1. Không còn chữ "Vietcombank" / "VIETCOMBANK PAY" trong checkout flow
2. `PaymentQrCard` đã xóa, `flutter analyze` clean
3. Admin order detail vẫn hiển thị label đúng qua `OrderStatusLabel.paymentMethodVi`

---

## Files

| Action | Path |
|--------|------|
| MODIFY | `lib/core/utils/order_status_label.dart` |
| MODIFY | `lib/features/checkout/presentation/pages/checkout_success_page.dart` |
| MODIFY | `lib/app/router/app_router.dart` (nếu truyền extra) |
| MODIFY | `lib/features/checkout/presentation/pages/checkout_page.dart` (pass extra on success nav) |
| DELETE | `lib/features/cart/presentation/widgets/payment_qr_card.dart` |
