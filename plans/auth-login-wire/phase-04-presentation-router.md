# Phase 4: Presentation & Router Audit

## Goal
Ensure UI navigation matches role from API; remove duplicate/heuristic routing.

**Delivers:** US-3, US-4, US-7

---

## Tasks

- [ ] **4.1** `LoginPage` listener: keep `isAdmin` → `adminDashboard`, else `home` (already present — verify after entity change).
- [ ] **4.2** `SplashPage`: on `AuthAuthenticated`, route admin → `/admin`, user → `/home` (not always home).
- [ ] **4.3** `AppRouter.redirect`: when authenticated admin visits `/home`, redirect `/admin`; when user visits `/admin`, redirect `/home` or `/products` (existing guard).
- [ ] **4.4** Consider `initialLocation: '/splash'` for cleaner cold start (optional).
- [ ] **4.5** Remove navigation from login listener if router redirect is sufficient — **pick one** to avoid double navigation (prefer router-only OR page listener, not both).

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/auth/presentation/pages/login_page.dart` | Verify listener |
| `lib/features/auth/presentation/pages/splash_page.dart` | Role-aware redirect |
| `lib/app/router/app_router.dart` | Admin/home redirect polish |

---

## Acceptance Criteria

- [ ] ADMIN account never lands on shopper home after login (ends on `/admin`).
- [ ] USER account never sees admin dashboard.
- [ ] No `email.contains('admin')` anywhere in auth feature.

---

## Dependencies
- Phase 3 complete.
