import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';

// Route modules
import 'package:flutter_ecommerce/app/router/auth_routes.dart';
import 'package:flutter_ecommerce/app/router/admin_routes.dart';
import 'package:flutter_ecommerce/app/router/customer_routes.dart';

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
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    redirect: (BuildContext context, GoRouterState state) {
      final path = state.uri.path;
      final isForgotPasswordFlow = path.startsWith('/forgot-password');
      final isGoingToAuth = path == '/login' ||
          path == '/register' ||
          path == '/register/otp' ||
          path == '/register/password' ||
          path == '/splash' ||
          isForgotPasswordFlow;

      final authState = sl<AuthBloc>().state;
      if (authState is AuthRegistrationSuccess) {
        if (path.startsWith('/register')) return '/login';
        return null;
      }
      if (authState is AuthOtpVerified && path == '/register/otp') {
        return '/register/password';
      }
      if (authState is AuthOtpSent ||
          authState is AuthRegisterOtpError ||
          authState is AuthOtpVerified) {
        return null;
      }

      final isAuthenticated = authState is AuthAuthenticated;

      if (!isAuthenticated && !isGoingToAuth) return '/login';

      if (isAuthenticated) {
        final user = authState.user;
        if (isForgotPasswordFlow) {
          return user.isAdmin ? '/admin' : '/home';
        }
        if (user.isAdmin) {
          if (isGoingToAuth || path == '/home') return '/admin';
        } else {
          if (isGoingToAuth) return '/home';
          if (path.startsWith('/admin')) return '/home';
        }
      }

      return null;
    },
    routes: [
      ...authRoutes(),
      ...adminRoutes(),
      ...customerRoutes(),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error?.message}')),
    ),
  );
}
