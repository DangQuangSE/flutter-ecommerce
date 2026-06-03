import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  const AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // TODO: replace with real login when login flow is wired
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.isEmpty || password.isEmpty) {
      throw const NetworkException('Invalid credentials');
    }
    return UserModel.mock;
  }

  @override
  Future<void> requestRegistrationOtp({required String email}) async {
    await _dioClient.dio.post(
      ApiConstants.registerRequestOtp,
      data: {'email': email.trim().toLowerCase()},
    );
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await _dioClient.dio.post(
      ApiConstants.verifyOtp,
      data: {
        'email': email.trim().toLowerCase(),
        'otp': otp,
      },
    );
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _dioClient.dio.post(
      ApiConstants.register,
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await _dioClient.dio.post(
      ApiConstants.resendOtp,
      data: {'email': email.trim().toLowerCase()},
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
