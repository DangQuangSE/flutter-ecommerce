import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/repositories/forgot_password_repository.dart';

class ForgotPasswordVerifyOtpUseCase {
  final ForgotPasswordRepository _repository;

  const ForgotPasswordVerifyOtpUseCase(this._repository);

  Future<Result<String>> call({
    required String email,
    required String otpCode,
  }) {
    return _repository.verifyOtp(email: email, otpCode: otpCode);
  }
}
