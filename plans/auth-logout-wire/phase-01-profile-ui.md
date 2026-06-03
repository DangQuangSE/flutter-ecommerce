# Phase 1: Profile Logout UI

**Mode:** Fast | **Testing:** default

## Goal
Add shopper logout entry point on `ProfilePage` wired to `AuthBloc`.

## Tasks

- [x] **1.1** Import `flutter_bloc`, `AuthBloc`, `AuthEvent` in `profile_page.dart`.
- [x] **1.2** Add menu group (e.g. eyebrow `TÀI KHOẢN`) with a destructive **Đăng xuất** row below existing account items — reuse `ProfileMenuRow` styling or admin-style red icon/text for consistency with `admin_dashboard_page.dart`.
- [x] **1.3** On tap: show `AlertDialog` confirmation ("Bạn có chắc muốn đăng xuất?") with Cancel / **Đăng xuất** (P2 US-4).
- [x] **1.4** On confirm: `context.read<AuthBloc>().add(const AuthLogoutRequested())`.
- [x] **1.5** Optional: wrap logout row in `BlocBuilder<AuthBloc, AuthState>` to disable button while `state is AuthLoading` (P3 US-7).
- [x] **1.6** Ensure `ProfilePage` has access to `AuthBloc` (verify `MaterialApp` / shell provides bloc — same as admin page pattern).

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/profile/presentation/pages/profile_page.dart` | Logout row + confirmation + bloc dispatch |

## Acceptance Criteria

- [ ] Logged-in USER on `/profile` sees **Đăng xuất**.
- [ ] Confirm → Dio `POST /api/auth/logout` (check debug log).
- [ ] App navigates to `/login` via router redirect on `AuthUnauthenticated`.
- [ ] No BE file changes.

## Out of Scope

- Replacing mock bio (`Alex Mercer`) with live user data (US-8).
- New repository or datasource methods.
