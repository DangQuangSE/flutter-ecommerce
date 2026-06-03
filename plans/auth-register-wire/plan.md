# Plan: Flutter Register → Spring Boot OTP Auth Wire-Up
Status: 🟢 Implemented (pending manual E2E)
Date: 2026-06-03
Mode: Hard

## Overview
Connect the existing Flutter `RegisterPage` to the real Spring Boot OTP-based registration flow (`/api/auth/register/request-otp` → `/api/auth/verify-otp` → `/api/auth/register`). Introduces a dedicated `OtpVerificationPage`, replaces all mocked auth logic with live Dio calls, and corrects broken API constants and routing.

---

## User Stories

### P1 — Must Have (core register flow)
- **US-1**: As a new user, I can enter my email on the Register page and receive a 6-digit OTP by email, so I can verify my identity before creating an account.
- **US-2**: As a new user, I can enter the 6-digit OTP on a dedicated verification page, so the backend confirms my email ownership.
- **US-3**: As a new user, after OTP is verified I can submit my password and have my account created, then be redirected to the Login page with a success message.

### P2 — Should Have (resilience + UX)
- **US-4**: As a user who did not receive the OTP, I can tap "Resend OTP" (with a 60-second cooldown) so I am not locked out of registration.
- **US-5**: As a user, I see clear inline error messages for API errors (email already exists 409, invalid OTP 400, rate-limited 429, network failure) so I know what went wrong and how to fix it.
- **US-6**: As a user, all loading states (OTP request, OTP verify, register submit) show a spinner and disable the submit button so I don't submit twice.

### P3 — Nice to Have (polish)
- **US-7**: As a user, the Name field I filled on Register page is preserved in my session for a personalised welcome on the Login page after registration (name is not sent to the backend).
- **US-8**: As a developer, `baseUrl` is configurable via `--dart-define=BASE_URL=...` so the app can target emulator, device, or staging without rebuilding.

---

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-03
**Phase in progress:** Phase 4 (manual E2E)
**Status:** Code complete; run backend + emulator smoke test

### Decisions made this session
- Name field kept on UI only (not sent to backend)
- Post-register navigates to Login only (no auto-login)
- Default BASE_URL `http://10.0.2.2:8080` for Android emulator
- Dedicated `/register/otp` page with pinput

### Next immediate action
- `docker-compose up` in be-ecommerce, then full register flow on emulator

---

## Phases
- [x] Phase 1: API Config — Fix `ApiConstants`, add all OTP paths, wire `baseUrl` via dart-define
- [x] Phase 2: Data & Domain — Implement real datasource methods, repository methods, and four use cases (RequestOtp, VerifyOtp, Register, ResendOtp)
- [x] Phase 3: Presentation & OTP Flow — Add `OtpVerificationPage`, new bloc events/states, update `RegisterPage`, wire router route `/register/otp`
- [ ] Phase 4: Integration & Verification — End-to-end smoke test with running backend, error-path validation, DI wiring audit

---

## Story ↔ Phase Mapping

| Phase | P1 Stories | P2 Stories | P3 Stories |
|-------|-----------|-----------|-----------|
| Phase 1 | US-1 (foundation) | — | US-8 |
| Phase 2 | US-1, US-2, US-3 | US-4, US-5 | — |
| Phase 3 | US-1, US-2, US-3 | US-4, US-5, US-6 | US-7 |
| Phase 4 | US-1–3 (verify) | US-4–6 (verify) | US-7, US-8 (verify) |

---

## Research Summary
**Chosen approach:** Dedicated `OtpVerificationPage` at route `/register/otp`.

Rationale over the bottom-sheet alternative:
- Route isolation enables deep-linking and back-navigation with state preserved via `extra` parameter in `go_router`.
- Keeps `RegisterPage` widget tree clean; OTP pin input and resend timer live in their own widget.
- Reusable for future "forgot password" OTP verification with a different continuation action.
- No penalty — user already navigates away to verify; a new page is no more taps than a sheet.

Password is collected on the **`RegisterPage`** and passed forward as route extra (in-memory, not persisted). The `OtpVerificationPage` calls `VerifyOtp` then immediately calls `Register` with the held password, keeping the two-step sequence atomic from the user's perspective.

Post-registration navigates to `/login` (not `/home`) because the backend does **not** return a JWT on register — the user must login separately.

---

## Dependencies
- Spring Boot backend running on `localhost:8080` (docker-compose) — all four `/api/auth` endpoints must be reachable.
- `dio ^5.0.0`, `flutter_bloc`, `get_it`, `go_router ^14.0.0` — all already in `pubspec.yaml`; no new packages required.
- `pinput` package (or equivalent) — **must be added to `pubspec.yaml`** for the OTP pin-input widget in Phase 3.
- Phase 3 depends on Phase 1 (correct base URL) and Phase 2 (use cases in DI).
- Phase 4 depends on all prior phases and a live backend container.

---

## Risks

- **HIGH**: `AuthBloc` currently emits `AuthAuthenticated` on register — the router's `redirect` immediately sends the user to `/home`, bypassing the OTP page. Mitigation: introduce `AuthOtpRequested` and `AuthRegistrationSuccess` states, and add `/register/otp` to the `isGoingToAuth` set in the router redirect guard before touching the bloc.

- **HIGH**: `DioClient.BaseOptions.baseUrl` is hard-coded to the wrong dev domain. Emulator traffic to `localhost:8080` requires `10.0.2.2:8080`; physical devices need the LAN IP. Mitigation: use `--dart-define=BASE_URL` with sensible emulator default; document in README.

- **MEDIUM**: OTP state (email, verification status) lives only in bloc memory. If the user backgrounds the app during OTP entry and the process is killed, state is lost. Mitigation: consider persisting email to `SharedPreferences` in Phase 3 as a lightweight recovery. (Out of scope for P1; noted for follow-up.)

- **MEDIUM**: `AuthBloc` is a `LazySingleton` shared with the router's `refreshListenable`. Adding OTP states must not accidentally trigger the router redirect to `/login`. Mitigation: router redirect guard checks only `AuthAuthenticated` and `AuthUnauthenticated`; OTP intermediate states are transparent to it.

- **LOW**: The `name` field has no backend counterpart. Storing it in-memory via bloc state is sufficient for P3 (US-7 personalised welcome). No persistence risk.

- **LOW**: `pinput` package dependency — well-maintained, MIT, no native code; upgrade risk is minimal.

### Plan-review mitigations (2026-06-03)

- **HIGH**: `AuthOtpSent` re-emitted on resend must not double-navigate from `RegisterPage` — use a one-shot flag (`_hasNavigatedToOtp`) or listen only while `ModalRoute.of(context)?.isCurrent == true`.
- **HIGH**: `/register/otp` route `state.extra` null (deep link / hot restart) → redirect to `/register`.
- **HIGH**: If `verify-otp` succeeds but `register` fails (e.g. 409), show recovery CTA ("Đã có tài khoản — đăng nhập") instead of trapping the user on OTP page.
- **HIGH**: Router `redirect` must treat `AuthOtpSent` / `AuthRegistrationSuccess` as in-flow (return `null`) before unauthenticated → `/login` branch.
- **MEDIUM**: `AuthOtpSent` carries `password` in bloc state — override `toString()` to mask secrets in logs/observers.
