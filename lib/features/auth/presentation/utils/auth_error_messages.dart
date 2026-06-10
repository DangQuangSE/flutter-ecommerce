import 'package:flutter_ecommerce/core/errors/failures.dart';

const _emailExistsMessage =
    'Email này đã được đăng ký. Vui lòng đăng nhập hoặc dùng email khác.';

bool isRegisterEmailExistsFailure(Failure failure) {
  if (failure is NetworkFailure && failure.statusCode == 409) {
    return true;
  }
  return failure.message.toLowerCase().contains('already exists');
}

bool _isOtpRateLimitFailure(Failure failure) {
  if (failure is NetworkFailure && failure.statusCode == 429) {
    return true;
  }
  final lower = failure.message.toLowerCase();
  return lower.contains('requesting otp too frequently') ||
      lower.contains('otp too frequently');
}

bool isRegisterOtpFailure(Failure failure) {
  final lower = failure.message.toLowerCase();
  return lower.contains('otp') ||
      lower.contains('not verified') ||
      lower.contains('verify otp');
}

String mapRegisterOtpFailureMessage(Failure failure) {
  if (_isOtpRateLimitFailure(failure)) {
    return 'Bạn gửi yêu cầu OTP quá nhanh. Vui lòng thử lại sau vài giây.';
  }

  final lower = failure.message.trim().toLowerCase();
  if (lower.contains('otp code is incorrect') || lower == 'invalid otp') {
    return 'OTP không hợp lệ';
  }
  if (lower.contains('otp has expired')) {
    return 'Mã OTP đã hết hạn. Vui lòng gửi lại mã mới.';
  }
  if (lower.contains('locked due to too many incorrect attempts')) {
    return 'Mã OTP đã bị khóa do nhập sai quá nhiều lần.';
  }
  if (lower.contains('otp must be exactly 6 digits')) {
    return 'Mã OTP phải có đúng 6 chữ số.';
  }
  if (lower.contains('otp code is required')) {
    return 'Vui lòng nhập mã OTP.';
  }
  if (lower.contains('verify otp for this email before registering')) {
    return 'Vui lòng xác minh OTP trước khi đăng ký.';
  }
  if (lower.contains('email is not verified')) {
    return 'Email chưa được xác minh. Vui lòng xác minh OTP trước.';
  }
  if (lower == 'invalid request data') {
    return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
  }

  final message = failure.message.trim();
  return message.isEmpty
      ? 'Mã OTP không đúng hoặc đã hết hạn. Vui lòng thử lại.'
      : message;
}

String mapRegisterFailureMessage(Failure failure) {
  if (isRegisterEmailExistsFailure(failure)) {
    return _emailExistsMessage;
  }
  if (isRegisterOtpFailure(failure)) {
    return mapRegisterOtpFailureMessage(failure);
  }
  final message = failure.message.trim();
  if (message.toLowerCase() == 'invalid request data') {
    return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
  }
  return message.isEmpty ? 'Không thể đăng ký. Vui lòng thử lại.' : message;
}

const _invalidCredentialsMessage = 'Email hoặc mật khẩu không đúng.';

bool isInvalidCredentialsFailure(Failure failure) {
  if (failure is AuthFailure) {
    return true;
  }
  final lower = failure.message.toLowerCase();
  return lower.contains('invalid email or password') ||
      lower.contains('invalid credentials') ||
      lower.contains('unauthorised') ||
      lower.contains('unauthorized');
}

String mapLoginFailureMessage(Failure failure) {
  if (isInvalidCredentialsFailure(failure)) {
    return _invalidCredentialsMessage;
  }
  final message = failure.message.trim();
  if (message.toLowerCase() == 'invalid request data') {
    return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra email và mật khẩu.';
  }
  return message.isEmpty ? 'Không thể đăng nhập. Vui lòng thử lại.' : message;
}
