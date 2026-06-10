# Phase 3: OTP Page

**Phase:** 03 of 05
**Covers stories:** P1 (US-4, US-5, US-6), P2 (US-9, US-10), P3 (US-11)
**Testing:** Widget test for wrong-OTP inline error, resend cooldown, and navigation to password page on success

---

## Goal
Update `OtpVerificationPage` to be verify-only: correct OTP emits `AuthOtpVerified` (not `AuthRegistrationSuccess`), which navigates to the password page. Wrong OTP shows "OTP không hợp lệ" inline. Resend no longer carries a password argument. The page receives email from `RegisterOtpExtra` (now email-only after Phase 2).

---

## Tasks
- [ ] Remove all `widget.extra.password` references from `OtpVerificationPage` (the field no longer exists on the extra).
- [ ] Update `_onVerify` to dispatch `AuthOtpVerifyRequested` with email and OTP only (no password).
- [ ] Update `_onResend` to dispatch `AuthResendOtpRequested` with email only (no password).
- [ ] Update the `BlocConsumer` listener:
  - On `AuthOtpVerified` → navigate with `context.pushNamed(AppRoutes.registerPassword, extra: RegisterPasswordExtra(email: state.email))`.
  - On `AuthOtpSent` (resend success) → show "Mã OTP đã được gửi lại" snackbar and clear the PIN field (existing behaviour, keep as-is).
  - On `AuthError` → set `_inlineError` to `state.message` (existing behaviour, keep as-is; the message from `mapRegisterOtpFailureMessage` already returns "Mã OTP không đúng..." for wrong-OTP failures — update to return "OTP không hợp lệ" per the user requirement, see auth_error_messages update below).
  - Remove the `AuthRegistrationSuccess` handler (account creation no longer happens here).
  - Remove the `AuthRegisterAccountExists` handler (no longer reachable from this page).
- [ ] Update the back button to navigate to `AppRoutes.register` (already does this — verify it is correct).
- [ ] Update `auth_error_messages.dart`: in `mapRegisterOtpFailureMessage`, change **only** the `otp code is incorrect` / `invalid otp` branch to return `'OTP không hợp lệ'`. Leave expired, locked, rate-limit, and other branches unchanged.
- [ ] Create `RegisterPasswordExtra` model class (email-only) under `lib/features/auth/presentation/models/`.

---

## Files to Touch
- `lib/features/auth/presentation/pages/otp_verification_page.dart` — remove password refs, update dispatch, update listener states
- `lib/features/auth/presentation/utils/auth_error_messages.dart` — update wrong-OTP message string
- `lib/features/auth/presentation/models/register_password_extra.dart` — **new file**: email-only extra for password page

---

## Acceptance Criteria
- Entering a 6-digit wrong OTP causes the `_inlineError` to show "OTP không hợp lệ" below the PIN widget without navigating away.
- Entering the correct OTP dispatches verify and BLoC emits `AuthOtpVerified` (navigation to `/register/otp/password` is wired and verified in Phase 4).
- Tapping "Gửi lại mã OTP" dispatches `AuthResendOtpRequested` without a password; on `AuthOtpSent` response the snackbar appears and the PIN is cleared.
- The resend button is disabled during the 60-second cooldown and while loading.
- `dart analyze` is clean for all touched files.
- `AuthRegistrationSuccess` is no longer handled in this page's listener (verify by code search).

---

## Dependencies
- Phase 1 (BLoC changes) and Phase 2 (`RegisterOtpExtra` is email-only) must be complete.
- `AppRoutes.registerPassword` route name must be declared — can be added to `app_routes.dart` in this phase as a stub; the actual route builder is wired in Phase 4.

---

## Risks
- **"OTP không hợp lệ" wording**: the existing `auth_error_messages.dart` has a longer string. Changing it here also affects any other place that renders the OTP error — check there are no other listeners reading this message before changing.
