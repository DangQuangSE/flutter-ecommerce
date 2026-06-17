# Plan: Checkout Payment Method Selector (COD / VNPay)

**Status:** Complete  
**Mode:** Hard  
**Test:** default

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-16
**Phase in progress:** (none — all phases complete)
**Status:** All 3 phases implemented; 73 tests pass; dart analyze clean.

### Decisions made this session
- Default payment: COD pre-selected (`CheckoutPaymentOption.cod`)
- VNPay icon: Material `Icons.account_balance_wallet_outlined`
- Success page: generic text "Thanh toán đã ghi nhận" (no route extra)
- `BANK_TRANSFER` label updated to "VNPay" in `OrderStatusLabel`
- `PaymentQrCard` deleted (no remaining references)

### Next immediate action
- Manual E2E: COD order on emulator + VNPay sandbox flow

### User decisions (plan validation)
- **Default method:** COD pre-selected
- **Success page:** generic text — không truyền payment method qua route
- **VNPay icon:** Material icon (`Icons.account_balance_wallet_outlined` hoặc tương đương)
- **Backend:** Flutter only — giữ `COD` + `BANK_TRANSFER`, không thêm enum `VNPAY`

---

## Scope Challenge

```
# Scope Challenge:
#   Exists?     → UI mock QR có (PaymentQrCard) ✅; VNPay flow + COD backend đã có ✅; selector chưa có ❌
#   Minimum?    → Widget chọn 2 phương thức + truyền paymentMethod + CheckoutBloc branch COD vs VNPay
#   Complexity? → Hard — multi-file Flutter, tích hợp CheckoutBloc, không đổi backend
#
# Mode: Hard
# Test: default
```

> Không có brainstorm report riêng. User mô tả rõ từ screenshot → tiếp tục plan.

---

## Research Summary

### Primary (recommended)

| Khía cạnh | Quyết định |
|-----------|------------|
| Widget | `PaymentMethodSelector` — 2 selectable cards trong white container, style khớp `_buildShippingForm` |
| State | Local `StatefulWidget` state trên `CheckoutPage` (`_selectedMethod`) — đủ vì chỉ ảnh hưởng submit |
| API mapping | UI **VNPay** → `paymentMethod: 'BANK_TRANSFER'`; UI **Ship COD** → `'COD'` |
| Bloc | `CheckoutBloc._onSubmitted` branch: COD → `CheckoutSuccess`; BANK_TRANSFER → flow VNPay hiện tại |
| Backend | **Không đổi** — `OrderService` đã xử lý COD (fulfill ngay) vs BANK_TRANSFER (defer đến IPN) |

### Alternative (rejected)

| Approach | Lý do reject |
|----------|--------------|
| `PaymentMethodCubit` riêng | Over-engineering cho 2 lựa chọn chỉ dùng ở 1 màn |
| Lưu selection trong `CheckoutBloc` state | Cần thêm event `PaymentMethodChanged` — không cần thiết khi chỉ submit 1 lần |
| Thêm enum `VNPAY` backend | Out of scope; docs đã map VNPay = `BANK_TRANSFER` |

---

## User Stories

| ID | Priority | Story |
|----|----------|-------|
| US-1 | P1 | User thấy 2 lựa chọn thanh toán (COD, VNPay) thay vì QR Vietcombank |
| US-2 | P1 | User chọn COD → đặt hàng → success page (không mở WebView) |
| US-3 | P1 | User chọn VNPay → đặt hàng → WebView sandbox → verify → success |
| US-4 | P2 | Success page / labels hiển thị đúng tên phương thức (không còn "Vietcombank Pay") |
| US-5 | P3 | Xóa `PaymentQrCard` nếu không còn reference |

---

## Phases

- [x] **Phase 1:** Payment method selector widget + checkout page UI
- [x] **Phase 2:** CheckoutBloc branch COD vs VNPay + submit wiring
- [x] **Phase 3:** Labels polish + cleanup PaymentQrCard

---

## Architecture

```mermaid
flowchart TD
    A[CheckoutPage] --> B{User chọn}
    B -->|COD| C[OrderRequest paymentMethod=COD]
    B -->|VNPay| D[OrderRequest paymentMethod=BANK_TRANSFER]
    C --> E[CheckoutBloc placeOrder]
    D --> E
    E --> F{paymentMethod}
    F -->|COD| G[emit CheckoutSuccess]
    F -->|BANK_TRANSFER| H[createVnpayPayment → WebView → verify]
    G --> I[refresh cart → success page]
    H --> I
```

---

## Dependencies

- `CheckoutBloc` + VNPay flow — đã implement (`plans/vnpay-payment-sandbox/`)
- Backend `PaymentMethod.COD` / `BANK_TRANSFER` — đã có
- `OrderRequestEntity.paymentMethod` — field đã có, default cần đổi

---

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| User không chọn phương thức | LOW | Pre-select COD (hoặc bắt buộc chọn — xem Q2) |
| Nhầm label VNPay vs BANK_TRANSFER | MEDIUM | Constant map trong `core/constants/` hoặc domain enum |
| Success page hardcode Vietcombank | LOW | Phase 3 — truyền method qua route extra hoặc generic text |
| CheckoutBloc vẫn luôn gọi VNPay | HIGH | Phase 2 — branch bắt buộc trước khi merge |

---

## Red-Team Review (inline)

| Finding | Verdict |
|---------|---------|
| Chỉ đổi UI mà không branch Bloc → COD vẫn mở WebView | **ACCEPTED** — Phase 2 bắt buộc |
| Default `BANK_TRANSFER` trên entity gây nhầm | **ACCEPTED** — đổi default hoặc bỏ default, luôn truyền từ UI |
| `order_status_label` ghi "Chuyển khoản" thay vì VNPay | **NOTED** — Phase 3 cập nhật label user-facing |
| Backend không cần sửa | **ACCEPTED** |

---

## Files Overview

| Action | Path |
|--------|------|
| CREATE | `lib/features/checkout/presentation/widgets/payment_method_selector.dart` |
| CREATE | `lib/core/constants/payment_method_constants.dart` (optional) |
| MODIFY | `lib/features/checkout/presentation/pages/checkout_page.dart` |
| MODIFY | `lib/features/checkout/presentation/bloc/checkout_bloc.dart` |
| MODIFY | `lib/features/checkout/domain/entities/order_request_entity.dart` |
| MODIFY | `lib/features/checkout/presentation/pages/checkout_success_page.dart` |
| MODIFY | `lib/core/utils/order_status_label.dart` |
| DELETE | `lib/features/cart/presentation/widgets/payment_qr_card.dart` (Phase 3, nếu không dùng) |

**Backend:** không thay đổi.

---

## Out of Scope

- Thêm `VNPAY` enum riêng trên backend
- CREDIT_CARD / Vietcombank QR thật
- Payment method trên cart page
- Unit test CheckoutBloc (có thể thêm nếu `--tdd`)
