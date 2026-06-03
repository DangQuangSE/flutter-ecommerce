import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<void>> requestRegistrationOtp({required String email});

  Future<Result<void>> verifyOtp({required String email, required String otp});

  Future<Result<void>> register({
    required String email,
    required String password,
  });

  Future<Result<void>> resendOtp({required String email});

  Future<Result<void>> logout();

  Future<Result<UserEntity?>> getCurrentUser();
}
