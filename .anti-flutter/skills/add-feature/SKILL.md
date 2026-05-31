---
name: add-feature
description: "Scaffold a new Flutter feature with a full 3-layer Clean Architecture structure (data/domain/presentation). Use when creating a new e-commerce feature from scratch."
user-invocable: true
---

# add-feature — Scaffold a New Feature

Creates the complete 3-layer folder structure and stub files for a new feature, following the project's Clean Architecture convention.

**Trigger:** `/add-feature {feature_name}` or "create feature {name}"

---

## Step 1 — Gather Information

Before creating files, confirm (if not already in the prompt):

1. **Feature name** (snake_case): `wishlist`, `review`, `notification`
2. **State type**: BLoC (complex) or Cubit (simple)?
   - BLoC → auth, product, checkout, order
   - Cubit → cart, profile, UI toggles
3. **Entity fields**: at minimum `id` + 2–3 key fields

---

## Step 2 — Create Directory Tree

```
lib/features/{feature}/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    bloc/   OR   cubit/
    pages/
    widgets/
```

---

## Step 3 — Domain Layer (create first)

### Entity

```dart
// lib/features/{feature}/domain/entities/{feature}_entity.dart
import 'package:equatable/equatable.dart';

class {Feature}Entity extends Equatable {
  final String id;
  // add fields here

  const {Feature}Entity({required this.id});

  @override
  List<Object?> get props => [id];
}
```

Rules: NO `fromJson`, NO `dio` import, NO `@JsonSerializable`.

### Abstract Repository

```dart
// lib/features/{feature}/domain/repositories/{feature}_repository.dart
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/{feature}/domain/entities/{feature}_entity.dart';

abstract interface class {Feature}Repository {
  Future<Result<List<{Feature}Entity>>> getAll();
  Future<Result<{Feature}Entity>> getById(String id);
}
```

### Use Case

```dart
// lib/features/{feature}/domain/usecases/get_{feature}s_usecase.dart
import 'package:flutter_ecommerce/core/errors/result.dart';
import '../entities/{feature}_entity.dart';
import '../repositories/{feature}_repository.dart';

class Get{Feature}sUseCase {
  final {Feature}Repository _repository;
  const Get{Feature}sUseCase(this._repository);

  Future<Result<List<{Feature}Entity>>> call() => _repository.getAll();
}
```

---

## Step 4 — Data Layer

### Model

```dart
// lib/features/{feature}/data/models/{feature}_model.dart
import '../../domain/entities/{feature}_entity.dart';

class {Feature}Model extends {Feature}Entity {
  const {Feature}Model({required super.id});

  factory {Feature}Model.fromJson(Map<String, dynamic> json) => {Feature}Model(
    id: json['id'] as String,
  );

  static List<{Feature}Model> get mockList => [
    const {Feature}Model(id: 'mock-001'),
  ];
}
```

### Remote DataSource

```dart
// Abstract
abstract interface class {Feature}RemoteDataSource {
  Future<List<{Feature}Model>> getAll();
  Future<{Feature}Model> getById(String id);
}

// Impl
class {Feature}RemoteDataSourceImpl implements {Feature}RemoteDataSource {
  // ignore: unused_field — replaced with real Dio call when API is ready
  final DioClient _dioClient;
  const {Feature}RemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<{Feature}Model>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {Feature}Model.mockList; // TODO: _dioClient.dio.get(...)
  }

  @override
  Future<{Feature}Model> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {Feature}Model.mockList.first;
  }
}
```

### Repository Impl

```dart
// lib/features/{feature}/data/repositories/{feature}_repository_impl.dart
class {Feature}RepositoryImpl implements {Feature}Repository {
  final {Feature}RemoteDataSource _remoteDataSource;
  const {Feature}RepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<{Feature}Entity>>> getAll() async {
    try {
      return Success(await _remoteDataSource.getAll());
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<{Feature}Entity>> getById(String id) async {
    try {
      return Success(await _remoteDataSource.getById(id));
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }
}
```

---

## Step 5 — Presentation Layer

Use `/add-bloc {feature}` to generate the BLoC or Cubit files.

### Page stub

```dart
// lib/features/{feature}/presentation/pages/{feature}_page.dart
import 'package:flutter/material.dart';

class {Feature}Page extends StatelessWidget {
  const {Feature}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{Feature}')),
      body: const Center(child: Text('{Feature} — stub')),
    );
  }
}
```

---

## Step 6 — DI Registration

Add to `lib/core/di/injection_container.dart` in this order:

```dart
sl.registerLazySingleton<{Feature}RemoteDataSource>(
  () => {Feature}RemoteDataSourceImpl(sl<DioClient>()),
);
sl.registerLazySingleton<{Feature}Repository>(
  () => {Feature}RepositoryImpl(sl<{Feature}RemoteDataSource>()),
);
sl.registerLazySingleton<Get{Feature}sUseCase>(
  () => Get{Feature}sUseCase(sl<{Feature}Repository>()),
);
// BLoC → registerFactory | app-wide Cubit → registerLazySingleton
sl.registerFactory<{Feature}Bloc>(
  () => {Feature}Bloc(getUseCase: sl()),
);
```

---

## Step 7 — Router

Add to `lib/app/router/app_router.dart`:

```dart
GoRoute(
  path: '/{feature}s',
  name: AppRoutes.{feature}List,
  builder: (context, state) => BlocProvider(
    create: (_) => sl<{Feature}Bloc>(),
    child: const {Feature}Page(),
  ),
),
```

Add constant to `lib/app/router/app_routes.dart`:
```dart
static const String {feature}List = '{feature}-list';
```

---

## Completion Checklist

- [ ] `domain/entities/{feature}_entity.dart`
- [ ] `domain/repositories/{feature}_repository.dart` (abstract)
- [ ] `domain/usecases/get_{feature}s_usecase.dart`
- [ ] `data/models/{feature}_model.dart`
- [ ] `data/datasources/{feature}_remote_datasource.dart`
- [ ] `data/datasources/{feature}_remote_datasource_impl.dart`
- [ ] `data/repositories/{feature}_repository_impl.dart`
- [ ] `presentation/bloc/` or `presentation/cubit/` files
- [ ] `presentation/pages/{feature}_page.dart`
- [ ] `injection_container.dart` — DI registered in correct order
- [ ] `app_router.dart` — GoRoute with BlocProvider wrapper
- [ ] `flutter analyze` → 0 errors

## Anti-Patterns

- ❌ Entity in `data/` layer
- ❌ `dio` import in domain or presentation
- ❌ `setState()` instead of BLoC/Cubit
- ❌ Calling repository directly from BLoC (skip use case)
- ❌ `registerLazySingleton<{Feature}Bloc>` — must be `registerFactory`
