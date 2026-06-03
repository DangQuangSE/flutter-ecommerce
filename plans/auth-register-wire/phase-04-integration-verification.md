# Phase 4: Integration & Verification

## Goal
Validate the complete OTP registration flow end-to-end against the live Spring Boot backend, verify all error paths behave correctly under real network conditions, confirm DI wiring is complete, and ensure no regressions in the existing login flow or router redirect logic.

**Delivers:** Verification of US-1 through US-8 in a running system.

---

## Tasks

- [ ] **4.1 — DI audit**: Grep `injection_container.dart` and confirm all four new use cases are registered and `AuthBloc` factory injects them. Run `flutter run` cold-start; verify no `GetIt` "not registered" exceptions in the console.

- [ ] **4.2 — Happy-path E2E (emulator)**: With the Spring Boot container running (`docker-compose up`), run the app on an Android emulator. Walk through: enter name + email + password → receive OTP email → enter OTP → confirm navigation to Login page with success snack-bar. Capture a screen recording or annotated screenshots for the PR.

- [ ] **4.3 — Error-path validation**: Manually (or via integration test) trigger each error branch:
  - Submit register with an email that already exists → expect 409 error message on Register page.
  - Submit wrong OTP → expect 400 error message inline on OTP page.
  - Submit OTP after it has expired → expect expiry error message.
  - Tap Resend before 60s cooldown expires → button must remain disabled (UI-only, no network call).
  - Kill network mid-flow → expect `NetworkFailure` message and no crash.
  - Verify OTP succeeds but register returns 409 → recovery CTA navigates to Login.

- [ ] **4.4 — Login regression check**: Confirm existing login flow (mock admin user path + real login path if backend supports it) still works after all bloc/DI changes. The `AuthAuthenticated` state must still trigger router redirect to `/home` or `/admin`.

- [ ] **4.5 — Router guard audit**: Confirm that:
  - An unauthenticated user accessing `/register/otp` directly is **not** redirected (it's in `isGoingToAuth`).
  - An authenticated user navigating to `/register` or `/register/otp` is redirected to `/home`.
  - `AuthOtpSent` and `AuthRegistrationSuccess` states do **not** accidentally trigger the router's `refreshListenable` to redirect.

- [ ] **4.6 — `flutter analyze` full pass**: Run `flutter analyze` on the entire project. Fix any warnings introduced by this feature. Do not suppress warnings with `// ignore` unless the suppression is justified in a comment.

- [ ] **4.7 — Physical device smoke (optional P3)**: If a physical Android device is available, run with `--dart-define=BASE_URL=http://<LAN_IP>:8080` and verify the full happy path. Documents that dart-define configuration works (US-8).

---

## Files to Touch

No new source files in this phase. Potential edits only:

| File | Possible Change |
|------|----------------|
| `lib/core/di/injection_container.dart` | Fix any missing registrations found in 4.1 |
| `lib/app/router/app_router.dart` | Fix any redirect guard gap found in 4.5 |
| Any bloc/page file | Fix any runtime crash or unhandled state found during 4.2–4.3 |
| `README.md` | Add docker-compose startup steps and dart-define examples |

---

## Acceptance Criteria

- [ ] Cold-start app with backend running: no `GetIt` exceptions, app reaches `/login` or `/home` correctly.
- [ ] Happy-path E2E completes without errors: new account is created in the database, user lands on Login page.
- [ ] All five error branches in 4.3 display the correct user-facing message without crashing.
- [ ] Login flow (existing) is unaffected: admin mock user and any real login path navigate correctly.
- [ ] `flutter analyze` exits with zero errors and zero warnings introduced by this feature.
- [ ] `AuthOtpSent` and `AuthRegistrationSuccess` states do not cause unexpected router redirects.

---

## Dependencies

- All of Phases 1, 2, and 3 complete and passing `flutter analyze`.
- Spring Boot backend reachable at `http://10.0.2.2:8080` (emulator) or configured LAN IP (device).
- A real or seeded email inbox accessible to receive the OTP (or backend SMTP configured to a test mailbox / Mailtrap).

---

## Test Suggestions

- **Integration test (`integration_test/` folder)**: Use `flutter_test` + `integration_test` package to script the happy-path tap sequence on an emulator. Assert that the `OtpVerificationPage` is present after register submit, and that the Login page is present after correct OTP entry. Backend can be pointed at a test environment or use a Wiremock stub.
- **Bloc test suite run**: Confirm all unit tests from Phases 2 and 3 still pass after any Phase 4 fixes (`flutter test`).
- **Screenshot artefact**: Capture and attach to the PR: Register page → OTP page → Login page success state. Annotate expected vs actual for reviewer.
