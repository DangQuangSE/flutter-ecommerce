import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/models/register_otp_extra.dart';
import 'package:flutter_ecommerce/features/auth/presentation/models/register_password_extra.dart';

class OtpVerificationPage extends StatefulWidget {
  final RegisterOtpExtra extra;

  const OtpVerificationPage({super.key, required this.extra});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _pinController = TextEditingController();
  Timer? _resendTimer;
  int _resendSeconds = 0;

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
  void initState() {
    super.initState();
    _startResendCooldown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AuthBloc>().state;
      if (state is AuthRegisterOtpError) {
        _pinController.clear();
      }
    });
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
          onPressed: () => context.goNamed(AppRoutes.register),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthOtpVerified) {
                // Router redirect handles navigation; post-frame fallback if refresh races.
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
              } else if (state is AuthRegisterOtpError) {
                _pinController.clear();
              } else if (state is AuthOtpSent) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mã OTP đã được gửi lại')),
                );
                _pinController.clear();
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              final inlineError = state is AuthRegisterOtpError
                  ? state.message
                  : null;
              final canVerify =
                  !isLoading && _pinController.text.trim().length == 6;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Xác minh email',
                    style: GoogleFonts.lexend(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhập mã 6 số đã gửi tới ${_maskEmail(widget.extra.email)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
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
                  if (inlineError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      inlineError,
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
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Xác nhận',
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
                          ? 'Gửi lại sau ${_resendSeconds}s'
                          : 'Gửi lại mã OTP',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
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
    );
  }
}
