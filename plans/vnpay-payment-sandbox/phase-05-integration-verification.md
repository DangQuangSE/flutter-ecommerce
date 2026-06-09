# Phase 5: Integration Verification — Sandbox E2E

**Goal:** Xác nhận luồng VNPay sandbox hoạt động end-to-end trên thiết bị thật/emulator.

**Covers:** Tất cả P1; US-6–8 (P2)

**Dependencies:** Phase 1–4

---

## Prerequisites

- [ ] Tài khoản VNPay sandbox (TMN_CODE, HASH_SECRET) từ [https://sandbox.vnpayment.vn/](https://sandbox.vnpayment.vn/)
- [ ] Backend chạy với profile `dev`
- [ ] IPN URL đã đăng ký trên VNPay portal ✅ (user confirmed)
- [ ] Cấu hình `vnpay.tmn-code`, `vnpay.hash-secret` trong `application-dev.yml` (không commit)
- [ ] Flutter `BASE_URL` = `http://10.0.2.2:8080` (Android emulator default — đã có trong `api_constants.dart`)
- [ ] ngrok chỉ cần nếu IPN URL trỏ localhost; nếu IPN đã trỏ server dev public thì bỏ qua

---

## Test Checklist

### Backend (curl / Postman)
- [ ] Login lấy JWT
- [ ] Thêm sản phẩm vào cart
- [ ] `POST /api/v1/orders` với `paymentMethod: "VNPAY"`
- [ ] `POST /api/v1/payments/vnpay/create` → copy `paymentUrl`, mở browser → thanh toán sandbox
- [ ] Kiểm tra log IPN nhận callback
- [ ] `GET /api/v1/payments/vnpay/verify/{orderId}` → `SUCCESS`

### Flutter E2E (manual)
- [ ] Login → cart có item → checkout → chọn VNPay
- [ ] WebView hiện trang VNPay sandbox
- [ ] Thanh toán bằng thẻ test VNPay (theo docs sandbox)
- [ ] App quay lại qua deep link `sportpro://payment-result`
- [ ] Màn success hiển thị
- [ ] Order list/detail hiển thị CONFIRMED + VNPAY

### Negative Cases
- [ ] User bấm Hủy trên WebView → quay checkout, order vẫn PENDING
- [ ] `vnp_ResponseCode != 00` → failure UI
- [ ] Deep link khi app cold start → vẫn navigate đúng
- [ ] IPN không đến (tắt ngrok) → verify trả PENDING, UI thông báo "Đang xác nhận..."

### Platform Matrix (priority: Android emulator)
| Platform | Deep link | WebView intercept | IPN |
|----------|-----------|---------------------|-----|
| **Android emulator** | ☐ | ☐ | ☐ |
| iOS simulator | defer | defer | defer |
| Physical device | optional | optional | optional |

---

## VNPay Sandbox Test Cards

> Tra cứu thẻ test mới nhất tại tài liệu VNPay sandbox. Thường dùng ngân hàng NCB với số thẻ test được cung cấp trên portal.

---

## Documentation
- [ ] Ghi `docs/payment/vnpay_sandbox_setup.md` trong `be-ecommerce` — env vars, ngrok, IPN registration
- [ ] Comment trong `api_constants.dart` về BASE_URL cho device thật

---

## Acceptance Criteria

1. Ít nhất 1 giao dịch sandbox thành công trên Android **hoặc** iOS
2. IPN log xác nhận order `CONFIRMED`
3. Deep link params khớp với verify API response
4. Negative cases không crash app
5. Setup doc đủ để dev khác reproduce
