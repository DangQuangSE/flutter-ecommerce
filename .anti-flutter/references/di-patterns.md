# Dependency Injection Patterns (get_it)

Working DI code derived from `lib/core/di/injection_container.dart`.

## Registration Rules — Quick Reference

| What | Method | Why |
|------|--------|-----|
| SharedPreferences | `registerLazySingleton` | Initialized once |
| DioClient | `registerLazySingleton` | Expensive, shared |
| LocalStorage | `registerLazySingleton` | Thin wrapper |
| Remote DataSource | `registerLazySingleton` | Stateless |
| Repository impl | `registerLazySingleton` | Stateless |
| Use case | `registerLazySingleton` | Stateless function |
| **ProductBloc** | **`registerFactory`** | Per-route, no stale state |
| **CheckoutBloc** | **`registerFactory`** | Per-route |
| **OrderBloc** | **`registerFactory`** | Per-route |
| **AuthBloc** | **`registerLazySingleton`** | Router stream reads it |
| **CartCubit** | **`registerLazySingleton`** | App-wide cart |
| **ProfileCubit** | **`registerLazySingleton`** | App-wide profile |

## Full injection_container.dart Structure

```dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// core imports
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';

// feature imports (auth, product, cart, ...)

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {

  // ── External (await first) ───────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // ── Core ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage(sl()));
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ── Auth (singleton — router reads AuthBloc.stream) ──────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(loginUseCase: sl(), authRepository: sl()),
  );

  // ── Product (factory — one BLoC per route) ────────────────────────────────
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

  // ── Cart (singleton — app-wide state) ────────────────────────────────────
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl());
  sl.registerLazySingleton<CartCubit>(() => CartCubit(sl<CartRepository>()));

  // ── Profile (singleton — app-wide state) ─────────────────────────────────
  sl.registerLazySingleton<ProfileCubit>(() => ProfileCubit());
}
```

## app.dart MultiBlocProvider

Only singleton BLoCs/Cubits go in the root provider:

```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<CartCubit>(create: (_) => sl<CartCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
        // ❌ Never add ProductBloc, CheckoutBloc, OrderBloc here
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

## Accessing DI in Tests

```dart
// In test setUp
setUp(() {
  sl.reset();
  sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(loginUseCase: sl(), authRepository: sl()),
  );
});
```
