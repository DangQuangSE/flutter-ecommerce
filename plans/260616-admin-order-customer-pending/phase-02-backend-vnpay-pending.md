# Phase 2: Backend — VNPay giữ PENDING + verify SUCCESS

**Goal:** Thanh toán VNPay thành công không auto CONFIRMED; verify vẫn báo payment SUCCESS.

**Covers:** US-2, US-3, US-4

**Dependencies:** Phase 1

---

## Tasks

### 1. VnpayService.handleIpn (success path)

- [ ] Idempotency: `if (order.isPaymentCompleted()) return success`
- [ ] Sau verify amount: `orderService.fulfillOrder(orderId)`
- [ ] Set `paymentCompleted = true`
- [ ] **Không** set `status = CONFIRMED` — giữ `PENDING`
- [ ] Xóa/bỏ dòng `order.setStatus(OrderStatus.CONFIRMED)`

### 2. mapPaymentStatus

- [ ] Đổi signature nhận `Order` (hoặc thêm param `paymentCompleted`)
- [ ] Logic:
  - `paymentCompleted == true` (BANK_TRANSFER đã trả) → `SUCCESS`
  - `CANCELLED` → `FAILED`
  - else → `PENDING`
- [ ] Bỏ map `CONFIRMED` → SUCCESS (hoặc giữ cho đơn admin đã confirm — optional)

### 3. fulfillOrder idempotency (review)

- [ ] Hiện skip khi `status == CONFIRMED` — đổi sang skip khi `paymentCompleted` (COD) hoặc stock đã trừ
- [ ] Đảm bảo IPN retry không double-deduct stock

### 4. Docs

- [ ] Cập nhật `docs/payment/vnpay_sandbox_setup.md`: IPN → PENDING + paymentCompleted

---

## Acceptance Criteria

1. VNPay IPN success → order `status=PENDING`, `paymentCompleted=true`
2. `GET /payments/vnpay/verify/{id}` → `paymentStatus=SUCCESS` sau IPN
3. COD order → `PENDING`, `paymentCompleted=false`
4. Admin thấy badge "Chờ xác nhận" cho cả COD và VNPay đã trả

---

## Files

| Action | Path |
|--------|------|
| MODIFY | `be-ecommerce/.../payment/vnpay/service/VnpayService.java` |
| MODIFY | `be-ecommerce/.../order/service/OrderService.java` (fulfill idempotency nếu cần) |
| MODIFY | `be-ecommerce/docs/payment/vnpay_sandbox_setup.md` |
