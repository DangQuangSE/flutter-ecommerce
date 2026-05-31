import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> register({
    required String email,
    required String password,
    required String name,
  });

  Future<Result<void>> logout();

  Future<Result<UserEntity?>> getCurrentUser();
}
