# Phase 1: Domain Entities + Filter Mapping

## Goal
Mở rộng domain layer order để đủ dữ liệu hiển thị list + helper map filter pills.

**Delivers:** US-2, US-3 (domain foundation)

---

## Tasks

- [ ] **1.1** `OrderItemEntity` — fields: `id`, `productName`, `size`, `color`, `quantity`, `price`, `imageUrl` (nullable, maps from `designImageUrl`).
- [ ] **1.2** Mở rộng `OrderEntity`:
  - `id` (int), `status` (raw enum string), `totalAmount`, `createdAt`, `items` (List<OrderItemEntity>)
  - Getter `displayCode` → `'#${id.toString().padLeft(4, '0')}'`
  - Getter `primaryItem` → `items.firstOrNull`
  - Getter `statusLabel` → delegate `OrderStatusLabel.vi(status)`
  - Getter `statusColor` → map từ `OrderStatusLabel.badgeColors` foreground color
- [ ] **1.3** `CustomerOrderFilter` helper (`lib/core/utils/customer_order_filter.dart`):
  - `static const pills = ['Tất cả', 'Xác nhận', 'Đang xử lý', 'Đang giao', 'Đã giao', 'Đã hủy']`
  - `static bool matches(String pill, String rawStatus)` — mapping per plan.md
  - `static List<OrderEntity> apply(String pill, List<OrderEntity> orders)`
- [ ] **1.4** Mở rộng `OrderEntity` thêm fields cho detail: `shippingAddress`, `phoneNumber`, `paymentMethod`, `paymentCompleted`
- [ ] **1.5** Cập nhật `OrderRepository` interface:
  - `Future<Result<PagedResult<OrderEntity>>> getOrders({int page = 0, int size = 10})`
  - `Future<Result<OrderEntity>> getOrderById(int id)`

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/order/domain/entities/order_item_entity.dart` | **New** |
| `lib/features/order/domain/entities/order_entity.dart` | **Expand** |
| `lib/features/order/domain/repositories/order_repository.dart` | **Update** signature |
| `lib/core/utils/customer_order_filter.dart` | **New** |

---

## Acceptance Criteria

- `OrderEntity` có đủ fields render 1 list item không cần Map mock
- Filter helper unit-testable (pure Dart, no Flutter import ngoài Color nếu cần)
- `dart analyze` pass
