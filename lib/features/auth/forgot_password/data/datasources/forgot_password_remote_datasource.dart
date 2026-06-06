abstract interface class ForgotPasswordRemoteDataSource {
  Future<String> requestOtp({required String email});

  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  });

  Future<void> resetPassword({
    required String forgotPasswordToken,
    required String newPassword,
  });
}
