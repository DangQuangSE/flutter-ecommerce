# Plan: Flutter E-Commerce Project Structure
Status: Done
Date: 2026-05-31
Mode: Hard

## Overview
Establish a professional, scalable Flutter e-commerce project structure using Feature-first Clean Architecture, BLoC/Cubit state management, GoRouter navigation, and get_it dependency injection — transforming a blank Flutter project into a ready-to-develop MVP foundation across 6 features.

## Phases
- [x] Phase 1: Foundation — Fix SDK constraint, add all packages, update main.dart skeleton
- [x] Phase 2: Core Layer — Implement errors, network, storage, DI container, constants, and extensions
- [x] Phase 3: App Shell — Build router with auth guard, theme system, and wire App widget
- [x] Phase 4: Feature Stubs — Scaffold all 6 features with full 3-layer Clean Architecture stubs
- [x] Phase 5: Verification — Confirm zero analyze errors, codegen success, and app launches

## Research Summary
Architecture decisions are finalized:

- **Pattern:** Feature-first + Clean Architecture. Each feature owns `data/`, `domain/`, and `presentation/` layers. No cross-feature imports — shared types live in `core/`.
- **State:** BLoC for complex flows (auth, product, cart, checkout, order); Cubit for simpler UI state (profile, theme toggles). All states use Dart 3 sealed classes for exhaustive pattern matching.
- **DI:** Manual get_it with `registerLazySingleton` for repositories and data sources (expensive to construct, shared), `registerFactory` for BLoCs/Cubits (new instance per route).
- **Router:** GoRouter 14.x with `GoRouterRefreshStream` listening to the auth BLoC stream for automatic login/logout redirects. All routes are named constants defined in `AppRoutes`.
- **Error handling:** Dart 3 native `sealed class Result<T>` — avoids the `dartz` dependency entirely. Cleaner for MVP, easy to extend later.
- **Codegen:** `freezed` + `build_runner` for entities and BLoC states. Eliminates boilerplate equality, copyWith, and toString.
- **SDK fix required:** Current `pubspec.yaml` has `sdk: ^3.11.5` which is an invalid constraint (caret syntax not valid for SDK). Must be changed to `sdk: ">=3.3.0 <4.0.0"` in Phase 1 before any `pub get` can succeed.

## Dependencies
- Flutter SDK >= 3.3.0 installed locally
- Android Studio / Xcode for device targets (Android + iOS primary)
- `dart run build_runner build` must be run after Phase 4 to generate `.freezed.dart` and `.g.dart` files
- No backend required — all datasources return mock/stub data during this phase

## Risks
- HIGH: Invalid SDK constraint (`sdk: ^3.11.5`) blocks all package resolution — fixed in first step of Phase 1 before any other work proceeds
- HIGH: Freezed codegen files (`.freezed.dart`) are not committed to git — developer must run `dart run build_runner build` before the project compiles; Phase 5 explicitly verifies this
- MEDIUM: GoRouter 14.x has breaking API changes from v12/v13 — all router code in this plan is written for 14.x; mixing old examples from the internet will cause errors
- MEDIUM: get_it registration order matters — BLoCs must be registered after their repository dependencies; injection_container.dart in Phase 4 enforces correct order
- LOW: `cached_network_image` requires internet permission on Android — already included by default in new Flutter projects but worth verifying if images fail
- LOW: `intl` version conflicts with Flutter's internal intl dependency — pinned to `^0.19.0` which is compatible with Flutter 3.x
