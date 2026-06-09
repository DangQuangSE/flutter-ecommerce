# Phase 1: Backend — VNPay Config + Create Payment URL

**Goal:** Module VNPay sandbox có thể tạo signed payment URL cho order đã tồn tại.

**Covers:** US-1 (P1)

**Dependencies:** None

---

## Tasks

- [ ] Thêm `VNPAY` vào `PaymentMethod` enum
- [ ] Migration/alter: cột `vnp_txn_ref VARCHAR(64)` trên bảng `orders` (nullable)
- [ ] Tạo `VnpayProperties` (`@ConfigurationProperties(prefix = "vnpay")`)
  - `tmnCode`, `hashSecret`, `payUrl`, `returnUrl`, `ipnUrl`
- [ ] Tạo `VnpayService`
  - `buildPaymentUrl(Order order, String clientIp)` — build params, HMAC-SHA512 `vnp_SecureHash`
  - `generateTxnRef(Long orderId)` → `{orderId}_{System.currentTimeMillis()}`
  - Map amount: VNPay yêu cầu số tiền × 100 (VND, không decimal)
- [ ] Tạo `VnpayController`
  - `POST /api/v1/payments/vnpay/create` body `{ "orderId": Long }`
  - Validate: order thuộc user hiện tại, `paymentMethod == VNPAY`, `status == PENDING`
  - Lưu `vnpTxnRef` vào order, trả `{ paymentUrl, txnRef, orderId }`
- [ ] DTO: `VnpayCreateRequest`, `VnpayCreateResponse`
- [ ] Thêm config mẫu vào `application-dev.yml` + `.env.example`
- [ ] Unit test `VnpayService` — verify hash generation với vector test VNPay docs
- [ ] **Refactor `OrderService.placeOrder` cho VNPAY:**
  - Không trừ `stock_quantity` khi `paymentMethod == VNPAY`
  - Không xóa cart items khi `paymentMethod == VNPAY`
  - Tạo order + order items ở trạng thái "reserved" (PENDING, chưa trừ stock)
  - Stock deduct + cart clear → chuyển sang Phase 2 IPN handler khi `ResponseCode=00`

---

## Files

| Action | Path |
|--------|------|
| CREATE | `modules/payment/vnpay/config/VnpayProperties.java` |
| CREATE | `modules/payment/vnpay/config/VnpayConfig.java` |
| CREATE | `modules/payment/vnpay/service/VnpayService.java` |
| CREATE | `modules/payment/vnpay/service/VnpayHashUtil.java` |
| CREATE | `modules/payment/vnpay/controller/VnpayController.java` |
| CREATE | `modules/payment/vnpay/dto/VnpayCreateRequest.java` |
| CREATE | `modules/payment/vnpay/dto/VnpayCreateResponse.java` |
| MODIFY | `modules/order/enums/PaymentMethod.java` |
| MODIFY | `modules/order/domain/Order.java` |
| MODIFY | `src/main/resources/application-dev.yml` |

---

## VNPay Params (create URL)

```
vnp_Version=2.1.0
vnp_Command=pay
vnp_TmnCode={tmnCode}
vnp_Amount={amount * 100}
vnp_CurrCode=VND
vnp_TxnRef={txnRef}
vnp_OrderInfo=Thanh toan don hang #{orderId}
vnp_OrderType=other
vnp_Locale=vn
vnp_ReturnUrl=sportpro://payment-result
vnp_IpAddr={clientIp}
vnp_CreateDate=yyyyMMddHHmmss
vnp_SecureHash={HMAC-SHA512}
```

---

## Acceptance Criteria

1. Gọi `POST /api/v1/payments/vnpay/create` với order VNPAY hợp lệ → `200` + `paymentUrl` chứa `sandbox.vnpayment.vn`
2. URL có `vnp_SecureHash` hợp lệ (verify bằng unit test)
3. Order không thuộc user / không phải VNPAY → `400`/`403`
4. `vnp_ReturnUrl` trong URL = `sportpro://payment-result` (deep link, không phải http)
