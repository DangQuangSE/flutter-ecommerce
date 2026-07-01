import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/extensions/string_extensions.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/models/register_otp_extra.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_ambient_background.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_brand_header.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_tab_bar.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_error_banner.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_submit_button.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/terms_agreement_footer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  bool _hasNavigatedToOtp = false;
  bool _hideBlocEmailError = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
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
    _animationController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _hasNavigatedToOtp = false;
        _hideBlocEmailError = false;
      });
      context.read<AuthBloc>().add(
            AuthOtpRequested(email: _emailController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
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
                      child: _RegisterCard(
                        formKey: _formKey,
                        emailController: _emailController,
                        showError: !_hideBlocEmailError,
                        onSubmitted: _onSubmit,
                        onEmailChanged: () {
                          if (!_hideBlocEmailError) {
                            setState(() => _hideBlocEmailError = true);
                          }
                        },
                        hasNavigatedToOtp: _hasNavigatedToOtp,
                        onNavigatedToOtp: () {
                          _hasNavigatedToOtp = true;
                        },
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXl + 8),
                    _AnimatedEntrance(
                      delay: 300,
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

class _RegisterCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool showError;
  final VoidCallback onSubmitted;
  final VoidCallback onEmailChanged;
  final bool hasNavigatedToOtp;
  final VoidCallback onNavigatedToOtp;

  const _RegisterCard({
    required this.formKey,
    required this.emailController,
    required this.showError,
    required this.onSubmitted,
    required this.onEmailChanged,
    required this.hasNavigatedToOtp,
    required this.onNavigatedToOtp,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthTabBar(
                  activeIndex: 1,
                  onLoginTap: () => context.goNamed(AppRoutes.login),
                  onRegisterTap: () {},
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingXl),
                  child: _RegisterFormContent(
                    formKey: formKey,
                    emailController: emailController,
                    showError: showError,
                    onSubmitted: onSubmitted,
                    onEmailChanged: onEmailChanged,
                    hasNavigatedToOtp: hasNavigatedToOtp,
                    onNavigatedToOtp: onNavigatedToOtp,
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

class _RegisterFormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool showError;
  final VoidCallback onSubmitted;
  final VoidCallback onEmailChanged;
  final bool hasNavigatedToOtp;
  final VoidCallback onNavigatedToOtp;

  const _RegisterFormContent({
    required this.formKey,
    required this.emailController,
    required this.showError,
    required this.onSubmitted,
    required this.onEmailChanged,
    required this.hasNavigatedToOtp,
    required this.onNavigatedToOtp,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent && !hasNavigatedToOtp) {
          onNavigatedToOtp();
          context.pushNamed(
            AppRoutes.registerOtp,
            extra: RegisterOtpExtra(email: state.email),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final emailApiError = showError
            ? switch (state) {
                AuthRegisterAccountExists(:final message) => message,
                AuthError(:final message) => message,
                _ => null,
              }
            : null;
        final hasCredentialError = emailApiError != null;

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
              if (emailApiError != null) ...[
                const SizedBox(height: AppSizes.paddingSm + 4),
                LoginErrorBanner(message: emailApiError),
              ],
              const SizedBox(height: AppSizes.paddingXl),
              LoginSubmitButton(
                isLoading: isLoading,
                onPressed: onSubmitted,
                label: AppStrings.registerTitle,
              ),
            ],
          ),
        );
      },
    );
  }
}

