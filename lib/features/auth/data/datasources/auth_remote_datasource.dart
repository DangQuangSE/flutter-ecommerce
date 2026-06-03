import 'package:flutter_ecommerce/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<void> requestRegistrationOtp({required String email});

  Future<void> verifyOtp({required String email, required String otp});

  Future<void> register({required String email, required String password});

  Future<void> resendOtp({required String email});

  Future<void> logout();
}
