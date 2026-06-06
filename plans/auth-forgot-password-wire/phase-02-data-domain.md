# Phase 2: Data & Domain Layer

## Goal
Introduce a **forgot-password-only** data/domain stack (separate from register OTP on `AuthRepository`) with three use cases: request OTP, verify OTP (returns token), reset password — so presentation can depend on clean `Result` types before any UI work.

**Delivers:** US-1–3 network plumbing, US-4 resend plumbing (same as request OTP), US-5 error mapping, US-8 (no persistence in this layer).

---

## Tasks

- [ ] **2.1 — Datasource contract**: Create `ForgotPasswordRemoteDataSource` with `requestOtp(email)` → returns **neutral `message` string** (top-level `ApiResponse.message`, `data: null`), `verifyOtp(email, otpCode)` → `forgotPasswordToken`, `resetPassword(forgotPasswordToken, newPassword)`.
- [ ] **2.2 — Datasource impl**: Implement with `DioClient` + Phase 1 constants. After successful `request-otp`, parse `(response.data!['message'] as String?)`. Parse verify: `data['forgotPasswordToken']` from envelope (sample: `{ message, data: { message, forgotPasswordToken } }`).
- [ ] **2.3 — Repository interface**: `ForgotPasswordRepository` — `requestOtp` → `Result<String>` (message), verify → `Result<String>` (token), reset → `Result<void>`.
- [ ] **2.4 — Repository impl**: Map `ServerException` / `NetworkException` to failures; surface backend `message` for UI (429, 400 OTP errors, invalid token).
- [ ] **2.5 — Use cases** (under `forgot_password/domain/usecases/`):
  - `ForgotPasswordRequestOtpUseCase`
  - `ForgotPasswordVerifyOtpUseCase`
  - `ForgotPasswordResetUseCase`
- [ ] **2.6 — DI**: Register datasource + repository as lazy singletons; use cases as `registerFactory`. **Do not** inject into `AuthBloc`.
- [ ] **2.7 — Leave `AuthRemoteDataSource` unchanged** for register/login paths.

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/auth/forgot_password/data/datasources/forgot_password_remote_datasource.dart` | New — abstract |
| `lib/features/auth/forgot_password/data/datasources/forgot_password_remote_datasource_impl.dart` | New — Dio impl |
| `lib/features/auth/forgot_password/data/repositories/forgot_password_repository_impl.dart` | New |
| `lib/features/auth/forgot_password/domain/repositories/forgot_password_repository.dart` | New — abstract |
| `lib/features/auth/forgot_password/domain/usecases/forgot_password_request_otp_usecase.dart` | New |
| `lib/features/auth/forgot_password/domain/usecases/forgot_password_verify_otp_usecase.dart` | New |
| `lib/features/auth/forgot_password/domain/usecases/forgot_password_reset_usecase.dart` | New |
| `lib/core/di/injection_container.dart` | Register forgot-password stack only |

---

## Acceptance Criteria

- [ ] `requestOtp` posts `{"email": "<normalized>"}` to `/api/forgot-password/request-otp` and returns non-empty neutral `message` on 2xx.
- [ ] `verifyOtp` posts `{"email": "...", "otpCode": "123456"}` — **not** `"otp"`.
- [ ] Successful verify returns non-empty `forgotPasswordToken` string to repository/use case caller.
- [ ] `resetPassword` posts only `forgotPasswordToken` + `newPassword` (min length aligned with backend: 6+).
- [ ] 429 from resend/request surfaces as `ServerFailure` with backend message string.
- [ ] `flutter analyze` clean on all new files.
- [ ] `sl<ForgotPasswordRequestOtpUseCase>()` resolves without `GetIt` error.
- [ ] `AuthBloc` / register use cases unchanged and still compile.

---

## Manual Test Steps

1. Start backend (`docker-compose up` in `be-ecommerce`).
2. From a temporary debug entry or unit test with real Dio (optional integration test), call `requestOtp` for a seeded user email — inbox receives OTP.
3. Call `verifyOtp` with correct `otpCode` — assert token string non-empty.
4. Call `resetPassword` with that token + new password — 200; login with new password succeeds.

---

## Dependencies

- Phase 1 complete.
- Backend reachable at configured `BASE_URL`.

---

## Test Suggestions

- **Unit — datasource (mock Dio)**: Assert URL, method, JSON keys for each call; mock verify response JSON with `data: { forgotPasswordToken: 'x' }`.
- **Unit — repository**: 400 → `ServerFailure(message)`; network error → `NetworkFailure`.
- **Unit — use cases**: Delegation one-liners per use case.
