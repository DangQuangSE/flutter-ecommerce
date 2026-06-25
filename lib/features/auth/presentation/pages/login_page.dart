import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/extensions/string_extensions.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_ambient_background.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_brand_header.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_tab_bar.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_error_banner.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_submit_button.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/terms_agreement_footer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _hideBlocLoginError = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@sportpro.com');
  final _passwordController = TextEditingController(text: 'Password123');
  bool _obscurePassword = true;
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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _hideBlocLoginError = false);
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      child: _LoginCard(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        showError: !_hideBlocLoginError,
                        onSubmitted: _onSubmit,
                        onEmailChanged: () {
                          if (!_hideBlocLoginError) {
                            setState(() => _hideBlocLoginError = true);
                          }
                        },
                        onPasswordChanged: () {
                          if (!_hideBlocLoginError) {
                            setState(() => _hideBlocLoginError = true);
                          }
                        },
                        onToggleObscure: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingLg),
                    _AnimatedEntrance(
                      delay: 250,
                      controller: _animationController,
                      child: const _OrDivider(),
                    ),
                    const SizedBox(height: AppSizes.paddingLg),
                    _AnimatedEntrance(
                      delay: 300,
                      controller: _animationController,
                      child: const _GoogleSignInButton(),
                    ),
                    const SizedBox(height: AppSizes.paddingXl + 4),
                    _AnimatedEntrance(
                      delay: 400,
                      controller: _animationController,
                      child: const TermsAgreementFooter(),
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

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool showError;
  final VoidCallback onSubmitted;
  final VoidCallback onEmailChanged;
  final VoidCallback onPasswordChanged;
  final VoidCallback onToggleObscure;

  const _LoginCard({
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
      padding: const EdgeInsets.all(1.0), // Creates gradient border line refraction
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
                  child: _LoginFormContent(
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

class _LoginFormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool showError;
  final VoidCallback onSubmitted;
  final VoidCallback onEmailChanged;
  final VoidCallback onPasswordChanged;
  final VoidCallback onToggleObscure;

  const _LoginFormContent({
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
        final hasCredentialError = loginError != null;

        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LoginFormField(
                controller: emailController,
                label: AppStrings.emailLabel,
                hint: AppStrings.emailHint,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                showError: hasCredentialError,
                onChanged: (_) => onEmailChanged(),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) {
                    return AppStrings.emailRequired;
                  }
                  if (!value.isValidEmail) {
                    return AppStrings.emailInvalid;
                  }
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
                showError: hasCredentialError,
                onChanged: (_) => onPasswordChanged(),
                validator: (v) {
                  if (v?.isEmpty ?? true) {
                    return AppStrings.passwordRequired;
                  }
                  if ((v?.length ?? 0) < 6) {
                    return AppStrings.passwordMinLength(6);
                  }
                  return null;
                },
              ),
              if (loginError != null) ...[
                const SizedBox(height: AppSizes.paddingSm + 4),
                LoginErrorBanner(message: loginError),
              ],
              const SizedBox(height: AppSizes.paddingSm + 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.pushNamed(AppRoutes.forgotPassword),
                  icon: const Icon(
                    Icons.lock_reset_rounded,
                    size: AppSizes.iconSm,
                  ),
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
          ),
        );
      },
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.divider.withValues(alpha: 0.6),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Hoặc',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.divider.withValues(alpha: 0.6),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _GoogleSignInButton extends StatefulWidget {
  const _GoogleSignInButton();

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) {
        _scaleController.forward();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập bằng Google đang được thiết lập'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onTapCancel: () => _scaleController.forward(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: AppColors.borderGray.withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'G',
                style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF4285F4), // Google Blue
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Google',
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

