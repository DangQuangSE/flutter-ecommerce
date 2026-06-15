# Flutter E-Commerce — Project Context

This is a Flutter mobile e-commerce app built with Clean Architecture, BLoC/Cubit state management, GetIt DI, and GoRouter navigation. The backend is a Spring Boot REST API (`java-ecommerce`).

## Mandatory: Grading Standards

@.claude/rules/flutter-grading-standards.md

Every code change to Dart files **must** satisfy the grading criteria in that file.
Before completing any task that touches `.dart` files, mentally check the relevant criteria.
Flag any existing violation you encounter and note it, even if fixing it is out of scope.

## Architecture

```
lib/
  main.dart                 # DI init + app bootstrap only
  app/
    router/app_router.dart  # GoRouter — all routes defined here
    di/injection.dart       # GetIt service locator
  core/
    constants/              # AppColors, AppSizes, AppStrings, AppRoutes
    themes/
    network/                # Dio client, interceptors
    error/                  # Failure types, Result<T>
  features/
    <feature>/
      data/
        datasources/        # Remote API calls (Dio)
        models/             # JSON ↔ entity mapping
        repositories/       # Implements domain repository
      domain/
        entities/           # Pure Dart classes, no Flutter imports
        repositories/       # Abstract interfaces
        usecases/
      presentation/
        bloc/ or cubit/     # State management
        pages/              # Full screens (one per route)
        widgets/            # Reusable sub-widgets
```

## Key Conventions

- **State pattern:** every Cubit/BLoC exposes `Initial | Loading | Success | Error | Empty`
- **Error handling:** use `Result<T>` or `Either<Failure, T>` — never throw raw exceptions across layers
- **Models:** `fromJson` / `toJson` live in `data/models/`, never in domain entities
- **Navigation:** use GoRouter typed routes — no `Navigator.push` outside the router
- **DI:** register all dependencies in `injection.dart` — no `locator<T>()` inside widgets
- **Lists:** always `ListView.builder` / `GridView.builder` for dynamic collections
- **Images:** use `cached_network_image` for all network images

## Backend

- Spring Boot REST API at `http://10.0.2.2:8080` (Android emulator) or `http://localhost:8080`
- Auth: JWT — token stored in secure storage, sent via `Authorization: Bearer <token>` header
- Source: `d:\GitHub\java-ecommerce`

## Before Every Commit

1. `dart analyze` — zero errors
2. `dart format .` — consistent formatting
3. No `RenderFlex overflowed` in the running app
4. All new screens handle Loading / Error / Empty states
