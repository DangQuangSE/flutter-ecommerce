import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/models/register_otp_extra.dart';
import 'package:flutter_ecommerce/features/auth/presentation/models/register_password_extra.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_ambient_background.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_brand_header.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_submit_button.dart';

class OtpVerificationPage extends StatefulWidget {
  final RegisterOtpExtra extra;

  const OtpVerificationPage({super.key, required this.extra});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  Timer? _resendTimer;
  int _resendSeconds = 0;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AuthBloc>().state;
      if (state is AuthRegisterOtpError) {
        _pinController.clear();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].length < 2) return email;
    return '${parts[0][0]}***@${parts[1]}';
  }

  void _onVerify() {
    final otp = _pinController.text.trim();
    if (otp.length != 6) return;
    context.read<AuthBloc>().add(
          AuthOtpVerifyRequested(
            email: widget.extra.email,
            otp: otp,
          ),
        );
  }

  void _onResend() {
    if (_resendSeconds > 0) return;
    _pinController.clear();
    context.read<AuthBloc>().add(
          AuthResendOtpRequested(email: widget.extra.email),
        );
    _startResendCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 44,
      height: 48,
      textStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.borderGray.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
    );

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
                      child: _OtpCard(
                        email: _maskEmail(widget.extra.email),
                        pinController: _pinController,
                        defaultPinTheme: defaultPinTheme,
                        onVerify: _onVerify,
                        onResend: _onResend,
                        resendSeconds: _resendSeconds,
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

class _OtpCard extends StatelessWidget {
  final String email;
  final TextEditingController pinController;
  final PinTheme defaultPinTheme;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final int resendSeconds;

  const _OtpCard({
    required this.email,
    required this.pinController,
    required this.defaultPinTheme,
    required this.onVerify,
    required this.onResend,
    required this.resendSeconds,
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
                if (state is AuthOtpVerified) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    final location = GoRouterState.of(context).uri.path;
                    if (location != '/register/password') {
                      context.goNamed(
                        AppRoutes.registerPassword,
                        extra: RegisterPasswordExtra(email: state.email),
                      );
                    }
                  });
                } else if (state is AuthOtpSent) {
                  AppSnackBar.show(
                    context,
                    message: AppStrings.otpResent,
                    type: AppSnackBarType.success,
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                final inlineError =
                    state is AuthRegisterOtpError ? state.message : null;
                final canVerify =
                    !isLoading && pinController.text.trim().length == 6;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.otpVerifyEmailTitle.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: AppSizes.fontXxl - 2, // 16
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.otpSentToEmail(email),
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontLg - 1, // 13
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Pinput(
                        controller: pinController,
                        length: 6,
                        enabled: !isLoading,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.6,
                            ),
                          ),
                        ),
                        onChanged: (_) {},
                        onCompleted: (_) => onVerify(),
                      ),
                    ),
                    if (inlineError != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        inlineError,
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.fontSm + 1, // 12
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    LoginSubmitButton(
                      isLoading: isLoading,
                      onPressed: canVerify ? onVerify : null,
                      label: AppStrings.otpConfirm,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed:
                          resendSeconds > 0 || isLoading ? null : onResend,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        resendSeconds > 0
                            ? AppStrings.otpResendCountdown(resendSeconds)
                            : AppStrings.otpResendCode,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
