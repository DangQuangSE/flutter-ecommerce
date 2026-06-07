# Plan: Admin Order Management — Wire Flutter UI to Backend APIs
Status: 🟢 Implemented (pending backend E2E)
Date: 2026-06-06
Mode: Hard
Test: default

## Overview
Kết nối giao diện quản lý đơn hàng admin trên Flutter với 3 API backend đã có sẵn (`GET` list, `GET` detail, `PATCH` status). Thay mock data bằng Clean Architecture layer (datasource → repository → use cases → Cubit) theo pattern `brand` + `auth-login-wire`, thêm màn danh sách + chi tiết admin và cập nhật trạng thái đơn.

---

## Scope Challenge

```
# Scope Challenge:
#   Exists?     → Backend AdminOrderController ✅ | Flutter admin order UI mock-only ❌
#   Minimum?    → List + detail + status update qua 3 admin endpoints
#   Complexity? → Hard — multi-layer Flutter, pagination, enum mapping, ADMIN auth
#
# Mode: Hard
# Test: default
```

---

## User Stories

### P1 — Must Have
- **US-1**: Admin xem danh sách đơn hàng phân trang từ `GET /api/v1/admin/orders`.
- **US-2**: Admin lọc đơn theo trạng thái (`status` query param) và tìm kiếm (`search`).
- **US-3**: Admin xem chi tiết đơn (`GET /api/v1/admin/orders/{id}`) — items, địa chỉ, tổng tiền, payment.
- **US-4**: Admin cập nhật trạng thái đơn (`PATCH /api/v1/admin/orders/{id}/status`) và thấy phản hồi thành công/lỗi.

### P2 — Should Have
- **US-5**: Nút "XEM TẤT CẢ" trên dashboard admin điều hướng tới danh sách đơn thật.
- **US-6**: Recent orders trên dashboard lấy từ API (5 đơn mới nhất) thay mock `AdminStatsModel`.
- **US-7**: Infinite scroll / load-more khi cuộn danh sách.

### P3 — Nice to Have
- **US-8**: Pull-to-refresh trên list + detail.
- **US-9**: Admin return/refund flow (`AdminReturnController`) — out of scope v1.

---

## Research Summary

**Primary (RECOMMEND):**
1. Thêm layer admin-order **trong feature `admin`** (admin-only, không reuse user order pages).
2. `AdminOrderCubit` riêng — tránh phình `AdminBloc` (đang quản stats + products).
3. Pattern copy từ `BrandRemoteDataSourceImpl`: Dio → `response.data['data']` → parse Spring `Page` (`content`, `totalElements`, `totalPages`, `number`).
4. Entity/model map trực tiếp `OrderResponse` backend; status enum giữ raw (`PENDING`…) + helper `OrderStatusLabel.vi(status)`.
5. UI mới: `AdminOrderListPage` + `AdminOrderDetailPage`; tái sử dụng style từ `admin_dashboard_page` cards và layout `order_detail_page`.
6. `ApiConstants.adminOrders = '/api/v1/admin/orders'`.

**Alternative (CAUTION):**
- Gộp vào `AdminBloc` + reuse `order_list_page` với flag `isAdmin` → ít file hơn nhưng coupling cao, API/action khác user flow, khó maintain.
- Chọn khi cần ship cực nhanh MVP 1 màn list-only, bỏ detail.

---

## Phases
- [x] Phase 1: API constants + shared pagination model
- [x] Phase 2: Data & domain — models, datasource, repository, use cases
- [x] Phase 3: AdminOrderCubit + DI registration
- [x] Phase 4: Presentation — list, detail, status update, dashboard link
- [ ] Phase 5: Integration verification (deferred — backend chưa setup)

---

## Story ↔ Phase Mapping

| Phase | P1 | P2 | P3 |
|-------|----|----|-----|
| 1 | US-1 | — | — |
| 2 | US-1–4 | — | — |
| 3 | US-1–4 | — | US-8 |
| 4 | US-1–4 | US-5–7 | US-8 |
| 5 | all verify | US-5–7 | — |

---

## Backend Contract Reference

| Method | Path | Query/Body |
|--------|------|------------|
| GET | `/api/v1/admin/orders` | `search?`, `status?`, `page`, `size`, `sort` |
| GET | `/api/v1/admin/orders/{orderId}` | — |
| PATCH | `/api/v1/admin/orders/{orderId}/status` | `{ "status": "CONFIRMED" }` |

**Auth:** `ROLE_ADMIN` — JWT đã wire qua `DioClient` interceptor.

**OrderStatus enum:** `PENDING`, `CONFIRMED`, `PROCESSING`, `SHIPPED`, `DELIVERED`, `CANCELLED`, `RETURN_REQUESTED`, `RETURNED`, `REFUNDED`

---

## Session Decisions (2026-06-06)

- **Dashboard recent orders:** Wire luôn (P2 in scope) — fetch 5 đơn mới nhất từ admin list API.
- **Status update:** Dropdown cho phép chọn **mọi** OrderStatus enum.
- **Navigation:** Chỉ qua nút "XEM TẤT CẢ" trên dashboard — **không** thêm tab bottom nav.
- **Page size:** `size=10` mặc định.
- **Backend E2E:** Chưa setup — Phase 5 manual test deferred until backend + ADMIN account ready.

---

## Risks

| Risk | Mitigation |
|------|------------|
| Dashboard stats API chưa có → recent orders không wire được | P2 US-6: fetch 5 orders từ admin list API; stats KPI giữ mock tạm |
| Spring page index 0-based vs UI page 1 | Datasource dùng `page: 0` nội bộ; Cubit expose page cho UI |
| Status transition invalid server-side | Hiển thị backend error message; không hardcode transition matrix v1 |
| `OrderEntity` stub quá mỏng | Tạo `AdminOrderEntity` riêng, không extend stub user order |

---

## Red-Team Review (inline)

| Finding | Verdict |
|---------|---------|
| Thiếu route `/admin/orders` | ACCEPTED → Phase 4 |
| Chưa map `paymentMethod` enum | ACCEPTED → Phase 2 model |
| AdminBloc conflict nếu gộp order | ACCEPTED → separate Cubit |
| Backend search field unclear | NOTED → test with order id / phone in Phase 5 |

---

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-06
**Phase in progress:** phase-05-integration (deferred)
**Status:** Code complete — chờ backend + ADMIN account để E2E

### Decisions made this session
- Page size mặc định: 10
- Status dropdown: mọi OrderStatus enum
- Navigation: chỉ qua "XEM TẤT CẢ", không thêm bottom nav tab
- Dashboard recent orders: fetch 5 đơn từ API, fallback mock nếu API lỗi

### Next immediate action
- Chạy backend + tạo ADMIN account + seed orders → Phase 5 checklist

---

## Ready to Cook

```
/ck:cook --hard plans/admin-order-wire/plan.md
```
