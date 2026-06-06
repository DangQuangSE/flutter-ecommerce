import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/utils/extensions/string_extensions.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_bloc.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_event.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_state.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/models/forgot_password_otp_extra.dart';

class ForgotPasswordEmailPage extends StatefulWidget {
  const ForgotPasswordEmailPage({super.key});

  @override
  State<ForgotPasswordEmailPage> createState() =>
      _ForgotPasswordEmailPageState();
}

class _ForgotPasswordEmailPageState extends State<ForgotPasswordEmailPage> {
  bool _hasNavigatedToOtp = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _hasNavigatedToOtp = false);
      context.read<ForgotPasswordBloc>().add(
            ForgotPasswordEmailSubmitted(email: _emailController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.goNamed(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
            listener: (context, state) {
              // BE returns neutral success even when email may not exist — always
              // navigate on 2xx so we do not leak account enumeration.
              if (state is ForgotPasswordOtpSent && !_hasNavigatedToOtp) {
                _hasNavigatedToOtp = true;
                context.pushNamed(
                  AppRoutes.forgotPasswordOtp,
                  extra: ForgotPasswordOtpExtra(
                    email: state.email,
                    neutralMessage: state.neutralMessage,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is ForgotPasswordLoading;
              final apiError = state is ForgotPasswordError ? state.message : null;

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Quên mật khẩu',
                      style: GoogleFonts.lexend(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhập email đã đăng ký để nhận mã OTP đặt lại mật khẩu.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'EMAIL',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'email@example.com',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!email.isValidEmail) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    if (apiError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        apiError,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: isLoading ? null : _onSubmit,
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
                              'Tiếp tục',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
