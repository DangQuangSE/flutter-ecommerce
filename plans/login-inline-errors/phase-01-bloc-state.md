# Phase 1: Bloc — AuthLoginFailed + message mapper

**Covers:** US-1, US-2, US-3, US-5 (P1–P2)  
**testing:** manual

## Goal

Login failure emit state riêng, message tiếng Việt, không dùng `AuthError`.

## Tasks

- [ ] **1.1** `auth_state.dart`: thêm `AuthLoginFailed { String message }`.
- [ ] **1.2** `auth_error_messages.dart`: thêm `mapLoginFailureMessage(Failure failure)`:
  - `AuthFailure` / message chứa `invalid email or password` → *"Email hoặc mật khẩu không đúng."*
  - Network/empty → fallback VI chung
- [ ] **1.3** `_onLoginRequested`: `ResultFailure` → `emit(AuthLoginFailed(mapped))`; `try/catch` → `AuthLoginFailed` fallback.
- [ ] **1.4** Không đổi register handlers (`AuthError` / `AuthRegisterAccountExists` giữ nguyên).

## Files

| File | Change |
|------|--------|
| `lib/features/auth/presentation/bloc/auth_state.dart` | New state |
| `lib/features/auth/presentation/utils/auth_error_messages.dart` | Login mapper |
| `lib/features/auth/presentation/bloc/auth_bloc.dart` | Login handler |

## Done when

- Login sai credential → bloc state `AuthLoginFailed`, không `AuthError`.
