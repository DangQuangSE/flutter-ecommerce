/// Authentication feature strings (login, register, OTP, forgot password).
abstract final class AuthStrings {
  static const String appDisplayName = 'Flutter E-Commerce';
  static const String googleSignInSetup = 'Đăng nhập bằng Google đang được thiết lập';
  static const String registerSuccessLoginPrompt = 'Đăng ký thành công! Vui lòng đăng nhập.';
  static const String forgotPasswordResetSuccess =
      'Đặt lại mật khẩu thành công. Vui lòng đăng nhập.';
  static const String otpResent = 'Mã OTP đã được gửi lại';
  static const String otpVerifyEmailTitle = 'Xác minh email';
  static String otpSentToEmail(String email) => 'Nhập mã 6 số đã gửi tới $email';
  static const String otpConfirm = 'Xác nhận';
  static String otpResendCountdown(int seconds) => 'Gửi lại sau ${seconds}s';
  static const String otpResendCode = 'Gửi lại mã OTP';
  static const String forgotPasswordOtpTitle = 'Nhập mã OTP';
  static const String forgotPasswordOtpHelp =
      'Nếu bạn không nhận được mã, kiểm tra email hoặc quay lại.';
  static const String forgotPasswordResendShort = 'Gửi lại mã';
  static const String forgotPasswordBackToEmail = 'Quay lại nhập email';
  static const String authTagline = 'Hiệu suất tối đa. Khởi đầu ngay.';
  static const String loginTitle = 'Đăng nhập';
  static const String loginSubmit = 'Đăng nhập';
  static const String loginOrDivider = 'Hoặc';
  static const String googleLogoLetter = 'G';
  static const String googleBrandName = 'Google';
  static const String registerTitle = 'Đăng ký';
  static const String emailLabel = 'EMAIL';
  static const String passwordLabel = 'MẬT KHẨU';
  static const String emailHint = 'vvd@example.com';
  static const String passwordHint = '••••••••';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String emailRequired = 'Vui lòng nhập email';
  static const String emailInvalid = 'Email không đúng định dạng';
  static const String passwordRequired = 'Vui lòng nhập mật khẩu';
  static String passwordMinLength(int n) => 'Mật khẩu phải chứa ít nhất $n ký tự';
  static const String termsPrefix = 'Bằng việc đăng nhập, bạn đồng ý với ';
  static const String termsOfService = 'Điều khoản dịch vụ';
  static const String andConnector = ' và ';
  static const String privacyPolicy = 'Chính sách bảo mật';
  static const String termsSuffix = ' của chúng tôi.';
}
