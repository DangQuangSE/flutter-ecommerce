# Phase 2: Data & Domain Layer

## Goal
Replace all stubbed auth data-layer code with real Dio HTTP calls matching the Spring Boot contract, and introduce the four domain use cases (`RequestOtpUseCase`, `VerifyOtpUseCase`, `RegisterUseCase`, `ResendOtpUseCase`) plus the updated repository contract — so every business action has a clean, testable entry-point before any UI is wired.

**Delivers:** US-1 network plumbing, US-2 network plumbing, US-3 network plumbing, US-4 network plumbing, US-5 error mapping.

---

## Tasks

- [ ] **2.1 — Abstract datasource contract**: Add four method signatures to `AuthRemoteDataSource`: `requestOtp(email)`, `verifyOtp(email, otp)`, `register(email, password)`, `resendOtp(email)`. Return types should be `Future<void>` for side-effect calls; `register` may return a simple success indicator. Keep `login` signature unchanged.

- [ ] **2.2 — Implement datasource**: In `AuthRemoteDataSourceImpl`, implement each new method as a real `dio.post(ApiConstants.X, data: {...})` call. On non-2xx, Dio's interceptor already throws `ServerException`; extract `response.data['message']` as the error message so the existing `_ErrorInterceptor` pattern is preserved. Remove the stub delay and mock user from `register`.

- [ ] **2.3 — Update repository interface**: Add `requestOtp`, `verifyOtp`, `register`, `resendOtp` to `AuthRepository` abstract class, all returning `Future<Result<void>>` (or `Future<Result<String>>` for any message). Keep `login` and `logout` untouched.

- [ ] **2.4 — Implement repository methods**: In `AuthRepositoryImpl`, wrap each datasource call in a `try/catch` converting `ServerException` → `ServerFailure` and `NetworkException` → `NetworkFailure`, matching the existing `login` pattern. Expose the backend's `message` field through the failure for display in the UI.

- [ ] **2.5 — Write use cases**: Create four use case classes under `domain/usecases/`:
  - `RequestOtpUseCase` — calls `repository.requestOtp(email)`
  - `VerifyOtpUseCase` — calls `repository.verifyOtp(email, otp)`
  - `RegisterUseCase` — calls `repository.register(email, password)`
  - `ResendOtpUseCase` — calls `repository.resendOtp(email)`
  Each follows the same single-method pattern as `LoginUseCase`.

- [ ] **2.6 — Register in DI**: In `injection_container.dart`, register the four new use cases as `registerFactory` (stateless, instantiated per use). Inject them into `AuthBloc` alongside the existing `LoginUseCase`.

- [ ] **2.7 — Update AuthBloc constructor**: Accept the four new use cases as named parameters. Do not change any event handlers yet — that is Phase 3. Just wire the constructor so DI compiles.

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/auth/data/datasources/auth_remote_datasource.dart` | Add 4 abstract method signatures |
| `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart` | Implement 4 real Dio calls; remove register stub |
| `lib/features/auth/domain/repositories/auth_repository.dart` | Add 4 method signatures |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | Implement 4 methods with error mapping |
| `lib/features/auth/domain/usecases/request_otp_usecase.dart` | New file |
| `lib/features/auth/domain/usecases/verify_otp_usecase.dart` | New file |
| `lib/features/auth/domain/usecases/register_usecase.dart` | New file |
| `lib/features/auth/domain/usecases/resend_otp_usecase.dart` | New file |
| `lib/core/di/injection_container.dart` | Register 4 use cases; update `AuthBloc` factory |
| `lib/features/auth/presentation/bloc/auth_bloc.dart` | Add constructor params (no handler changes yet) |

---

## Acceptance Criteria

- [ ] `flutter analyze` reports zero new errors across all touched files.
- [ ] `AuthRemoteDataSourceImpl.requestOtp` calls `POST /api/auth/register/request-otp` with body `{"email": email}` — verifiable via `LogInterceptor` output.
- [ ] `AuthRemoteDataSourceImpl.verifyOtp` calls `POST /api/auth/verify-otp` with body `{"email": email, "otp": otp}`.
- [ ] `AuthRemoteDataSourceImpl.register` calls `POST /api/auth/register` with body `{"email": email, "password": password}` and no longer returns a mock user.
- [ ] `AuthRemoteDataSourceImpl.resendOtp` calls `POST /api/auth/resend-otp` with body `{"email": email}`.
- [ ] A 400/409/429 response from the backend surfaces as a `ServerFailure` with the backend's `message` string (not a generic "Unknown error").
- [ ] All four use cases can be resolved from `GetIt` (`sl<RequestOtpUseCase>()` etc.) without throwing.
- [ ] Existing `LoginUseCase` and mock `AuthCheckRequested` behavior are unaffected.

---

## Dependencies

- Phase 1 must be complete (correct `ApiConstants` paths).
- Backend container must be running for live integration checks; unit tests with mocked datasource can run without it.

---

## Test Suggestions

- **Unit — datasource**: Mock `DioClient`, verify correct URL + body for each method; simulate 4xx response and assert `ServerException` is thrown with the correct message string.
- **Unit — repository**: Mock `AuthRemoteDataSource`, verify `ServerException` maps to `ServerFailure(message)` and `NetworkException` maps to `NetworkFailure`.
- **Unit — use cases**: Trivial delegation tests — assert `RequestOtpUseCase(email)` calls `repository.requestOtp(email)` once.
- **Manual integration**: With backend running, trigger `requestOtp` from a test harness or DartPad snippet and confirm the email inbox receives the OTP.
