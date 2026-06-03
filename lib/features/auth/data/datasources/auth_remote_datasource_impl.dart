import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/data/models/auth_me_model.dart';
import 'package:flutter_ecommerce/features/auth/data/models/login_response_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  const AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    return LoginResponseModel.fromApiResponse(response.data!);
  }

  @override
  Future<LoginResponseModel> refreshAccessToken() async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.refreshToken,
    );
    return LoginResponseModel.fromApiResponse(response.data!);
  }

  @override
  Future<AuthMeModel> fetchMe() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      ApiConstants.me,
    );
    return AuthMeModel.fromApiResponse(response.data!);
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
    await _dioClient.dio.post(ApiConstants.logout);
  }
}
