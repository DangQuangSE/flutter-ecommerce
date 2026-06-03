# Phase 3: Bloc & Session Restore

## Goal
Wire `AuthBloc` to real use cases; restore session on splash.

**Delivers:** US-1, US-3, US-4, US-5

---

## Tasks

- [ ] **3.1** Replace mock `_onLoginRequested` with `LoginUseCase` → `AuthAuthenticated(user)` or `AuthError`.
- [ ] **3.2** Implement `_onCheckRequested` via repository `getCurrentUser` (no mock delay).
- [ ] **3.3** Implement `_onLogoutRequested`: call repository logout, `clearTokens`, emit `AuthUnauthenticated`.
- [ ] **3.4** Remove hard-coded admin email/password mock branch entirely.
- [ ] **3.5** On login failure, ensure token is not left half-saved (rollback if me fails after login).

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/auth/presentation/bloc/auth_bloc.dart` | Real handlers |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | Transactional login (token rollback) |

---

## Acceptance Criteria

- [ ] Login no longer uses `Future.delayed` mock.
- [ ] Cold start with valid token → splash → home or admin based on role.
- [ ] Cold start with expired/invalid token → login screen.
- [ ] Logout clears token and shows login.

---

## Dependencies
- Phase 2 complete.
