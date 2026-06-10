# Plan: Registration 3-Step Flow Refactor
Status: 🟢 Implemented
Date: 2026-06-10
Mode: Hard

## Overview
Refactor the single-page registration into a clean 3-step flow: Email → OTP → Password.
The password field is removed from early steps and only collected on the final step, eliminating premature state coupling between OTP verification and account creation.

---

## User Stories

### P1 — Core Flow (must ship)
- **US-1** As a new user, I can enter my email on a dedicated page and immediately see a format validation error if the email is malformed, without needing to submit.
- **US-2** As a new user, after I submit a valid email, the system checks whether that email is already registered; if it is, I see "Email này đã được đăng ký" on the same page.
- **US-3** As a new user, after a valid unregistered email is submitted, an OTP is sent and I am taken to the OTP verification page.
- **US-4** As a new user on the OTP page, if I enter a wrong code, I see "OTP không hợp lệ" inline (no navigation away).
- **US-5** As a new user on the OTP page, I can request a resend; the button enters a 60-second cooldown and shows a success snackbar.
- **US-6** As a new user, after entering the correct OTP, I am taken to the password setup page (OTP page no longer triggers account creation).
- **US-7** As a new user on the password page, I enter a password and confirm it; a mismatch shows "Mật khẩu xác nhận không khớp" inline.
- **US-8** As a new user, after submitting valid passwords, the account is created and I am redirected to the login page with a success snackbar.

### P2 — Guard & Navigation (must ship)
- **US-9** As a user who navigates directly to `/register/otp` or `/register/otp/password` without prior context, I am redirected back to `/register` (deep-link guard).
- **US-10** As a user on the OTP or password page, the back button navigates to the previous step (not pop-to-root).

### P3 — Polish (nice-to-have)
- **US-11** The OTP page shows the masked email address in its subtitle, sourced from the new email-only `RegisterOtpExtra`.
- **US-12** The password page shows the same branding header (Sport Pro italic) as the email page for visual consistency.

---

## Phases
- [x] Phase 1: BLoC State & Event Refactor — Remove password coupling from OTP events/states; add `AuthOtpVerified` state and `AuthRegisterPasswordSubmitted` event
- [x] Phase 2: Email Page — Rework `RegisterPage` to email-only form; move password field removal; handle email-exists error display
- [x] Phase 3: OTP Page — Detach registration call; wire verify-only path to `AuthOtpVerified`; update resend to drop password
- [x] Phase 4: Password Page & Router — Build `RegisterPasswordPage`; add `/register/otp/password` route with deep-link guard
- [x] Phase 5: Integration & Verification — Unit tests for error messages; backend docs updated

---

## Research Summary
Primary approach chosen: **Extend AuthBloc, no backend changes**.

- Reuse `POST /api/auth/register/request-otp` — atomic email-check + OTP send; 409 = email exists.
- `POST /api/auth/verify-otp` — OTP verification only (no password needed).
- `POST /api/auth/register` — account creation on password step.
- `POST /api/auth/resend-otp` — resend without password.

Alternative (RegisterBloc + ShellRoute) was rejected: adds ~8 new files with no net architectural gain since all use cases are already wired into AuthBloc.

---

## Dependencies
- All backend endpoints already implemented (no backend changes required).
- `pinput` package already installed.
- `go_router` ≥ 6.x already in use — sub-route redirect guards available.

---

## Risks
- HIGH: Router redirect logic currently whitelists `AuthOtpSent` and `AuthRegistrationSuccess` states to prevent forced redirect to `/login`; the new `AuthOtpVerified` state must be added to the same whitelist or the password page will be immediately ejected — **Mitigation:** update the `redirect` callback in `app_router.dart` as part of Phase 4 before wiring the new page.
- MEDIUM: `AuthResendOtpRequested` and `AuthOtpSent` state currently carry `password`; any call site that reads `state.password` after this refactor will break at compile time — **Mitigation:** Phase 1 removes the field early; compiler errors surface all affected call sites before UI work begins.
- LOW: The `_hasNavigatedToOtp` guard in `RegisterPage` prevents double-navigation on `AuthOtpSent`; the new email page must keep an equivalent guard — **Mitigation:** carry the guard pattern forward verbatim into the refactored email page.
- NOTED: Back navigation from password page to OTP may show a stale OTP screen; backend OTP is single-use after verify — confirm re-verify + resend behavior is acceptable for v1.

---

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-10
**Phase in progress:** Complete
**Status:** All 5 phases implemented; auth tests pass (6/6)

### Decisions made this session
- Nút bước 1 giữ label "Đăng ký"
- Thông báo email tồn tại: giữ chuỗi hiện tại
- Back từ trang mật khẩu → `/register` (trang email), không về OTP
- Mật khẩu tối thiểu 6 ký tự
- Cập nhật cả Flutter và `be-ecommerce/docs/auth-user/auth_login_register_otp.md`

### Next immediate action
- Manual E2E: đăng ký email mới qua 3 bước trên thiết bị/emulator

- Forgot-password flow (`ForgotPasswordBloc` + `ShellRoute`) is the reference pattern for multi-step auth UI.
- `forgot_password_reset_page.dart` is the visual reference for `RegisterPasswordPage`.
- `auth_error_messages.dart` already has the correct Vietnamese strings for wrong OTP and email-exists errors; only the inline display location changes (OTP page inline vs snackbar).
- `RegisterOtpExtra` needs `password` field removed; a new `RegisterPasswordExtra` (email only, or email + verified token if backend adds one later) is needed for the password page.
