# Phase 4: Feature Stubs

## Requirements
Scaffold all 6 features (auth, product, cart, checkout, order, profile) with complete 3-layer Clean Architecture stubs — every layer has at least one real file per feature so the DI container, router, and analyzer all see a coherent, compile-clean project. No feature returns real data; datasources return hardcoded mock values.

## Steps
1. Create the `auth` feature fully end-to-end (entity, model, abstract repo, repo impl, datasource, use case, BLoC with sealed states, login/register/splash pages) — this is the most complex feature and serves as the template.
2. Create the `product` feature following the same pattern, using BLoC and a `Product` entity with at least `id`, `name`, `price`, and `imageUrl` fields.
3. Create the `cart` and `profile` features using Cubit (simpler than BLoC — no events) with `CartCubit` and `ProfileCubit` respectively.
4. Create the `checkout` and `order` features using BLoC with sealed states — they share the order-placement flow and are wired together conceptually.
5. Register all feature datasources, repositories, and BLoCs/Cubits in `injection_container.dart` — datasources and repos as `registerLazySingleton`, BLoCs/Cubits as `registerFactory`.
6. Create a barrel `index.dart` for each feature's `presentation/` layer for clean BlocProvider imports.

## Success Criteria
- `flutter analyze lib/features/` returns 0 errors
- `sl<AuthBloc>()` returns a new AuthBloc instance without throwing
- AuthBloc emits `AuthInitial` as its initial state
- `dart run build_runner build --delete-conflicting-outputs` completes with no errors (freezed files generated)
- All 6 feature folder trees exist with the full `data/domain/presentation` structure

## Risks
- Freezed codegen requires `part 'filename.freezed.dart';` directive in every freezed-annotated file — missing this causes a cryptic compile error; double-check every entity and state file
- BLoC `registerFactory` (not `registerLazySingleton`) is critical — sharing a BLoC instance across routes causes stale state bugs; a factory creates a fresh instance per call
- Sealed class states in Dart 3 require every subclass to be in the same library (same file or same `part` chain) — keep all state classes in the single `_state.dart` file

---

## Architecture pattern — copy this for every feature

```
lib/features/{feature}/
  data/
    datasources/
      {feature}_remote_datasource.dart      ← abstract interface
      {feature}_remote_datasource_impl.dart ← stub returning mock data
    models/
      {feature}_model.dart                  ← freezed, extends entity
    repositories/
      {feature}_repository_impl.dart        ← implements domain repo
  domain/
    entities/
      {feature}_entity.dart                 ← freezed, pure Dart
    repositories/
      {feature}_repository.dart             ← abstract interface
    usecases/
      {usecase_name}.dart                   ← single-method class
  presentation/
    bloc/  OR  cubit/
      {feature}_bloc.dart / {feature}_cubit.dart
      {feature}_event.dart  (BLoC only)
      {feature}_state.dart
    pages/
      {feature}_page.dart
    widgets/
      (empty for now)
    index.dart                              ← barrel export
```

---

## Exact File Contents

### AUTH FEATURE

#### `lib/features/auth/domain/entities/user_entity.dart`

```dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, avatarUrl, createdAt];
}
```

#### `lib/features/auth/domain/repositories/auth_repository.dart`

```dart
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> register({
    required String email,
    required String password,
    required String name,
  });

  Future<Result<void>> logout();

  Future<Result<UserEntity?>> getCurrentUser();
}
```

#### `lib/features/auth/domain/usecases/login_usecase.dart`

```dart
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
```

#### `lib/features/auth/data/models/user_model.dart`

```dart
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarUrl,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Mock user for stub datasource.
  static UserModel get mock => UserModel(
        id: 'user-001',
        email: 'demo@example.com',
        name: 'Demo User',
        avatarUrl: null,
        createdAt: DateTime(2024, 1, 1),
      );
}
```

#### `lib/features/auth/data/datasources/auth_remote_datasource.dart`

```dart
import 'package:flutter_ecommerce/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();
}
```

#### `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart`

```dart
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  const AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // TODO: replace with real API call using _dioClient.dio.post(...)
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    if (email.isEmpty || password.isEmpty) {
      throw const NetworkException('Invalid credentials');
    }
    return UserModel.mock;
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // UserModel extends entity directly — no freezed copyWith. Construct directly.
    return UserModel(
      id: 'user-new',
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

#### `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      return Success(user);
    } on UnauthorisedException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<UserEntity>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      return Success(user);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    // TODO: check local storage for cached token and return cached user
    return const Success(null);
  }
}
```

#### `lib/features/auth/presentation/bloc/auth_event.dart`

```dart
import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

