# Phase 2: Data & Domain — Admin Order Models + Repository

## Goal
Implement HTTP layer cho 3 admin order endpoints, map JSON → entities.

**Delivers:** US-1, US-2, US-3, US-4 (data layer)

---

## Tasks

- [ ] **2.1** `AdminOrderItemEntity` + `AdminOrderItemModel.fromJson` — map `OrderItemResponse` fields.
- [ ] **2.2** `AdminOrderEntity` + `AdminOrderModel.fromJson`:
  - `id`, `shippingAddress`, `phoneNumber`, `totalAmount`, `status`, `paymentMethod`, `createdAt`, `items`
  - Getter `displayCode` → `'#${id.toString().padLeft(4, '0')}'` (hoặc `'ORD-$id'`)
  - Getter `primaryProductName` → first item name or `'N/A'`
- [ ] **2.3** `OrderStatusLabel` helper (`lib/core/utils/order_status_label.dart`):
  | Enum | VI label |
  |------|----------|
  | PENDING | Chờ xác nhận |
  | CONFIRMED | Đã xác nhận |
  | PROCESSING | Đang xử lý |
  | SHIPPED | Đang giao |
  | DELIVERED | Đã giao |
  | CANCELLED | Đã hủy |
  | RETURN_REQUESTED | Yêu cầu trả hàng |
  | RETURNED | Đã trả hàng |
  | REFUNDED | Đã hoàn tiền |
- [ ] **2.4** `AdminOrderRemoteDataSource` interface:
  - `getOrders({String? search, String? status, int page, int size})`
  - `getOrderById(int id)`
  - `updateOrderStatus(int id, String status)`
- [ ] **2.5** `AdminOrderRemoteDataSourceImpl` — Dio calls:
  - GET `ApiConstants.adminOrders` + query params
  - GET `$adminOrders/$id`
  - PATCH `$adminOrders/$id/status` body `{ 'status': status }`
  - Parse `response.data['data']` (match brand pattern)
- [ ] **2.6** `AdminOrderRepository` + `AdminOrderRepositoryImpl` — wrap `Result<T>` / `AppException`.
- [ ] **2.7** Use cases:
  - `GetAdminOrdersUseCase`
  - `GetAdminOrderDetailUseCase`
  - `UpdateAdminOrderStatusUseCase`

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/admin/domain/entities/admin_order_entity.dart` | **New** |
| `lib/features/admin/domain/entities/admin_order_item_entity.dart` | **New** |
| `lib/features/admin/data/models/admin_order_model.dart` | **New** |
| `lib/features/admin/data/models/admin_order_item_model.dart` | **New** |
| `lib/features/admin/data/datasources/admin_order_remote_datasource.dart` | **New** |
| `lib/features/admin/data/datasources/admin_order_remote_datasource_impl.dart` | **New** |
| `lib/features/admin/domain/repositories/admin_order_repository.dart` | **New** |
| `lib/features/admin/data/repositories/admin_order_repository_impl.dart` | **New** |
| `lib/features/admin/domain/usecases/get_admin_orders_usecase.dart` | **New** |
| `lib/features/admin/domain/usecases/get_admin_order_detail_usecase.dart` | **New** |
| `lib/features/admin/domain/usecases/update_admin_order_status_usecase.dart` | **New** |
| `lib/core/utils/order_status_label.dart` | **New** |

---

## Acceptance Criteria

- [ ] List call trả về `PagedResult<AdminOrderEntity>` với pagination metadata.
- [ ] Detail call map đủ `items[]` including `designImageUrl`.
- [ ] Status update gửi enum string uppercase (e.g. `CONFIRMED`).
- [ ] 401/403/404 surfaced as `ResultFailure` with backend message.

---

## Dependencies
- Phase 1 complete.
