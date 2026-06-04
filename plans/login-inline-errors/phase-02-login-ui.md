# Phase 2: LoginPage — Inline error UX

**Covers:** US-1, US-2, US-4, US-6 (P1–P2)  
**testing:** manual

## Goal

`LoginPage` mirror pattern `RegisterPage`: builder đọc state, không SnackBar.

## Tasks

- [ ] **2.1** State `_hideBlocLoginError`; reset `false` trong `_onSubmit`.
- [ ] **2.2** `BlocConsumer`:
  - **listener**: chỉ `AuthAuthenticated` → navigate (xóa nhánh `AuthError` SnackBar).
  - **builder**: `isLoading = state is AuthLoading`; `loginError` từ `AuthLoginFailed` khi `!_hideBlocLoginError`.
- [ ] **2.3** Hiển thị `loginError` **dưới ô mật khẩu**, trước nút Đăng nhập (form-level credential error).
- [ ] **2.4** `onChanged` email + password → `_hideBlocLoginError = true`.
- [ ] **2.5** Viền đỏ email + password khi `loginError != null` (copy decoration pattern từ register).
- [ ] **2.6** Nút: `onPressed: isLoading ? null : _onSubmit`; spinner khi `isLoading`.

## Files

| File | Change |
|------|--------|
| `lib/features/auth/presentation/pages/login_page.dart` | Full inline UX |

## Placement (quyết định)

Lỗi *"Email hoặc mật khẩu không đúng"* đặt **dưới password**, không dưới email — vì backend không chỉ ra field nào sai.

## Done when

- Không còn `ScaffoldMessenger` cho login errors.
- UX khớp register (inline text 12px, `AppColors.error`).
