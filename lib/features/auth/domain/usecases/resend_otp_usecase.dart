import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository _repository;

  const ResendOtpUseCase(this._repository);

  Future<Result<void>> call({required String email}) {
    return _repository.resendOtp(email: email);
  }
}
