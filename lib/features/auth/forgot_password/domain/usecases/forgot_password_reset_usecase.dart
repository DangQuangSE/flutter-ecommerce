import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/repositories/forgot_password_repository.dart';

class ForgotPasswordResetUseCase {
  final ForgotPasswordRepository _repository;

  const ForgotPasswordResetUseCase(this._repository);

  Future<Result<void>> call({
    required String forgotPasswordToken,
    required String newPassword,
  }) {
    return _repository.resetPassword(
      forgotPasswordToken: forgotPasswordToken,
      newPassword: newPassword,
    );
  }
}
