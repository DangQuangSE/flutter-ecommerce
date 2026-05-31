# Spec: Flutter E-Commerce — Project Structure & Foundation

**Date:** 2026-05-31
**Status:** Ready

---

## Problem Statement

Fresh Flutter project needs a professional, scalable folder structure and dependency foundation for a real e-commerce MVP. No structure exists yet — only `main.dart`.

---

## User Stories

- **[P1]** As a developer, I want a feature-first folder structure so that each feature (auth, product, cart, checkout, order, profile) is self-contained and independently developable.
  Accepted when: `lib/features/` contains 6 feature folders, each with `data/`, `domain/`, `presentation/` subfolders.

- **[P1]** As a developer, I want BLoC/Cubit wired per feature so that state is predictable and testable.
  Accepted when: each feature's `presentation/bloc/` or `presentation/cubit/` contains typed event/state/bloc files.

- **[P1]** As a developer, I want a `core/` layer with shared utilities so that network, storage, error handling, and common widgets are not duplicated across features.
  Accepted when: `core/network/`, `core/storage/`, `core/errors/`, `core/widgets/` all exist with base implementations.

- **[P1]** As a developer, I want GoRouter configured so that named routes exist for all MVP screens.
  Accepted when: `app/router/app_router.dart` defines routes for all 6 features with no unnamed navigation.

- **[P2]** As a developer, I want get_it DI container set up so that repositories and data sources are injectable.
  Accepted when: `core/di/injection_container.dart` registers at least one feature's dependencies end-to-end.

- **[P3]** _(Flavor/environment config — out of scope for structure phase)_

---

## Functional Requirements

1. FR-01: Create `lib/` folder structure matching the agreed feature-first + Clean Architecture layout.
2. FR-02: Add all MVP packages to `pubspec.yaml` (flutter_bloc, go_router, dio, equatable, get_it, shared_preferences, cached_network_image, intl).
3. FR-03: Implement `core/network/dio_client.dart` with base URL, headers, and error interceptor.
4. FR-04: Implement `core/errors/failures.dart` and `exceptions.dart` with base error types.
5. FR-05: Implement `app/router/app_router.dart` with GoRouter and named routes for all features.
6. FR-06: Implement `app/theme/` with AppColors, AppTextStyles, AppTheme.
7. FR-07: Create barrel `index.dart` files per feature for clean imports.
8. FR-08: Each feature must have at minimum: one entity, one abstract repository, one use case stub, one BLoC/Cubit stub, one page widget.

---

## Non-Functional Requirements

- Structure: max 4 levels deep inside any feature folder
- Imports: no cross-feature direct imports — features communicate via shared domain entities in `core/` only
- Linting: `flutter_lints` passes with zero warnings on empty stubs
- Naming: snake_case files, PascalCase classes, consistent `_bloc/_cubit/_event/_state` suffixes

---

## Success Criteria

- [ ] `flutter analyze` returns 0 errors, 0 warnings after structure is created
- [ ] `flutter run` launches app (even if just blank screen) with no compile errors
- [ ] All 6 features have complete 3-layer folder structure
- [ ] GoRouter navigates to at least 2 routes without crashing
- [ ] BLoC registered and emitting initial state for at least `auth` feature

---

## Out of Scope

- Actual UI implementation (screens beyond scaffold stubs)
- Real API integration (datasources return mock data for now)
- Payment gateway integration
- Push notifications
- Authentication logic (JWT refresh, token storage — stub only)

---

## Assumptions

- Backend is REST API (not Firebase) — Dio is the correct HTTP client
- Single flavor for now (no dev/staging/prod split yet)
- Target platforms: Android + iOS primary, Web/Windows secondary
- Dart SDK >= 3.11.5

---

## Architecture Reference

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── app_routes.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_text_styles.dart
├── core/
│   ├── constants/
│   ├── di/
│   │   └── injection_container.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── dio_client.dart
│   ├── storage/
│   │   └── local_storage.dart
│   ├── utils/
│   │   └── extensions/
│   └── widgets/
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── bloc/
    │       ├── pages/
    │       └── widgets/
    ├── product/   # same 3-layer structure
    ├── cart/      # uses Cubit (simpler state)
    ├── checkout/
    ├── order/
    └── profile/  # uses Cubit
```

## Packages

```yaml
flutter_bloc: ^9.0.0
go_router: ^14.0.0
dio: ^5.0.0
equatable: ^2.0.0
get_it: ^8.0.0
shared_preferences: ^2.0.0
cached_network_image: ^3.0.0
intl: ^0.19.0
```
