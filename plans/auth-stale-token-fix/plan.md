# Plan: Fix stale access token on CategoryApiClient after account switch

**Status:** 🔴 Not started  
**Date:** 2026-06-16  
**Mode:** Fast  
**Test:** default (`dart analyze` + manual account-switch E2E)

## Overview

User đăng nhập **ADMIN** nhưng `POST /api/admin/categories` vẫn gửi Bearer token của **USER** đã login trước đó → 403 Forbidden.

**Root cause:** `CategoryApiClient` (LazySingleton) cache token trong field `_token`. Sau khi logout/login account khác, `LocalStorage` (`auth_token`) đã cập nhật nhưng singleton vẫn giữ token cũ trong RAM.

`DioClient` chính **không** bị lỗi này — `_AuthRefreshInterceptor` đọc `AuthTokenStorage.getAccessToken()` mỗi request.

---

## Scope Challenge

```
# Scope Challenge:
#   Exists?     → Có — CategoryApiClient._token in-memory cache (singleton)
#   Minimum?    → Bỏ cache; đọc token fresh từ AuthTokenStorage mỗi request
#   Complexity? → Fast — 1 file chính + DI wiring, pattern quen thuộc
#
# Mode: Fast
# Test:  default
```

**Spec Quality Check:** N/A (không có spec.md) — yêu cầu user rõ ràng, có root cause xác nhận.

---

## User Stories

### P1 — Must Have
- **US-1**: Sau khi logout USER rồi login ADMIN (không restart app), `POST /api/admin/categories` gửi token ADMIN → 201 Created.
- **US-2**: Sau logout, category admin writes không còn gửi Bearer token cũ (401/403 hoặc không có header cho đến khi login lại).
- **US-3**: Login USER → login ADMIN trực tiếp (không logout) vẫn dùng token mới nhất từ storage.

### P2 — Should Have
- **US-4**: `CategoryApiClient` dùng `AuthTokenStorage` thay vì đọc `LocalStorage` trực tiếp — đồng bộ với auth layer.
- **US-5**: Regression: GET `/api/categories` (public) vẫn hoạt động khi chưa login.

### P3 — Nice to Have
- **US-6**: Migrate `CategoryRemoteDataSource` sang shared `DioClient` — xóa duplicate Dio/error interceptors.
- **US-7**: Sửa `AuthInterceptor` dùng `AppConstants.tokenKey` thay vì hardcoded `'access_token'` (dead key).

---

## Phases

- [ ] Phase 1: Remove stale token cache + wire AuthTokenStorage
- [ ] Phase 2: Manual E2E verification (account switch paths)

---

## Story ↔ Phase Mapping

| Phase | P1 | P2 | P3 |
|-------|----|----|-----|
| 1 | US-1, US-2, US-3 | US-4, US-5 | — |
| 2 | US-1–3 (verify) | US-4, US-5 (verify) | US-6, US-7 (defer) |

---

## Root Cause (confirmed)

```72:82:lib/features/category/data/network/category_api_client.dart
  Future<String?> _ensureToken() {
    if (_token != null && _token!.isNotEmpty) return Future.value(_token);  // ← stale

    final stored = _storage.getString(AppConstants.tokenKey);
    if (stored != null && stored.isNotEmpty) {
      _token = stored;
    }
    return Future.value(_token);
  }
```

- `CategoryApiClient` registered `registerLazySingleton` → sống suốt app lifecycle.
- `_token` chỉ clear khi 401 retry — **không** clear khi login/logout.

---

## Chosen Fix (minimal)

1. Xóa field `_token` và logic cache trong `_ensureToken()`.
2. Inject `AuthTokenStorage` thay `LocalStorage`.
3. Mỗi `onRequest`: `final token = _authTokenStorage.getAccessToken()`.
4. Cập nhật `injection_container.dart`: `CategoryApiClient(sl<AuthTokenStorage>())`.

**Rejected (for P1):**
- Full migrate sang `DioClient` — đúng hướng dài hạn nhưng scope lớn hơn; defer US-6.
- `clearTokenCache()` gọi từ AuthBloc — fragile, dễ miss client khác; prefer read-fresh.

---

## Dependencies

- `auth-login-wire` (AuthTokenStorage, login/logout clear session).
- Backend chạy; có account USER + ADMIN.
- Category management screen (`/admin/categories`).

---

## Risks

| Severity | Risk | Mitigation |
|----------|------|------------|
| LOW | Perf: đọc storage mỗi request | `LocalStorage` in-memory; negligible vs network |
| LOW | Module-specific Dio clients khác cũng cache token | Grep `_token` — hiện chỉ `CategoryApiClient` |
| MEDIUM | User hot-restart với stale singleton trước fix | Fix + manual E2E sau hot restart |
| LOW | `AuthInterceptor` wrong key `'access_token'` | Out of scope P1; note US-7 |

---

## Research Summary (inline — Fast mode)

**Primary:** Remove in-memory cache; single source of truth = `AuthTokenStorage`.

**Alternative:** Consolidate all HTTP qua `DioClient` — fewer interceptors, auto refresh on 401 — defer to follow-up.

---

## Cook Command

```
/ck:cook --fast plans/auth-stale-token-fix/plan.md
```
