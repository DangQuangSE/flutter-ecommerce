# Canonical Folder Structure

The complete `lib/` tree for this project. Every new file must fit into this structure.

```
lib/
├── main.dart                              ← async main, DI init, runApp
│
├── app/
│   ├── app.dart                           ← MultiBlocProvider + MaterialApp.router
│   ├── router/
│   │   ├── app_router.dart               ← GoRouter config + GoRouterRefreshStream
│   │   └── app_routes.dart               ← static const String route name constants
│   └── theme/
│       ├── app_colors.dart               ← Color constants
│       ├── app_text_styles.dart          ← TextStyle constants
│       └── app_theme.dart                ← ThemeData.light()
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart            ← baseUrl, endpoint paths
│   │   └── app_constants.dart            ← appName, token keys, timeouts
│   ├── di/
│   │   └── injection_container.dart      ← get_it registrations
│   ├── errors/
│   │   ├── exceptions.dart               ← AppException sealed class hierarchy
│   │   ├── failures.dart                 ← Failure sealed class hierarchy
│   │   └── result.dart                   ← Result<T> = Success | ResultFailure
│   ├── network/
│   │   └── dio_client.dart               ← Dio instance + interceptors
│   ├── storage/
│   │   └── local_storage.dart            ← SharedPreferences wrapper
│   └── utils/
│       └── extensions/
│           ├── context_extensions.dart   ← BuildContext shortcuts
│           └── string_extensions.dart    ← String helpers
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── auth_remote_datasource.dart
    │   │   │   └── auth_remote_datasource_impl.dart
    │   │   ├── models/
    │   │   │   └── user_model.dart
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── user_entity.dart
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart     ← abstract interface
    │   │   └── usecases/
    │   │       └── login_usecase.dart
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── auth_bloc.dart
    │       │   ├── auth_event.dart
    │       │   └── auth_state.dart
    │       ├── pages/
    │       │   ├── login_page.dart
    │       │   ├── register_page.dart
    │       │   └── splash_page.dart
    │       └── widgets/
    │
    ├── product/                           ← same 3-layer structure, uses BLoC
    ├── cart/                              ← uses CartCubit (app-wide singleton)
    ├── checkout/                          ← uses BLoC
    ├── order/                             ← uses BLoC
    └── profile/                           ← uses ProfileCubit (app-wide singleton)
```

## Key Rules

- Files outside `lib/features/{feature}/` go into `lib/core/` or `lib/app/`
- No feature-to-feature imports — use `core/` for shared types
- Every feature has exactly: `data/`, `domain/`, `presentation/`
- Every `domain/repositories/` file is abstract interface only
- Every `data/repositories/` file is the impl
