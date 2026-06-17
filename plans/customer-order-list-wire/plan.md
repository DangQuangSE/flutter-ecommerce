# Plan: Customer Order List + Detail — Wire Flutter UI to Backend API
Status: 🟢 Implemented
Date: 2026-06-17
Mode: Hard
Test: default

## Overview
Kết nối màn **Đơn Hàng Của Tôi** (`OrderListPage`) và **Chi tiết đơn** (`OrderDetailPage`) với API backend thật (`GET /api/v1/orders`, `GET /api/v1/orders/{id}`), thay mock data bằng Clean Architecture layer (datasource → repository → use case → BLoC). Giữ nguyên UI hiện tại.

---

## Scope Challenge

```
# Scope Challenge:
#   Exists?     → Backend OrderController GET list ✅ | Flutter order list mock-only ❌
#   Minimum?    → Fetch paginated orders + hiển thị list + filter pills + loading/error/empty
#   Complexity? → Hard — multi-layer Flutter, pagination, status mapping, auth JWT
#
# Mode: Hard
# Test: default
```

---

## User Stories

### P1 — Must Have
- **US-1**: Khách hàng đã đăng nhập xem danh sách đơn hàng của mình từ `GET /api/v1/orders`.
- **US-2**: Mỗi item hiển thị mã đơn, trạng thái (tiếng Việt), tên SP đầu tiên, size, số lượng, tổng tiền, ngày đặt, ảnh thumbnail.
- **US-3**: Filter pills (`Tất cả`, `Đang giao`, `Đã giao`, `Đã hủy`) lọc danh sách đã tải.
- **US-4**: Xử lý Loading / Error / Empty states theo chuẩn grading.

### P2 — Should Have
- **US-5**: Load-more khi cuộn xuống cuối danh sách (`size=10`).
- **US-6**: Pull-to-refresh tải lại trang đầu.
- **US-7**: Tap item → `OrderDetailPage` với dữ liệu thật từ `GET /api/v1/orders/{id}`.

### P3 — Nice to Have
- **US-8**: Backend thêm `status` query param cho user orders — **out of scope v1**.
- **US-9**: Tracking number / estimated delivery từ backend — hiện không có trong `OrderResponse`, ẩn hoặc placeholder.

---

## Research Summary

**Primary (RECOMMEND):**
1. Xây layer order **riêng trong feature `order`** — không reuse `AdminOrderEntity` (admin-only, khác use case).
2. `OrderBloc` (theo add-feature skill) — list + filter + pagination events.
3. Pattern copy từ `AdminOrderRemoteDataSourceImpl`: Dio → `response.data['data']` → `PagedResult.fromSpringPage`.
4. Mở rộng `OrderEntity` + `OrderItemEntity` map `OrderResponse` / `OrderItemResponse` backend.
5. Reuse `OrderStatusLabel` (`lib/core/utils/order_status_label.dart`) cho label + màu status.
6. Thêm `CustomerOrderFilter` helper map pill VI → raw status enum cho client-side filter.
7. Ảnh list item: dùng `designImageUrl` từ item đầu tiên (backend đã map product thumbnail vào field này).
8. `ApiConstants.orders` đã có — không cần thêm constant.

**Alternative (CAUTION):**
- Reuse `AdminOrderModel` + adapter → coupling admin/user, vi phạm layer separation.
- Gọi API 1 lần `size=100` bỏ pagination → đơn giản nhưng không scale.
- Cubit thay BLoC → nhanh hơn nhưng lệch convention project (`order` = BLoC).
- Thêm `status` filter backend trước → chính xác hơn nhưng cần sửa Java + test BE.

---

## Phases
- [x] Phase 1: Domain entities + filter mapping helper
- [x] Phase 2: Data layer — models, datasource, repository, use cases (list + detail)
- [x] Phase 3: OrderBloc + DI registration (list + detail)
- [x] Phase 4: Wire OrderListPage presentation
- [x] Phase 5: Wire OrderDetailPage presentation
- [x] Phase 6: Integration verification (unit tests + analyze pass; manual E2E on device)

---

## Story ↔ Phase Mapping

