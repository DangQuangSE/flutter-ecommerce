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
