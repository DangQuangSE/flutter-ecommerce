import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/splash_page.dart';
import 'package:flutter_ecommerce/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_ecommerce/features/notification/presentation/pages/notification_page.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/pages/checkout_success_page.dart';
import 'package:flutter_ecommerce/features/order/presentation/pages/order_detail_page.dart';
import 'package:flutter_ecommerce/features/order/presentation/pages/order_list_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/product_detail_page.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/product_list_page.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/home_page.dart';
import 'package:flutter_ecommerce/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter_ecommerce/features/profile/presentation/pages/profile_page.dart';

/// GoRouterRefreshStream was removed from go_router 5+; implement manually.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    // Wired to the AuthBloc singleton — router re-evaluates on every auth state change
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    redirect: (BuildContext context, GoRouterState state) {
      final path = state.uri.path;
      final isGoingToAuth =
          path == '/login' || path == '/register' || path == '/splash';

      // Derive auth status from BLoC state — no static bool needed
      final isAuthenticated = sl<AuthBloc>().state is AuthAuthenticated;

      if (!isAuthenticated && !isGoingToAuth) return '/login';
      if (isAuthenticated && isGoingToAuth) return '/products';
      return null;
    },
    routes: [
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

      // Home route (main screen after login)
      GoRoute(
        path: '/home',
        name: AppRoutes.home,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProductBloc>(),
          child: const HomePage(),
        ),
      ),

      // ProductBloc is registerFactory — wrap each route in its own BlocProvider
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

      GoRoute(
        path: '/cart',
        name: AppRoutes.cart,
        builder: (context, state) => const CartPage(),
      ),

      GoRoute(
        path: '/notifications',
        name: AppRoutes.notificationList,
        builder: (context, state) => const NotificationPage(),
      ),

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
      body: Center(child: Text('Page not found: ${state.error?.message}')),
    ),
  );
}
