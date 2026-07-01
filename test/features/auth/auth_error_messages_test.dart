import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/features/auth/presentation/utils/auth_error_messages.dart';

void main() {
  group('mapRegisterOtpFailureMessage', () {
    test('wrong OTP returns OTP không hợp lệ', () {
      const failure = NetworkFailure(
        'OTP code is incorrect',
        statusCode: 400,
      );
      expect(
        mapRegisterOtpFailureMessage(failure),
        'OTP không hợp lệ',
      );
    });

    test('expired OTP keeps specific message', () {
      const failure = NetworkFailure(
        'OTP has expired',
        statusCode: 400,
      );
      expect(
        mapRegisterOtpFailureMessage(failure),
        'Mã OTP đã hết hạn. Vui lòng gửi lại mã mới.',
      );
    });
  });

  group('mapRegisterFailureMessage', () {
    test('email exists returns current Vietnamese string', () {
      const failure = NetworkFailure(
        'Email already exists',
        statusCode: 409,
      );
      expect(
        mapRegisterFailureMessage(failure),
        'Email này đã được đăng ký. Vui lòng đăng nhập hoặc dùng email khác.',
      );
    });
  });
}
