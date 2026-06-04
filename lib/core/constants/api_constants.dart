abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String registerRequestOtp = '/api/auth/register/request-otp';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String register = '/api/auth/register';
  static const String resendOtp = '/api/auth/resend-otp';

  // Forgot password — verify body uses `otpCode` (not register's `otp`).
  // request-otp: { email } → message (neutral), data: null
  // verify-otp: { email, otpCode } → data: { message, forgotPasswordToken }
  // reset: { forgotPasswordToken, newPassword }
  static const String forgotPasswordRequestOtp =
      '/api/forgot-password/request-otp';
  static const String forgotPasswordVerifyOtp =
      '/api/forgot-password/verify-otp';
  static const String forgotPasswordReset = '/api/forgot-password/reset';

  // TODO: align with backend when product/cart APIs are wired
  static const String products = '/products';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';
}
