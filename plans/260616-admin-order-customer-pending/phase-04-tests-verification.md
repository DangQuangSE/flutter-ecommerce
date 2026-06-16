# Phase 4: Tests + Verification

**Goal:** Regression tests cho status flow và field mapping.

**Covers:** US-2, US-3, US-4 verification

**Dependencies:** Phase 2, 3

---

## Tasks

### Backend tests (nếu có test infra)

- [ ] Unit test `VnpayService` / `mapPaymentStatus`: `paymentCompleted=true` + `PENDING` → SUCCESS
- [ ] Hoặc manual checklist nếu project chưa có VNPay tests

### Flutter tests

- [ ] `AdminOrderModel.fromJson` parses `customerName`
- [ ] `OrderRequestModel.toJson` includes `customerName`
- [ ] Cập nhật `checkout_bloc_test` nếu `OrderRequestEntity` constructor đổi

### Manual E2E

- [ ] COD order → admin detail: tên + "Chờ xác nhận"
- [ ] VNPay sandbox → admin detail: tên + "Chờ xác nhận" (không "Đã xác nhận")
- [ ] Admin PATCH → CONFIRMED → badge đổi
- [ ] `flutter test` + `dart analyze` pass

---

## Acceptance Criteria

1. Full test suite pass
2. Manual checklist 3 scenarios documented in plan session notes

---

## Files

| Action | Path |
|--------|------|
| CREATE/MODIFY | `test/features/checkout/checkout_bloc_test.dart` |
| CREATE | `test/features/admin/admin_order_model_test.dart` (optional) |
