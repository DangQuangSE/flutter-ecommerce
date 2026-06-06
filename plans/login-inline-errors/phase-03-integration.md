# Phase 3: Integration — Splash / router

**Covers:** US-5 verify (P2)  
**testing:** analyze + tab switch manual

## Goal

State mới không gây redirect/navigate lạ.

## Tasks

- [ ] **3.1** `splash_page.dart`: `case AuthLoginFailed()` → no-op (giống `AuthError`), vẫn ở splash hoặc chờ user.
- [ ] **3.2** `app_router.dart`: `AuthLoginFailed` không coi là authenticated; không redirect bất thường (giống `AuthError`).
- [ ] **3.3** Tab Login ↔ Register: lỗi register không hiện login (`AuthLoginFailed` vs `AuthError` tách biệt).
- [ ] **3.4** `flutter analyze lib/features/auth/`.

## Files

| File | Change |
|------|--------|
| `lib/features/auth/presentation/pages/splash_page.dart` | Optional case |
| `lib/app/router/app_router.dart` | Verify only (likely no change) |

## Done when

- Analyze clean; manual tab-switch test pass.
