import 'package:flutter_ecommerce/core/errors/failures.dart';

const forgotPasswordOtpGenericError =
    'Mã OTP không đúng hoặc đã hết hạn. Vui lòng thử lại.';

const forgotPasswordOtpRateLimitMessage =
    'Bạn gửi yêu cầu OTP quá nhanh. Vui lòng thử lại sau vài giây.';

bool _isOtpRateLimitFailure(Failure failure) {
  if (failure is NetworkFailure && failure.statusCode == 429) {
    return true;
  }
  final lower = failure.message.toLowerCase();
  return lower.contains('requesting otp too frequently') ||
      lower.contains('otp too frequently');
}

/// Normalizes verify OTP failures so distinct BE messages cannot enumerate accounts.
String mapForgotPasswordOtpFailure(Failure failure) {
  if (_isOtpRateLimitFailure(failure)) {
    return forgotPasswordOtpRateLimitMessage;
  }
  return forgotPasswordOtpGenericError;
}

String mapForgotPasswordResetFailure(Failure failure) {
  final message = failure.message.trim();
  if (message.isEmpty) {
    return 'Không thể đặt lại mật khẩu. Vui lòng thử lại.';
  }
  return message;
}

String mapForgotPasswordRequestFailure(Failure failure) {
  if (_isOtpRateLimitFailure(failure)) {
    return forgotPasswordOtpRateLimitMessage;
  }
  final message = failure.message.trim();
  return message.isEmpty ? 'Không thể gửi mã OTP. Vui lòng thử lại.' : message;
}
