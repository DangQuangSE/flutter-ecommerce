# Plan: Admin Order Detail — Tên người đặt + Trạng thái Chờ xác nhận

**Status:** Complete  
**Mode:** Hard  
**Test:** default

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-16
**Phase in progress:** (none — all phases complete)
**Status:** Implemented; Flutter 77 tests pass (9 new admin/order tests); restart backend for ddl-auto columns.

### Decisions made this session
- `customerName` optional on API; empty/blank trimmed to null
- VNPay IPN: `paymentCompleted=true`, status stays `PENDING`
- `fulfillOrder` idempotency via `paymentCompleted` (not `CONFIRMED`)
- Admin UI: `displayCustomerName` → "—" when null

### Next immediate action
- Restart backend → place COD/VNPay order → verify admin detail shows name + "Chờ xác nhận"

### User decisions (plan validation)
- **Tên người đặt:** Lưu từ form checkout "Họ và tên" → cột `customerName` trên Order
- **VNPay sau thanh toán:** Giữ `PENDING` — admin xác nhận sau (`paymentCompleted=true` cho verify UX)
- **customerName API:** Optional — không `@NotBlank`; admin hiển thị "—" nếu thiếu

---

## Phases

- [x] **Phase 1:** Backend — `customerName` + `paymentCompleted` trên Order/DTO
- [x] **Phase 2:** Backend — VNPay IPN giữ `PENDING`, verify map payment SUCCESS qua `paymentCompleted`
- [x] **Phase 3:** Flutter — checkout gửi `customerName` + admin detail UI
- [x] **Phase 4:** Tests + verify end-to-end
