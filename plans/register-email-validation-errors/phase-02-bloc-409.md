# Phase 2: Bloc — 409 email đã tồn tại + message tiếng Việt

**Covers:** US-2, US-4 (P1–P2)  
**testing:** manual + analyze

## Goal

`request OTP` và `resend OTP` trả 409 → `AuthRegisterAccountExists` với message tiếng Việt.

## Tasks

- [ ] **2.1** Thêm helper (private trong `auth_bloc.dart` hoặc `lib/features/auth/presentation/utils/auth_error_messages.dart`):
  - `mapRegisterFailure(Failure failure)` → `String`
  - 409 hoặc message chứa `already exists` → `'Email này đã được đăng ký. Vui lòng đăng nhập hoặc dùng email khác.'`
  - Các lỗi khác → `failure.message` (hoặc fallback tiếng Việt chung nếu rỗng)
- [ ] **2.2** `_onOtpRequested`: on failure, nếu `NetworkFailure` + `statusCode == 409` → `emit(AuthRegisterAccountExists(mappedMessage))`; else `AuthError`.
- [ ] **2.3** `_onResendOtpRequested`: cùng logic 409 (email đã verify giữa chừng).
- [ ] **2.4** `_onOtpVerifyRequested` register step: dùng cùng mapper cho 409 (thay `_failureMessage` thuần).

## Files

| File | Change |
|------|--------|
| `lib/features/auth/presentation/bloc/auth_bloc.dart` | 409 branches + mapper |
| `lib/features/auth/presentation/utils/auth_error_messages.dart` | Optional new file |

## Done when

- Gọi API request-otp với email đã có → bloc emit `AuthRegisterAccountExists`, không `AuthOtpSent`.
