# Plan: Flutter Logout UI → Spring Boot `/api/auth/logout`
Status: 🟢 Implemented (pending manual E2E)
Date: 2026-06-03
Mode: Fast
Test: default

## Overview
Connect shopper-facing logout UI to the **existing** logout stack. Backend `POST /api/auth/logout` and Flutter data layer (`AuthRemoteDataSource`, `AuthRepositoryImpl`, `AuthBloc`) are already implemented. Gap: **customer `ProfilePage` has no logout control**; only `AdminDashboardPage` dispatches `AuthLogoutRequested`. This plan adds profile logout UI, optional confirmation UX, and manual E2E verification that the refresh cookie is revoked server-side.

---

## User Stories

### P1 — Must Have
- **US-1**: As a logged-in shopper (USER role), I can tap **Đăng xuất** on the Profile screen and the app calls `POST /api/auth/logout` before clearing local session.
- **US-2**: After logout, I land on the Login screen and cannot navigate back to protected routes (home, cart, profile).
- **US-3**: Logout clears local access token **and** persisted cookies (`PersistCookieJar` via `clearSession`).

### P2 — Should Have
- **US-4**: As a user, I see a confirmation dialog before logout so I don't tap accidentally.
- **US-5**: As an ADMIN, logout from the admin dashboard still works (regression — already wired).
- **US-6**: If the logout API fails (network/5xx), local session is still cleared and I am logged out in-app (existing `finally` in repository).

### P3 — Nice to Have
- **US-7**: Show a brief loading indicator on the profile logout action while `AuthLoading` is active.
- **US-8**: Bind profile header (name/email/avatar) from `AuthBloc` / profile API instead of hardcoded mock data (out of scope for logout-only but improves UX).

---

## Phases
- [x] Phase 1: Profile logout UI + `AuthLogoutRequested` dispatch
- [ ] Phase 2: Manual E2E + regression (USER + ADMIN paths)

---

## Story ↔ Phase Mapping

| Phase | P1 | P2 | P3 |
|-------|----|----|-----|
| 1 | US-1, US-2, US-3 | US-4 | US-7 |
| 2 | US-1–3 (verify) | US-5, US-6 (verify) | US-8 (defer) |

---

## Existing Implementation (no BE work expected)

| Layer | Location | Status |
|-------|----------|--------|
| API | `be-ecommerce` `AuthController.logout` | ✅ Revoke refresh + clear cookie |
| Constant | `ApiConstants.logout` | ✅ |
| Remote | `auth_remote_datasource_impl.dart` `dio.post(logout)` | ✅ Cookie via `CookieManager` |
| Repository | `auth_repository_impl.dart` | ✅ Server call + `clearSession` in `finally` |
| Bloc | `auth_bloc.dart` `_onLogoutRequested` | ✅ → `AuthUnauthenticated` |
| Router | `app_router.dart` redirect on unauthenticated | ✅ |
| Admin UI | `admin_dashboard_page.dart` | ✅ Already dispatches event |
| Shopper UI | `profile_page.dart` | ❌ Missing logout row |

---

## Dependencies
- `auth-login-wire` completed (token storage, cookie jar, bloc, router).
- Backend running (`docker-compose` or local) on emulator-reachable `BASE_URL`.
- Test accounts: one `USER`, one `ADMIN`.

---

## Risks

| Severity | Risk | Mitigation |
|----------|------|------------|
| MEDIUM | Logout without refresh cookie → BE no-ops revoke but still returns 200; stale token in DB | Accept for P1; cookie set at login. Verify cookie present in Dio logs during E2E. |
| LOW | `AuthLoading` during logout may flash globally | Scope loading to logout button only (P3) or accept brief splash. |
| LOW | Profile mock data unrelated to auth | Do not block logout; US-8 deferred. |
| LOW | Double-tap logout dispatches twice | Disable button while `AuthLoading` or debounce in UI. |

---

## Research Summary (inline — Fast mode)

**Chosen:** Reuse `AuthLogoutRequested` → existing repository → router redirect. Add destructive-styled menu row on `ProfilePage` (mirror admin pattern).

**Rejected:**
- New logout use case / duplicate API client — unnecessary.
- Backend change to accept refresh token in body for mobile — out of scope; cookie jar already used for refresh.
- Logout-only local clear without API call — breaks server-side revoke.

---

## Cook Command

```
/ck:cook --fast plans/auth-logout-wire/plan.md
```
