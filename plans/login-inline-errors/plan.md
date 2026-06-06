# Plan: Lỗi đăng nhập inline (giống Đăng ký)

**Status:** 🟢 Implemented  
**Date:** 2026-06-04  
**Mode:** Fast  
**Test:** default (`flutter analyze` + test tay)

## Overview

Thay SnackBar trên `LoginPage` bằng **lỗi inline** khi sai email/mật khẩu, đồng bộ UX với `RegisterPage` (đọc từ bloc state trong `builder`, nút loading dừng đúng, xóa lỗi khi user sửa input).

Tách state lỗi login khỏi `AuthError` của register để **không lẫn lỗi** khi chuyển tab Login ↔ Đăng ký.

---

## Scope Challenge

```
# Scope Challenge:
#   Exists?     → Có — Login dùng SnackBar; Register đã inline + Dio fix
#   Minimum?    → AuthLoginFailed state + LoginPage inline UI + map message VI
#   Complexity? → Fast — 1 page + bloc state + helper message
#
# Mode: Fast
# Test:  default
```

**Spec Quality Check:** PASS — yêu cầu rõ (inline, giống register, sai email/password).

---

## Hiện trạng

| | Login | Register |
|---|-------|----------|
| Lỗi API | SnackBar `AuthError` | Inline dưới email từ bloc state |
| Loading | `state is AuthLoading` | `isLoading` trong builder |
| State lỗi | Chung `AuthError` | `AuthError` + `AuthRegisterAccountExists` |
| Backend 401 | `"Invalid email or password"` | — |

**Vấn đề:** `AuthError` dùng chung → lỗi đăng ký có thể hiện trên login khi đổi tab; SnackBar không giống register.

---

## User Stories

### P1 — Must Have
- **US-1**: Sai email hoặc mật khẩu → thông báo tiếng Việt **inline** trên form login, không SnackBar.
- **US-2**: Nút Đăng nhập dừng loading sau lỗi; user có thể thử lại.

### P2 — Should Have
- **US-3**: Map `Invalid email or password` → *"Email hoặc mật khẩu không đúng."*
- **US-4**: Sửa email hoặc mật khẩu → ẩn lỗi API (pattern `_hideBlocLoginError` như register).
- **US-5**: State `AuthLoginFailed` — login không dùng `AuthError` (tránh bleed sang register).

### P3 — Nice to Have
- **US-6**: Viền đỏ cả email + password khi login fail (giống register viền email).

---

## Phases

- [x] Phase 1: Bloc — `AuthLoginFailed` + `mapLoginFailureMessage`
- [x] Phase 2: LoginPage — Inline error, loading, clear on change, email format
- [x] Phase 3: Router/splash — Xử lý state mới (nếu cần)

---

## Story ↔ Phase Mapping

| Phase | P1 | P2 | P3 |
|-------|----|----|-----|
| Phase 1 | US-1, US-2 | US-3, US-5 | — |
| Phase 2 | US-1, US-2 | US-4, US-6 | — |
| Phase 3 | — | — | US-5 (verify) |

---

## Out of Scope

- Validate format email trên login (user chưa yêu cầu)
- Đổi backend message
- Forgot password

---

## Risks

| Risk | Mitigation |
|------|------------|
| Login fail nhưng repository trả `AuthFailure` không map | `mapLoginFailureMessage` xử lý `AuthFailure` + fallback EN |
| `try/catch` login giống register OTP | Thêm catch trong `_onLoginRequested` emit `AuthLoginFailed` |

---

## Verification (manual)

1. Email/password sai → inline VI, không SnackBar, nút không quay.
2. Sửa 1 ký tự → lỗi biến mất.
3. Đăng ký fail → sang tab Login → **không** thấy lỗi đăng ký.
4. Đăng nhập đúng → vào Home/Admin.
