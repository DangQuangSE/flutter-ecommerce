import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/features/auth/presentation/utils/auth_error_messages.dart';

void main() {
  group('mapRegisterOtpFailureMessage', () {
    test('wrong OTP returns OTP không hợp lệ', () {
      final failure = NetworkFailure('OTP code is incorrect', statusCode: 400);
      expect(mapRegisterOtpFailureMessage(failure), 'OTP không hợp lệ');
    });

    test('"invalid otp" exact match returns OTP không hợp lệ', () {
      final failure = NetworkFailure('invalid otp', statusCode: 400);
      expect(mapRegisterOtpFailureMessage(failure), 'OTP không hợp lệ');
    });

    test('expired OTP returns expired message', () {
      final failure = NetworkFailure('OTP has expired', statusCode: 400);
      expect(
        mapRegisterOtpFailureMessage(failure),
        'Mã OTP đã hết hạn. Vui lòng gửi lại mã mới.',
      );
    });

    test('locked after too many attempts returns locked message', () {
      final failure = NetworkFailure(
        'Locked due to too many incorrect attempts',
        statusCode: 400,
      );
      expect(
        mapRegisterOtpFailureMessage(failure),
        'Mã OTP đã bị khóa do nhập sai quá nhiều lần.',
      );
    });

    test('otp must be exactly 6 digits returns digit message', () {
      final failure =
          NetworkFailure('OTP must be exactly 6 digits', statusCode: 400);
      expect(
        mapRegisterOtpFailureMessage(failure),
        'Mã OTP phải có đúng 6 chữ số.',
      );
    });

    test('otp code is required returns required message', () {
      final failure =
          NetworkFailure('OTP code is required', statusCode: 400);
      expect(mapRegisterOtpFailureMessage(failure), 'Vui lòng nhập mã OTP.');
    });

    test('verify otp for this email before registering returns verify message',
        () {
      final failure = NetworkFailure(
        'Verify OTP for this email before registering',
        statusCode: 400,
      );
      expect(
        mapRegisterOtpFailureMessage(failure),
        'Vui lòng xác minh OTP trước khi đăng ký.',
      );
    });

    test('email is not verified returns email unverified message', () {
      final failure =
          NetworkFailure('Email is not verified', statusCode: 400);
      expect(
        mapRegisterOtpFailureMessage(failure),
        'Email chưa được xác minh. Vui lòng xác minh OTP trước.',
      );
    });

    test('"invalid request data" returns data invalid message', () {
      final failure =
          NetworkFailure('invalid request data', statusCode: 400);
      expect(
        mapRegisterOtpFailureMessage(failure),
        'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.',
      );
    });

    test('empty message returns generic OTP message', () {
      final failure = NetworkFailure('', statusCode: 400);
      expect(
        mapRegisterOtpFailureMessage(failure),
        'Mã OTP không đúng hoặc đã hết hạn. Vui lòng thử lại.',
      );
    });

    test('rate limit via 429 status returns rate limit message', () {
      final failure = NetworkFailure('Too many requests', statusCode: 429);
      expect(
        mapRegisterOtpFailureMessage(failure),
        'Bạn gửi yêu cầu OTP quá nhanh. Vui lòng thử lại sau vài giây.',
      );
    });

    test('rate limit via message keyword returns rate limit message', () {
      final failure = NetworkFailure('Requesting OTP too frequently');
      expect(
        mapRegisterOtpFailureMessage(failure),
        'Bạn gửi yêu cầu OTP quá nhanh. Vui lòng thử lại sau vài giây.',
      );
    });

    test('unknown OTP message returns the message as-is', () {
      final failure = NetworkFailure('Some OTP error', statusCode: 400);
      expect(mapRegisterOtpFailureMessage(failure), 'Some OTP error');
    });
  });

  group('isRegisterEmailExistsFailure', () {
    test('409 status returns true', () {
      expect(
        isRegisterEmailExistsFailure(
            NetworkFailure('conflict', statusCode: 409)),
        isTrue,
      );
    });

    test('message contains "already exists" returns true', () {
      expect(
        isRegisterEmailExistsFailure(NetworkFailure('Email already exists')),
        isTrue,
      );
    });

    test('unrelated failure returns false', () {
      expect(
        isRegisterEmailExistsFailure(
            NetworkFailure('network error', statusCode: 500)),
        isFalse,
      );
    });
  });

  group('isRegisterOtpFailure', () {
    test('message contains "otp" returns true', () {
      expect(
        isRegisterOtpFailure(NetworkFailure('invalid otp')),
        isTrue,
      );
    });

    test('message contains "not verified" returns true', () {
      expect(
        isRegisterOtpFailure(NetworkFailure('email not verified')),
        isTrue,
      );
    });

    test('message contains "verify otp" returns true', () {
      expect(
        isRegisterOtpFailure(NetworkFailure('verify otp first')),
        isTrue,
      );
    });

    test('unrelated message returns false', () {
      expect(
        isRegisterOtpFailure(NetworkFailure('network timeout')),
        isFalse,
      );
    });
  });

  group('mapRegisterFailureMessage', () {
    test('email exists returns Vietnamese email exists message', () {
      final failure = NetworkFailure('Email already exists', statusCode: 409);
      expect(
        mapRegisterFailureMessage(failure),
        'Email này đã được đăng ký. Vui lòng đăng nhập hoặc dùng email khác.',
      );
    });

    test('OTP failure routes through OTP mapper', () {
      final failure = NetworkFailure('OTP has expired', statusCode: 400);
      expect(
        mapRegisterFailureMessage(failure),
        'Mã OTP đã hết hạn. Vui lòng gửi lại mã mới.',
      );
    });

    test('"invalid request data" returns data invalid message', () {
      final failure = NetworkFailure('invalid request data', statusCode: 400);
      expect(
        mapRegisterFailureMessage(failure),
        'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.',
      );
    });

    test('empty message returns generic register error', () {
      final failure = NetworkFailure('');
      expect(
        mapRegisterFailureMessage(failure),
        'Không thể đăng ký. Vui lòng thử lại.',
      );
    });

    test('unknown message is returned as-is', () {
      final failure = NetworkFailure('Server maintenance');
      expect(mapRegisterFailureMessage(failure), 'Server maintenance');
    });
  });

  group('isInvalidCredentialsFailure', () {
    test('AuthFailure always returns true', () {
      expect(isInvalidCredentialsFailure(const AuthFailure('auth')), isTrue);
    });

    test('message contains "invalid email or password" returns true', () {
      expect(
        isInvalidCredentialsFailure(
            NetworkFailure('Invalid email or password')),
        isTrue,
      );
    });

    test('message contains "invalid credentials" returns true', () {
      expect(
        isInvalidCredentialsFailure(
            NetworkFailure('Invalid credentials')),
        isTrue,
      );
    });

    test('message contains "unauthorized" returns true', () {
      expect(
        isInvalidCredentialsFailure(NetworkFailure('Unauthorized')),
        isTrue,
      );
    });

    test('unrelated failure returns false', () {
      expect(
        isInvalidCredentialsFailure(NetworkFailure('Server error', statusCode: 500)),
        isFalse,
      );
    });
  });

  group('mapLoginFailureMessage', () {
    test('invalid credentials returns Vietnamese message', () {
      expect(
        mapLoginFailureMessage(const AuthFailure('invalid')),
        'Email hoặc mật khẩu không đúng.',
      );
    });

    test('"invalid request data" returns validation message', () {
      expect(
        mapLoginFailureMessage(NetworkFailure('invalid request data')),
        'Dữ liệu không hợp lệ. Vui lòng kiểm tra email và mật khẩu.',
      );
    });

    test('empty message returns generic login error', () {
      expect(
        mapLoginFailureMessage(NetworkFailure('')),
        'Không thể đăng nhập. Vui lòng thử lại.',
      );
    });

    test('unknown message is returned as-is', () {
      expect(
        mapLoginFailureMessage(NetworkFailure('Service unavailable')),
        'Service unavailable',
      );
    });
  });
}
