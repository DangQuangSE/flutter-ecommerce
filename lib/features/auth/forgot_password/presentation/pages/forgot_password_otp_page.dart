import 'dart:async';

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
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_bloc.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_event.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_state.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/models/forgot_password_otp_extra.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/models/forgot_password_reset_extra.dart';

class ForgotPasswordOtpPage extends StatefulWidget {
  final ForgotPasswordOtpExtra extra;

  const ForgotPasswordOtpPage({super.key, required this.extra});

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  final _pinController = TextEditingController();
  Timer? _resendTimer;
  int _resendSeconds = 0;
  String? _inlineError;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
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
    setState(() => _inlineError = null);
    context.read<ForgotPasswordBloc>().add(
          ForgotPasswordOtpSubmitted(
            email: widget.extra.email,
            otpCode: otp,
          ),
        );
  }

  void _onResend() {
    if (_resendSeconds > 0) return;
    _pinController.clear();
    setState(() => _inlineError = null);
    context.read<ForgotPasswordBloc>().add(
          ForgotPasswordResendRequested(email: widget.extra.email),
        );
    _startResendCooldown();
  }

  void _onBackToEmail() {
    if (context.read<ForgotPasswordBloc>().state is ForgotPasswordLoading) {
      return;
    }
    context.pop();
  }

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC1C6D7)),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _onBackToEmail,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordOtpVerified) {
                context.pushNamed(
                  AppRoutes.forgotPasswordReset,
                  extra: ForgotPasswordResetExtra(
                    email: state.email,
                    forgotPasswordToken: state.forgotPasswordToken,
                  ),
                );
              } else if (state is ForgotPasswordResendSuccess) {
                AppSnackBar.show(
                  context,
                  message: AppStrings.otpResent,
                  type: AppSnackBarType.success,
                );
                _pinController.clear();
                setState(() => _inlineError = null);
              } else if (state is ForgotPasswordError) {
                setState(() => _inlineError = state.message);
              }
            },
            builder: (context, state) {
              final isLoading = state is ForgotPasswordLoading;
              final canVerify =
                  !isLoading && _pinController.text.trim().length == 6;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.forgotPasswordOtpTitle,
                    style: GoogleFonts.lexend(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.otpSentToEmail(
                      _maskEmail(widget.extra.email),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (widget.extra.neutralMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.extra.neutralMessage,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.forgotPasswordOtpHelp,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Pinput(
                    controller: _pinController,
                    length: 6,
                    enabled: !isLoading,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onCompleted: (_) => _onVerify(),
                  ),
                  if (_inlineError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _inlineError!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: canVerify ? _onVerify : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const AppLoadingView(
                            size: AppSizes.iconMd,
                            color: Colors.white,
                          )
                        : Text(
                            AppStrings.otpConfirm,
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed:
                        _resendSeconds > 0 || isLoading ? null : _onResend,
                    child: Text(
                      _resendSeconds > 0
                          ? AppStrings.otpResendCountdown(_resendSeconds)
                          : AppStrings.forgotPasswordResendShort,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : _onBackToEmail,
                    child: Text(
                      AppStrings.forgotPasswordBackToEmail,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
