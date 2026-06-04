# Plan: Flutter Forgot-Password Flow Wire-Up
Status: 🟢 Implemented (pending manual E2E)
Date: 2026-06-04
Mode: Hard
Test: default (bloc + widget tests where practical; manual E2E in Phase 4)

## Overview
Wire the existing login "Quên mật khẩu?" link to a three-step forgot-password journey (email → OTP → new password) against the already-implemented Spring Boot `/api/forgot-password/*` endpoints. Uses a **dedicated `ForgotPasswordBloc`** and go_router routes — **does not extend `AuthBloc`** (register OTP remains on `AuthBloc` + `RegisterUseCase` chain).

---

## User Stories

### P1 — Must Have (core forgot-password flow)
- **US-1**: As a user on the login screen, I can tap "Quên mật khẩu?" and enter my email on a dedicated screen so I can start resetting my password.
- **US-2**: As a user, after submitting a valid email and a successful `request-otp` response, I am taken to an OTP screen (6-digit pin, same UX as register) so I can prove I received the code.
- **US-3**: As a user, after entering the correct OTP, I can set a new password (with confirm) and, on success, land on login with a success message so I can sign in with the new password.

### P2 — Should Have (resilience + UX)
- **US-4**: As a user who did not receive the OTP, I can tap "Gửi lại mã" (resend = `request-otp` again) with a 60-second client cooldown; server 429 shows the backend message.
- **US-5**: As a user, I see clear inline/snackbar errors for invalid OTP (400), expired OTP, locked attempts, invalid reset token, rate limit (429), and network failures.
- **US-6**: As a user, all submit actions show loading state and disable double-tap during API calls.

### P3 — Nice to Have (polish)
- **US-7**: As a user, copy on forgot-password screens is Vietnamese-friendly and consistent with register/login tone.
- **US-8**: As a developer, forgot-password flow state (`email`, `forgotPasswordToken`) lives only in bloc memory + route `extra` — never persisted to secure storage (reduces token leakage risk).

---

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-04
**Phase in progress:** Phase 4 (manual E2E)
**Status:** Code complete — smoke test with backend + emulator

### Decisions made this session
- User confirmed: neutral navigate to OTP, confirm password field (client only), min 6 chars, post-reset login only
- Dedicated `ForgotPasswordBloc` + `ShellRoute` for shared provider across 3 steps
- OTP verify errors normalized to single Vietnamese message (anti-enumeration)
- Resend = `request-otp` again with 60s client cooldown

### Next immediate action
- `docker-compose up` in be-ecommerce, then full forgot-password flow on emulator

---

## Phases
- [x] Phase 1: API Config — Add `/api/forgot-password/*` path constants (verify field names vs register OTP)
- [x] Phase 2: Data & Domain — Forgot-password datasource, repository, three use cases, DI registration
- [x] Phase 3: Presentation Flow — `ForgotPasswordBloc`, three pages, router + login link, route extras
- [ ] Phase 4: Integration & Verification — E2E with live backend, error paths, router/DI audit, regression on login/register

---

## Story ↔ Phase Mapping

| Phase | P1 Stories | P2 Stories | P3 Stories |
|-------|-----------|-----------|-----------|
| Phase 1 | US-1 (foundation) | — | — |
| Phase 2 | US-1–3 (network) | US-4–5 (errors) | US-8 |
| Phase 3 | US-1–3 (UI flow) | US-4–6 | US-7 |
| Phase 4 | US-1–3 (verify) | US-4–6 (verify) | US-7–8 (verify) |

---

## Research Summary

**Chosen approach:** Dedicated `ForgotPasswordBloc` under `lib/features/auth/forgot_password/` with three sibling go_router routes (mirror register nesting):

| Route | Screen |
|-------|--------|
| `/forgot-password` | Email entry |
| `/forgot-password/otp` | OTP (pinput; dedicated page bound to `ForgotPasswordBloc`) |
| `/forgot-password/reset` | New password + confirm |

Use a **`ShellRoute`** whose builder wraps `child` in `BlocProvider(create: (_) => sl<ForgotPasswordBloc>())` so OTP and reset pages share one bloc instance. Nested `GoRoute` child builders do **not** inherit a parent route’s `BlocProvider` (unlike register, which uses the `AuthBloc` DI singleton).

**Why not extend `AuthBloc`:** Register verify chains to `RegisterUseCase` inside `AuthBloc`; mixing forgot-password token/password reset would widen auth state surface and risk router `refreshListenable` side effects. Forgot flow is orthogonal to session login.

**Neutral `request-otp` response (security UX tradeoff):** Backend always returns success message `"If your email exists in our system, an OTP has been sent"` whether or not the email exists (`ForgotPasswordService.requestOtp`). Client **cannot** detect account enumeration. **Product decision:** Navigate to OTP when (a) client-side email format is valid and (b) HTTP call succeeds (2xx). Show the backend `message` on the OTP screen as informational copy. Document in code comment on email page listener.

