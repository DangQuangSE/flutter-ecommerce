# Phase 2: E2E Verification & Regression

**Mode:** Fast | **Testing:** default (manual)

## Goal
Prove logout revokes server session and does not regress admin flow.

## Prerequisites

- Backend up: `docker-compose up` in `be-ecommerce` (or local Spring on `:8080`).
- Flutter: `flutter run` with `BASE_URL` pointing at emulator host (`http://10.0.2.2:8080` default).

## Manual Test Checklist

### USER path (P1)
- [ ] **2.1** Login as USER → land on `/home`.
- [ ] **2.2** Open Profile tab → tap **Đăng xuất** → confirm.
- [ ] **2.3** Observe debug log: `POST .../api/auth/logout` with `Set-Cookie` clear (if logged).
- [ ] **2.4** Land on Login; press system back — must **not** return to home/profile.
- [ ] **2.5** Cold restart app → should stay logged out (splash → login).

### Refresh after logout (cookie revoke)
- [ ] **2.6** After logout, attempt login again OR (if holding old access token manually) call refresh — refresh must fail / require re-login.

### ADMIN regression (P2 US-5)
- [ ] **2.7** Login as ADMIN → Admin dashboard Profile tab → **Đăng xuất tài khoản** still works.

### API failure resilience (P2 US-6)
- [ ] **2.8** Stop backend → logout from profile → app still clears session and shows login (repository `finally`).

## Optional DB Check

- [ ] Query `refresh_tokens` for test user: latest row `revoked = true` after logout.

## Done When

- [ ] All checklist items pass.
- [ ] Update `plan.md` Status → 🟢 Implemented.

## No Code Unless Failures

If logout POST returns 401/403 unexpectedly, inspect:
- `SecurityConfig` permits `/api/auth/logout`
- Cookie domain/path mismatch between login and logout
- Document finding in plan Risks; do not expand scope without user approval.
