import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/repositories/forgot_password_repository.dart';

class ForgotPasswordRequestOtpUseCase {
  final ForgotPasswordRepository _repository;

  const ForgotPasswordRequestOtpUseCase(this._repository);

  Future<Result<String>> call({required String email}) {
    return _repository.requestOtp(email: email);
  }
}
