import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';
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
    // Defer to next microtask — ensures BlocProvider tree is fully settled
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
          case AuthAuthenticated(:final user):
            if (user.isAdmin) {
              context.goNamed(AppRoutes.adminDashboard);
            } else {
              context.goNamed(AppRoutes.home);
            }
          case AuthUnauthenticated():
          case AuthError():
          case AuthLoginFailed():
          case AuthOtpSent():
          case AuthRegisterOtpError():
          case AuthOtpVerified():
          case AuthRegistrationSuccess():
          case AuthRegisterAccountExists():
            final hasSeen = sl<LocalStorage>().getBool('has_seen_onboarding') ?? false;
            if (!hasSeen) {
              context.goNamed(AppRoutes.onboarding);
            } else {
              context.goNamed(AppRoutes.login);
            }
          case AuthInitial():
          case AuthLoading():
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
              Text(
                'Flutter E-Commerce',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
