# Phase 1: Payment Method Selector UI

**Goal:** Thay `PaymentQrCard` bằng widget cho phép chọn Ship COD hoặc VNPay, khớp design checkout hiện tại.

**Covers:** US-1 (P1)

**Dependencies:** None

---

## Tasks

### 1. Constants / enum (presentation layer)

- [ ] Tạo `CheckoutPaymentOption` (sealed hoặc enum) trong widget file hoặc `lib/core/constants/payment_method_constants.dart`:
  - `cod` — label UI: **"Thanh toán khi nhận hàng (COD)"**, API: `'COD'`
  - `vnpay` — label UI: **"VNPay"**, API: `'BANK_TRANSFER'`
- [ ] Helper `String apiValue(CheckoutPaymentOption option)` để map sang `OrderRequestEntity.paymentMethod`

### 2. `PaymentMethodSelector` widget

- [ ] Tạo `lib/features/checkout/presentation/widgets/payment_method_selector.dart`
- [ ] Props: `CheckoutPaymentOption selected`, `ValueChanged<CheckoutPaymentOption> onChanged`
- [ ] UI: white card container (border/shadow giống `_buildShippingForm`)
- [ ] 2 hàng selectable:
  - **COD** — icon `Icons.local_shipping_outlined`, subtitle ngắn: "Trả tiền mặt khi nhận hàng"
  - **VNPay** — icon/logo placeholder (hoặc `Icons.account_balance_wallet_outlined`), subtitle: "Thanh toán online qua VNPay"
- [ ] Selected state: border `AppColors.primary` (width 1.5), radio indicator bên phải
- [ ] Unselected: border `Color(0xFFC1C6D7)` alpha 0.3
- [ ] `InkWell` / `GestureDetector` trên cả row — tap chọn

### 3. Wire vào `checkout_page.dart`

- [ ] Thêm state: `CheckoutPaymentOption _selectedPayment = CheckoutPaymentOption.cod` (default — confirm với user)
- [ ] Đổi section icon từ `Icons.qr_code_scanner_rounded` → `Icons.payments_outlined`
- [ ] Thay `PaymentQrCard(...)` → `PaymentMethodSelector(selected: ..., onChanged: ...)`
- [ ] Xóa import `payment_qr_card.dart`

### 4. Submit wiring (chỉ truyền value — bloc branch ở Phase 2)

- [ ] Trong `_buildStickyFooter` `CheckoutSubmitted`, truyền:
  ```dart
  OrderRequestEntity(
    shippingAddress: ...,
    phoneNumber: ...,
    paymentMethod: _selectedPayment.apiValue,
    cartItemIds: cartItemIds,
  )
  ```

---

## Acceptance Criteria

1. Màn checkout không còn QR Vietcombank
2. User tap COD hoặc VNPay → visual selected state đổi ngay
3. `flutter analyze` zero errors trên files đã sửa
4. Confirm order gửi đúng `paymentMethod` string trong request (log/debug hoặc unit test Phase 2)

---

## Files

| Action | Path |
|--------|------|
| CREATE | `lib/features/checkout/presentation/widgets/payment_method_selector.dart` |
| CREATE | `lib/core/constants/payment_method_constants.dart` (optional) |
| MODIFY | `lib/features/checkout/presentation/pages/checkout_page.dart` |
