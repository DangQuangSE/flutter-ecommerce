---
name: wire-di
description: "Register all components of a feature in injection_container.dart following the correct factory vs singleton rules. Use after scaffolding a new feature or when DI registration is missing."
---

# wire-di — DI Registration

Adds correct get_it registrations for a feature to `injection_container.dart`.

## When to use this skill

- Use this after scaffolding a new feature to register all its dependencies.
- Use this when dependency injection (get_it) registration is missing, incorrect, or causing stale state runtime exceptions.

## How to use it

### Step 1 — Read the Feature

Read `lib/features/{feature}/` to discover what exists:
- Datasource class names
- Repository interface and impl class names
- Use case class names
- BLoC or Cubit class name

Read `lib/core/di/injection_container.dart` to see what's already registered.

---

### Step 2 — Apply Registration Rules

| Component type | Registration method | Reason |
|----------------|-------------------|--------|
| `SharedPreferences` | `registerLazySingleton` | Initialized once, shared |
| `DioClient` | `registerLazySingleton` | Expensive, shared |
| `LocalStorage` | `registerLazySingleton` | Shared wrapper |
| Remote DataSource | `registerLazySingleton` | Stateless, shared |
| Repository impl | `registerLazySingleton` | Stateless, shared |
| Use case | `registerLazySingleton` | Stateless function |
| **BLoC** (product, checkout, order) | **`registerFactory`** | Fresh per route, no stale state |
| **AuthBloc** | **`registerLazySingleton`** | Router reads its stream — must be singleton |
| **CartCubit** | **`registerLazySingleton`** | App-wide cart state |
| **ProfileCubit** | **`registerLazySingleton`** | App-wide profile state |

---

### Step 3 — Generate Registration Code

Add inside `configureDependencies()` in this exact order (top-down dependency order):

```dart
// ── {Feature} ────────────────────────────────────────────────────────────────
sl.registerLazySingleton<{Feature}RemoteDataSource>(
  () => {Feature}RemoteDataSourceImpl(sl<DioClient>()),
);
sl.registerLazySingleton<{Feature}Repository>(
  () => {Feature}RepositoryImpl(sl<{Feature}RemoteDataSource>()),
);
sl.registerLazySingleton<Get{Feature}sUseCase>(
  () => Get{Feature}sUseCase(sl<{Feature}Repository>()),
);

// BLoC (factory) — one fresh instance per route navigation
sl.registerFactory<{Feature}Bloc>(
  () => {Feature}Bloc(
    getUseCase: sl<Get{Feature}sUseCase>(),
    repository: sl<{Feature}Repository>(),
  ),
);
```

---

### Step 4 — Add Required Imports

Add the feature's import block at the top of `injection_container.dart`:

```dart
// {Feature}
import 'package:flutter_ecommerce/features/{feature}/data/datasources/{feature}_remote_datasource.dart';
import 'package:flutter_ecommerce/features/{feature}/data/datasources/{feature}_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/{feature}/data/repositories/{feature}_repository_impl.dart';
import 'package:flutter_ecommerce/features/{feature}/domain/repositories/{feature}_repository.dart';
import 'package:flutter_ecommerce/features/{feature}/domain/usecases/get_{feature}s_usecase.dart';
import 'package:flutter_ecommerce/features/{feature}/presentation/bloc/{feature}_bloc.dart';
```

---

### Step 5 — Update MultiBlocProvider in app.dart

App-wide singletons (AuthBloc, CartCubit, ProfileCubit) must also be provided in `lib/app/app.dart`:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),      // singleton
    BlocProvider<CartCubit>(create: (_) => sl<CartCubit>()),    // singleton
    BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()), // singleton
    // DO NOT add ProductBloc or other factory BLoCs here
  ],
  child: MaterialApp.router(...),
)
```

Factory BLoCs (ProductBloc, etc.) are provided at the route level — see `/add-feature` Step 7.

---

### Step 6 — Verify

```bash
flutter analyze lib/core/di/injection_container.dart lib/app/app.dart
```

Expected: 0 errors.

Runtime check: the app should launch to SplashPage and `sl<AuthBloc>()` should not throw.

---

## Anti-Patterns to Avoid

- ❌ `registerLazySingleton<ProductBloc>` — BLoC must be `registerFactory`
- ❌ Registering dependencies in wrong order (BLoC before its UseCase)
- ❌ Adding factory BLoCs to root `MultiBlocProvider` — only singletons belong there
- ❌ Not importing the concrete impl class (only importing the abstract interface)
- ❌ Calling `sl<ProductBloc>()` at app startup before navigating to a route