| Phase | P1 | P2 | P3 |
|-------|----|----|-----|
| 1 | US-2, US-3 | — | — |
| 2 | US-1, US-2 | US-7 | — |
| 3 | US-1, US-4 | US-5–7 | — |
| 4 | US-1–4 | US-5–6 | — |
| 5 | US-2 | US-7 | US-9 |
| 6 | all verify | US-5–7 | — |

---

## Backend Contract Reference

| Method | Path | Auth | Query |
|--------|------|------|-------|
| GET | `/api/v1/orders` | `ROLE_USER` JWT | `page`, `size`, `sort=createdAt,desc` |
| GET | `/api/v1/orders/{orderId}` | `ROLE_USER` JWT | — (detail — follow-up) |

**OrderResponse fields used for list:**
`id`, `status`, `totalAmount`, `createdAt`, `items[]` → `productName`, `size`, `quantity`, `price`, `designImageUrl`

**OrderStatus enum:** `PENDING`, `CONFIRMED`, `PROCESSING`, `SHIPPED`, `DELIVERED`, `CANCELLED`, `RETURN_REQUESTED`, `RETURNED`, `REFUNDED`

**Client filter mapping (pill → raw status):**
| Pill UI | Match statuses |
|---------|--------------|
| Tất cả | (no filter) |
| Xác nhận | `CONFIRMED` |
| Đang xử lý | `PROCESSING` |
| Đang giao | `SHIPPED` |
| Đã giao | `DELIVERED` |
| Đã hủy | `CANCELLED` |

**Display code:** `#0001` via `id.toString().padLeft(4, '0')`

---

## Risks

| Risk | Mitigation |
|------|------------|
| User API không có `status` query → filter chỉ trên data đã load | Document limitation; load-more giúp bổ sung; P3 US-9 nếu cần filter chính xác |
| `OrderEntity` stub quá mỏng | Phase 1 mở rộng entity + item entity |
| `OrderResponse` thiếu trackingNumber, shippingFee, estimatedDelivery | Phase 5: ẩn row hoặc dùng placeholder; subtotal = sum items; total = totalAmount |
| Chưa đăng nhập → 401 | Error state + message; auth guard đã có trên route |
| Ảnh SP null | `CachedNetworkImage` + error placeholder (đã có pattern) |

---

## Red-Team Review (inline)

| Finding | Verdict |
|---------|---------|
| Client-side filter incomplete khi chưa load hết pages | NOTED → Risks; load-more in P2 |
| Thêm 2 filter pills làm UI dài hơn | ACCEPTED → horizontal scroll ListView (đã có) |
| BLoC vs Cubit — project convention order=BLoC | ACCEPTED → Phase 3 dùng BLoC |
| Duplicate model code vs admin | ACCEPTED → separate entities; JSON shape giống nhưng domain tách |
| `Image.network` thay `cached_network_image` | ACCEPTED → Phase 4 đổi sang CachedNetworkImage |
| Filter tách PROCESSING / CONFIRMED riêng | ACCEPTED → 6 pills per user decision |

---

## Session Decisions (2026-06-17)

- **Order detail:** Gộp wire `OrderDetailPage` trong cùng cook.
- **Filter pills:** `Tất cả`, `Xác nhận` (CONFIRMED), `Đang xử lý` (PROCESSING), `Đang giao` (SHIPPED), `Đã giao` (DELIVERED), `Đã hủy` (CANCELLED).
- **Pagination:** `size=10` + load-more on scroll.
- **Mã đơn:** `#0001` (padLeft 4).
- **Backend:** Đã chạy + có user có đơn thật → Phase 6 E2E có thể verify ngay.

---

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-17
**Phase in progress:** complete
**Status:** All 6 phases implemented — 7 unit tests pass, dart analyze clean on order files

### Decisions made this session
- Gộp OrderDetailPage wire trong cùng cook
- 6 filter pills: Tất cả, Xác nhận, Đang xử lý, Đang giao, Đã giao, Đã hủy
- Mã đơn `#0001` via padLeft(4)
- Ẩn estimated delivery + shipping method trên detail (API không có)
- OrderBloc riêng cho list và detail routes (factory per BlocProvider)

### Next immediate action
- Manual E2E: đăng nhập → tab Orders → verify list + detail với backend thật

---

## Ready to Cook

```
/ck:cook --hard plans/customer-order-list-wire/plan.md
```
