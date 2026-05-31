# BLoC / Cubit Patterns

Working code patterns derived from the actual project codebase.

## AuthBloc — Full Example (template for complex BLoC)

```dart
// auth_event.dart
sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override List<Object?> get props => [];
}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override List<Object?> get props => [email, password];
}

final class AuthLogoutRequested extends AuthEvent { const AuthLogoutRequested(); }
final class AuthCheckRequested extends AuthEvent { const AuthCheckRequested(); }
```

```dart
// auth_state.dart
sealed class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}

final class AuthInitial extends AuthState { const AuthInitial(); }
final class AuthLoading extends AuthState { const AuthLoading(); }

final class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override List<Object?> get props => [message];
}
```

```dart
// auth_bloc.dart
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
    final result = await _loginUseCase(email: event.email, password: event.password);
    switch (result) {
      case Success(:final data): emit(AuthAuthenticated(data));
      case ResultFailure(:final failure): emit(AuthError(failure.message));
    }
  }
}
```

---

## CartCubit — Full Example (template for simple Cubit)

```dart
// cart_state.dart
sealed class CartState extends Equatable {
  const CartState();
  @override List<Object?> get props => [];
}

final class CartInitial extends CartState { const CartInitial(); }
final class CartLoading extends CartState { const CartLoading(); }

final class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  const CartLoaded(this.items);
  double get totalPrice => items.fold(0, (sum, item) => sum + item.subtotal);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  @override List<Object?> get props => [items];
}

final class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override List<Object?> get props => [message];
}
```

```dart
// cart_cubit.dart
class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;
  CartCubit(this._repository) : super(const CartInitial());

  Future<void> loadCart() async {
    emit(const CartLoading());
    final result = await _repository.getCartItems();
    switch (result) {
      case Success(:final data): emit(CartLoaded(data));
      case ResultFailure(:final failure): emit(CartError(failure.message));
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
}
```

---

## Consuming BLoC in a Page

```dart
// ✅ SplashPage — dispatch on init safely
class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthCheckRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthAuthenticated():
            context.goNamed(AppRoutes.productList);
          case AuthUnauthenticated():
          case AuthError():
            context.goNamed(AppRoutes.login);
          case AuthInitial():
          case AuthLoading():
            break; // explicit — no default
        }
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
```

```dart
// ✅ Builder with switch expression
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) => switch (state) {
    ProductLoading() => const CircularProgressIndicator(),
    ProductLoaded(:final products) => ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) => Text(products[i].name),
      ),
    ProductError(:final message) => Text(message),
    _ => const SizedBox.shrink(),
  },
)
```

---

## Route-Level BLoC Provider (factory BLoCs only)

```dart
// In app_router.dart — factory BLoC wrapped per route
GoRoute(
  path: '/products',
  name: AppRoutes.productList,
  builder: (context, state) => BlocProvider(
    create: (_) => sl<ProductBloc>(),  // fresh instance per navigation
    child: const ProductListPage(),
  ),
),
```

Root `MultiBlocProvider` (in `app.dart`) only holds singleton BLoCs:
- `AuthBloc` — app-wide, router depends on it
- `CartCubit` — app-wide cart state
- `ProfileCubit` — app-wide profile state
