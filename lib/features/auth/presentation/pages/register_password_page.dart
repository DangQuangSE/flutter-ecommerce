import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/models/register_password_extra.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_ambient_background.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_brand_header.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_submit_button.dart';

class RegisterPasswordPage extends StatefulWidget {
  final RegisterPasswordExtra extra;

  const RegisterPasswordPage({super.key, required this.extra});

  @override
  State<RegisterPasswordPage> createState() => _RegisterPasswordPageState();
}

class _RegisterPasswordPageState extends State<RegisterPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterPasswordSubmitted(
              email: widget.extra.email,
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => context.goNamed(AppRoutes.register),
        ),
      ),
      body: Stack(
        children: [
          const AuthAmbientBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXl,
                  vertical: AppSizes.paddingXl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AnimatedEntrance(
                      delay: 0,
                      controller: _animationController,
                      child: const AuthBrandHeader(),
                    ),
                    const SizedBox(height: AppSizes.paddingXl + 8),
                    _AnimatedEntrance(
                      delay: 150,
                      controller: _animationController,
                      child: _PasswordCard(
                        formKey: _formKey,
                        passwordController: _passwordController,
                        confirmController: _confirmController,
                        obscurePassword: _obscurePassword,
                        obscureConfirm: _obscureConfirm,
                        onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        onToggleConfirm: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        onSubmit: _onSubmit,
                        email: widget.extra.email,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final int delay;
  final AnimationController controller;

  const _AnimatedEntrance({
    required this.child,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final start = delay / 1000.0;
    final end = (delay + 450) / 1000.0;

    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: curvedAnimation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 24 * (1.0 - curvedAnimation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _PasswordCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;
  final String email;

  const _PasswordCard({
    required this.formKey,
    required this.passwordController,
    required this.confirmController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
      ),
      padding: const EdgeInsets.all(1.0), // Gradient border refraction
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl - 1),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: AppColors.white.withValues(alpha: 0.76),
            padding: const EdgeInsets.all(AppSizes.paddingXl),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthRegistrationSuccess) {
                  AppSnackBar.show(
                    context,
                    message: AppStrings.registerSuccessLoginPrompt,
                    type: AppSnackBarType.success,
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    final location = GoRouterState.of(context).uri.path;
                    if (location != '/login') {
                      context.goNamed(AppRoutes.login);
                    }
                  });
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                final apiError = state is AuthError ? state.message : null;
                final hasError = apiError != null;

                return Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Tạo mật khẩu'.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppSizes.fontXxl - 2, // 16
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hoàn tất đăng ký cho $email',
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.fontLg - 1, // 13
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      LoginFormField(
                        controller: passwordController,
                        label: 'MẬT KHẨU',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outlined,
                        obscureText: obscurePassword,
                        isObscurable: true,
                        onToggleObscure: onTogglePassword,
                        showError: hasError,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải chứa ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingLg),
                      LoginFormField(
                        controller: confirmController,
                        label: 'XÁC NHẬN MẬT KHẨU',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_clock_outlined,
                        obscureText: obscureConfirm,
                        isObscurable: true,
                        onToggleObscure: onToggleConfirm,
                        showError: hasError,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập lại mật khẩu';
                          }
                          if (value != passwordController.text) {
                            return 'Mật khẩu xác nhận không khớp';
                          }
                          return null;
                        },
                      ),
                      if (apiError != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          apiError,
                          style: GoogleFonts.inter(
                            fontSize: AppSizes.fontSm + 1, // 12
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      LoginSubmitButton(
                        isLoading: isLoading,
                        onPressed: onSubmit,
                        label: 'Hoàn tất đăng ký',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