final class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
```

#### `lib/features/auth/presentation/bloc/auth_state.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
```

#### `lib/features/auth/presentation/bloc/auth_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );
    switch (result) {
      case Success(:final data):
        emit(AuthAuthenticated(data));
      case ResultFailure(:final failure):
        emit(AuthError(failure.message));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.getCurrentUser();
    switch (result) {
      case Success(:final data):
        if (data != null) {
          emit(AuthAuthenticated(data));
        } else {
          emit(const AuthUnauthenticated());
        }
      case ResultFailure():
        emit(const AuthUnauthenticated());
    }
  }
}
```

#### `lib/features/auth/presentation/pages/splash_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Defer to next microtask — ensures BlocProvider tree is fully settled before dispatch
    Future.microtask(
      () => context.read<AuthBloc>().add(const AuthCheckRequested()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthAuthenticated():
            AppRouter.updateAuthState(isAuthenticated: true);
            context.goNamed(AppRoutes.productList);
          case AuthUnauthenticated():
          case AuthError():
            AppRouter.updateAuthState(isAuthenticated: false);
            context.goNamed(AppRoutes.login);
          case AuthInitial():
          case AuthLoading():
            // No navigation — wait for auth check to complete.
            break;
        }
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.blue),
              SizedBox(height: 16),
              Text('Flutter E-Commerce', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 32),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### `lib/features/auth/presentation/pages/login_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            AppRouter.updateAuthState(isAuthenticated: true);
            context.goNamed(AppRoutes.productList);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Password is required' : null,
                  ),
                  const SizedBox(height: 32),
                  if (state is AuthLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _onSubmit,
                      child: const Text('Sign In'),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.goNamed(AppRoutes.register),
                    child: const Text("Don't have an account? Register"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

#### `lib/features/auth/presentation/pages/register_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Register Page — stub'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.goNamed(AppRoutes.login),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### PRODUCT FEATURE (abbreviated — follow auth pattern)

#### `lib/features/product/domain/entities/product_entity.dart`

```dart
import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final int stockQuantity;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.stockQuantity,
  });

  bool get isInStock => stockQuantity > 0;

  @override
  List<Object?> get props =>
      [id, name, description, price, imageUrl, categoryId, stockQuantity];
}
```

#### `lib/features/product/domain/repositories/product_repository.dart`

```dart
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

abstract interface class ProductRepository {
  Future<Result<List<ProductEntity>>> getProducts({int page = 1, int limit = 20});
  Future<Result<ProductEntity>> getProductById(String id);
}
```

#### `lib/features/product/domain/usecases/get_products_usecase.dart`

```dart
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository _repository;
  const GetProductsUseCase(this._repository);

  Future<Result<List<ProductEntity>>> call({int page = 1}) =>
      _repository.getProducts(page: page);
}
```

#### `lib/features/product/data/models/product_model.dart`

```dart
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.categoryId,
    required super.stockQuantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      stockQuantity: json['stock_quantity'] as int? ?? 0,
    );
  }

  static List<ProductModel> get mockList => [
        const ProductModel(
          id: 'p-001',
          name: 'Wireless Headphones',
          description: 'Premium noise-cancelling headphones',
          price: 149.99,
          imageUrl: 'https://via.placeholder.com/300',
          categoryId: 'cat-electronics',
          stockQuantity: 50,
        ),
        const ProductModel(
          id: 'p-002',
          name: 'Running Shoes',
          description: 'Lightweight performance shoes',
          price: 89.99,
          imageUrl: 'https://via.placeholder.com/300',
          categoryId: 'cat-sports',
          stockQuantity: 120,
        ),
      ];
}
```

#### `lib/features/product/data/datasources/product_remote_datasource.dart`

```dart
import 'package:flutter_ecommerce/features/product/data/models/product_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20});
  Future<ProductModel> getProductById(String id);
}
```

#### `lib/features/product/data/datasources/product_remote_datasource_impl.dart`

```dart
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/data/models/product_model.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient _dioClient;
  const ProductRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ProductModel.mockList; // TODO: replace with _dioClient.dio.get(...)
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ProductModel.mockList.first;
  }
}
```

#### `lib/features/product/data/repositories/product_repository_impl.dart`

```dart
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  const ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<ProductEntity>>> getProducts({int page = 1, int limit = 20}) async {
    try {
      final products = await _remoteDataSource.getProducts(page: page, limit: limit);
      return Success(products);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<ProductEntity>> getProductById(String id) async {
    try {
      final product = await _remoteDataSource.getProductById(id);
      return Success(product);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }
}
```

#### `lib/features/product/presentation/bloc/product_event.dart`

```dart
import 'package:equatable/equatable.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

final class ProductFetchRequested extends ProductEvent {
  final int page;
  const ProductFetchRequested({this.page = 1});
  @override
  List<Object?> get props => [page];
}

final class ProductDetailRequested extends ProductEvent {
  final String productId;
  const ProductDetailRequested(this.productId);
  @override
  List<Object?> get props => [productId];
}
```

#### `lib/features/product/presentation/bloc/product_state.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

sealed class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

final class ProductInitial extends ProductState {
  const ProductInitial();
}

final class ProductLoading extends ProductState {
  const ProductLoading();
}

final class ProductListLoaded extends ProductState {
  final List<ProductEntity> products;
  const ProductListLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

final class ProductDetailLoaded extends ProductState {
  final ProductEntity product;
  const ProductDetailLoaded(this.product);
  @override
  List<Object?> get props => [product];
}

final class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}
```

#### `lib/features/product/presentation/bloc/product_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_event.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase _getProductsUseCase;
  final ProductRepository _productRepository;

  ProductBloc({
    required GetProductsUseCase getProductsUseCase,
    required ProductRepository productRepository,
  })  : _getProductsUseCase = getProductsUseCase,
        _productRepository = productRepository,
        super(const ProductInitial()) {
    on<ProductFetchRequested>(_onFetchRequested);
    on<ProductDetailRequested>(_onDetailRequested);
  }

  Future<void> _onFetchRequested(
    ProductFetchRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    final result = await _getProductsUseCase(page: event.page);
    switch (result) {
      case Success(:final data):
        emit(ProductListLoaded(data));
      case ResultFailure(:final failure):
        emit(ProductError(failure.message));
    }
  }

  Future<void> _onDetailRequested(
    ProductDetailRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    final result = await _productRepository.getProductById(event.productId);
    switch (result) {
      case Success(:final data):
        emit(ProductDetailLoaded(data));
      case ResultFailure(:final failure):
        emit(ProductError(failure.message));
    }
  }
}
```

#### `lib/features/product/presentation/pages/product_list_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_event.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_state.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return switch (state) {
            ProductLoading() => const Center(child: CircularProgressIndicator()),
            ProductListLoaded(:final products) => ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    onTap: () => context.goNamed(
                      AppRoutes.productDetail,
                      pathParameters: {'productId': product.id},
                    ),
                  );
                },
              ),
            ProductError(:final message) => Center(child: Text(message)),
            _ => const Center(child: Text('Tap to load products')),
          };
        },
      ),
    );
  }
}
```

#### `lib/features/product/presentation/pages/product_detail_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_event.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_state.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductDetailRequested(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return switch (state) {
            ProductLoading() => const Center(child: CircularProgressIndicator()),
            ProductDetailLoaded(:final product) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('\$${product.price.toStringAsFixed(2)}'),
                    Text(product.description),
                  ],
                ),
              ),
            ProductError(:final message) => Center(child: Text(message)),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
