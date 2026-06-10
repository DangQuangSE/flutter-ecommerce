# Phase 5: Integration & Verification

**Phase:** 05 of 05
**Covers stories:** P1 (all US-1–US-8), P2 (US-9, US-10), P3 (US-11, US-12)
**Testing:** End-to-end manual walkthrough + widget tests for all three pages

---

## Goal
Verify the complete 3-step registration flow works end-to-end on a real device/emulator, confirm all error paths display correct Vietnamese copy, and ensure no compile warnings or analyzer errors remain. Write or update widget tests to cover the main state transitions on each page.

---

## Tasks
- [ ] Run `dart analyze` on the entire `lib/` directory — resolve any remaining errors or warnings.
- [ ] **Happy path walkthrough**: fresh email → OTP received → correct OTP → password set → redirected to login page with success snackbar.
- [ ] **Error path — email exists**: enter a known registered email → confirm "Email này đã được đăng ký..." appears inline; field border turns red; no navigation occurs.
- [ ] **Error path — wrong OTP**: submit an incorrect OTP → confirm "OTP không hợp lệ" appears inline below the PIN widget; PIN input remains editable.
- [ ] **Error path — password mismatch**: enter mismatched passwords on the password page → confirm inline error appears; submit button stays disabled.
- [ ] **Deep-link guard**: navigate directly to `/register/otp` and `/register/otp/password` without extras → confirm redirect to `/register`.
- [ ] **Resend cooldown**: tap "Gửi lại mã OTP" → confirm button disables for 60 seconds; confirm resend success snackbar appears.
- [ ] Write/update widget tests:
  - `register_page_test.dart`: email format validation, email-exists BLoC state shows inline error, `AuthOtpSent` triggers navigation.
  - `otp_verification_page_test.dart`: `AuthError` state shows inline OTP error, `AuthOtpVerified` triggers navigation to password page, resend dispatches correct event.
  - `register_password_page_test.dart`: password mismatch validator, `AuthRegistrationSuccess` triggers navigation to login, `AuthError` shows inline error.
- [ ] Clean up any dead imports or unused variables introduced during the refactor.

---

## Files to Touch
- `test/features/auth/presentation/pages/register_page_test.dart` — update or create
- `test/features/auth/presentation/pages/otp_verification_page_test.dart` — update or create
- `test/features/auth/presentation/pages/register_password_page_test.dart` — **new**
- Any file flagged by `dart analyze`

---

## Acceptance Criteria
- `dart analyze lib/` exits with 0 issues.
- All three widget test files pass with `flutter test`.
- Manual happy-path produces a real account (confirmed via backend or dev DB inspection).
- All Vietnamese error strings match the user requirements exactly:
  - Email exists → "Email này đã được đăng ký. Vui lòng đăng nhập hoặc dùng email khác."
  - Wrong OTP → "OTP không hợp lệ"
  - Password mismatch → "Mật khẩu xác nhận không khớp"
  - Registration success snackbar → "Đăng ký thành công! Vui lòng đăng nhập."
- No `password` field remains on `RegisterOtpExtra` or in `AuthOtpRequested` / `AuthResendOtpRequested` / `AuthOtpSent` (verify via code search).

---

## Dependencies
- Phases 1–4 must all be complete and individually compile-clean.

---

## Risks
- **Test environment OTP**: if the test environment does not deliver real emails, the happy-path walkthrough must use a seeded/hardcoded OTP or a test bypass; coordinate with the backend if needed.
- **GoRouter test setup**: widget tests involving navigation require a `GoRouter` or `MockGoRouter` wrapper — use the existing pattern from `login_page_test.dart` (if present) as a template.
