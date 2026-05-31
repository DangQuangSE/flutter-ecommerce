# Phase 3: App Shell

## Requirements
Deliver the app's outer shell: a complete theme system (colors, typography, light theme), a GoRouter configuration with named routes for all 6 features plus an auth redirect guard, and an `App` widget that replaces the Phase 1 placeholder — making the app navigate correctly between at least two routes.

## Steps
1. Build the theme system in `app/theme/` — define the brand color palette in `AppColors`, typography scale in `AppTextStyles`, and assemble them into `AppTheme.light()` using `ThemeData`.
2. Define all named route constants in `app/router/app_routes.dart` as a single abstract class with `static const String` fields for every screen in all 6 features.
3. Implement `app/router/app_router.dart` using GoRouter 14.x — wire `GoRouterRefreshStream` to the auth BLoC stream, add an `redirect` callback that enforces the auth guard, and define `GoRoute` entries for all named routes pointing to the feature page stubs from Phase 4.
4. Replace the `app/app.dart` placeholder with `MaterialApp.router` wired to `AppRouter`, `AppTheme.light()`, and the app name constant.
5. Update `lib/main.dart` to confirm `App` still resolves (no change needed if Phase 1 stub is already correct).

## Success Criteria
- App compiles and launches to the splash/home stub screen without errors
- `GoRouter.of(context).goNamed(AppRoutes.login)` navigates to the login page stub
- `flutter analyze lib/app/` returns 0 issues
- Theme colors resolve correctly (no missing color references)

## Risks
- GoRouter 14.x requires routes to be defined as `GoRoute` with `name:` for `goNamed()` to work — using `path:` only will cause a runtime exception; every route in this plan includes both
- `GoRouterRefreshStream` listens to a `Stream<dynamic>` — the auth BLoC stream is not available until Phase 4; use a `StreamController` placeholder that never emits during Phase 3 to keep the router compiling

---

## Exact File Contents

### `lib/app/theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A73E8);       // Blue
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color primaryLight = Color(0xFF63A4FF);
  static const Color accent = Color(0xFFFF6D00);        // Orange CTA
  static const Color accentLight = Color(0xFFFF9E40);

  // ── Neutral ───────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
}
```

### `lib/app/theme/app_text_styles.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

abstract final class AppTextStyles {
  static const String _fontFamily = 'Roboto'; // Flutter default; swap to custom font later

  // ── Display ───────────────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  // ── Heading ───────────────────────────────────────────────────────────────
  static const TextStyle headingLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Body ──────────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ── Label / Caption ───────────────────────────────────────────────────────
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle price = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
  );
}
```

### `lib/app/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/app/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.accent,
        onSecondary: AppColors.textOnPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headingMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: AppColors.textHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        headlineSmall: AppTextStyles.headingSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelMedium: AppTextStyles.label,
      ),
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}
```

### `lib/app/router/app_routes.dart`

```dart
/// All named route constants for GoRouter.
/// Use `context.goNamed(AppRoutes.xxx)` — never hardcode path strings.
abstract final class AppRoutes {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';

  // ── Main shell ────────────────────────────────────────────────────────────
  static const String home = 'home';

  // ── Product ───────────────────────────────────────────────────────────────
  static const String productList = 'product-list';
  static const String productDetail = 'product-detail';

  // ── Cart ──────────────────────────────────────────────────────────────────
  static const String cart = 'cart';

  // ── Checkout ──────────────────────────────────────────────────────────────
  static const String checkout = 'checkout';
  static const String checkoutSuccess = 'checkout-success';

