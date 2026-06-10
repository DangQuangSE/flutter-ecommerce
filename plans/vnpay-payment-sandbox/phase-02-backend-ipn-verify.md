# Phase 2: Backend — IPN Callback + Verify API + Order Status

**Goal:** VNPay IPN xác nhận thanh toán (nguồn sự thật); app gọi verify sau deep link.

**Covers:** US-4, US-5 (P1); US-6, US-8 (P2); US-10 (P3)

**Dependencies:** Phase 1

---

## Tasks

- [ ] `VnpayService.verifyIpn(Map<String,String> params)` — verify `vnp_SecureHash`, parse `vnp_ResponseCode`
- [ ] `GET /api/v1/payments/vnpay/ipn` (public, no JWT)
  - Log toàn bộ params (sandbox debug)
  - Tìm order theo `vnp_TxnRef` (match `orders.vnp_txn_ref`)
  - `vnp_ResponseCode == "00"` → `order.status = CONFIRMED` + **trừ stock** + **xóa cart items** (deferred từ place order)
  - Khác `00` → `order.status = CANCELLED`, cart/stock không đổi
  - Trả body VNPay yêu cầu: `{"RspCode":"00","Message":"Confirm Success"}` hoặc error code
  - **Idempotent:** IPN gọi lại không double-update
- [ ] `GET /api/v1/payments/vnpay/verify/{orderId}` (JWT)
  - Trả `{ orderId, status, paymentStatus, vnpResponseCode?, txnRef? }`
  - `paymentStatus`: `SUCCESS` | `PENDING` | `FAILED` derived từ order status + txn
- [ ] Thêm `/api/v1/payments/vnpay/ipn` vào `PUBLIC_URLS` trong `SecurityConfig`
- [ ] (Dự phòng) `GET /api/v1/payments/vnpay/bridge-return` — HTML 302 redirect sang deep link nếu sandbox không chấp nhận custom scheme trực tiếp
- [ ] Cập nhật `OrderResponse` — expose `vnpTxnRef` (optional, admin only hoặc owner)
- [ ] Integration test IPN với mock params + known hash
- [ ] Extract `fulfillOrder(Order order)` — trừ stock từng order item + xóa cart items tương ứng (logic tách từ `placeOrder` cũ)
- [ ] Gọi `fulfillOrder` trong IPN handler khi success; idempotent (skip nếu đã CONFIRMED)

---

## IPN Flow

```
VNPay → GET /api/v1/payments/vnpay/ipn?vnp_Amount=...&vnp_ResponseCode=00&...
      → verify hash
      → find order by vnp_TxnRef
      → if ResponseCode=00 AND amount matches → CONFIRMED
      → return {"RspCode":"00","Message":"Confirm Success"}
```

---

## Amount Verification

```
expectedAmount = order.totalAmount * 100 (long, no decimal)
actualAmount = Long.parseLong(params.get("vnp_Amount"))
if (!expectedAmount.equals(actualAmount)) → reject, log fraud attempt
```

---

## Files

| Action | Path |
|--------|------|
| MODIFY | `modules/payment/vnpay/service/VnpayService.java` |
| MODIFY | `modules/payment/vnpay/controller/VnpayController.java` |
| CREATE | `modules/payment/vnpay/dto/VnpayIpnResponse.java` |
| CREATE | `modules/payment/vnpay/dto/VnpayVerifyResponse.java` |
| MODIFY | `config/SecurityConfig.java` |
| MODIFY | `modules/order/dto/OrderResponse.java` |
| CREATE | `src/test/.../VnpayServiceTest.java` |

---

## Acceptance Criteria

1. Mock IPN với `vnp_ResponseCode=00` + hash đúng → order `CONFIRMED`
2. Mock IPN hash sai → `400`, order không đổi
3. Mock IPN amount sai → reject
4. `GET verify/{orderId}` sau IPN success → `paymentStatus: SUCCESS`
5. `GET verify/{orderId}` trước IPN (race) → `paymentStatus: PENDING`
6. IPN endpoint accessible không cần JWT
7. Gọi IPN 2 lần cùng txn → idempotent, không lỗi
