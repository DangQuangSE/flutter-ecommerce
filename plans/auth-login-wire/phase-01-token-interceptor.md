# Phase 1: Token Storage + Dio Auth Interceptor

## Goal
Persist access tokens and attach `Authorization: Bearer <token>` on every Dio request after login.

**Delivers:** US-2

---

## Tasks

- [ ] **1.1** Add `ApiConstants.me = '/api/auth/me'`, `logout = '/api/auth/logout'`, `refreshToken = '/api/auth/refresh-token'`, `profileMe = '/api/profiles/me'`.
- [ ] **1.2** Create `AuthTokenStorage` (wraps `LocalStorage`): `saveAccessToken`, `getAccessToken`, `clearTokens`.
- [ ] **1.3** Register `AuthTokenStorage` in `injection_container.dart` (singleton).
- [ ] **1.4** Add `_AuthInterceptor` on `DioClient`: read token from storage, set header; skip if no token.
- [ ] **1.5** Inject `AuthTokenStorage` into `DioClient` constructor (update DI factory).

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/core/constants/api_constants.dart` | Add me, logout, refresh, profile paths |
| `lib/core/storage/auth_token_storage.dart` | **New** |
| `lib/core/network/dio_client.dart` | Auth interceptor |
| `lib/core/di/injection_container.dart` | Register storage; wire DioClient |

---

## Acceptance Criteria

- [ ] After `saveAccessToken`, Dio logs show `Authorization: Bearer ...` on requests.
- [ ] `clearTokens` removes header on subsequent requests.
- [ ] `flutter analyze` clean on touched files.

---

## Dependencies
- None (builds on existing `ApiConstants.baseUrl`).
