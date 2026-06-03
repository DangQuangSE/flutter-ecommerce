import 'package:flutter_ecommerce/features/auth/data/models/auth_me_model.dart';
import 'package:flutter_ecommerce/features/auth/data/models/login_response_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<LoginResponseModel> refreshAccessToken();

  Future<AuthMeModel> fetchMe();

  Future<void> requestRegistrationOtp({required String email});

  Future<void> verifyOtp({required String email, required String otp});

  Future<void> register({required String email, required String password});

  Future<void> resendOtp({required String email});

  Future<void> logout();
}
