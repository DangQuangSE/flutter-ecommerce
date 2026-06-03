# Phase 3: Presentation & OTP Flow

## Goal
Introduce the `OtpVerificationPage` at route `/register/otp`, update `AuthBloc` events and states to drive the multi-step register flow, update `RegisterPage` to trigger the OTP request instead of emitting a mock user, and wire everything into the router — so the complete P1/P2/P3 user-visible register journey works end-to-end in the UI.

**Delivers:** US-1, US-2, US-3 (full register flow), US-4 (resend OTP), US-5 (error display), US-6 (loading states), US-7 (name preserved).

---

## Tasks

- [ ] **3.1 — Extend AuthBloc events**: Add new sealed events to `auth_event.dart`:
  - `AuthOtpRequested` (fields: `email`, `password`, `name`) — fires when Register form submits
  - `AuthOtpVerifyRequested` (fields: `email`, `otp`, `password`) — fires when OTP page submits pin
  - `AuthResendOtpRequested` (field: `email`) — fires from resend button
  Keep existing events (`AuthLoginRequested`, `AuthRegisterRequested`, `AuthLogoutRequested`, `AuthCheckRequested`) to avoid breaking the login page.

- [ ] **3.2 — Extend AuthBloc states**: Add new sealed states to `auth_state.dart`:
  - `AuthOtpSent` (fields: `email`, `password`, `name`) — emitted after OTP request succeeds; carries forward the password and name so they are not lost. **Override `toString()`** to mask `password`.
  - `AuthRegistrationSuccess` — emitted after `POST /register` returns 201; triggers redirect to Login
  - `AuthRegisterAccountExists` (optional) — when verify succeeded but register returns 409; show login CTA on OTP page
  Keep existing states (`AuthAuthenticated`, `AuthUnauthenticated`, `AuthLoading`, `AuthError`, `AuthInitial`) unchanged.

- [ ] **3.3 — Implement bloc handlers**: In `auth_bloc.dart`:
  - `_onOtpRequested`: emit `AuthLoading` → call `RequestOtpUseCase` → on success emit `AuthOtpSent(email, password, name)`; on failure emit `AuthError(message)`.
  - `_onOtpVerifyRequested`: emit `AuthLoading` → call `VerifyOtpUseCase` → on success call `RegisterUseCase(email, password)` → on 201 emit `AuthRegistrationSuccess`; on any failure emit `AuthError(message)`.
  - `_onResendOtpRequested`: emit `AuthLoading` → call `ResendOtpUseCase` → emit `AuthOtpSent` (same credentials) or `AuthError`.
  - Replace the mocked body of the old `_onRegisterRequested` handler with a no-op or remove it if `AuthRegisterRequested` is no longer dispatched anywhere.

- [ ] **3.4 — Add `pinput` package**: Add `pinput` to `pubspec.yaml` and run `flutter pub get`. Use it for the 6-digit OTP pin input on the new page.

- [ ] **3.5 — Build `OtpVerificationPage`**: Create `lib/features/auth/presentation/pages/otp_verification_page.dart`. Accepts `email`, `password`, `name` via constructor (passed from router `extra`). Layout:
  - Heading: "Verify your email"
  - Sub-heading showing the masked email address
  - `Pinput` widget (6 digits, auto-focus, obscure last char)
  - "Verify" submit button (disabled during `AuthLoading` **or** when pin length ≠ 6)
  - "Resend OTP" `TextButton` with a 60-second countdown timer (disabled while counting, re-enabled after)
  - `BlocConsumer`: `AuthRegistrationSuccess` → `context.goNamed(AppRoutes.login)` with a success snack-bar; `AuthError` → inline error text below the pin field; `AuthOtpSent` (resend) → reset pin + show snack-bar "OTP resent".

- [ ] **3.6 — Update `RegisterPage`**: Replace the `AuthRegisterRequested` dispatch with `AuthOtpRequested(email, password, name)`. In the `BlocConsumer` listener, replace `AuthAuthenticated → go home` with `AuthOtpSent → context.goNamed(AppRoutes.registerOtp, extra: {email, password, name})` **only once** (e.g. `_hasNavigatedToOtp` flag or `ModalRoute.of(context)?.isCurrent` guard) so resend re-emissions do not push OTP again. Keep all existing form validation, UI styling, and the `AuthError` snack-bar path unchanged.