```

---

### CART FEATURE (Cubit)

#### `lib/features/cart/domain/entities/cart_item_entity.dart`

```dart
import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  const CartItemEntity({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get subtotal => price * quantity;

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
    );
  }

  @override
  List<Object?> get props => [productId, productName, price, quantity, imageUrl];
}
```

#### `lib/features/cart/domain/repositories/cart_repository.dart`

```dart
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';

abstract interface class CartRepository {
  Future<Result<List<CartItemEntity>>> getCartItems();
  Future<Result<void>> addItem(CartItemEntity item);
  Future<Result<void>> removeItem(String productId);
  Future<Result<void>> clearCart();
}
```

#### `lib/features/cart/presentation/cubit/cart_state.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';

sealed class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartLoaded extends CartState {
  final List<CartItemEntity> items;

  const CartLoaded(this.items);

  double get totalPrice =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items];
}

final class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object?> get props => [message];
}
```

#### `lib/features/cart/presentation/cubit/cart_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;

  CartCubit(this._repository) : super(const CartInitial());

  Future<void> loadCart() async {
    emit(const CartLoading());
    final result = await _repository.getCartItems();
    switch (result) {
      case Success(:final data):
        emit(CartLoaded(data));
      case ResultFailure(:final failure):
        emit(CartError(failure.message));
    }
  }

  Future<void> addItem(CartItemEntity item) async {
    await _repository.addItem(item);
    await loadCart();
  }

  Future<void> removeItem(String productId) async {
    await _repository.removeItem(productId);
    await loadCart();
  }

  Future<void> clearCart() async {
    await _repository.clearCart();
    emit(const CartLoaded([]));
  }
}
```

#### `lib/features/cart/presentation/pages/cart_page.dart`

```dart
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: const Center(child: Text('Cart — stub')),
    );
  }
}
```

---

### REMAINING FEATURE STUBS

For **checkout**, **order**, and **profile**, create minimal stubs following the same patterns. Full entity/repo/usecase/bloc files are omitted here for brevity — use the auth and product features above as templates. The critical files needed for the app to compile (imported by the router) are the page files:

#### `lib/features/checkout/presentation/pages/checkout_page.dart`

```dart
import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: const Center(child: Text('Checkout — stub')),
    );
  }
}
```

#### `lib/features/checkout/presentation/pages/checkout_success_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';

