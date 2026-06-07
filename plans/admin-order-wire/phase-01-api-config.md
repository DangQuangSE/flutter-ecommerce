# Phase 1: API Constants + Pagination Helper

## Goal
Khai báo endpoint admin orders và helper parse Spring `Page` response — nền tảng cho datasource.

**Delivers:** US-1 (infra)

---

## Tasks

- [ ] **1.1** Thêm vào `ApiConstants`:
  ```dart
  static const String adminOrders = '/api/v1/admin/orders';
  ```
- [ ] **1.2** Tạo `lib/core/models/paged_result.dart` (generic):
  ```dart
  class PagedResult<T> {
    final List<T> content;
    final int totalElements;
    final int totalPages;
    final int page; // 0-based from API
    final bool isLast;
  }
  ```
- [ ] **1.3** Helper `PagedResult.fromSpringPage(Map json, T Function(Map) mapper)` — parse `data.content`, `totalElements`, `totalPages`, `number`, `last`.

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/core/constants/api_constants.dart` | Add `adminOrders` |
| `lib/core/models/paged_result.dart` | **New** |

---

## Acceptance Criteria

- [ ] `adminOrders` path khớp backend `@RequestMapping("/api/v1/admin/orders")`.
- [ ] `PagedResult.fromSpringPage` parse đúng structure `ApiResponse<Page<T>>`.

---

## Dependencies
- None (auth interceptor already attaches JWT).
