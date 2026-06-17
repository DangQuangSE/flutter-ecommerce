# Phase 1: Backend — customerName + paymentCompleted

**Goal:** Order lưu tên người đặt; cờ thanh toán VNPay tách khỏi trạng thái xác nhận admin.

**Covers:** US-1, US-5 (data layer)

**Dependencies:** None

---

## Tasks

### 1. Order entity

- [ ] Thêm `customerName` (`customer_name`, `VARCHAR`, nullable cho đơn cũ)
- [ ] Thêm `paymentCompleted` (`payment_completed`, `BOOLEAN`, default `false`)

### 2. DTOs

- [ ] `OrderRequest`: thêm `customerName` (optional, không `@NotBlank`)
- [ ] `OrderResponse`: thêm `customerName`, `paymentCompleted` (optional expose)

### 3. OrderService.placeOrder

- [ ] Set `order.customerName` từ `request.getCustomerName()`
- [ ] COD: `paymentCompleted = false`, `status = PENDING` (giữ nguyên)

### 4. mapToOrderResponse

- [ ] Map `customerName` vào response
- [ ] Admin + user endpoints đều nhận field mới

---

## Acceptance Criteria

1. `POST /api/v1/orders` với `customerName` → field lưu DB
2. Response GET order có `customerName`
3. Backend compile + start OK (`ddl-auto=update` tạo columns)

---

## Files

| Action | Path |
|--------|------|
| MODIFY | `be-ecommerce/.../order/domain/Order.java` |
| MODIFY | `be-ecommerce/.../order/dto/OrderRequest.java` |
| MODIFY | `be-ecommerce/.../order/dto/OrderResponse.java` |
| MODIFY | `be-ecommerce/.../order/service/OrderService.java` |
