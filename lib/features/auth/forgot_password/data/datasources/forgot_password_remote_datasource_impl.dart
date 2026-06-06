import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/data/datasources/forgot_password_remote_datasource.dart';

class ForgotPasswordRemoteDataSourceImpl
    implements ForgotPasswordRemoteDataSource {
  final DioClient _dioClient;

  const ForgotPasswordRemoteDataSourceImpl(this._dioClient);

  @override
  Future<String> requestOtp({required String email}) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.forgotPasswordRequestOtp,
      data: {'email': email.trim().toLowerCase()},
    );
    return _extractMessage(response.data);
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.forgotPasswordVerifyOtp,
      data: {
        'email': email.trim().toLowerCase(),
        'otpCode': otpCode,
      },
    );
    final data = response.data?['data'];
    if (data is Map<String, dynamic>) {
      final token = data['forgotPasswordToken'] as String?;
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }
    throw StateError('Missing forgotPasswordToken in verify response');
  }

  @override
  Future<void> resetPassword({
    required String forgotPasswordToken,
    required String newPassword,
  }) async {
    await _dioClient.dio.post(
      ApiConstants.forgotPasswordReset,
      data: {
        'forgotPasswordToken': forgotPasswordToken,
        'newPassword': newPassword,
      },
    );
  }

  String _extractMessage(Map<String, dynamic>? json) {
    final message = json?['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    return 'If your email exists in our system, an OTP has been sent';
  }
}
