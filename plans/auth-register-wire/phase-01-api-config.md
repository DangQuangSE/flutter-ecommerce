# Phase 1: API Config

## Goal
Correct all network constants and base URL configuration so the Flutter app can reach the Spring Boot backend at `http://localhost:8080/api/auth/*` from an emulator or device, and add all OTP-related path constants needed by later phases.

**Delivers:** US-8 (dart-define baseUrl), unblocks every other phase.

---

## Tasks

- [ ] **1.1** Replace the hard-coded `baseUrl` in `ApiConstants` with a value read from `--dart-define=BASE_URL`, defaulting to `http://10.0.2.2:8080` (Android emulator loopback to host).
- [ ] **1.2** Change all existing path constants to use the `/api/auth/` prefix: update `login` → `/api/auth/login`, `register` → `/api/auth/register`.
- [ ] **1.3** Add the four new OTP path constants: `registerRequestOtp`, `verifyOtp`, `register`, `resendOtp` — all under `/api/auth/`.
- [ ] **1.4** Remove or rename the stale non-auth paths (`products`, `cart`, `orders`, `profile`) only if they are not referenced elsewhere; otherwise leave and annotate with a TODO comment to align in a separate ticket.
- [ ] **1.5** Confirm `DioClient` picks up the updated `ApiConstants.baseUrl` without requiring any change to its constructor (it should already read from `ApiConstants.baseUrl` in `BaseOptions`).
- [ ] **1.6** Add a `README` note (or update existing) documenting how to pass `--dart-define=BASE_URL=http://192.168.x.x:8080` for physical device testing.

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/core/constants/api_constants.dart` | Replace `baseUrl`, add OTP paths, fix prefix |
| `lib/core/network/dio_client.dart` | Read-only verify — confirm `BaseOptions(baseUrl: ApiConstants.baseUrl)` |
| `README.md` (project root) | Add dart-define usage note |

---

## Acceptance Criteria

- [ ] `ApiConstants.baseUrl` compiles to `http://10.0.2.2:8080` when no `--dart-define` is provided.
- [ ] Providing `--dart-define=BASE_URL=http://192.168.1.5:8080` at `flutter run` changes the effective base URL (verifiable with a debug print in `DioClient` constructor).
- [ ] `ApiConstants.registerRequestOtp` equals `/api/auth/register/request-otp`.
- [ ] `ApiConstants.verifyOtp` equals `/api/auth/verify-otp`.
- [ ] `ApiConstants.register` equals `/api/auth/register`.
- [ ] `ApiConstants.resendOtp` equals `/api/auth/resend-otp`.
- [ ] `ApiConstants.login` equals `/api/auth/login`.
- [ ] `flutter analyze` reports zero new errors or warnings in `api_constants.dart` and `dio_client.dart`.

---

## Dependencies

- None. This phase is self-contained and is a prerequisite for all other phases.

---

## Test Suggestions

- Unit test `ApiConstants` constant values with `expect(ApiConstants.registerRequestOtp, '/api/auth/register/request-otp')` etc. (trivial but catches typos).
- Manual smoke: run the app against a live backend and confirm `DioClient` logs show the correct base URL in `LogInterceptor` output.
