# Phase 1: BLoC State & Event Refactor

**Phase:** 01 of 05
**Covers stories:** P1 (US-3, US-4, US-6, US-8), P2 (US-9)
**Testing:** Unit-testable; add bloc unit tests for new state transitions

---

## Goal
Remove the `password` field from all OTP-related events and states, and introduce the two new BLoC members (`AuthOtpVerified` state, `AuthRegisterPasswordSubmitted` event) that decouple OTP verification from account creation. All subsequent phases depend on this being correct and compiling cleanly.

---

## Tasks
- [ ] Remove the `password` parameter from `AuthOtpRequested` event and update its `props`.
- [ ] Remove the `password` parameter from `AuthResendOtpRequested` event and update its `props`.
- [ ] Remove the `password` parameter from `AuthOtpVerifyRequested` event and update its `props`.
- [ ] Remove the `password` field from `AuthOtpSent` state; update `props` and `toString`.
- [ ] Add new sealed class `AuthOtpVerified` to `auth_state.dart` carrying only `email`.
- [ ] Add new sealed class `AuthRegisterPasswordSubmitted` to `auth_event.dart` carrying `email` and `password`.
- [ ] In `auth_bloc.dart`, split `_onOtpVerifyRequested`: the handler now only calls `_verifyOtpUseCase` and emits `AuthOtpVerified` on success (remove the chained `_registerUseCase` call).
- [ ] Register a new handler `on<AuthRegisterPasswordSubmitted>` in `AuthBloc` that calls `_registerUseCase` and emits `AuthRegistrationSuccess` or delegates to `_emitRegisterFailure`.
- [ ] Update `_onResendOtpRequested` to emit `AuthOtpSent` without a password field.
- [ ] Fix all compile errors caused by removed `password` fields (call sites in `register_page.dart` and `otp_verification_page.dart` will break — leave them marked for Phases 2 & 3).

---

## Files to Touch
- `lib/features/auth/presentation/bloc/auth_event.dart` — remove password from 2 events, add 1 new event
- `lib/features/auth/presentation/bloc/auth_state.dart` — remove password from `AuthOtpSent`, add `AuthOtpVerified`
- `lib/features/auth/presentation/bloc/auth_bloc.dart` — split verify handler, add register-password handler, fix resend handler

---

## Acceptance Criteria
- `dart analyze` reports zero errors in the three BLoC files after changes (other files may still have errors — those are fixed in later phases).
- `AuthOtpVerified` carries `email` and appears in the `sealed class` hierarchy.
- `AuthRegisterPasswordSubmitted` carries `email` and `password`.
- `_onOtpVerifyRequested` no longer calls `_registerUseCase`.
- `_onRegisterPasswordSubmitted` correctly calls `_registerUseCase` and routes success/failure.
- All existing BLoC unit tests still pass (or are updated to remove password arguments).

---

## Dependencies
- None — this is the foundational phase; all other phases depend on it.

---

## Risks
- **Router whitelists specific AuthBloc states**: `AuthOtpVerified` is not yet in the router whitelist at the end of this phase. Do not navigate to the password page yet — that is wired in Phase 4. The app will compile and run, but `/register/password` does not exist until Phase 4.
