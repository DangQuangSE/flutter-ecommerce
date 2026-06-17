# Phase 1: Remove stale token cache in CategoryApiClient

## Goal

Đảm bảo mọi admin category request dùng access token **hiện tại** trong storage, không cache RAM cũ.

**Delivers:** US-1, US-2, US-3, US-4, US-5

---

## Tasks

- [ ] **1.1** Trong `category_api_client.dart`:
  - Xóa field `String? _token`
  - Thay constructor param `LocalStorage _storage` → `AuthTokenStorage _authTokenStorage`
  - `_ensureToken()` → đọc trực tiếp `_authTokenStorage.getAccessToken()` (sync, không cache)
  - Trong `onError` 401 retry: bỏ `_token = null` (không còn cache)
- [ ] **1.2** Cập nhật `injection_container.dart`:
  - `CategoryApiClient(sl<AuthTokenStorage>())` thay `sl<LocalStorage>()`
- [ ] **1.3** Cập nhật class doc comment — bỏ mention "in-memory cache"
- [ ] **1.4** `dart analyze` trên touched files — zero errors

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/category/data/network/category_api_client.dart` | Remove cache; inject AuthTokenStorage |
| `lib/core/di/injection_container.dart` | Update CategoryApiClient factory |

---

## Acceptance Criteria

- [ ] Login USER → mở app (category client khởi tạo) → logout → login ADMIN → `POST /api/admin/categories` log shows ADMIN token (decode JWT `roles: ["ADMIN"]`).
- [ ] Login USER → login ADMIN **without logout** → same: ADMIN token on POST.
- [ ] Logout → POST category → no stale USER token in Authorization header.
- [ ] GET `/api/categories` without login still works.
- [ ] `dart analyze` clean on touched files.

---

## Implementation Sketch

```dart
// Before
String? _token;
Future<String?> _ensureToken() {
  if (_token != null && _token!.isNotEmpty) return Future.value(_token);
  ...
}

// After
Future<String?> _ensureToken() async {
  final token = _authTokenStorage.getAccessToken();
  return (token != null && token.isNotEmpty) ? token : null;
}
```

Or inline in `onRequest` without helper — either is fine if no cache.

---

## Dependencies

- None (AuthTokenStorage already registered).

---

## Out of Scope

- Migrate to shared `DioClient` (US-6)
- Fix `AuthInterceptor` key mismatch (US-7)