**Resend:** Call `POST /request-otp` again (not a separate resend endpoint). Client enforces 60s cooldown; server may return 429 `OTP_REQUEST_TOO_FREQUENT`.

**OTP field name:** Forgot-password verify uses `otpCode` in JSON; register verify uses `otp` — do not reuse register datasource methods blindly.

**Post-reset:** `context.goNamed(AppRoutes.login)` + snackbar (e.g. "Đặt lại mật khẩu thành công. Vui lòng đăng nhập.") — no auto-login (reset does not return JWT).

**Reuse:** Visual/UX patterns from `OtpVerificationPage` (pinput, 60s timer, masked email) but **new** `ForgotPasswordOtpPage` wired to `ForgotPasswordBloc`.

---

## API Contract Table

Base URL: `ApiConstants.baseUrl` (existing `--dart-define=BASE_URL`).

| Step | Method | Path | Request body | Success response | Notes |
|------|--------|------|--------------|------------------|-------|
| 1. Request OTP | `POST` | `/api/forgot-password/request-otp` | `{ "email": string }` | `ApiResponse<Void>` — `message` neutral, `data: null` | Always 2xx for valid email format even if user missing; 429 if cooldown |
| 2. Verify OTP | `POST` | `/api/forgot-password/verify-otp` | `{ "email": string, "otpCode": string }` | `data.forgotPasswordToken`, `data.message` | 400: wrong/expired/locked OTP |
| 3. Reset password | `POST` | `/api/forgot-password/reset` | `{ "forgotPasswordToken": string, "newPassword": string }` | `message` success, `data: null` | Email derived server-side from token only |

**Security notes for implementors:**
- Never send `email` on reset — only `forgotPasswordToken` + `newPassword`.
- Do not persist `forgotPasswordToken` in `SharedPreferences` / secure storage.
- Pass token via bloc state + `ForgotPasswordResetExtra` on route navigation.

---

## Dependencies
- Spring Boot backend running (`docker-compose up` in `be-ecommerce`); `/api/forgot-password/**` permitted in `SecurityConfig` (already done).
- Existing: `dio`, `flutter_bloc`, `get_it`, `go_router`, `pinput` (from register wire-up).
- Phase 3 depends on Phases 1–2; Phase 4 depends on all prior phases + live backend + test mailbox for OTP.

---

## Risks

- **HIGH**: Reusing register `verifyOtp` body key (`otp` vs `otpCode`) causes silent 400s. **Mitigation:** Phase 1 checklist + dedicated forgot-password datasource methods with explicit JSON keys.

- **HIGH**: Extending `AuthBloc` for forgot flow triggers router redirect when intermediate states emit. **Mitigation:** Dedicated `ForgotPasswordBloc` as `registerFactory`; router `refreshListenable` stays on `AuthBloc` only.

- **HIGH**: User expects OTP only if email exists — neutral API always navigates to OTP on success. **Mitigation:** Document tradeoff in plan + inline comment; show backend neutral message on OTP screen; invalid emails still fail client validation only.

- **MEDIUM**: Route `extra` null on deep link / hot restart loses `email` / token. **Mitigation:** Redirect `/forgot-password/otp` and `/forgot-password/reset` → `/forgot-password` when `extra` invalid; bloc re-hydrate from `extra` on push.

- **MEDIUM**: 429 on resend while client timer still running — show server message, do not crash. **Mitigation:** Map `ServerFailure` in bloc; keep timer UX.

- **LOW**: Duplicate OTP UI maintenance vs register page. **Mitigation:** Extract shared pin theme widget later (out of scope P1).

- **HIGH**: Verify OTP returns distinct BE messages for no OTP record vs wrong code (`Invalid OTP` vs `OTP code is incorrect`). **Mitigation:** Client `mapForgotPasswordOtpFailure()` — one generic Vietnamese message for all verify failures.

- **MEDIUM**: Neutral navigate → unregistered emails reach OTP but never receive mail; verify always fails. **Mitigation:** OTP screen helper copy: *"Nếu bạn không nhận được mã, kiểm tra email hoặc quay lại."*

- **MEDIUM**: Resend 429 only applies when email exists in DB. **Mitigation:** Scope 429 tests to registered emails only.

### Plan-review checklist (pre-cook)
- [x] Login `onTap` on "Quên mật khẩu?" → `context.pushNamed(AppRoutes.forgotPassword)`
- [x] `isGoingToAuth` includes all three forgot paths (`path.startsWith('/forgot-password')`)
- [x] Authenticated user hitting forgot routes → redirect home/admin
- [x] `ForgotPasswordBloc` / extras `toString` masks token/password fields
