# Phase 3: Flutter — Checkout wire + Admin detail UI

**Goal:** Gửi tên người đặt khi checkout; admin detail hiển thị tên.

**Covers:** US-1, US-5

**Dependencies:** Phase 1

---

## Tasks

### 1. Checkout data layer

- [ ] `OrderRequestEntity`: thêm `customerName`
- [ ] `OrderRequestModel.toJson()`: thêm `'customerName'`
- [ ] `checkout_page.dart`: truyền `_nameController.text.trim()` vào entity

### 2. Admin entity/model

- [ ] `AdminOrderEntity`: thêm `customerName` (nullable `String?`)
- [ ] `AdminOrderModel.fromJson`: parse `customerName`
- [ ] Cập nhật `props` / constructor

### 3. Admin order detail UI

- [ ] `admin_order_detail_page.dart` — trong section THÔNG TIN ĐƠN HÀNG, thêm row:
  - Label: **Tên người đặt**
  - Value: `order.customerName?.isNotEmpty == true ? order.customerName! : '—'`
- [ ] Đặt sau "Mã đơn hàng", trước "Số điện thoại"

### 4. Optional P2

- [ ] `admin_order_list_page` card subtitle — chỉ nếu có chỗ hiển thị gọn (out of scope nếu chật)

---

## Acceptance Criteria

1. Confirm order gửi `customerName` trong JSON
2. Admin detail hiển thị tên từ API
3. `dart analyze` clean
4. Đơn cũ không có tên → hiển thị "—"

---

## Files

| Action | Path |
|--------|------|
| MODIFY | `lib/features/checkout/domain/entities/order_request_entity.dart` |
| MODIFY | `lib/features/checkout/data/models/order_request_model.dart` |
| MODIFY | `lib/features/checkout/presentation/pages/checkout_page.dart` |
| MODIFY | `lib/features/admin/domain/entities/admin_order_entity.dart` |
| MODIFY | `lib/features/admin/data/models/admin_order_model.dart` |
| MODIFY | `lib/features/admin/presentation/pages/admin_order_detail_page.dart` |
