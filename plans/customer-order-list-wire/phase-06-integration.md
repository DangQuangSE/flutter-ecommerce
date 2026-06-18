# Phase 6: Integration Verification

## Goal
E2E verify customer order list với backend + DB thật.

**Delivers:** all P1 + P2 verification

---

## Prerequisites

- Backend running (`http://10.0.2.2:8080` emulator / `localhost:8080`)
- User account với ít nhất 1 đơn hàng (đặt qua checkout flow hoặc seed DB)
- JWT token valid (đăng nhập trước khi vào tab Orders)

---

## Manual Test Checklist

- [ ] **6.1** Đăng nhập user → tab Orders → thấy danh sách đơn thật (không phải ORD-001 mock)
- [ ] **6.2** Mỗi item hiển thị đúng: mã `#0001`, status VI, tên SP, size, qty, giá, ngày, ảnh
- [ ] **6.3** Filter "Tất cả" → tất cả đơn đã load
- [ ] **6.4** Filter "Xác nhận" → chỉ CONFIRMED
- [ ] **6.5** Filter "Đang xử lý" → chỉ PROCESSING
- [ ] **6.6** Filter "Đang giao" → chỉ SHIPPED
- [ ] **6.7** Filter "Đã giao" → chỉ DELIVERED
- [ ] **6.8** Filter "Đã hủy" → chỉ CANCELLED
- [ ] **6.9** User chưa có đơn → empty state
- [ ] **6.10** Pull-to-refresh reload list
- [ ] **6.11** Scroll bottom → load-more (nếu >10 đơn)
- [ ] **6.12** Tap item → detail hiển thị data thật (items, địa chỉ, tổng tiền)
- [ ] **6.13** Token expired / chưa login → error state có message
- [ ] **6.14** `dart analyze` — zero errors
- [ ] **6.15** No `RenderFlex overflowed` trên order screens

---

## Automated Tests (optional P2)

- [ ] **5.14** `OrderBloc` bloc_test: load success, filter change, load-more, error
- [ ] **5.15** `CustomerOrderFilter` unit test: mapping pills → statuses

---

## Acceptance Criteria

- All P1 checklist items pass
- Document any backend data issues found
