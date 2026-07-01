import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_tab_bar.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_form_content.dart';
import 'package:go_router/go_router.dart';

class LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool showError;
  final VoidCallback onSubmitted;
  final VoidCallback onEmailChanged;
  final VoidCallback onPasswordChanged;
  final VoidCallback onToggleObscure;

  const LoginCard({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.showError,
    required this.onSubmitted,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onToggleObscure,
  });

  BoxDecoration get _decoration => BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _decoration,
      padding: const EdgeInsets.all(1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl - 1),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: AppColors.white.withValues(alpha: 0.76),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthTabBar(
                  activeIndex: 0,
                  onLoginTap: () {},
                  onRegisterTap: () => context.goNamed(AppRoutes.register),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingXl),
                  child: LoginFormContent(
                    formKey: formKey,
                    emailController: emailController,
                    passwordController: passwordController,
                    obscurePassword: obscurePassword,
                    showError: showError,
                    onSubmitted: onSubmitted,
                    onEmailChanged: onEmailChanged,
                    onPasswordChanged: onPasswordChanged,
                    onToggleObscure: onToggleObscure,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
