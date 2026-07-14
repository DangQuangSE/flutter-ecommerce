import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_bloc.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/models/forgot_password_otp_extra.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/models/forgot_password_reset_extra.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/pages/forgot_password_email_page.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/pages/forgot_password_otp_page.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/pages/forgot_password_reset_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/models/register_otp_extra.dart';
import 'package:flutter_ecommerce/features/auth/presentation/models/register_password_extra.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/register_password_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/splash_page.dart';

RegisterOtpExtra? _resolveRegisterOtpExtra(GoRouterState state) {
  if (state.extra is RegisterOtpExtra) {
    return state.extra as RegisterOtpExtra;
  }
  return switch (sl<AuthBloc>().state) {
    AuthOtpSent(:final email) => RegisterOtpExtra(email: email),
    AuthRegisterOtpError(:final email) => RegisterOtpExtra(email: email),
    _ => null,
  };
}

RegisterPasswordExtra? _resolveRegisterPasswordExtra(GoRouterState state) {
  if (state.extra is RegisterPasswordExtra) {
    return state.extra as RegisterPasswordExtra;
  }
  return switch (sl<AuthBloc>().state) {
    AuthOtpVerified(:final email) => RegisterPasswordExtra(email: email),
    _ => null,
  };
}

List<RouteBase> authRoutes() {
  return [
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
      routes: [
        GoRoute(
          path: 'otp',
          name: AppRoutes.registerOtp,
          redirect: (context, state) {
            final authState = sl<AuthBloc>().state;
            if (authState is AuthOtpVerified) {
              return '/register/password';
            }
            if (state.extra is RegisterOtpExtra) return null;
            if (authState is AuthOtpSent ||
                authState is AuthRegisterOtpError) {
              return null;
            }
            return '/register';
          },
          builder: (context, state) {
            final extra = _resolveRegisterOtpExtra(state);
            if (extra == null) return const RegisterPage();
            return OtpVerificationPage(extra: extra);
          },
        ),
        GoRoute(
          path: 'password',
          name: AppRoutes.registerPassword,
          redirect: (context, state) {
            final authState = sl<AuthBloc>().state;
            if (authState is AuthRegistrationSuccess) return '/login';
            if (authState is AuthOtpVerified) return null;
            if (state.extra is RegisterPasswordExtra) return null;
            return '/register';
          },
          builder: (context, state) {
            final extra = _resolveRegisterPasswordExtra(state);
            if (extra == null) return const RegisterPage();
            return RegisterPasswordPage(extra: extra);
          },
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) => BlocProvider(
        create: (_) => sl<ForgotPasswordBloc>(),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/forgot-password',
          name: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordEmailPage(),
          routes: [
            GoRoute(
              path: 'otp',
              name: AppRoutes.forgotPasswordOtp,
              redirect: (context, state) {
                if (state.extra is! ForgotPasswordOtpExtra) {
                  return '/forgot-password';
                }
                return null;
              },
              builder: (context, state) {
                final extra = state.extra! as ForgotPasswordOtpExtra;
                return ForgotPasswordOtpPage(extra: extra);
              },
            ),
            GoRoute(
              path: 'reset',
              name: AppRoutes.forgotPasswordReset,
              redirect: (context, state) {
                if (state.extra is! ForgotPasswordResetExtra) {
                  return '/forgot-password';
                }
                return null;
              },
              builder: (context, state) {
                final extra = state.extra! as ForgotPasswordResetExtra;
                return ForgotPasswordResetPage(extra: extra);
              },
            ),
          ],
        ),
      ],
    ),
  ];
}
