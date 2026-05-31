# Flutter E-Commerce — Architecture Rules

These rules are mandatory for every code generation in this project.
**Always read this entire file before creating any Dart file.**

---

## 1. Folder Structure

Every feature must live under `lib/features/{feature}/` with a fixed structure:

```
lib/features/{feature}/
  data/
    datasources/
      {feature}_remote_datasource.dart       ← abstract interface
      {feature}_remote_datasource_impl.dart  ← stub returning mock data
    models/
      {feature}_model.dart                   ← extends entity, has fromJson/toJson
    repositories/
      {feature}_repository_impl.dart         ← implements domain repository
  domain/
    entities/
      {feature}_entity.dart                  ← pure Dart + Equatable, NO fromJson
    repositories/
      {feature}_repository.dart              ← abstract interface ONLY
    usecases/
      {usecase}_usecase.dart                 ← one class, one call() method
  presentation/
    bloc/         ← use for complex features (auth, product, checkout, order)
      {feature}_bloc.dart
      {feature}_event.dart
      {feature}_state.dart
    cubit/        ← use for simple state (cart, profile, UI toggles)
      {feature}_cubit.dart
      {feature}_state.dart
    pages/
      {feature}_page.dart
    widgets/      ← small reusable widgets scoped to this feature
```

**NEVER:**
- Create files outside this structure
- Put business logic in `pages/`
- Import directly between features (use `core/` only)

---

## 2. Layer Rules — STRICT

| Layer | May import | Must NOT import |
|-------|-----------|----------------|
| `domain/` | `core/errors/`, `equatable` | `data/`, `presentation/`, `dio`, `flutter_bloc` |
| `data/` | `domain/`, `core/`, `dio` | `presentation/` |
| `presentation/` | `domain/`, `core/`, `flutter_bloc` | `data/` directly |

**Golden rule:** `presentation/` → `domain/` → `data/` — one direction only.

---

## 3. Entities

```dart
// ✅ CORRECT
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final double price;

  const ProductEntity({required this.id, required this.name, required this.price});

  @override
  List<Object?> get props => [id, name, price];
}

// ❌ WRONG — entity must not have fromJson, must not import dio
```

---

## 4. Models (Data Layer)

```dart
// ✅ CORRECT — model extends entity, has fromJson/toJson
class ProductModel extends ProductEntity {
  const ProductModel({required super.id, required super.name, required super.price});

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
  );
}

// ❌ WRONG — @JsonSerializable on entity
// ❌ WRONG — model does not extend entity
```

---

## 5. Result Type — MANDATORY

**Never** throw exceptions from repository to presentation.
Every repository method must return `Future<Result<T>>`.

```dart
// ✅ CORRECT
Future<Result<ProductEntity>> getProductById(String id) async {
  try {
    final model = await _remoteDataSource.getProductById(id);
    return Success(model);
  } on AppException catch (e) {
    return ResultFailure(NetworkFailure(e.message));
  }
}

// ❌ WRONG — throwing directly, not wrapping in Result
```

Import: `package:flutter_ecommerce/core/errors/result.dart`

---

## 6. BLoC Pattern

```dart
// ✅ Event — sealed class, Equatable
sealed class ProductEvent extends Equatable {
  const ProductEvent();
  @override List<Object?> get props => [];
}

// ✅ State — sealed class, Equatable
sealed class ProductState extends Equatable {
  const ProductState();
  @override List<Object?> get props => [];
}

// ✅ Switch on sealed — NO default arm
switch (result) {
  case Success(:final data): emit(ProductLoaded(data));
  case ResultFailure(:final failure): emit(ProductError(failure.message));
}

// ❌ WRONG — default on sealed class defeats exhaustiveness checking
switch (state) {
  case ProductLoaded(): ...
  default: break;
}
```

---

## 7. BLoC vs Cubit

| Use BLoC | Use Cubit |
|----------|-----------|
| auth, product, checkout, order | cart, profile, theme, bottomNav |
| Multiple events from multiple UI paths | Simple state, few transitions |
| Need to trace specific events | Toggle, counter, simple load |

---

## 8. Dependency Injection (get_it)

```dart
// ✅ Repos/datasources/usecases → registerLazySingleton (shared, expensive to build)
sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

// ✅ BLoCs → registerFactory (fresh instance per route, prevents stale state)
sl.registerFactory<ProductBloc>(() => ProductBloc(getProductsUseCase: sl()));

// ✅ AuthBloc → registerLazySingleton (singleton because router reads its stream)
sl.registerLazySingleton<AuthBloc>(() => AuthBloc(loginUseCase: sl(), authRepository: sl()));

// ❌ WRONG — BLoC as singleton causes stale state across route changes
sl.registerLazySingleton<ProductBloc>(() => ProductBloc(...));
```

---

## 9. GoRouter

```dart
// ✅ CORRECT — always use named routes
context.goNamed(AppRoutes.productList);

// ✅ CORRECT — wrap factory BLoC in route builder
GoRoute(
  path: '/products',
  name: AppRoutes.productList,
  builder: (context, state) => BlocProvider(
    create: (_) => sl<ProductBloc>(),
    child: const ProductListPage(),
  ),
),

// ✅ CORRECT — use state.uri.path (state.matchedLocation is deprecated in 14.x)
final path = state.uri.path;

// ❌ WRONG — hardcoded path string
context.go('/products');
```

---

## 10. Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Files | snake_case | `product_detail_page.dart` |
| Classes | PascalCase | `ProductDetailPage` |
| BLoC events | `{Feature}{Action}Requested` | `ProductListRequested` |
| BLoC states | `{Feature}{Status}` | `ProductLoaded`, `ProductError` |
| Use cases | `{Verb}{Entity}UseCase` | `GetProductsUseCase` |
| Repos (abstract) | `{Feature}Repository` | `ProductRepository` |
| Repos (impl) | `{Feature}RepositoryImpl` | `ProductRepositoryImpl` |

---

## 11. Absolute Prohibitions

- ❌ `setState()` for business state — use BLoC/Cubit
- ❌ Call `dio.get()` directly from a widget or page
- ❌ `context.read<XBloc>()` inside `initState()` — use `Future.microtask()`
- ❌ Cross-feature direct imports
- ❌ `default:` arm in switch on a sealed class
- ❌ `registerLazySingleton<ProductBloc>` — must be `registerFactory`
