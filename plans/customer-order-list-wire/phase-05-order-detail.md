# Phase 5: Wire OrderDetailPage Presentation

## Goal
Thay `_mockOrder` bằng `OrderBloc` detail state, map `OrderResponse` fields có sẵn.

**Delivers:** US-7 (P2)

---

## Tasks

- [ ] **5.1** Router: wrap `OrderDetailPage` với `BlocProvider` dispatch `OrderDetailRequested(orderId)` on create.
- [ ] **5.2** Refactor `OrderDetailPage`:
  - Xóa `_mockOrder`
  - `BlocBuilder` → Loading / Error (retry) / Loaded
  - Map `OrderEntity` → UI sections
- [ ] **5.3** Status card: `OrderStatusLabel.vi(status)` + badge color; **ẩn** "Dự kiến giao" (backend không có field).
- [ ] **5.4** Thông tin đơn:
  - Mã đơn: `displayCode` (`#0001`)
  - Ngày đặt: `createdAt` formatted
  - Thanh toán: `OrderStatusLabel.paymentMethodVi(paymentMethod)`
  - **Ẩn** "Phương thức vận chuyển" (không có trong API)
- [ ] **5.5** Địa chỉ: `shippingAddress` + `phoneNumber` nếu có
- [ ] **5.6** Items list: loop `order.items` — `CachedNetworkImage`, name, size, qty, price
- [ ] **5.7** Summary:
  - Tạm tính = sum item `price * quantity`
  - Phí vận chuyển: "Miễn phí" (không có field) hoặc ẩn row
  - Tổng = `totalAmount`
- [ ] **5.8** Bottom bar: "THEO DÕI ĐƠN" khi `status == 'SHIPPED'` (raw enum, không VI string)

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/order/presentation/pages/order_detail_page.dart` | **Major refactor** |
| `lib/app/router/app_router.dart` | **BlocProvider** for detail route |

---

## Acceptance Criteria

- Không còn `_mockOrder`
- Detail hiển thị data thật từ API
- Loading / Error states handled
- `dart analyze` pass
