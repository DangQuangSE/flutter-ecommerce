# Phase 2: Auth flow cleanup

**Covers:** US-2, US-3, US-4 (P1–P2)  
**testing:** manual + `flutter analyze`

## Goal

Loại bỏ `name` khỏi presentation layer; thông báo đăng ký thành công không phụ thuộc tên.

## Tasks

- [ ] **2.1** `auth_event.dart`: bỏ `name` từ `AuthOtpRequested`, `AuthOtpVerifyRequested`, `AuthResendOtpRequested`.
- [ ] **2.2** `auth_state.dart`: bỏ `name` từ `AuthOtpSent`; `AuthRegistrationSuccess` bỏ `welcomeName` (hoặc luôn `const AuthRegistrationSuccess()`).
- [ ] **2.3** `auth_bloc.dart`: emit `AuthOtpSent` không `name`; `AuthRegistrationSuccess()` không welcome name.
- [ ] **2.4** `register_otp_extra.dart`: chỉ `email` + `password`.
- [ ] **2.5** `otp_verification_page.dart`: events không `name`; snack-bar cố định: `Đăng ký thành công! Vui lòng đăng nhập.`
- [ ] **2.6** `register_page.dart`: `AuthOtpRequested` / `RegisterOtpExtra` không `name`.
- [ ] **2.7** Grep `lib/features/auth` cho `name:` / `welcomeName` — sửa mọi call site còn sót.
- [ ] **2.8** Chạy `flutter analyze lib/features/auth/`.

## Files

| File | Change |
|------|--------|
| `lib/features/auth/presentation/bloc/auth_event.dart` | Remove name fields |
| `lib/features/auth/presentation/bloc/auth_state.dart` | Remove name / welcomeName |
| `lib/features/auth/presentation/bloc/auth_bloc.dart` | Update emit + handlers |
| `lib/features/auth/presentation/models/register_otp_extra.dart` | Remove name |
| `lib/features/auth/presentation/pages/otp_verification_page.dart` | Events + success message |
| `lib/features/auth/presentation/pages/register_page.dart` | Align with new API |

## Notes

- `UserEntity.name` / login response — **không đổi** (tên từ API hoặc email local-part).
- Không cần sửa data layer / use cases (đã không gửi name).

## Done when

- `flutter analyze` clean trên auth presentation files.
- E2E register flow pass (backend chạy).
