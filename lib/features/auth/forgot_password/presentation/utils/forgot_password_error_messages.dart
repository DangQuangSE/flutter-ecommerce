import 'package:flutter_ecommerce/core/errors/failures.dart';

const forgotPasswordOtpGenericError =
    'Mã OTP không đúng hoặc đã hết hạn. Vui lòng thử lại.';

/// Normalizes verify OTP failures so distinct BE messages cannot enumerate accounts.
String mapForgotPasswordOtpFailure(Failure failure) {
  if (failure is NetworkFailure && failure.statusCode == 429) {
    final message = failure.message.trim();
    return message.isEmpty
        ? 'Bạn gửi yêu cầu quá nhanh. Vui lòng thử lại sau.'
        : message;
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
  if (failure is NetworkFailure && failure.statusCode == 429) {
    final message = failure.message.trim();
    return message.isEmpty
        ? 'Bạn gửi yêu cầu quá nhanh. Vui lòng thử lại sau.'
        : message;
  }
  final message = failure.message.trim();
  return message.isEmpty
      ? 'Không thể gửi mã OTP. Vui lòng thử lại.'
      : message;
}
