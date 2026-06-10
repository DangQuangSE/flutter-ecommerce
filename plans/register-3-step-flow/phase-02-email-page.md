# Phase 2: Email Page

**Phase:** 02 of 05
**Covers stories:** P1 (US-1, US-2, US-3), P2 (US-10), P3 (US-11)
**Testing:** Widget test for email validation, email-exists error display, and loading state

---

## Goal
Rework `RegisterPage` into an email-only step. The password field and all password-related state are removed. Submitting a valid email triggers OTP dispatch; a 409 response shows an inline "email already registered" error on the same page; success navigates to the OTP page passing only the email.

---

## Tasks
- [ ] Remove the password `TextFormField`, `_passwordController`, `_obscurePassword`, and their validators from `RegisterPage`.
- [ ] Update `_onSubmit` to dispatch `AuthOtpRequested` with email only (no password).
- [ ] Update the `BlocConsumer` listener: on `AuthOtpSent`, navigate to `AppRoutes.registerOtp` passing a `RegisterOtpExtra` with email only.
- [ ] Update the `BlocConsumer` builder: email API error now shows for both `AuthRegisterAccountExists` and `AuthError` states (same behaviour, just no password field to confuse layout).
- [ ] Update `RegisterOtpExtra` model to remove the `password` field (now carries email only).
- [ ] Keep the `_hasNavigatedToOtp` + `_hideBlocEmailError` guard pattern to prevent double-navigation and to clear the error on field edit.
- [ ] Update the submit button label if needed (currently "Đăng ký" — consider "Tiếp tục" to reflect the step progression).

---

## Files to Touch
- `lib/features/auth/presentation/pages/register_page.dart` — strip password field, update dispatch, update listener
- `lib/features/auth/presentation/models/register_otp_extra.dart` — remove `password` field

---

## Acceptance Criteria
- Typing a malformed email triggers the inline validator message before any button press (autovalidateMode already set to `onUserInteraction`).
- Submitting a valid email while the BLoC emits `AuthLoading` disables the button and shows the spinner.
- When the BLoC emits `AuthRegisterAccountExists`, the field border turns red and the error message "Email này đã được đăng ký..." appears below the field without navigating away.
- When the BLoC emits `AuthOtpSent`, the page navigates to `/register/otp` and the `RegisterOtpExtra` passed contains only `email` (no password field).
- `dart analyze` is clean for both touched files.

---

## Dependencies
- Phase 1 must be complete (`RegisterOtpExtra` removing `password` breaks the current OTP page compile — handled in Phase 3).

---

## Risks
- **`RegisterOtpExtra` change cascades to `OtpVerificationPage`**: removing `password` from the extra will cause a compile error in `otp_verification_page.dart` where `widget.extra.password` is used. Leave `OtpVerificationPage` broken until Phase 3 completes — do not try to fix it here.