  // ── Order ─────────────────────────────────────────────────────────────────
  static const String orderList = 'order-list';
  static const String orderDetail = 'order-detail';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profile = 'profile';
  static const String editProfile = 'edit-profile';
}
```

### `lib/app/router/app_router.dart`

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';

// Feature page imports — these stubs are created in Phase 4.
// Add each import as you create the corresponding page file.
import 'package:flutter_ecommerce/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/splash_page.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/product_list_page.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/product_detail_page.dart';
import 'package:flutter_ecommerce/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/pages/checkout_success_page.dart';
import 'package:flutter_ecommerce/features/order/presentation/pages/order_list_page.dart';
import 'package:flutter_ecommerce/features/order/presentation/pages/order_detail_page.dart';
import 'package:flutter_ecommerce/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_ecommerce/features/profile/presentation/pages/edit_profile_page.dart';

class AppRouter {
  /// Replace this with `sl<AuthBloc>().stream` in Phase 4 once AuthBloc exists.
  static final StreamController<dynamic> _authStreamController =
      StreamController<dynamic>.broadcast();

  static bool _isAuthenticated = false;

  /// Call this from the AuthBloc listener (Phase 4) to update auth state.
  static void updateAuthState({required bool isAuthenticated}) {
    _isAuthenticated = isAuthenticated;
    _authStreamController.add(isAuthenticated);
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(_authStreamController.stream),
    redirect: (BuildContext context, GoRouterState state) {
      // GoRouter 14.x: use state.uri.path (matchedLocation is deprecated)
      final path = state.uri.path;
      final isGoingToAuth = path == '/login' ||
          path == '/register' ||
          path == '/splash';

      if (!_isAuthenticated && !isGoingToAuth) {
        return '/login';
      }
      if (_isAuthenticated && isGoingToAuth) {
        return '/products';
      }
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // ── Home shell (alias for product list — main screen after login) ────
      GoRoute(
        path: '/home',
        name: AppRoutes.home,
        builder: (context, state) => const ProductListPage(),
      ),

      // ── Product ───────────────────────────────────────────────────────────
      // ProductBloc is registerFactory — wrap each page so each route gets
      // its own fresh BLoC instance. Do NOT add ProductBloc to the root
      // MultiBlocProvider or stale state will persist across navigation.
      GoRoute(
        path: '/products',
        name: AppRoutes.productList,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProductBloc>(),
          child: const ProductListPage(),
        ),
        routes: [
          GoRoute(
            path: ':productId',
            name: AppRoutes.productDetail,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<ProductBloc>(),
              child: ProductDetailPage(
                productId: state.pathParameters['productId'] ?? '',
              ),
            ),
          ),
        ],
      ),

      // ── Cart ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/cart',
        name: AppRoutes.cart,
        builder: (context, state) => const CartPage(),
      ),

      // ── Checkout ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/checkout',
        name: AppRoutes.checkout,
        builder: (context, state) => const CheckoutPage(),
        routes: [
          GoRoute(
            path: 'success',
            name: AppRoutes.checkoutSuccess,
            builder: (context, state) => const CheckoutSuccessPage(),
          ),
        ],
      ),

      // ── Order ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/orders',
        name: AppRoutes.orderList,
        builder: (context, state) => const OrderListPage(),
        routes: [
          GoRoute(
            path: ':orderId',
            name: AppRoutes.orderDetail,
            builder: (context, state) => OrderDetailPage(
              orderId: state.pathParameters['orderId'] ?? '',
            ),
          ),
        ],
      ),

      // ── Profile ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        name: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: 'edit',
            name: AppRoutes.editProfile,
            builder: (context, state) => const EditProfilePage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error?.message}'),
      ),
    ),
  );
}
```

### `lib/app/app.dart` — final replacement

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/router/app_router.dart';
import 'package:flutter_ecommerce/app/theme/app_theme.dart';
import 'package:flutter_ecommerce/core/constants/app_constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light(),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

## Checklist

- [ ] Create `lib/app/theme/app_colors.dart`
- [ ] Create `lib/app/theme/app_text_styles.dart`
- [ ] Create `lib/app/theme/app_theme.dart`
- [ ] Create `lib/app/router/app_routes.dart`
- [ ] Create `lib/app/router/app_router.dart` (note: imports will show errors until Phase 4 page stubs exist — this is expected)
- [ ] Replace `lib/app/app.dart` with the final version above
- [ ] Confirm `lib/main.dart` still imports `App` correctly (no change needed)
- [ ] Run `flutter analyze lib/app/` after Phase 4 pages exist — must be 0 issues
- [ ] Manually test: launch app, confirm it shows SplashPage stub without crashing
- [ ] Manually test: call `AppRouter.updateAuthState(isAuthenticated: true)` from SplashPage and confirm redirect to ProductListPage
