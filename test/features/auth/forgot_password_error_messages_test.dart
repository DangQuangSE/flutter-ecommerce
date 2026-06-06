import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/utils/forgot_password_error_messages.dart';

void main() {
  test('forgot password API paths match backend', () {
    expect(
      ApiConstants.forgotPasswordRequestOtp,
      '/api/forgot-password/request-otp',
    );
    expect(
      ApiConstants.forgotPasswordVerifyOtp,
      '/api/forgot-password/verify-otp',
    );
    expect(ApiConstants.forgotPasswordReset, '/api/forgot-password/reset');
  });

  test('mapForgotPasswordRequestFailure translates 429 OTP rate limit', () {
    expect(
      mapForgotPasswordRequestFailure(
        const NetworkFailure(
          'You are requesting OTP too frequently. Please try again in a few seconds',
          statusCode: 429,
        ),
      ),
      forgotPasswordOtpRateLimitMessage,
    );
  });

  test('mapForgotPasswordOtpFailure normalizes distinct BE messages', () {
    expect(
      mapForgotPasswordOtpFailure(
        const NetworkFailure('Invalid OTP', statusCode: 400),
      ),
      forgotPasswordOtpGenericError,
    );
    expect(
      mapForgotPasswordOtpFailure(
        const NetworkFailure('OTP code is incorrect', statusCode: 400),
      ),
      forgotPasswordOtpGenericError,
    );
  });
}
