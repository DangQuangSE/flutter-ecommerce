# Phase 1: API Config

## Goal
Add forgot-password endpoint constants to `ApiConstants` with correct paths and document the **request/response JSON shape** (especially `otpCode` vs register's `otp`) so later phases cannot accidentally call the wrong contract.

**Delivers:** Foundation for US-1 network calls; unblocks Phases 2–4.

---

## Tasks

- [ ] **1.1** Add three path constants under `/api/forgot-password/`: `forgotPasswordRequestOtp`, `forgotPasswordVerifyOtp`, `forgotPasswordReset`.
- [ ] **1.2** Add a short comment block in `api_constants.dart` listing body keys per endpoint — implementors must not copy register `verifyOtp` payload. Include verify response sample: `{ "message": "...", "data": { "message": "...", "forgotPasswordToken": "..." } }`.
- [ ] **1.3** Confirm `DioClient` still uses `ApiConstants.baseUrl` unchanged; no forgot-specific client needed.
- [ ] **1.4** Grep project for mistaken paths (`/api/auth/forgot`, etc.) — none should exist pre-wire.

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/core/constants/api_constants.dart` | Add 3 forgot-password path constants + contract comment |

---

## Acceptance Criteria

- [ ] `ApiConstants.forgotPasswordRequestOtp` equals `/api/forgot-password/request-otp`.
- [ ] `ApiConstants.forgotPasswordVerifyOtp` equals `/api/forgot-password/verify-otp`.
- [ ] `ApiConstants.forgotPasswordReset` equals `/api/forgot-password/reset`.
- [ ] Comment/doc notes verify body uses `otpCode`, not `otp`.
- [ ] `flutter analyze` — zero new issues in `api_constants.dart`.

---

## Manual Test Steps

1. Temporarily log or breakpoint-read the three constants in a debug build — values match the API contract table in `plan.md`.
2. (Optional) With backend running, use Postman/curl against `POST {baseUrl}/api/forgot-password/request-otp` with `{"email":"known@test.com"}` — confirm 200 and neutral `message` in JSON.

---

## Dependencies

None. Prerequisite for Phase 2.

---

## Test Suggestions

- Trivial unit test: `expect(ApiConstants.forgotPasswordVerifyOtp, '/api/forgot-password/verify-otp')`.
