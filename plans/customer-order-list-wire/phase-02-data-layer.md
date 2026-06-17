# Phase 2: Data Layer — Models, Datasource, Repository, Use Cases

## Goal
HTTP layer cho `GET /api/v1/orders`, map JSON → entities, wrap `Result<T>`.

**Delivers:** US-1, US-2

---

## Tasks

- [ ] **2.1** `OrderItemModel extends OrderItemEntity` + `fromJson` — map `OrderItemResponse` fields; `imageUrl` ← `designImageUrl`.
- [ ] **2.2** `OrderModel extends OrderEntity` + `fromJson` — map `OrderResponse` fields; parse `items` list.
- [ ] **2.3** `OrderRemoteDataSource` interface:
  - `Future<PagedResult<OrderModel>> getOrders({int page = 0, int size = 10})`
- [ ] **2.4** `OrderRemoteDataSourceImpl`:
  - GET `ApiConstants.orders`
  - Query: `page`, `size`, `sort: 'createdAt,desc'`
  - Parse `response.data['data']` → `PagedResult.fromSpringPage(data, OrderModel.fromJson)`
  - Pattern: copy `AdminOrderRemoteDataSourceImpl.getOrders` (bỏ search/status params)
- [ ] **2.5** `OrderRepositoryImpl` implements `OrderRepository`:
  - Wrap Dio errors → `ResultFailure(AppException...)`
  - Map `OrderModel` → `OrderEntity` (models already extend entities)
- [ ] **2.6** `GetOrdersUseCase` + `GetOrderByIdUseCase`
- [ ] **2.7** `getOrderById` trong datasource: GET `$orders/{id}` → `OrderModel.fromJson`

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/order/data/models/order_item_model.dart` | **New** |
| `lib/features/order/data/models/order_model.dart` | **New** |
| `lib/features/order/data/datasources/order_remote_datasource.dart` | **New** |
| `lib/features/order/data/datasources/order_remote_datasource_impl.dart` | **New** |
| `lib/features/order/data/repositories/order_repository_impl.dart` | **New** |
| `lib/features/order/domain/usecases/get_orders_usecase.dart` | **New** |
| `lib/features/order/domain/usecases/get_order_by_id_usecase.dart` | **New** |

---

## Acceptance Criteria

- Datasource gọi đúng endpoint + query params
- Model parse được response mẫu từ backend (id int, status string, items array)
- Repository trả `Result` không throw raw exception
- `dart analyze` pass
