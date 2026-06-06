# Phase 3: Presentation Flow

## Goal
Ship the user-visible three-step forgot-password journey: dedicated bloc, three pages, go_router routes with route extras, and wire login "Quên mật khẩu?" — matching register visual language but isolated from `AuthBloc`.

**Delivers:** US-1–7 in UI; US-6 loading states; security UX per research (navigate to OTP on successful request + valid email).

---

## Tasks

- [ ] **3.1 — Route extras models**: `ForgotPasswordOtpExtra(email, neutralMessage)` — pass backend message from `requestOtp`, `ForgotPasswordResetExtra(email, forgotPasswordToken)` — immutable, no persistence.
- [ ] **3.2 — ForgotPasswordBloc**: Sealed events/states, e.g.:
  - Events: email submitted, OTP submitted, resend requested, reset submitted.
  - States: initial, loading, otp sent (email + `neutralMessage`), otp verified (email + token), success, error(message).
  - Mask secrets in `toString`.
- [ ] **3.3 — Email page** (`ForgotPasswordEmailPage`): Title "Quên mật khẩu?", subtitle hướng dẫn nhập email, email field + validator (format), CTA "Tiếp tục". On success → navigate to OTP with extra; show snackbar/inline with backend `message` if available. **Comment** documenting neutral-response navigation policy.
- [ ] **3.4 — OTP page** (`ForgotPasswordOtpPage`): Reuse pinput layout from `OtpVerificationPage` — heading "Nhập mã OTP", masked email, show `neutralMessage` from extra, helper *"Nếu bạn không nhận được mã, kiểm tra email hoặc quay lại."*, 6-digit pin, "Xác nhận", "Gửi lại mã" + 60s timer. Resend dispatches request-otp again. Add `mapForgotPasswordOtpFailure()` — **never** surface raw BE strings separately (`Invalid OTP` vs `OTP code is incorrect`); one generic Vietnamese inline error for all verify failures. Start cooldown on enter.
- [ ] **3.5 — Reset page** (`ForgotPasswordResetPage`): New password + confirm fields; validate match + min length; submit reset use case. On success → `goNamed(login)` + snackbar "Đặt lại mật khẩu thành công. Vui lòng đăng nhập."
- [ ] **3.6 — Router**: Add **`ShellRoute`** wrapping all forgot steps: `BlocProvider(create: (_) => sl<ForgotPasswordBloc>(), child: child)`. Child routes: `/forgot-password` (email), `/forgot-password/otp`, `/forgot-password/reset`; names in `AppRoutes`. Null/invalid `extra` → **redirect** to `/forgot-password` (prefer redirect over inline fallback for token-bearing routes). Add all three paths to `isGoingToAuth`. Authenticated users → `/home` or `/admin`.
- [ ] **3.7 — BlocProvider scope**: Lives in **`ShellRoute` builder only** — not on individual page widgets.
- [ ] **3.8 — Login link**: Replace `onTap: () {}` on "Quên mật khẩu?" with `context.pushNamed(AppRoutes.forgotPassword)` (or `go` per UX preference — `push` preserves back to login).
- [ ] **3.9 — Back navigation**: System back from OTP → email; from reset → OTP only if token still in bloc/extra; otherwise email.

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/auth/forgot_password/presentation/bloc/forgot_password_bloc.dart` | New |
| `lib/features/auth/forgot_password/presentation/bloc/forgot_password_event.dart` | New |
| `lib/features/auth/forgot_password/presentation/bloc/forgot_password_state.dart` | New |
| `lib/features/auth/forgot_password/presentation/pages/forgot_password_email_page.dart` | New |
| `lib/features/auth/forgot_password/presentation/pages/forgot_password_otp_page.dart` | New |
| `lib/features/auth/forgot_password/presentation/pages/forgot_password_reset_page.dart` | New |
| `lib/features/auth/forgot_password/presentation/models/forgot_password_otp_extra.dart` | New |
| `lib/features/auth/forgot_password/presentation/models/forgot_password_reset_extra.dart` | New |
| `lib/app/router/app_router.dart` | Routes + `isGoingToAuth` + `BlocProvider` |
| `lib/app/router/app_routes.dart` | `forgotPassword`, `forgotPasswordOtp`, `forgotPasswordReset` |
| `lib/features/auth/presentation/pages/login_page.dart` | Wire forgot link |
| `lib/core/di/injection_container.dart` | `registerFactory<ForgotPasswordBloc>(...)` |
| `lib/features/auth/forgot_password/presentation/utils/forgot_password_error_messages.dart` | New — OTP verify error normalization |

**Do not modify** (unless fixing unrelated bug): `auth_bloc.dart`, `otp_verification_page.dart` register flow.

---

## Acceptance Criteria

- [ ] Tap "Quên mật khẩu?" on login opens email screen (Vietnamese copy).
- [ ] Valid email + successful `request-otp` navigates to OTP screen even when email may not exist (neutral API); OTP screen may show informational text from backend message.
- [ ] Correct OTP navigates to reset screen; bloc holds `forgotPasswordToken` only in memory.
- [ ] Matching new passwords + successful reset lands on login with success snackbar (Vietnamese).
- [ ] Wrong OTP shows inline error (not silent failure).
- [ ] Resend triggers `request-otp` again; button disabled 60s; 429 shows server message without crash.
- [ ] Loading states disable primary buttons on all three screens.
- [ ] Hot restart / direct URL to `/forgot-password/otp` without extra redirects to email step.
- [ ] `flutter analyze` — zero new errors.

---

## Manual Test Steps

1. Login screen → "Quên mật khẩu?" → email page displayed.
2. Enter invalid email format → inline validation, no API call.
3. Enter valid email (existing user) → OTP page; check email for OTP.
4. Enter wrong OTP → error message visible; pin can be retried.
5. Enter correct OTP → reset page with two password fields.
6. Mismatch confirm → validation error, no API call.
7. Valid reset → login screen + snackbar "Đặt lại mật khẩu thành công...".
8. Login with new password works.
9. Enter valid format email **not** in system → still reaches OTP (neutral API); verify no crash (user may never get email — expected tradeoff).
10. Resend within 60s → button disabled; after 60s resend works or 429 message if server rejects.

---

## Dependencies

- Phases 1–2 complete.
- `pinput` already in `pubspec.yaml`.

---

## Test Suggestions

- **Bloc tests**: Email success → `[Loading, OtpSent]`; verify success → token state; reset success → terminal success state.
- **Widget — email page**: Tap continue with invalid email → no navigation; mock bloc success → `goNamed(forgotPasswordOtp)`.
- **Widget — OTP page**: 6 digits → verify event; resend → request OTP event + timer disabled.
- **Router**: Forgot paths in `isGoingToAuth`; unauthenticated access allowed.
