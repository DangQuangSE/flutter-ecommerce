# Phase 4: Integration & Verification

## Goal
Validate forgot-password end-to-end against the live Spring Boot backend, exercise error paths (429, bad OTP, invalid token), audit DI/router guards, and confirm **no regressions** on login, register OTP, or session redirect behavior.

**Delivers:** Verification of US-1 through US-8 in a running system.

---

## Tasks

- [ ] **4.1 — DI audit**: Confirm forgot-password datasource, repository, three use cases, and `ForgotPasswordBloc` factory in `injection_container.dart`. Cold start — no `GetIt` registration errors.
- [ ] **4.2 — Happy-path E2E (emulator)**: Backend up → login → forgot → email (known user) → OTP from email → reset → login with new password. Capture screenshots or short recording for PR.
- [ ] **4.3 — Error-path validation**:
  - Wrong OTP → 400 inline message on OTP screen (same message for unknown email vs wrong code — no enumeration).
  - Expired OTP (wait or use old code) → expiry message.
  - Resend spam → 429 message when server rejects (**registered email only** — unknown emails always get 200 on resend).
  - Reset with tampered/empty token → 400, user can navigate back to start.
  - Airplane mode mid-flow → network message, no crash.
  - Non-existent email (valid format) → still reaches OTP; document that no email arrives (neutral API behavior).
- [ ] **4.4 — Login/register regression**: Login still works; register OTP flow still uses `AuthBloc` and `/register/otp`; authenticated user cannot stay on forgot routes.
- [ ] **4.5 — Router guard audit**: Unauthenticated `/forgot-password/*` not redirected to login; authenticated user on forgot paths redirected to home/admin; `AuthBloc` OTP states still bypass erroneous redirect; OTP/reset pages resolve `ForgotPasswordBloc` without `ProviderNotFoundException`.
- [ ] **4.6 — Security checklist**: `forgotPasswordToken` not written to `SharedPreferences` / secure storage; grep for accidental persistence.
- [ ] **4.7 — `flutter analyze` + `flutter test`**: Full project analyze clean; run existing + new bloc/widget tests from Phases 2–3.

---

## Files to Touch

No new feature files expected. Fixes only if audit finds gaps:

| File | Possible change |
|------|-----------------|
| `lib/core/di/injection_container.dart` | Missing registration |
| `lib/app/router/app_router.dart` | `isGoingToAuth` / redirect gap |
| Forgot-password bloc/pages | Runtime crash or unhandled state |
| `README.md` | Optional: forgot-password manual test section |

---

## Acceptance Criteria

- [ ] Cold start with backend: no `GetIt` exceptions.
- [ ] Happy-path E2E completes: password changed in DB, login succeeds with new password.
- [ ] Error branches in 4.3 show correct Vietnamese-friendly messages without crashing.
- [ ] Login and register flows unchanged (smoke test both).
- [ ] No token persistence in local storage (grep/manual inspection).
- [ ] `flutter analyze` — zero new errors/warnings from this feature.
- [ ] `flutter test` — all tests pass (including new forgot-password tests if added).

---

## Manual Test Steps

| # | Scenario | Expected |
|---|----------|----------|
| 1 | Full happy path (existing user) | Reset success → login snackbar → login OK |
| 2 | Full flow with unknown email (valid format) | Reaches OTP; no email; no app crash; user can back out |
| 3 | Wrong OTP ×3+ | Lock/invalid message per backend |
| 4 | Resend after 60s | New OTP received (existing user) |
| 5 | Resend too fast (server, **existing user**) | 429 message displayed |
| 6 | Back from OTP to email | Email field editable; can resubmit |
| 7 | After reset, press back | Does not expose reset form with stale token (redirect or login) |
| 8 | Logged-in user opens `/forgot-password` | Redirect to home/admin |
| 9 | Register new user E2E | Still works independently |

---

## Dependencies

- Phases 1–3 complete.
- Backend at `http://10.0.2.2:8080` (emulator) or LAN IP via `--dart-define`.
- SMTP/test inbox for OTP delivery on happy path.

---

## Test Suggestions

- **Integration test** (optional): Script tap flow email → OTP → reset on emulator with test backend.
- **Manual artefact for PR**: Login → forgot email → OTP → reset → login success (4 screenshots).
- Re-run register happy path once to prove `AuthBloc` isolation.
