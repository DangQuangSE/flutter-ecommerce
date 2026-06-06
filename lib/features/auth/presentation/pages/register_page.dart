import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/utils/extensions/string_extensions.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/models/register_otp_extra.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _hasNavigatedToOtp = false;
  bool _hideBlocEmailError = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _hasNavigatedToOtp = false;
        _hideBlocEmailError = false;
      });
      context.read<AuthBloc>().add(
            AuthOtpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Ambient Background Accents (Kinetic/Atmospheric glows)
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.05),
              ),
            ),
          ),

          // 2. Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Anchor (Slanted SPORT PRO heading)
                    Center(
                      child: Column(
                        children: [
                          Transform(
                            transform: Matrix4.skewX(-0.15),
                            alignment: Alignment.center,
                            child: Text(
                              'Sport Pro',
                              style: GoogleFonts.lexend(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                color: AppColors.primary,
                                letterSpacing: -1.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hiệu suất tối đa. Khởi đầu ngay.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Main Container Card
                    Card(
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Tabs
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => context.goNamed(AppRoutes.login),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Đăng nhập',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {}, // Already on register
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppColors.primary,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Đăng ký',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColors.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Form
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: BlocConsumer<AuthBloc, AuthState>(
                              listener: (context, state) {
                                if (state is AuthOtpSent && !_hasNavigatedToOtp) {
                                  _hasNavigatedToOtp = true;
                                  context.pushNamed(
                                    AppRoutes.registerOtp,
                                    extra: RegisterOtpExtra(
                                      email: state.email,
                                      password: state.password,
                                    ),
                                  );
                                }
                              },
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                final emailApiError = _hideBlocEmailError
                                    ? null
                                    : switch (state) {
                                        AuthRegisterAccountExists(:final message) =>
                                          message,
                                        AuthError(:final message) => message,
                                        _ => null,
                                      };

                                return Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Email field
                                      Text(
                                        'EMAIL',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        onChanged: (_) {
                                          if (!_hideBlocEmailError) {
                                            setState(
                                              () => _hideBlocEmailError = true,
                                            );
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'vvd@example.com',
                                          prefixIcon: const Icon(
                                            Icons.mail_outline_rounded,
                                            size: 20,
                                            color: AppColors.textSecondary,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: emailApiError != null
                                                  ? AppColors.error
                                                  : const Color(0xFFC1C6D7),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: emailApiError != null
                                                  ? AppColors.error
                                                  : AppColors.primary,
                                              width: 1.5,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: AppColors.error,
                                            ),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: AppColors.error,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        validator: (v) {
                                          final value = v?.trim() ?? '';
                                          if (value.isEmpty) {
                                            return 'Vui lòng nhập email';
                                          }
                                          if (!value.isValidEmail) {
                                            return 'Email không đúng định dạng';
                                          }
                                          return null;
                                        },
                                      ),
                                      if (emailApiError != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          emailApiError,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.error,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 20),

                                      // Password field
                                      Text(
                                        'MẬT KHẨU',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          hintText: '••••••••',
                                          prefixIcon: const Icon(
                                            Icons.lock_outlined,
                                            size: 20,
                                            color: AppColors.textSecondary,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              size: 20,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFC1C6D7),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: AppColors.primary,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v?.isEmpty ?? true) {
                                            return 'Vui lòng nhập mật khẩu';
                                          }
                                          if ((v?.length ?? 0) < 6) {
                                            return 'Mật khẩu phải chứa ít nhất 6 ký tự';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 28),

                                      // Primary Action "Đăng ký"
                                      ElevatedButton(
                                        onPressed: isLoading ? null : _onSubmit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.accent,
                                          foregroundColor: Colors.white,
                                          elevation: 2,
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
                                                      AlwaysStoppedAnimation<Color>(
                                                          Colors.white),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Đăng ký',
                                                    style: GoogleFonts.lexend(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 1.0,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.arrow_forward,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                    // Footer terms and policy
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'Bằng việc đăng nhập, bạn đồng ý với '),
                            TextSpan(
                              text: 'Điều khoản dịch vụ',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: ' và '),
                            TextSpan(
                              text: 'Chính sách bảo mật',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: ' của chúng tôi.'),
                          ],
                        ),
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
