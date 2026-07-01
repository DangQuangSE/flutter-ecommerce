import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/extensions/string_extensions.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_error_banner.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_submit_button.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginFormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool showError;
  final VoidCallback onSubmitted;
  final VoidCallback onEmailChanged;
  final VoidCallback onPasswordChanged;
  final VoidCallback onToggleObscure;

  const LoginFormContent({
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.isAdmin) {
            context.goNamed(AppRoutes.adminDashboard);
          } else {
            context.goNamed(AppRoutes.home);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final loginError = showError
            ? switch (state) {
                AuthLoginFailed(:final message) => message,
                _ => null,
              }
            : null;
        return Form(
          key: formKey,
          child: _LoginFormFields(
            emailController: emailController,
            passwordController: passwordController,
            obscurePassword: obscurePassword,
            loginError: loginError,
            isLoading: isLoading,
            onSubmitted: onSubmitted,
            onEmailChanged: onEmailChanged,
            onPasswordChanged: onPasswordChanged,
            onToggleObscure: onToggleObscure,
          ),
        );
      },
    );
  }
}

class _LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final String? loginError;
  final bool isLoading;
  final VoidCallback onSubmitted;
  final VoidCallback onEmailChanged;
  final VoidCallback onPasswordChanged;
  final VoidCallback onToggleObscure;

  const _LoginFormFields({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.loginError,
    required this.isLoading,
    required this.onSubmitted,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginFormField(
          controller: emailController,
          label: AppStrings.emailLabel,
          hint: AppStrings.emailHint,
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          showError: loginError != null,
          onChanged: (_) => onEmailChanged(),
          validator: (v) {
            final value = v?.trim() ?? '';
            if (value.isEmpty) return AppStrings.emailRequired;
            if (!value.isValidEmail) return AppStrings.emailInvalid;
            return null;
          },
        ),
        const SizedBox(height: AppSizes.paddingLg),
        LoginFormField(
          controller: passwordController,
          label: AppStrings.passwordLabel,
          hint: AppStrings.passwordHint,
          prefixIcon: Icons.lock_outlined,
          obscureText: obscurePassword,
          isObscurable: true,
          onToggleObscure: onToggleObscure,
          showError: loginError != null,
          onChanged: (_) => onPasswordChanged(),
          validator: (v) {
            if (v?.isEmpty ?? true) return AppStrings.passwordRequired;
            if ((v?.length ?? 0) < 6) return AppStrings.passwordMinLength(6);
            return null;
          },
        ),
        if (loginError != null) ...[
          const SizedBox(height: AppSizes.paddingSm + 4),
          LoginErrorBanner(message: loginError!),
        ],
        const SizedBox(height: AppSizes.paddingSm + 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => context.pushNamed(AppRoutes.forgotPassword),
            icon: const Icon(Icons.lock_reset_rounded, size: AppSizes.iconSm),
            label: Text(
              AppStrings.forgotPassword,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.forgotPasswordFontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingLg),
        LoginSubmitButton(
          isLoading: isLoading,
          onPressed: onSubmitted,
          label: AppStrings.loginSubmit,
        ),
      ],
    );
  }
}