class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Placed!')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text('Your order has been placed!'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoutes.orderList),
              child: const Text('View Orders'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### `lib/features/order/presentation/pages/order_list_page.dart`

```dart
import 'package:flutter/material.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: const Center(child: Text('Order List — stub')),
    );
  }
}
```

#### `lib/features/order/presentation/pages/order_detail_page.dart`

```dart
import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #$orderId')),
      body: const Center(child: Text('Order Detail — stub')),
    );
  }
}
```

#### `lib/features/profile/presentation/pages/profile_page.dart`

```dart
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile — stub')),
    );
  }
}
```

#### `lib/features/profile/presentation/pages/edit_profile_page.dart`

```dart
import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: const Center(child: Text('Edit Profile — stub')),
    );
  }
}
```

---

### CART STUB IMPLEMENTATIONS (required for DI registration)

> **Architecture note:** `CartRepositoryImpl` uses an in-memory `List<CartItemEntity>` for MVP — cart data does not persist across app restarts. `CartLocalDataSource` and `CartItemModel` are scaffolded here as the persistence layer for a future sprint. They are NOT wired in `injection_container.dart` yet. Do not pass `CartLocalDataSource` to `CartRepositoryImpl` until you are ready to implement SharedPreferences persistence — leave the in-memory stub as-is for now.

#### `lib/features/cart/data/datasources/cart_local_datasource.dart`

```dart
// Deferred — will replace in-memory CartRepositoryImpl in a future sprint.
// Not registered in injection_container.dart yet.
import 'package:flutter_ecommerce/features/cart/data/models/cart_item_model.dart';

abstract interface class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> saveCartItems(List<CartItemModel> items);
  Future<void> clearCart();
}
```

#### `lib/features/cart/data/models/cart_item_model.dart`

```dart
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.productId,
    required super.productName,
    required super.price,
    required super.quantity,
    required super.imageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_name': productName,
        'price': price,
        'quantity': quantity,
        'image_url': imageUrl,
      };
}
```

#### `lib/features/cart/data/repositories/cart_repository_impl.dart`

```dart
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final List<CartItemEntity> _items = [];

  @override
  Future<Result<List<CartItemEntity>>> getCartItems() async =>
      Success(List.unmodifiable(_items));

  @override
  Future<Result<void>> addItem(CartItemEntity item) async {
    final index = _items.indexWhere((i) => i.productId == item.productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> removeItem(String productId) async {
    _items.removeWhere((i) => i.productId == productId);
    return const Success(null);
  }

  @override
  Future<Result<void>> clearCart() async {
    _items.clear();
    return const Success(null);
  }
}
```

---

### UPDATED `lib/core/di/injection_container.dart` — with all features

```dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';

// Auth
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';

// Product
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/product/data/repositories/product_repository_impl.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';

// Cart
import 'package:flutter_ecommerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:flutter_ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── External ──────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<LocalStorage>(
    () => LocalStorage(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ── Auth ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  // AuthBloc is a singleton — the router's refresh stream reads from it,
  // so there must be exactly one instance app-wide. Do NOT use registerFactory here.
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // ── Product ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl<ProductRepository>()),
  );
  sl.registerFactory<ProductBloc>(
    () => ProductBloc(
      getProductsUseCase: sl<GetProductsUseCase>(),
      productRepository: sl<ProductRepository>(),
    ),
  );

  // ── Cart ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl());
  sl.registerFactory<CartCubit>(() => CartCubit(sl<CartRepository>()));

  // ── Checkout / Order / Profile ────────────────────────────────────────────
  // Register when full implementations are added in subsequent development sprints.
}
```

### `lib/app/app.dart` — add MultiBlocProvider for global BLoCs

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/router/app_router.dart';
import 'package:flutter_ecommerce/app/theme/app_theme.dart';
import 'package:flutter_ecommerce/core/constants/app_constants.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<CartCubit>(create: (_) => sl<CartCubit>()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.light(),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

> **Note on DI rules:**
> - `AuthBloc` → `registerLazySingleton` — one instance app-wide (router reads from it). Provided at root via `MultiBlocProvider`.
> - `CartCubit` → `registerLazySingleton` — one cart state app-wide. Provided at root via `MultiBlocProvider`.
> - `ProductBloc` → `registerFactory` — fresh instance per route. Wrap each product page in the GoRouter builder: `BlocProvider(create: (_) => sl<ProductBloc>(), child: const ProductListPage())`. See Phase 3 router update below.
> - Never provide `AuthBloc` again at the route level — it will create a second, disconnected instance that breaks the auth redirect guard.

## Checklist

**Auth feature**
- [ ] Create `lib/features/auth/domain/entities/user_entity.dart`
- [ ] Create `lib/features/auth/domain/repositories/auth_repository.dart`
- [ ] Create `lib/features/auth/domain/usecases/login_usecase.dart`
- [ ] Create `lib/features/auth/data/models/user_model.dart`
- [ ] Create `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- [ ] Create `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart`
- [ ] Create `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [ ] Create `lib/features/auth/presentation/bloc/auth_event.dart`
- [ ] Create `lib/features/auth/presentation/bloc/auth_state.dart`
- [ ] Create `lib/features/auth/presentation/bloc/auth_bloc.dart`
- [ ] Create `lib/features/auth/presentation/pages/splash_page.dart`
- [ ] Create `lib/features/auth/presentation/pages/login_page.dart`
- [ ] Create `lib/features/auth/presentation/pages/register_page.dart`
- [ ] Create empty `lib/features/auth/presentation/widgets/.gitkeep`

**Product feature**
- [ ] Create all domain, data, and presentation files following auth pattern above
- [ ] Create `lib/features/product/presentation/pages/product_list_page.dart`
- [ ] Create `lib/features/product/presentation/pages/product_detail_page.dart`

**Cart feature**
- [ ] Create `lib/features/cart/domain/entities/cart_item_entity.dart`
- [ ] Create `lib/features/cart/domain/repositories/cart_repository.dart`
- [ ] Create `lib/features/cart/data/models/cart_item_model.dart`
- [ ] Create `lib/features/cart/data/repositories/cart_repository_impl.dart`
- [ ] Create `lib/features/cart/presentation/cubit/cart_state.dart`
- [ ] Create `lib/features/cart/presentation/cubit/cart_cubit.dart`
- [ ] Create `lib/features/cart/presentation/pages/cart_page.dart`

**Checkout, Order, Profile features (page stubs)**
- [ ] Create all 6 page stub files listed above
- [ ] Create minimal domain entities for each feature (even if just an ID field)

**DI wiring**
- [ ] Update `lib/core/di/injection_container.dart` with full feature registrations
- [ ] Update `lib/app/app.dart` to use `MultiBlocProvider` with AuthBloc and CartCubit

**Wire GoRouterRefreshStream to real AuthBloc stream**

After `AuthBloc` is registered as a singleton, update `app/router/app_router.dart` to remove the placeholder `StreamController` and wire the real BLoC stream:

```dart
// In app_router.dart — replace the placeholder StreamController with:
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    // Wire to real AuthBloc stream — refreshes router on every state change
    refreshListenable: GoRouterRefreshStream(
      sl<AuthBloc>().stream,
    ),
    redirect: (BuildContext context, GoRouterState state) {
      final path = state.uri.path;
      final isGoingToAuth = path == '/login' ||
          path == '/register' ||
          path == '/splash';

      // Derive auth state directly from the BLoC — no static bool needed
      final authState = sl<AuthBloc>().state;
      final isAuthenticated = authState is AuthAuthenticated;

      if (!isAuthenticated && !isGoingToAuth) return '/login';
      if (isAuthenticated && isGoingToAuth) return '/products';
      return null;
    },
    routes: [ /* same routes as Phase 3 */ ],
  );
}
```

- [ ] Remove `_authStreamController`, `_isAuthenticated`, and `updateAuthState()` static method from `AppRouter`
- [ ] Remove all `AppRouter.updateAuthState(...)` calls from `splash_page.dart` and `login_page.dart` — the router now re-evaluates automatically on every BLoC state change

**Verification**
- [ ] Run `flutter analyze lib/` — 0 errors (warnings about unused variables in stubs are acceptable)
- [ ] Note: `dart run build_runner build` is a no-op in this phase — no `@freezed` annotations are used yet (all entities use plain `Equatable`). Build runner is installed for future use; skip this step until freezed annotations are added.