- [ ] **3.7 — Add router route**: In `app_router.dart`, add a `GoRoute` for `/register/otp` (name: `AppRoutes.registerOtp`). Extract `email`, `password`, `name` from `state.extra`; if `extra` is null → `redirect` to `/register`. Add `/register/otp` to the `isGoingToAuth` set. In `redirect`, if bloc state is `AuthOtpSent` or `AuthRegistrationSuccess`, return `null` (stay in auth flow) before unauthenticated → `/login`.

- [ ] **3.8 — Add route name constant**: In `app_routes.dart` add `static const String registerOtp = 'registerOtp'`.

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/auth/presentation/bloc/auth_event.dart` | Add 3 new events |
| `lib/features/auth/presentation/bloc/auth_state.dart` | Add `AuthOtpSent`, `AuthRegistrationSuccess` |
| `lib/features/auth/presentation/bloc/auth_bloc.dart` | Implement 3 new handlers; replace mock register handler |
| `lib/features/auth/presentation/pages/register_page.dart` | Dispatch `AuthOtpRequested`; listener navigates to OTP page |
| `lib/features/auth/presentation/pages/otp_verification_page.dart` | **New file** — full OTP page |
| `lib/app/router/app_router.dart` | Add `/register/otp` route; update `isGoingToAuth` guard |
| `lib/app/router/app_routes.dart` | Add `registerOtp` constant |
| `pubspec.yaml` | Add `pinput` dependency |

---

## Acceptance Criteria

- [ ] Submitting the Register form fires `POST /api/auth/register/request-otp`; user lands on `OtpVerificationPage` with email shown.
- [ ] Entering correct 6-digit OTP and tapping "Verify" fires `POST /api/auth/verify-otp` then `POST /api/auth/register`; on 201 the user is navigated to the Login page with a "Registration successful" snack-bar.
- [ ] Tapping "Resend OTP" fires `POST /api/auth/resend-otp`; the button becomes disabled for 60 seconds; the pin field is cleared.
- [ ] A wrong OTP returns a 400 error; the `AuthError` message from the backend is shown inline below the pin field (not a snack-bar).
- [ ] A duplicate email (409) on OTP request shows the backend `message` in a snack-bar on the Register page.
- [ ] During any loading state, the submit button shows a `CircularProgressIndicator` and is non-tappable.
- [ ] The `name` entered on RegisterPage is preserved in `AuthOtpSent` state and accessible to `OtpVerificationPage` (satisfies US-7 personalised welcome foundation).
- [ ] Navigating back from `OtpVerificationPage` to `RegisterPage` does not trigger the router redirect to `/login`.
- [ ] `flutter analyze` reports zero new errors.

---

## Dependencies

- Phase 1 (correct `ApiConstants`) must be complete.
- Phase 2 (use cases registered in DI) must be complete.
- `pinput` added to `pubspec.yaml` and `flutter pub get` run before building `OtpVerificationPage`.

---

## Test Suggestions

- **Widget test — `RegisterPage`**: Mock `AuthBloc`, dispatch `AuthOtpSent`; assert `context.goNamed(AppRoutes.registerOtp)` is called with correct extras.
- **Widget test — `OtpVerificationPage`**: Mock `AuthBloc`, enter 6 digits, tap Verify; assert `AuthOtpVerifyRequested` event is added with correct otp string.
- **Widget test — resend timer**: Assert button is disabled immediately after tap and re-enabled after 60s (use `fakeAsync`).
- **Bloc test — `_onOtpRequested`**: Mock `RequestOtpUseCase` success → expect `[AuthLoading, AuthOtpSent]`; mock failure → expect `[AuthLoading, AuthError]`.
- **Bloc test — `_onOtpVerifyRequested`**: Mock both use cases succeed → expect `[AuthLoading, AuthRegistrationSuccess]`; verify OTP fails → expect `[AuthLoading, AuthError]`.
- **Router test**: Verify `/register/otp` path is in `isGoingToAuth` and does not redirect an `AuthUnauthenticated` user.
