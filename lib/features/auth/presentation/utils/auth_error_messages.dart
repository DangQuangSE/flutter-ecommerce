import 'package:flutter_ecommerce/core/errors/failures.dart';

const _emailExistsMessage =
    'Email này đã được đăng ký. Vui lòng đăng nhập hoặc dùng email khác.';

bool isRegisterEmailExistsFailure(Failure failure) {
  if (failure is NetworkFailure && failure.statusCode == 409) {
    return true;
  }
  return failure.message.toLowerCase().contains('already exists');
}

String mapRegisterFailureMessage(Failure failure) {
  if (isRegisterEmailExistsFailure(failure)) {
    return _emailExistsMessage;
  }
  final message = failure.message.trim();
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
  return message.isEmpty ? 'Không thể đăng nhập. Vui lòng thử lại.' : message;
}
