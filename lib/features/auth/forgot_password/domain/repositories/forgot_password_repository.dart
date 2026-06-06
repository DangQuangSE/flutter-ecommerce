import 'package:flutter_ecommerce/core/errors/result.dart';

abstract interface class ForgotPasswordRepository {
  Future<Result<String>> requestOtp({required String email});

  Future<Result<String>> verifyOtp({
    required String email,
    required String otpCode,
  });

  Future<Result<void>> resetPassword({
    required String forgotPasswordToken,
    required String newPassword,
  });
}
