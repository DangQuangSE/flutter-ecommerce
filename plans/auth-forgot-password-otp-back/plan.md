# Plan: Forgot Password OTP — Nút quay lại nhập email
Status: 🟢 Implemented
Date: 2026-06-04
Mode: Fast
Test: default

## Overview
Thêm nút **「Quay lại nhập email」** trên màn `/forgot-password/otp` để người dùng quay về màn nhập email (sửa email, gửi OTP lại). AppBar back icon giữ nhưng dùng `pop()` thay `goNamed` để khớp stack `pushNamed` từ email → OTP.

## Scope Challenge
```
Exists?     → AppBar leading back (goNamed) — thiếu CTA rõ, navigation có thể không pop đúng stack
Minimum?    → TextButton + _onBackToEmail() dùng context.pop(); disable khi loading
Complexity? → Fast — 1 file, pattern có sẵn (register OTP)
Mode: Fast
Test: default
```

## User Stories
### P1
- **US-1**: Trên màn OTP quên mật khẩu, tôi thấy nút quay lại rõ ràng để sửa email nếu nhập sai hoặc không nhận được mã.

## Phase 1: OTP back CTA
- [x] **1.1** `ForgotPasswordOtpPage`: method `_onBackToEmail()` → `context.pop()` (không `goNamed`)
- [x] **1.2** AppBar `leading` gọi `_onBackToEmail()`
- [x] **1.3** `TextButton` label **「Quay lại nhập email」** dưới 「Gửi lại mã」, `onPressed` null khi `ForgotPasswordLoading`
- [ ] **1.4** Manual: OTP → quay lại → email hiển thị, sửa email → Tiếp tục → OTP lại OK

## Files
| File | Change |
|------|--------|
| `lib/features/auth/forgot_password/presentation/pages/forgot_password_otp_page.dart` | Back CTA + pop navigation |

## Risks
- **LOW**: `goNamed` thay vì `pop` gây stack lạ — mitigated bằng pop.
