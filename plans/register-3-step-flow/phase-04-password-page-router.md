# Phase 4: Password Page & Router

**Phase:** 04 of 05
**Covers stories:** P1 (US-7, US-8), P2 (US-9, US-10), P3 (US-12)
**Testing:** Widget test for password mismatch, successful submit → login redirect, and deep-link guard redirect

---

## Goal
Build `RegisterPasswordPage` (modelled on `forgot_password_reset_page.dart`) and wire it into the router as `/register/password`. Add a redirect guard so direct deep-link access without a valid `RegisterPasswordExtra` bounces back to `/register`. Add `AuthOtpVerified` to the router's state whitelist so the page is not ejected mid-flow.

---

## Tasks
- [ ] Create `RegisterPasswordPage` as a `StatefulWidget` accepting `RegisterPasswordExtra` (email):
  - Two password fields: "MẬT KHẨU" and "XÁC NHẬN MẬT KHẨU".
  - Client-side validator: passwords must match; minimum 6 characters.
  - On submit, dispatch `AuthRegisterPasswordSubmitted` with email + password.
  - `BlocConsumer` listener:
    - `AuthRegistrationSuccess` → show "Đăng ký thành công! Vui lòng đăng nhập." snackbar, then `context.goNamed(AppRoutes.login)`.
    - `AuthError` → show inline error below the confirm-password field.
  - Back button navigates to `AppRoutes.registerOtp` (or pop) — note this re-enters OTP page; acceptable since the flow is linear.
  - Branding header (Sport Pro italic) reused from `RegisterPage` for visual consistency (P3 US-12).
- [ ] Add `static const String registerPassword = 'registerPassword'` to `app_routes.dart`.
- [ ] Update the existing `/register/otp` route guard: replace the builder-fallback (`if extra is! RegisterOtpExtra → RegisterPage`) with a `redirect:` callback (same pattern as `/forgot-password/otp`).
- [ ] Add `AppRoutes.registerPassword` route in `app_router.dart` as a sub-route of `/register/otp`:
  - Path: `password` → full path `/register/otp/password`.
  - `redirect` guard: if `state.extra is! RegisterPasswordExtra` → return `/register`.
  - Builder: `RegisterPasswordPage(extra: state.extra as RegisterPasswordExtra)`.
- [ ] Add `AuthOtpVerified` to the router redirect whitelist (alongside `AuthOtpSent` and `AuthRegistrationSuccess`) so a user on the password page is not redirected to `/login`.
- [ ] Update the router `isGoingToAuth` path list to include `/register/otp/password`.

---

## Files to Touch
- `lib/features/auth/presentation/pages/register_password_page.dart` — **new file**: password + confirm fields, submit to BLoC
- `lib/app/router/app_routes.dart` — add `registerPassword` constant
- `lib/app/router/app_router.dart` — add sub-route, redirect guard, whitelist `AuthOtpVerified`

---

## Acceptance Criteria
- Navigating to `/register/otp/password` without `RegisterPasswordExtra` in `extra` redirects to `/register`.
- On the password page, entering mismatched passwords shows "Mật khẩu xác nhận không khớp" inline without submitting.
- On the password page, a successful submit dispatches `AuthRegisterPasswordSubmitted` → BLoC emits `AuthRegistrationSuccess` → snackbar appears and the router navigates to `/login`.
- A user currently on the password page (BLoC in `AuthOtpVerified` state) is NOT redirected away by the router refresh listener.
- `dart analyze` is clean for all touched files.

---

## Dependencies
- Phases 1–3 must be complete and compile cleanly.
- `RegisterPasswordExtra` model must exist (created in Phase 3).

---

## Risks
- **Router whitelist ordering**: the existing `redirect` callback checks `authState is AuthOtpSent || authState is AuthRegistrationSuccess` before the `isAuthenticated` check. Adding `AuthOtpVerified` to this same guard is critical — missing it will cause the page to flash and redirect to `/login` on every auth stream event.
- **Back navigation from password page**: navigating back with `context.pop()` will pop to the OTP page which still holds the verified email. The user will see a "stale" OTP page; entering a new OTP will re-verify and re-navigate forward. This is acceptable UX for v1.
